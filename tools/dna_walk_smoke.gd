class_name DnaWalkSmoke
extends Node
## D.N.A. slice, Part E: walk the whole zone with human-style input (real injected keys and clicks), windowed.
## Arrival on the approach causeway and the walk through the gate into the Lobby Plaza; every quest NPC and the vendor (E opens their talk / shop); the coffee
## machine, the time clock, the suggestion box and the haunted printer; the quiz master, the matching game and the routing puzzle (E opens them); Sub-Basement 3
## (the mini dungeon asks to enter); the Hall of Final Approvals at the stair's foot (prompt, no lettered plate, E asks); the giant chest and the vault lever
## (prompts up); every sub-area through its gates and exits (Cubicle Fields -> The Queue -> Records Basement -> Executive Approach -> Records Basement -> hub);
## then back out down the causeway to town by simply walking off its end. Screenshots to _screenshots/dna_walk/.
##   Godot --path . --resolution 1600x900 res://tools/dna_walk_smoke_launcher.tscn     (bash tools/run_dna_walk_smoke.sh)
## Deliberate shortcuts: long legs across the map are a teleport to a few metres short of the target, then real walking for the last stretch (the walkability probe
## covers the long routes); the battles, the quiz questions and the puzzle moves have their own smoke (tools/run_fifth_brief_final_smoke.sh).
## Exit code 0 = every check passed; 1 = a check failed.

const SHOT_DIR: String = "res://_screenshots/dna_walk/"
const TAG: String = "dna_walk_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)
	Session.set_flag(CorruptedNpcs.unlock_flag(DnaZone.ID))
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	Session.enter_zone(DnaZone.ID)
	var zone: DnaScene = await _wait_for(DnaScene) as DnaScene
	if zone == null:
		_finish(false, "the D.N.A. never loaded")
		return
	await driver.seconds(3.5)  # the zone title card
	await _dismiss_dialogue(zone.dialogue)
	await _arrival_on_the_causeway(zone)
	await _the_people_and_the_things(zone)
	await _the_games(zone)
	await _the_dungeons(zone)
	await _the_chest_and_the_lever(zone)
	zone = await _every_sub_area(zone)
	if zone != null:
		await _back_out_down_the_causeway(zone)
	_finish(_failures.is_empty(), "causeway -> gate -> lobby -> NPCs, vendor, interactables -> quiz, matching, puzzle -> Sub-Basement 3, the Hall -> giant chest, lever -> Cubicle Fields -> The Queue -> Records Basement -> Executive Approach -> Records Basement -> hub -> causeway -> town (%d screenshots)" % _shots)


# ---- Legs ----------------------------------------------------------------------------------------------------------


func _arrival_on_the_causeway(zone: DnaScene) -> void:
	var pos: Vector3 = zone.player.position
	_check(DnaLayout.on_approach(pos.x, pos.z), "arrival: the hero starts on the approach causeway (%.0f, %.0f)" % [pos.x, pos.z])
	await _shot("w_01_arrival_on_the_causeway")
	var centre: Vector3 = zone.builder.anchor("lobby_center")
	await _walk_to(zone, Vector3(centre.x, 0.0, centre.z + 1.0), 2.0, 16.0)
	pos = zone.player.position
	_check(Vector2(pos.x - centre.x, pos.z - centre.z).length() < 4.5, "arrival: walked north through the gate into the Lobby Plaza (%.1f m from its centre)" % Vector2(pos.x - centre.x, pos.z - centre.z).length())
	_check(not DnaLayout.on_approach(pos.x, pos.z), "arrival: standing in the lobby")
	await _shot("w_02_the_lobby_plaza")


