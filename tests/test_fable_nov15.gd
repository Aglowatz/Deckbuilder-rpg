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


# ---- Part 3: no 3D or placeholder people -----------------------------------------------------------------------------------------------
# (the scene-level check is the driver tools/run_npc_3d_scan.sh: every area, oppressed and freed, has no rigged model and no capsule)


func test_every_placed_npc_is_a_painted_sprite() -> void:
	# the zones: the standing people and the freed lobby's people
	for zone_id: String in ZoneDefs.ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		var entries: Array = []
		entries.append_array(def.npcs)
		entries.append_array(def.freed_npcs)
		for entry: Variant in entries:
			var character: String = NpcSprites.character_for_entry(entry as Dictionary)
			assert_true(character != "" and SpriteLibrary.has_character(character), "%s: %s is a painted sprite (a 3D %s otherwise)" % [zone_id, str((entry as Dictionary)["id"]), str((entry as Dictionary).get("model", "?"))])
	# Crosspath: every id the town places
	var town: GDScript = load("res://world/town_scene.gd") as GDScript
	var source: String = FileAccess.get_file_as_string("res://world/town_scene.gd")
	var sprites: Dictionary = town.get("NPC_SPRITES") as Dictionary
	var ids: Dictionary = town.get("NPC_IDS") as Dictionary
	var regex: RegEx = RegEx.new()
	regex.compile("_add_npc\\(\"([a-z_]+)\"")
	var placed: Array[String] = []
	for found: RegExMatch in regex.search_all(source):
		placed.append(found.get_string(1))
	assert_gt(placed.size(), 8, "the town's NPC list was read (%d)" % placed.size())
	assert_false(placed.has("mannequin"), "the 3D window mannequin beside Pip Threadwell is gone")
	for id: String in placed:
		var character: String = str(sprites.get(id, ""))
		if character == "":
			character = NpcSprites.character_for(str(ids.get(id, "")))
		assert_true(character != "" and SpriteLibrary.has_character(character), "Crosspath %s is a painted sprite" % id)


func test_the_ruler_statue_is_the_painted_ruler_in_stone() -> void:
	for zone_id: String in ZoneDefs.ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		for toppled: bool in [false, true]:
			var statue: Node3D = RulerPresence._statue(def.ruler_tint, toppled, zone_id)
			add_child_autofree(statue)
			for node: Node in statue.find_children("*", "MeshInstance3D", true, false):
				assert_false((node as MeshInstance3D).mesh is CapsuleMesh, "%s: no capsule figure" % zone_id)
				assert_false((node as MeshInstance3D).mesh is SphereMesh, "%s: no ball for a head" % zone_id)
			var figure: MeshInstance3D = statue.get_node_or_null(RulerPresence.FIGURE_NAME) as MeshInstance3D
			assert_not_null(figure, "%s: the ruler's painted figure stands for the statue" % zone_id)
			if figure != null:
				# Batch 17 (Nov 18): the painted stone statue (its own art) where it is in the game, else the cut-out through the statue shader
				assert_true(figure.material_override is ShaderMaterial or figure.has_meta("statue_art"), "carved in stone (painted statue or the statue shader)")
				assert_eq(figure.position.y < 0.5, toppled, "standing on the plinth while oppressed, lying beside it once freed")


# ---- Part 4b: shops that scroll show it; the packs' medallions ---------------------------------------------------------------------------


func test_every_scrollbar_of_the_theme_can_be_seen() -> void:
	var theme: Theme = UIStyle.theme()
	for bar: String in ["VScrollBar", "HScrollBar"]:
		var track: StyleBoxFlat = theme.get_stylebox("scroll", bar) as StyleBoxFlat
		assert_not_null(track, "%s has a track" % bar)
		assert_gte(track.content_margin_left + track.content_margin_right, 12.0, "%s is thick enough to see and grab" % bar)
		assert_gt(track.border_width_left, 0, "the track has an edge (it was a 35 %% black smudge on dark wood)")
		assert_gt(track.border_color.a, 0.5)
		var grabber: StyleBoxFlat = theme.get_stylebox("grabber", bar) as StyleBoxFlat
		assert_gt(grabber.bg_color.r, 0.5, "a gold grabber")


