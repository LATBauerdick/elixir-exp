
fb = with f = fn 
                0, 0, _ -> "FizzBuzz"
                0, _, _ -> "Fizz"
                _, 0, _ -> "Buzz"
                _, _, c -> c
              end, 
      do: fn n -> f.(rem(n,3), rem(n,5), n) |> IO.puts end

Enum.each (1..100), fb 

values = [1, 2, 3, 4, 5, 6, 7, 8]
mean = with count = Enum.count(values), 
            sum = Enum.sum(values),
        do: sum/count
IO.puts(mean)