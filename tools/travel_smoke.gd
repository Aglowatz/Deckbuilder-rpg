class_name TravelSmoke
extends Node
## Brief 10b e2e with human-style input (real injected keys and clicks): the Beefcake Rift Express and the return position after a
## battle. Flow: 1 walk to the town's Rift Station and open it (only the town station is open), 2 enter a zone and see its station
## unlock when its town is reached, 3 rip from the zone to the town and back (arrival at the stations, a fresh visit), 4 win a normal
## encounter and stand exactly where the battle began.
## Deliberate shortcuts (stated): the zone is entered through `Session.enter_zone` (the guardian gate fight is covered elsewhere), the duel
## is resolved by forcing the win, and the encounter is started by the enemy walking into the player.
## Screenshots: _screenshots/brief10b/.   Godot --path . res://tools/travel_launcher.tscn

const SHOT_DIR: String = "res://_screenshots/brief10b/"
const TAG: String = "travel_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)
	await _flow_town_station(town)
	await _flow_zone_unlock()
	await _flow_rips()
	await _flow_return_position()
	await _flow_town_return_position()
	_finish(_failures.is_empty(), "town station, zone unlock, rips both ways, position kept after a battle (%d screenshots)" % _shots)


# ---- 1 ----------------------------------------------------------------------------------------------------------------------


func _flow_town_station(town: TownScene) -> void:
	_check(FastTravel.unlocked_ids(Session.flags).size() == 1, "only the town station is open at the start")
	var station: Vector3 = town.town.anchors["rift_station"] as Vector3
	await _walk_to(town, station + Vector3(0.0, 0.0, 1.6), 1.6)
	await driver.seconds(0.4)
	await _shot("t01_town_station")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(town.dialogue.active, "the Beefcake operator talks")
	await _shot("t02_town_operator")
	await _dismiss(town.dialogue)
	await driver.seconds(0.6)
	var screen: FastTravelScreen = _find_screen(town)
	_check(screen != null, "the Rift Express menu opens")
	if screen == null:
		return
	_check(screen.find_child("Rip_%s" % DnaZone.ID, true, false) == null, "no zone station is open yet")
	await _shot("t03_menu_town")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)


# ---- 2 ----------------------------------------------------------------------------------------------------------------------


func _flow_zone_unlock() -> void:
	Session.enter_zone(DnaZone.ID)
	var zone: DnaScene = await _wait_for(DnaScene) as DnaScene
	_check(zone != null, "entered the zone")
	if zone == null:
		return
	zone._spawn_grace = 60.0
	await driver.seconds(2.0)
	_check(Session.fast_travel_unlocked(DnaZone.ID), "reaching the zone's town unlocked its station")
	_check(zone.dialogue.active, "the cousin announces it")
	await _shot("t04_zone_unlock")
	await _dismiss(zone.dialogue)


# ---- 3 ----------------------------------------------------------------------------------------------------------------------


func _flow_rips() -> void:
	var zone: DnaScene = get_tree().current_scene as DnaScene
	zone._spawn_grace = 60.0
	var spot: ZoneSpot = _station_spot(zone)
	await _walk_to(zone, spot.position, 1.6)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(zone.dialogue)
	await driver.seconds(0.6)
	var screen: FastTravelScreen = _find_screen(zone)
	_check(screen != null, "the zone's station opens the menu")
	if screen == null:
		return
	_check(screen.find_child("Rip_%s" % FastTravel.TOWN, true, false) != null, "the town is a destination")
	await _shot("t05_menu_zone")
	await driver.click(driver.center_of_control(screen.find_child("Rip_%s" % FastTravel.TOWN, true, false) as Control))
	await driver.seconds(0.8)
	_check(zone.dialogue.active, "the operator shouts a rip line")
	await _dismiss(zone.dialogue)
	await driver.seconds(0.5)
	await _shot("t06_ripping")
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "the rip took the hero to town")
	if town == null:
		return
	await driver.seconds(1.0)
	var station: Vector3 = town.town.anchors["rift_station"] as Vector3
	_check(Vector2(town.player.position.x - station.x, town.player.position.z - station.z).length() < 3.0, "and they arrive at the town's station")
	_check(Session.zone_run == null, "the zone visit ended")
	await _shot("t07_arrived_in_town")
	await _dismiss(town.dialogue)
	# And back to the zone from the town's station.
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(town.dialogue)
	await driver.seconds(0.6)
	var back_screen: FastTravelScreen = _find_screen(town)
	_check(back_screen != null and back_screen.find_child("Rip_%s" % DnaZone.ID, true, false) != null, "the town menu now lists the zone")
	if back_screen == null:
		return
	await _shot("t08_menu_town_unlocked")
	await driver.click(driver.center_of_control(back_screen.find_child("Rip_%s" % DnaZone.ID, true, false) as Control))
	await driver.seconds(0.8)
	await _dismiss(town.dialogue)
	var again: DnaScene = await _wait_for(DnaScene) as DnaScene
	_check(again != null, "ripped back into the zone")
	if again == null:
		return
	await driver.seconds(1.0)
	var zone_station: Vector3 = again.builder.anchor(FastTravel.ANCHOR)
	_check(Vector2(again.player.position.x - zone_station.x, again.player.position.z - zone_station.z).length() < 3.5, "and they arrive at the zone's station")
	_check(Session.zone_run != null and Session.zone_run.hp == Session.zone_run.max_hp(), "a fresh visit at full HP")
	await _shot("t09_arrived_in_zone")
	await _dismiss(again.dialogue)


