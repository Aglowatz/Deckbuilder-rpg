class_name BuffetWalkSmoke
extends Node
## Endless Buffet slice, Part E: walk the whole zone with human-style input (real injected keys and clicks), windowed.
## Arrival on the biscuit bridge and the walk north into the Grand Dining Hall; every quest NPC and the vendor (E opens their talk / shop); the Hearty Meal, the
## Grand Oven, the Soup Fountain, the fortune cookies and Old Meatloaf; the quiz master, Chef Flambe's Dinner in a Dash and the Taste-Test Station; the Mystery
## Stew Pot on the Pancake Summit; the Walk-In Freezer door (sealed: the hook; unlocked: E asks to enter the Omakase) and the Test Kitchen gate (prompt, no lettered
## plate, E asks); the giant chest and the vault lever (prompts up); then back out over the bridge to town by simply walking off its far end (the zone is one
## walkable map, docs/design/subarea_removal.md). Screenshots to _screenshots/buffet_walk/.
##   Godot --path . --resolution 1600x900 res://tools/buffet_walk_smoke_launcher.tscn     (bash tools/run_buffet_walk_smoke.sh)
## Deliberate shortcuts: long legs across the map are a teleport to a few metres short of the target, then real walking for the last stretch (the walkability probe
## covers the long routes); the rafts, the susan, the jelly pads, the battles, the quiz questions and the puzzle moves have their own smoke
## (tools/run_seventh_brief_final_smoke.sh buffet). Exit code 0 = every check passed; 1 = a check failed.

const SHOT_DIR: String = "res://_screenshots/buffet_walk/"
const TAG: String = "buffet_walk_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	Session.set_flag(CorruptedNpcs.unlock_flag(BuffetZone.ID))
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	Session.enter_zone(BuffetZone.ID)
	var zone: BuffetScene = await _wait_for(BuffetScene) as BuffetScene
	if zone == null:
		_finish(false, "the Endless Buffet never loaded")
		return
	await driver.seconds(3.5)  # the zone title card
	await _dismiss_dialogue(zone.dialogue)
	# the three golem gates open for the walk (their conditions are unit-tested and played by the Buffet smoke)
	for gate: BuffetGates.Gate in BuffetGates.gates():
		Session.set_flag(gate.flag)
		zone.buf.open_gate(gate.id)
	await _arrival_over_the_bridge(zone)
	await _the_people_and_the_things(zone)
	await _the_games(zone)
	await _the_dungeons(zone)
	await _the_chest_and_the_lever(zone)
	await _back_out_over_the_bridge(zone)
	_finish(_failures.is_empty(), "bridge -> plaza -> NPCs, vendor, interactables -> quiz, Dinner in a Dash, taste test, stew pot -> the Walk-In Freezer (Omakase), the Test Kitchen -> giant chest, lever -> bridge -> town (%d screenshots)" % _shots)


# ---- Legs ----------------------------------------------------------------------------------------------------------


func _arrival_over_the_bridge(zone: BuffetScene) -> void:
	var pos: Vector3 = zone.player.position
	_check(BuffetLayout.on_bridge(pos.x, pos.z), "arrival: the hero starts on the bridge (%.0f, %.0f)" % [pos.x, pos.z])
	await _shot("w_01_arrival_on_the_bridge")
	var plaza: Vector3 = zone.builder.anchor("plaza")
	await _walk_to(zone, Vector3(plaza.x, 0.0, plaza.z - 3.0), 2.0, 16.0)
	pos = zone.player.position
	_check(not BuffetLayout.on_bridge(pos.x, pos.z), "arrival: walked north off the bridge into the Grand Dining Hall")
	_check(Vector2(pos.x - 50.0, pos.z - 64.0).length() < BuffetLayout.PLAZA_RADIUS + 1.0, "arrival: standing in the plaza (%.1f m from the fountain)" % Vector2(pos.x - 50.0, pos.z - 64.0).length())
	_check(zone.buf.test_kitchen != null and zone.buf.test_kitchen.visible, "arrival: the Test Kitchen stands on the skyline")
	await _shot("w_02_the_grand_dining_hall")


## Each NPC and interactable: walk up, the prompt is up, E does its thing, the hero is given back.
func _the_people_and_the_things(zone: BuffetScene) -> void:
	await _use_spot(zone, "odalys", "w_03_basil", true)
	await _use_spot(zone, "tarragon", "w_04_tarragon", true)
	await _use_spot(zone, "dolcetta", "w_05_mirepoix", true)
	await _use_spot(zone, "heal", "w_06_hearty_meal", false)
	await _use_spot(zone, "oven", "w_07_grand_oven", false)
	await _use_spot(zone, "soup_fountain", "w_08_soup_fountain", false)
	Session.add_gold(60)
	await _use_spot(zone, "fortune_cookie", "w_09_fortune_cookie", false)
	await _use_spot(zone, "old_meatloaf", "w_10_old_meatloaf", false)


