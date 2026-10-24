class_name OpeningForestSmoke
extends Node
## Opening Forest rebuild, Part E (docs/art/opening_forest.md): human-input e2e of the rebuilt opening. Title -> New Game -> the wake-up still and lines
## -> the hooded figure beside the camp talks, the Path choice (Beefcake) -> the figure leaves -> the hero walks with held WASD keys from the camp up the
## worn path to the cave mouth (no teleport: a stall fails the run) -> "Enter the cave" -> the Forgotten Cave -> back out at the cave mouth where Elder
## Maren waits -> Crosspath. Saves are off for the whole run (the player's slots are never touched).
## Run windowed:  bash tools/run_opening_forest_smoke.sh   (exit code 0 = every check passed)

const TIME_LIMIT_SECONDS: float = 60.0
const WALK_LIMIT_SECONDS: float = 25.0

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}


func run() -> void:
	Session.save_enabled = false
	driver = UiDriver.new(get_tree())
	await driver.seconds(1.2)
	# the title: New Game (and "Start Over" when the player has saves; with saving off nothing is replaced)
	_check(await driver.click_button("New Game"), "the title offers New Game")
	await driver.seconds(0.6)
	# Oct 23: the campaign slot picker (with saving off, "Start Over" deletes nothing).
	if driver.find_button("Start here") != null:
		await driver.click_button("Start here")
	elif driver.find_button("Start over here") != null:
		await driver.click_button("Start over here")
		await driver.seconds(0.5)
	if driver.find_button("Start Over") != null:
		await driver.click_button("Start Over")
	var scene: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if scene == null:
		_finish(false, "the Opening Forest never loaded")
		return
	_check(scene.area.layout != null and scene.area.models != null, "the Opening Forest is built from its layout")
	_check(scene.atmosphere != null and scene.atmosphere.lantern_light != null, "the camp lantern is lit")
	_check(scene.frame != null, "silhouette leaves frame the screen")
	var spawn: Vector3 = scene.area.anchors["spawn"] as Vector3
	_check(Vector2(scene.player.position.x - spawn.x, scene.player.position.z - spawn.z).length() < 0.5, "the hero wakes up at the camp")
	# the wake-up still, the lines, then the hooded figure's conversation up to the Path choice
	var guard: int = 0
	while _find_element_choice(scene) == null and guard < 80:
		guard += 1
		if get_tree().root.find_child("StoryStill", true, false) != null:
			await driver.click(Vector2(800, 450))
		if scene.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.2)
	_check(scene._rescuer != null, "the hooded figure is there")
	if scene._rescuer != null:
		var bed: Vector3 = scene.area.layout.mark("bedroll")
		_check(Vector2(scene._rescuer.position.x - bed.x, scene._rescuer.position.z - bed.z).length() < 2.5, "the hooded figure stands beside the camp")
	var choice: ElementChoiceScreen = _find_element_choice(scene)
	if choice == null:
		_finish(false, "the Path choice never appeared in the conversation")
		return
	await driver.click(driver.center_of_control(choice._tiles[Affinity.Type.BEEFCAKE] as Button))
	await driver.click_button("Begin")
	await driver.seconds(0.5)
	_check(Session.has_profile() and Session.profile.primary_affinity == Affinity.Type.BEEFCAKE, "talking to the hooded figure sets the starting Path")
	guard = 0
	while (scene.dialogue.active or scene._rescuer != null or scene._locked) and guard < 80:
		guard += 1
		if scene.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.25)
	_check(scene._rescuer == null and not scene._locked, "the figure leaves and the hero is free to walk")
	# walk the worn path with held keys, waypoint by waypoint, to the gate
	var route: Array[Vector3] = []
	for p: Vector2 in OpeningForestLayout.PATH:
		route.append(Vector3(p.x, 0.0, p.y))
	var gate: Vector3 = scene.area.anchors["gate"] as Vector3
	route.append(gate + Vector3(0.0, 0.0, 0.3))
	var started: float = Time.get_ticks_msec() / 1000.0
	var walked: bool = true
	for index: int in range(route.size()):
		var reach: float = 0.5 if index == route.size() - 1 else 1.4
		if not await _walk_to(scene, route[index], reach):
			walked = false
			_check(false, "the hero walks to path point %d %s (stuck at %s)" % [index, str(route[index]), str(scene.player.position)])
			break
	await _release_all()
	var walk_time: float = Time.get_ticks_msec() / 1000.0 - started
	_check(walked, "the hero walks from the camp up the path to the cave mouth with the keys (%.1f s)" % walk_time)
	await driver.seconds(0.3)
	_check(scene._prompt_panel.visible and scene._prompt_label.text.contains("cave"), "at the mouth the prompt offers the cave")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(await driver.click_button("Enter"), "the gate asks to enter the Forgotten Cave")
	await driver.seconds(1.0)
	_check(Session.in_dungeon() and Session.dungeon_map != null and Session.dungeon_map.dungeon_name == "The Forgotten Cave", "the cave mouth leads on into the Forgotten Cave (node-based)")
	# out through the cave: back at the mouth, Maren waits, then Crosspath
	while SceneManager.busy:
		await driver.frames(5)
	Session.complete_trial()
	Session.cave_exit_pending = true
	SceneManager.go_to_start_area()
	await driver.seconds(0.5)
	var exit_scene: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if exit_scene == null:
		_finish(false, "the cave mouth scene never loaded")
		return
	await driver.seconds(0.8)
	_check(exit_scene._maren != null, "Elder Maren waits at the cave mouth")
	var mouth_gate: Vector3 = exit_scene.area.anchors["gate"] as Vector3
	_check(exit_scene.area.is_walkable(exit_scene.player.position), "the hero comes out of the cave on open ground")
	_check(Vector2(exit_scene.player.position.x - mouth_gate.x, exit_scene.player.position.z - mouth_gate.z).length() < 1.0, "at the mouth")
	guard = 0
	while get_tree().current_scene is StartingAreaScene and guard < 60:
		guard += 1
		if exit_scene.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.25)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "after Maren the hero arrives in Crosspath")
	_finish(_failures.is_empty(), "opening forest: New Game, wake-up, the hooded figure, the walk up the path, the cave, out at the mouth, Crosspath")


