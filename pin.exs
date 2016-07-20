defmodule Greeter do
  
  def for(name, greeting) do
    fn 
      (^name) -> "#{greeting} #{name}"
      (_) -> "I don't know you"
    end
  end
end

mr_valim = Greeter.for("José", "Oi!")
dave = Greeter.for("Dave", "Howdy,")

IO.puts mr_valim.("José")
IO.puts dave.("Dave")
IO.puts dave.("José")