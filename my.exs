defmodule LATButil do

  def convert(source, target) do
#
# recursively convert any .JPG file in the source tree
# to a smaller JPG in the target tree
# -- creating directories as required
# -- not overwriting exiting files
#
    dtree(source)
    |> Enum.map(fn p -> a=Path.relative_to(p, source);
            cond do
              a == p -> {source, target}
              true -> {Path.absname(a, source), Path.absname(a, target)}
            end
            end)
    |> Enum.each(fn {s, t} -> IO.puts "#{s} -> #{t}"
                  File.mkdir_p(t)
                  do_convert s, t
                 end)

  end

  defp do_convert(s, t) do
    Path.wildcard(Path.absname("*.JPG",s))
    |> Enum.map(&Path.basename/1)
    |> Enum.filter(fn path -> not File.exists?(Path.absname(path,t)) end)
    |> Enum.map(fn x ->
          [ "convert", Path.absname(x,s), "-resize", "2560x2048",
          "-quality" , "50", Path.absname(x,t) ]
                end)
    |> Stream.map(fn x -> Task.async(fn -> do_sys(x) end) end)
    |> Enum.map(&Task.await/1)

  end
  defp do_sys([cmd | args]), do: System.cmd(cmd, args,
                                    into: IO.stream(:stdio, :line))

  defp dtree(dir) do
    cond do
      File.dir?(dir) ->
        [dir | File.ls!(dir)
          |> Enum.filter(fn name -> File.dir?("#{dir}/#{name}") end)
          |> Enum.map(fn name -> ["#{dir}/#{name}" | dtree("#{dir}/#{name}")] end)
          |> List.flatten()
        ]
      true -> []
    end
  end

end

#      |> Stream.map(​fn​ name -> Task.async(​fn​ -> load_task(name) ​end​) ​end​)

source = "/mnt/P/O/P2016/2016"
###target = "/Users/bauerdic/Dropbox/Pictures/sJPEGs/2016"
target = Path.expand("~/2016")

p = "2016-05" # allow to restrict to sub path
sp = Path.absname(p, source)
tp = Path.absname(p, target)

LATButil.convert sp, tp
