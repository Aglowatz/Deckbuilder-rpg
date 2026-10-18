extends GutTest
## Opening Forest rebuild (docs/art/opening_forest.md): the layout keeps the playbook's clearances, the camp and the hooded figure sit where the paint-over has
## them, the path to the cave is wide and clear, the tutorial's spots (spawn, gate, Maren's, the secrets) still work, and the dressing keeps off the floor.

const HERO_WIDTH: float = StorybookScale.BODY_RADIUS * 2.0


func _built(lab_open: bool = false) -> StartingAreaBuilder:
	var area: StartingAreaBuilder = StartingAreaBuilder.new()
	area.lab_open = lab_open
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	area.build(root)
	return area


func test_the_path_is_four_hero_widths_and_nothing_solid_stands_on_it() -> void:
	assert_gte(OpeningForestLayout.PATH_HALF * 2.0, 4.2, "the path is a main route: 4.2 m or more (playbook 20)")
	assert_gte(OpeningForestLayout.PATH_HALF * 2.0, HERO_WIDTH * 4.0)
	var area: StartingAreaBuilder = _built()
	for obstacle: Vector3 in area.obstacles:
		if obstacle == OpeningForestLayout.MOUTH_BLOCKER:
			continue  # the lip of the cave mouth is where the path ends
		var clear: float = area.layout.path_distance(Vector2(obstacle.x, obstacle.y)) - obstacle.z
		assert_gt(clear, OpeningForestLayout.PATH_HALF - 0.05, "nothing solid on the path: %s" % str(obstacle))
	for rock: Vector3 in area.models.boulder_points:
		assert_gt(area.layout.path_distance(Vector2(rock.x, rock.y)), OpeningForestLayout.PATH_HALF, "no boulder on the path: %s" % str(rock))


func test_the_path_runs_from_the_clearing_back_and_right_to_the_cave() -> void:
	var path: Array[Vector2] = OpeningForestLayout.PATH
	var gate: Vector3 = OpeningForestLayout.GATE
	var spawn: Vector3 = OpeningForestLayout.SPAWN
	assert_lt(path[0].distance_to(Vector2(spawn.x, spawn.z)), 5.0, "the path starts at the camp's clearing")
	assert_lt(path[path.size() - 1].distance_to(Vector2(gate.x, gate.z)), 0.5, "and ends at the cave gate")
	assert_gt(gate.x - spawn.x, 6.0, "the cave is to the right")
	assert_lt(gate.z - spawn.z, -15.0, "and well back from the camp")
	var walk: float = 0.0
	for index: int in range(path.size() - 1):
		walk += path[index].distance_to(path[index + 1])
	assert_between(walk, 16.0, 40.0, "a short walk, not a corridor")


func test_the_camp_and_the_hooded_figure_sit_at_the_front_of_the_clearing() -> void:
	var layout: OpeningForestLayout = OpeningForestLayout.new()
	var spawn: Vector2 = Vector2(OpeningForestLayout.SPAWN.x, OpeningForestLayout.SPAWN.z)
	for id: String in ["bedroll", "pack", "lantern", "rescuer"]:
		var mark: Vector3 = layout.mark(id)
		assert_true(layout.is_floor(Vector2(mark.x, mark.z)), "%s stands in the clearing" % id)
		assert_lt(Vector2(mark.x, mark.z).distance_to(spawn), 3.4, "%s is beside the wake-up spot" % id)
	var lantern: Vector3 = layout.mark("lantern")
	assert_gt(lantern.z, layout.mark("rescuer").z, "the lantern is in front of the hooded figure (camera side)")
	var area: StartingAreaBuilder = _built()
	assert_true(area.is_walkable(OpeningForestLayout.SPAWN), "the hero wakes up on open ground")


func test_the_cave_spots_of_the_tutorial_still_work() -> void:
	var area: StartingAreaBuilder = _built()
	var gate: Vector3 = area.anchors["gate"] as Vector3
	assert_true(area.is_walkable(gate + Vector3(0.0, 0.0, 0.5)), "the hero stands at the gate after the cave")
	assert_true(area.is_walkable(gate + Vector3(0.0, 0.0, 2.3)), "Elder Maren's spot is open ground")
	var mouth: Vector3 = area.layout.mark("cave_mouth")
	assert_false(area.is_walkable(mouth), "the cave itself is not walkable (no explorable cave)")
	assert_lt(Vector2(gate.x - mouth.x, gate.z - mouth.z).length(), 2.6, "the gate stands at the mouth")


func test_the_only_way_out_is_the_cave_mouth() -> void:
	var layout: OpeningForestLayout = OpeningForestLayout.new()
	var bounds: Rect2 = layout.bounds()
	assert_lt(bounds.size.x, 34.0, "a small opening area")
	assert_lt(bounds.size.y, 34.0)
	var mouth: Vector3 = layout.mark("cave_mouth")
	for x: float in [mouth.x - 6.0, mouth.x, mouth.x + 4.0]:
		assert_false(layout.is_floor(Vector2(x, mouth.z - 1.0)), "no floor behind the cliff at x %.1f" % x)


