class_name TourBot
extends Node
## Overnight Oct 17, Part 13: the playthrough bot. Tours every walkable area (the starting forest, Crosspath, the four Path zones, the
## Capital), talks to every NPC and uses every spot that does not leave the area (dialogue clicked through, shops and menus opened and
## closed again), opens every town menu (deck station, collection book, character, quests, map, wardrobe), starts one battle in each zone
## (dealt and played into the mulligan, then won by decree through the normal completion path) and logs every error, warning and frame over
## 33 ms to docs/overnight/bot_report.md. Windowed (frame times need a real renderer):
##   bash tools/run_tour_bot.sh
## Exit code 0 = no script errors.

const REPORT: String = "res://docs/overnight/bot_report.md"
const SLOW_FRAME_MS: float = 33.0
## Spot ids / kinds that leave the area or start a long flow; the tour never presses them.
const SKIP_WORDS: Array[String] = ["portal", "exit", "gate", "rift", "dungeon", "door", "hatch", "bridge", "travel", "leave", "boat", "passage", "cave", "lab", "vault", "throw", "rip", "undercroft", "fast_travel", "castle", "tunnel", "lever", "giant_chest", "dev_shrine", "arena", "npc_beefcake", "npc_gourmand", "npc_refusemancer", "npc_necrocrat", "graveyard", "guard"]
const ZONES: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer"]

var driver: UiDriver
var _log: Array[String] = []
var _errors: Array[String] = []
var _warnings: Array[String] = []
var _area: String = ""
var _slow: Dictionary = {}
var _frames: Dictionary = {}
var _worst: Dictionary = {}
var _measuring: bool = false
var _talked: Dictionary = {}
var _menus: Array[String] = []
var _battles: Array[String] = []
var _logger: Object = null
var _started_msec: int = 0
## The action being timed ("town: open codex", "beefcake: talk npc_gus") and the worst frame seen during each action.
var _action: String = ""
var _action_worst: Dictionary = {}


func run() -> void:
	_started_msec = Time.get_ticks_msec()
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	driver = UiDriver.new(get_tree())
	_install_logger()
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	for flag: String in ["rescuer_met", "trial_cleared", "elder_greeted"]:
		Session.set_flag(StringName(flag))
	Session.add_xp(ProgressionTable.xp_to_reach(6))
	await _tour_scene("forest", "res://scenes/starting_area.tscn", StartingAreaScene)
	await _tour_scene("town", "res://scenes/town.tscn", TownScene)
	for zone_id: String in ZONES:
		Session.set_flag(StringName("%s_zone_unlocked" % zone_id))
		await _tour_zone(zone_id)
	await _tour_zone(CapitalZone.ID)
	_write_report()
	get_tree().quit(1 if not _errors.is_empty() else 0)


func _process(delta: float) -> void:
	if not _measuring or _area.is_empty():
		return
	var ms: float = delta * 1000.0
	_frames[_area] = int(_frames.get(_area, 0)) + 1
	if ms > SLOW_FRAME_MS:
		_slow[_area] = int(_slow.get(_area, 0)) + 1
	_worst[_area] = maxf(float(_worst.get(_area, 0.0)), ms)
	if not _action.is_empty():
		_action_worst[_action] = maxf(float(_action_worst.get(_action, 0.0)), ms)


func _note(text: String) -> void:
	_log.append(text)
	print("tour_bot: ", text)


# ---- Errors and warnings --------------------------------------------------------------------------------------------------------------


func _install_logger() -> void:
	if not ClassDB.class_exists(&"Logger"):
		_note("no Logger class in this engine: errors are read from the console log instead")
		return
	var script: GDScript = load("res://tools/tour_bot_logger.gd") as GDScript
	if script == null:
		return
	_logger = script.new()
	_logger.set("bot", self)
	OS.call(&"add_logger", _logger)


## Called by the logger (any thread): kept short and copied out on the main thread.
func record(kind: String, text: String) -> void:
	var line: String = "[%s] %s" % [_area if not _area.is_empty() else "boot", text.strip_edges()]
	if kind == "error":
		if _errors.size() < 200 and not _errors.has(line):
			_errors.append(line)
	elif _warnings.size() < 200 and not _warnings.has(line):
		_warnings.append(line)


