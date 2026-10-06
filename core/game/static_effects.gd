class_name StaticEffects
extends RefCounted
## Continuous ("static") effects of permanents on the field: stat auras, keyword grants, player-wide flags (Raccoon, Harvest
## Festival, Chancellor Clench...), cost changes. Computed on demand from the cards on the field, so there is no state to keep in sync.
## Part B ships the resource-related hooks; Part C fills in card scripts.


## True when any permanent `player_index` controls (or, for global flags, any permanent) sets the flag.
static func player_flag(_state: GameState, _player_index: int, _flag: String) -> bool:
	return false


## How many times over resources of `kind` created for `player_index` are multiplied (Infinite Pantry, Harvest Festival).
static func resource_multiplier(_state: GameState, _player_index: int, _kind: ResourceKind.Kind) -> int:
	return 1
