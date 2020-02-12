defmodule Utils do
  @doc """
    Generate all list permutations

    Examples:
      iex> Utils.permutations([0, 1, 2])
      [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
  """
  def permutations([]), do: [[]]

  def permutations(list) do
    for elem <- list,
        rest <- permutations(list -- [elem]) do
      [elem | rest]
    end
  end
end
