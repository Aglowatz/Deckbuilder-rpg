class_name MatchGame
extends RefCounted
## Part H: the matching (memory) card game. 16 cards = 8 pairs, flip two at a time. Each pair of flips is one MOVE; the player has
## `max_moves` moves to find every pair. Stars by moves used: <= 10 -> 3 stars, <= 12 -> 2, otherwise 1 (still a win). Running out of
## moves is a loss. Pure rules: Dex's tables (`CardMatchCircuit`, `CardMatchScreen`) deal it from real cards. Nov 18 day: the D.N.A.'s
## Rec Room table (Kyle's nostalgia icons, its rewards and `MatchGameScreen`) is gone; Kyle gives "Hall Monitor" instead.

const PAIRS: int = 8
const MAX_MOVES: int = 14
const THREE_STAR_MOVES: int = 10
const TWO_STAR_MOVES: int = 12
## Icon index (0..PAIRS-1) of each of the 16 slots.
var cards: Array[int] = []
var matched: Array[bool] = []
var face_up: Array[int] = []
var moves: int = 0
var pairs_found: int = 0
## Overnight Nov 9, Part 3: the move limit of this table (CardMatchCircuit.TABLE_MAX_MOVES for Dex's tables).
var max_moves: int = MAX_MOVES


func _init(shuffle_seed: int = 0) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	if shuffle_seed != 0:
		rng.seed = shuffle_seed
	else:
		rng.randomize()
	for icon: int in range(PAIRS):
		cards.append(icon)
		cards.append(icon)
	for i: int in range(cards.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var swap: int = cards[i]
		cards[i] = cards[j]
		cards[j] = swap
	matched.resize(cards.size())
	matched.fill(false)


func slot_count() -> int:
	return cards.size()


func moves_left() -> int:
	return max_moves - moves


## Flips a card up. Returns "ignored", "first" (one card up), "match" or "mismatch" (two up; the
## caller shows them briefly, then calls `resolve()`).
func flip(index: int) -> String:
	if is_over() or index < 0 or index >= cards.size() or matched[index] or face_up.has(index) or face_up.size() >= 2:
		return "ignored"
	face_up.append(index)
	if face_up.size() == 1:
		return "first"
	moves += 1
	if cards[face_up[0]] == cards[face_up[1]]:
		matched[face_up[0]] = true
		matched[face_up[1]] = true
		pairs_found += 1
		return "match"
	return "mismatch"


## Turns the two face-up cards back down (after a match they simply stay matched).
func resolve() -> void:
	face_up.clear()


func is_won() -> bool:
	return pairs_found == PAIRS


## Out of moves with pairs left (only meaningful once the last pair of flips was resolved).
func is_lost() -> bool:
	return not is_won() and moves >= max_moves


func is_over() -> bool:
	return is_won() or (moves >= max_moves and face_up.size() != 1)


func stars() -> int:
	if not is_won():
		return 0
	if moves <= THREE_STAR_MOVES:
		return 3
	if moves <= TWO_STAR_MOVES:
		return 2
	return 1
