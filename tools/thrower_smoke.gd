class_name ThrowerSmoke
extends Node
## Gainlands corrective pass, Part F: every travel route of the Gainlands with human-style input (real injected keys and clicks), windowed.
## For each Beefcake thrower and portal ripper (`GainlandsTravel.points()`): stand at the Beefcake, E, through the dialogue, the confirm button, then
## watch the ride: a thrower must lift the hero in a real arc (the apex well above both ends), the hero must come down on the right place (the island
## under their feet, or the main land for a return / cross-country chuck), standing on that surface at its height, within reach of the destination anchor,
## on walkable ground with open space round it (nothing blocks the landing after the declutter). Every island must also have a way back down (checked
## from the data). Screenshots of the first throw in mid-air and at the landing, and one per route at the landing, go to _screenshots/throwers/.
##   Godot --path . --resolution 1600x900 res://tools/thrower_smoke_launcher.tscn     (bash tools/run_thrower_smoke.sh)
## Deliberate shortcuts: every lock is opened up front (wheel powered, the Gym Rat card, two enemies, Spot Me done) so each route can be ridden; the hero
## is placed beside each Beefcake rather than walked across the map (walkability has its own tests).
## Exit code 0 = every check passed; 1 = a check failed.

const SHOT_DIR: String = "res://_screenshots/throwers/"
const TAG: String = "thrower_smoke"
const RIDE_LIMIT: float = 14.0

var driver: UiDriver
var _failures: PackedStringArray = []
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	_unlock_every_route()
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	Session.enter_zone(GainlandsZone.ID)
	var zone: GainlandsScene = await _wait_for(GainlandsScene) as GainlandsScene
	if zone == null:
		_finish(false, "the Gainlands never loaded")
		return
	await driver.seconds(1.0)
	await _dismiss_dialogue(zone.dialogue)
	zone._spawn_grace = 100000.0
	var ridden: int = 0
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		_check(GainlandsTravel.is_unlocked(point, Session.unlock_state()), "%s is unlocked for the ride" % point.id)
		await _ride(zone, point, ridden == 0)
		ridden += 1
		await _clear_popups(zone)
	_check_ways_back(zone)
	_finish(_failures.is_empty(), "%d travel routes ridden with real input (%d screenshots)" % [ridden, _shots])


func _unlock_every_route() -> void:
	Session.set_flag(GainlandsZone.FLAG_WHEEL_POWERED)
	Session.bump_counter(GainlandsZone.COUNTER_ENEMIES, 2)
	var card: CardData = Session.card_by_id("B-27")
	if card != null:
		Session.add_cards([card] as Array[CardData])
	Session.quest_log.completed.append(GainlandsZone.QUEST_SPOT_ME)


# ---- One route ------------------------------------------------------------------------------------------------------


func _ride(zone: GainlandsScene, point: GainlandsTravel.Point, first: bool) -> void:
	var spot: ZoneSpot = _spot(zone, "travel_" + point.id)
	if spot == null:
		return
	var builder: GainlandsBuilder = zone.gain
	var start: Vector3 = spot.position + Vector3(0.0, 0.0, 0.5)
	start.y = builder.height_at(start)
	zone.player.position = start
	zone.last_safe = start
	zone._camera.position = zone.player.position + CameraRig.shape(zone.camera_offset)
	await driver.frames(6)
	_check(zone._near == spot, "%s: the prompt is the Beefcake's (near %s)" % [point.id, str(zone._near.id) if zone._near != null else "nothing"])
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	var clicked: bool = await driver.click_button("Throw me!" if point.kind == "throw" else "Step through")
	_check(clicked, "%s: the confirm offers the ride" % point.id)
	var dest: Vector3 = builder.anchor(point.dest_anchor)
	var from_y: float = start.y
	var apex: float = -1000.0
	var airborne_seen: bool = false
	var mid_shot: bool = not first
	var waited: float = 0.0
	while waited < RIDE_LIMIT:
		await driver.frames(2)
		waited += 2.0 / 60.0
		if zone.player.airborne:
			airborne_seen = true
			apex = maxf(apex, zone.player.position.y)
			if not mid_shot and zone.player.position.y > maxf(from_y, dest.y) + 2.5:
				mid_shot = true
				await _shot("%s_mid_air" % point.id)
		elif airborne_seen and not zone._locked:
			break
	_check(airborne_seen, "%s: the hero went up" % point.id)
	if point.kind == "throw":
		_check(apex > maxf(from_y, dest.y) + 3.0, "%s: a real arc (apex %.1f m, ends %.1f / %.1f)" % [point.id, apex, from_y, dest.y])
	await driver.seconds(0.4)
	var pos: Vector3 = zone.player.position
	var island: GainlandsLayout.Island = builder.island_under(pos)
	if point.dest_anchor.begins_with("arrive_"):
		var island_id: String = point.dest_anchor.trim_prefix("arrive_")
		_check(island != null and island.id == island_id, "%s: landed on %s (on %s)" % [point.id, island_id, island.id if island != null else "the main land"])
	else:
		_check(island == null and GainlandsLayout.is_main_ground(pos.x, pos.z), "%s: landed back on the main land" % point.id)
	_check(absf(pos.y - builder.height_at(pos)) < 0.3, "%s: standing on the surface (y %.2f, surface %.2f)" % [point.id, pos.y, builder.height_at(pos)])
	_check(Vector2(pos.x - dest.x, pos.z - dest.z).length() < 1.5, "%s: at the destination %s (%.1f m off)" % [point.id, point.dest_anchor, Vector2(pos.x - dest.x, pos.z - dest.z).length()])
	_check(builder.is_walkable(pos, 0.3), "%s: the landing spot is walkable" % point.id)
	var open: int = 0
	for step: int in range(8):
		var angle: float = TAU * float(step) / 8.0
		if builder.is_walkable(pos + Vector3(cos(angle) * 1.3, 0.0, sin(angle) * 1.3), 0.3):
			open += 1
	_check(open >= 6, "%s: open ground round the landing (%d of 8 directions clear)" % [point.id, open])
	_check(not zone._locked and zone.player.input_enabled, "%s: the hero can move again after the ride" % point.id)
	await _shot("%s_landing" % point.id)


## Every island has an always-open way back to the main land (a thrower or ripper with no lock whose destination is on the main land).
func _check_ways_back(zone: GainlandsScene) -> void:
	var layout: GainlandsLayout = zone.gain.layout
	for island: GainlandsLayout.Island in layout.islands:
		var way_back: bool = false
		for point: GainlandsTravel.Point in GainlandsTravel.points():
			var at: Vector3 = layout.anchors[point.anchor] as Vector3
			var to: Vector3 = layout.anchors[point.dest_anchor] as Vector3
			if layout.island_at(at.x, at.z) == island and point.lock == null and GainlandsLayout.is_main_ground(to.x, to.z):
				way_back = true
		_check(way_back, "%s has an always-open way back down" % island.title)


# ---- Helpers -------------------------------------------------------------------------------------------------------


func _spot(zone: GainlandsScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	_fail("no such spot: %s" % id)
	return null


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


func _clear_popups(zone: GainlandsScene) -> void:
	var guard: int = 0
	while guard < 20 and (zone.dialogue.active or (zone._overlay is LevelUpScreen or zone._overlay is RewardPopup)):
		guard += 1
		if zone.dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.15)
		else:
			await driver.click_button("Continue")
			await driver.seconds(0.4)


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
