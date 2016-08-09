defmodule Fib do
  def of(0), do: 1
  def of(1), do: 1
  def of(n), do: of(n-2)+of(n-1)
end

IO.puts "Starting task"
worker = Task.async fn -> Fib.of(20) end

IO.puts "Do something else"

IO.puts "Waiting for task"
result = Task.await(worker)

IO.puts "The result is #{result}"
