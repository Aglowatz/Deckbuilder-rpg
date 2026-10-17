class_name HeapWalkSmoke
extends Node
## The Verdant Dump slice, Part A: walk the whole zone with human-style input (real injected keys and clicks), windowed.
## Arrival on the entrance bridge and the walk north into the Compost Commons; every quest NPC and the vendor (E opens their talk / shop); the Harvest
## Meal, the compost bin, the druid shrine, the trough, the boar stable (mount, then Q); the quiz master, Recycle Rhonda's fair and the Seed Shrine on
## Rust Peak; the Landfill Depths door at the Trash Panda Throne (sealed: the hook; unlocked: E asks to enter the side dungeon) and the Rotheart's root
## gate (prompt, no lettered plate, E asks); the giant chest and the vault lever (prompts up); then back out over the bridge to town by walking off its
## far end. Screenshots to _screenshots/heap_walk/. HEAP_WALK_CAMERA=0|1|2 picks the camera angle (Cinematic, Classic, Overview).
##   Godot --path . --resolution 1600x900 res://tools/heap_walk_smoke_launcher.tscn     (bash tools/run_heap_walk_smoke.sh [camera])
## Deliberate shortcuts: long legs across the map are a teleport to a few metres short of the target, then real walking for the last stretch (the
## walkability probe covers the long routes); the vine bridges, the beanstalks, the chutes, the battles, the quiz questions and the puzzle moves have
## their own smoke (tools/run_eighth_brief_final_smoke.sh). Exit code 0 = every check passed; 1 = a check failed.

const SHOT_DIR: String = "res://_screenshots/heap_walk/"
const TAG: String = "heap_walk_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.REFUSEMANCER)
	Session.set_flag(CorruptedNpcs.unlock_flag(HeapZone.ID))
	var camera: String = OS.get_environment("HEAP_WALK_CAMERA")
	if camera != "":
		Settings.set_camera_angle(int(camera))
	print("%s: camera angle %d" % [TAG, Settings.camera_angle])
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	Session.enter_zone(HeapZone.ID)
	var zone: HeapScene = await _wait_for(HeapScene) as HeapScene
	if zone == null:
		_finish(false, "the Verdant Dump never loaded")
		return
	await driver.seconds(3.5)  # the zone title card
	await _dismiss_dialogue(zone.dialogue)
	# everything grown and smashed for the walk (the growth and the barricades are unit-tested and played by the eighth brief smoke)
	for growth: HeapGrowth.Growth in HeapGrowth.all():
		Session.set_flag(growth.flag)
		if growth.kind == "bridge":
			zone.heap.set_bridge_progress(growth.id, 1.0)
		else:
			zone.heap.set_ladder_progress(growth.id, 1.0)
	for barricade: HeapGrowth.Barricade in HeapGrowth.barricades():
		Session.set_flag(barricade.flag)
		zone.heap.smash_barricade(barricade.id)
	await _arrival_over_the_bridge(zone)
	await _the_people_and_the_things(zone)
	await _the_games(zone)
	await _the_dungeons(zone)
	await _the_chest_and_the_lever(zone)
	await _back_out_over_the_bridge(zone)
	_finish(_failures.is_empty(), "bridge -> plaza -> NPCs, vendor, interactables, the boar -> quiz, the fair, the Seed Shrine -> the Landfill Depths door at the throne, the Rotheart's root gate -> giant chest, lever -> bridge -> town (%d screenshots)" % _shots)


# ---- Legs ----------------------------------------------------------------------------------------------------------


func _arrival_over_the_bridge(zone: HeapScene) -> void:
	var pos: Vector3 = zone.player.position
	_check(HeapLayout.on_entrance(pos.x, pos.z), "arrival: the hero starts on the bridge (%.0f, %.0f)" % [pos.x, pos.z])
	await _shot("w_01_arrival_on_the_bridge")
	var hub: Vector3 = zone.builder.anchor("hub")
	await _walk_to(zone, Vector3(hub.x, 0.0, hub.z), 2.0, 16.0)
	pos = zone.player.position
	_check(not HeapLayout.on_entrance(pos.x, pos.z), "arrival: walked north off the bridge into the Compost Commons")
	var off_centre: float = Vector2(pos.x - HeapLayout.PLAZA_CENTER.x, pos.z - HeapLayout.PLAZA_CENTER.y).length()
	_check(off_centre < HeapLayout.PLAZA_RADIUS + 1.0, "arrival: standing in the plaza (%.1f m from the greenhouse)" % off_centre)
	_check(zone.heap.rotheart != null and zone.heap.rotheart.visible, "arrival: the Rotheart stands on the skyline")
	await _shot("w_02_the_compost_commons")


