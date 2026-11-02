extends GutTest
## Nov 2 pass, Part 2: however the Capital is built - walking in through the gate, the hidden hole in the west wall (the hero already inside
## when the scene builds), the service shaft into the Crease, a fast-travel landing, a save loaded inside, the return from a battle inside,
## the freed city, or a rebuild from the build cache - no random bush, shrub, grass clump or wildflower stands inside the walls. The formal
## topiary, rose planters and garden beds (CapitalDressing) are design and stay; this counts the generic layers (WorldFoliage, ZoneDressing).
##
## The cause was WorldLookRig: the `capital_inside` / `capital_freed` moods carried a foliage density of 1, so a build that started with the
## hero inside (the mood is picked from where the hero stands) scattered the look rig's grass, flowers and bushes over the whole city, while
## a build that started outside (the gate: `capital_outskirts`, density 0) never made the layer at all. Both moods now say 0.

const SCENE: String = "res://scenes/capital_zone.tscn"
## Node names of the generic scatter layers (the Capital's own design dressing is `CapitalDressing`).
const SCATTER_LAYERS: Array[String] = ["WorldFoliage", "ZoneDressing"]

var _inside_points: Array[Vector3] = [Vector3(60.0, 0.0, 40.0), Vector3(20.0, 0.0, 58.0), Vector3(100.0, 0.0, 58.0), Vector3(8.0, 0.0, 30.0)]


func before_each() -> void:
	Session.new_game()


func after_each() -> void:
	Session.pending_zone_result = {}
	Session.arrive_at_station = false


func _inside(p: Vector3) -> bool:
	return p.x > 1.0 and p.x < 119.0 and p.z > 1.0 and p.z < float(CapitalLayout.WALL_Z0)


func _under_scatter_layer(node: Node) -> bool:
	var walk: Node = node
	while walk != null:
		if walk.name in SCATTER_LAYERS:
			return true
		walk = walk.get_parent()
	return false


## Instances of the generic scatter layers that stand inside the walls: {"inside": n, "total": n, "layers": [names]}.
func _scatter_inside(scene: Node) -> Dictionary:
	var inside: int = 0
	var total: int = 0
	var layers: Array[String] = []
	var ranges: Dictionary = {}
	for layer: String in SCATTER_LAYERS:
		for found: Node in scene.find_children(layer, "", true, false):
			layers.append(found.name)
	for node: Node in scene.find_children("*", "MultiMeshInstance3D", true, false):
		if not _under_scatter_layer(node):
			continue
		var mm: MultiMeshInstance3D = node as MultiMeshInstance3D
		if mm.multimesh == null:
			continue
		# the producers keep every instance position as metadata: a headless (dummy) renderer reads MultiMesh transforms back as the identity
		var positions: PackedVector3Array = mm.get_meta(&"positions", PackedVector3Array()) as PackedVector3Array
		assert_eq(positions.size(), mm.multimesh.instance_count, "%s records a position per instance" % mm.get_parent().name)
		for index: int in range(positions.size()):
			total += 1
			var p: Vector3 = mm.global_transform * positions[index]
			var r: Array = ranges.get(mm.get_parent().name, [Vector3.ONE * 1e9, -Vector3.ONE * 1e9, 0]) as Array
			ranges[mm.get_parent().name] = [(r[0] as Vector3).min(p), (r[1] as Vector3).max(p), int(r[2]) + 1]
			if _inside(p):
				inside += 1
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		if not _under_scatter_layer(node):
			continue
		total += 1
		if _inside((node as Node3D).global_position):
			inside += 1
	return {"inside": inside, "total": total, "layers": layers, "ranges": ranges}


func _build() -> ZoneScene:
	var scene: ZoneScene = (load(SCENE) as PackedScene).instantiate() as ZoneScene
	scene.call("screenshot_prepare", {"nohud": "true"})
	add_child(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	return scene


func _check(label: String) -> void:
	var scene: ZoneScene = await _build()
	var report: Dictionary = _scatter_inside(scene)
	gut.p("%s: hero at %s, mood %s, scatter layers %s, %d instances, %d inside the wall" % [label, str(scene.player.position), str(scene.style_rig.preset_id), str(report["layers"]), int(report["total"]), int(report["inside"])])
	gut.p("  ranges: %s" % str(report["ranges"]))
	assert_eq(int(report["inside"]), 0, "%s: no random plant inside the walls" % label)
	scene.queue_free()
	await get_tree().process_frame


func _start_inside(at: Vector3) -> void:
	Session.ensure_game()
	Session.begin_zone_visit(CapitalZone.ID)
	Session.zone_run.return_position = at
	Session.zone_run.has_return_position = true
	Session.set_flag(CapitalZone.FLAG_INSIDE)


func test_the_capital_moods_carry_no_random_foliage() -> void:
	for mood_id: String in ["capital_inside", "capital_inside_dark", "capital_freed", "capital_outskirts", "capital_dark"]:
		var mood: Dictionary = WorldLookRig.mood_for(StringName(mood_id))
		var foliage: Dictionary = mood.get("foliage", {}) as Dictionary
		assert_eq(float(foliage.get("density", 1.0)), 0.0, "%s: the look rig's foliage layer is off" % mood_id)


func test_entry_through_the_gate() -> void:
	await _check("gate (fresh visit, outside)")


func test_entry_through_the_hidden_hole_in_the_west_wall() -> void:
	# The hero squeezed through the hole: the next build (a fight, a save) starts behind the Reek's yards.
	Session.discover_secret(CapitalScene.WALL_PASSAGE_SECRET)
	_start_inside(Vector3(8.0, 0.0, 30.0))
	await _check("west-wall hole")


func test_entry_through_the_service_shaft_into_the_crease() -> void:
	Session.set_flag(CapitalZone.FLAG_TUNNEL_FOUND)
	Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
	Session.set_flag(CapitalZone.FLAG_INSIDE)
	Session.ensure_game()
	Session.begin_zone_visit(CapitalZone.ID)
	await _check("service shaft (Crease spawn)")


func test_fast_travel_landing() -> void:
	Session.ensure_game()
	Session.begin_zone_visit(CapitalZone.ID)
	Session.arrive_at_station = true
	await _check("fast travel (rift station)")


func test_a_save_loaded_inside_the_walls() -> void:
	for at: Vector3 in _inside_points:
		Session.new_game()
		_start_inside(at)
		await _check("save loaded inside at %s" % str(at))


func test_the_return_from_a_battle_inside_the_walls() -> void:
	_start_inside(Vector3(60.0, 0.0, 40.0))
	Session.pending_zone_result = {"kind": "enemy_win", "enemy_id": "", "gold": 0, "xp": 0}
	await _check("back from a battle inside")


func test_the_freed_city() -> void:
	Session.set_flag(&"primm_defeated")
	Session.set_flag(CapitalZone.FLAG_FREED)
	_start_inside(Vector3(60.0, 0.0, 40.0))
	await _check("freed city, hero inside")
	Session.new_game()
	Session.set_flag(&"primm_defeated")
	Session.set_flag(CapitalZone.FLAG_FREED)
	await _check("freed city, hero at the gate")


func test_a_rebuild_from_the_build_cache() -> void:
	_start_inside(Vector3(60.0, 0.0, 40.0))
	await _check("first build inside (fills the cache)")
	Session.new_game()
	_start_inside(Vector3(60.0, 0.0, 40.0))
	await _check("second build inside (from the cache)")