# ---- 4 ----------------------------------------------------------------------------------------------------------------------


func _flow_return_position() -> void:
	var zone: DnaScene = get_tree().current_scene as DnaScene
	var target: ZoneEnemy = null
	for enemy: ZoneEnemy in zone.enemies:
		if enemy.info.kind == ZoneEnemyInfo.Kind.BATTLE:
			target = enemy
			break
	_check(target != null, "a roaming enemy to fight")
	if target == null:
		return
	zone.player.position = target.position + Vector3(2.4, 0.0, 0.8)
	zone._spawn_grace = 0.0
	zone._invulnerable = 0.0
	await driver.seconds(0.3)
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	if battle == null:
		_note("the enemy did not reach the player: touching it directly")
		zone._on_enemy_touched(target)
		battle = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "a normal encounter starts")
	if battle == null:
		return
	var before: Vector3 = Session.zone_run.return_position
	_check(Session.zone_run.has_return_position, "the spot is remembered")
	await _force_win(battle)
	var after_zone: DnaScene = await _wait_for(DnaScene) as DnaScene
	_check(after_zone != null, "back in the zone after the win")
	if after_zone == null:
		return
	await driver.seconds(0.6)
	var moved: float = Vector2(after_zone.player.position.x - before.x, after_zone.player.position.z - before.z).length()
	_check(moved < 0.5, "the hero stands where the battle began (moved %.2f)" % moved)
	await _shot("t10_after_battle_same_place")




# ---- 5: a duel in town (a corrupted NPC) also puts the hero back where they stood --------------------------------------------


func _flow_town_return_position() -> void:
	Session.leave_zone()
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "back in town")
	if town == null:
		return
	await driver.seconds(1.0)
	await _dismiss(town.dialogue)
	var start: Vector3 = (town.town.anchors["npc_beefcake"] as Vector3) + Vector3(0.0, 0.0, 1.4)
	town.player.position = start
	await driver.seconds(0.4)
	Session.challenge_corrupted_npc("beefcake")
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "the duel starts")
	if battle == null:
		return
	await _force_win(battle)
	var after: TownScene = await _wait_for(TownScene) as TownScene
	_check(after != null, "back in town after the duel")
	if after == null:
		return
	await driver.seconds(0.8)
	var moved: float = Vector2(after.player.position.x - start.x, after.player.position.z - start.z).length()
	_check(moved < 0.5, "the hero stands where they were before the duel (moved %.2f)" % moved)
	await _shot("t11_town_after_duel_same_place")


# ---- Helpers ----------------------------------------------------------------------------------------------------------------


func _find_screen(scene: Node) -> FastTravelScreen:
	for node: Node in scene.find_children("*", "Control", true, false):
		if node is FastTravelScreen:
			return node as FastTravelScreen
	return null


func _station_spot(zone: ZoneScene) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == "rift_station":
			return spot
	return null


func _dismiss(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


## Shortcut (stated): a duel is resolved by forcing the win, then flows through the real results/rewards.
func _force_win(battle_scene: Node) -> void:
	var context: BattleContext = (battle_scene as BattleScreen).context
	await driver.seconds(0.5)
	if context == null:
		return
	context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
	context.game._end_game(0, false)
	context.won = true
	Session.complete_battle(context)
	await driver.seconds(1.5)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 30.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _walk_to(scene: Node, target: Vector3, radius: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < 14.0:
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
	if Vector2(player.position.x - target.x, player.position.z - target.z).length() >= radius:
		_note("walk fell back to a short teleport near %s" % str(target))
		player.position = target + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held.get(key, false)) == down:
		return
	_held[key] = down
	await driver.key(key, down)


func _shot(name: String) -> void:
	_shots += 1
	await driver.frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, name]))
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


func _note(message: String) -> void:
	print("%s: note  %s" % [TAG, message])
