defmodule ElixirMathParser do
  @moduledoc """
  Documentation for `ElixirMathParser`.
  """

  defp reduce_to_value({:int, _line, value}, _state) do
    value
  end

  defp reduce_to_value({:add_op, lhs, rhs}, state) do
    reduce_to_value(lhs, state) + reduce_to_value(rhs, state)
  end

  defp reduce_to_value({:sub_op, lhs, rhs}, state) do
    reduce_to_value(lhs, state) - reduce_to_value(rhs, state)
  end

  defp reduce_to_value({:mul_op, lhs, rhs}, state) do
    reduce_to_value(lhs, state) * reduce_to_value(rhs, state)
  end

  defp reduce_to_value({:div_op, lhs, rhs}, state) do
    reduce_to_value(lhs, state) / reduce_to_value(rhs, state)
  end

  defp reduce_to_value({:atom, _line, atom}, state) do
    state[atom]
  end
  
  defp evaluate_tree([{:assign, {:atom, _line, lhs}, rhs} | tail], state) do
    rhs_value = reduce_to_value(rhs, state)
    evaluate_tree(tail, Map.merge(state, %{lhs => rhs_value}))
  end

   defp evaluate_tree([], state) do
     state
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
