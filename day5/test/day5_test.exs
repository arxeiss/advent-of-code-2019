defmodule Day5Test do
  use ExUnit.Case

  import ExUnit.CaptureIO

  doctest Day5

  test "Interpreting code" do
    code =
      "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"

    assert capture_io(fn -> Day5.interpret_string_code(code, 7) end) ==
             "Thermal Environment Supervision Terminal output: 999\n"

    assert capture_io(fn -> Day5.interpret_string_code(code, 8) end) ==
             "Thermal Environment Supervision Terminal output: 1000\n"

    assert capture_io(fn -> Day5.interpret_string_code(code, 9) end) ==
             "Thermal Environment Supervision Terminal output: 1001\n"
  end
end
