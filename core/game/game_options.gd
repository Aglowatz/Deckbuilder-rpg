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
## Fable Nov 21 (Part 2.6, the owner: Captain Spotless got stuck with none): the OTHER seat (the AI) gets the same floor, by the same
## hidden soft mulligan on the game's own seeded RNG, after its draw and after its mulligan. 0 = off: the tutorial fights of the Forgotten
## Cave switch it off (`FirstDuel.apply_flood_guard`), so the first foes can still stumble.
var foe_opening_infrastructure_floor: int = 2
## Nov 25 night (Part C.2): the AI seat's opening hand also holds at least this many cards that are not infrastructure (a flooded hand
## swaps infrastructure back for plays). Set with a higher infrastructure floor by `OpponentHands` for postgame and draft foes. 0 = off.
var foe_opening_play_floor: int = 0
## Nov 25 night (Part C, the owner: "at least 8 cards when their first turn begins"): the AI seat is dealt enough that it holds this many
## when its first turn begins - this many when it goes first, one less (plus its extra draws) when its first turn starts with a draw.
## 0 = off.
var foe_first_turn_hand: int = 0
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
	copy.foe_opening_infrastructure_floor = foe_opening_infrastructure_floor
	copy.foe_opening_play_floor = foe_opening_play_floor
	copy.foe_first_turn_hand = foe_first_turn_hand
	copy.opening_infrastructure_seat = opening_infrastructure_seat
	copy.flood_guard = flood_guard
	copy.flood_guard_seat = flood_guard_seat
	copy.first_player = first_player
	copy.turn_limit = turn_limit
	copy.record_events = record_events
	copy.rng_seed = rng_seed
	return copy
