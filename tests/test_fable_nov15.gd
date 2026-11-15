extends GutTest
## Fable Nov 15 (the owner's four fixes): the pins for this pass.
## Part 1 - outside the D.N.A. is a wasteland like the one outside the Capital: the same ash ground and the Capital's wasteland kit,
## composed (never rows), off the walkable map, under the camera's line; the floating paper stays.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.save_enabled = true


# ---- Part 1: the D.N.A.'s wasteland ----------------------------------------------------------------------------------------------------


func _dna_wasteland() -> Array:
	var builder: DnaBuilder = DnaBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var dressing: DnaDressing = DnaDressing.build(holder, builder, 1)
	return [builder, dressing.wasteland, holder]


func test_the_dna_ground_is_the_capitals_ash_not_grey_tiles() -> void:
	var moods: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/zone_looks.json")) as Dictionary
	var scenery: Dictionary = (moods["dna"] as Dictionary)["scenery"] as Dictionary
	var apron: Dictionary = scenery["apron"] as Dictionary
	assert_false(apron.has("tiles"), "no flat grey tiles")
	var ground: Dictionary = apron["wasteland"] as Dictionary
	assert_eq(str(ground["ash"]), "TEX-CAP-ASH", "the Capital's outer ground")
	assert_eq(str(ground["paving"]), "TEX-CAP-CRACKEDROAD")
	assert_true(WorldScenery._apron_material(apron) is ShaderMaterial, "the wasteland ground material builds")
	assert_true(bool(scenery["rings"]), "the far skyline shows, so the ground never ends in a bare horizon")
	var capital: Dictionary = (moods["capital_outskirts"] as Dictionary)["look"] as Dictionary
	assert_eq(float(((moods["dna"] as Dictionary)["look"] as Dictionary)["fog_density"]), float(capital["fog_density"]), "the Capital's fog density")


func test_the_dna_wasteland_uses_the_capitals_kit() -> void:
	for id: String in ["CAP-TREE-DEAD", "CAP-PLANT-CRYSTAL", "CAP-DEC-ASH", "CAP-PROP-RUBBLE-ROW", "CAP-SHEET-RUBBLE-01", "CAPI-PROP-STATUE-FALLEN", "CAP-WALL-RUIN"]:
		assert_true(EnvKit.has_art(id), "%s is imported" % id)
	var parts: Array = _dna_wasteland()
	var wasteland: DnaWasteland = parts[1] as DnaWasteland
	assert_not_null(wasteland, "the dressing builds the wasteland")
	var least: Dictionary = {"house": 4, "fragment": 14, "statue": 2, "crystal": 12, "tree": 30, "mound": 20, "lamp": 6, "debris": 3, "row": 8}
	for kind: String in least.keys():
		assert_gte((wasteland.placed[kind] as Array).size(), int(least[kind]), "%s: %d placed" % [kind, (wasteland.placed[kind] as Array).size()])
	assert_gt(wasteland.tufts, 200, "dark tufts of dead grass (%d)" % wasteland.tufts)
	assert_lte((wasteland.placed["debris"] as Array).size(), 8, "only a few office touches stay")
	var holder: Node3D = parts[2] as Node3D
	assert_null(holder.find_child("WastelandCrates", true, false), "the rows of crates are gone")
	assert_false(FileAccess.get_file_as_string("res://world/dna/dna_dressing.gd").contains("WASTELAND_ROWS"), "and so are the furniture rows")
	assert_true(FileAccess.get_file_as_string("res://world/dna/dna_scene.gd").contains("DnaPaperDrift.build"), "the floating paper stays")
	assert_eq(DnaPaperDrift.COUNT, 380, "as thick as before")


