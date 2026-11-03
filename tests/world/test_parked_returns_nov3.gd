extends GutTest
## Overnight Nov 2-3, Part 3 (docs/perf/loading_nov3.md): the arena and the graveyard park the town like a roamer fight (back in about a second
## instead of a 4-5 s rebuild); the resume hook shows their results as a fresh build would. A parked scene leaves the tree and comes back, so
## what a node frees on leaving the tree must survive that (the dialogue's portraits) and what it wires on entering must not be wired twice
## (the UI sounds).


func _town() -> TownScene:
	Session.save_enabled = false
	Session.ensure_game()
	var scene: TownScene = (load("res://scenes/town.tscn") as PackedScene).instantiate() as TownScene
	add_child_autofree(scene)
	return scene


## Takes the scene out of the tree and puts it back, as SceneManager parks and resumes it around a battle.
func _park_and_return(scene: Node) -> void:
	var parent: Node = scene.get_parent()
	parent.remove_child(scene)
	await get_tree().process_frame
	parent.add_child(scene)
	await get_tree().process_frame


## The headless test renderer has no textures ("Parameter \"t\" is null" when a screen asks for one) and a freed town's art warm-up
## coroutine wakes after it is gone: environment noise, not what these tests check - every other error still fails them.
func _accept_noise() -> void:
	for error: Variant in get_errors():
		var text: String = str(error.get("code")) + " " + str(error.get("rationale"))
		if text.contains("texture_2d_get") or text.contains("Parameter \"t\" is null") or text.contains("ui_art_warmup"):
			error.set("handled", true)


func test_which_fights_park_the_town() -> void:
	var arena: BattleContext = BattleContext.new()
	arena.arena_id = "a1"
	assert_true(Session.parks_town_scene(arena), "the arena")
	var graveyard: BattleContext = BattleContext.new()
	graveyard.is_graveyard_boss = true
	assert_true(Session.parks_town_scene(graveyard), "the graveyard")
	var npc: BattleContext = BattleContext.new()
	npc.town_npc_id = "beefcake"
	assert_false(Session.parks_town_scene(npc), "a corrupted NPC's duel changes the town: it rebuilds")
	var dungeon: BattleContext = BattleContext.new()
	dungeon.node_id = 3
	assert_false(Session.parks_town_scene(dungeon), "a dungeon fight goes on to the rewards scene")
	_accept_noise()


func test_back_from_the_arena_the_list_reopens_with_the_result() -> void:
	var town: TownScene = _town()
	await get_tree().process_frame
	await _park_and_return(town)
	Session.pending_arena_result = {"won": true, "encounter": "test", "gold": 10}
	town.resume_after_battle()
	for frame: int in range(4):
		await get_tree().process_frame
	assert_true(town._overlay is ArenaScreen, "the arena list is open again, with the result")
	assert_true(Session.pending_arena_result.is_empty(), "the result is shown once")
	assert_almost_eq(town._battle_push, 1.0, 0.001, "the camera is back at its normal distance")
	_accept_noise()


func test_back_from_the_graveyard_the_cairn_speaks_with_its_portrait_box() -> void:
	var town: TownScene = _town()
	await get_tree().process_frame
	town._battle_push = 0.55  # the push-in before the fight
	await _park_and_return(town)
	Session.pending_graveyard_result = {"won": false, "first_win": false}
	town.resume_after_battle()
	for frame: int in range(4):
		await get_tree().process_frame
	assert_true(town.dialogue.active, "the Restless Cairn's after-lines play")
	assert_almost_eq(town._battle_push, 1.0, 0.001, "the push-in is undone")
	var portrait: Variant = town.dialogue.get("_portrait")
	assert_true(is_instance_valid(portrait), "the dialogue's portrait view survived the park")
	_accept_noise()


func test_a_dialogue_after_a_park_shows_a_portrait() -> void:
	var town: TownScene = _town()
	await get_tree().process_frame
	await _park_and_return(town)
	town.dialogue.start("Elder Maren", ["Back already?"] as Array[String], "NPC-ELDER")
	await get_tree().process_frame
	var portrait: PortraitView = town.dialogue.get("_portrait") as PortraitView
	assert_true(is_instance_valid(portrait))
	assert_true(portrait.shown, "Maren's portrait shows (it was freed with the park before the fix)")
	_accept_noise()


func test_ui_sounds_wire_a_control_once() -> void:
	var holder: Control = Control.new()
	add_child_autofree(holder)
	var button: Button = Button.new()
	holder.add_child(button)
	var wired: int = button.mouse_entered.get_connections().size()
	holder.remove_child(button)
	holder.add_child(button)
	assert_eq(button.mouse_entered.get_connections().size(), wired, "re-entering the tree does not wire the hover sound twice")
	_accept_noise()
