class_name GrowthGrid
extends RefCounted
## The Verdant Dump's puzzle, "The Seed Shrine": a 5 x 5 garden of plots, each bare or in bloom. Planting a seed in a
## plot flips that plot AND its four neighbours (bare <-> bloom). Bring every plot into bloom to grow the great
## beanstalk. The garden starts as the all-bloom garden with a secret set of plantings already undone, so a
## solution always exists; the chase-the-lights method finds every solution (a 5 x 5 board has exactly four, and the
## shortest is checked by the tests). Pure rules - `GrowthGridScreen` is the garden.

const SIZE: int = 5
const CELLS: int = 25
## The plantings (cell index = row * 5 + column) that were undone to make the starting garden.
const SECRET: Array[int] = [0, 2, 3, 6, 7, 9, 11, 12, 16, 18, 19, 22, 24]


## The cells flipped by planting in `cell`: itself and its orthogonal neighbours.
static func flipped_by(cell: int) -> Array[int]:
	var row: int = cell / SIZE
	var column: int = cell % SIZE
	var result: Array[int] = [cell]
	if row > 0:
		result.append(cell - SIZE)
	if row < SIZE - 1:
		result.append(cell + SIZE)
	if column > 0:
		result.append(cell - 1)
	if column < SIZE - 1:
		result.append(cell + 1)
	return result


## True = in bloom. Applies a planting to `board` (a copy is returned).
static func plant(board: Array[bool], cell: int) -> Array[bool]:
	var next: Array[bool] = board.duplicate()
	for index: int in flipped_by(cell):
		next[index] = not next[index]
	return next


static func all_bloom() -> Array[bool]:
	var board: Array[bool] = []
	board.resize(CELLS)
	board.fill(true)
	return board


## The starting garden: everything in bloom, then the SECRET plantings undone.
static func start_board() -> Array[bool]:
	var board: Array[bool] = all_bloom()
	for cell: int in SECRET:
		board = plant(board, cell)
	return board


static func is_solved(board: Array[bool]) -> bool:
	for bloom: bool in board:
		if not bloom:
			return false
	return true


## Every set of plantings (as a sorted cell list) that turns the starting garden fully into bloom.
static func solutions() -> Array[Array]:
	var found: Array[Array] = []
	for first_row: int in range(1 << SIZE):
		var board: Array[bool] = start_board()
		var presses: Array[int] = []
		for column: int in range(SIZE):
			if (first_row >> column) & 1 == 1:
				board = plant(board, column)
				presses.append(column)
		for row: int in range(1, SIZE):
			for column: int in range(SIZE):
				if not board[(row - 1) * SIZE + column]:
					var cell: int = row * SIZE + column
					board = plant(board, cell)
					presses.append(cell)
		if is_solved(board):
			presses.sort()
			found.append(presses)
	return found


static func shortest_solution() -> Array[int]:
	var best: Array[int] = []
	for solution: Array in solutions():
		if best.is_empty() or solution.size() < best.size():
			best.assign(solution)
	return best
