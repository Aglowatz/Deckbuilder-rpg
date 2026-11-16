class_name HeapCornerCamera
extends Node
## Fable Nov 16c (Part 3): the Verdant Dump's two south corners, walked with real keys while the camera is measured every frame. The
## owner's report: in the south-east corner (the fridge chest and the vault lever) the camera fights the player - it does not follow.
## The walk goes into each corner and out again; every frame the smoke records where the hero stands on the screen, how far the lens
## stands sideways of the hero and how much the hero's screen position jumps between two frames. Shots at every stop.
##   bash tools/run_heap_corner_camera.sh <tag> [camera 0|3]      (0 the default camera, 3 Low; tag: before / after)
## Exit code 0 = the camera followed (the hero stayed in the middle of the frame, no jumps); 1 = it did not.

const SHOT_DIR: String = "res://_screenshots/heap_corner/"
const TAG: String = "heap_corner_camera"
## The hero must stay inside this part of the frame (shares of its width and height) while walking.
const FRAME_X: Vector2 = Vector2(0.3, 0.7)
const FRAME_Y: Vector2 = Vector2(0.3, 0.85)
## The largest move of the hero on the screen between two frames (pixels at 1600 wide) that still counts as smooth, and the largest
## sideways distance between the lens and the hero (metres).
const MAX_JUMP: float = 14.0
const MAX_SIDE: float = 2.0
## South-east: from the commons' east side down past the lever to the fridge chest, into the very corner, and out again.
const ROUTE_SE: Array[Array] = [
	["start", Vector3(70.0, 0.0, 115.0)], ["band_edge", Vector3(72.0, 0.0, 120.0)], ["toward_lever", Vector3(76.5, 0.0, 124.5)], ["lever", Vector3(79.0, 0.0, 128.3)],
	["chest", Vector3(74.6, 0.0, 130.2)], ["corner", Vector3(79.2, 0.0, 132.6)], ["back_at_chest", Vector3(75.5, 0.0, 129.5)], ["out", Vector3(70.0, 0.0, 116.0)],
]
const ROUTE_SW: Array[Array] = [
	["start", Vector3(31.0, 0.0, 115.0)], ["band_edge", Vector3(28.0, 0.0, 121.0)], ["inner", Vector3(24.0, 0.0, 127.0)], ["corner", Vector3(21.5, 0.0, 132.0)], ["out", Vector3(30.0, 0.0, 116.0)],
]

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0
var _zone: HeapScene
var _tag: String = "run"
var _camera_name: String = "default"
var _measuring: bool = false
var _last_screen: Vector2 = Vector2.INF
var _stats: Dictionary = {}


func _ready() -> void:
	process_priority = 2000  # after the look rig: the camera of the frame that is drawn


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.REFUSEMANCER)
	Session.set_flag(CorruptedNpcs.unlock_flag(HeapZone.ID))
	_tag = OS.get_environment("HEAP_CORNER_TAG") if OS.get_environment("HEAP_CORNER_TAG") != "" else "run"
	var camera: String = OS.get_environment("HEAP_CORNER_CAMERA")
	if camera != "":
		Settings.set_camera_angle(int(camera))
	_camera_name = "low" if Settings.camera_angle == 3 else ("default" if Settings.camera_angle == 0 else "cam%d" % Settings.camera_angle)
	print("%s: %s, camera angle %d (%s)" % [TAG, _tag, Settings.camera_angle, _camera_name])
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	Session.enter_zone(HeapZone.ID)
	_zone = await _wait_for(HeapScene) as HeapScene
	if _zone == null:
		_finish(false, "the Verdant Dump never loaded")
		return
	await driver.seconds(3.5)
	await _dismiss_dialogue(_zone.dialogue)
	for foe: Node in _zone.get_tree().get_nodes_in_group(&"zone_roamers"):
		foe.queue_free()
	await _walk_route("se", ROUTE_SE)
	await _walk_route("sw", ROUTE_SW)
	_finish(_failures.is_empty(), "both south corners walked in and out (%d screenshots)" % _shots)


