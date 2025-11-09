defmodule ElixirMathParser.Main do
  def process_parse({:error, result}) do
    {line, _file, errors} = result
    err = Enum.join(errors)
    err <> " (line " <> to_string(line) <> ")"
  end

  def process_parse({:ok, tree}) do
    IO.puts("\nParse tree")
    IO.inspect(tree, pretty: true)

    case ElixirMathParser.process_tree(tree) do
      {:ok, _} -> :ok
      {:error, line, reason} -> reason <> " (line " <> to_string(line) <> ")"
      {:error, reason} -> reason
    end
  end

  def main(args) do
    filename = Enum.fetch!(args, 0)

    IO.puts("Parsing #{filename}")
    text = File.read!(filename)

    {:ok, tokens, line} = :elixir_math_parser_lexer.string(String.to_charlist(text))
    IO.puts("Parsed #{filename}, stopped at line #{line}")

    res = process_parse(:elixir_math_parser.parse(tokens))

    if res != :ok do
      IO.puts(:stderr, "\n" <> res)
    end
  end
end
