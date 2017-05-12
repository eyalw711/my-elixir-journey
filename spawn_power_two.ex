defmodule SpawnPowerTwo do
  def workerfunc(i, acc, parent) when i <= 1 do
    IO.puts "reached the bottom, acc is #{acc}"
    send(parent,  {:result, acc})
  end
  def workerfunc(i, acc, parent) do
    spawn fn ->
      IO.puts "spawned. i = #{i}, acc = #{acc}. going down..."
      workerfunc(i - 1, 2 * acc, self())
      receive do
        {:result, res} ->
          IO.puts "received #{res} and moving up."
          send(parent, {:result, res})
      end #receive
    end #fn
  end #workerfunc
end #module

parent = self()
IO.puts "I am #{inspect parent}"
SpawnPowerTwo.workerfunc(10, 2, parent)
receive do
  {:result, res} -> IO.puts "Got #{res}"
end

# prints:
# I am #PID<0.48.0>
# spawned. i = 10, acc = 2. going down...
# spawned. i = 9, acc = 4. going down...
# spawned. i = 8, acc = 8. going down...
# spawned. i = 7, acc = 16. going down...
# spawned. i = 6, acc = 32. going down...
# spawned. i = 5, acc = 64. going down...
# spawned. i = 4, acc = 128. going down...
# spawned. i = 3, acc = 256. going down...
# spawned. i = 2, acc = 512. going down...
# reached the bottom, acc is 1024
# received 1024 and moving up.
# received 1024 and moving up.
# received 1024 and moving up.
# received 1024 and moving up.
# received 1024 and moving up.
# received 1024 and moving up.
# received 1024 and moving up.
# received 1024 and moving up.
# received 1024 and moving up.
# Got 1024
