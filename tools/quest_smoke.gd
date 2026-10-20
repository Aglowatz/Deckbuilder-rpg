class_name QuestSmoke
extends Node
## Overnight Oct 16, Block 1g: the quest overhaul with human-style input, windowed. In town: the tracker, the "!" over Brannoch, the objective
## marker over the Gainlands gatekeeper, the Quest Log (J) tabs and tracking with the keyboard. Then in two zones (the Gainlands and the
## D.N.A.): walk up to a quest giver (the "!" mark), accept with E, toggle the tracker with ] and [, finish the steps (debug flags: the
## minigames and roaming fights have their own smokes), see the "?" mark, and hand the quest in with E.
##   Godot --path . --resolution 1600x900 res://tools/quest_smoke_launcher.tscn     (bash tools/run_quest_smoke.sh)
## Exit code 0 = every check passed.

const SHOT_DIR: String = "res://_screenshots/quest_smoke/"
const TAG: String = "quest_smoke"

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
	SceneManager.go_to_town()
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.seconds(3.5)
	await _dismiss_dialogue(town.dialogue)
	await _town_leg(town)
	await _zone_leg(GainlandsZone.ID, GainlandsZone.QUEST_POWER, "gus", func() -> void:
		Session.set_flag(GainlandsZone.FLAG_WHEEL_POWERED)
		Session.bump_counter(GainlandsZone.COUNTER_SHAKES))
	await _zone_leg(DnaZone.ID, ZoneQuestDefinitions.ONBOARDING, "barnaby", func() -> void:
		Session.bump_counter(DnaZone.COUNTER_PUNCHED_IN)
		Session.bump_counter(DnaZone.COUNTER_COFFEE))
	_finish(_failures.is_empty(), "town tracker, markers and log; accept, track, toggle and hand in in the Gainlands and the D.N.A. (%d screenshots)" % _shots)


func _town_leg(town: TownScene) -> void:
	var qlog: QuestLog = Session.quest_log
	# Oct 20: Maren's first errand leads the MAIN quests; follow the first zone line for the marker checks, and take a side quest for the log's Side tab.
	_check(qlog.tracked_id() == QuestDefinitions.MERCHANTS, "town: Maren's first errand is tracked on arrival (%s)" % qlog.tracked_id())
	qlog.track(QuestDefinitions.zone_main_id("beefcake"))
	Session.start_quest(ZoneQuestDefinitions.SIDE_TOWN, false)
	qlog.track(QuestDefinitions.zone_main_id("beefcake"))
	EventBus.quest_changed.emit()
	var tracker: QuestTracker = town.hud.find_child("QuestTracker", true, false) as QuestTracker
	_check(tracker != null and tracker.visible, "town: the tracker is on the HUD")
	_check(town.hud.find_child("LocationPanel", true, false) == null, "town: no location / zones-freed header")
	await driver.seconds(1.2)
	_check(str(town.quest_markers.marks().get("guard", "")) == "!", "town: Brannoch shows a ! (Free the Four Zones on offer)")
	var gate: Dictionary = QuestMarkerLayer.resolve_in(town.spots, "npc_beefcake")
	_check(town.quest_markers.objective_position() != Vector3.INF and Vector2(town.quest_markers.objective_position().x - (gate["pos"] as Vector3).x, town.quest_markers.objective_position().z - (gate["pos"] as Vector3).z).length() < 0.5, "town: the objective marker floats over Brick Bronson")
	await _shot("q_01_town_tracker_and_markers")
	var first: String = qlog.tracked_id()
	await driver.tap_key(KEY_BRACKETRIGHT)
	await driver.frames(4)
	_check(qlog.tracked_id() != first, "town: ] tracks the next quest (%s)" % qlog.tracked_id())
	await _shot("q_02_town_toggled")
	await driver.tap_key(KEY_BRACKETLEFT)
	await driver.frames(4)
	_check(qlog.tracked_id() == first, "town: [ goes back")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.6)
	var log_screen: QuestLogScreen = town.find_child("*", true, false) as QuestLogScreen
	for node: Node in town.find_children("*", "QuestLogScreen", true, false):
		log_screen = node as QuestLogScreen
	_check(log_screen != null, "town: J opens the Quest Log")
	_check(driver.find_button("Main") != null and driver.find_button("Side") != null and driver.find_button("Completed") != null, "town: the log has Main, Side and Completed tabs")
	await _shot("q_03_quest_log_main")
	# Right moves the focus from the Main tab to the Side tab and Enter opens it; a click on the side quest tracks it.
	await driver.tap_key(KEY_RIGHT)
	await driver.seconds(0.3)
	await driver.tap_key(KEY_ENTER)
	await driver.seconds(0.3)
	var side_entry: Control = log_screen.find_child("Quest_%s" % ZoneQuestDefinitions.SIDE_TOWN, true, false) as Control if log_screen != null else null
	_check(side_entry != null, "town: Right then Enter opens the Side tab with the side quest")
	if side_entry != null:
		await driver.click(driver.center_of_control(side_entry))
	await driver.seconds(0.3)
	_check(qlog.tracked_id() == ZoneQuestDefinitions.SIDE_TOWN, "town: a click on the side quest tracks it (%s)" % qlog.tracked_id())
	await _shot("q_04_quest_log_side")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.5)


