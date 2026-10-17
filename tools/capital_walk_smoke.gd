class_name CapitalWalkSmoke
extends Node
## The Capital layout pass (docs/art/capital_slice.md): walk the whole zone with human-style input (real injected keys), windowed.
## OUTSIDE: arrival on the Gate Road facing north and the walk up the road toward the great gate (the castle over it); the gate captain and his
## guards, Kestrel at the resistance camp, the Old Service Tunnels' mouth (E asks to enter the mini dungeon), the rift fields (a rift-stone and the
## hidden service shaft's prompt), then along the outside's west edge and through the hidden hole in the west wall on foot with the gate shut. INSIDE: the Gate Plaza's booth and complaint
## box, the palace approach's citizen, door, loudspeaker and portrait, every district's quest giver and objects (Fern, Widow Pell and the permit
## window, Rollo and a wheel crew, Chef Marlo, the Correction Ward's window and patient), the castle door at the stair's foot (E asks to enter
## Primm's Castle, node-based), a hidden chest; then, the gate open, back out through it and down the Gate Road to the way home.
## Screenshots to _screenshots/capital_walk/. CAPITAL_WALK_CAMERA=0|1|2 picks the camera angle (Cinematic, Classic, Overview).
##   Godot --path . --resolution 1600x900 res://tools/capital_walk_smoke_launcher.tscn     (bash tools/run_capital_walk_smoke.sh [camera])
## Deliberate shortcuts: long legs across the map are a teleport to a few metres short of the target, then real walking for the last stretch (the
## walkability probe covers the long routes); the battles, the quests' steps and the hideout have their own tests and smokes.

const SHOT_DIR: String = "res://_screenshots/capital_walk/"
const TAG: String = "capital_walk_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var camera: String = OS.get_environment("CAPITAL_WALK_CAMERA")
	if camera != "":
		Settings.set_camera_angle(int(camera))
	print("%s: camera angle %d" % [TAG, Settings.camera_angle])
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	if OS.get_environment("CAPITAL_WALK_ONLY") == "restored":
		# CAPITAL_WALK_ONLY=restored: just the second visit (a quicker check of the districts restored)
		await _the_districts_restored()
		_finish(_failures.is_empty(), "the districts restored (%d screenshots)" % _shots)
		return
	Session.enter_zone(CapitalZone.ID)
	var zone: CapitalScene = await _wait_for(CapitalScene) as CapitalScene
	if zone == null:
		_finish(false, "the Capital never loaded")
		return
	await driver.seconds(3.5)  # the zone title card
	await _dismiss_dialogue(zone.dialogue)
	# the roaming enemies hold still at their homes (they bumped the hero off the scripted lines; the battles have their own smokes)
	for enemy: ZoneEnemy in zone.enemies:
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
	await _arrival_on_the_gate_road(zone)
	await _outside(zone)
	await _through_the_passage(zone)
	await _inside(zone)
	await _the_castle_door(zone)
	await _save_and_load()
	await _back_out_through_the_gate(zone)
	await _the_districts_restored()
	_finish(_failures.is_empty(), "Gate Road -> gate, camp, tunnels, outpost, rift fields (a rift sealed) -> the west strip and the hidden hole -> plaza, approach, the five districts, the Ward -> the castle door -> save/load -> through the gate -> town -> back with the four Paths freed: every district restored and welcomed (%d screenshots)" % _shots)


# ---- Legs ----------------------------------------------------------------------------------------------------------


func _arrival_on_the_gate_road(zone: CapitalScene) -> void:
	var pos: Vector3 = zone.player.position
	var area: CapitalLayout.Area = zone.capital.layout.area_at(pos.x, pos.z)
	_check(area != null and area.id == "gate", "arrival: the hero starts on the Gate Road (%.0f, %.0f)" % [pos.x, pos.z])
	_check(zone.capital.landmarks.has("castle") and (zone.capital.landmarks["castle"] as Node3D).visible, "arrival: Primm's Castle stands at the city's heart")
	await _shot("w_01_arrival_on_the_gate_road")
	await _walk_to(zone, Vector3(60.0, 0.0, 86.0), 2.0, 22.0)
	await _shot("w_02_up_the_road_to_the_gate")
	_check(not zone._is_inside(zone.player.position), "the closed gate keeps the hero outside")


