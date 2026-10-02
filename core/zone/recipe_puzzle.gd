class_name RecipePuzzle
extends RefCounted
## The Endless Buffet's puzzle, "The Mystery Stew": a recipe logic puzzle. Pick 4 of 6 ingredients and put
## them in order (6 x 5 x 4 x 3 = 360 possible stews). Seven clues pin down exactly one of them - the
## test suite checks that by brute force. Serving gives only "right" or "wrong" (never which clue fails),
## so the player has to reason it out. Pure rules - `RecipePuzzleScreen` is the pot and the clue board.
##
## The clue TEXT lives in the story file (`recipe.clue.<n>`, `recipe.ingredients`); rewrite it freely as
## long as it keeps the meaning of the clue data below.

const INGREDIENT_COUNT: int = 6
const SLOTS: int = 4
## Indices into the ingredient list (story key `recipe.ingredients`).
const CARROT: int = 0
const ONION: int = 1
const MUSHROOM: int = 2
const PAPRIKA: int = 3
const LEEK: int = 4
const PUMPKIN: int = 5

## The one stew that satisfies every clue (position 0 first).
const SOLUTION: Array[int] = [ONION, MUSHROOM, LEEK, PAPRIKA]

enum Kind { EITHER, NOT_IN, FIRST_OF, BEFORE, NOT_AT, NOT_LAST }


class Clue:
	extends RefCounted
	var kind: Kind = Kind.NOT_IN
	var a: int = -1
	var b: int = -1
	var list: Array[int] = []


static func _clue(kind: Kind, a: int = -1, b: int = -1, list: Array[int] = []) -> Clue:
	var made: Clue = Clue.new()
	made.kind = kind
	made.a = a
	made.b = b
	made.list = list
	return made


## The clues, in the order the board shows them (story keys `recipe.clue.1` ... `recipe.clue.7`).
static func clues() -> Array[Clue]:
	return [
		_clue(Kind.EITHER, PUMPKIN, MUSHROOM),
		_clue(Kind.NOT_IN, CARROT),
		_clue(Kind.FIRST_OF, -1, -1, [ONION, CARROT] as Array[int]),
		_clue(Kind.BEFORE, MUSHROOM, LEEK),
		_clue(Kind.NOT_AT, PAPRIKA, 1),
		_clue(Kind.NOT_LAST, LEEK),
		_clue(Kind.NOT_AT, MUSHROOM, 0),
	] as Array[Clue]


## True when `order` (ingredient indices, first to last) satisfies `clue`.
static func satisfies(order: Array[int], clue: Clue) -> bool:
	match clue.kind:
		Kind.EITHER:
			return order.has(clue.a) != order.has(clue.b)
		Kind.NOT_IN:
			return not order.has(clue.a)
		Kind.FIRST_OF:
			return not order.is_empty() and clue.list.has(order[0])
		Kind.BEFORE:
			var first: int = order.find(clue.a)
			var second: int = order.find(clue.b)
			return first >= 0 and second >= 0 and first < second
		Kind.NOT_AT:
			return order.find(clue.a) != clue.b
		Kind.NOT_LAST:
			return not order.is_empty() and order[order.size() - 1] != clue.a
	return false


## A complete, duplicate-free stew of exactly SLOTS ingredients.
static func is_complete(order: Array[int]) -> bool:
	if order.size() != SLOTS:
		return false
	for index: int in range(order.size()):
		if order[index] < 0 or order[index] >= INGREDIENT_COUNT or order.find(order[index]) != index:
			return false
	return true


static func is_solved(order: Array[int]) -> bool:
	if not is_complete(order):
		return false
	for clue: Clue in clues():
		if not satisfies(order, clue):
			return false
	return true


## Every stew that satisfies every clue (there is exactly one).
static func solutions() -> Array[Array]:
	var found: Array[Array] = []
	var all_clues: Array[Clue] = clues()
	for a: int in range(INGREDIENT_COUNT):
		for b: int in range(INGREDIENT_COUNT):
			if b == a:
				continue
			for c: int in range(INGREDIENT_COUNT):
				if c == a or c == b:
					continue
				for d: int in range(INGREDIENT_COUNT):
					if d == a or d == b or d == c:
						continue
					var order: Array[int] = [a, b, c, d]
					var ok: bool = true
					for clue: Clue in all_clues:
						if not satisfies(order, clue):
							ok = false
							break
					if ok:
						found.append(order)
	return found
