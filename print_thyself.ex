#print thyself
stream = File.stream!("print_thyself.ex")
Enum.take(stream, 3) |> IO.puts