func _outside(zone: CapitalScene) -> void:
	await _use_spot(zone, "spotless", "w_03_captain_spotless")
	await _use_spot(zone, "guard_height", "w_04_height_inspection")
	await _use_spot(zone, "kestrel", "w_05_kestrel_at_the_camp")
	await _use_spot(zone, "old_tunnels", "w_06_old_service_tunnels")
	# the rift-stone: its prompt comes up (E would start the guardian fight while the guardian stands; sealing is unit-tested)
	var stone: ZoneSpot = _spot(zone, "seal_out_a")
	if stone != null:
		_teleport(zone, stone.position + Vector3(0.0, 0.0, 3.0))
		await _walk_to(zone, stone.position + Vector3(0.0, 0.0, 0.8), 0.9, 6.0)
		await _dismiss_dialogue(zone.dialogue)
		await driver.frames(4)
		_check(zone._near == stone, "the rift-stone: its prompt is up (near %s)" % (zone._near.id if zone._near != null else "nothing"))
		await _shot("w_07_rift_stone")
	# sealing a rift (the art pass): its guardian counted as beaten (the battles have their own smokes), E at the stone seals it and the tear collapses
	if stone != null:
		var rift_id: String = str(stone.data.get("rift", "out_a"))
		Session.zone_run.mark_defeated(CapitalLayout.guardian_id(rift_id))
		await _walk_to(zone, stone.position + Vector3(0.0, 0.0, 0.8), 0.9, 4.0)
		await driver.frames(4)
		await driver.tap_key(KEY_E)
		await driver.seconds(1.4)
		_check(CapitalRifts.is_sealed(Session.flags, rift_id), "the rift-stone: E seals rift %s once its guardian is beaten" % rift_id)
		_check(not zone.capital.rift_nodes.has(rift_id), "the sealed rift's tear collapses")
		await _shot("w_07b_a_rift_sealed")
		await _close_everything(zone)
	# the ruined outpost: the broken watchtower with the four Paths' banner
	_teleport(zone, Vector3(92.0, 0.0, 112.0))
	await _walk_to(zone, Vector3(92.0, 0.0, 108.5), 1.0, 6.0)
	var outpost: CapitalLayout.Area = zone.capital.layout.area_at(zone.player.position.x, zone.player.position.z)
	_check(outpost != null and outpost.id == "outpost", "the ruined outpost: walked to the watchtower")
	await _shot("w_06b_the_ruined_outpost")
	# the hidden service shaft: no plate, but the prompt comes up when the hero stands on it (E is not pressed: it leads to the Crease)
	var shaft: ZoneSpot = _spot(zone, "tunnel_in")
	if shaft != null:
		_teleport(zone, shaft.position + Vector3(2.5, 0.0, 0.0))
		await _walk_to(zone, shaft.position + Vector3(0.6, 0.0, 0.0), 0.9, 6.0)
		await driver.frames(4)
		_check(zone._near == shaft, "the hidden shaft: its prompt comes up on the spot (near %s)" % (zone._near.id if zone._near != null else "nothing"))


## The hidden way in (the Capital pass, Part D): from the rift fields round the front wall's west end, north up the narrow strip along the city's
## west wall and through the small hole at its foot, all on foot with the gate shut.
func _through_the_passage(zone: CapitalScene) -> void:
	var hole_z: float = float(CapitalLayout.HOLE_Z0) + float(CapitalLayout.HOLE_W) * 0.5
	_teleport(zone, Vector3(6.0, 0.0, 84.0))
	await driver.frames(4)
	for leg: Vector3 in [Vector3(3.0, 0.0, 78.0), Vector3(-3.5, 0.0, 78.0), Vector3(-3.5, 0.0, 66.0)]:
		await _walk_to(zone, leg, 0.9, 12.0)
	_check(not zone._is_inside(zone.player.position) and zone.player.position.z < float(CapitalLayout.WALL_Z0), "the west edge: walked up the strip outside the city's west wall")
	await _shot("w_08a_the_west_strip")
	await _walk_to(zone, Vector3(-3.5, 0.0, hole_z), 0.7, 10.0)
	await _walk_to(zone, Vector3(4.0, 0.0, hole_z), 0.9, 10.0)
	await driver.seconds(1.4)
	_check(zone._is_inside(zone.player.position), "the hidden hole: walked into the city with the gate shut")
	_check(Session.found_secret(CapitalScene.WALL_PASSAGE_SECRET), "the hidden hole: the secret is found")
	await _dismiss_dialogue(zone.dialogue)
	await _shot("w_08_through_the_hidden_hole")


