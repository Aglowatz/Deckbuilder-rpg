class_name MatchupStats
extends RefCounted
## Aggregated results of many games between deck A and deck B.

var deck_a: String = ""
var deck_b: String = ""
var games: int = 0
var wins_a: int = 0
var wins_b: int = 0
var draws: int = 0
var total_turns: int = 0
var illegal_actions: int = 0
## Games won by whoever went first, and games where the first player was decided.
var first_player_wins: int = 0
var decided_games: int = 0
## card id -> total casts across all games, per deck.
var casts_a: Dictionary = {}
var casts_b: Dictionary = {}


func add(record: GameRecord) -> void:
	games += 1
	total_turns += record.turns
	illegal_actions += record.illegal_actions
	if record.winner == 0:
		wins_a += 1
	elif record.winner == 1:
		wins_b += 1
	else:
		draws += 1
	if record.winner >= 0:
		decided_games += 1
		if record.winner == record.first_player:
			first_player_wins += 1
	_merge(casts_a, record.casts[0])
	_merge(casts_b, record.casts[1])


## Deck A's win rate, counting a draw as half a win.
func win_rate_a() -> float:
	if games == 0:
		return 0.0
	return (float(wins_a) + 0.5 * float(draws)) / float(games)


func average_turns() -> float:
	return float(total_turns) / float(maxi(1, games))


func first_player_win_rate() -> float:
	return float(first_player_wins) / float(maxi(1, decided_games))


static func _merge(into: Dictionary, from: Dictionary) -> void:
	for id: Variant in from.keys():
		into[id] = int(into.get(id, 0)) + int(from[id])
