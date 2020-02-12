defmodule Interpreter do
  def interpret_code(code, instruction_pointer) do
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
    if(param_mode == 0, do: Enum.at(code, param, 0), else: param)
  end

  defp clear_mailbox do
    receive do
      {:input, _} -> clear_mailbox()
    after
      0 -> nil
    end
  end

  defp interpret_quadruple(code, 99, _, _, instruction_pointer) do
    clear_mailbox()
    {:halt, code, instruction_pointer + 1, nil}
  end

  defp interpret_quadruple(code, opcode, [pos | _], _, instruction_pointer) when opcode == 3 do
    code =
      receive do
        {:input, input_value} -> List.replace_at(code, pos, input_value)
      end

    interpret_code(code, instruction_pointer + 2)
  end

  defp interpret_quadruple(code, opcode, [param | _], [param_mode | _], instruction_pointer) when opcode == 4 do
    output = get_param_value(code, param, param_mode)

    {:cont, code, instruction_pointer + 2, output}
  end

  defp interpret_quadruple(code, opcode, params, param_modes, instruction_pointer) when opcode in [1, 2] do
    [param1, param2, result_position] = params
    [param1_mode, param2_mode, _] = param_modes

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
    [param1, param2, param3] = params
    [param1_mode, param2_mode, _] = param_modes

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
              param3,
              if(get_param_value(code, param1, param1_mode) < get_param_value(code, param2, param2_mode), do: 1, else: 0)
            )

          {code, instruction_pointer + 4}

        8 ->
          code =
            List.replace_at(
              code,
              param3,
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
    Parse string into code
  """
  def get_code_from_string(code_string) do
    String.split(code_string, ",", trim: true)
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  def set_initial_inputs(initial_inputs) do
    Enum.each(initial_inputs, fn initial_input ->
      send(self(), {:input, initial_input})
    end)
  end

  @doc """
    Interpret given Intcode until receive halt and return all outputs
  """
  def interpret_string_code_until_halt(code, initial_inputs) do
    set_initial_inputs(initial_inputs)

    get_code_from_string(code)
    |> interpret_code_until_halt(0)
  end

  defp interpret_code_until_halt(code, instruction_pointer) do
    {exit_code, code, instruction_pointer, output} = interpret_code(code, instruction_pointer)

    if exit_code == :halt do
      []
    else
      [output | interpret_code_until_halt(code, instruction_pointer)]
    end
  end
end
