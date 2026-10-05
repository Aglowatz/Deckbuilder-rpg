class_name ThirteenthBriefSmoke
extends Node
## Brief 13 e2e with human-style input: the five zone passageways in the main town. For each: walk up (the sign label appears), walk into the SEALED passage (the hero is
## stopped, still in town), unlock it, walk in again (the right zone scene loads, then back to town). Also checks the wheel zoom and the single Menu button.
## Shortcuts: the town starts from `Session.ensure_game()`, unlocking sets the corrupted-guardian flag directly, the walk teleports next to the passage if it cannot reach it in time.
## Screenshots: _screenshots/brief13/.   Godot --path . res://tools/thirteenth_brief_final_launcher.tscn

const SHOT_DIR: String = "res://_screenshots/brief13/"
const TAG: String = "thirteenth_smoke"
const ZONES: Array[Dictionary] = [
	{"id": "beefcake", "scene": "GainlandsScene"}, {"id": "necrocrat", "scene": "DnaScene"}, {"id": "gourmand", "scene": "BuffetScene"},
	{"id": "refusemancer", "scene": "HeapScene"}, {"id": "final", "scene": "CapitalScene"},
]

var driver: UiDriver
var _failures: PackedStringArray = []
var _held: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for_town()
	if town == null:
		_finish(false, "town never loaded")
		return
	await _flow_hud_and_zoom(town)
	var only: String = OS.get_environment("SMOKE_ONLY")
	for zone: Dictionary in ZONES:
		if only != "" and only != str(zone["id"]):
			continue
		town = await _flow_passage(town, str(zone["id"]), str(zone["scene"]))
		if town == null:
			_finish(false, "could not get back to town")
			return
	_finish(_failures.is_empty(), "five passageways: sign, sealed block, unlock, walk in, zone loads; Menu button and zoom (%d screenshots)" % _shots)


func _wheel(direction: int) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_WHEEL_UP if direction < 0 else MOUSE_BUTTON_WHEEL_DOWN
	event.pressed = true
	event.position = Vector2(960, 540)
	Input.parse_input_event(event)
	await driver.frames(1)


func _flow_hud_and_zoom(town: TownScene) -> void:
	var before: float = Settings.camera_zoom
	for i: int in range(3):
		await _wheel(1)
	await driver.seconds(0.3)
	_check(Settings.camera_zoom > before, "the mouse wheel zooms out (%.1f -> %.1f)" % [before, Settings.camera_zoom])
	for i: int in range(40):
		await _wheel(-1)
	_check(is_equal_approx(Settings.camera_zoom, Settings.ZOOM_MIN), "and stops at the minimum")
	for i: int in range(40):
		await _wheel(1)
	_check(is_equal_approx(Settings.camera_zoom, Settings.ZOOM_MAX), "and at the maximum")
	Settings.camera_zoom = before
	await driver.seconds(0.4)
	_check(town.hud.find_child("MenuButton", true, false) != null, "the single Menu button exists")
	_check(Session.quest_log.tracked_id() != "", "one quest is tracked (the most recent by default)")


func _flow_passage(town: TownScene, zone_id: String, scene_class: String) -> TownScene:
	var info: ZonePortals.Info = ZonePortals.find(zone_id)
	var flag: StringName = CorruptedNpcs.unlock_flag(zone_id)
	var locked: bool = zone_id != ZonePortals.FINAL_ID
	if locked:
		Session.flags.erase(str(flag))
		town.get_tree().reload_current_scene()
		await driver.frames(10)
		town = await _wait_for_town()
		if town == null:
			return null
	var entry: Vector3 = town.town.anchors["portal_%s" % zone_id] as Vector3
	var mouth: Vector3 = town.town.anchors["portal_%s_mouth" % zone_id] as Vector3
	await _walk_to(town, entry, 1.2)
	await driver.seconds(0.5)
	var spot: TownScene.Spot = null
	for candidate: TownScene.Spot in town.spots:
		if candidate.id == "portal_%s" % zone_id:
			spot = candidate
	_check(spot != null and spot.plate.visible and spot.plate.modulate.a > 0.5, "%s: the zone name shows on approach (%s)" % [zone_id, info.display_name])
	await _shot("g_passage_%s_approach" % zone_id)
	if locked:
		await _walk_to(town, mouth, 0.6)
		await driver.seconds(0.8)
		_check(get_tree().current_scene == town, "%s: the sealed passage keeps the hero in town" % zone_id)
		var dist: float = Vector2(town.player.position.x - mouth.x, town.player.position.z - mouth.z).length()
		_check(dist > 1.3, "%s: the hero is stopped before the barrier (%.1f m from the mouth)" % [zone_id, dist])
		await _shot("g_passage_%s_sealed" % zone_id)
		Session.set_flag(flag)
		town.get_tree().reload_current_scene()
		await driver.frames(10)
		town = await _wait_for_town()
		if town == null:
			return null
		await _walk_to(town, entry, 1.2)
		await driver.seconds(0.3)
	await _walk_to(town, mouth, 0.5)
	var zone_scene: Node = await _wait_for_scene(scene_class)
	_check(zone_scene != null, "%s: walking down the open passage loads %s" % [zone_id, scene_class])
	if zone_scene != null:
		await driver.seconds(1.0)
		await _shot("g_passage_%s_arrived" % zone_id)
	Session.leave_zone()
	return await _wait_for_town()


# ---- helpers ----------------------------------------------------------------------------------------------------------------------------


func _wait_for_town() -> TownScene:
	var elapsed: float = 0.0
	while elapsed < 30.0:
		var scene: Node = get_tree().current_scene
		if scene is TownScene and not SceneManager.busy:
			await driver.seconds(0.6)
			var town: TownScene = scene as TownScene
			var guard: int = 0
			while guard < 12 and (town.dialogue.active or town._overlay != null):  # arrival dialogue, level-up or reward screens
				guard += 1
				if town.dialogue.active:
					await driver.tap_key(KEY_E)
				elif not await driver.click_button("Continue"):
					await driver.tap_key(KEY_ESCAPE)
				await driver.seconds(0.3)
			return scene as TownScene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _wait_for_scene(class_name_text: String) -> Node:
	var elapsed: float = 0.0
	while elapsed < 75.0:
		var scene: Node = get_tree().current_scene
		if scene != null and scene.get_script() != null and str((scene.get_script() as Script).get_global_name()) == class_name_text and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _walk_to(scene: Node, target: Vector3, radius: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < 25.0:
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < radius:
			break
		if get_tree().current_scene != scene:
			break
		await _hold(KEY_W, offset.z < -0.3)
		await _hold(KEY_S, offset.z > 0.3)
		await _hold(KEY_A, offset.x < -0.3)
		await _hold(KEY_D, offset.x > 0.3)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	if get_tree().current_scene == scene and radius > 1.0 and Vector2(player.position.x - target.x, player.position.z - target.z).length() >= radius + 0.8:
		_note("walk fell back to a teleport near %s" % str(target))
		player.position = target
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held.get(key, false)) == down:
		return
	_held[key] = down
	await driver.key(key, down)


func _shot(shot_name: String) -> void:
	_shots += 1
	await driver.frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, shot_name]))
	print("%s: screenshot -> %s.png" % [TAG, shot_name])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
		return
	print("%s: FAIL  %s" % [TAG, message])
	push_error("%s: %s" % [TAG, message])
	_failures.append(message)


func _note(message: String) -> void:
	print("%s: note  %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
