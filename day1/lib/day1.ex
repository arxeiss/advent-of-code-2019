defmodule Day1 do
  @doc """
    Examples:
        iex> Day1.mass_to_fuel(12)
        2

        iex> Day1.mass_to_fuel(14)
        2

        iex> Day1.mass_to_fuel(1969)
        966

        iex> Day1.mass_to_fuel(100756)
        50346
  """
  def mass_to_fuel(mass) when mass > 0 do
    fuel_mass = max(Integer.floor_div(mass, 3) - 2, 0)

    fuel_mass + mass_to_fuel(fuel_mass)
  end

  def mass_to_fuel(mass) do
    mass
  end

  @doc false
  def get_required_fuel_from_file do
    File.read!('input.txt')
    |> String.split("\n", trim: true)
    |> Enum.map(fn mass -> String.to_integer(mass) end)
    |> Enum.reduce(0, fn mass, acc -> acc + mass_to_fuel(mass) end)
  end
end
