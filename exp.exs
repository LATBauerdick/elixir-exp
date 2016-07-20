defmodule Exp do
  @author "LATBauerdick"
  @version 5.6
  def get_author,   do: @author
  def get_version,  do: @version
###########################################################

  def doc do
    IO.write """
        example for Heredocs
        in the module Exp
    """
  end

  def open_file(s \\ "/etc/passwd") do
    case File.open(s) do
    { :ok, file } ->
      IO.puts "First line: #{IO.read(file, :line)}"
    { :error, reason } ->
      IO.puts :stderr, "Failed to open file #{s}: #{:file.format_error(reason)}"
    end
  end

  defmodule FizzBuzz do
    def upto1(n) when n>0, do: 1..n |> Enum.map(&_fb1/1)
    defp _fb1(n), do: _fw(n, rem(n,3), rem(n,5))
    defp _fw(_n,0,0), do: "FizzBuzz"
    defp _fw(_n,0,_), do: "Fizz"
    defp _fw(_n,_,0), do: "Buzz"
    defp _fw(n,_,_), do: n

    def upto(n) when n>0, do: 1..n |> Enum.map(&_fb/1)
    defp _fb(n) do
      cond do
        rem(n,3) == 0 and rem(n,5) == 0 -> "FizzBuzz"
        rem(n,3) == 0 -> "Fizz"
        rem(n,5) == 0 -> "Buzz"
        true -> n
      end
    end
    def upto2(n) when n>0 do
      for i <- 1..n do
        case {rem(i,3), rem(i,5), i} do
        {0, 0, _} -> "FizzBuzz"
        {0, _, _}  -> "Fizz"
        {_, 0, _}  -> "Buzz"
        {_, _, i}  -> i
        end
      end
    end

  end

  def fizzbuzz_upto(n) when n>0, do: _upto(1, n, [])
  defp _upto(_current, 0, result), do: Enum.reverse result
  defp _upto(current, left, result) do
    next_answer =
      cond do
        rem(current, 3) == 0 and rem(current, 5) == 0 -> "FizzBuzz"
        rem(current, 3) == 0 -> "Fizz"
        rem(current, 5) == 0 -> "Buzz"
        true -> current
      end
    _upto(current+1, left-1, [next_answer | result])
  end


  def long_map_reduce, do:
    IO.puts File.stream!("/usr/share/dict/words") |> center

  def center(strings) do
    strings
    |> Enum.map_reduce(0, &accumulate_max_length(&1, &2))
    |> center_strings_in_field
    |> Enum.each(&(IO.puts(&1)))
  end
  # map_reduce creates list of {string, length} and max length
  defp accumulate_max_length(string, max_length_so_far) do
    l = String.length(string)
    { {string, l}, max(l, max_length_so_far)}
  end
  defp center_strings_in_field( {strings, field_width} ) do
  # strings has the list of {string, length} tuples
    strings |> Enum.map(&center_one_string(field_width, &1))
  end
  defp center_one_string(field_width, {string, length}) do
    ~s[#{String.duplicate(" ", div(field_width - length, 2))}#{string}]
  end

  def anagram?(w1 \\ 'i am lor∂ vol∂emort',w2 \\ 'tom marvolo ri∂∂le '), do:
    Enum.sort(w1) == Enum.sort(w2)

  def primes_up_to(n) do
    range = span(2,n)
    range -- (for a <- range, b <- range, a <= b, a*b<=n, do: a*b)
  end

  def comprehensions do
    for x <- [ 1,2 ], y <- [ 5,6 ], do: x*y
      |> IO.inspect

    first8 = [ 1,2,3,4,5,6,7,8 ]
    for x <- first8, y <- first8, x >= y, rem(x*y,10)==0, do:
      { x, y } |> IO.inspect
    reports = [ dalls: :hot, minneapolis: :cold, dc: :muggy, la: :smoggy ]
    for { city, weather } <- reports, do: { weather, city }
      |> IO.inspect
    for x <- ~w{ cat dog ants }, into: IO.stream(:stdio, :line), do: "<<#{x}>>\n"
  end

  def bitstrings(s \\ "hello" ) do
# have fun with bitstrings from string s
    bin = <<3 :: size(2), 5 :: size(4), 1 :: size(2)>>
    :io.format("binary: ~-8.2b~n", :binary.bin_to_list(bin))
    IO.puts "byte size is #{byte_size bin}"

    for << ch <- s >>, do: ch |> IO.inspect
    for << ch <- s >>, do: <<ch>> |> IO.inspect
    for << << b1::size(2), b2::size(3), b3::size(3) >> <- s >>, do: "0#{b1}#{b2}#{b3}" # print octal rep
      |> IO.puts
    << _sign::size(1), exp::size(11), mantissa::size(52) >> =
      << 3.14159::float >>
    (1 + mantissa / :math.pow(2,52)) * :math.pow(2, exp-1023)
  end

  def stream_fun do
    Stream.cycle(~w{ green white }) |>
    Stream.zip(1..5) |>
    Enum.map(fn {class, value} -> ~s{<tr class="#{class}"><td>#{value}</td></tr>\n} end) |>
    IO.puts

    Stream.repeatedly(&:random.uniform/0) |> Enum.take(3) |> IO.inspect

    Stream.iterate(2, &(&1*&1)) |> Enum.take(5) |> IO.inspect
    Stream.iterate([], &([&1])) |> Enum.take(5) |> IO.inspect

    Stream.unfold({0,1}, fn {f1, f2} -> {f1, {f2, f1+f2}} end) |> Enum.take(25) |> IO.inspect

    Stream.resource( fn -> File.open!("/etc/passwd") end,
                    fn file ->
                          case IO.read(file, :line) do
                            data when is_binary(data) -> {[data], file}
                            _ -> {:halt, file}
                          end
                    end,
                    fn file-> File.close(file) end
                  ) |> Enum.take(20) |> Enum.drop(18) |> IO.inspect
  end

  def enum_vs_stream do
    with {t, _} = :timer.tc(
                    fn -> Enum.map(1..10_000_000, &(&1+1))
                          |> Enum.take(5) end,
                    []
                  ),
    do: IO.puts "Enum   takes #{t/1_000} msec"
    with {t, _} = :timer.tc(
                    fn -> Stream.map(1..10_000_000, &(&1+1))
                          |> Enum.take(5) end,
                    []
                  ),
    do: :io.format "Stream takes ~.3f msec~n", [t/1_000]
  end

  def longest_word, do:
    IO.puts File.stream!("/usr/share/dict/words")
    |> Enum.max_by(&String.length/1)

  def lp, do:
      with  {:ok, file}   = File.open("/etc/passwd"),
            content       = IO.read(file, :all),
            :ok           = File.close(file),
            [_, uid, gid] = Regex.run(~r/_lp:.*?:(\d+):(\d+)/, content),
      do: "Group: #{gid}, User: #{uid}"


  def flatten(list), do: _f(list, [])
  defp _f([h|t], tail) when is_list(h), do: _f(h, _f(t, tail))
  defp _f([h|t], tail), do: [h|_f(t, tail)]
  defp _f([], tail), do: tail

  def all?(e, f \\ fn x -> x end)
  def all?([], _f), do: true
  def all?([h|t], f), do: if f.(h), do: all?(t, f), else: false


  def deal(n \\ 13), do:
    (for r<-'23456789TJQKA', s<-'CDHS', do: [s,r]) |> Enum.shuffle |> Enum.take(n)

  def span(_f=t, t), do: [t]
  def span(f, t) when f<t, do: [f|span(f+1,t)]

  def caesar([],_s), do: []
  def caesar([h|t],s) do
    [ rem(h-?a + s, ?z-?a+1) + ?a| caesar(t,s)]
  end

  def max([h]), do: h
  def max([h|t]), do: Kernel.max h, max t

  def mapsum([],_), do: 0
  def mapsum([h|t], f), do: f.(h)+mapsum(t,f)

  def reduce([],v,_), do: v
  def reduce([h|t],v,f), do: reduce(t, f.(h,v), f)

  def sum(list), do: _sum(list,0)
  defp _sum([], total), do: total
  defp _sum([h|t], total), do: _sum(t, h+total)

  def sum2([]), do: 0
  def sum2([h|t]), do: h+sum2(t)


  def len([]),      do: 0
  def len([_h|t]),  do: 1+len(t)

  def map([], _f),  do: []
  def map([h|t],f), do: [f.(h) | map(t,f)]

  def guess(a, r = l..h) do
    g = div(l+h,2)
    IO.puts "Is it #{g}?"
    _guess(a,g,r)
  end
  defp _guess(a, a, _), do: IO.puts "yes, it's #{a}"
  defp _guess(a, g, _l..h) when g<a, do: guess(a, g+1..h)
  defp _guess(a, g, l.._h) when g>a, do: guess(a,l..g-1)


  def double(n), do: n * 2
  def triple(n), do: n * 3
  def quadruple(n), do: 2*double(n)
  def of(0), do: 1
  def of(n) when n>0 , do: n * of(n-1)
  def fib(1), do: 1
  def gcd(x,y), do:
    with f = fn
                  x, 0 -> x
                  x, y -> gcd(y, rem(x,y))
                end,
    do: f.(x,y)

  def e(range), do:
    range |> Enum.map(&(&1*&1))
          |> Enum.filter(&(&1<40))
end
IO.puts "Exp v. #{Exp.get_version} was written by #{Exp.get_author}"
