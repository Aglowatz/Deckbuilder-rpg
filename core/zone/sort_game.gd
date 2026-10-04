class_name SortGame
extends RefCounted
## The Verdant Dump's minigame, "Sort It Out!" - a SORTING / classification game (unlike the D.N.A.'s memory game, the
## Gainlands' timing game and the Endless Buffet's assembly game). Twenty pieces of junk ride down a conveyor, one
## after another and faster and faster; send the front piece to the right bin (Compost, Metal, Glass or Paper)
## before it reaches the end. A wrong bin or a piece that falls off the end breaks your streak. Points: 1 per piece,
## 2 once the streak is 4, 3 once it is 8. Stars by pieces sorted right: >= 18 -> 3, >= 13 -> 2, >= 7 -> 1, else 0
## (a failed run pays nothing). Rewards: the FIRST finished run (>= 1 star) pays a large reward by stars plus a
## one-time bonus; every later run pays a small flat reward. Retries are unlimited. Pure rules (no clock of its own) -
## `SortGameScreen` feeds in the time.

const COMPOST: int = 0
const METAL: int = 1
const GLASS: int = 2
const PAPER: int = 3
const BIN_COUNT: int = 4
## Bin names live in the story file (`sort.bins`), piece names in `sort.items` (index-aligned with ITEM_BINS).
const ITEM_BINS: Array[int] = [
	COMPOST, METAL, GLASS, PAPER, COMPOST, METAL, GLASS, PAPER, COMPOST, METAL,
	GLASS, PAPER, COMPOST, METAL, GLASS, PAPER, COMPOST, METAL, GLASS, PAPER,
]
## The order the pieces arrive in (indices into ITEM_BINS / `sort.items`).
const ORDER: Array[int] = [0, 5, 2, 7, 4, 1, 10, 3, 8, 13, 6, 11, 12, 9, 14, 15, 16, 17, 18, 19]
const PIECES: int = 20
## Piece i appears at FIRST + i * GAP - i * i * SQUEEZE (seconds) and reaches the end TRAVEL - i * SHRINK later.
const FIRST: float = 1.0
const GAP: float = 1.35
const SQUEEZE: float = 0.012
const TRAVEL: float = 4.4
const SHRINK: float = 0.05

const THREE_STAR_PIECES: int = 18
const TWO_STAR_PIECES: int = 13
const ONE_STAR_PIECES: int = 7

## Reward by stars: gold, xp. The first-ever run also pays FIRST_CLEAR_BONUS.
const STAR_REWARDS: Array[Dictionary] = [
	{"gold": 0, "xp": 0},
	{"gold": 20, "xp": 10},
	{"gold": 45, "xp": 20},
	{"gold": 80, "xp": 35},
]
const FIRST_CLEAR_BONUS: Dictionary = {"gold": 50, "item": "healing_salve"}
const REPEAT_REWARD: Dictionary = {"gold": 10, "xp": 5}

enum Result { IGNORED, CORRECT, WRONG }

## Per piece: 1 = sorted right, 0 = wrong bin, -1 = fell off the end. Filled in order.
var outcomes: Array[int] = []
var points_total: int = 0
var streak: int = 0
var best_streak: int = 0
var next_piece: int = 0


static func spawn_time(piece: int) -> float:
	return FIRST + float(piece) * GAP - float(piece * piece) * SQUEEZE


static func end_time(piece: int) -> float:
	return spawn_time(piece) + TRAVEL - float(piece) * SHRINK


static func bin_of(piece: int) -> int:
	return ITEM_BINS[ORDER[piece]]


## Where along the conveyor a piece is at `time` (0 = just appeared, 1 = at the end), clamped.
static func progress(piece: int, time: float) -> float:
	return clampf((time - spawn_time(piece)) / (end_time(piece) - spawn_time(piece)), 0.0, 1.0)


func is_finished() -> bool:
	return next_piece >= PIECES


## True when the front piece has appeared on the belt by `time`.
func front_visible(time: float) -> bool:
	return not is_finished() and time >= spawn_time(next_piece)


## A press of bin `bin` at `time`: judged against the front piece (presses before it appears are ignored).
func press(bin: int, time: float) -> Result:
	if not front_visible(time):
		return Result.IGNORED
	var correct: bool = bin == bin_of(next_piece)
	_resolve(1 if correct else 0)
	return Result.CORRECT if correct else Result.WRONG


## Call as the clock advances: a piece that reached the end unsorted is lost. Returns how many fell this call.
func advance(time: float) -> int:
	var lost: int = 0
	while not is_finished() and time > end_time(next_piece):
		_resolve(-1)
		lost += 1
	return lost


func _resolve(outcome: int) -> void:
	outcomes.append(outcome)
	next_piece += 1
	if outcome == 1:
		streak += 1
		best_streak = maxi(best_streak, streak)
		points_total += 3 if streak >= 8 else (2 if streak >= 4 else 1)
	else:
		streak = 0


func correct_count() -> int:
	var count: int = 0
	for outcome: int in outcomes:
		if outcome == 1:
			count += 1
	return count


func stars() -> int:
	return stars_for(correct_count())


static func stars_for(correct: int) -> int:
	if correct >= THREE_STAR_PIECES:
		return 3
	if correct >= TWO_STAR_PIECES:
		return 2
	if correct >= ONE_STAR_PIECES:
		return 1
	return 0


## A perfect sorter who presses `delay` seconds after each piece appears (for tests and the autopilot).
static func play_perfect(delay: float) -> SortGame:
	var game: SortGame = SortGame.new()
	for piece: int in range(PIECES):
		var time: float = spawn_time(piece) + delay
		game.advance(time)
		game.press(bin_of(piece), time)
	game.advance(end_time(PIECES - 1) + 1.0)
	return game


## Pays the large first-clear reward or the small repeat reward, and records the result. Returns
## {gold, xp, item, first_win, stars}.
static func apply_result(stars_earned: int) -> Dictionary:
	var result: Dictionary = {"gold": 0, "xp": 0, "item": "", "first_win": false, "stars": stars_earned}
	if stars_earned <= 0:
		return result
	var first_flag: StringName = ZoneDefs.current().flag_minigame_first
	if not Session.flag(first_flag):
		Session.set_flag(first_flag)
		result["first_win"] = true
		result["gold"] = int(STAR_REWARDS[stars_earned]["gold"]) * 2 + int(FIRST_CLEAR_BONUS["gold"])
		result["xp"] = int(STAR_REWARDS[stars_earned]["xp"]) * 2
		result["item"] = str(FIRST_CLEAR_BONUS["item"])
	else:
		result["gold"] = int(STAR_REWARDS[stars_earned]["gold"]) / 2 + int(REPEAT_REWARD["gold"])
		result["xp"] = int(REPEAT_REWARD["xp"])
	if int(result["gold"]) > 0:
		Session.add_gold(int(result["gold"]))
	if int(result["xp"]) > 0:
		Session.pending_level_ups.append_array(Session.add_xp(int(result["xp"])))
	if not str(result["item"]).is_empty() and Session.content.item(str(result["item"])) != null:
		Session.add_item(Session.content.item(str(result["item"])))
	Session.save_game()
	return result