func _the_games(zone: BuffetScene) -> void:
	await _use_spot(zone, "quiz", "w_11_professor_pate", true)
	await _use_spot(zone, "minigame", "w_12_dinner_in_a_dash", true)
	await _use_spot(zone, "taste_test", "w_13_taste_test", false)
	await _use_spot(zone, "puzzle", "w_14_mystery_stew_pot", true)


func _the_dungeons(zone: BuffetScene) -> void:
	# the Walk-In Freezer: sealed, the door drops the Omakase hook; unlocked, E asks to enter (the side dungeon is node-based)
	var freezer: ZoneSpot = _spot(zone, "mini_dungeon")
	_check(freezer != null, "the Walk-In Freezer spot exists")
	if freezer != null:
		_teleport(zone, freezer.position + Vector3(0.0, 0.0, 5.0))
		await _walk_to(zone, freezer.position + Vector3(0.0, 0.0, 0.6), 1.2, 8.0)
		await _dismiss_dialogue(zone.dialogue)
		await driver.frames(4)
		_check(zone._near == freezer, "the Walk-In Freezer: the door prompt is up (near %s)" % (zone._near.id if zone._near != null else "nothing"))
		_check(not freezer.plate.visible, "the Walk-In Freezer: no lettered plate (the Pavilion's board carries the icon)")
		_check(zone.buf.landmarks.has("BUFF-HERO-OMAKASE-PAVILION"), "the Omakase Pavilion stands over the door")
		await _shot("w_15_walk_in_freezer")
		await driver.tap_key(KEY_E)
		await driver.seconds(0.6)
		_check(not Session.side_unlocked("S-GOUR") and zone._overlay == null and str(zone.hud._toast.text).to_lower().contains("sealed"), "the Walk-In Freezer: sealed until the Golden Reservation, the door says so")
		Session.set_flag(DungeonCatalog.side_unlock_flag("S-GOUR"))
		await driver.seconds(0.4)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.6)
		var not_yet: Button = driver.find_button("Not yet")
		_check(not_yet != null, "the Walk-In Freezer: unlocked, E asks to enter the Omakase (its node map)")
		await _shot("w_16_omakase_ask")
		if not_yet != null:
			await driver.click_button("Not yet")
			await driver.seconds(0.4)
		_check(not zone._locked, "the Walk-In Freezer: the hero is given back")
	# the Test Kitchen at its gate
	var entrance: Vector3 = zone.builder.anchor("main_dungeon")
	_teleport(zone, Vector3(entrance.x, 0.0, entrance.z + 7.0))
	await _walk_to(zone, entrance + Vector3(0.0, 0.0, 1.2), 1.2, 8.0)
	await _dismiss_dialogue(zone.dialogue)
	await driver.frames(4)
	_check(zone._near != null and zone._near.kind == "main_dungeon", "the Test Kitchen: the gate prompt is up (near %s)" % (zone._near.id if zone._near != null else "nothing"))
	_check(zone._near != null and not zone._near.plate.visible, "the Test Kitchen: no lettered plate at the gate")
	await _shot("w_17_test_kitchen_gate")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	var not_yet_kitchen: Button = driver.find_button("Not yet")
	_check(not_yet_kitchen != null, "the Test Kitchen: E asks to enter the dungeon (the entrance still works)")
	await _shot("w_18_test_kitchen_ask")
	if not_yet_kitchen != null:
		await driver.click_button("Not yet")
		await driver.seconds(0.4)
	_check(not zone._locked, "the Test Kitchen: Not yet gives the hero back")


func _the_chest_and_the_lever(zone: BuffetScene) -> void:
	for key: String in ["giant_chest", "vault_lever"]:
		var pos: Vector3 = zone.builder.anchor(key)
		# both stand at the table's south edge: approach along it (the giant chest has the gravy pond just north of it)
		var side: float = 1.0 if key == "giant_chest" else -1.0
		_teleport(zone, pos + Vector3(side * 5.0, 0.0, 0.0))
		await _walk_to(zone, pos + Vector3(side * 1.6, 0.0, 0.0), 1.0, 8.0)
		await _dismiss_dialogue(zone.dialogue)
		await driver.frames(4)
		var prompt: String = str(zone.hud._prompt_label.text)
		_check(prompt != "", "%s: a prompt is up when the hero walks up (%s)" % [key, prompt])
		await _shot("w_19_%s" % key)


