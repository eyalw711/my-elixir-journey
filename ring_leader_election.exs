defmodule Spawner do
  def start do
    num_of_agents = 11
    agents = for id <- 1..num_of_agents do
      spawn(LeaderElection, :loop, [self(), id, num_of_agents, nil, nil])
    end
    IO.puts "Spawner: my workers are #{inspect agents}"
    for id <- 1..num_of_agents do
      k = id - 1
      [before, next] = [Enum.at(agents, rem(k-1, num_of_agents)), Enum.at(agents, rem(k+1, num_of_agents))]
      #IO.puts "Spawner orientates id=#{id}"
      send Enum.at(agents, k), {:setup, before, next}
    end
    watch_the_show(0, num_of_agents)
  end

  def watch_the_show(completed, num_of_agents) when completed < num_of_agents do
    receive do
      :complete -> watch_the_show(completed + 1, num_of_agents)
      _ -> IO.puts "Spawner: I don't care what this is..."
    end
  end

  def watch_the_show(completed, num_of_Agents) do #when args are ==
    IO.puts "Show is over."
  end
end

defmodule LeaderElection do
  def loop(spawner, id, num_of_agents, nil, nil) do
    receive do
      {:setup, back, forw} ->
        #IO.puts "id #{id}: back #{inspect back}, forw #{inspect forw}, n.o.a #{num_of_agents}"
        loop(spawner, id, num_of_agents, back , forw, 0, 0)
    end
  end
  def loop(spawner, id, num_of_agents, back , forw, votes_collected, sum_vote) when votes_collected == 0 do
    # here need to gen rand num 0 <= vote <= n-1
    vote = :rand.uniform(num_of_agents) - 1
    IO.puts "id #{id}: vote for #{vote}"
    myself = self()
    send forw, {:vote, myself, vote}
    loop(spawner, id, num_of_agents, back, forw, 1, vote)
  end
  def loop(spawner, id, num_of_agents, back, forw, votes_collected, sum_vote) when votes_collected < num_of_agents do
    receive do
      {:vote, back, vote} ->
        sum_vote_n = rem(sum_vote + vote, num_of_agents)
        send forw, {:vote, self(), vote}
        #IO.puts "id #{id}: have collected #{votes_collected} votes."
        loop(spawner, id, num_of_agents, back, forw, votes_collected + 1, sum_vote_n)
      {_, pid, _} -> IO.puts "id #{id}: did not expect a message from #{inspect pid}!"
    end
  end
  def loop(spawner, id, num_of_agents, back , forw, votes_collected, sum_vote) do #when votes_collected == num_of_agents
    case sum_vote do
      ^id -> IO.puts "id #{id}: I am the Leader!"
      other_id -> IO.puts "id #{id}: declare my leader to be id = #{other_id}"
    end
    send spawner, :complete
  end
end

Spawner.start
