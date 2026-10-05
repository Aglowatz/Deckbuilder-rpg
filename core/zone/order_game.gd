class_name OrderGame
extends RefCounted
## The Endless Buffet's minigame, "Order Up!" - an ASSEMBLY / time-pressure game (unlike the D.N.A.'s memory
## game and the Gainlands' timing game). Six tickets arrive one at a time; each names a dish, which is an
## ordered stack of ingredients. Press the ingredient stations in the right order before the ticket's
## timer runs out. A wrong ingredient tosses the plate (the stack restarts) and costs PENALTY seconds.
## Serving fast scores 3 / 2 / 1 points, a timed-out ticket scores 0 (18 is a flawless shift).
## Stars: >= 14 -> 3, >= 9 -> 2, >= 4 -> 1, else 0 (a failed shift pays nothing). Rewards: the FIRST finished
## shift (>= 1 star) pays a large reward by stars plus a one-time bonus; every later shift pays a small flat
## reward. Retries are unlimited. Pure rules (no clock of its own) - `OrderGameScreen` feeds in the time.

## Stations (ingredient bins). Names live in the story file (`order.stations`), by index.
const BUN: int = 0
const PATTY: int = 1
const CHEESE: int = 2
const LETTUCE: int = 3
const TOMATO: int = 4
const FRIES: int = 5
const STATION_COUNT: int = 6

## The dishes (names in the story file, `order.dishes`, by index) and what each one is made of, in order.
const DISHES: Array[Array] = [
	[BUN, PATTY, BUN],
	[BUN, PATTY, CHEESE, BUN],
	[LETTUCE, TOMATO, CHEESE],
	[BUN, PATTY, BUN, FRIES],
	[BUN, PATTY, CHEESE, LETTUCE, TOMATO, BUN],
	[BUN, PATTY, CHEESE, PATTY, FRIES, BUN],
]
## The shift: which dish each ticket asks for (dish indices), in order.
const TICKETS: Array[int] = [0, 1, 2, 3, 4, 5]
const TICKET_COUNT: int = 6
## Seconds a ticket allows: BASE + PER_ITEM per ingredient.
const BASE_SECONDS: float = 5.0
const PER_ITEM_SECONDS: float = 1.7
const PENALTY: float = 1.5
## Breathing room between tickets.
const GAP: float = 1.2

const THREE_STAR_POINTS: int = 14
const TWO_STAR_POINTS: int = 9
const ONE_STAR_POINTS: int = 4

## Reward by stars: gold, xp. The first-ever shift also pays FIRST_CLEAR_BONUS.
const STAR_REWARDS: Array[Dictionary] = [
	{"gold": 0, "xp": 0},
	{"gold": 20, "xp": 10},
	{"gold": 45, "xp": 20},
	{"gold": 80, "xp": 35},
]
const FIRST_CLEAR_BONUS: Dictionary = {"gold": 50, "item": "scroll_of_insight"}
const REPEAT_REWARD: Dictionary = {"gold": 10, "xp": 5}

enum Result { IGNORED, ADDED, WRONG, SERVED }

## Points per finished ticket (0 = timed out).
var points_per_ticket: Array[int] = []
var mistakes: int = 0
var current: int = 0
## The stack on the plate for the current ticket.
var plate: Array[int] = []
var ticket_started: float = 0.0
var _penalty_total: float = 0.0
var _gap_until: float = 0.0


func start(time: float) -> void:
	current = 0
	points_per_ticket.clear()
	mistakes = 0
	plate.clear()
	_penalty_total = 0.0
	ticket_started = time
	_gap_until = 0.0


func is_finished() -> bool:
	return current >= TICKET_COUNT


func dish_index() -> int:
	return TICKETS[mini(current, TICKET_COUNT - 1)]


func recipe() -> Array:
	return DISHES[dish_index()]


## Seconds the current ticket allows in total (before any penalties).
func ticket_seconds() -> float:
	return BASE_SECONDS + PER_ITEM_SECONDS * float(recipe().size())


## Seconds left on the current ticket at `time` (never negative).
func time_left(time: float) -> float:
	return maxf(0.0, ticket_started + ticket_seconds() - _penalty_total - time)


## True while the short pause between tickets runs (presses are ignored).
func in_gap(time: float) -> bool:
	return time < _gap_until


## A press of ingredient station `station` at `time`.
func press(station: int, time: float) -> Result:
	if is_finished() or in_gap(time) or time_left(time) <= 0.0:
		return Result.IGNORED
	var wanted: int = recipe()[plate.size()] as int
	if station != wanted:
		mistakes += 1
		plate.clear()
		_penalty_total += PENALTY
		return Result.WRONG
	plate.append(station)
	if plate.size() < recipe().size():
		return Result.ADDED
	var fraction: float = time_left(time) / ticket_seconds()
	var earned: int = 1
	if fraction >= 0.5:
		earned = 3
	elif fraction >= 0.25:
		earned = 2
	_finish_ticket(earned, time)
	return Result.SERVED


## Call as the clock advances: a ticket whose time ran out is a 0. Returns true when one just timed out.
func advance(time: float) -> bool:
	if is_finished() or in_gap(time):
		return false
	if time_left(time) <= 0.0:
		_finish_ticket(0, time)
		return true
	return false


func _finish_ticket(earned: int, time: float) -> void:
	points_per_ticket.append(earned)
	current += 1
	plate.clear()
	_penalty_total = 0.0
	_gap_until = time + GAP
	ticket_started = time + GAP


func points() -> int:
	var total: int = 0
	for earned: int in points_per_ticket:
		total += earned
	return total


func stars() -> int:
	return stars_for(points())


static func stars_for(score: int) -> int:
	if score >= THREE_STAR_POINTS:
		return 3
	if score >= TWO_STAR_POINTS:
		return 2
	if score >= ONE_STAR_POINTS:
		return 1
	return 0


static func max_points() -> int:
	return TICKET_COUNT * 3


## Plays a whole shift with a perfect player who takes `seconds_per_press` between presses (for tests and the
## autopilot): serves every ticket in order, never a mistake.
static func play_perfect(seconds_per_press: float) -> OrderGame:
	var game: OrderGame = OrderGame.new()
	var time: float = 0.0
	game.start(time)
	while not game.is_finished():
		time = maxf(time, game.ticket_started)
		for station: Variant in game.recipe().duplicate():
			time += seconds_per_press
			game.press(int(station), time)
			if game.is_finished():
				break
		time += 0.01
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
	PackRewards.grant_minigame_prize(result)
	if int(result["gold"]) > 0:
		Session.add_gold(int(result["gold"]))
	if int(result["xp"]) > 0:
		Session.pending_level_ups.append_array(Session.add_xp(int(result["xp"])))
	if not str(result["item"]).is_empty() and Session.content.item(str(result["item"])) != null:
		Session.add_item(Session.content.item(str(result["item"])))
	Session.save_game()
	return result