func test_a_shop_row_scrolls_with_the_wheel_and_follows_the_focus() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size = Vector2(600, 200)
	add_child_autofree(scroll)
	ScrollKit.row(scroll)
	var row: HBoxContainer = HBoxContainer.new()
	scroll.add_child(row)
	for index: int in range(6):
		var tile: Button = Button.new()
		tile.custom_minimum_size = Vector2(200, 120)
		row.add_child(tile)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(scroll.horizontal_scroll_mode, ScrollContainer.SCROLL_MODE_AUTO, "the bar shows whenever the row overflows")
	assert_ne(scroll.vertical_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED, "never DISABLED: that grows the scroll and hides its bar")
	assert_true(scroll.follow_focus, "a controller's left / right brings the focused tile into view")
	assert_gte(scroll.get_h_scroll_bar().custom_minimum_size.y, 16.0, "a bar thick enough to see")
	assert_true(ScrollKit.overflows(scroll), "six tiles do not fit")
	assert_true(scroll.get_h_scroll_bar().visible, "so the bar is drawn")
	assert_eq(scroll.size.y, 200.0, "the scroll keeps its height (the bar stays inside its panel)")
	var wheel: InputEventMouseButton = InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	ScrollKit._on_row_input(wheel, scroll)
	assert_gt(scroll.scroll_horizontal, 0, "wheel down moves the row to the right")
	var moved: int = scroll.scroll_horizontal
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	ScrollKit._on_row_input(wheel, scroll)
	assert_lt(scroll.scroll_horizontal, moved, "wheel up moves it back")
	# the last tile takes the focus: the row follows
	(row.get_child(5) as Button).grab_focus()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_gt(scroll.scroll_horizontal, 300, "the focused tile is scrolled into view")
	for path: String in ["res://ui/town/pack_shop_screen.gd", "res://ui/town/packs_screen.gd", "res://ui/town/wardrobe_screen.gd", "res://ui/town/deckbuilder_screen.gd"]:
		assert_true(FileAccess.get_file_as_string(path).contains("ScrollKit.row("), "%s uses the shop row" % path.get_file())
	assert_false(FileAccess.get_file_as_string("res://ui/town/pack_shop_screen.gd").contains("Vector2(1780.0"), "the pack shop's row no longer asks for a fixed 1780 px")


func _pack_face(pack: PackData) -> Control:
	var art: PackArt = PackArt.create(pack)
	add_child_autofree(art)
	return art._faces[0] if not art._faces.is_empty() else null


func test_pack_medallions_carry_the_canonical_path_icon_inside_the_ring() -> void:
	for path: Affinity.Type in PathIcons.ORDER:
		for pack: PackData in [PackCatalog.gilded_pack(path), PackCatalog.find(PackRules.path_pack_id(path))]:
			assert_not_null(pack, "the %s packs exist" % Affinity.display_name(path))
			if pack == null:
				continue
			assert_false(PackArt.art_id_for(pack).is_empty(), "%s has its painted wrapper" % pack.display_name)
			var face: Control = _pack_face(pack)
			if PackArt.PAINTED_MEDALLIONS.has(PackArt.art_id_for(pack)):
				# Batch 16 (Nov 16): the new painting carries the canonical icon itself; nothing is drawn over it
				assert_null(face.get_node_or_null("PathMedallion"), "%s: its painted medallion shows, no icon over it" % pack.display_name)
				continue
			var medallion: TextureRect = face.get_node_or_null("PathMedallion") as TextureRect
			assert_not_null(medallion, "%s shows its Path's icon" % pack.display_name)
			if medallion == null:
				continue
			assert_eq(medallion.texture, IconArt.texture(PathIcons.icon(path), PackArt.SIZE.x * PackArt.MEDALLION_ICON_SPAN), "%s: the canonical icon (%s)" % [pack.display_name, PathIcons.icon(path)])
			var centre: Vector2 = medallion.position + medallion.size * 0.5
			var wanted: Vector2 = Vector2(PackArt.SIZE.x * PackArt.MEDALLION_CENTER.x, PackArt.SIZE.y * PackArt.MEDALLION_CENTER.y)
			assert_almost_eq(centre.x, wanted.x, 0.6, "centred on the medallion")
			assert_almost_eq(centre.y, wanted.y, 0.6)
			assert_almost_eq(medallion.size.x, medallion.size.y, 0.01, "a whole round icon, not a cut-out stretched")
			assert_lte(medallion.size.x * 0.5, PackArt.SIZE.x * 0.25, "inside the gold ring (its inner edge is a quarter of the width out)")
			assert_null(medallion.material, "no circular crop over it (the old cut-out lost its bottom)")
			assert_eq(medallion.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	# the Necrocrat's is the skull in ghost-flame (ICON-ENERGY-N), on both of its packs
	assert_eq(PathIcons.icon(Affinity.Type.NECROCRAT), "ICON-ENERGY-N")
	# packs of no Path keep their own painted centre
	for id: String in ["general_1", "general_2", "prismatic"]:
		var pack: PackData = PackCatalog.find(id)
		if pack == null or PackArt.art_id_for(pack).is_empty():
			continue
		assert_null(_pack_face(pack).get_node_or_null("PathMedallion"), "%s has no Path icon" % id)


func test_the_gilded_wrapper_per_path_is_asked_for_and_wired() -> void:
	var gilded: PackData = PackCatalog.gilded_pack(Affinity.Type.NECROCRAT)
	assert_not_null(gilded)
	var id: String = PackArt.art_id_for(gilded)
	assert_true(id == "UI-PACK-GILDED" or id == "UI-PACK-GILDED-N", "the shared wrapper until the Necrocrat's own is painted, then its own (%s)" % id)
	assert_eq(str(PackArt.GILDED_PACK_IDS[Affinity.Type.NECROCRAT]), "UI-PACK-GILDED-N")
	var sheet: String = FileAccess.get_file_as_string("res://docs/art/batch16_nov14.csv")
	for wanted: String in ["UI-PACK-GILDED-N", "UI-PACK-N (redo)", "UI-PACK-R (redo)"]:
		assert_true(sheet.contains(wanted), "Batch 16 lists %s" % wanted)