## Each NPC and interactable: walk up, the prompt is up, E does its thing, the hero is given back.
func _the_people_and_the_things(zone: HeapScene) -> void:
	await _use_spot(zone, "marigold", "w_03_brother_bramble", true)
	await _use_spot(zone, "hob", "w_04_granny_gristle", true)
	await _use_spot(zone, "wren", "w_05_wren_muckfoot", true)
	await _use_spot(zone, "heal", "w_06_harvest_meal", false)
	HeapInteractables.give("junk", 6)
	await _use_spot(zone, "compost_bin", "w_07_compost_bin", false)
	await _use_spot(zone, "shrine", "w_08_druid_shrine", false)
	await _use_spot(zone, "trough", "w_09_feeding_trough", false)
	await _use_spot(zone, "stable_1", "w_10_boris_the_boar", false)
	_check(zone.is_riding(), "the boar: E mounts it")
	await driver.tap_key(KEY_Q)
	await driver.seconds(0.5)
	_check(not zone.is_riding(), "the boar: Q dismounts")


func _the_games(zone: HeapScene) -> void:
	await _use_spot(zone, "quiz", "w_11_druid_thistlewick", true)
	await _use_spot(zone, "minigame", "w_12_recycle_rhonda", true)
	await _use_spot(zone, "puzzle", "w_13_seed_shrine", true)


func _the_dungeons(zone: HeapScene) -> void:
	# the Landfill Depths door at the throne's steps: sealed, it drops the Trash Panda Throne's hook; unlocked, E asks to enter (the side dungeon is node-based)
	var door: ZoneSpot = _spot(zone, "mini_dungeon")
	_check(door != null, "the Landfill Depths door exists")
	if door != null:
		_teleport(zone, door.position + Vector3(0.0, 0.0, 5.0))
		await _walk_to(zone, door.position + Vector3(0.0, 0.0, 0.6), 1.2, 8.0)
		await _dismiss_dialogue(zone.dialogue)
		await driver.frames(4)
		_check(zone._near == door, "the Landfill Depths: the door prompt is up (near %s)" % (zone._near.id if zone._near != null else "nothing"))
		_check(not door.plate.visible, "the Landfill Depths: no lettered plate (the board carries the icon)")
		_check(zone.heap.landmarks.has("DUMP-HERO-TRASH-PANDA-THRONE"), "the Trash Panda Throne stands over the door")
		await _shot("w_14_landfill_depths_door")
		await driver.tap_key(KEY_E)
		await driver.seconds(0.6)
		_check(not Session.side_unlocked("S-REF") and zone._overlay == null and str(zone.hud._toast.text).to_lower().contains("sealed"), "the Landfill Depths: sealed until its quest, the door says so")
		Session.set_flag(DungeonCatalog.side_unlock_flag("S-REF"))
		await driver.seconds(0.4)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.6)
		var not_yet: Button = driver.find_button("Not yet")
		_check(not_yet != null, "the Landfill Depths: unlocked, E asks to enter the Trash Panda Throne (its node map)")
		await _shot("w_15_trash_panda_throne_ask")
		if not_yet != null:
			await driver.click_button("Not yet")
			await driver.seconds(0.4)
		_check(not zone._locked, "the Landfill Depths: the hero is given back")
	# the Rotheart at its root gate
	var entrance: Vector3 = zone.builder.anchor("main_dungeon")
	_teleport(zone, Vector3(entrance.x, 0.0, entrance.z + 7.0))
	await _walk_to(zone, entrance + Vector3(0.0, 0.0, 1.2), 1.2, 8.0)
	await _dismiss_dialogue(zone.dialogue)
	await driver.frames(4)
	_check(zone._near != null and zone._near.kind == "main_dungeon", "the Rotheart: the gate prompt is up (near %s)" % (zone._near.id if zone._near != null else "nothing"))
	_check(zone._near != null and not zone._near.plate.visible, "the Rotheart: no lettered plate at the gate")
	await _shot("w_16_rotheart_root_gate")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	var not_yet_root: Button = driver.find_button("Not yet")
	_check(not_yet_root != null, "the Rotheart: E asks to enter the dungeon (the entrance still works)")
	await _shot("w_17_rotheart_ask")
	if not_yet_root != null:
		await driver.click_button("Not yet")
		await driver.seconds(0.4)
	_check(not zone._locked, "the Rotheart: Not yet gives the hero back")