func _inside(zone: CapitalScene) -> void:
	_teleport(zone, Vector3(CapitalLayout.PLAZA_CENTER.x - 6.0, 0.0, CapitalLayout.PLAZA_CENTER.y + 8.0))
	await driver.seconds(1.0)
	await _shot("w_09_the_gate_plaza")
	await _use_spot(zone, "exit_booth", "w_10_exit_interview_booth")
	await _use_spot(zone, "complaint_1", "w_11_complaint_box")
	await _use_spot(zone, "citizen_1", "w_12_a_citizen")
	await _use_spot(zone, "door_1", "w_13_a_perfect_door")
	await _use_spot(zone, "speaker_1", "w_14_a_loudspeaker")
	await _use_spot(zone, "portrait_f1", "w_15_a_portrait")
	await _use_spot(zone, "fern", "w_16_old_fern_in_the_reek")
	await _use_spot(zone, "pell", "w_17_widow_pell_in_grave_row")
	await _use_spot(zone, "permit_window", "w_18_the_permit_window")
	await _use_spot(zone, "rollo", "w_19_rollo_in_the_transit_yards")
	await _use_spot(zone, "wheel_2", "w_20_a_wheel_crew")
	await _use_spot(zone, "marlo", "w_21_chef_marlo_in_the_hungry_quarter")
	await _use_spot(zone, "ward_window", "w_22_the_correction_ward")
	await _use_spot(zone, "ward_patient", "w_23_a_corrected_citizen")
	# a hidden chest: the prompt comes up beside it
	var chest: Vector3 = zone.capital.layout.chests["chest_facade_back"] as Vector3
	_teleport(zone, chest + Vector3(0.0, 0.0, 3.0))
	await _walk_to(zone, chest + Vector3(0.0, 0.0, 1.0), 0.8, 6.0)
	await driver.frames(4)
	_check(str(zone.hud._prompt_label.text) != "", "a hidden chest: its prompt comes up beside it (%s)" % str(zone.hud._prompt_label.text))
	await _shot("w_24_a_hidden_chest")


func _the_castle_door(zone: CapitalScene) -> void:
	var door: Vector3 = zone.builder.anchor("castle_door")
	_teleport(zone, Vector3(door.x, 0.0, door.z + 14.0))
	await _walk_to(zone, door + Vector3(0.0, 0.0, 1.0), 1.4, 12.0)
	await _dismiss_dialogue(zone.dialogue)
	await driver.frames(4)
	_check(zone._near != null and zone._near.kind == "main_dungeon", "the castle door: the prompt is up at the stair's foot (near %s)" % (zone._near.id if zone._near != null else "nothing"))
	await _shot("w_25_the_castle_door")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.7)
	var asked: bool = driver.find_button("Not yet") != null or zone.dialogue.active or zone._overlay != null
	_check(asked, "the castle door: E asks to enter Primm's Castle (its node map)")
	await _shot("w_26_enter_primms_castle")
	await _close_everything(zone)
	_check(not zone._locked and not zone.dialogue.active, "the castle door: the hero is given back")


func _back_out_through_the_gate(zone: CapitalScene) -> void:
	Session.set_flag(CapitalZone.FLAG_GATE_OPEN)
	zone.capital.open_gate()
	await driver.seconds(1.6)
	_teleport(zone, Vector3(60.0, 0.0, 64.0))
	await driver.frames(4)
	await _walk_to(zone, Vector3(60.0, 0.0, 84.0), 1.6, 18.0)
	await driver.seconds(1.4)
	_check(not zone._is_inside(zone.player.position), "the open gate: walked back out onto the Gate Road")
	await _dismiss_dialogue(zone.dialogue)
	await _shot("w_27_out_through_the_gate")
	var exit: ZoneSpot = _spot(zone, "exit")
	_teleport(zone, exit.position + Vector3(0.0, 0.0, -6.0))
	await _walk_to(zone, exit.position + Vector3(0.0, 0.0, -0.6), 0.9, 10.0)
	await _dismiss_dialogue(zone.dialogue)
	await driver.frames(4)
	_check(zone._near == exit, "the way home: the prompt is up at the road's end")
	await _shot("w_28_the_road_home")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	var leave: Button = driver.find_button("Leave")
	_check(leave != null, "the way home: E asks to leave (Leave / Stay)")
	if leave != null:
		await driver.click_button("Leave")
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "the road home leads back to town")
	if town != null:
		await driver.seconds(0.8)
		await _shot("w_29_back_in_town")


## A manual save in the Capital (a slot in a throwaway folder) and the load back: the gold and the flags come back as saved.
func _save_and_load() -> void:
	SaveSlots.dir = "%s/capital_walk_smoke_saves/" % OS.get_user_data_dir()
	var gold: int = Session.gold
	_check(Session.save_to_slot(3, "capital walk smoke"), "save/load: a manual save in the Capital")
	Session.gold = gold + 321
	Session.set_flag("capital_walk_smoke_after_save")
	_check(Session.load_from_slot(3), "save/load: the slot loads back")
	_check(Session.gold == gold and not Session.flag(&"capital_walk_smoke_after_save"), "save/load: the gold (%d) and the flags are as saved" % Session.gold)
	await driver.frames(10)