func _back_out_over_the_bridge(zone: BuffetScene) -> void:
	var plaza: Vector3 = zone.builder.anchor("plaza")
	_teleport(zone, Vector3(plaza.x, 0.0, plaza.z - 2.0))
	await driver.frames(4)
	# walk south onto the bridge, down it and off its far end: no prompt needed
	await _walk_to(zone, zone.builder.anchor("spawn"), 1.6, 14.0)
	_check(BuffetLayout.on_bridge(zone.player.position.x, zone.player.position.z), "leaving: back on the bridge")
	await _shot("w_21_leaving_over_the_bridge")
	await _hold(KEY_S, true)
	var waited: float = 0.0
	while waited < 10.0 and get_tree().current_scene == zone:
		await driver.frames(3)
		waited += 3.0 / 60.0
	await _hold(KEY_S, false)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "walking off the far end of the bridge leads back to town")
	if town != null:
		await driver.seconds(0.8)
		await _shot("w_22_back_in_town")


# ---- Helpers -------------------------------------------------------------------------------------------------------


## Walk up to a spot, check its prompt, press E, then close whatever opened (a talk, a shop, a game screen, a toast) and check the hero is free again.
func _use_spot(zone: BuffetScene, id: String, shot_name: String, opens_screen: bool) -> void:
	var spot: ZoneSpot = _spot(zone, id)
	_check(spot != null, "%s: the spot exists" % id)
	if spot == null:
		return
	# stand beside the spot on the first open side (south, north, east, west), walking the last metres
	var stand: Vector3 = spot.position
	var start: Vector3 = spot.position
	for dir: Vector3 in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
		var near: Vector3 = spot.position + dir * maxf(spot.radius - 0.3, 0.8)
		if zone.builder.is_walkable(near):
			stand = near
			start = near + dir * 3.5
			if not zone.builder.is_walkable(start):
				start = near + dir * 1.5
			if not zone.builder.is_walkable(start):
				start = near
			break
	_teleport(zone, start)
	await _walk_to(zone, stand, 0.9, 8.0)
	await _dismiss_dialogue(zone.dialogue)
	await driver.frames(4)
	_check(zone._near == spot, "%s: the prompt is up (near %s)" % [id, zone._near.id if zone._near != null else "nothing"])
	await driver.tap_key(KEY_E)
	await driver.seconds(0.7)
	var opened: bool = zone.dialogue.active or zone._overlay != null or str(zone.hud._toast.text) != "" or zone._locked
	_check(opened, "%s: E does something (a talk, a screen or a toast)" % id)
	await _shot(shot_name)
	# close it again: talks with E, screens with Escape, confirm boxes with their Not yet / Close buttons
	var guard: int = 0
	while (zone.dialogue.active or zone._overlay != null or zone._locked) and guard < 40:  # Overnight Oct 18: conversations grew in the dialogue pass (two taps a line with the typewriter)
		guard += 1
		var cancel: Button = driver.find_button("Not yet")
		if cancel == null:
			cancel = driver.find_button("Close")
		if cancel == null:
			cancel = driver.find_button("Leave it")
		if cancel == null:
			cancel = driver.find_button("Not now")
		if cancel != null:
			await driver.click_button(cancel.text)
			await driver.seconds(0.3)
			continue
		if zone._overlay != null:
			await driver.tap_key(KEY_ESCAPE)
			await driver.seconds(0.35)
			continue
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)
	await driver.dismiss_reward_box(0.3)
	await driver.seconds(0.3)
	_check(not zone._locked and zone._overlay == null and not zone.dialogue.active, "%s: the hero is given back (screen %s, locked %s)" % [id, str(opens_screen), str(zone._locked)])


func _spot(zone: BuffetScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	return null


func _teleport(zone: BuffetScene, pos: Vector3) -> void:
	pos.y = zone.builder.height_at(pos)
	zone.player.position = pos
	zone._spawn_grace = 100000.0
	zone._invulnerable = 100000.0
	zone._bridge_exit_armed = false
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
			# step sideways round whatever blocks the straight line (a post, a chef, a stage's edge)
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
	if off >= radius and "buf" in scene:
		var near: PackedStringArray = PackedStringArray()
		for list: Variant in (scene.buf as BuffetBuilder)._buckets.values():
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
	await driver.frames(3)
	get_tree().quit(0 if ok else 1)
