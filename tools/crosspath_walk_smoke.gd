class_name CrosspathWalkSmoke
extends Node
## Crosspath pass, Part E: the rebuilt town and hub walked with human-style input, windowed. The full loop round the outside of the town (every
## leg walked, no teleports), every shop vendor round the square (the prompt, E opens the vendor, it closes again), the Secret Dealer's alley
## (with the giant chest opened), the lakeshore and the dock, and the abandoned cottage's hatch to the Undercroft. The zone roads in both states
## are the hub walk smoke's (tools/run_hub_walk_smoke.sh).
##   Godot --path . --resolution 1600x900 res://tools/crosspath_walk_smoke_launcher.tscn     (bash tools/run_crosspath_walk_smoke.sh)

const SHOT_DIR: String = "res://_screenshots/crosspath_walk/"
const TAG: String = "crosspath_walk_smoke"
const VENDORS: Array[String] = ["vendor", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "alchemist"]

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.discover_secret(TownScene.HIDDEN_VENDOR_SECRET)  # the Secret Dealer is in the alley
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	SceneManager.go_to_town()
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.seconds(3.0)
	# The outskirts roamers (Playtest v0.4.0) start a fight when the loop brushes past one; this smoke walks the lanes, not the fights.
	var roamers: Array[ZoneEnemy] = town.enemies.duplicate()
	town.enemies.clear()
	for enemy: ZoneEnemy in roamers:
		enemy.queue_free()
	await _dismiss_dialogue(town.dialogue)
	await _dismiss_popups()
	await _shot("c_00_square")
	await _loop(town)
	await _vendors(town)
	await _alley(town)
	await _lake(town)
	await _undercroft(town)
	_finish(_failures.is_empty(), "the loop round the town, %d vendors, the alley, the lakeshore and the hatch (%d screenshots)" % [VENDORS.size(), _shots])


## Every leg of TownBounds.LOOP walked with WASD from the first point; a leg that does not arrive is a failure (something blocks the lane).
func _loop(town: TownScene) -> void:
	var loop: PackedVector2Array = TownBounds.LOOP
	_teleport(town, Vector3(loop[0].x, 0.0, loop[0].y))
	await driver.frames(6)
	var stuck: int = 0
	for index: int in range(1, loop.size() + 1):
		var p: Vector2 = loop[index % loop.size()]
		var target: Vector3 = Vector3(p.x, 0.0, p.y)
		var from: Vector3 = town.player.position
		var limit: float = Vector2(target.x - from.x, target.z - from.z).length() / 3.0 + 3.0
		await _walk_to(town, target, 1.2, limit)
		var left: float = Vector2(town.player.position.x - target.x, town.player.position.z - target.z).length()
		if left > 2.0:
			stuck += 1
			_check(false, "the loop: stuck %.1f m short of %s" % [left, str(p)])
			_teleport(town, target)
			await driver.frames(4)
		if index % 6 == 0:
			await _shot("c_loop_%02d" % index)
	_check(get_tree().current_scene == town, "the loop never takes the hero out of town")
	_check(stuck == 0, "the whole loop round the town is walked (%d legs)" % loop.size())


func _spot(town: TownScene, id: String) -> TownScene.Spot:
	for spot: TownScene.Spot in town.spots:
		if spot.id == id:
			return spot
	return null


## Each vendor: walked up to from the middle of the square, [E] prompt, E opens the vendor (its dialogue, then its screen), and it closes again.
func _vendors(town: TownScene) -> void:
	for id: String in VENDORS:
		var spot: TownScene.Spot = _spot(town, id)
		if spot == null:
			_check(false, "%s: the spot exists" % id)
			continue
		var toward: Vector3 = (spot.position - TownLayout.PLAZA)
		toward.y = 0.0
		_teleport(town, spot.position - toward.normalized() * 3.5)
		await driver.frames(4)
		await _walk_to(town, spot.position, 0.9, 4.0)
		await driver.frames(8)
		_check(town._near != null and town._near.id == id, "%s: walked up to from the square, the prompt is theirs (%s)" % [id, town.hud._prompt_label.text])
		await _shot("c_vendor_%s" % id)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.5)
		_check(town.dialogue.active or town._overlay != null, "%s: E opens the vendor" % id)
		await _close_everything(town)
		_check(not town.dialogue.active and town._overlay == null, "%s: it closes again and the town is live" % id)


