defmodule Fib do
  def of(0); do 1
  def of(1); do 1
  def of(n); of(n-2)+of(n-1)
end

IO.puts "Starting task"
worker = Task.async fn x -> Fib.of(x) end

IO.puts "Do something else"

IO.puts "Waiting for task"
result = Task.wait(worker)

IO.puts "The result is #{result}"
