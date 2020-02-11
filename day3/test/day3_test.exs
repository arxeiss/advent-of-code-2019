defmodule Day3Test do
  use ExUnit.Case
  doctest Day3

  test "Correct line intersection" do
    # Both vertical but touches
    assert Day3.lines_intersect(
             %{p1: %{x: 10, y: 7}, p2: %{x: 10, y: 13}},
             %{p1: %{x: 10, y: -4}, p2: %{x: 10, y: 7}}
           ) == %{x: 10, y: 7}

    assert Day3.lines_intersect(
             %{p1: %{x: 10, y: 13}, p2: %{x: 10, y: 7}},
             %{p1: %{x: 10, y: -4}, p2: %{x: 10, y: 7}}
           ) == %{x: 10, y: 7}

    assert Day3.lines_intersect(
             %{p1: %{x: 10, y: -4}, p2: %{x: 10, y: 7}},
             %{p1: %{x: 10, y: 13}, p2: %{x: 10, y: 7}}
           ) == %{x: 10, y: 7}

    assert Day3.lines_intersect(
             %{p1: %{x: 10, y: 7}, p2: %{x: 10, y: 13}},
             %{p1: %{x: 10, y: 7}, p2: %{x: 10, y: -4}}
           ) == %{x: 10, y: 7}
  end

  test "Correct line intersection - Both horizontal but touches" do
    assert Day3.lines_intersect(
             %{p1: %{x: 4, y: 5}, p2: %{x: 8, y: 5}},
             %{p1: %{x: 4, y: 5}, p2: %{x: -20, y: 5}}
           ) == %{x: 4, y: 5}

    assert Day3.lines_intersect(
             %{p1: %{x: 8, y: 5}, p2: %{x: 4, y: 5}},
             %{p1: %{x: 4, y: 5}, p2: %{x: -20, y: 5}}
           ) == %{x: 4, y: 5}

    assert Day3.lines_intersect(
             %{p1: %{x: 4, y: 5}, p2: %{x: -20, y: 5}},
             %{p1: %{x: 8, y: 5}, p2: %{x: 4, y: 5}}
           ) == %{x: 4, y: 5}

    assert Day3.lines_intersect(
             %{p1: %{x: 8, y: 5}, p2: %{x: 4, y: 5}},
             %{p1: %{x: -20, y: 5}, p2: %{x: 4, y: 5}}
           ) == %{x: 4, y: 5}
  end

  test "Correct line intersection - Both vertical" do
    assert Day3.lines_intersect(
             %{p1: %{x: 10, y: 5}, p2: %{x: 10, y: -5}},
             %{p1: %{x: 2, y: -4}, p2: %{x: 2, y: -2}}
           ) == nil
  end

  test "Correct line intersection - Both horizontal" do
    assert Day3.lines_intersect(
             %{p1: %{x: 4, y: 5}, p2: %{x: 8, y: 5}},
             %{p1: %{x: -10, y: -7}, p2: %{x: -20, y: -7}}
           ) == nil
  end

  test "Correct line intersection - Perpendicular but not intersect" do
    assert Day3.lines_intersect(
             %{p1: %{x: 4, y: 10}, p2: %{x: 4, y: 5}},
             %{p1: %{x: 5, y: 3}, p2: %{x: 20, y: 3}}
           ) == nil
  end

  test "Correct line intersection - Perpendicular and touch on the end" do
    assert Day3.lines_intersect(
             %{p1: %{x: 4, y: 10}, p2: %{x: 4, y: 3}},
             %{p1: %{x: 4, y: 3}, p2: %{x: 20, y: 3}}
           ) == %{x: 4, y: 3}
  end

  test "Correct line intersection - Perpendicular and scross" do
    assert Day3.lines_intersect(
             %{p1: %{x: 2, y: 10}, p2: %{x: 2, y: -3}},
             %{p1: %{x: 3, y: 5}, p2: %{x: -20, y: 5}}
           ) == %{x: 2, y: 5}
  end
end
