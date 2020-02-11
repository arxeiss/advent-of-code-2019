defmodule Day4 do
  @doc """
    Check if two adjacent digits in the password are the same

    Examples:
      iex> Day4.has_same_adjacent_digits('123456')
      false

      iex> Day4.has_same_adjacent_digits('123356')
      true
  """
  def has_same_adjacent_digits(password) do
    [current | rest] = password

    result =
      Enum.reduce_while(rest, current, fn next, current ->
        if next == current, do: {:halt, 0}, else: {:cont, next}
      end)

    result == 0
  end

  @doc """
    Check if two adjacent digits in the password are the same

    Examples:
      iex> Day4.has_exactly_2_same_adjacent_digits('123456')
      false

      iex> Day4.has_exactly_2_same_adjacent_digits('123356')
      true

      iex> Day4.has_exactly_2_same_adjacent_digits('123444')
      false

      iex> Day4.has_exactly_2_same_adjacent_digits('113444')
      true
  """
  def has_exactly_2_same_adjacent_digits(password) do
    Enum.reduce(password, %{}, fn digit, acc ->
      Map.update(acc, digit, 1, fn amount -> amount + 1 end)
    end)
    |> Map.values()
    |> Enum.member?(2)
  end

  @doc """
    Check if digits are increasing or are the same

    Examples:
      iex> Day4.digits_not_decreasing('123456')
      true

      iex> Day4.digits_not_decreasing('123356')
      true

      iex> Day4.digits_not_decreasing('123326')
      false
  """
  def digits_not_decreasing(password) do
    [current | rest] = password

    result =
      Enum.reduce_while(rest, current, fn next, current ->
        if next < current, do: {:halt, 0}, else: {:cont, next}
      end)

    result > 0
  end

  @doc """
    Count how many possible passwords exists in the range

    Examples:
      iex> Day4.count_possibilites(123444, 123467)
      8
  """
  def count_possibilites(from, to) do
    Enum.count(from..to, fn x ->
      x = Integer.to_charlist(x)
      digits_not_decreasing(x) && has_same_adjacent_digits(x)
    end)
  end

  @doc """
    Count how many possible passwords exists in the range with additional rule

    Examples:
      iex> Day4.count_possibilites_additional_rule(123444, 123467)
      7
  """
  def count_possibilites_additional_rule(from, to) do
    Enum.count(from..to, fn x ->
      x = Integer.to_charlist(x)
      digits_not_decreasing(x) && has_exactly_2_same_adjacent_digits(x)
    end)
  end

  @doc """
    Run
  """
  def run do
    from = 273_025
    to = 767_253

    %{
      part1: count_possibilites(from, to),
      part2: count_possibilites_additional_rule(from, to)
    }
  end
end
