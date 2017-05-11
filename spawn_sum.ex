defmodule SpawnSum do
  def workerfunc(i, acc, parent) when i <= 1 do
    #:ok = IO.puts "from #{self()} reached the bottom. acc = #{acc}"
    send(parent,  {:result, acc * 2})
  end
  def workerfunc(i, acc, parent) do
    spawn fn ->
      #:ok = IO.puts "from #{self()} i = #{i}, acc = #{acc}. going down..."
      workerfunc(i - 1, 2 * acc, self())
      receive do
        {:result, res} ->
          #:ok = IO.puts "from #{self()} received #{res} and moving up."
          send(parent, {:result, res})
      end #receive
    end #fn
  end #workerfunc
end #module

parent = self()
IO.puts "I am #{inspect parent}"
SpawnSum.workerfunc(10, 1, parent)
receive do
  {:result, res} -> IO.puts "Got #{res}"
end

# prints 1024
# open question: why doens't it work with printing ?
