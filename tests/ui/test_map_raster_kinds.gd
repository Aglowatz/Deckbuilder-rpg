extends GutTest
## Overnight Oct 17 (Phase 2 cycle 24): the map sorts ground into open ground, path and blocked a few rows per frame, then reuses it.


class FakeArea:
	extends WalkableArea

	func is_walkable(pos: Vector3, _body_radius: float = 0.3) -> bool:
		return not (pos.x > 2.0 and pos.x < 3.0 and pos.z > 2.0 and pos.z < 3.0)

	func is_floor_at(pos: Vector3) -> bool:
		return pos.x >= 0.0 and pos.x < 8.0 and pos.z >= 0.0 and pos.z < 8.0

	func surface_at(pos: Vector3) -> StringName:
		return &"cobble" if pos.x > 5.0 and pos.x < 6.0 else &"grass"

	func map_bounds() -> Rect2:
		return Rect2(0.0, 0.0, 8.0, 8.0)


func test_cells_are_sorted_and_reused() -> void:
	MapRaster._kind_cache.clear()
	var area: FakeArea = FakeArea.new()
	var fog: FogOfWar = FogOfWar.for_bounds(area.map_bounds())
	var raster: MapRaster = MapRaster.build(area, fog)
	assert_false(raster.refined, "plain ground first")
	var guard: int = 0
	while not raster.refine(1000) and guard < 200:
		guard += 1
	assert_true(raster.refined)
	var blocked_cell: Vector2i = Vector2i(roundi((2.5 - fog.origin.x) / FogOfWar.CELL - 0.5), roundi((2.5 - fog.origin.y) / FogOfWar.CELL - 0.5))
	var path_cell: Vector2i = Vector2i(roundi((5.5 - fog.origin.x) / FogOfWar.CELL - 0.5), roundi((0.5 - fog.origin.y) / FogOfWar.CELL - 0.5))
	assert_eq(raster.kind_at(blocked_cell.x, blocked_cell.y), MapRaster.BLOCKED)
	assert_eq(raster.kind_at(path_cell.x, path_cell.y), MapRaster.PATH)
	var again: MapRaster = MapRaster.build(area, fog)
	assert_true(again.refined, "the second map of the same area reuses the sorted cells")
