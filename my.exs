defmodule My do
  def convert(s, t \\ "./") do
    {:ok, l} = File.ls(s)
    l
    |> Enum.map(fn x ->
          [ s<>x, "-size 2560x2048", "-quality 50", t<>x] end)
    |> Enum.map(fn x -> System.cmd("echo", x) end)
    |> Enum.each(&IO.inspect/1)
  end
end

My.convert "/mnt/P/O/P2016/2016/2016-01/2016-01-2/"