func test_the_side_nook_holds_a_chest_off_the_main_path() -> void:
	var nook: Vector3 = OpeningForestLayout.POCKETS["nook"] as Vector3
	var chest: Vector3 = (OpeningForestLayout.HIDDEN_CHESTS["start_west"] as Dictionary)["pos"] as Vector3
	assert_lt(Vector2(chest.x - nook.x, chest.z - nook.y).length(), nook.z, "the west chest is in the nook")
	var layout: OpeningForestLayout = OpeningForestLayout.new()
	assert_gt(layout.path_distance(Vector2(nook.x, nook.y)), OpeningForestLayout.PATH_HALF + nook.z, "the nook is a side trip, off the path")
	assert_true(layout.is_quiet(Vector2(nook.x, nook.y)), "the hero does not talk themselves back from the nook")
	var area: StartingAreaBuilder = _built()
	var can_stand: Callable = func(pos: Vector3) -> bool: return area.is_walkable(pos, 0.22)
	assert_eq(WalkProbe.unreachable(can_stand, OpeningForestLayout.SPAWN, area.map_bounds(), {"nook": Vector3(nook.x, 0.0, nook.y)}), [] as Array[String], "the nook is reached")


func test_breathing_room_round_the_gate_and_the_camp() -> void:
	var area: StartingAreaBuilder = _built()
	var gate: Vector3 = area.anchors["gate"] as Vector3
	for obstacle: Vector3 in area.obstacles:
		var d: float = Vector2(obstacle.x - gate.x, obstacle.y - gate.z).length() - obstacle.z
		if obstacle == OpeningForestLayout.MOUTH_BLOCKER:
			continue
		assert_gt(d, 1.5, "nothing crowds the gate: %s" % str(obstacle))


func test_the_lab_pocket_is_treeline_until_revealed() -> void:
	var closed: StartingAreaBuilder = _built(false)
	var open: StartingAreaBuilder = _built(true)
	var lab: Vector3 = closed.anchors["lab"] as Vector3
	assert_false(closed.is_floor_at(lab + Vector3(0, 0, 0.6)))
	assert_true(open.is_floor_at(lab + Vector3(0, 0, 0.6)))
	var can_stand: Callable = func(pos: Vector3) -> bool: return open.is_walkable(pos, 0.22)
	assert_eq(WalkProbe.unreachable(can_stand, OpeningForestLayout.SPAWN, open.map_bounds(), {"lab": lab}), [] as Array[String], "the hatch is reached once open")


func test_dressing_keeps_off_the_floor_and_the_camera_side() -> void:
	var area: StartingAreaBuilder = _built()
	for p: Vector2 in area.models.tree_points:
		assert_gt(area.layout.floor_sdf(p), 0.9, "tree at %s stands off the floor" % str(p))
		assert_false(area.layout.camera_side(p), "tree at %s is not between the camera and the floor" % str(p))
	assert_gt(area.models.tree_points.size(), 60, "a dense forest edge")
	assert_gt(area.models.fern_count, 120, "ferns and undergrowth at the edges")
	assert_gt(area.models.flagstone_count, 20, "flagstones along the path")
	assert_gt(area.models.boulder_points.size(), 12, "mossy boulders round the clearing")


func test_the_stand_ins_are_listed() -> void:
	assert_gte(OpeningForestModels.STANDINS.size(), 8)
	for id: String in OpeningForestModels.STANDINS.keys():
		assert_true(id.begins_with("OF-"), "%s uses the OF- prefix" % id)


func _atmosphere(quality: int) -> OpeningForestAtmosphere:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var hero: Node3D = Node3D.new()
	host.add_child(hero)
	return OpeningForestAtmosphere.build(host, OpeningForestLayout.new(), hero, quality)


func test_the_lantern_is_a_warm_real_light_at_the_camp_and_the_cave_glows_cool() -> void:
	var air: OpeningForestAtmosphere = _atmosphere(GraphicsQuality.Level.MEDIUM)
	assert_not_null(air.lantern_light)
	assert_gt(air.lantern_light.light_color.r, air.lantern_light.light_color.b + 0.3, "the lantern is warm amber")
	var lantern: Vector3 = OpeningForestLayout.MARKS["lantern"] as Vector3
	assert_lt(Vector2(air.lantern_light.position.x - lantern.x, air.lantern_light.position.z - lantern.z).length(), 0.1, "the light sits in the lantern")
	assert_gt(air.cave_light.light_color.b, air.cave_light.light_color.r, "the cave glow is cool")
	assert_not_null(air.hero_light, "a soft light rides with the hero")
	assert_gt(air.shroom_count, 5, "glowing mushrooms lead up the path")


func test_the_lantern_flickers_gently() -> void:
	var air: OpeningForestAtmosphere = _atmosphere(GraphicsQuality.Level.MEDIUM)
	var seen: Array[float] = []
	for i: int in range(40):
		air._process(0.05)
		seen.append(air.lantern_light.light_energy)
	assert_gt(seen.max() - seen.min(), 0.05, "it flickers")
	assert_lt(seen.max() - seen.min(), OpeningForestAtmosphere.LANTERN_ENERGY * 0.35, "never a strobe")


func test_quality_scales_the_mist_rays_and_mushrooms() -> void:
	var low: OpeningForestAtmosphere = _atmosphere(GraphicsQuality.Level.LOW)
	var high: OpeningForestAtmosphere = _atmosphere(GraphicsQuality.Level.HIGH)
	assert_lt(low.mist_count, high.mist_count)
	assert_lt(low.ray_count, high.ray_count)
	assert_lt(low.shroom_count, high.shroom_count)
	assert_gte(low.mist_count, 3, "even Low keeps ground mist")