## Each NPC and interactable: walk up, the prompt is up, E does its thing, the hero is given back.
func _the_people_and_the_things(zone: DnaScene) -> void:
	await _use_spot(zone, "dolores", "w_03_agnes", true)
	await _use_spot(zone, "pip", "w_04_requisitions", true)
	await _use_spot(zone, "barnaby", "w_05_gerald", true)
	await _use_spot(zone, "coffee", "w_06_coffee", false)
	await _use_spot(zone, "time_clock", "w_07_time_clock", false)
	await _use_spot(zone, "suggestion", "w_08_suggestion_box", false)
	await _use_spot(zone, "printer", "w_09_printer", false)
	await _use_spot(zone, "heal", "w_10_couch", false)


func _the_games(zone: DnaScene) -> void:
	await _use_spot(zone, "quiz", "w_11_quiz", true)
	await _use_spot(zone, "matching", "w_12_matching", true)
	await _use_spot(zone, "puzzle", "w_13_puzzle", true)


func _the_dungeons(zone: DnaScene) -> void:
	# Sub-Basement 3: the elevator asks to enter (or says it is sealed until its quest)
	var mini: ZoneSpot = _spot(zone, "mini_dungeon")
	if mini != null:
		_teleport(zone, mini.position + Vector3(0.0, 0.0, 5.0))
		await _walk_to(zone, mini.position + Vector3(0.0, 0.0, 1.0), 1.2, 8.0)
		await _dismiss_dialogue(zone.dialogue)
		await driver.frames(4)
		_check(zone._near == mini, "Sub-Basement 3: the elevator prompt is up (near %s)" % (zone._near.id if zone._near != null else "nothing"))
		await _shot("w_14_sub_basement_3")
		await driver.tap_key(KEY_E)
		await driver.seconds(0.6)
		var not_yet: Button = driver.find_button("Not yet")
		_check(not_yet != null or str(zone.hud._toast.text).to_lower().contains("sealed"), "Sub-Basement 3: E asks to enter or says it is sealed")
		if not_yet != null:
			await driver.click_button("Not yet")
			await driver.seconds(0.4)
		_check(not zone._locked, "Sub-Basement 3: the hero is given back")
	# the Hall of Final Approvals at the foot of its stair
	var entrance: Vector3 = zone.builder.anchor("main_dungeon")
	_teleport(zone, Vector3(entrance.x, 0.0, entrance.z + 7.0))
	await _walk_to(zone, entrance + Vector3(0.0, 0.0, 1.0), 1.2, 8.0)
	await _dismiss_dialogue(zone.dialogue)
	await driver.frames(4)
	_check(zone._near != null and zone._near.kind == "main_dungeon", "the Hall: the entrance prompt is up at the stair foot (near %s)" % (zone._near.id if zone._near != null else "nothing"))
	_check(zone._near != null and not zone._near.plate.visible, "the Hall: no lettered plate at the entrance")
	_check(zone.dna.hall != null and zone.dna.hall.visible, "the Hall: the building stands beyond the stair")
	await _shot("w_15_hall_of_final_approvals")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	var not_yet_hall: Button = driver.find_button("Not yet")
	_check(not_yet_hall != null, "the Hall: E asks to enter the dungeon (the entrance still works)")
	await _shot("w_16_hall_ask")
	if not_yet_hall != null:
		await driver.click_button("Not yet")
		await driver.seconds(0.4)
	_check(not zone._locked, "the Hall: Not yet gives the hero back")


func _the_chest_and_the_lever(zone: DnaScene) -> void:
	for key: String in ["giant_chest", "vault_lever"]:
		var pos: Vector3 = zone.builder.anchor(key)
		_teleport(zone, pos + Vector3(5.0, 0.0, 0.0))
		await _walk_to(zone, pos + Vector3(1.5, 0.0, 0.0), 1.0, 8.0)
		await _dismiss_dialogue(zone.dialogue)
		await driver.frames(4)
		var prompt: String = str(zone.hud._prompt_label.text)
		_check(prompt != "", "%s: a prompt is up when the hero walks up (%s)" % [key, prompt])
		await _shot("w_17_%s" % key)


