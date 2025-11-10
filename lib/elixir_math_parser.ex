defmodule ElixirMathParser do
  @moduledoc """
  Documentation for `ElixirMathParser`.
  """
  alias ElixirMathParser.Math.Rational
  alias ElixirMathParser.Math.Calc
  alias ElixirMathParser.Math.Conversion
  alias ElixirMathParser.Math.Function

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

  defp reduce_to_value({:eval_func, {:var, line, var}, params}, state) do
    if !Map.has_key?(state, var) do
      {:error, line, "function " <> to_string(var) <> " not found"}
    else
      v = state[var]

      # check if the mult is implicit
      if Rational.is_rational(v) do
        [head | _] = params
        reduce_to_value({:mul_op, {:var, line, var}, head}, state)
      else
        params = Enum.map(params, fn v -> with {:ok, v} <- reduce_to_value(v, state), do: v end)

        with {:ok, v} <- state[var] |> Function.eval(params) do
          {:ok, v}
        else
          {:error, reason} -> {:error, line, reason}
          {:error, line, reason} -> {:error, line, reason}
        end
      end
    end
  end

  defp evaluate_tree([{:assign, {:var, line, lhs}, rhs} | tail], state) do
    with {:ok, val} <- reduce_to_value(rhs, state) do
      evaluate_tree(tail, Map.merge(state, %{lhs => val}))
    else
      {:error, reason} -> {:error, line, reason}
      {:error, line, reason} -> {:error, line, reason}
    end
  end

  defp evaluate_tree([{:eval, expr} | tail], state) do
    with {:ok, expr} <- reduce_to_value(expr, state) do
      IO.puts(expr)

      evaluate_tree(tail, state)
    end
  end

  defp evaluate_tree([{:assign_func, {:var, _line, name}, vars, expr} | tail], state) do
    fun =
      Function.new(
        fn params, given ->
          state =
            Enum.reduce(given, state, fn {v, id}, acc -> Map.merge(acc, %{params[id] => v}) end)

          reduce_to_value(expr, state)
        end,
        Enum.map(vars, fn {:var, _line, name} -> name end)
      )

    evaluate_tree(tail, Map.merge(state, %{name => fun}))
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
