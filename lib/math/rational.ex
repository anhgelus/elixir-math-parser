# Original author: Qqwy (https://github.com/Qqwy/elixir-rational/), license: MIT
# Modified to work with Elixir 1.19 and to use no deps
defmodule ElixirMathParser.Math.Rational do
  alias ElixirMathParser.Math.Rational

  import Kernel,
    except: [
      div: 2,
      abs: 1,
      floor: 1,
      ceil: 1,
      trunc: 1
    ]

  defmacro __using__(_) do
    quote do
      import Kernel, except: [+: 2, -: 2, *: 2, /: 2, ==: 2, >: 2, <: 2, >=: 2, <=: 2]

      def left + right do
        Rational.add(left, right)
      end

      def left - right do
        Rational.sub(left, right)
      end

      def left * right do
        Rational.mult(left, right)
      end

      def left / right do
        Rational.div(left, right)
      end

      def left == right do
        Rational.eq?(left, right)
      end

      def left > right do
        Rational.gt?(left, right)
      end

      def left < right do
        Rational.lt?(left, right)
      end

      def left >= right do
        Rational.gte?(left, right)
      end

      def left <= right do
        Rational.lte?(left, right)
      end
    end
  end

  @doc """
  A Rational number is defined as a numerator and a denominator.
  Both the numerator and the denominator are integers.
  If you want to match for a rational number, you can do so by matching against this Struct.

  Note that *directly manipulating* the struct, however, is usually a bad idea, as then there are no validity checks, nor wil the rational be simplified.

  Use `Rational.new/2` instead.
  """
  defstruct numerator: 0, denominator: 1
  @type t :: %Rational{numerator: integer(), denominator: pos_integer()}

  @doc """
  Check to see whether something is a ratioal struct.

  On recent OTP versions that expose `:erlang.map_get/2` this function is guard safe.

  iex> require Rational
  iex> Rational.is_rational(Rational.new(1, 2))
  true
  iex> Rational.is_rational(Rational.new(10))
  true
  iex> Rational.is_rational(42)
  false
  iex> Rational.is_rational(%{})
  false
  iex> Rational.is_rational("My quick brown fox")
  false
  """
  defguard is_rational(val)
           when is_map(val) and is_map_key(val, :__struct__) and is_struct(val) and
                  :erlang.map_get(:__struct__, val) == __MODULE__

  @doc """
  Creates a new Rational number.
  This number is simplified to the most basic form automatically.

  Rational numbers with a `0` as denominator are not allowed.

  Note that it is recommended to use integer numbers for the numerator and the denominator.

  ## Examples

      iex> Rational.new(1, 2)
      Rational.new(1, 2)
      iex> Rational.new(100, 300)
      Rational.new(1, 3)
      iex> Rational.new(1.5, 4)
      Rational.new(3, 8)
      iex> Rational.new(Rational.new(3, 2), 3)
      Rational.new(1, 2)
      iex> Rational.new(Rational.new(3, 3), 2)
      Rational.new(1, 2)
      iex> Rational.new(Rational.new(3, 2), Rational.new(1, 3))
      Rational.new(9, 2)
  """
  def new(numerator, denominator \\ 1)

  def new(_numerator, 0) do
    raise ArithmeticError
  end

  def new(numerator, denominator) when is_integer(numerator) and is_integer(denominator) do
    simplify(%Rational{numerator: numerator, denominator: denominator})
  end

  def new(numerator = %Rational{}, denominator = %Rational{}) do
    div(numerator, denominator)
  end

  def new(numerator, denominator = %Rational{}) when is_integer(numerator) do
    div(%Rational{numerator: numerator, denominator: 1}, denominator)
  end

  def new(numerator = %Rational{}, denominator) when is_integer(denominator) do
    div(numerator, %Rational{numerator: denominator, denominator: 1})
  end

  @doc """
  Returns the absolute version of the given number (which might be an integer, float or Rational).

  ## Examples

      iex>Rational.abs(Rational.new(-5, 2))
      Rational.new(5, 2)
  """
  def abs(number) when is_number(number), do: Kernel.abs(number)

  def abs(%Rational{numerator: numerator, denominator: denominator}),
    do: Rational.new(Kernel.abs(numerator), denominator)

  @doc """
  Returns the sign of the given number (which might be an integer, float or Rational)

  This is:

   - 1 if the number is positive.
   - -1 if the number is negative.
   - 0 if the number is zero.

  """
  def sign(%Rational{numerator: numerator}) when Kernel.>(numerator, 0), do: 1
  def sign(%Rational{numerator: numerator}) when Kernel.<(numerator, 0), do: Kernel.-(1)
  def sign(number) when is_number(number) and Kernel.>(number, 0), do: 1
  def sign(number) when is_number(number) and Kernel.<(number, 0), do: Kernel.-(1)
  def sign(number) when is_number(number), do: 0

  @doc """
  Converts the passed *number* as a Rational number, and extracts its denominator.
  For integers returns the passed number itself.

  """
  def numerator(number) when is_integer(number), do: number

  def numerator(%Rational{numerator: numerator}), do: numerator

  @doc """
  Treats the passed *number* as a Rational number, and extracts its denominator.
  For integers, returns `1`.
  """
  def denominator(number) when is_number(number), do: 1
  def denominator(%Rational{denominator: denominator}), do: denominator

  @doc """
  Adds two rational numbers.

      iex> Rational.add(Rational.new(1, 4), Rational.new(2, 4))
      Rational.new(3, 4)

  For ease of use, `rhs` is allowed to be an integer as well:

      iex> Rational.add(Rational.new(1, 4), 2)
      Rational.new(9, 4)

  To perform addition where one of the operands might be another numeric type,
  use `Numbers.add/2` instead, as this will perform the required coercions
  between the number types:

      iex> Rational.add(Rational.new(1, 3), Decimal.new("3.14"))
      ** (FunctionClauseError) no function clause matching in Rational.add/2

      iex> Numbers.add(Rational.new(1, 3), Decimal.new("3.14"))
      Rational.new(521, 150)
  """
  def add(lhs, rhs)

  def add(%Rational{numerator: a, denominator: lcm}, %Rational{numerator: c, denominator: lcm}) do
    Rational.new(Kernel.+(a, c), lcm)
  end

  def add(%Rational{numerator: a, denominator: b}, %Rational{numerator: c, denominator: d}) do
    Rational.new(Kernel.+(a * d, c * b), b * d)
  end

  def add(lhs = %Rational{}, rhs) when is_integer(rhs) do
    add(lhs, Rational.new(rhs))
  end

  @doc """
  Subtracts the rational number *rhs* from the rational number *lhs*.

      iex> Rational.sub(Rational.new(1, 4), Rational.new(2, 4))
      Rational.new(-1, 4)

  For ease of use, `rhs` is allowed to be an integer as well:

      iex> Rational.sub(Rational.new(1, 4), 2)
      Rational.new(-7, 4)

  To perform addition where one of the operands might be another numeric type,
  use `Numbers.sub/2` instead, as this will perform the required coercions
  between the number types:

      iex> Rational.sub(Rational.new(1, 3), Decimal.new("3.14"))
      ** (FunctionClauseError) no function clause matching in Rational.sub/2

      iex> Numbers.sub(Rational.new(1, 3), Decimal.new("3.14"))
      Rational.new(-421, 150)
  """
  def sub(lhs, rhs)

  def sub(lhs = %Rational{}, rhs = %Rational{}), do: add(lhs, minus(rhs))
  def sub(lhs = %Rational{}, rhs) when is_integer(rhs), do: add(lhs, -rhs)

  @doc """
  Negates the given rational number.

  ## Examples

  iex> Rational.minus(Rational.new(5, 3))
  Rational.new(-5, 3)
  """
  def minus(%Rational{numerator: numerator, denominator: denominator}) do
    %Rational{numerator: Kernel.-(numerator), denominator: denominator}
  end

  @doc """
  Multiplies two rational numbers.

      iex> Rational.mult( Rational.new(1, 3), Rational.new(1, 2))
      Rational.new(1, 6)

  For ease of use, allows `rhs` to be an integer as well as a `Rational` struct.

      iex> Rational.mult( Rational.new(1, 3), 2)
      Rational.new(2, 3)

  To perform multiplication where one of the operands might be another numeric type,
  use `Numbers.mult/2` instead, as this will perform the required coercions
  between the number types:

      iex> Rational.mult( Rational.new(1, 3), Decimal.new("3.14"))
      ** (FunctionClauseError) no function clause matching in Rational.mult/2

      iex> Numbers.mult( Rational.new(1, 3), Decimal.new("3.14"))
      Rational.new(157, 150)
  """
  def mult(lhs, rhs)

  def mult(%Rational{numerator: numerator1, denominator: denominator1}, %Rational{
        numerator: numerator2,
        denominator: denominator2
      }) do
    Rational.new(Kernel.*(numerator1, numerator2), Kernel.*(denominator1, denominator2))
  end

  def mult(lhs = %Rational{}, rhs) when is_integer(rhs) do
    mult(lhs, Rational.new(rhs))
  end

  @doc """
  Divides the rational number `lhs` by the rational number `rhs`.

      iex> Rational.div(Rational.new(2, 3), Rational.new(8, 5))
      Rational.new(5, 12)

  For ease of use, allows `rhs` to be an integer as well as a `Ratio` struct.

      iex> Rational.div(Rational.new(2, 3), 10)
      Rational.new(2, 30)

  To perform division where one of the operands might be another numeric type,
  use `Numbers.div/2` instead, as this will perform the required coercions
  between the number types:

      iex> Rational.div(Rational.new(2, 3), Decimal.new(10))
      ** (FunctionClauseError) no function clause matching in Rational.div/2

      iex> Numbers.div(Rational.new(2, 3), Decimal.new(10))
      Rational.new(2, 30)
  """
  def div(lhs, rhs)

  def div(%Rational{numerator: numerator1, denominator: denominator1}, %Rational{
        numerator: numerator2,
        denominator: denominator2
      }) do
    Rational.new(Kernel.*(numerator1, denominator2), Kernel.*(denominator1, numerator2))
  end

  def div(lhs = %Rational{}, rhs) when is_integer(rhs) do
    div(lhs, Rational.new(rhs))
  end

  defmodule ComparisonError do
    defexception message: "These things cannot be compared."
  end

  @doc """
  Compares two rational numbers, returning `:lt`, `:eg` or `:gt`
  depending on whether *a* is less than, equal to or greater than *b*, respectively.

  This function is able to compare rational numbers against integers or floats as well.

  This function accepts other types as input as well, comparing them using Erlang's Term Ordering.
  This is mostly useful if you have a collection that contains other kinds of numbers (builtin integers or floats) as well.
  """
  # TODO enhance this function to work with other number types?
  def compare(%Rational{numerator: a, denominator: b}, %Rational{numerator: c, denominator: d}) do
    compare(Kernel.*(a, d), Kernel.*(b, c))
  end

  def compare(%Rational{numerator: numerator, denominator: denominator}, b) do
    compare(numerator, Kernel.*(b, denominator))
  end

  def compare(a, %Rational{numerator: numerator, denominator: denominator}) do
    compare(Kernel.*(a, denominator), numerator)
  end

  # Fallback using the builting Erlang term ordering.
  def compare(a, b) do
    case {a, b} do
      {a, b} when a > b -> :gt
      {a, b} when a < b -> :lt
      _ -> :eq
    end
  end

  @doc """
  True if *a* is equal to *b*
  """
  def eq?(a, b), do: compare(a, b) |> Kernel.==(:eq)

  @doc """
  True if *a* is larger than or equal to *b*
  """
  def gt?(a, b), do: compare(a, b) |> Kernel.==(:gt)

  @doc """
  True if *a* is smaller than *b*
  """
  def lt?(a, b), do: compare(a, b) |> Kernel.==(:lt)

  @doc """
  True if *a* is larger than or equal to *b*
  """
  def gte?(a, b), do: compare(a, b) in [:eq, :gt]

  @doc """
  True if *a* is smaller than or equal to *b*
  """
  def lte?(a, b), do: compare(a, b) in [:lt, :eq]

  @doc """
  True if *a* is equal to *b*?
  """
  def equal?(a, b), do: compare(a, b) |> Kernel.==(:eq)

  @doc """
  Converts the given *number* to a Float. As floats do not have arbitrary precision, this operation is generally not reversible.
  """
  @spec to_float(Rational.t() | number) :: float
  def to_float(%Rational{numerator: numerator, denominator: denominator}),
    do: Kernel./(numerator, denominator)

  def to_float(number), do: :erlang.float(number)

  @doc """
  Returns a binstring representation of the Rational number.
  If the denominator is `1` it will still be printed wrapped with `Rational.new`.

  ## Examples

      iex> Rational.to_string Rational.new(10, 7)
      "Rational.new(10, 7)"
      iex> Rational.to_string Rational.new(10, 2)
      "Rational.new(5, 1)"
  """
  def to_string(rational)

  def to_string(%Rational{numerator: num, denominator: den}) do
    "#{num}" <> if den != 1, do: "/#{den}", else: ""
  end

  defimpl String.Chars, for: Rational do
    def to_string(rational) do
      Rational.to_string(rational)
    end
  end

  defimpl Inspect, for: Rational do
    def inspect(rational, _) do
      "Rational.new(#{Rational.numerator(rational)}, #{Rational.denominator(rational)})"
    end
  end

  # Simplifies the Rational to its most basic form.
  # Which might result in an integer.
  # Ensures that a `-` is only kept in the numerator.
  defp simplify(rational)

  defp simplify(%Rational{numerator: numerator, denominator: denominator}) do
    gcdiv = gcd(numerator, denominator)
    denominator = Kernel.div(denominator, gcdiv)

    {denominator, numerator} =
      if denominator < 0 do
        {Kernel.-(denominator), Kernel.-(numerator)}
      else
        {denominator, numerator}
      end

    %Rational{numerator: Kernel.div(numerator, gcdiv), denominator: denominator}
  end

  # Calculates the Greatest Common denominator of two numbers.
  defp gcd(a, 0), do: abs(a)

  defp gcd(0, b), do: abs(b)
  defp gcd(a, b), do: gcd(b, Kernel.rem(a, b))

  @doc """
  Rounds a number (rational, integer or float) to the largest whole number less than or equal to num.
  For negative numbers, this means we are rounding towards negative infinity.


  iex> Rational.floor(Rational.new(1, 2))
  0
  iex> Rational.floor(Rational.new(5, 4))
  1
  iex> Rational.floor(Rational.new(-3, 2))
  -2

  """
  def floor(num) when is_integer(num), do: num
  def floor(num) when is_float(num), do: Float.floor(num)

  def floor(%Rational{numerator: numerator, denominator: denominator}),
    do: Integer.floor_div(numerator, denominator)

  @doc """
  Rounds a number (rational, integer or float) to the largest whole number larger than or equal to num.
  For negative numbers, this means we are rounding towards negative infinity.


  iex> Rational.ceil(Rational.new(1, 2))
  1
  iex> Rational.ceil(Rational.new(5, 4))
  2
  iex> Rational.ceil(Rational.new(-3, 2))
  -1
  iex> Rational.ceil(Rational.new(400))
  400

  """
  def ceil(num) when is_float(num), do: Float.ceil(num)
  def ceil(num) when is_integer(num), do: num

  def ceil(num = %Rational{numerator: numerator, denominator: denominator}) do
    floor = Rational.floor(num)

    if rem(numerator, denominator) == 0 do
      floor
    else
      floor + 1
    end
  end

  @doc """
  Returns the integer part of number.

  ## Examples

      iex> Rational.trunc(1.7)
      1
      iex> Rational.trunc(-1.7)
      -1
      iex> Rational.trunc(3)
      3
      iex> Rational.trunc(Rational.new(5, 2))
      2
  """
  @spec trunc(t | number) :: integer
  def trunc(num) when is_integer(num), do: num
  def trunc(num) when is_float(num), do: Kernel.trunc(num)

  def trunc(%Rational{numerator: numerator, denominator: denominator}) do
    Kernel.div(numerator, denominator)
  end
end
