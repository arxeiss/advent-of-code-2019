defmodule Day8 do
  defp layer_with_fewest_zeros(layers) do
    Enum.min_by(layers, fn layer ->
      Enum.count(layer, &(&1 == 0))
    end)
  end

  @doc """
    Get checksum of layers

    Examples:
      iex> Day8.get_checksum([[0,0,1,1,2,2,2], [0,0,0,1,2], [0,0,0,0]])
      6
  """
  def get_checksum(layers) do
    layer_to_count_in = layer_with_fewest_zeros(layers)
    Enum.count(layer_to_count_in, &(&1 == 1)) * Enum.count(layer_to_count_in, &(&1 == 2))
  end

  @doc """
    Merge layers into pixels and evaluate them

    Help: 0 - black, 1 - white, 2 - transparent

    Examples:
      iex> Day8.convert_into_image([[0, 2, 2, 2], [1, 1, 2, 2], [2, 2, 1, 2], [0, 0, 0, 0]], 2)
      [[0, 1], [1, 0]]
  """
  def convert_into_image(layers, columns) do
    Enum.zip(layers)
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn pixel_layers ->
      Enum.reduce_while(pixel_layers, 2, fn pixel, _ ->
        case pixel do
          2 -> {:cont, 2}
          val -> {:halt, val}
        end
      end)
    end)
    |> Enum.chunk_every(columns)
  end

  defp print_image(layers, columns) do
    convert_into_image(layers, columns)
    |> Enum.map(fn row ->
      Enum.map(row, fn char -> if(char == 1, do: "X", else: " ") end)
      |> Enum.join()
      |> IO.puts()
    end)

    "Image printed above"
  end

  def run do
    columns = 25
    rows = 6

    layers =
      File.read!('input.txt')
      |> String.replace("\n", "")
      |> String.split("", trim: true)
      |> Enum.map(fn item -> String.to_integer(item) end)
      |> Enum.chunk_every(columns * rows)

    %{
      part1: get_checksum(layers),
      part2: print_image(layers, columns)
    }
  end
end
