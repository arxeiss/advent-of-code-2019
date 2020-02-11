defmodule Day3 do
  defp get_end_coordinates(<<direction, vector_length::binary>>, start_x, start_y) do
    vector_length = String.to_integer(vector_length)

    end_coordinates =
      case direction do
        ?U -> {start_x, start_y + vector_length}
        ?R -> {start_x + vector_length, start_y}
        ?D -> {start_x, start_y - vector_length}
        ?L -> {start_x - vector_length, start_y}
      end

    end_coordinates
  end

  @doc """
    Examples:
    iex> Day3.directions_into_lines(["R4", "D5", "L7"]) |> Enum.reverse()
    [
      %{p1: %{x: 0, y: 0}, p2: %{x: 4, y: 0}},
      %{p1: %{x: 4, y: 0}, p2: %{x: 4, y: -5}},
      %{p1: %{x: 4, y: -5}, p2: %{x: -3, y: -5}}
    ]
  """
  def directions_into_lines(vectors) do
    {lines, _} =
      vectors
      |> Enum.reduce({[], {0, 0}}, fn vector, {lines, {start_x, start_y}} ->
        {x, y} = get_end_coordinates(vector, start_x, start_y)

        {[%{p1: %{x: start_x, y: start_y}, p2: %{x: x, y: y}} | lines], {x, y}}
      end)

    lines
  end

  @doc """
    Simplified formular as lines are only horizontal or vertical
  """
  def lines_intersect(line1, line2) do
    {intersect, horizontal, vertical} =
      case [line1, line2] do
        # Both lines are parallel - and touch
        [%{p1: touch}, %{p1: touch}] -> {touch, nil, nil}
        [%{p1: touch}, %{p2: touch}] -> {touch, nil, nil}
        [%{p2: touch}, %{p1: touch}] -> {touch, nil, nil}
        [%{p2: touch}, %{p2: touch}] -> {touch, nil, nil}
        # Both lines are parallel - no intersect
        [%{p1: %{x: x1}, p2: %{x: x1}}, %{p1: %{x: x2}, p2: %{x: x2}}] -> {nil, nil, nil}
        [%{p1: %{y: y1}, p2: %{y: y1}}, %{p1: %{y: y2}, p2: %{y: y2}}] -> {nil, nil, nil}
        # Lines are perpendicular
        [%{p1: %{x: x}, p2: %{x: x}}, %{p1: %{y: y}, p2: %{y: y}}] -> {%{x: x, y: y}, line2, line1}
        [%{p1: %{y: y}, p2: %{y: y}}, %{p1: %{x: x}, p2: %{x: x}}] -> {%{x: x, y: y}, line1, line2}
      end

    # Check if intersect is within line boundaries or outside
    if intersect do
      cond do
        horizontal == nil and vertical == nil ->
          intersect

        intersect.x == vertical.p1.x and Enum.member?(horizontal.p1.x..horizontal.p2.x, intersect.x) and
          intersect.y == horizontal.p1.y and Enum.member?(vertical.p1.y..vertical.p2.y, intersect.y) ->
          intersect

        true ->
          nil
      end
    end
  end

  @doc """
    Part 1 Find smallest distance between intersect and beginning of wire

    Examples:
      iex> elem(Day3.closest_intersect_to_beginning("R75,D30,R83,U83,L12,D49,R71,U7,L72","U62,R66,U55,R34,D71,R55,D58,R83"), 0)
      159

      iex> elem(Day3.closest_intersect_to_beginning("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"), 0)
      135
  """
  def closest_intersect_to_beginning(wire1, wire2) do
    wire1 = wire1 |> String.split(",", trim: true) |> directions_into_lines()
    wire2 = wire2 |> String.split(",", trim: true) |> directions_into_lines()

    lengths_to_intersects =
      wire1
      |> Enum.reduce([], fn line1, acc ->
        Enum.reduce(wire2, acc, fn line2, acc ->
          intersect = lines_intersect(line1, line2)

          if intersect do
            [abs(intersect.x) + abs(intersect.y) | acc]
          else
            acc
          end
        end)
      end)

    min_length =
      lengths_to_intersects
      |> Enum.filter(fn x -> x > 0 end)
      |> Enum.min()

    {min_length, lengths_to_intersects}
  end

  @doc """
    Part 2 Find the smallest sum of wire lengths to the intersection

    Examples:
      iex> elem(Day3.shortest_length_to_intersection("R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"), 0)
      610

      iex> elem(Day3.shortest_length_to_intersection("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"), 0)
      410
  """
  def shortest_length_to_intersection(wire1, wire2) do
    wire1 = wire1 |> String.split(",", trim: true) |> directions_into_lines() |> Enum.reverse()
    wire2 = wire2 |> String.split(",", trim: true) |> directions_into_lines() |> Enum.reverse()

    {wire_lengths_to_intersects, _} =
      wire1
      |> Enum.reduce({[], 0}, fn line1, {acc, wire1_length} ->
        {acc, _} =
          Enum.reduce(wire2, {acc, 0}, fn line2, {acc, wire2_length} ->
            intersect = lines_intersect(line1, line2)
            new_wire2_length = wire2_length + abs(line2.p1.x - line2.p2.x) + abs(line2.p1.y - line2.p2.y)

            if intersect do
              {[
                 wire1_length + abs(line1.p1.x - intersect.x) + abs(line1.p1.y - intersect.y) + wire2_length +
                   abs(line2.p1.x - intersect.x) + abs(line2.p1.y - intersect.y)
                 | acc
               ], new_wire2_length}
            else
              {acc, new_wire2_length}
            end
          end)

        wire1_length = wire1_length + abs(line1.p1.x - line1.p2.x) + abs(line1.p1.y - line1.p2.y)
        {acc, wire1_length}
      end)

    shortest_length =
      wire_lengths_to_intersects
      |> Enum.filter(fn x -> x > 0 end)
      |> Enum.min()

    {shortest_length, wire_lengths_to_intersects}
  end

  @doc """
    Run
  """
  def run do
    [wire1 | [wire2 | _]] =
      File.read!('input.txt')
      |> String.split("\n", trim: true)

    %{
      closest_intersect: closest_intersect_to_beginning(wire1, wire2),
      shortest_wire: shortest_length_to_intersection(wire1, wire2)
    }
  end
end
