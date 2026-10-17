class_name HubWalkSmoke
extends Node
## Overnight Oct 16, Block 3h: the hub world with human-style input, windowed. From the square to every zone road: the obstacle stops the hero
## while its gatekeeper is unbeaten (the toast names who to beat); with the gatekeepers beaten (debug flags) every obstacle stands cleared and
## walking down the road enters the zone, and the way back lands on the same road. The imperial road enters the Capital from the start. The
## Undercroft: the hatch is chained before the first zone is free; afterwards the hatch opens The Undercroft's booth.
##   Godot --path . --resolution 1600x900 res://tools/hub_walk_smoke_launcher.tscn     (bash tools/run_hub_walk_smoke.sh)
## Long legs across the town are a teleport to a few metres short of the target, then real walking (the walkability probe covers the routes).

const SHOT_DIR: String = "res://_screenshots/hub_walk/"
const TAG: String = "hub_walk_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	var town: TownScene = await _to_town()
	if town == null:
		_finish(false, "town never loaded")
		return
	_check(town.town.hub_land and town.hub_obstacles != null, "the hub is one country with its road obstacles")
	await _shot("h_00_square")
	for zone_id: String in Gatekeepers.IDS:
		town = await _blocked_road(town, zone_id)
	town = await _hatch_chained(town)
	for zone_id: String in Gatekeepers.IDS:
		Session.set_flag(CorruptedNpcs.unlock_flag(zone_id))
	Session.set_flag(ZoneCompletion.flag_name(GainlandsZone.ID))  # the first zone free: the Undercroft opens
	town = await _to_town()
	for zone_id: String in Gatekeepers.IDS:
		_check(town.hub_obstacles.is_cleared(zone_id), "%s: the obstacle stands cleared once its gatekeeper is beaten" % zone_id)
	for zone_id: String in Gatekeepers.IDS + ["final"]:
		town = await _open_road(town, zone_id)
		if town == null:
			_finish(false, "lost the town after %s" % zone_id)
			return
	await _undercroft_open(town)
	_finish(_failures.is_empty(), "five roads blocked/open and back, the Undercroft chained and open (%d screenshots)" % _shots)


func _to_town() -> TownScene:
	SceneManager.go_to_town()
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town != null:
		await driver.seconds(3.0)
		await _dismiss_dialogue(town.dialogue)
		await _dismiss_popups()
	return town


func _blocked_road(town: TownScene, zone_id: String) -> TownScene:
	var mouth: Vector3 = town.town.anchors["portal_%s_mouth" % zone_id] as Vector3
	var out: Vector3 = TownBuilder.PORTAL_OUT[zone_id] as Vector3
	_teleport(town, mouth - out * 7.0)
	await driver.frames(4)
	await _walk_to(town, mouth + out * 1.0, 0.6, 4.0, false)
	await driver.seconds(0.6)
	_check(get_tree().current_scene == town, "%s: the obstacle stops the hero (still in town)" % zone_id)
	var stop: float = Vector2(town.player.position.x - mouth.x, town.player.position.z - mouth.z).length()
	_check(stop > 1.3, "%s: the hero stands short of the road's end (%.1f m)" % [zone_id, stop])
	_check(str(town.hud._toast.text).contains(Gatekeepers.display_name(zone_id)), "%s: the toast says who to beat (%s)" % [zone_id, town.hud._toast.text])
	await _shot("h_%s_blocked" % zone_id)
	return town


func _open_road(town: TownScene, zone_id: String) -> TownScene:
	var mouth: Vector3 = town.town.anchors["portal_%s_mouth" % zone_id] as Vector3
	var out: Vector3 = TownBuilder.PORTAL_OUT[zone_id] as Vector3
	_teleport(town, mouth - out * 7.0)
	await driver.frames(4)
	await _shot("h_%s_open" % zone_id)
	await _walk_to(town, mouth + out * 1.5, 0.6, 6.0, true)
	var zone: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	_check(zone != null and zone.def.id == zone_id, "%s: walking down the open road enters the zone" % zone_id)
	if zone == null:
		return await _to_town()
	await driver.seconds(2.5)
	await _dismiss_dialogue(zone.dialogue)
	await _dismiss_popups()
	await _shot("h_%s_arrived" % zone_id)
	Session.leave_zone()
	await driver.frames(10)
	var back: TownScene = await _wait_for(TownScene) as TownScene
	if back == null:
		return null
	await driver.seconds(2.0)
	await _dismiss_dialogue(back.dialogue)
	await _dismiss_popups()
	var at: float = Vector2(back.player.position.x - mouth.x, back.player.position.z - mouth.z).length()
	_check(at < 9.0, "%s: back on the same road (%.1f m from its end)" % [zone_id, at])
	return back


func _hatch_chained(town: TownScene) -> TownScene:
	var spot: Vector3 = town.town.anchors["arena"] as Vector3
	_teleport(town, spot + Vector3(0.0, 0.0, 3.0))
	await _walk_to(town, spot, 0.8, 4.0, false)
	await driver.frames(8)
	_check(town._near != null and town._near.id == "arena", "the Undercroft: the hatch prompt is up")
	_check(str(town.hud._prompt_label.text).contains("chained"), "the Undercroft: chained shut before the first zone is free (%s)" % town.hud._prompt_label.text)
	await _shot("h_undercroft_chained")
	return town


func _undercroft_open(town: TownScene) -> void:
	var spot: Vector3 = town.town.anchors["arena"] as Vector3
	_teleport(town, spot + Vector3(0.0, 0.0, 3.0))
	await _walk_to(town, spot, 0.8, 4.0, false)
	await driver.frames(8)
	_check(str(town.hud._prompt_label.text).contains("cellar"), "the Undercroft: the hatch opens once a zone is free (%s)" % town.hud._prompt_label.text)
	await _shot("h_undercroft_hatch")
	await driver.tap_key(KEY_E)
	await _dismiss_dialogue(town.dialogue)
	await driver.seconds(0.8)
	var screen: Node = null
	for node: Node in town.find_children("*", "ArenaScreen", true, false):
		screen = node
	_check(screen != null, "the Undercroft: the booth opens (the ring is a screen, not a place)")
	await _shot("h_undercroft_booth")


# ---- Helpers -------------------------------------------------------------------------------------------------------


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


## Walks toward `target` with WASD; stops early when the scene changes (a road taken) when `may_leave`.
func _walk_to(scene: Node, target: Vector3, radius: float, limit: float, may_leave: bool) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < limit:
		if get_tree().current_scene != scene:
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
	if not may_leave and is_instance_valid(player):
		pass


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _shot(name: String) -> void:
	_shots += 1
	await driver.frames(2)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var texture: Texture2D = get_tree().root.get_texture()
	if texture == null:
		return
	texture.get_image().save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, name]))
	print("%s: screenshot -> %s.png" % [TAG, name])


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