func _alley(town: TownScene) -> void:
	var dealer: Vector3 = town.town.anchors["hidden_vendor"] as Vector3
	var mouth: Vector3 = Vector3(TownLayout.ALLEY.get_center().x, 0.0, TownLayout.ALLEY.end.y + 1.5)
	_teleport(town, Vector3(30.0, 0.0, 6.0))
	await driver.frames(4)
	await _walk_to(town, mouth, 0.8, 5.0)
	await _shot("c_alley_mouth")
	await _walk_to(town, dealer + Vector3(0.0, 0.0, 1.0), 0.8, 5.0)
	await driver.frames(8)
	_check(town._near != null and town._near.id == "hidden_vendor", "the alley: the Secret Dealer is reached up the alley (%s)" % town.hud._prompt_label.text)
	await _shot("c_alley_dealer")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(town.dialogue.active or town._overlay != null, "the alley: the Secret Dealer opens the black market")
	await _close_everything(town)


func _lake(town: TownScene) -> void:
	var dock: Vector3 = Vector3(TownBounds.DOCK.get_center().x, 0.0, TownBounds.DOCK.get_center().y)
	_teleport(town, Vector3(53.4, 0.0, 41.0))
	await driver.frames(4)
	await _walk_to(town, Vector3(53.8, 0.0, 47.9), 0.8, 4.0)
	await _walk_to(town, dock + Vector3(2.0, 0.0, 0.0), 0.8, 5.0)
	var on_dock: bool = TownBounds.on_dock(town.player.position)
	_check(on_dock, "the lake: the hero walks out on the dock (%s)" % str(town.player.position))
	await _shot("c_lake_dock")
	# into the water from the dock's end: the hero stops at the planks
	await _walk_to(town, dock + Vector3(8.0, 0.0, 0.0), 0.5, 2.0)
	_check(not TownBounds.in_lake(town.player.position), "the lake: the hero never walks into the water")
	var chest: Vector3 = town.town.anchors["chest"] as Vector3
	_teleport(town, Vector3(54.0, 0.0, 37.0))
	await driver.frames(4)
	# along the middle of the narrow peninsula, then round the chest to its front
	await _walk_to(town, Vector3(61.0, 0.0, 37.3), 0.7, 5.0)
	await _walk_to(town, Vector3(63.4, 0.0, 37.6), 0.7, 3.0)
	await _walk_to(town, chest, 0.9, 4.0)
	_check(Vector2(town.player.position.x - chest.x, town.player.position.z - chest.z).length() < 1.6, "the lake: out along the peninsula to the old chest")
	await _shot("c_lake_peninsula")


func _undercroft(town: TownScene) -> void:
	var hatch: Vector3 = town.town.anchors["arena"] as Vector3
	_teleport(town, Vector3(25.2, 0.0, 41.5))
	await driver.frames(4)
	await _walk_to(town, Vector3(30.5, 0.0, 47.0), 0.9, 4.0)
	await _walk_to(town, hatch + Vector3(1.5, 0.0, 1.5), 0.9, 4.0)
	await _walk_to(town, hatch, 0.8, 3.0)
	await driver.frames(8)
	_check(town._near != null and town._near.id == "arena", "the Undercroft: walked round the abandoned cottage to its hatch (%s)" % town.hud._prompt_label.text)
	await _shot("c_undercroft_hatch")


# ---- Helpers -------------------------------------------------------------------------------------------------------


func _close_everything(town: TownScene) -> void:
	var guard: int = 0
	while guard < 30:
		guard += 1
		if await driver.dismiss_reward_box(0.25):
			continue
		if town.dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.2)
		elif town._overlay != null:
			var closed: bool = await driver.click_button("Continue")
			if not closed:
				closed = await driver.click_button("Close")
			if not closed:
				town._close_overlay()
			await driver.seconds(0.5)
		else:
			break


func _teleport(town: TownScene, pos: Vector3) -> void:
	town.player.position = Vector3(pos.x, 0.0, pos.z)
	town._camera.position = town.player.position + CameraRig.shape(town.camera_offset)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 30.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _dismiss_popups() -> void:
	var guard: int = 0
	while driver.find_button("Continue") != null and guard < 10:
		guard += 1
		await driver.tap_key(KEY_ENTER)
		await driver.seconds(0.5)


func _dismiss_dialogue(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue != null and dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


## Walks toward `target` with WASD (diagonals as two keys) until within `radius` or `limit` seconds pass.
func _walk_to(scene: Node, target: Vector3, radius: float, limit: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < limit:
		if get_tree().current_scene != scene:
			print("crosspath_walk_smoke: left the scene near %s for %s" % [str(target), str(get_tree().current_scene.name) if get_tree().current_scene != null else "(changing)"])
			break
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < radius * 0.55:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _shot(shot_name: String) -> void:
	_shots += 1
	await driver.frames(2)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var texture: Texture2D = get_tree().root.get_texture()
	if texture == null:
		return
	texture.get_image().save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, shot_name]))
	print("%s: screenshot -> %s.png" % [TAG, shot_name])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])
		push_error("%s: %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