# ---- Areas ----------------------------------------------------------------------------------------------------------------------------


func _tour_scene(area: String, path: String, type: Variant, enter: Callable = Callable()) -> Node:
	_area = area
	_action = "%s: arrive" % area
	_measuring = false
	var before: Node = get_tree().current_scene
	if enter.is_valid():
		enter.call()
	else:
		SceneManager.change_scene(path)
	var scene: Node = await _wait_for(type, 30.0, before)
	if scene == null:
		_errors.append("[%s] the scene did not load" % area)
		return null
	await driver.seconds(2.0)
	_measuring = true
	await _clear(scene)
	await _use_spots(scene, area)
	if area == "town":
		await _open_menus(scene)
	await driver.seconds(1.0)
	_measuring = false
	return scene


func _tour_zone(zone_id: String) -> void:
	var def: ZoneDef = ZoneDefs.get_def(zone_id)
	if def == null:
		return
	var scene: Node = await _tour_scene(zone_id, def.scene_path, ZoneScene, func() -> void: Session.enter_zone(zone_id))
	if scene == null:
		return
	await _battle_in(scene as ZoneScene, zone_id)


func _wait_for(type: Variant, timeout: float = 30.0, not_this: Node = null) -> Node:
	var waited: float = 0.0
	while waited < timeout:
		var current: Node = get_tree().current_scene
		if current != null and current != not_this and is_instance_valid(current) and not current.is_queued_for_deletion() and is_instance_of(current, type):
			return current
		await driver.seconds(0.2)
		waited += 0.2
	return null


func _skip(spot_id: String, kind: String) -> bool:
	var key: String = (spot_id + " " + kind).to_lower()
	for word: String in SKIP_WORDS:
		if key.contains(word):
			return true
	return false


func _use_spots(scene: Node, area: String) -> void:
	var raw: Variant = scene.get("spots")
	if not raw is Array:
		_note("%s: no spot list to tour" % area)
		return
	var spots: Array = raw as Array
	for spot: Variant in spots.duplicate():
		if not is_instance_valid(spot) or get_tree().current_scene != scene:
			continue
		var id: String = str(spot.get("id"))
		var kind: String = str(spot.get("kind")) if spot.get("kind") != null else ""
		if _skip(id, kind):
			continue
		var player: Node3D = scene.get("player") as Node3D
		var where: Vector3 = spot.get("position") as Vector3 if spot.get("position") != null else Vector3.ZERO
		if player != null and where != Vector3.ZERO:
			player.position = where + Vector3(0.0, 0.0, 1.0)
		_action = "%s: use %s" % [area, id]
		scene.call(&"_interact", spot)
		_talked["%s/%s" % [area, id]] = true
		await driver.seconds(0.4)
		await _clear(scene)
		if get_tree().current_scene != scene:
			_note("%s: %s changed the scene; back to the tour" % [area, id])
			return


func _open_menus(scene: Node) -> void:
	for method: String in ["_open_deck_station", "_open_codex", "_open_character_screen", "_open_quest_log", "_open_full_map", "_open_wardrobe", "_open_vendor", "_open_item_vendor", "_open_pack_vendor"]:
		if not scene.has_method(StringName(method)):
			continue
		_action = "town: open %s" % method.trim_prefix("_open_")
		scene.call(StringName(method))
		_menus.append(method.trim_prefix("_open_"))
		await driver.seconds(0.8)
		await _clear(scene)


## Clicks through dialogue, closes shops/menus/dialogs and dismisses reward and level-up boxes until the area is free again.
func _clear(scene: Node) -> void:
	for _guard: int in range(40):
		if get_tree().current_scene != scene:
			return
		var busy: bool = false
		var dialogue: DialogueBox = scene.get("dialogue") as DialogueBox
		if dialogue != null and dialogue.active:
			dialogue.press()
			busy = true
		for node: Node in scene.find_children("*", "", true, false):
			if not is_instance_valid(node) or node.is_queued_for_deletion():
				continue
			if node is ConfirmDialog:
				(node as ConfirmDialog).cancelled.emit()
				node.queue_free()
				busy = true
			elif node is LevelUpScreen:
				(node as LevelUpScreen).finished.emit()
				busy = true
			elif node is PopupFrame:
				(node as PopupFrame).confirmed.emit()
				busy = true
			elif node is OverlayScreen and (node as Control).is_visible_in_tree():
				(node as OverlayScreen).request_close()
				busy = true
		if not busy:
			return
		await driver.seconds(0.25)