func _every_sub_area(zone: DnaScene) -> DnaScene:
	var gates: SubAreaGates = zone.find_child("SubAreaGates", true, false) as SubAreaGates
	_check(gates != null, "the hub shows its sub-area gates")
	if gates == null:
		return zone
	var cubicles: int = -1
	for i: int in range(gates.gates.size()):
		if str(gates.gates[i]["sub"]) == "cubicle_fields":
			cubicles = i
	_check(cubicles >= 0, "the Cubicle Fields gate is in the hub")
	if cubicles < 0:
		return zone
	var gate_pos: Vector3 = SubAreaMap.pos3(gates.gates[cubicles]["pos"])
	var hub_dir: Vector3 = (zone.builder.anchor("lobby_center") - gate_pos)
	hub_dir.y = 0.0
	hub_dir = hub_dir.normalized()
	_teleport(zone, gate_pos + hub_dir * 5.0)
	await _walk_to(zone, gate_pos + hub_dir * 1.4, 1.4, 8.0)
	await _dismiss_dialogue(zone.dialogue)
	await driver.frames(4)
	await _shot("w_18_cubicle_fields_gate")
	await driver.tap_key(KEY_E)
	var scene: SubAreaScene = await _wait_for(SubAreaScene) as SubAreaScene
	_check(scene != null and scene.sub_id == "cubicle_fields", "E at the gate loads the Cubicle Fields")
	if scene == null:
		return null
	await driver.seconds(0.8)
	await _shot("w_19_cubicle_fields")
	scene = await _take_exit(scene, "the_queue", "w_20_the_queue")
	if scene == null:
		return null
	scene = await _take_exit(scene, "records_basement", "w_21_records_basement")
	if scene == null:
		return null
	scene = await _take_exit(scene, "executive_approach", "w_22_executive_approach")
	if scene == null:
		return null
	scene = await _take_exit(scene, "records_basement", "w_23_records_basement_again")
	if scene == null:
		return null
	# the way home
	var exit_spot: Dictionary = _exit_to(scene, "hub")
	_check(not exit_spot.is_empty(), "Records Basement: has an exit back to the hub")
	if exit_spot.is_empty():
		return null
	var home_pos: Vector3 = exit_spot["pos"] as Vector3
	var home_inward: Vector3 = _inward(home_pos)
	_teleport_sub(scene, home_pos + home_inward * 5.0)
	await _walk_to(scene, home_pos + home_inward * 1.8, 1.0, 8.0)
	await driver.tap_key(KEY_E)
	var back: DnaScene = await _wait_for(DnaScene) as DnaScene
	_check(back != null, "the exit leads back to the hub")
	if back != null:
		await driver.seconds(0.6)
		await _dismiss_dialogue(back.dialogue)
		var basement_gate: Vector3 = Vector3(70.5, 0.0, 24.5)
		var pos: Vector3 = back.player.position
		_check(Vector2(pos.x - basement_gate.x, pos.z - basement_gate.z).length() < 12.0, "back in the hub beside the Records Basement gate (%.1f m)" % Vector2(pos.x - basement_gate.x, pos.z - basement_gate.z).length())
		await _shot("w_24_back_in_the_hub")
	return back


func _take_exit(scene: SubAreaScene, target: String, shot_name: String) -> SubAreaScene:
	var from_id: String = scene.sub_id
	var exit_spot: Dictionary = _exit_to(scene, target)
	_check(not exit_spot.is_empty(), "%s: has an exit to %s" % [from_id, target])
	if exit_spot.is_empty():
		return null
	var pos: Vector3 = exit_spot["pos"] as Vector3
	var inward: Vector3 = _inward(pos)
	_teleport_sub(scene, pos + inward * 5.0)
	await _walk_to(scene, pos + inward * 1.8, 1.0, 8.0)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	var next: SubAreaScene = await _wait_for_sub(target)
	_check(next != null, "%s: E at the exit loads %s" % [from_id, target])
	if next != null:
		await driver.seconds(0.8)
		_check(next.map.is_walkable(next.player.position, 0.3), "%s: the hero arrives on walkable ground" % target)
		await _shot(shot_name)
	return next


