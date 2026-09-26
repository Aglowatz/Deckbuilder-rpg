class_name Targets
extends RefCounted
## Target references are plain ints: a positive value is a card uid, a negative value is a
## player (-1 = player 0, -2 = player 1), and 0 means "no target".

const NONE: int = 0


static func player(index: int) -> int:
	return -(index + 1)


static func is_player(ref: int) -> bool:
	return ref < 0


static func player_index(ref: int) -> int:
	return -ref - 1
