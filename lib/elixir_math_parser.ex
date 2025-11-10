defmodule ElixirMathParser do
  @moduledoc """
  Documentation for `ElixirMathParser`.
  """
  alias ElixirMathParser.Math.Rational
  alias ElixirMathParser.Math.Calc
  alias ElixirMathParser.Math.Conversion

  defp reduce_to_value({:int, _line, value}, _state) do
    {:ok, Rational.new(value)}
  end

  defp reduce_to_value({:float, _line, value}, _state) do
    {:ok, to_string(value) |> Conversion.literal_float_to_rational()}
  end

  defp reduce_to_value({:var, line, var}, state) do
    if !Map.has_key?(state, var) do
      {:error, line, "value not found for " <> to_string(var)}
    else
      {:ok, state[var]}
    end
  end

  defp reduce_to_value({:add_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok, Rational.add(op1, op2)}
    end
  end

  defp reduce_to_value({:sub_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok, Rational.sub(op1, op2)}
    end
  end

  defp reduce_to_value({:mul_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok, Rational.mult(op1, op2)}
    end
  end

  defp reduce_to_value({:div_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok, Rational.div(op1, op2)}
    end
  end

  defp reduce_to_value({:factor_op, lhs}, state) do
    with {:ok, op} <- reduce_to_value(lhs, state),
         true <- Rational.denominator(op) == 1,
         true <- Rational.numerator(op) >= 0 do
      {:ok, Calc.factorial(Rational.numerator(op)) |> Rational.new()}
    else
      {:error, line, reason} -> {:error, line, reason}
      false -> {:error, "must have a positive integer for the factorial"}
    end
  end

  defp reduce_to_value({:exp_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok,
       Calc.pow(
         op1,
         if Rational.denominator(op2) == 1 do
           Rational.numerator(op2)
         else
           op2
         end
       )}
    end
  end

  defp evaluate_tree([{:assign, {:var, line, lhs}, rhs} | tail], state) do
    with {:ok, val} <- reduce_to_value(rhs, state) do
      evaluate_tree(tail, Map.merge(state, %{lhs => val}))
    else
      {:error, reason} -> {:error, line, reason}
    end
  end

  defp evaluate_tree([{:eval, expr} | tail], state) do
    with {:ok, expr} <- reduce_to_value(expr, state) do
      IO.puts(expr)

      evaluate_tree(tail, state)
    end
  end

  defp evaluate_tree([], state) do
    {:ok, state}
  end

  def process_tree(tree) do
    evaluate_tree(tree, %{})
  end

  def parse_file(filename) do
    text = File.read!(filename)
    {:ok, tokens, _line} = :elixir_math_parser_lexer.string(String.to_charlist(text))
    {:ok, tree} = :elixir_math_parser.parse(tokens)
    process_tree(tree)
  end
end
