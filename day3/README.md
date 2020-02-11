# Day 3: Crossed Wires

> :warning: **SPOILER ALERT** :warning: - The code contains solution for the whole task. Try first to solve it **yourself**. :link: https://adventofcode.com/2019/day/3

---

## How to run

Run iex with mix `iex -S mix`

```elixir
# Run
Day3.run

# Returns part 1 and part 2 together

%{
	#Part 1
	closest_intersect: {
		# The final result
		446,
		# Length of all intersects
		[0, 446, 1031, 690, 1012, 1358, 1060, 972, 2208, 2604, 2264, 2418, 1655, 1152, 1675, 2583, 2019, 2187, 3304, 3901]
	},
	# Part 2
	shortest_wire: {
		# The final result
		9006,
		# Steps to all intersects
		[156498, 156498, 42164, 41828, 27892, 26076, 25030, 17962, 17148, 16756, 20548, 19756, 26268, 25944, 9006, 26622, 25434, 24532, 24532, 0]
	}
}

```
