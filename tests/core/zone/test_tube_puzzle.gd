extends GutTest
## Part F: the pneumatic tube puzzle's rules - flipping junctions, a unique solution.


func _setup_from_bits(bits: int) -> Array[int]:
	var result: Array[int] = []
	for i: int in range(TubePuzzle.JUNCTIONS):
		result.append((bits >> i) & 1)
	return result


func test_junctions_flip_after_each_capsule() -> void:
	var puzzle: TubePuzzle = TubePuzzle.new([0, 0, 0, 0, 0, 0, 0] as Array[int])
	var first: Array[int] = puzzle.send_next()
	assert_eq(first, [0, 1, 3, 0] as Array[int], "all-left sends the first capsule down the far-left path")
	assert_eq(puzzle.states[0], 1, "root flipped")
	assert_eq(puzzle.states[1], 1)
	assert_eq(puzzle.states[3], 1)
	var second: Array[int] = puzzle.send_next()
	assert_eq(second[0], 0)
	assert_eq(second[1], 2, "root now sends right")


func test_every_setup_sends_the_eight_capsules_to_eight_different_bins() -> void:
	for bits: int in range(128):
		var leaves: Array[int] = TubePuzzle.simulate(_setup_from_bits(bits))
		var seen: Dictionary = {}
		for leaf: int in leaves:
			seen[leaf] = true
		assert_eq(seen.size(), 8, "setup %d visits every bin once" % bits)


func test_exactly_one_setup_solves_the_puzzle() -> void:
	var wanted: Array[int] = TubePuzzle.targets()
	var solutions: int = 0
	for bits: int in range(128):
		if TubePuzzle.simulate(_setup_from_bits(bits)) == wanted:
			solutions += 1
	assert_eq(solutions, 1)


func test_the_hidden_solution_solves_it_and_a_wrong_setup_does_not() -> void:
	var good: TubePuzzle = TubePuzzle.new(TubePuzzle.SOLUTION)
	for i: int in range(TubePuzzle.CAPSULES):
		good.send_next()
	assert_true(good.is_solved())
	var bad: TubePuzzle = TubePuzzle.new([0, 0, 0, 0, 0, 0, 0] as Array[int])
	for i: int in range(TubePuzzle.CAPSULES):
		bad.send_next()
	assert_false(bad.is_solved())
	assert_lt(bad.correct_count(), TubePuzzle.CAPSULES)


func test_reset_restores_the_initial_setup() -> void:
	var puzzle: TubePuzzle = TubePuzzle.new(TubePuzzle.SOLUTION)
	puzzle.send_next()
	puzzle.reset(TubePuzzle.SOLUTION)
	assert_eq(puzzle.sent, 0)
	assert_eq(puzzle.states, TubePuzzle.SOLUTION)
	assert_true(puzzle.landed.is_empty())