func _back_out_down_the_causeway(zone: DnaScene) -> void:
	var centre: Vector3 = zone.builder.anchor("lobby_center")
	_teleport(zone, Vector3(centre.x + 1.0, 0.0, centre.z + 4.0))
	await driver.frames(4)
	# walk south through the gate, down the causeway and off its far end: no prompt needed
	await _walk_to(zone, zone.builder.anchor("spawn"), 1.6, 14.0)
	await _shot("w_25_leaving_down_the_causeway")
	await _hold(KEY_S, true)
	var waited: float = 0.0
	while waited < 10.0 and get_tree().current_scene == zone:
		await driver.frames(3)
		waited += 3.0 / 60.0
	await _hold(KEY_S, false)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "walking off the far end of the causeway leads back to town")
	if town != null:
		await driver.seconds(0.8)
		await _shot("w_26_back_in_town")


# ---- Helpers -------------------------------------------------------------------------------------------------------


## Walk up to a spot, check its prompt, press E, then close whatever opened (a talk, a shop, a game screen, a toast) and check the hero is free again.
func _use_spot(zone: DnaScene, id: String, shot_name: String, opens_screen: bool) -> void:
	var spot: ZoneSpot = _spot(zone, id)
	_check(spot != null, "%s: the spot exists" % id)
	if spot == null:
		return
	# the spot itself is the counter, the desk or the bench: stand beside it on the first open side (south, north, east, west), walking the last metres
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
	var opened: bool = zone.dialogue.active or zone._overlay != null or str(zone.hud._toast.text) != ""
	_check(opened, "%s: E does something (a talk, a screen or a toast)" % id)
	await _shot(shot_name)
	# close it again: talks with E, screens with Escape, confirm boxes with their Not yet / Close buttons
	var guard: int = 0
	while (zone.dialogue.active or zone._overlay != null or zone._locked) and guard < 12:
		guard += 1
		var cancel: Button = driver.find_button("Not yet")
		if cancel == null:
			cancel = driver.find_button("Close")
		if cancel == null:
			cancel = driver.find_button("Leave it")
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
	await driver.seconds(0.3)
	_check(not zone._locked and zone._overlay == null and not zone.dialogue.active, "%s: the hero is given back (screen %s, locked %s)" % [id, str(opens_screen), str(zone._locked)])


func _spot(zone: DnaScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	return null


## The way to approach an exit on a sub-area edge: from the middle of the map (an exit stands at the edge, the far side is outside the map).
func _inward(pos: Vector3) -> Vector3:
	var flat: Vector3 = Vector3(-pos.x, 0.0, -pos.z)
	return flat.normalized() if flat.length() > 0.5 else Vector3(0.0, 0.0, -1.0)


func _exit_to(scene: SubAreaScene, target: String) -> Dictionary:
	for spot: Dictionary in scene.spots:
		if str(spot["type"]) == "exit" and str((spot["data"] as Dictionary).get("to", "hub")) == target:
			return spot
	return {}


func _teleport(zone: DnaScene, pos: Vector3) -> void:
	pos.y = zone.builder.height_at(pos)
	zone.player.position = pos
	zone._spawn_grace = 100000.0
	zone._invulnerable = 100000.0
	zone._camera.position = zone.player.position + CameraRig.shape(zone.camera_offset)


func _teleport_sub(scene: SubAreaScene, pos: Vector3) -> void:
	scene.player.position = pos


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 25.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _wait_for_sub(sub_id: String) -> SubAreaScene:
	var elapsed: float = 0.0
	while elapsed < 25.0:
		var scene: Node = get_tree().current_scene
		if scene is SubAreaScene and (scene as SubAreaScene).sub_id == sub_id and not SceneManager.busy:
			return scene as SubAreaScene
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
			# step sideways round whatever blocks the straight line (a lamp, a clerk, the station's edge)
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
	if off >= radius and "dna" in scene:
		var near: PackedStringArray = PackedStringArray()
		for list: Variant in (scene.dna as DnaBuilder)._buckets.values():
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
