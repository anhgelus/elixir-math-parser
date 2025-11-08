defmodule ElixirMathParser do
  @moduledoc """
  Documentation for `ElixirMathParser`.
  """

  defp reduce_to_value({:int, _line, value}, _state) do
    {:ok, value}
  end

  defp reduce_to_value({:var, _line, var}, state) do
    if !Map.has_key?(state, var) do
      {:error, "value not found for " <> to_string(var)}
    else
      {:ok, state[var]}
    end
  end

  defp reduce_to_value({:add_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok, op1 + op2}
    end
  end

  defp reduce_to_value({:sub_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok, op1 - op2}
    end
  end

  defp reduce_to_value({:mul_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok, op1 * op2}
    end
  end

  defp reduce_to_value({:div_op, lhs, rhs}, state) do
    with {:ok, op1} <- reduce_to_value(lhs, state),
         {:ok, op2} <- reduce_to_value(rhs, state) do
      {:ok, op1 / op2}
    end
  end

  defp evaluate_tree([{:assign, {:var, _line, lhs}, rhs} | tail], state) do
    with {:ok, val} <- reduce_to_value(rhs, state) do
      evaluate_tree(tail, Map.merge(state, %{lhs => val}))
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