func _zone_leg(zone_id: String, quest_id: String, giver_spot: String, finish_steps: Callable) -> void:
	Session.enter_zone(zone_id)
	var zone: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	if zone == null:
		_fail("%s never loaded" % zone_id)
		return
	await driver.seconds(3.5)
	await _dismiss_dialogue(zone.dialogue)
	await _dismiss_popups()
	var giver: ZoneSpot = null
	for spot: ZoneSpot in zone.spots:
		if spot.id == giver_spot:
			giver = spot
	if giver == null:
		_fail("%s: no %s" % [zone_id, giver_spot])
		return
	await driver.seconds(1.1)
	_check(str(zone.quest_markers.marks().get(giver_spot, "")) == "!", "%s: %s shows a ! before talking" % [zone_id, giver.title])
	var poi_marked: bool = false
	for poi: MapPoi in zone._collect_pois():
		if poi.quest_marker and Vector2(poi.pos.x - giver.position.x, poi.pos.z - giver.position.z).length() < 1.0:
			poi_marked = true
	_check(poi_marked, "%s: the giver's ! is on the minimap" % zone_id)
	_teleport(zone, giver.position + Vector3(0.0, 0.0, 3.0))
	await _walk_to(zone, giver.position + Vector3(0.0, 0.0, 0.9), 1.2, 6.0)
	await driver.frames(6)
	await _shot("q_%s_01_giver" % zone_id)
	await driver.tap_key(KEY_E)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	var qlog: QuestLog = Session.quest_log
	_check(qlog.is_active(quest_id), "%s: E accepted %s" % [zone_id, quest_id])
	_check(qlog.tracked_id() == quest_id, "%s: the new quest is tracked" % zone_id)
	await _shot("q_%s_02_accepted" % zone_id)
	await driver.tap_key(KEY_BRACKETRIGHT)
	await driver.frames(4)
	_check(qlog.tracked_id() != quest_id, "%s: ] toggles away" % zone_id)
	await driver.tap_key(KEY_BRACKETLEFT)
	await driver.frames(4)
	_check(qlog.tracked_id() == quest_id, "%s: [ toggles back" % zone_id)
	finish_steps.call()
	await driver.seconds(1.2)
	await _dismiss_popups()
	_check(qlog.is_ready_to_turn_in(QuestCatalog.find(quest_id), Session.unlock_state()), "%s: every step done, ready to hand in" % zone_id)
	_check(str(zone.quest_markers.marks().get(giver_spot, "")) == "?", "%s: the giver now shows a ?" % zone_id)
	await _shot("q_%s_03_turn_in_mark" % zone_id)
	await driver.tap_key(KEY_E)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.5)
	_check(qlog.is_completed(quest_id), "%s: handed in with E" % zone_id)
	await _dismiss_popups()
	await _shot("q_%s_04_handed_in" % zone_id)


# ---- Helpers -------------------------------------------------------------------------------------------------------


func _teleport(zone: ZoneScene, pos: Vector3) -> void:
	pos.y = zone.builder.height_at(pos)
	zone.player.position = pos
	if "last_safe" in zone:
		zone.set("last_safe", pos)
	if "_spawn_grace" in zone:
		zone.set("_spawn_grace", 100000.0)
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


func _dismiss_popups() -> void:
	var guard: int = 0
	while driver.find_button("Continue") != null and guard < 10:
		guard += 1
		await driver.tap_key(KEY_ENTER)
		await driver.seconds(0.5)


func _dismiss_dialogue(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 40:
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
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	var off: float = Vector2(player.position.x - target.x, player.position.z - target.z).length()
	if off >= radius:
		print("%s: note  walked short (%.1f m off), placing the hero" % [TAG, off])
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
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
