defmodule ElixirMathParser.Math.Calc do
  alias ElixirMathParser.Math.Rational
  def factorial(n), do: factorial_rec(n, 1)
  defp factorial_rec(n, acc) when n > 0, do: factorial_rec(n - 1, acc * n)
  defp factorial_rec(0, acc), do: acc

  def pow(value, exponent), do: pow_rec(value, exponent, Rational.new(1))

  defp pow_rec(value, exponent, acc) when is_integer(exponent) do
    case exponent do
      0 ->
        acc

      _ when exponent < 0 ->
        pow_rec(Rational.new(1, value), -exponent, acc)

      _ when Kernel.rem(exponent, 2) == 0 ->
        pow_rec(Rational.mult(value, value), Kernel.div(exponent, 2), acc)

      _ ->
        pow_rec(
          Rational.mult(value, value),
          Kernel.div(exponent - 1, 2),
          Rational.mult(acc, value)
        )
    end
  end
end
