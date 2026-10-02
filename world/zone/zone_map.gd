class_name ZoneMap
extends WalkableArea
## What a zone's world has to provide to the shared zone framework (`ZoneScene`, `ZoneEnemy`, the
## minimap): building the geometry, named anchors, walkability/line of sight, hidden chest and enemy
## spawn positions, area names for the zone banner and the height of the ground. A new zone's
## map class (`DnaBuilder`, `GainlandsBuilder`) extends this; the defaults are the "do nothing" case.

## Chest nodes by chest id (so the scene can animate the one that opens).
var chest_nodes: Dictionary = {}


## Builds all geometry under `parent`.
func build(_parent: Node3D) -> void:
	pass


## A named world position ("spawn", "heal", "exit", ...); zero when unknown.
func anchor(_anchor_name: String) -> Vector3:
	return Vector3.ZERO


func has_anchor(_anchor_name: String) -> bool:
	return false


## Hidden chest positions by id. Never shown on the map.
func chest_positions() -> Dictionary:
	return {}


## Roaming enemy spawns: [{type, home, patrol}].
func enemy_spawns() -> Array[Dictionary]:
	return []


## A runtime blocker (an NPC standing somewhere).
func add_blocker(_pos: Vector3, _radius: float) -> void:
	pass


func has_line_of_sight(_a: Vector3, _b: Vector3) -> bool:
	return true


## Hides far geometry (chunked zones); called every frame with the player position.
func update_visibility(_focus: Vector3) -> void:
	pass


## The [id, title] of the named area at `pos` for the zone banner, or [] outside any.
func area_at(_pos: Vector3) -> Array[String]:
	return []


## True when there is ground (of any kind, ignoring props and NPCs) at `pos` - the minimap draws it.
func is_floor_at(_pos: Vector3) -> bool:
	return false


## World-space xz rectangle covering everything walkable (the minimap's extent).
func map_bounds() -> Rect2:
	return Rect2()