func _battle_in(scene: ZoneScene, zone_id: String) -> void:
	var enemy: ZoneEnemy = null
	for candidate: ZoneEnemy in scene.enemies:
		if is_instance_valid(candidate) and candidate.info.kind == ZoneEnemyInfo.Kind.BATTLE:
			enemy = candidate
			break
	if enemy == null:
		_note("%s: no battle enemy to fight" % zone_id)
		return
	var enemy_name: String = enemy.info.display_name
	_area = "%s battle" % zone_id
	_action = "%s: battle" % zone_id
	_measuring = false
	scene.call(&"_start_enemy_battle", enemy)
	var battle: BattleScreen = await _wait_for(BattleScreen, 20.0) as BattleScreen
	if battle == null:
		_errors.append("[%s] the battle did not start" % zone_id)
		return
	await driver.seconds(1.5)
	_measuring = true
	await driver.seconds(4.0)
	_measuring = false
	_battles.append("%s (%s)" % [zone_id, enemy_name])
	var context: BattleContext = battle.context
	if context != null and context.game != null:
		context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
		context.game._end_game(0, false)
		context.won = true
		Session.complete_battle(context)
	await _wait_for(ZoneScene, 20.0)
	await driver.seconds(1.0)


# ---- Report ---------------------------------------------------------------------------------------------------------------------------


func _write_report() -> void:
	var minutes: float = float(Time.get_ticks_msec() - _started_msec) / 60000.0
	var lines: PackedStringArray = []
	lines.append("# Bot report")
	lines.append("")
	lines.append("Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on %s, %.1f minutes." % [Time.get_datetime_string_from_system(), minutes])
	lines.append("")
	lines.append("- Areas: forest, town, %s, capital" % ", ".join(ZONES))
	lines.append("- Spots used (NPCs, shops, signs, chests...): %d" % _talked.size())
	lines.append("- Menus opened: %s" % ", ".join(_menus))
	lines.append("- Battles: %s" % ", ".join(_battles))
	lines.append("- Errors: %d, warnings: %d" % [_errors.size(), _warnings.size()])
	lines.append("")
	lines.append("## Frames over %d ms" % int(SLOW_FRAME_MS))
	lines.append("")
	lines.append("| Area | Frames | Over 33 ms | Worst (ms) |")
	lines.append("|---|---|---|---|")
	for area: Variant in _frames.keys():
		lines.append("| %s | %d | %d | %.0f |" % [str(area), int(_frames[area]), int(_slow.get(area, 0)), float(_worst.get(area, 0.0))])
	lines.append("")
	lines.append("## Slowest moments (worst frame during one action)")
	lines.append("")
	var actions: Array = _action_worst.keys()
	actions.sort_custom(func(a: Variant, b: Variant) -> bool: return float(_action_worst[a]) > float(_action_worst[b]))
	for action: Variant in actions.slice(0, 15):
		lines.append("- %s: %.0f ms" % [str(action), float(_action_worst[action])])
	lines.append("")
	lines.append("## Errors")
	lines.append("")
	if _errors.is_empty():
		lines.append("None.")
	for line: String in _errors:
		lines.append("- " + line.replace("|", "/"))
	lines.append("")
	lines.append("## Warnings")
	lines.append("")
	if _warnings.is_empty():
		lines.append("None.")
	for line: String in _warnings:
		lines.append("- " + line.replace("|", "/"))
	lines.append("")
	lines.append("## Log")
	lines.append("")
	for line: String in _log:
		lines.append("- " + line)
	var file: FileAccess = FileAccess.open(REPORT, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(lines) + "\n")
		file.close()
	print("tour_bot: %s - %d spots, %d menus, %d battles, %d errors, %d warnings" % ["OK" if _errors.is_empty() else "ERRORS", _talked.size(), _menus.size(), _battles.size(), _errors.size(), _warnings.size()])
