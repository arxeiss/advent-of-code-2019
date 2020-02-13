defmodule Day9 do
  def get_boost_keycode(code, initial_input) do
    Interpreter.interpret_string_code_until_halt(code, initial_input)
  end

  def run do
    file_content =
      File.read!('input.txt')
      |> String.replace("\n", "")

    %{
      part1: get_boost_keycode(file_content, [1]),
      part2: get_boost_keycode(file_content, [2])
    }
  end
end
