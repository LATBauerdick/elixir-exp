
defmodule Pictures.Process do
  @source "/mnt/P/O/P2016/"
  @subtree "2016/2016-03/2016-03-1" # allow to restrict to sub tree

  ###@target "/Users/bauerdic/Dropbox/Pictures/sJPEGs/2016"
  @target "~/"

  def jpegs do
    sp = Path.absname(@subtree, @source) |> Path.expand
    tp = Path.absname(@subtree, @target) |> Path.expand
    cmd = fn source, target -> [ "cp", "-va", source, target ] end
    {time, _result} = :timer.tc(
      &Pictures.Process.run/3, [sp, tp, cmd]
      )
      :io.format "processing took ~.2f seconds~n", [time/1_000_000.0]
  end
  def sjpegs do
    sp = Path.absname(@subtree, @source) |> Path.expand
    tp = Path.absname(@subtree, @target) |> Path.expand
  # time Pictures.Process.run sp, tp, &convert_cmd/2
    {time, _result} = :timer.tc(
      &Pictures.Process.run/3, [sp, tp, &convert_cmd/2]
      )
      :io.format "processing took ~.2f seconds~n", [time/1_000_000.0]
  end
  defp convert_cmd(source, target), do:
    [ "convert",
      source,
      "-resize", "2560x2048",
      "-quality" , "50",
      target
    ]


  def run(source, target, cmd) do
#
# recursively process any .JPG file in the source tree
# using command structure [cmd, args, ...]
# e.g. use [convert s -resize 100x100 t] to create
#    a smaller JPG in the target tree
# -- creating directories as required
# -- not overwriting exiting files
#
    [source | dtree(source)]
    |> Enum.map(fn p -> a=Path.relative_to(p, source);
                  cond do
                    a == p -> {source, target}
                    true -> {Path.absname(a, source), Path.absname(a, target)}
                  end
                end)
    |> Enum.each(fn {s, t} -> IO.puts "#{s} -> #{t}"
                  File.mkdir_p(t)
                  do_process s, t, cmd
                 end)
  end

  @max_parallel 16
  defp do_process(s, t, cmd) do
    Path.wildcard(Path.absname("*.{JPG,jpg}",s))
    |> Enum.map(&Path.basename/1)
    |> Enum.filter(fn path -> not File.exists?(Path.absname(path,t)) end)
    |> Enum.map(fn x -> cmd.(Path.absname(x,s),Path.absname(x,t)) end)
    |> Enum.chunk(@max_parallel, @max_parallel, [])
    |> Enum.each(fn c -> do_exec(c) end)
  end
  defp do_exec(chunk) do
# exec cmd in chunks of max_parallel
    chunk
    |> Enum.map(fn x -> Task.async(fn -> do_sys(x) end) end)
    |> Enum.map(fn t -> Task.await(t, 120_000) end)
  end

  defp do_sys([cmd | args]) do
#    System.cmd(cmd, args, into: IO.stream(:stdio, :line))
    {time, result} = :timer.tc(
        System, :cmd, ["nice", [cmd | args]]
      )
    {_output, status} = result
    :io.format "processing #{cmd} #{Path.basename(hd(args))}, status ~2B, took ~.2f sec~n",
                [status, time/1_000_000.0]
    result
  end

  defp dtree(dir) do
    cond do
      not File.dir?(dir) -> []
      true -> File.ls!(dir)
          |> Enum.filter(fn name -> File.dir?("#{dir}/#{name}") end)
          |> Enum.map(fn name -> ["#{dir}/#{name}" | dtree("#{dir}/#{name}")] end)
          |> List.flatten()
    end
  end

end
