defmodule ElixirMathParser.Math.Conversion do
  alias ElixirMathParser.Math.Rational

  def literal_float_to_rational(value) do
    {int, dec} = Integer.parse(value)

    String.graphemes(dec)
    |> Enum.reduce(Rational.new(int), fn v, acc ->
      if v != "." do
        num = Rational.numerator(acc) * 10
        den = Rational.denominator(acc) * 10
        Rational.newRaw(num + String.to_integer(v), den)
      else
        acc
      end
    end)
    |> Rational.simplify()
  end
end