func _walk_route(corner: String, route: Array[Array]) -> void:
	var first: Vector3 = route[0][1] as Vector3
	_teleport(_zone, first)
	await driver.seconds(1.2)
	_stats = {"frames": 0, "out_x": 0, "out_y": 0, "max_jump": 0.0, "max_side": 0.0, "min_x": 1.0, "max_x": 0.0, "min_y": 1.0, "max_y": 0.0, "worst_at": Vector3.ZERO}
	_last_screen = Vector2.INF
	_measuring = true
	for index: int in range(route.size()):
		var stop: Array = route[index]
		var target: Vector3 = stop[1] as Vector3
		if index > 0:
			await _walk_to(_zone, target, 1.3, 14.0)
		await driver.seconds(0.9)  # let the camera settle: a camera that follows has nothing left to do
		var side: float = _zone._camera.global_position.x - _zone.player.global_position.x
		var screen: Vector2 = _hero_on_screen()
		print("%s: stop  %s %s at (%.1f, %.1f): hero on screen (%.2f, %.2f), lens %.1f m to the side" % [TAG, corner, str(stop[0]), _zone.player.position.x, _zone.player.position.z, screen.x, screen.y, side])
		await _shot("%s_%s_%s_%d_%s" % [_tag, _camera_name, corner, index + 1, str(stop[0])])
	_measuring = false
	var frames: int = maxi(int(_stats["frames"]), 1)
	print("%s: walk  %s: %d frames; hero on screen x %.2f to %.2f, y %.2f to %.2f; outside the middle of the frame %d frames sideways, %d up or down; biggest jump between two frames %.1f px; lens up to %.1f m to the side (worst at %.1f, %.1f)" % [
		TAG, corner, frames, float(_stats["min_x"]), float(_stats["max_x"]), float(_stats["min_y"]), float(_stats["max_y"]), int(_stats["out_x"]), int(_stats["out_y"]), float(_stats["max_jump"]), float(_stats["max_side"]),
		(_stats["worst_at"] as Vector3).x, (_stats["worst_at"] as Vector3).z])
	_check(int(_stats["out_x"]) == 0, "%s: the hero stays in the middle of the frame, left to right (%.2f to %.2f)" % [corner, float(_stats["min_x"]), float(_stats["max_x"])])
	_check(int(_stats["out_y"]) == 0, "%s: the hero stays in the middle of the frame, top to bottom (%.2f to %.2f)" % [corner, float(_stats["min_y"]), float(_stats["max_y"])])
	_check(float(_stats["max_jump"]) <= MAX_JUMP, "%s: no jump (%.1f px between two frames at most)" % [corner, float(_stats["max_jump"])])
	_check(float(_stats["max_side"]) <= MAX_SIDE, "%s: the lens stays behind the hero (%.1f m to the side at most)" % [corner, float(_stats["max_side"])])


## Where the hero's chest is on the screen, as shares of its width and height.
func _hero_on_screen() -> Vector2:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var point: Vector2 = _zone._camera.unproject_position(_zone.player.global_position + Vector3(0.0, 0.8, 0.0))
	return Vector2(point.x / view.x, point.y / view.y)


func _process(_delta: float) -> void:
	if not _measuring or _zone == null or not is_instance_valid(_zone) or _zone._camera == null:
		return
	var view: Vector2 = get_viewport().get_visible_rect().size
	var screen: Vector2 = _hero_on_screen()
	_stats["frames"] = int(_stats["frames"]) + 1
	_stats["min_x"] = minf(float(_stats["min_x"]), screen.x)
	_stats["max_x"] = maxf(float(_stats["max_x"]), screen.x)
	_stats["min_y"] = minf(float(_stats["min_y"]), screen.y)
	_stats["max_y"] = maxf(float(_stats["max_y"]), screen.y)
	if screen.x < FRAME_X.x or screen.x > FRAME_X.y:
		_stats["out_x"] = int(_stats["out_x"]) + 1
	if screen.y < FRAME_Y.x or screen.y > FRAME_Y.y:
		_stats["out_y"] = int(_stats["out_y"]) + 1
	var pixels: Vector2 = screen * view * (1600.0 / view.x)
	if _last_screen != Vector2.INF:
		_stats["max_jump"] = maxf(float(_stats["max_jump"]), pixels.distance_to(_last_screen))
	_last_screen = pixels
	var side: float = absf(_zone._camera.global_position.x - _zone.player.global_position.x)
	if side > float(_stats["max_side"]):
		_stats["max_side"] = side
		_stats["worst_at"] = _zone.player.global_position


func _teleport(zone: HeapScene, pos: Vector3) -> void:
	pos.y = zone.builder.height_at(pos)
	zone.player.position = pos
	zone.last_safe = pos
	zone._spawn_grace = 100000.0
	zone._invulnerable = 100000.0
	zone._entrance_exit_armed = false
	zone._camera.position = zone.player.position + CameraRig.shape(zone.camera_offset)
	_last_screen = Vector2.INF


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 25.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _dismiss_dialogue(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 30:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


func _walk_to(scene: Node, target: Vector3, radius: float, limit: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	var last_pos: Vector3 = player.position
	var stuck_for: float = 0.0
	var sidestep: float = 0.0
	var side: float = 1.0
	while elapsed < limit:
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < radius * 0.55:
			break
		if sidestep > 0.0:
			var across: Vector3 = Vector3(-offset.z, 0.0, offset.x).normalized() * side
			await _hold(KEY_W, across.z < -0.35)
			await _hold(KEY_S, across.z > 0.35)
			await _hold(KEY_A, across.x < -0.35)
			await _hold(KEY_D, across.x > 0.35)
			await driver.frames(2)
			elapsed += 2.0 / 60.0
			sidestep -= 2.0 / 60.0
			continue
		if player.position.distance_to(last_pos) < 0.02:
			stuck_for += 2.0 / 60.0
			if stuck_for > 0.4:
				stuck_for = 0.0
				sidestep = 0.5
				side *= -1.0
		else:
			stuck_for = 0.0
		last_pos = player.position
		if (scene.dialogue as DialogueBox).active:
			for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
				await _hold(key, false)
			await driver.tap_key(KEY_E)
			await driver.seconds(0.2)
			continue
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	var off: float = Vector2(player.position.x - target.x, player.position.z - target.z).length()
	_check(off < radius + 0.6, "walked to (%.1f, %.1f) on foot (%.1f m off)" % [target.x, target.z, off])


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


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	await driver.frames(3)
	get_tree().quit(0 if ok else 1)