func _the_chest_and_the_lever(zone: HeapScene) -> void:
	for key: String in ["giant_chest", "vault_lever"]:
		var pos: Vector3 = zone.builder.anchor(key)
		# both stand near the land's south edge: approach from the north
		_teleport(zone, pos + Vector3(0.0, 0.0, -5.0))
		await _walk_to(zone, pos + Vector3(0.0, 0.0, -1.6), 1.0, 8.0)
		await _dismiss_dialogue(zone.dialogue)
		await driver.frames(4)
		var prompt: String = str(zone.hud._prompt_label.text)
		_check(prompt != "", "%s: a prompt is up when the hero walks up (%s)" % [key, prompt])
		await _shot("w_18_%s" % key)
	# save and load in the Dump (a slot in a throwaway folder): the run's gold, flags and the zone visit come back
	SaveSlots.dir = "%s/heap_walk_smoke_saves/" % OS.get_user_data_dir()
	var gold: int = Session.gold
	_check(Session.save_to_slot(3, "heap walk smoke"), "save/load: a manual save in the Verdant Dump")
	Session.gold = gold + 321
	Session.set_flag("heap_walk_smoke_after_save")
	_check(Session.load_from_slot(3), "save/load: the slot loads back")
	_check(Session.gold == gold and not Session.flag(&"heap_walk_smoke_after_save"), "save/load: the gold (%d) and the flags are as saved" % Session.gold)
	await driver.frames(10)


func _back_out_over_the_bridge(zone: HeapScene) -> void:
	var hub: Vector3 = zone.builder.anchor("hub")
	_teleport(zone, Vector3(hub.x, 0.0, hub.z))
	await driver.frames(4)
	# walk south onto the bridge, down it and off its far end: no prompt needed
	await _walk_to(zone, zone.builder.anchor("spawn"), 1.6, 14.0)
	_check(HeapLayout.on_entrance(zone.player.position.x, zone.player.position.z), "leaving: back on the bridge")
	await _shot("w_19_leaving_over_the_bridge")
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
		await _shot("w_20_back_in_town")


# ---- Helpers -------------------------------------------------------------------------------------------------------


## Walk up to a spot, check its prompt, press E, then close whatever opened (a talk, a shop, a game screen, a toast) and check the hero is free again.
func _use_spot(zone: HeapScene, id: String, shot_name: String, opens_screen: bool) -> void:
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
	var opened: bool = zone.dialogue.active or zone._overlay != null or str(zone.hud._toast.text) != "" or zone._locked or zone.is_riding()
	_check(opened, "%s: E does something (a talk, a screen or a toast)" % id)
	await _shot(shot_name)
	# close it again: talks with E, screens with Escape, confirm boxes with their Not yet / Close buttons
	var guard: int = 0
	while (zone.dialogue.active or zone._overlay != null or zone._locked) and guard < 14:
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


func _spot(zone: HeapScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	return null


func _teleport(zone: HeapScene, pos: Vector3) -> void:
	pos.y = zone.builder.height_at(pos)
	zone.player.position = pos
	zone.last_safe = pos
	zone._spawn_grace = 100000.0
	zone._invulnerable = 100000.0
	zone._entrance_exit_armed = false
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
			# step sideways round whatever blocks the straight line (a post, an NPC, a prop's edge)
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
	if off >= radius and "heap" in scene:
		var near: PackedStringArray = PackedStringArray()
		for list: Variant in (scene.heap as HeapBuilder)._buckets.values():
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
	# Sound pass: what was heard on the walk (footsteps by surface, interactions, the ambience profiles) and anything with no sound.
	print("%s: sounds %s" % [TAG, str(Audio.play_counts)])
	print("%s: ambience %s" % [TAG, str(Audio.ambience.area_history)])
	print("%s: missing sounds %s" % [TAG, str(Audio.missing_log)])
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	await driver.frames(3)
	get_tree().quit(0 if ok else 1)
