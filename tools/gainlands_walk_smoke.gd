class_name GainlandsWalkSmoke
extends Node
## Gainlands corrective pass, Part G: walk the whole zone with human-style input (real injected keys and clicks), windowed.
## Arrival over the bridge and the walk into the plaza; the House of Gains gate (the entrance still asks to enter); the locked Mount Swolympus gate
## (coming soon, never opens) and the sealed Iron Cavern; then back out over the bridge to town by simply walking off its far end (there are no
## sub-area scenes: the zone is one walkable map, docs/design/subarea_removal.md). Screenshots to _screenshots/gainlands_walk/.
##   Godot --path . --resolution 1600x900 res://tools/gainlands_walk_smoke_launcher.tscn     (bash tools/run_gainlands_walk_smoke.sh)
## Deliberate shortcuts: long legs across the map are a teleport to a few metres short of the target, then real walking for the last stretch (the
## walkability probe covers the long routes); the thrower routes have their own smoke (tools/run_thrower_smoke.sh).
## Exit code 0 = every check passed; 1 = a check failed.

const SHOT_DIR: String = "res://_screenshots/gainlands_walk/"
const TAG: String = "gainlands_walk_smoke"

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
	Session.enter_zone(GainlandsZone.ID)
	var zone: GainlandsScene = await _wait_for(GainlandsScene) as GainlandsScene
	if zone == null:
		_finish(false, "the Gainlands never loaded")
		return
	await driver.seconds(3.5)  # the zone title card
	await _dismiss_dialogue(zone.dialogue)
	await _arrival_over_the_bridge(zone)
	await _house_of_gains_gate(zone)
	await _locked_swolympus(zone)
	await _back_out_over_the_bridge(zone)
	_finish(_failures.is_empty(), "bridge -> plaza -> House of Gains gate -> locked Swolympus gate and cavern -> bridge -> town (%d screenshots)" % _shots)


# ---- Legs ----------------------------------------------------------------------------------------------------------


func _arrival_over_the_bridge(zone: GainlandsScene) -> void:
	var pos: Vector3 = zone.player.position
	_check(GainlandsLayout.on_bridge(pos.x, pos.z), "arrival: the hero starts on the bridge (%.0f, %.0f)" % [pos.x, pos.z])
	await _shot("g_01_arrival_on_the_bridge")
	var hub: Vector3 = zone.builder.anchor("hub")
	await _walk_to(zone, Vector3(hub.x, 0.0, hub.z + 2.0), 2.0, 16.0)
	pos = zone.player.position
	_check(Vector2(pos.x - hub.x, pos.z - hub.z).length() < 4.5, "arrival: walked north off the bridge into the plaza (%.1f m from its centre)" % Vector2(pos.x - hub.x, pos.z - hub.z).length())
	_check(not GainlandsLayout.on_bridge(pos.x, pos.z) and GainlandsLayout.is_main_ground(pos.x, pos.z), "arrival: standing on the meadow")
	await _shot("g_02_the_plaza")


func _house_of_gains_gate(zone: GainlandsScene) -> void:
	var entrance: Vector3 = zone.builder.anchor("main_dungeon")
	_teleport(zone, Vector3(entrance.x, 0.0, entrance.z + 9.0))
	await _walk_to(zone, entrance + Vector3(0.0, 0.0, 0.6), 1.2, 8.0)
	await _dismiss_dialogue(zone.dialogue)
	await driver.frames(4)
	_check(zone._near != null and zone._near.kind == "main_dungeon", "House of Gains: the gate prompt is up (near %s)" % (zone._near.id if zone._near != null else "nothing"))
	_check(zone._near != null and not zone._near.plate.visible, "House of Gains: no lettered plate at the gate")
	await _shot("g_03_house_of_gains_gate")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	var not_yet: Button = driver.find_button("Not yet")
	_check(not_yet != null, "House of Gains: E asks to enter the dungeon (the entrance still works)")
	await _shot("g_04_house_of_gains_ask")
	if not_yet != null:
		await driver.click_button("Not yet")
		await driver.seconds(0.4)
	_check(not zone._locked, "House of Gains: Not yet gives the hero back")


