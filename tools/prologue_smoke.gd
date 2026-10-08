class_name PrologueSmoke
extends Node
## Story v2 Part C: human-input e2e of the new opening. New game -> choose a look -> wake up -> the Rescuer's conversation with the starting deck choice
## (Gourmand) -> the Rescuer fades -> walking into the treeline makes the Wanderer talk themselves back -> the cave gate walks straight into the Forgotten Cave
## (no second element choice) -> the Warden's dialogue -> clearing the cave -> Elder Maren waits at the cave mouth -> Crosspath.
## Run windowed:  bash tools/run_prologue_smoke.sh   (exit code 0 = every check passed)

const TIME_LIMIT_SECONDS: float = 60.0

var driver: UiDriver
var _failures: PackedStringArray = []


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var scene: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if scene == null:
		_finish(false, "starting area never loaded")
		return
	await driver.seconds(0.5)
	_check(await driver.click_button("Start my adventure"), "the starting look screen appears first and can be confirmed")
	await driver.seconds(0.4)
	# The wake-up lines, then the Rescuer.
	var guard: int = 0
	while _find_element_choice(scene) == null and guard < 60:
		guard += 1
		if scene.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.2)
	_check(scene._rescuer != null, "a hooded Rescuer kneels beside the Wanderer")
	_check(_find_element_choice(scene) != null, "the starting deck choice is asked inside the Rescuer's conversation")
	_check(Session.profile == null, "no profile exists before the choice")
	var choice: ElementChoiceScreen = _find_element_choice(scene)
	if choice == null:
		_finish(false, "the Path choice never appeared")
		return
	var tile: Button = choice._tiles[Affinity.Type.GOURMAND] as Button
	await driver.click(driver.center_of_control(tile))
	await driver.click_button("Begin")
	await driver.seconds(0.5)
	_check(Session.has_profile() and Session.profile.primary_affinity == Affinity.Type.GOURMAND, "choosing a Path sets the primary Path")
	_check(Session.deck != null and Session.deck.size() == 42, "the 42-card starter deck exists (got %d)" % (Session.deck.size() if Session.deck != null else -1))
	_check(Session.flag(&"rescuer_met"), "the rescuer_met flag is set")
	guard = 0
	while (scene.dialogue.active or scene._rescuer != null or scene._locked) and guard < 80:
		guard += 1
		if scene.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.25)
	_check(scene._rescuer == null, "the Rescuer fades out and is gone")
	_check(not scene._locked, "the hero is free to move afterwards")

	# Walk into the treeline: the Wanderer talks themselves back.
	scene.player.position = _find_edge_spot(scene)
	await driver.seconds(0.6)
	_check(scene.dialogue.active, "standing at the treeline makes the Wanderer talk to themselves")
	_check(scene.dialogue.npc_id == NpcRegistry.PLAYER_ID, "the self-talk is the Wanderer's own line")
	await _dismiss(scene)

	# The cave gate goes straight into the dungeon (no second choice).
	var gate: Vector3 = scene.area.anchors.get("gate", Vector3.ZERO) as Vector3
	scene.player.position = gate + Vector3(0.0, 0.0, 0.2)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(await driver.click_button("Enter"), "the gate asks to enter the Forgotten Cave")
	await driver.seconds(1.0)
	_check(Session.in_dungeon(), "the gate walks straight into the Forgotten Cave with no second Path choice")
	var map: DungeonMap = Session.dungeon_map
	_check(map != null and map.dungeon_name == "The Forgotten Cave", "the dungeon is called The Forgotten Cave")
	# The cave has no Beefcake or Necrocrat infrastructure on the enemy side.
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BATTLE or node.kind == DungeonMap.Kind.BOSS:
			for id: String in TrialOfTheHollow.enemy_recipe(node.enemy_name).keys():
				_check(id != "BAS-B" and id != "BAS-N", "%s has no Beefcake/Necrocrat infrastructure (%s)" % [node.enemy_name, id])

	# Clear the cave and step out: Elder Maren is waiting.
	Session.complete_trial()
	Session.cave_exit_pending = true
	SceneManager.go_to_start_area()
	await driver.seconds(0.5)
	var exit_scene: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if exit_scene == null:
		_finish(false, "cave mouth scene never loaded")
		return
	await driver.seconds(0.8)
	_check(exit_scene._maren != null, "Elder Maren is waiting at the cave mouth")
	guard = 0
	while get_tree().current_scene is StartingAreaScene and guard < 60:
		guard += 1
		if exit_scene.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.25)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "after Maren's welcome the player arrives in Crosspath")
	_check(Session.flag(&"maren_met"), "the maren_met flag is set")
	_finish(_failures.is_empty(), "prologue: forest, Rescuer, deck choice, self-talk, the Forgotten Cave, Maren at the cave mouth, Crosspath")


# ---- Helpers ----------------------------------------------------------------------------


func _dismiss(scene: StartingAreaScene) -> void:
	var guard: int = 0
	while scene.dialogue.active and guard < 20:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


## A walkable point within the probe distance of the treeline, away from the secrets.
func _find_edge_spot(scene: StartingAreaScene) -> Vector3:
	var bounds: Rect2 = scene.area.map_bounds()
	var x: float = bounds.position.x
	while x < bounds.end.x:
		var z: float = bounds.position.y
		while z < bounds.end.y:
			var spot: Vector3 = Vector3(x, 0.0, z)
			if scene.area.is_walkable(spot):
				var near_secret: bool = false
				for key: String in scene.area.anchors.keys():
					if key.begins_with("hidden_chest_") or key == "tunnel":
						var secret: Vector3 = scene.area.anchors[key] as Vector3
						if Vector2(x - secret.x, z - secret.z).length() < 2.6:
							near_secret = true
				if not near_secret:
					for step: int in range(8):
						var angle: float = TAU * float(step) / 8.0
						if not scene.area.is_floor_at(spot + Vector3(cos(angle), 0.0, sin(angle)) * (StartingAreaScene.EDGE_PROBE - 0.05)):
							return spot
			z += 0.25
		x += 0.25
	return Vector3.ZERO


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < TIME_LIMIT_SECONDS:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _find_element_choice(scene: StartingAreaScene) -> ElementChoiceScreen:
	for child: Node in scene._overlay_layer.get_children():
		if child is ElementChoiceScreen:
			return child as ElementChoiceScreen
	return null


func _check(condition: bool, message: String) -> void:
	if condition:
		print("prologue_smoke: ok    ", message)
	else:
		_failures.append(message)
		print("prologue_smoke: FAIL  ", message)
		push_error("prologue_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("prologue_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