func test_the_dna_wasteland_stands_off_the_map_and_under_the_camera() -> void:
	var parts: Array = _dna_wasteland()
	var builder: DnaBuilder = parts[0] as DnaBuilder
	var wasteland: DnaWasteland = parts[1] as DnaWasteland
	for spot: Vector3 in wasteland.all_spots():
		assert_false(builder.is_floor_at(spot), "nothing stands on the floor (%s)" % str(spot))
		assert_gte(wasteland.distance_at(spot.x, spot.z), 1.5, "nor against a wall (%s)" % str(spot))
		assert_false(DnaLayout.on_approach(spot.x, spot.z), "nor on the causeway")
		assert_false(builder.is_walkable(spot), "and nothing can be walked into")
	for kind: String in ["house", "fragment", "statue", "crystal", "tree", "mound"]:
		for spot: Variant in wasteland.placed[kind] as Array:
			assert_false(DnaWasteland.kept_out((spot as Vector3).x, (spot as Vector3).z), "%s keeps off the causeway and the far landmarks" % kind)
	# never rows: no three trees share a line of latitude (the Nov 14 rows stood on exact z values)
	var by_z: Dictionary = {}
	for spot: Variant in wasteland.placed["tree"] as Array:
		var key: int = int(roundf((spot as Vector3).z * 10.0))
		by_z[key] = int(by_z.get(key, 0)) + 1
	for key: Variant in by_z.keys():
		assert_lt(int(by_z[key]), 3, "trees are scattered, not in a row (z %.1f)" % (float(key) / 10.0))
	# under the camera's line: a house shell never stands with floor close to its north
	for spot: Variant in wasteland.placed["house"] as Array:
		assert_gte(wasteland.north_cap((spot as Vector3).x, (spot as Vector3).z), 5.0, "a ruined house never hides the hero")
	# the same every visit
	var again: DnaWasteland = (_dna_wasteland()[1]) as DnaWasteland
	assert_eq(again.all_spots(), wasteland.all_spots(), "placement is fixed")


# ---- Part 2: Mortimer Grimsby in the freed lobby ---------------------------------------------------------------------------------------


func test_mortimer_stands_on_the_lobbys_west_side_clear_of_everything() -> void:
	var def: ZoneDef = DnaZone.build_def()
	var builder: DnaBuilder = DnaBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var dressing: DnaDressing = DnaDressing.build(holder, builder, 1)
	var hub: Vector3 = builder.anchor(def.hub_anchor)
	var mortimer: Vector3 = Vector3.INF
	var others: Dictionary = {}
	for entry: Dictionary in def.freed_npcs:
		var pos: Vector3 = hub + (entry["offset"] as Vector3)
		if str(entry["id"]) == "mortimer":
			mortimer = pos
		else:
			others["freed %s" % str(entry["id"])] = pos
	assert_ne(mortimer, Vector3.INF, "Mortimer is one of the freed lobby's people")
	var station: Vector3 = builder.anchor(FastTravel.ANCHOR)
	assert_lt(mortimer.x, hub.x - 3.0, "he stands on the left (west) side of the entrance room")
	assert_gt(Vector2(mortimer.x - station.x, mortimer.z - station.z).length(), 5.0, "well clear of the Rift Station (was 0.6 m)")
	var room: DnaLayout.Room = builder.layout.room_at(mortimer)
	assert_not_null(room, "inside a room")
	assert_eq(builder.layout.room_at(hub).id, room.id, "the entrance room itself")
	assert_false(DnaLayout.LOBBY_WEST_PASSAGE.grow(0.8).has_point(Vector2(mortimer.x, mortimer.z)), "not in the west passage")
	# open floor all round him (the dressing's blockers are in the builder by now)
	for step: int in range(16):
		var angle: float = TAU * float(step) / 16.0
		assert_true(builder.is_walkable(mortimer + Vector3(cos(angle), 0.0, sin(angle)) * 1.1, 0.25), "open floor %d degrees round him" % int(rad_to_deg(angle)))
	# nobody and nothing with a prompt or a label within 2.5 m
	others["the Rift Express operator"] = station + Vector3(-2.4, 0.0, 0.8)
	for entry: Dictionary in def.npcs:
		others["npc %s" % str(entry["id"])] = builder.anchor(str(entry["anchor"])) + (entry.get("offset", Vector3.ZERO) as Vector3)
	for entry: Dictionary in def.spots:
		others["spot %s" % str(entry["id"])] = builder.anchor(str(entry["anchor"])) + (entry["offset"] as Vector3)
	for id: Variant in dressing.lobby_placed.keys():
		others["prop %s" % str(id)] = dressing.lobby_placed[id] as Vector3
	for key: Variant in others.keys():
		var at: Vector3 = others[key] as Vector3
		assert_gt(Vector2(mortimer.x - at.x, mortimer.z - at.z).length(), 2.5, "%s is more than 2.5 m away" % str(key))
