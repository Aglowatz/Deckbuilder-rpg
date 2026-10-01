class_name TubePuzzle
extends RefCounted
## Part F: the Mail Room's pneumatic soul-routing puzzle. A tree of 7 junctions (root, two on the
## second level, four on the third) ends in 8 departments (bins). Every junction FLIPS after a
## capsule passes through it. The player sets each junction's starting side, then sends all 8
## capsules in order; each capsule must land in the department stamped on it.
##
## Because junctions flip, the 8 capsules visit every bin exactly once - the puzzle is working out
## which starting position of 7 junctions produces the stamped sequence. Exactly one of the 128
## possible setups does (verified in tests/core/zone/test_tube_puzzle.gd).

const JUNCTIONS: int = 7
const LEAVES: int = 8
const CAPSULES: int = 8
## The intended (hidden) solution: starting side per junction, 0 = left, 1 = right.
const SOLUTION: Array[int] = [1, 0, 1, 1, 0, 0, 1]

## Current junction sides (0/1). Index 0 is the root.
var states: Array[int] = []
## How many capsules have been sent in the current run.
var sent: int = 0
## Leaf each sent capsule landed in.
var landed: Array[int] = []


func _init(initial: Array[int] = []) -> void:
	reset(initial)


func reset(initial: Array[int] = []) -> void:
	states.clear()
	for i: int in range(JUNCTIONS):
		states.append(initial[i] if i < initial.size() else 0)
	sent = 0
	landed.clear()


## Children of junction `j`: a junction index (< JUNCTIONS) or a leaf (offset by JUNCTIONS).
static func child(j: int, side: int) -> int:
	if j < 3:
		return 2 * j + 1 + side
	return JUNCTIONS + (j - 3) * 2 + side


## Sends the next capsule. Returns the junctions it passed (in order) followed by the leaf index
## as the last element; every junction passed flips afterwards.
func send_next() -> Array[int]:
	var path: Array[int] = []
	var node: int = 0
	while node < JUNCTIONS:
		path.append(node)
		var side: int = states[node]
		states[node] = 1 - side
		node = child(node, side)
	var leaf: int = node - JUNCTIONS
	path.append(leaf)
	landed.append(leaf)
	sent += 1
	return path


## The leaf of each of `count` capsules for a given starting setup (pure function).
static func simulate(initial: Array[int], count: int = CAPSULES) -> Array[int]:
	var run: TubePuzzle = TubePuzzle.new(initial)
	var result: Array[int] = []
	for i: int in range(count):
		var path: Array[int] = run.send_next()
		result.append(path[path.size() - 1])
	return result


## The destination stamped on each capsule (derived from SOLUTION, so it always has a solution).
static func targets() -> Array[int]:
	return simulate(SOLUTION)


## True once all capsules were sent and every one landed in its stamped department.
func is_solved() -> bool:
	if landed.size() != CAPSULES:
		return false
	var wanted: Array[int] = targets()
	for i: int in range(CAPSULES):
		if landed[i] != wanted[i]:
			return false
	return true


## How many sent capsules landed correctly so far.
func correct_count() -> int:
	var wanted: Array[int] = targets()
	var count: int = 0
	for i: int in range(landed.size()):
		if landed[i] == wanted[i]:
			count += 1
	return count
