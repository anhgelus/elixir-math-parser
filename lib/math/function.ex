defmodule ElixirMathParser.Math.Function do
  alias ElixirMathParser.Math.Function

  defstruct relation: nil, parameters: %{}

  def is_function(val) when is_map(val) and is_map_key(val, :__struct__) and is_struct(val),
    do: :erlang.map_get(:__struct__, val) == __MODULE__

  def new(relation, parameters) do
    params =
      Enum.with_index(parameters)
      |> Enum.reduce(%{}, fn {v, id}, acc -> Map.merge(acc, %{id => v}) end)

    %Function{relation: relation, parameters: params}
  end

  def eval(fun, parameters) do
    if Enum.count(parameters) != Enum.count(fun.parameters) do
      {:error, "wrong count of parameters"}
    else
      params =
        Enum.with_index(parameters)
        |> Enum.reduce(%{}, fn {v, id}, acc -> Map.merge(acc, %{v => id}) end)

      fun.relation.(fun.parameters, params)
    end
  end
end
