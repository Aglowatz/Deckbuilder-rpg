class_name WalkableArea
extends RefCounted
## Common interface for the hex-grid areas `TownPlayer` can walk around in (`TownBuilder`,
## `StartingAreaBuilder`): whether a world position may be stood on. Lets one player controller
## and its collision/sliding logic be shared by every walkable 3D scene.


## True when a character may stand at `pos` (on a walkable cell and clear of obstacles).
func is_walkable(_pos: Vector3, _body_radius: float = 0.22) -> bool:
	return false


## Height of the ground at `pos` (hills, floating islands). Flat areas stay at 0.
func height_at(_pos: Vector3) -> float:
	return 0.0
