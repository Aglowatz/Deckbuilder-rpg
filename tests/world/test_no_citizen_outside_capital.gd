extends GutTest
## Playtest v0.4.0 Part B: the blonde white-suit CITIZEN sprite is Primm's perfect citizen and only ever walks the Capital. Crosspath's
## strollers and every other zone's people use VILLAGER or their own sets.

const SCENE_SCRIPTS: Array[String] = [
	"res://world/town_scene.gd", "res://world/starting_area_scene.gd", "res://world/zone/zone_scene.gd",
	"res://world/zone/gainlands_scene.gd", "res://world/zone/dna_scene.gd", "res://world/zone/buffet_scene.gd", "res://world/zone/heap_scene.gd",
]


func test_no_zone_but_the_capital_places_a_citizen_npc() -> void:
	for zone_id: String in ZoneDefs.all_ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		if def == null:
			continue
		for entry: Dictionary in def.npcs:
			var uses_citizen: bool = str(entry.get("npc_id", "")) == "NPC-CITIZEN" or str(entry.get("sprite", "")) == "CITIZEN"
			if zone_id == CapitalZone.ID:
				continue
			assert_false(uses_citizen, "%s places a CITIZEN (%s)" % [zone_id, str(entry.get("id", ""))])
	var capital: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	var citizens: int = 0
	for entry: Dictionary in capital.npcs:
		if str(entry.get("npc_id", "")) == "NPC-CITIZEN":
			citizens += 1
	assert_gt(citizens, 0, "the Capital keeps its facade citizens")


func test_no_scene_script_outside_the_capital_spawns_the_citizen_sprite() -> void:
	for path: String in SCENE_SCRIPTS:
		if not ResourceLoader.exists(path):
			continue
		var source: String = FileAccess.get_file_as_string(path)
		for line: String in source.split("\n"):
			var code: String = line.strip_edges()
			if code.begins_with("#") or code.begins_with("##"):
				continue
			assert_false(code.contains("\"CITIZEN\""), "%s spawns the CITIZEN sprite: %s" % [path, code])
	assert_true(SpriteLibrary.has_character("VILLAGER"), "the villager set exists for the strollers")
	assert_false((SpriteLibrary.info("VILLAGER").get("walk_dirs", []) as Array).is_empty(), "and it can walk")


func test_the_crosspath_strollers_are_villagers() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/town_scene.gd")
	assert_true(source.contains("stroller.character = \"VILLAGER\""), "the town's strollers wear the villager set")
