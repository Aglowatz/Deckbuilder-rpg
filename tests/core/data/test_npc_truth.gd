extends GutTest
## Overnight Oct 17, Part 11: data/npcs/npcs.json is the one NPC source of truth (tools/npc_truth.js): every NPC has the agreed fields,
## the game reads them (NpcRegistry), passing barks come from it (NpcBarks), and docs/design/npc_registry.csv follows the sheet.


func _rows() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string(NpcRegistry.NPC_PATH)) as Array


func test_every_npc_has_the_source_of_truth_fields() -> void:
	for row: Variant in _rows():
		var data: Dictionary = row as Dictionary
		for key: String in ["id", "name", "location", "role", "species_type", "description", "personality", "speech_style", "sample_line", "barks", "quest_links", "vendor_links", "portrait_status", "world_sprite_status", "art_check"]:
			assert_true(data.has(key), "%s has %s" % [data.get("id", "?"), key])
		assert_true(str(data["art_check"]) in ["OK", "missing", "mismatch"], str(data["id"]))


func test_species_are_set_and_mixed() -> void:
	var humans: int = 0
	var animals: int = 0
	for row: Variant in _rows():
		var species: String = str((row as Dictionary)["species_type"])
		assert_false(species.is_empty(), "%s has a species" % (row as Dictionary)["id"])
		if species.begins_with("Human"):
			humans += 1
		elif species.begins_with("Animal"):
			animals += 1
	assert_lt(absi(humans - animals), 8, "roughly as many humans as humanoid animals (%d / %d)" % [humans, animals])


func test_the_game_reads_barks_and_descriptions_from_it() -> void:
	NpcRegistry.reset()
	var sable: NpcRegistry.Entry = NpcRegistry.find("V-SABLE")
	assert_false(sable.description.is_empty())
	assert_false(NpcRegistry.barks("V-SABLE").is_empty())
	assert_false(NpcRegistry.barks("NPC-VILLAGER").is_empty(), "the strolling baker has lines too")
	assert_eq(sable.sample_line, NpcRegistry.barks("V-SABLE")[0])


func test_barks_are_short() -> void:
	for row: Variant in _rows():
		for line: Variant in (row as Dictionary)["barks"] as Array:
			assert_lt(str(line).length(), 90, str(line))


func test_the_registry_csv_follows_the_sheet_columns() -> void:
	var text: String = FileAccess.get_file_as_string("res://docs/design/npc_registry.csv")
	assert_true(text.begins_with("NPC ID,Name,Role / Type,Location,Personality & Interesting Traits,Voice & Speech Style,Game Function,Portrait Image ID"), text.substr(0, 120))
	assert_true(text.contains("Art Check"))


func test_barks_show_one_line_when_the_hero_walks_up() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0, 8, 10)
	root.add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.make_current()
	var npc: Node3D = Node3D.new()
	root.add_child(npc)
	var hero: Node3D = Node3D.new()
	hero.position = Vector3(20, 0, 0)
	root.add_child(hero)
	var barks: NpcBarks = NpcBarks.new()
	root.add_child(barks)
	barks.target = hero
	barks.register(npc, "V-SABLE")
	barks._global = 0.0
	barks._entries[0]["cooldown"] = 0.0
	await wait_process_frames(2)
	assert_eq(barks.current_line(), "", "quiet while the hero is far")
	hero.position = Vector3(1, 0, 0)
	await wait_process_frames(2)
	assert_true(NpcRegistry.barks("V-SABLE").has(barks.current_line()), "a line from the NPC's barks")
