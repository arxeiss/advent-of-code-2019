defmodule Day7 do
  @doc """
    Get thruster signal from amplifiers

    Examples:
      iex> Day7.get_thruster_signal("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0", 0, [4,3,2,1,0])
      43210

      iex> Day7.get_thruster_signal("3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0", 0, 0..4)
      54321

      iex> Day7.get_thruster_signal("3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0", 0, [1,0,4,3,2])
      65210
  """
  def get_thruster_signal(code, initial_input, phase_settings) do
    Enum.reduce(phase_settings, initial_input, fn phase, input ->
      [output] = Interpreter.interpret_string_code_until_halt(code, [phase, input])
      output
    end)
  end

  @doc """
    Find phase settings for maximal thruster signal

    Examples:
      iex> Day7.get_max_thruster_signal("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0", 0)
      {43210, [4,3,2,1,0]}

      iex> Day7.get_max_thruster_signal("3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0", 0)
      {54321, [0,1,2,3,4]}

      iex> Day7.get_max_thruster_signal("3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0", 0)
      {65210, [1,0,4,3,2]}
  """
  def get_max_thruster_signal(code, initial_input) do
    Enum.map(Utils.permutations([0, 1, 2, 3, 4]), fn phase_settings ->
      {get_thruster_signal(code, initial_input, phase_settings), phase_settings}
    end)
    |> Enum.max_by(fn {x, _} -> x end)
  end

  defp cycle_through_loopback(amplifiers, input) do
    {amplifiers, exit_code, output} =
      Enum.reduce(amplifiers, {[], nil, input}, fn {code, instruction_pointer}, {amps, _, input} ->
        Interpreter.set_initial_inputs([input])
        {exit_code, code, instruction_pointer, output} = Interpreter.interpret_code(code, instruction_pointer)

        {[{code, instruction_pointer} | amps], exit_code, output}
      end)

    if exit_code == :halt do
      nil
    else
      amplifiers = Enum.reverse(amplifiers)
      previous_output = cycle_through_loopback(amplifiers, output)
      if previous_output == nil, do: output, else: previous_output
    end
  end

  @doc """
    Examples:
      iex> Day7.get_thruster_signal_with_loopback("3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5", 0, [9,8,7,6,5])
      139629729

      iex> Day7.get_thruster_signal_with_loopback("3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10", 0, [9,7,8,5,6])
      18216
  """
  def get_thruster_signal_with_loopback(code, initial_input, phase_settings) do
    {amplifiers, output} =
      Enum.reduce(phase_settings, {[], initial_input}, fn amp_phase, {amps, input} ->
        Interpreter.set_initial_inputs([amp_phase, input])

        {_, code, instruction_pointer, output} =
          Interpreter.get_code_from_string(code)
          |> Interpreter.interpret_code(0)

        {[{code, instruction_pointer} | amps], output}
      end)

    amplifiers = Enum.reverse(amplifiers)

    cycle_through_loopback(amplifiers, output)
  end

  @doc """
    Find phase settings for maximal thruster signal

    Examples:
      iex> Day7.get_max_thruster_signal_with_loopback("3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5", 0)
      {139629729, [9,8,7,6,5]}

      iex> Day7.get_max_thruster_signal_with_loopback("3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10", 0)
      {18216, [9,7,8,5,6]}
  """
  def get_max_thruster_signal_with_loopback(code, initial_input) do
    Enum.map(Utils.permutations([5, 6, 7, 8, 9]), fn phase_settings ->
      {get_thruster_signal_with_loopback(code, initial_input, phase_settings), phase_settings}
    end)
    |> Enum.max_by(fn {x, _} -> x end)
  end

  @doc """
    Running part 1 with input numer "1"
  """
  def run do
    file_content =
      File.read!('input.txt')
      |> String.replace("\n", "")

    %{
      part1: get_max_thruster_signal(file_content, 0),
      part2: get_max_thruster_signal_with_loopback(file_content, 0)
    }
  end
end
