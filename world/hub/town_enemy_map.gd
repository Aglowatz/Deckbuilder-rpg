class_name TownEnemyMap
extends ZoneMap
## Playtest v0.4.0, Part D: the walkable country of Crosspath seen through the zone framework's eyes, so `ZoneEnemy` can roam the
## town's outskirts. Wraps the `TownBuilder` (a `WalkableArea`, not a `ZoneMap`): walkability and ground height come from it; roamers
## are kept out of the square, off the roads' passages and inside the hub outline, and never near the hero's spawn point.

const KEEP_OUT_RADIUS: float = 16.0
const PASSAGE_RADIUS: float = 6.0

var town: TownBuilder
var keep_out: Array[Vector3] = []


static func wrap(builder: TownBuilder) -> TownEnemyMap:
	var map: TownEnemyMap = TownEnemyMap.new()
	map.town = builder
	map.keep_out.append(TownLayout.PLAZA)
	map.keep_out.append(TownLayout.SPAWN)
	return map


func is_walkable(pos: Vector3, body_radius: float = StorybookScale.BODY_RADIUS) -> bool:
	return town != null and town.is_walkable(pos, body_radius)


func height_at(pos: Vector3) -> float:
	return town.height_at(pos) if town != null else 0.0


func is_floor_at(pos: Vector3) -> bool:
	return town != null and town.is_floor_at(pos)


func map_bounds() -> Rect2:
	return town.map_bounds() if town != null else Rect2()


func enemy_spawns() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in TownEnemies.SPAWNS:
		result.append(entry.duplicate())
	return result


## Roamers stay on the outskirts: walkable ground inside the hub outline, outside the square and the spawn, clear of every zone passage.
func is_enemy_walkable(pos: Vector3, body_radius: float = 0.25) -> bool:
	if not is_walkable(pos, body_radius):
		return false
	if town.hub_land and not TownBounds.contains(pos):
		return false
	for point: Vector3 in keep_out:
		if Vector2(pos.x - point.x, pos.z - point.z).length() < KEEP_OUT_RADIUS:
			return false
	for key: Variant in town.anchors.keys():
		if str(key).begins_with("portal_") and not str(key).ends_with("_mouth"):
			var portal: Vector3 = town.anchors[key] as Vector3
			if Vector2(pos.x - portal.x, pos.z - portal.z).length() < PASSAGE_RADIUS:
				return false
	return true
