class_name WheelPuzzle
extends RefCounted
## The Gainlands' puzzle, "Power Routing": six hamster wheels each make a fixed number of watts. Each
## wheel is wired to TWO of the three machines (the lift, the gate, the mill) and its switch can send
## the power to either one or leave the wheel idle. Every machine needs its exact wattage, and only
## `MAX_RUNNING` wheels may run at once (they get tired). Find the one switch setting that powers all
## three. Verified by `tests/core/zone/test_wheel_puzzle.gd`: exactly one of the 729 settings solves it.
## Pure rules - `WheelPuzzleScreen` is only the control panel.

const WHEELS: int = 6
const MACHINES: int = 3
## Switch positions: 0 = idle, 1 = first wired machine, 2 = second wired machine.
const SWITCH_STATES: int = 3
const MAX_RUNNING: int = 5

## Watts each wheel produces while running.
const OUTPUT: Array[int] = [5, 3, 8, 4, 2, 7]
## The two machines (indices into MACHINE_NAMES) each wheel is piped to: [first, second].
const WIRING: Array[Array] = [[0, 1], [1, 2], [1, 2], [0, 2], [1, 2], [0, 1]]
## Exact watts each machine needs.
const TARGET: Array[int] = [7, 8, 9]
const MACHINE_NAMES: Array[String] = ["Lift", "Gate", "Mill"]


## Watts delivered to each machine by `switches` (one 0-2 value per wheel).
static func delivered(switches: Array[int]) -> Array[int]:
	var totals: Array[int] = [0, 0, 0]
	for wheel: int in range(mini(switches.size(), WHEELS)):
		var state: int = switches[wheel]
		if state > 0:
			var machine: int = WIRING[wheel][state - 1] as int
			totals[machine] += OUTPUT[wheel]
	return totals


static func running(switches: Array[int]) -> int:
	var count: int = 0
	for state: int in switches:
		if state > 0:
			count += 1
	return count


static func is_solved(switches: Array[int]) -> bool:
	if running(switches) > MAX_RUNNING:
		return false
	return delivered(switches) == TARGET


## Every setting that solves the puzzle (there is exactly one).
static func solutions() -> Array[Array]:
	var found: Array[Array] = []
	var total: int = int(pow(float(SWITCH_STATES), float(WHEELS)))
	for code: int in range(total):
		var switches: Array[int] = []
		var rest: int = code
		for wheel: int in range(WHEELS):
			switches.append(rest % SWITCH_STATES)
			rest /= SWITCH_STATES
		if is_solved(switches):
			found.append(switches)
	return found


## Which machine a wheel feeds in this state, or -1 if idle.
static func machine_of(wheel: int, state: int) -> int:
	if state <= 0:
		return -1
	return WIRING[wheel][state - 1] as int
