defmodule Interpreter do
  def interpret_code(code, instruction_pointer) do
    instruction = Map.get(code, instruction_pointer)
    params = Map.take(code, Enum.to_list((instruction_pointer + 1)..(instruction_pointer + 3))) |> Map.values()
    opcode = rem(instruction, 100)

    param_modes = [
      trunc(rem(instruction, 1000) / 100),
      trunc(rem(instruction, 10000) / 1000),
      trunc(rem(instruction, 100_000) / 10000)
    ]

    interpret_quadruple(code, opcode, params, param_modes, instruction_pointer)
  end

  defp get_param_value(code, param, param_mode) do
    case param_mode do
      0 -> Map.get(code, param, 0)
      1 -> param
      2 -> Map.get(code, param + Map.get(code, :rel_base, 0), 0)
    end
  end

  defp get_param_address(code, param, param_mode) do
    case param_mode do
      0 -> param
      1 -> raise "Param address cannot be in immediate mode"
      2 -> param + Map.get(code, :rel_base, 0)
    end
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

  defp interpret_quadruple(code, opcode, [param | _], [param_mode | _], instruction_pointer) when opcode == 3 do
    code =
      receive do
        {:input, input_value} ->
          Map.put(code, get_param_address(code, param, param_mode), input_value)
      end

    interpret_code(code, instruction_pointer + 2)
  end

  defp interpret_quadruple(code, opcode, [param | _], [param_mode | _], instruction_pointer) when opcode == 4 do
    output = get_param_value(code, param, param_mode)

    {:cont, code, instruction_pointer + 2, output}
  end

  defp interpret_quadruple(code, opcode, [param | _], [param_mode | _], instruction_pointer) when opcode == 9 do
    param_value = get_param_value(code, param, param_mode)
    code = Map.update(code, :rel_base, param_value, fn val -> val + param_value end)

    interpret_code(code, instruction_pointer + 2)
  end

  defp interpret_quadruple(code, opcode, params, param_modes, instruction_pointer) when opcode in [1, 2] do
    [param1, param2, result_position] = params
    [param1_mode, param2_mode, result_mode] = param_modes

    code =
      case opcode do
        1 ->
          Map.put(
            code,
            get_param_address(code, result_position, result_mode),
            get_param_value(code, param1, param1_mode) + get_param_value(code, param2, param2_mode)
          )

        2 ->
          Map.put(
            code,
            get_param_address(code, result_position, result_mode),
            get_param_value(code, param1, param1_mode) * get_param_value(code, param2, param2_mode)
          )
      end

    interpret_code(code, instruction_pointer + 4)
  end

  defp interpret_quadruple(code, opcode, params, param_modes, instruction_pointer) when opcode in [5, 6] do
    [param1, param2 | _] = params
    [param1_mode, param2_mode | _] = param_modes

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
      end

    interpret_code(code, instruction_pointer)
  end

  defp interpret_quadruple(code, opcode, params, param_modes, instruction_pointer) when opcode in [7, 8] do
    [param1, param2, param3] = params
    [param1_mode, param2_mode, param3_mode] = param_modes

    {code, instruction_pointer} =
      case opcode do
        7 ->
          code =
            Map.put(
              code,
              get_param_address(code, param3, param3_mode),
              if(get_param_value(code, param1, param1_mode) < get_param_value(code, param2, param2_mode), do: 1, else: 0)
            )

          {code, instruction_pointer + 4}

        8 ->
          code =
            Map.put(
              code,
              get_param_address(code, param3, param3_mode),
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
    |> Stream.with_index()
    |> Stream.map(fn {code, index} -> {index, code} end)
    |> Map.new()
  end

  def set_initial_inputs(initial_inputs) do
    Enum.each(initial_inputs, fn initial_input ->
      send(self(), {:input, initial_input})
    end)
  end

  @doc """
    Interpret given Intcode until receive halt and return all outputs

    iex> Interpreter.interpret_string_code_until_halt("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99", [])
    [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0, 99]

    iex> Interpreter.interpret_string_code_until_halt("1102,34915192,34915192,7,4,7,99,0", [])
    [1219070632396864]

    iex> Interpreter.interpret_string_code_until_halt("104,1125899906842624,99", [])
    [1125899906842624]
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