# ---- walking ---------------------------------------------------------------------------------------------------------------------------------


## Holds the keys toward `target` (diagonals allowed) until within `reach`; dismisses any self-talk on the way. False on a stall.
func _walk_to(scene: StartingAreaScene, target: Vector3, reach: float) -> bool:
	var elapsed: float = 0.0
	var last: Vector3 = scene.player.position
	var still: float = 0.0
	while elapsed < WALK_LIMIT_SECONDS:
		if scene.dialogue.active:
			await _release_all()
			await driver.tap_key(KEY_E)
			await driver.seconds(0.2)
			continue
		var offset: Vector3 = target - scene.player.position
		offset.y = 0.0
		if offset.length() < reach:
			return true
		var dir: Vector3 = offset.normalized()
		await _hold(KEY_W, dir.z < -0.38)
		await _hold(KEY_S, dir.z > 0.38)
		await _hold(KEY_A, dir.x < -0.38)
		await _hold(KEY_D, dir.x > 0.38)
		await driver.frames(3)
		elapsed += 3.0 / 60.0
		if scene.player.position.distance_to(last) < 0.01:
			still += 3.0 / 60.0
			if still > 2.0:
				return false
		else:
			still = 0.0
		last = scene.player.position
	return false


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _release_all() -> void:
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)


# ---- helpers ---------------------------------------------------------------------------------------------------------------------------------


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
		print("opening_forest_smoke: ok    ", message)
	else:
		_failures.append(message)
		print("opening_forest_smoke: FAIL  ", message)
		push_error("opening_forest_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("opening_forest_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
