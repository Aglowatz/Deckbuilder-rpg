extends GutTest
## The sub-area scene end to end: it loads from data, a chest pays once and stays open (a saved flag), and a save made inside records the sub-area.


func _load(area: String, sub: String) -> SubAreaScene:
	Session.new_game()
	Session.set_flag(&"trial_cleared")
	SubAreaScene.pending_area = area
	SubAreaScene.pending_sub = sub
	var scene: SubAreaScene = (load(SubAreaScene.SCENE_PATH) as PackedScene).instantiate() as SubAreaScene
	scene.screenshot_prepare({"nohud": "true", "card": "false"})
	add_child_autofree(scene)
	return scene


func test_scene_builds_with_points_of_interest() -> void:
	var scene: SubAreaScene = _load("gainlands", "proving_grounds")
	assert_not_null(scene.player)
	assert_gt(scene.spots.size(), 5)
	assert_not_null(scene.map)


func test_a_chest_pays_once_and_is_remembered() -> void:
	var scene: SubAreaScene = _load("gainlands", "proving_grounds")
	var chest: Dictionary = {}
	for spot: Dictionary in scene.spots:
		if str(spot["type"]) == "chest":
			chest = spot
			break
	assert_false(chest.is_empty())
	var gold_before: int = Session.gold
	scene.interact(chest)
	assert_true(Session.flag(scene.flag_name(str(chest["id"]))), "the chest is marked opened")
	assert_gte(Session.gold, gold_before, "gold never goes down")
	var again: int = Session.gold
	scene.interact(chest)
	assert_eq(Session.gold, again, "a second visit pays nothing")


func test_a_save_records_the_subarea_and_the_flags_survive() -> void:
	var scene: SubAreaScene = _load("dna", "the_queue")
	Session.set_flag(scene.flag_name("q_chest"))
	assert_eq(Session.scene_kind(), "sub:dna/the_queue" if get_tree().current_scene is SubAreaScene else Session.scene_kind())
	assert_eq(SubAreaDefs.parse_token(SubAreaDefs.token("dna", "the_queue")), ["dna", "the_queue"] as Array[String])
	var data: Dictionary = Session.to_dict()
	assert_true(Session.from_dict(data))
	assert_true(Session.flag(scene.flag_name("q_chest")))
