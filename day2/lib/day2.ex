defmodule Day2 do
  @doc """
    Examples:
      iex> Day2.interpret_code([1, 0, 0, 0, 99])
      [2, 0, 0, 0, 99]

      iex> Day2.interpret_code([2, 3, 0, 3, 99])
      [2, 3, 0, 6, 99]

      iex> Day2.interpret_code([2, 4, 4, 5, 99, 0])
      [2, 4, 4, 5, 99, 9801]

      iex> Day2.interpret_code([1, 1, 1, 4, 99, 5, 6, 0, 99])
      [30, 1, 1, 4, 2, 5, 6, 0, 99]
  """
  def interpret_code(code, from \\ 0) do
    interpret_quadruple(code, Enum.slice(code, Range.new(from, -1)), from)
  end

  defp interpret_quadruple(code, [99 | _], _) do
    code
  end

  # defp interpret_quadruple(code, [], _) do
  #   code
  # end

  defp interpret_quadruple(code, [opcode | [op_pos1 | [op_pos2 | [res_pos | _]]]], from) do
    code =
      case opcode do
        1 -> List.replace_at(code, res_pos, Enum.at(code, op_pos1) + Enum.at(code, op_pos2))
        2 -> List.replace_at(code, res_pos, Enum.at(code, op_pos1) * Enum.at(code, op_pos2))
        _ -> code
      end

    interpret_code(code, from + 4)
  end

  @doc """
    Part1
  """
  def interpret_file_input do
    output =
      File.read!('input.txt')
      |> String.replace("\n", "")
      |> String.split(",", trim: true)
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> List.replace_at(1, 12)
      |> List.replace_at(2, 2)
      |> interpret_code()

    [head | _] = output
    head
  end

  @doc """
  Part 2
  """
  def interpret_file_input_with_search do
    input =
      File.read!('input.txt')
      |> String.replace("\n", "")
      |> String.split(",", trim: true)
      |> Enum.map(fn x -> String.to_integer(x) end)

    Enum.find_value(1..100, 0, fn noun ->
      verb =
        Enum.find(1..100, 0, fn verb ->
          output =
            input
            |> List.replace_at(1, noun)
            |> List.replace_at(2, verb)
            |> interpret_code()

          [head | _] = output

          head == 19_690_720
        end)

      if verb > 0 do
        100 * noun + verb
      end
    end)

    # Another solution
    # try do
    #   for noun <- 1..100, verb <- 1..100 do
    #     output =
    #       input
    #       |> List.replace_at(1, noun)
    #       |> List.replace_at(2, verb)
    #       |> interpret_code()

    #     [head | _] = output

    #     if head == 19_690_720 do
    #       throw([:break, noun, verb])
    #     end
    #   end
    # catch
    #   [:break, noun, verb] -> [100 * noun + verb, noun, verb]
    # end
  end
end
