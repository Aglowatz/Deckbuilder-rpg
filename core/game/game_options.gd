class_name GameOptions
extends RefCounted
## Per-game rule options.

## Opening hand: draw 2 candidate hands and keep the one whose infrastructure count is closest to the
## deck's infrastructure ratio.
var hand_smoother: bool = true
## The smoother only steps in when the first hand is more than this many infrastructure away from the
## deck's infrastructure ratio (so it rescues clearly bad hands instead of perfecting every hand).
var smoother_tolerance: float = 1.0
## Each player may take one free mulligan.
var free_mulligan: bool = true
## Fable pass Nov 1 (the first duel, `FirstDuel`): card ids dealt as seat `scripted_hand_player`'s opening hand (pulled from its deck in
## this order; the rest of the hand is drawn as usual). Empty = a normal draw. A mulligan deals a normal hand.
var scripted_opening_hand: Array[String] = []
var scripted_hand_player: int = 0
## Fix pass Nov 7 (owner decision D6): every opening hand of seat `opening_infrastructure_seat` (the player) holds at least this many
## infrastructure cards - a hidden soft mulligan that swaps non-infrastructure cards for infrastructure from the deck. 0 = off.
var opening_infrastructure_floor: int = 2
var opening_infrastructure_seat: int = 0
## Overnight Nov 9-10 (RC1 critic #2, the first fights drag): the Forgotten Cave's FLOOD GUARD. While seat `flood_guard_seat` already
## holds this many infrastructure (in play + in hand), an infrastructure it draws is swapped for the next non-infrastructure card down its
## deck (deterministic, no RNG). 0 = off (every other fight).
var flood_guard: int = 0
var flood_guard_seat: int = 0
## 0/1 = that player goes first, -1 = random.
var first_player: int = 0
## Total turns (both players) after which an undecided game is a draw.
var turn_limit: int = 100
## When false no GameEvents are created (used for AI look-ahead clones).
var record_events: bool = true
## 0 = seed randomly.
var rng_seed: int = 0


func clone() -> GameOptions:
	var copy: GameOptions = GameOptions.new()
	copy.hand_smoother = hand_smoother
	copy.smoother_tolerance = smoother_tolerance
	copy.free_mulligan = free_mulligan
	copy.opening_infrastructure_floor = opening_infrastructure_floor
	copy.opening_infrastructure_seat = opening_infrastructure_seat
	copy.flood_guard = flood_guard
	copy.flood_guard_seat = flood_guard_seat
	copy.first_player = first_player
	copy.turn_limit = turn_limit
	copy.record_events = record_events
	copy.rng_seed = rng_seed
	return copy
