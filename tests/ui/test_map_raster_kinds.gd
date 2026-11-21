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


## Fable Nov 21 review (Part 5): the full map uses the picture the minimap already keeps for the same area and fog, and builds its own
## only when there is none (another area, another fog, the outline switched, or the minimap's picture gone).
func test_the_full_map_shares_the_minimaps_picture() -> void:
	MapRaster._kind_cache.clear()
	var area: FakeArea = FakeArea.new()
	var fog: FogOfWar = FogOfWar.for_bounds(area.map_bounds())
	var minimap_picture: MapRaster = MapRaster.build(area, fog)
	var hits: int = MapRaster.shared_hits
	var map_picture: MapRaster = MapRaster.shared_or_build(area, fog)
	assert_same(map_picture, minimap_picture, "the same picture, not a second copy")
	assert_eq(MapRaster.shared_hits, hits + 1)
	# what the minimap reveals shows on the shared picture at once
	var before: Color = map_picture.image.get_pixel(MapRaster.PAD + 1, MapRaster.PAD + 1)
	minimap_picture.apply_reveal(fog.reveal(Vector2(1.5, 1.5), 3.0))
	assert_ne(map_picture.image.get_pixel(MapRaster.PAD + 1, MapRaster.PAD + 1), before, "a newly walked cell is drawn on it")
	# another fog, the outline, or another area: its own picture
	var other_fog: FogOfWar = FogOfWar.for_bounds(area.map_bounds())
	assert_ne(MapRaster.shared_or_build(area, other_fog), minimap_picture, "another fog gets its own picture")
	assert_ne(MapRaster.shared_or_build(area, fog, true), minimap_picture, "the outlined picture is another picture")
	var other_area: FakeArea = FakeArea.new()
	assert_ne(MapRaster.shared_or_build(other_area, fog), minimap_picture, "another area gets its own picture")


func test_a_picture_that_is_gone_is_built_again() -> void:
	MapRaster._kind_cache.clear()
	var area: FakeArea = FakeArea.new()
	var fog: FogOfWar = FogOfWar.for_bounds(area.map_bounds())
	var first: MapRaster = MapRaster.build(area, fog)
	var first_id: int = first.get_instance_id()
	first = null
	var again: MapRaster = MapRaster.shared_or_build(area, fog)
	assert_not_null(again)
	assert_not_null(again.texture)
	assert_ne(again.get_instance_id(), first_id, "the old picture was freed with its map; a new one is built")
