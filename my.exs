defmodule My do
  def convert(s, t \\ "./") do
    do_sys(["echo",
              "/mnt/P/O/P2016/2016/2016-01/2016-01-2/2016-01-01-DSCF3317.JPG",
              "-resize", "2560x2048", "-quality", "50",
              "./2016-01-01-DSCF3317.JPG"
    ])
    Path.wildcard(s <>"*.JPG")
    |> Enum.map(&Path.basename/1)
    |> Enum.map(fn x ->
          [ "convert", s<>x, "-resize", "2560x2048", "-quality" , "50", t<>x ]
                end)
#    |> Stream.map(fn x -> Task.async(My, :do_cmd, [x]) end)
    |> Stream.map(fn x -> Task.async(fn -> do_sys(x) end) end)
    |> Enum.map(&Task.await/1)
  end
  defp do_sys([cmd | args]), do: System.cmd(cmd, args,
                                    into: IO.stream(:stdio, :line))
end

#      |> Stream.map(​fn​ name -> Task.async(​fn​ -> load_task(name) ​end​) ​end​)

My.convert "/mnt/P/O/P2016/2016/2016-01/2016-01-2/"
