class_name MatchGame
extends RefCounted
## Part H: the matching (memory) card game. 16 cards = 8 nostalgic pairs, flip two at a time. Each
## pair of flips is one MOVE; the player has MAX_MOVES moves to find every pair. Stars by moves
## used: <= 10 -> 3 stars, <= 12 -> 2, otherwise 1 (still a win). Running out of moves is a loss.
## Rewards (designer decision): the FIRST win pays a large reward (double the star reward plus a
## one-time bonus); every later win pays a small flat REPEAT_REWARD. Losses pay nothing; retries are
## unlimited. Pure rules - `MatchGameScreen` is only the table.

const PAIRS: int = 8
const MAX_MOVES: int = 14
const THREE_STAR_MOVES: int = 10
const TWO_STAR_MOVES: int = 12
## Nostalgia icons (game-icons.net), one per pair - the NAMES are story text (`match.pairs`).
const ICONS: Array[String] = [
	"caro-asercion/rotary-phone", "delapouite/three-friends", "caro-asercion/vhs",
	"delapouite/alien-egg", "delapouite/vibrating-smartphone", "delapouite/compact-disc",
	"delapouite/chat-bubble", "delapouite/audio-cassette",
]

## Reward by stars: gold, xp. The first-ever win also pays FIRST_WIN_BONUS.
const STAR_REWARDS: Array[Dictionary] = [
	{"gold": 0, "xp": 0},
	{"gold": 20, "xp": 10},
	{"gold": 45, "xp": 20},
	{"gold": 80, "xp": 35},
]
const FIRST_WIN_BONUS: Dictionary = {"gold": 50, "item": "scroll_of_insight"}
## Small flat reward for every win after the first.
const REPEAT_REWARD: Dictionary = {"gold": 10, "xp": 5}

## Icon index (0..PAIRS-1) of each of the 16 slots.
var cards: Array[int] = []
var matched: Array[bool] = []
var face_up: Array[int] = []
var moves: int = 0
var pairs_found: int = 0


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
	return MAX_MOVES - moves


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
	return not is_won() and moves >= MAX_MOVES


func is_over() -> bool:
	return is_won() or (moves >= MAX_MOVES and face_up.size() != 1)


func stars() -> int:
	if not is_won():
		return 0
	if moves <= THREE_STAR_MOVES:
		return 3
	if moves <= TWO_STAR_MOVES:
		return 2
	return 1


## Pays the large first-win reward or the small repeat reward, and records the result. Returns {gold, xp, item, first_win, stars}.
static func apply_result(stars_earned: int) -> Dictionary:
	var result: Dictionary = {"gold": 0, "xp": 0, "item": "", "first_win": false, "stars": stars_earned}
	if stars_earned <= 0:
		return result
	if not Session.flag(DnaZone.FLAG_MATCH_FIRST):
		Session.set_flag(DnaZone.FLAG_MATCH_FIRST)
		result["first_win"] = true
		result["gold"] = int(STAR_REWARDS[stars_earned]["gold"]) * 2 + int(FIRST_WIN_BONUS["gold"])
		result["xp"] = int(STAR_REWARDS[stars_earned]["xp"]) * 2
		result["item"] = str(FIRST_WIN_BONUS["item"])
	else:
		result["gold"] = int(REPEAT_REWARD["gold"])
		result["xp"] = int(REPEAT_REWARD["xp"])
	if int(result["gold"]) > 0:
		Session.add_gold(int(result["gold"]))
	if int(result["xp"]) > 0:
		Session.pending_level_ups.append_array(Session.add_xp(int(result["xp"])))
	if not str(result["item"]).is_empty() and Session.content.item(str(result["item"])) != null:
		Session.add_item(Session.content.item(str(result["item"])))
	Session.save_game()
	return result
