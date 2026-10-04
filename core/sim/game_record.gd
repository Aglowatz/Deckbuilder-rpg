class_name GameRecord
extends RefCounted
## Summary of one simulated game.

## Winning seat (0 = deck A, 1 = deck B), -1 for a draw.
var winner: int = -1
var turns: int = 0
var first_player: int = 0
## Spells cast per seat: card id -> count (infrastructure excluded).
var casts: Array[Dictionary] = [{}, {}]
## Actions the engine rejected (should always be 0).
var illegal_actions: int = 0
var finished: bool = false
