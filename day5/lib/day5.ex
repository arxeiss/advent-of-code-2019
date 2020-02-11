defmodule Day5 do
  defp interpret_code(code, instruction_pointer \\ 0) do
    [instruction | params] = Enum.slice(code, Range.new(instruction_pointer, instruction_pointer + 3))
    opcode = rem(instruction, 100)

    param_modes = [
      trunc(rem(instruction, 1000) / 100),
      trunc(rem(instruction, 10000) / 1000),
      trunc(rem(instruction, 100_000) / 10000)
    ]

    interpret_quadruple(code, opcode, params, param_modes, instruction_pointer)
  end

  defp get_param_value(code, param, param_mode) do
    if(param_mode == 0, do: Enum.at(code, param), else: param)
  end

  defp interpret_quadruple(code, 99, _, _, _) do
    code
  end

  defp interpret_quadruple(code, opcode, [pos | _], _, instruction_pointer) when opcode == 3 do
    code =
      receive do
        {:input, input_value} -> List.replace_at(code, pos, input_value)
      end

    interpret_code(code, instruction_pointer + 2)
  end

  defp interpret_quadruple(code, opcode, [param | _], [param_mode | _], instruction_pointer) when opcode == 4 do
    IO.puts("Thermal Environment Supervision Terminal output: #{get_param_value(code, param, param_mode)}")

    interpret_code(code, instruction_pointer + 2)
  end

  defp interpret_quadruple(code, opcode, params, param_modes, instruction_pointer) when opcode in [1, 2] do
    [param1 | [param2 | [result_position]]] = params
    [param1_mode | [param2_mode | _]] = param_modes

    code =
      case opcode do
        1 ->
          List.replace_at(
            code,
            result_position,
            get_param_value(code, param1, param1_mode) + get_param_value(code, param2, param2_mode)
          )

        2 ->
          List.replace_at(
            code,
            result_position,
            get_param_value(code, param1, param1_mode) * get_param_value(code, param2, param2_mode)
          )
      end

    interpret_code(code, instruction_pointer + 4)
  end

  defp interpret_quadruple(code, opcode, params, param_modes, instruction_pointer) when opcode in [5, 6, 7, 8] do
    [param1 | [param2 | [param3]]] = params
    [param1_mode | [param2_mode | param3_mode]] = param_modes

    {code, instruction_pointer} =
      case opcode do
        5 ->
          if get_param_value(code, param1, param1_mode) != 0,
            do: {code, get_param_value(code, param2, param2_mode)},
            else: {code, instruction_pointer + 3}

        6 ->
          if get_param_value(code, param1, param1_mode) == 0,
            do: {code, get_param_value(code, param2, param2_mode)},
            else: {code, instruction_pointer + 3}

        7 ->
          code =
            List.replace_at(
              code,
              get_param_value(code, param3, param3_mode),
              if(get_param_value(code, param1, param1_mode) < get_param_value(code, param2, param2_mode), do: 1, else: 0)
            )

          {code, instruction_pointer + 4}

        8 ->
          code =
            List.replace_at(
              code,
              get_param_value(code, param3, param3_mode),
              if(get_param_value(code, param1, param1_mode) == get_param_value(code, param2, param2_mode),
                do: 1,
                else: 0
              )
            )

          {code, instruction_pointer + 4}
      end

    interpret_code(code, instruction_pointer)
  end

  @doc """
    Interpret given Intcode
  """
  def interpret_string_code(code, initial_input) do
    send(self(), {:input, initial_input})

    code
    |> String.split(",", trim: true)
    |> Enum.map(fn x -> String.to_integer(x) end)
    |> interpret_code()
  end

  @doc """
    Running part 1 with input numer "1"
  """
  def part1 do
    File.read!('input.txt')
    |> String.replace("\n", "")
    |> interpret_string_code(1)

    "All finished"
  end

  @doc """
    Running part 2 with input number "5"
  """
  def part2 do
    File.read!('input.txt')
    |> String.replace("\n", "")
    |> interpret_string_code(5)

    "All finished"
  end
end
