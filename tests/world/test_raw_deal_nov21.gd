extends GutTest
## Fable Nov 21 (Part 7.1 and Part 8): the Buffet's sushi side dungeon is "The Raw Deal", entered through a walk-in freezer, and stands
## in the east district behind Colonel Casserole's gate (he must be beaten to reach it). Maren's staff line and the castle-gate scene.

var _layout: BuffetLayout
var _builder: BuffetBuilder


func before_all() -> void:
	var root: Node3D = Node3D.new()
	add_child(root)
	_builder = BuffetBuilder.new()
	_builder.build(root)
	_layout = _builder.layout


func after_all() -> void:
	for child: Node in get_children():
		child.queue_free()


func test_the_name_is_the_raw_deal_everywhere_it_is_shown() -> void:
	assert_eq(DungeonCatalog.find("S-GOUR").dungeon_name, "The Raw Deal")
	assert_string_contains(ZoneQuestDefinitions.sealed_message("S-GOUR"), "The Raw Deal")
	assert_string_contains(str((ZoneQuestDefinitions.WAY_IN["S-GOUR"] as Array)[5]), "behind Colonel Casserole's gate")
	assert_eq(Session.content.card("G-27").availability_source if Session.content != null else CardSet.card("G-27").availability_source, "The Raw Deal (the Itamae Supreme)")
	assert_string_contains(" ".join(DungeonCatalog.text_lines("quest.side_s_gour.done")), "Raw Deal")
	for path: String in ["res://data/feats/feats.json", "res://data/dungeons/dungeons.json", "res://core/zone/buffet_zone.gd", "res://core/quests/zone_quest_definitions.gd"]:
		assert_false(FileAccess.get_file_as_string(path).contains("Omakase"), "%s still says Omakase" % path)
	assert_string_contains(FileAccess.get_file_as_string("res://data/story/gourmand_story.tres"), "THE RAW DEAL")
	assert_string_contains(FileAccess.get_file_as_string("res://data/story/gourmand_story.tres"), "Enter through the walk-in freezer", "it is still entered through a walk-in freezer")


func test_the_entrance_is_on_the_east_side_behind_the_colonel() -> void:
	var door: Vector3 = _layout.anchors["mini_dungeon"] as Vector3
	var gate: Vector3 = _layout.gate_positions["battle"] as Vector3
	assert_gt(door.x, 64.5, "east of the divider (x 64): the Pancake Plateau's district")
	assert_lt(door.z, BuffetLayout.FENCE_Z, "north of the fork fence")
	assert_almost_eq(gate.x, 78.0, 0.01, "Colonel Casserole's gate is that district's gate")
	assert_gt(absf(door.x - (_layout.anchors["main_dungeon"] as Vector3).x), 8.0, "no longer next to the main dungeon")
	# Batch 18 (Nov 20): the way in stands at the painted freezer door, left of the front's middle (it was 4.5 m west of the pavilion's centre)
	assert_almost_eq(door.x, BuffetLayout.RAWDEAL_DOOR.x, 0.01, "the way in is the painted freezer door")
	assert_between(BuffetLayout.OMAKASE_PAVILION.x - door.x, 1.0, BuffetLayout.OMAKASE_PAVILION_SIZE.x * 0.5, "at the left of the building's base")


func test_it_can_only_be_reached_through_his_gate() -> void:
	var door: Vector3 = (_layout.anchors["mini_dungeon"] as Vector3) + Vector3(0.0, 0.0, 1.6)
	var spawn: Vector3 = _layout.anchors["hub"] as Vector3
	var north_side: Vector3 = Vector3(78.0, 0.0, BuffetLayout.FENCE_Z - 3.0)
	var middle: Vector3 = Vector3(50.0, 0.0, BuffetLayout.FENCE_Z - 6.0)
	var walk: Callable = func(at: Vector3) -> bool: return _builder.is_walkable(at, 0.3)
	assert_true(_builder.is_walkable(door, 0.3), "the hero can stand at the freezer door")
	var from_gate: PackedVector3Array = WalkPlanner.route(walk, _builder.map_bounds(), north_side, door, 0.5, 1.0)
	assert_gt(from_gate.size(), 1, "from just inside Colonel Casserole's gate the door can be walked to")
	var from_middle: PackedVector3Array = WalkPlanner.route(walk, _builder.map_bounds(), middle, door, 0.5, 1.0)
	assert_eq(from_middle.size(), 0, "from the middle district (the Test Kitchen's) there is no way through: the divider seals it")
	assert_eq(BossBlockers.flag_for("gourmand", "gate_casserole"), BuffetZone.FLAG_GATE_BATTLE, "and his gate opens only when he is beaten")


func test_marens_staff_line() -> void:
	var text: String = FileAccess.get_file_as_string("res://data/story/intro_story.tres")
	assert_string_contains(text, "this staff of mine. I have leaned on it for as long as I can remember")
	assert_false(text.contains("never told a soul why"))
	assert_false(text.contains("stick of mine"))


func test_the_castle_gate_scene_follows_the_brief() -> void:
	var scenes: Dictionary = (JSON.parse_string(FileAccess.get_file_as_string("res://data/story/story_scenes.json")) as Dictionary)["scenes"] as Dictionary
	var steps: Array = (scenes["pc_capture"] as Dictionary)["steps"] as Array
	var speakers: Array[String] = []
	for step: Variant in steps:
		speakers.append(str((step as Array)[0]))
	var elowen_lines: int = speakers.count("NPC-ELOWEN")
	assert_eq(elowen_lines, 1, "she speaks once: the shout")
	var text: String = JSON.stringify(steps)
	assert_string_contains(text, "The charges:", "Plume reads out her name and the charges")
	assert_string_contains(text, "{rescuer_full}")
	assert_lt(speakers.find("@set"), speakers.find("NPC-ELOWEN"), "her name is known from Plume before she shouts")
	assert_gt(speakers.find("@set"), speakers.find("NPC-PLUME"), "and only once he has read it")
	var shout: String = str((steps[speakers.find("NPC-ELOWEN")] as Array)[1])
	assert_string_contains(shout, "Don't follow me")
	assert_string_contains(shout, "Stop {villain}")
	assert_false(text.contains("I promised"), "she never gets to speak to him")
	assert_false(text.contains("Don't look so surprised"))
	assert_eq(speakers.back(), "NPC-PLAYER", "he closes the scene")
	assert_string_contains(str((steps.back() as Array)[1]), "keep out of sight", "he understands he must hide and go up")
	assert_string_contains(text, "before you are halfway there", "she is taken before he reaches her")
	assert_true(StoryScenes.flags_set("pc_capture").has("rescuer_named"))