func _locked_swolympus(zone: GainlandsScene) -> void:
	var gate: ZoneSpot = null
	for spot: ZoneSpot in zone.spots:
		if spot.id == GainlandsZone.SWOLYMPUS_GATE:
			gate = spot
	_check(gate != null and zone.builder.root.find_child("SwolympusGate", false, false) != null, "Swolympus: the locked trailhead gate stands in the hub")
	if gate == null:
		return
	var gate_pos: Vector3 = zone.builder.anchor(GainlandsZone.SWOLYMPUS_GATE)
	_teleport(zone, gate_pos + Vector3(-6.0, 0.0, 6.0))
	await _walk_to(zone, gate.position, 1.2, 8.0)
	await driver.frames(6)
	_check(zone._near == gate, "Swolympus: the gate prompt is up (near %s)" % (zone._near.id if zone._near != null else "nothing"))
	var prompt: String = str(zone.hud._prompt_label.text)
	_check(prompt.to_lower().contains("coming soon"), "Swolympus: the gate prompt says coming soon (%s)" % prompt)
	await _shot("g_05_swolympus_gate_locked")
	var before: String = Session.scene_kind()
	await driver.tap_key(KEY_E)
	await driver.seconds(0.8)
	_check(get_tree().current_scene == zone, "Swolympus: E at the locked gate goes nowhere (scene still the hub, was %s)" % before)
	_check(str(zone.hud._toast.text).to_lower().contains("coming soon"), "Swolympus: the HUD toast says coming soon")
	await _shot("g_06_swolympus_gate_toast")
	# the sealed cavern beside it
	var cavern: ZoneSpot = null
	for spot: ZoneSpot in zone.spots:
		if spot.kind == "mini_dungeon":
			cavern = spot
	_check(cavern != null, "Swolympus: the Iron Cavern spot exists")
	if cavern == null:
		return
	_teleport(zone, cavern.position + Vector3(0.0, 0.0, 5.0))
	await _walk_to(zone, cavern.position + Vector3(0.0, 0.0, 0.8), 1.2, 6.0)
	await driver.frames(6)
	_check(zone._near == cavern, "Swolympus: the cavern prompt is up")
	_check(str(zone.hud._prompt_label.text).to_lower().contains("coming soon"), "Swolympus: the cavern prompt says coming soon")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	_check(driver.find_button("Enter") == null and not zone._locked, "Swolympus: E at the cavern opens nothing")
	await _shot("g_07_iron_cavern_sealed")


func _back_out_over_the_bridge(zone: GainlandsScene) -> void:
	var spawn: Vector3 = zone.builder.anchor("spawn")
	_teleport(zone, Vector3(spawn.x, 0.0, GainlandsLayout.BRIDGE_Z0 + 3.0))
	await driver.frames(4)
	await _shot("g_15_leaving_over_the_bridge")
	# walk south down the deck and off its far end: no prompt needed
	await _hold(KEY_S, true)
	var waited: float = 0.0
	while waited < 14.0 and get_tree().current_scene == zone:
		await driver.frames(3)
		waited += 3.0 / 60.0
	await _hold(KEY_S, false)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "walking off the far end of the bridge leads back to town")
	if town != null:
		await driver.seconds(0.8)
		await _shot("g_16_back_in_town")


# ---- Helpers -------------------------------------------------------------------------------------------------------


func _teleport(zone: GainlandsScene, pos: Vector3) -> void:
	pos.y = zone.builder.height_at(pos)
	zone.player.position = pos
	zone.last_safe = pos
	zone._spawn_grace = 100000.0
	zone._camera.position = zone.player.position + CameraRig.shape(zone.camera_offset)


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
	while elapsed < limit:
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < radius * 0.55:
			break
		if "dialogue" in scene and (scene.dialogue as DialogueBox).active:
			# an NPC caught the hero on the way (the Rift Express unlock speech): read it and walk on
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
	_check(off < radius, "walked to (%.0f, %.0f) on foot (%.1f m off)" % [target.x, target.z, off])
	if off >= radius and "gain" in scene:
		var near: PackedStringArray = PackedStringArray()
		for list: Variant in (scene.gain as GainlandsBuilder)._buckets.values():
			for obstacle: Vector3 in (list as Array):
				if Vector2(obstacle.x - player.position.x, obstacle.y - player.position.z).length() < obstacle.z + 2.5:
					near.append("(%.1f, %.1f) r %.2f" % [obstacle.x, obstacle.y, obstacle.z])
		print("%s: note  stuck at (%.1f, %.1f); obstacles within reach: %s" % [TAG, player.position.x, player.position.z, ", ".join(near)])
	if off >= radius:
		player.position = target
		player.position.y = (scene.builder as WalkableArea).height_at(player.position) if "builder" in scene else player.position.y
		await driver.frames(3)


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
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("%s: FAIL  %s" % [TAG, message])
	push_error("%s: %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