## Back in the Capital with the four Paths freed (debug flags): each district is built restored and its first visit is welcomed (the lights, the
## Path's sting, the citizens), once.
func _the_districts_restored() -> void:
	# the completion flags only (debug flags: Session.complete_zone also plays the town's own freed-zone events, which held the smoke in town)
	for path: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		Session.set_flag(ZoneCompletion.flag_name(path))
	Session.set_flag(CapitalZone.FLAG_GATE_OPEN)
	Session.enter_zone(CapitalZone.ID)
	var zone: CapitalScene = await _wait_for(CapitalScene) as CapitalScene
	_check(zone != null, "the Capital again, the four Paths freed")
	if zone == null:
		return
	await driver.frames(200)
	# a reward box (the level gained from the sealed rift) pauses the game on arrival: the driver's timers stop while paused, so it is closed with keys
	# and frame waits (it takes Enter / Space / E)
	await _unpause()
	_check(not get_tree().paused, "back in the Capital: nothing holds the game paused")
	await _close_everything(zone)
	await _dismiss_dialogue(zone.dialogue)
	await _close_everything(zone)
	print("%s: note  back in the Capital (dialogue %s, locked %s)" % [TAG, str(zone.dialogue.active), str(zone._locked)])
	for enemy: ZoneEnemy in zone.enemies:
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
	var cameras: Dictionary = {"transit": "po_transit_yards", "hungry": "po_hungry_quarter", "grave": "po_grave_row", "reek": "po_the_reek"}
	for district: String in cameras.keys():
		await _unpause()
		await _close_everything(zone)
		var at: Vector2 = CapitalLayout.PO_CAMERAS[cameras[district]] as Vector2
		_teleport(zone, Vector3(at.x, 0.0, at.y + 3.0))
		await _walk_to(zone, Vector3(at.x, 0.0, at.y), 0.8, 6.0)
		await driver.seconds(1.2)
		_check(Session.flag(CapitalScene.welcome_flag(district)), "%s restored: the first visit is welcomed" % district)
		await _shot("w_30_%s_restored" % district)
		await driver.seconds(2.6)
		await _dismiss_dialogue(zone.dialogue)
	_check(not zone.capital.district_lights.is_empty(), "the restored districts have their lights")


# ---- Helpers ----------------------------------------------------------------------------------------------------


## Closes the reward boxes that hold the game on arrival (the level-up screens come one after another, "1 of 3 levels gained"; ESC on one
## opens the pause menu): Enter while one is up or the game is paused, frame waits only (the driver's timers stop while paused), until the game has
## run free for a full second or about twenty seconds have passed.
func _unpause() -> void:
	var calm: int = 0
	var frames: int = 0
	while calm < 60 and frames < 1200:
		frames += 1
		if get_tree().paused or driver.find_button("Continue") != null:
			calm = 0
			if frames % 20 == 0:
				await driver.tap_key(KEY_ENTER)
				continue
		else:
			calm += 1
		await driver.frames(1)


## Walk up to a spot, check its prompt, press E, then close whatever opened (a talk, a shop, a confirm box, a toast) and check the hero is free again.
func _use_spot(zone: CapitalScene, id: String, shot_name: String) -> void:
	var spot: ZoneSpot = _spot(zone, id)
	_check(spot != null, "%s: the spot exists" % id)
	if spot == null:
		return
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
	# the facade citizens stroll within 3 m of their spot: if one has wandered off, follow it
	var tries: int = 0
	while zone._near != spot and tries < 4 and zone._npcs.has(id):
		tries += 1
		await _walk_to(zone, spot.position + Vector3(0.0, 0.0, 0.9), 1.0, 4.0)
		await driver.frames(4)
	_check(zone._near == spot, "%s: the prompt is up (near %s)" % [id, zone._near.id if zone._near != null else "nothing"])
	await driver.tap_key(KEY_E)
	await driver.seconds(0.7)
	var opened: bool = zone.dialogue.active or zone._overlay != null or str(zone.hud._toast.text) != "" or zone._locked or driver.find_button("Not yet") != null
	_check(opened, "%s: E does something (a talk, a screen, a box or a toast)" % id)
	await _shot(shot_name)
	await _close_everything(zone)
	_check(not zone._locked and zone._overlay == null and not zone.dialogue.active, "%s: the hero is given back" % id)


func _close_everything(zone: CapitalScene) -> void:
	var guard: int = 0
	while (zone.dialogue.active or zone._overlay != null or zone._locked or driver.find_button("Not yet") != null) and guard < 16:
		guard += 1
		var cancel: Button = null
		for label: String in ["Not yet", "Close", "Leave it", "Not now", "No", "Cancel"]:
			cancel = driver.find_button(label)
			if cancel != null:
				break
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


func _spot(zone: CapitalScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	return null


func _teleport(zone: CapitalScene, pos: Vector3) -> void:
	pos.y = zone.builder.height_at(pos)
	zone.player.position = pos
	zone._spawn_grace = 100000.0
	zone._invulnerable = 100000.0
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
	if off >= radius:
		print("%s: note  stuck at (%.1f, %.1f)" % [TAG, player.position.x, player.position.z])
		player.position = target
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
