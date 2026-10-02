class_name RepGame
extends RefCounted
## The Gainlands' minigame, "Rep Counter" - a TIMING / rhythm lifting game (a different type from the
## D.N.A.'s memory game). Eight reps arrive on a beat that speeds up; press when the ring closes on
## the bar. Each press is judged by how far it is from its rep's beat: PERFECT, GOOD, OK or MISS.
## Points: 3 / 2 / 1 / 0, so 24 is a flawless set. Stars: >= 20 -> 3, >= 14 -> 2, >= 8 -> 1, else 0
## (a failed set pays nothing). Rewards: the FIRST finished set (>= 1 star) pays a large reward by
## stars plus a one-time bonus; every later set pays a small flat reward. Retries are unlimited.
## Pure rules (no timing source of its own) - `RepGameScreen` feeds in the clock.

const REPS: int = 8
## Seconds from the start of the set to each rep's beat (the cadence speeds up).
const BEATS: Array[float] = [1.4, 2.5, 3.6, 4.6, 5.5, 6.3, 7.0, 7.6]
## Seconds a ring takes to close (spawn -> beat).
const APPROACH: float = 0.95
## Judging windows, in seconds either side of the beat.
const PERFECT_WINDOW: float = 0.09
const GOOD_WINDOW: float = 0.19
const OK_WINDOW: float = 0.32

enum Rating { MISS, OK, GOOD, PERFECT }

const POINTS: Array[int] = [0, 1, 2, 3]
const THREE_STAR_POINTS: int = 20
const TWO_STAR_POINTS: int = 14
const ONE_STAR_POINTS: int = 8

## Reward by stars: gold, xp. The first-ever set also pays FIRST_CLEAR_BONUS.
const STAR_REWARDS: Array[Dictionary] = [
	{"gold": 0, "xp": 0},
	{"gold": 20, "xp": 10},
	{"gold": 45, "xp": 20},
	{"gold": 80, "xp": 35},
]
const FIRST_CLEAR_BONUS: Dictionary = {"gold": 50, "item": "healing_salve"}
const REPEAT_REWARD: Dictionary = {"gold": 10, "xp": 5}

var ratings: Array[int] = []
var next_rep: int = 0


## Judges a press `offset` seconds away from the beat (sign ignored).
static func rate(offset: float) -> Rating:
	var distance: float = absf(offset)
	if distance <= PERFECT_WINDOW:
		return Rating.PERFECT
	if distance <= GOOD_WINDOW:
		return Rating.GOOD
	if distance <= OK_WINDOW:
		return Rating.OK
	return Rating.MISS


## A press at `time`: judges it against the next unfinished rep. Presses long before the next beat
## (further than the OK window) are ignored (returns -1) so a stray tap does not cost a rep.
func press(time: float) -> int:
	if next_rep >= REPS:
		return -1
	var offset: float = time - BEATS[next_rep]
	if offset < -OK_WINDOW:
		return -1
	var rating: Rating = rate(offset)
	ratings.append(rating)
	next_rep += 1
	return rating


## Call as the clock advances: every rep whose OK window has fully passed unpressed is a MISS.
## Returns how many reps were just missed.
func advance(time: float) -> int:
	var missed: int = 0
	while next_rep < REPS and time > BEATS[next_rep] + OK_WINDOW:
		ratings.append(Rating.MISS)
		next_rep += 1
		missed += 1
	return missed


func is_finished() -> bool:
	return next_rep >= REPS


func points() -> int:
	var total: int = 0
	for rating: int in ratings:
		total += POINTS[rating]
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
	return REPS * POINTS[Rating.PERFECT]


## Plays a whole set from press times (for tests and the autopilot): one press time per rep, in order.
static func play(press_times: Array[float]) -> RepGame:
	var game: RepGame = RepGame.new()
	for time: float in press_times:
		game.advance(time)
		game.press(time)
	game.advance(BEATS[REPS - 1] + OK_WINDOW + 1.0)
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
