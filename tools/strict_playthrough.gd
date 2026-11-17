class_name StrictPlaythrough
extends StoryPlaythrough
## Overnight Nov 17, Part 1: one complete game from a new game to the credits and the first postgame step, with no state set by debug
## commands. Built on the story bot's --full mode (every fight played by the game's own planning AI in the hero's seat), with the bot's
## shortcuts taken out:
## - walking: the hero walks every leg with real keys along the same walkable route the quest arrow follows (`RouteGuide`), from where
##   it stands; only when the route fails (no route, or stuck for STUCK_SECONDS) is the hero moved, and that is logged as TRAPPED;
## - quests: every step is done by walking to its place and pressing E (Maren's errands, favours, side quests, the Capital's gate, the
##   manhole and Fig Sly); a few menu steps (equip an item, buy a card, save a deck) call the function their button calls (logged as UI);
## - fights: a lost fight is retried (the run gives XP and gold for every fight won on the way), never decreed, up to STRICT_TRIES;
## - the ending plays to the credits and back to the world by itself.
## Before each walk it checks that a quest marker (the tracked arrow, or a map dot) points at the place (MARKER lines), and it logs the
## level, the gold and the time at each boss and chapter (CHAPTER / BOSS lines).
##   bash tools/run_strict_playthrough.sh <path> [limit_seconds]     (log: _logs/strict/<path>.log)

const STRICT_TRIES: int = 10
const STUCK_SECONDS: float = 5.0
const WALK_LIMIT: float = 75.0
const REACH: float = 1.1

var _issues: PackedStringArray = []
var _chapters: PackedStringArray = []
var _chapter_started: int = 0
var _chapter_game_started: float = 0.0
var _walks: Dictionary = {"walked": 0, "trapped": 0, "metres": 0.0, "seconds": 0.0}
var _ui_calls: PackedStringArray = []


func run() -> void:
	_strict = true
	_chapter_started = Time.get_ticks_msec()
	var resume: String = _arg("resume", "")
	if resume.is_empty():
		await super.run()
		return
	await _resume_from(resume)


## `--resume=<snapshot>`: continue the SAME game from a save this bot made through the real save path (what Continue does after a crash or a
## stop), then play on: the zones not yet freed, the Capital, the ending, the first postgame step.
func _resume_from(snapshot_name: String) -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	driver = UiDriver.new(get_tree())
	_path_zone = _arg("path", "refusemancer")
	_full = true
	_real = true
	_saveload = _arg("saveload", "1") == "1"
	Settings.battle_speed = Settings.BATTLE_SPEEDS.size() - 1
	Settings.low_end = true
	Settings.graphics_quality = GraphicsQuality.Level.LOW
	Settings.apply_quality_preset()
	Settings.apply_performance()
	Settings.graphics_changed.emit()
	Engine.max_fps = 0
	EventBus.gold_changed.connect(_on_gold)
	_wall_started = Time.get_ticks_msec()
	await driver.frames(5)
	print("%s: RESUME %s" % [TAG, DevActions.load_snapshot(snapshot_name)])
	_last_gold = Session.gold
	var town: TownScene = await _to_town()
	var order: Array[String] = [_path_zone]
	for other: String in Gatekeepers.IDS:
		if other != _path_zone:
			order.append(other)
	for zone_id: String in order:
		if Session.is_zone_completed(zone_id):
			continue
		town = await _zone(town, zone_id)
		_tend_deck("after %s" % zone_id)
		if town == null:
			_step(false, "%s: lost the town" % zone_id)
			_finish()
			return
	await _save_progress("capital_ready")
	_tend_deck("before the Capital")
	await _capital_and_castle()
	_finish()


## A snapshot of the real progress (for the critics), nothing changed.
func _save_progress(label: String) -> void:
	print("%s: SNAPSHOT %s" % [TAG, DevActions.save_snapshot("bot_%s_%s" % [_path_zone, label])])


func _max_tries() -> int:
	return STRICT_TRIES


# ---- Logging --------------------------------------------------------------------------------------------------------------------------------


func _issue(kind: String, text: String) -> void:
	var line: String = "%s: %s (L%d, %d gold, %s)" % [kind, text, Session.profile.level if Session.profile != null else 0, Session.gold, _where()]
	_issues.append(line)
	print("%s: ISSUE %s" % [TAG, line])


func _where() -> String:
	var scene: Node = get_tree().current_scene
	var text: String = scene.name if scene != null else "none"
	if scene != null and "player" in scene and scene.get("player") is Node3D:
		var p: Vector3 = (scene.get("player") as Node3D).position
		text += " at (%.1f, %.1f)" % [p.x, p.z]
	return text


func _chapter(label: String) -> void:
	var wall: float = float(Time.get_ticks_msec() - _chapter_started) / 60000.0
	var game: float = (Session.playtime_seconds - _chapter_game_started) / 60.0
	var line: String = "%s | %.1f min wall, %.1f min game | L%d, %d gold, deck %d, %d gear" % [label, wall, game, Session.profile.level if Session.profile != null else 0, Session.gold, Session.deck.size() if Session.deck != null else 0, Session.owned_equipment_ids().size()]
	_chapters.append(line)
	print("%s: CHAPTER %s" % [TAG, line])
	_chapter_started = Time.get_ticks_msec()
	_chapter_game_started = Session.playtime_seconds


func _win(battle: BattleScreen, label: String) -> void:
	var foe: String = battle.context.board_key if battle != null and battle.context != null else ""
	print("%s: FIGHT %s | board %s | L%d, %d gold, deck %d" % [TAG, label, foe, Session.profile.level, Session.gold, Session.deck.size() if Session.deck != null else 0])
	var turns_before: int = -1
	await super._win(battle, label)
	if _last_win:
		print("%s: FIGHT won %s (turn %d)" % [TAG, label, battle.game.turn if is_instance_valid(battle) and battle.game != null else turns_before])


func _finish() -> void:
	print("%s: ==== strict summary ====" % TAG)
	print("%s: walks %s" % [TAG, _walks])
	for line: String in _chapters:
		print("%s: CHAPTERLIST %s" % [TAG, line])
	for line: String in _issues:
		print("%s: ISSUELIST %s" % [TAG, line])
	for line: String in _ui_calls:
		print("%s: UICALL %s" % [TAG, line])
	super._finish()


# ---- Walking ----------------------------------------------------------------------------------------------------------------------------------


## The places a marker shows in this scene right now: the tracked arrow's, the other arrow's, every map dot.
func _marked(scene: Node) -> Array[Vector3]:
	var result: Array[Vector3] = []
	var layer: QuestMarkerLayer = scene.get("quest_markers") as QuestMarkerLayer if scene != null and "quest_markers" in scene else null
	if layer == null:
		return result
	layer.refresh()
	for slot: Variant in layer._arrow_places:
		for place: Variant in slot as Array:
			result.append((place as Dictionary)["pos"] as Vector3)
	for goal: Dictionary in layer.goals():
		result.append(goal["pos"] as Vector3)
	for spot_id: Variant in layer._marks.keys():  # a giver's "!" or a turn-in's "?" over a head
		var where: Dictionary = layer.resolve.call(str(spot_id)) as Dictionary
		if not where.is_empty() and where.has("pos"):
			result.append(where["pos"] as Vector3)
	return result


func _check_marker(scene: Variant, pos: Vector3, why: String, needs_marker: bool) -> void:
	if not is_instance_valid(scene) or not (scene is Node) or get_tree().current_scene != scene:
		return
	if not needs_marker:
		return
	for place: Vector3 in _marked(scene):
		if Vector2(place.x - pos.x, place.z - pos.z).length() < 4.0:
			return
	var layer: QuestMarkerLayer = scene.get("quest_markers") as QuestMarkerLayer if "quest_markers" in scene else null
	var tracked: String = Session.quest_log.tracked_id()
	var aimed: String = ""
	if layer != null and not (layer._arrow_places[0] as Array).is_empty():
		var first: Dictionary = (layer._arrow_places[0] as Array)[0] as Dictionary
		aimed = "%s at (%.0f, %.0f)" % [str(first.get("title", first.get("spot", "?"))), (first["pos"] as Vector3).x, (first["pos"] as Vector3).z]
	_issue("MARKER", "no marker on %s (tracked quest %s; its arrow points at %s)" % [why, tracked, aimed if aimed != "" else "nothing"])


func _resolve(scene: Node, spot_id: String) -> Vector3:
	var layer: QuestMarkerLayer = scene.get("quest_markers") as QuestMarkerLayer if scene != null and "quest_markers" in scene else null
	var where: Dictionary = {}
	if layer != null and layer.resolve.is_valid():
		where = layer.resolve.call(spot_id) as Dictionary
	if where.is_empty() and scene is TownScene:
		where = QuestMarkerLayer.resolve_in((scene as TownScene).spots, spot_id)
	if where.is_empty() and "spots" in scene:
		for spot: Variant in scene.get("spots") as Array:
			if "id" in spot and str(spot.get("id")) == spot_id:
				return spot.get("position") as Vector3
	if where.is_empty():
		return Vector3.INF
	if where.has("many"):
		var best: Vector3 = Vector3.INF
		var from: Vector3 = (scene.get("player") as Node3D).position
		for entry: Variant in where["many"] as Array:
			var p: Vector3 = (entry as Dictionary)["pos"] as Vector3
			if best == Vector3.INF or p.distance_to(from) < best.distance_to(from):
				best = p
		return best
	return where["pos"] as Vector3


## Walks the hero of `scene` to `target` with real keys along the walkable route (the quest arrow's planner). True when it got there on
## foot; on a failed route it moves the hero there and logs TRAPPED (the run goes on).
func _route_walk(scene: Variant, target: Vector3, why: String, reach: float = REACH) -> bool:
	if not is_instance_valid(scene) or not (scene is Node) or get_tree().current_scene != scene:
		return false
	var player: Node3D = scene.get("player") as Node3D if "player" in scene else null
	var layer: QuestMarkerLayer = scene.get("quest_markers") as QuestMarkerLayer if "quest_markers" in scene else null
	if layer == null or not layer._guides[0].ready():
		for node: Node in scene.find_children("*", "QuestMarkerLayer", true, false):
			if (node as QuestMarkerLayer)._guides[0].ready():
				layer = node as QuestMarkerLayer
	if player == null:
		return false
	var guide: RouteGuide = RouteGuide.new()
	if layer == null and scene is StartingAreaScene:
		var forest_area: Variant = (scene as StartingAreaScene).area
		guide.setup(func(at: Vector3) -> bool: return forest_area.is_walkable(at), Callable(), forest_area.map_bounds() if forest_area.has_method("map_bounds") else Rect2(-60, -60, 120, 120), 0.5, 40000)
	if layer != null and layer._guides[0].ready():
		var lg: RouteGuide = layer._guides[0]
		guide.setup(lg.strict, lg.through_gates, lg.bounds, lg.step, 40000)
	var started: int = Time.get_ticks_msec()
	var start_pos: Vector3 = player.position
	var last_pos: Vector3 = player.position
	var last_move: int = Time.get_ticks_msec()
	var stuck_kicks: int = 0
	var arrived: bool = false
	var route_sig: String = ""
	var route_index: int = 0
	await _hold(KEY_SHIFT, true)
	while float(Time.get_ticks_msec() - started) / 1000.0 < WALK_LIMIT:
		if get_tree().current_scene != scene or not is_instance_valid(player):
			break
		if SceneManager.busy:
			await _keys_up()
			await driver.seconds(0.5)
			if SceneManager.busy or get_tree().current_scene != scene:
				_walks["walked"] = int(_walks["walked"]) + 1
				return true  # a roamer touched, a road taken: the game is changing scene
			continue
		if scene.get("dialogue") is DialogueBox and (scene.get("dialogue") as DialogueBox).active:
			await _keys_up()
			await _dismiss_dialogue(scene.get("dialogue") as DialogueBox)
			continue
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < reach:
			arrived = true
			break
		var aim: Vector3 = target
		if guide.ready():
			guide.aim(player.position, target)
			guide.work()
			guide.work()
			var route: PackedVector3Array = guide.route()
			if route.size() >= 2:
				# follow the route's own corners in order (the arrow's look-ahead cuts corners); a new plan starts again at its first corner
				var sig: String = "%d|%.1f|%.1f" % [route.size(), route[0].x, route[0].z]
				if sig != route_sig:
					route_sig = sig
					route_index = 0
				while route_index < route.size() - 1 and Vector2(route[route_index].x - player.position.x, route[route_index].z - player.position.z).length() < 1.0:
					route_index += 1
				aim = route[route_index]
		var dir: Vector3 = aim - player.position
		dir.y = 0.0
		if dir.length() < 0.3:
			dir = offset
		dir = dir.normalized()
		if OS.get_cmdline_user_args().has("--walkdebug=1") and Engine.get_process_frames() % 30 == 0:
			print("%s: WALKDBG pos (%.1f,%.1f) aim (%.1f,%.1f) target (%.1f,%.1f) route %d planning %s keys %s" % [TAG, player.position.x, player.position.z, aim.x, aim.z, target.x, target.z, guide.route().size(), guide._planning, str(_held_keys)])
		await _hold(KEY_W, dir.z < -0.38)
		await _hold(KEY_S, dir.z > 0.38)
		await _hold(KEY_A, dir.x < -0.38)
		await _hold(KEY_D, dir.x > 0.38)
		await driver.frames(2)
		if player.position.distance_to(last_pos) > 0.6:
			last_pos = player.position
			last_move = Time.get_ticks_msec()
		elif float(Time.get_ticks_msec() - last_move) / 1000.0 > STUCK_SECONDS:
			stuck_kicks += 1
			last_move = Time.get_ticks_msec()
			if player.position.distance_to(start_pos) < 0.3:
				# not one step since the walk began: something holds the hero (a box, a tip) - say what is on screen and press past it
				await _keys_up()
				var shown: PackedStringArray = []
				for node: Node in get_tree().root.find_children("*", "Button", true, false):
					if (node as Button).is_visible_in_tree() and not (node as Button).text.strip_edges().is_empty():
						shown.append((node as Button).text.strip_edges())
				print("%s: HELD hero cannot move at (%.1f, %.1f); buttons on screen: %s; dialogue %s" % [TAG, player.position.x, player.position.z, ", ".join(shown), scene.get("dialogue").active if scene.get("dialogue") is DialogueBox else "-"])
				for text: String in ["Got it", "Skip tips", "Continue", "OK", "Close", "Done"]:
					var b: Button = driver.find_button(text)
					if b != null and not b.disabled:
						await driver.click(driver.button_center(b))
						await driver.seconds(0.4)
				if scene is TownScene:
					await _clear_overlays(scene as TownScene)
				await driver.tap_key(KEY_ESCAPE)
				await driver.seconds(0.4)
				var resume: Button = driver.find_button("Resume")
				if resume != null:
					await driver.click(driver.button_center(resume))
				await _hold(KEY_SHIFT, true)
				continue
			if stuck_kicks >= 3:
				break
			# a sidestep, as a player would
			await _keys_up()
			var side: Key = KEY_A if stuck_kicks % 2 == 1 else KEY_D
			await _hold(side, true)
			await driver.seconds(0.6)
			await _hold(side, false)
	await _keys_up()
	var seconds: float = float(Time.get_ticks_msec() - started) / 1000.0
	_walks["seconds"] = float(_walks["seconds"]) + seconds
	_walks["metres"] = float(_walks["metres"]) + start_pos.distance_to(player.position if is_instance_valid(player) else start_pos)
	if get_tree().current_scene != scene:
		_walks["walked"] = int(_walks["walked"]) + 1
		return true  # the walk ran into a road, a door or a roamer: the scene changed under it
	if arrived:
		_walks["walked"] = int(_walks["walked"]) + 1
		return true
	_walks["trapped"] = int(_walks["trapped"]) + 1
	_issue("TRAPPED", "could not walk to %s at (%.1f, %.1f) - %s after %.0f s from (%.1f, %.1f), route %d points%s; moved there" % [why, target.x, target.z, "stuck" if stuck_kicks >= 3 else "too slow", seconds, start_pos.x, start_pos.z, guide.route().size(), "" if guide.ready() else " (no route planner)"])
	if is_instance_valid(player) and get_tree().current_scene == scene:
		var land: Vector3 = target + Vector3(0.0, 0.0, 1.0)
		player.position = Vector3(land.x, player.position.y, land.z)
		if scene is TownScene:
			(scene as TownScene)._camera.position = player.position + CameraRig.shape((scene as TownScene).camera_offset)
		await driver.frames(6)
	return false


func _keys_up() -> void:
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_SHIFT]:
		await _hold(key, false)


## Walks to a spot of the current scene (checking a marker shows it first) and presses E.
func _go_and_use(scene: Variant, spot_id: String, why: String, needs_marker: bool = true) -> bool:
	if not is_instance_valid(scene) or not (scene is Node) or get_tree().current_scene != scene:
		return false
	var pos: Vector3 = _resolve(scene, spot_id)
	if pos == Vector3.INF:
		_issue("GUESS", "no spot %s for %s in %s" % [spot_id, why, scene.name])
		return false
	_check_marker(scene, pos, why, needs_marker)
	await _route_walk(scene, pos, why)
	if get_tree().current_scene != scene:
		return true
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	return true


## The town version the story bot calls everywhere: walk from wherever the hero stands (real keys), no teleport.
func _walk_up(town: TownScene, spot_id: String) -> void:
	if not is_instance_valid(town) or get_tree().current_scene != town:
		town = await _live_town()
		if town == null:
			return
	var pos: Vector3 = _resolve(town, spot_id)
	if pos == Vector3.INF:
		_issue("GUESS", "no spot %s in town" % spot_id)
		return
	_check_marker(town, pos, "town spot %s" % spot_id, _town_spot_needs_marker(spot_id))
	await _route_walk(town, pos, "town spot %s" % spot_id)
	await driver.frames(6)


func _town_spot_needs_marker(spot_id: String) -> bool:
	return spot_id != "arena"


## Presses through every box an interaction opens (talk, a quest offer, a confirm, the deck check) until the scene is quiet or changes.
func _settle(scene: Variant, seconds: float = 6.0) -> void:
	if not is_instance_valid(scene) or not (scene is Node) or get_tree().current_scene != scene:
		return
	var started: int = Time.get_ticks_msec()
	while float(Time.get_ticks_msec() - started) / 1000.0 < seconds:
		if get_tree().current_scene != scene or SceneManager.busy:
			return
		var box: DialogueBox = scene.get("dialogue") as DialogueBox if "dialogue" in scene else null
		if box != null and box.active:
			await _dismiss_dialogue(box)
			started = Time.get_ticks_msec()
			continue
		if driver.find_button("Continue") != null or driver.find_button("Next level") != null or _reward_popup() != null or _slot_choice() != null:
			await _dismiss_popups()
			started = Time.get_ticks_msec()
			continue
		var pressed: bool = false
		# any open confirm box (a door, a gate's challenge, a ladder): its yes-button, never "Not yet" / "Cancel"
		for dialog: Node in get_tree().root.find_children("*", "ConfirmDialog", true, false):
			if pressed or not (dialog as CanvasItem).is_visible_in_tree():
				continue
			for node: Node in dialog.find_children("*", "Button", true, false):
				var yes: Button = node as Button
				var label: String = yes.text.strip_edges()
				if yes.is_visible_in_tree() and not yes.disabled and label != "" and not label in ["Not yet", "Cancel", "Stay", "Not now", "Keep watching", "Tell me more", "No"]:
					print("%s: confirm '%s'" % [TAG, label])
					await driver.click(driver.button_center(yes))
					await driver.seconds(0.6)
					pressed = true
					break
		if pressed:
			started = Time.get_ticks_msec()
			continue
		for text: String in ["Use this deck", "Enter", "Descend", "Take a number", "Step through", "Go down", "Climb down", "Fight", "Challenge"]:
			var button: Button = driver.find_button(text)
			if button != null and not button.disabled:
				await driver.click(driver.button_center(button))
				await driver.seconds(0.6)
				pressed = true
				break
		if pressed:
			started = Time.get_ticks_msec()
			continue
		await driver.seconds(0.3)


## Closes a shop or a page an interaction opened.
func _close_screens() -> void:
	for _i: int in range(3):
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.35)
		var pause: Button = driver.find_button("Resume")
		if pause != null:
			await driver.click(driver.button_center(pause))
			await driver.seconds(0.3)
			return


func _ui(text: String) -> void:
	_ui_calls.append(text)
	print("%s: UI %s" % [TAG, text])


# ---- 1. The forest and the tutorial ---------------------------------------------------------------------------------------------------------


func _forest_and_tutorial() -> void:
	Session.new_game()
	SceneManager.change_scene("res://scenes/starting_area.tscn")
	var forest: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	_step(forest != null, "the starting forest loads on a new game")
	await driver.seconds(2.0)
	if forest != null:
		await _settle(forest, 3.0)
	# The awakening and the Rescuer's conversation, read with E; her question is answered on its four-tile screen.
	var chose: bool = false
	var started: int = Time.get_ticks_msec()
	while forest != null and float(Time.get_ticks_msec() - started) / 1000.0 < 90.0:
		var choices: Array[Node] = forest.find_children("*", "ElementChoiceScreen", true, false)
		if not choices.is_empty() and not chose:
			chose = true
			await driver.seconds(0.8)
			(choices[0] as ElementChoiceScreen).chosen.emit(_path_type())
			_ui("the Rescuer's Path choice: %s (the tile's chosen signal)" % Affinity.display_name(_path_type()))
			await driver.seconds(0.6)
			continue
		if forest.dialogue.active:
			await _dismiss_dialogue(forest.dialogue)
			continue
		if chose and not forest._locked:
			break
		if not chose and not forest.find_children("*", "StoryStillScreen", true, false).is_empty():
			await driver.tap_key(KEY_E)
		await driver.seconds(0.4)
	if Session.profile == null:
		_issue("SHORTCUT", "the Rescuer's Path choice never appeared; chosen by its call")
		Session.choose_starting_path(_path_type())
	# The cave gate, on foot.
	if forest != null:
		var gate: Vector3 = forest.area.anchors.get("gate", Vector3.INF) as Vector3
		if gate != Vector3.INF:
			await _route_walk(forest, gate, "the Forgotten Cave's gate", 1.6)
			await driver.tap_key(KEY_E)
			await _settle(forest, 3.0)
	var map: Node = await _wait_for_short(DungeonMapScreen)
	if map == null:
		_issue("SHORTCUT", "the cave gate did not open by walking and E; entered by its call")
		Session.begin_intro_trial(_path_type())
		map = await _wait_for(DungeonMapScreen)
	_step(map != null, "the Forgotten Cave opens")
	await _boss_for_real(func() -> bool: return Session.flag(&"trial_cleared"), "the Forgotten Cave", "TUTORIAL")
	_step(Session.flag(&"trial_cleared"), "the tutorial cave is cleared by play")
	if not Session.flag(&"trial_cleared"):
		_issue("BLOCKER", "the Forgotten Cave was not cleared in %d tries" % STRICT_TRIES)
	_chapter("Chapter 0: the forest and the Forgotten Cave")


## After the cave the game walks itself to Crosspath (Maren at the cave mouth); from a zone, the exit on foot. Never the scene call
## unless that fails (logged).
func _to_town() -> TownScene:
	var started: int = Time.get_ticks_msec()
	while float(Time.get_ticks_msec() - started) / 1000.0 < 60.0:
		var scene: Node = get_tree().current_scene
		if scene is TownScene and not SceneManager.busy:
			await driver.seconds(2.5)
			await _settle(scene, 2.0)
			await _dismiss_popups()
			return scene as TownScene
		if scene is ZoneScene and not SceneManager.busy:
			return await _leave_to_town()
		if scene != null and "dialogue" in scene and scene.get("dialogue") is DialogueBox and (scene.get("dialogue") as DialogueBox).active:
			await _dismiss_dialogue(scene.get("dialogue") as DialogueBox)
		elif scene is RewardsScreen:
			await _take_rewards(scene as RewardsScreen)
		else:
			await _dismiss_popups()
		await driver.seconds(0.4)
	_issue("SHORTCUT", "no way to town by play from %s; went by the scene call" % _where())
	return await _scene_to_town()


func _scene_to_town() -> TownScene:
	SceneManager.go_to_town()
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town != null:
		await driver.seconds(2.5)
		await _dismiss_dialogue(town.dialogue)
		await _dismiss_popups()
	return town


## After a loss in a dungeon: heal at the zone's couch if hurt, walk to the door, E, Enter (the story bot entered by the call).
func _reenter(expected_key: String) -> void:
	var scene: Node = await _wait_for_walkable()
	await driver.seconds(1.0)
	if scene != null:
		await _settle(scene, 2.0)
		await _dismiss_popups()
	var spot: String = ""
	if scene is ZoneScene:
		spot = "castle_door" if expected_key == "D-PC" else ("mini_dungeon" if expected_key.begins_with("S-") else "main_dungeon")
		var zone: ZoneScene = scene as ZoneScene
		if Session.zone_run != null and Session.zone_run.hp < Session.zone_run.max_hp():
			await _go_and_use(zone, "heal", "the zone's healing spot before another try", false)
			await _settle(zone, 2.0)
		scene = await _wait_for_walkable()
	elif scene is StartingAreaScene and expected_key == "TUTORIAL":
		var gate: Vector3 = (scene as StartingAreaScene).area.anchors.get("gate", Vector3.INF) as Vector3
		if gate != Vector3.INF:
			await _route_walk(scene, gate, "the cave gate again", 0.8)
			await driver.tap_key(KEY_E)
			await _settle(scene, 3.0)
	if spot != "":
		await _go_and_use(scene, spot, "the dungeon door again (%s)" % expected_key, false)
		await _settle(scene, 4.0)
	var map: Node = await _wait_for_short(DungeonMapScreen)
	if map != null:
		await driver.seconds(1.0)
		return
	_issue("SHORTCUT", "re-entered %s by its call (no door by play from %s)" % [expected_key, _where()])
	await super._reenter(expected_key)


func _wall(text: String) -> void:
	_issue("BLOCKER", "WALL %s - the bot could not win in %d tries; decreed to see the rest" % [text, STRICT_TRIES])
	super._wall(text)


# ---- 1b. Maren's early-game chain, played --------------------------------------------------------------------------------------------------


func _early_chain(town: TownScene) -> void:
	await _settle(town, 3.0)
	# Maren's welcome: she gives Meet the Merchants
	if not Session.flag(&"maren_met"):
		await _walk_up(town, "elder")
		await driver.tap_key(KEY_E)
		await _click_through(town)
	_step(Session.flag(&"maren_met") or Session.quest_log.is_active(QuestDefinitions.MERCHANTS), "strict: Maren's welcome is heard")
	# Meet the Merchants: Tilly (her gift), equip it, Sable (a card), Pip
	await _talk_at(town, "item_vendor", "Tilly Tonic")
	await _close_screens()
	if Session.item_tutorial_open():
		var item: ItemData = Session.content.item(Session.TILLY_GIFT_ITEM)
		var slot: int = 0
		if item != null and Session.profile.equip_item_id(item, slot):
			Session.note_item_equipped(item)
			_ui("Character page: equipped Tilly's Power Wraps (CharacterScreen.equip_selected_into's calls)")
	await _talk_at(town, "vendor", "Sable")
	await _close_screens()
	if int(Session.counters.get("cards_bought", 0)) < 1:
		var bought: int = _shop([Session.profile.primary_affinity] as Array[Affinity.Type])
		_ui("Sable's shop: bought %d cards (the shop's buy calls)" % bought)
		Session.refresh_quests()
	await _talk_at(town, "tailor", "Pip Threadwell")
	await _close_screens()
	await _hand_in(town, QuestDefinitions.MERCHANTS)
	# Make It Yours: open a pack, save the deck at the Deck Station
	if Session.quest_log.is_active(QuestDefinitions.FIRST_DECK_EDIT):
		var opened: int = PacksScreen.open_all().size()
		_ui("Packs page: opened %d packs (PacksScreen.open_all)" % opened)
		await _walk_up(town, "deck")
		await driver.tap_key(KEY_E)
		await driver.seconds(1.0)
		if not Session.flag(&"deck_edited"):
			Session.save_deck_to_slot(Session.deck_box.active, Session.deck, Session.deck.deck_name)
			_ui("Deck Station: saved the deck to its slot (Session.save_deck_to_slot, the Save button's call)")
		await _close_screens()
		await _hand_in(town, QuestDefinitions.FIRST_DECK_EDIT)
	# The store room ghosts
	if Session.quest_log.is_active(QuestDefinitions.GHOSTS):
		await _walk_up(town, StoreroomGhosts.SPOT_ID)
		await driver.tap_key(KEY_E)
		await _settle(town, 3.0)
		var battle: BattleScreen = await _wait_for_short(BattleScreen) as BattleScreen
		var tries: int = 0
		while battle != null and tries < STRICT_TRIES:
			tries += 1
			await _win(battle, "the store room ghosts (try %d)" % tries)
			town = await _wait_for(TownScene) as TownScene
			await driver.seconds(1.5)
			await _clear_overlays(town)
			if Session.flag(StoreroomGhosts.FLAG_CLEARED):
				break
			await _walk_up(town, StoreroomGhosts.SPOT_ID)
			await driver.tap_key(KEY_E)
			await _settle(town, 3.0)
			battle = await _wait_for_short(BattleScreen) as BattleScreen
		if not Session.flag(StoreroomGhosts.FLAG_CLEARED):
			_issue("BLOCKER", "the store room ghosts were not beaten (%d tries)" % tries)
		await _hand_in(town, QuestDefinitions.GHOSTS)
	# Some Assembly Required: report, win one fight on the outskirts, collect, equip
	if Session.quest_log.is_active(QuestDefinitions.ARMORY) or not Session.quest_log.is_completed(QuestDefinitions.ARMORY):
		if not Session.quest_log.is_active(QuestDefinitions.ARMORY):
			await _walk_up(town, "elder")
			await driver.tap_key(KEY_E)
			await _click_through(town)
		await _talk_at(town, "equipment_vendor", "Bertram")
		await _close_screens()
		var won_before: int = int(Session.counters.get("duels_won", 0))
		for attempt: int in range(STRICT_TRIES):
			if int(Session.counters.get("duels_won", 0)) > won_before:
				break
			town = await _fight_roamer(town, QuestDefinitions.OUTSKIRTS_SPOT, "the armory's one fight (try %d)" % (attempt + 1))
			if town == null:
				return
		await _talk_at(town, "equipment_vendor", "Bertram")
		await _close_screens()
		if Session.equipment_tutorial_open():
			for piece: EquipmentData in Session.profile.owned_equipment:
				if piece != null and Session.equip_item(piece):
					_ui("Character page: equipped %s (Session.equip_item, the Weapon slot's call)" % piece.source_name)
					break
		await _clear_overlays(town)
	_step(Session.quest_log.is_completed(QuestDefinitions.ARMORY), "Maren's early-game chain is done (merchants, deck edit, ghosts, armory)")
	if not Session.quest_log.is_completed(QuestDefinitions.ARMORY):
		_issue("BLOCKER", "Settling In did not finish by play (merchants %s, deck %s, ghosts %s, armory %s)" % [Session.quest_log.is_completed(QuestDefinitions.MERCHANTS), Session.quest_log.is_completed(QuestDefinitions.FIRST_DECK_EDIT), Session.quest_log.is_completed(QuestDefinitions.GHOSTS), Session.quest_log.is_completed(QuestDefinitions.ARMORY)])
	_chapter("Chapter 1: Crosspath, Settling In")


## The town the story bot holds may have been freed by a fight in between: always the live one.
func _live_town() -> TownScene:
	var scene: Node = get_tree().current_scene
	if scene is TownScene:
		return scene as TownScene
	return await _to_town()


func _brannoch(_town: TownScene) -> TownScene:
	var town: TownScene = await _live_town()
	if town == null:
		return null
	return await super._brannoch(town)


func _talk_at(_town: TownScene, spot_id: String, who: String) -> void:
	var town: TownScene = await _live_town()
	await _clear_overlays(town)
	await _walk_up(town, spot_id)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _settle(town, 2.5)
	print("%s: talked to %s" % [TAG, who])


func _hand_in(_town: TownScene, quest_id: String) -> void:
	if Session.quest_log.is_completed(quest_id):
		return
	var town: TownScene = await _live_town()
	await _clear_overlays(town)
	await _walk_up(town, "elder")
	await driver.tap_key(KEY_E)
	await _click_through(town)
	if not Session.quest_log.is_completed(quest_id):
		_issue("BLOCKER", "Maren did not take %s back (steps met: %s)" % [quest_id, _steps_met(quest_id)])


func _steps_met(quest_id: String) -> String:
	var quest: QuestData = QuestCatalog.find(quest_id)
	if quest == null:
		return "?"
	var met: PackedStringArray = []
	for i: int in range(quest.objectives.size()):
		met.append("%s" % ("x" if Session.quest_log.objective_met(quest, i, Session.unlock_state()) else "."))
	return "".join(met)


## Walks into the roamer a spot stands for (real keys; touching it starts the fight) and plays the fight.
func _fight_roamer(scene: Node, spot_id: String, label: String) -> Node:
	var deadline: int = Time.get_ticks_msec() + 90000
	while Time.get_ticks_msec() < deadline:
		var here: Node = get_tree().current_scene
		if here is BattleScreen:
			await _win(here as BattleScreen, label)
			var back: Node = await _wait_for_walkable()
			if back != null:
				await driver.seconds(1.2)
				await _settle(back, 2.0)
				await _dismiss_popups()
			return back
		if here != scene:
			scene = here
		var pos: Vector3 = _resolve(scene, spot_id)
		if spot_id == QuestDefinitions.OUTSKIRTS_SPOT and scene is TownScene:
			pos = _nearest_roamer(scene as TownScene)
		if pos == Vector3.INF:
			_issue("GUESS", "no roamer for %s" % label)
			return scene
		await _route_walk(scene, pos, label, 0.4)
		await driver.seconds(0.3)
	_issue("GUESS", "never caught a roamer for %s" % label)
	return get_tree().current_scene


func _nearest_roamer(town: TownScene) -> Vector3:
	var best: Vector3 = Vector3.INF
	for enemy: ZoneEnemy in town.enemies:
		if is_instance_valid(enemy) and enemy.is_inside_tree() and enemy.visible:
			if best == Vector3.INF or enemy.position.distance_to(town.player.position) < best.distance_to(town.player.position):
				best = enemy.position
	return best


func _wait_for_walkable() -> Node:
	var elapsed: float = 0.0
	while elapsed < 40.0:
		var scene: Node = get_tree().current_scene
		if scene != null and not SceneManager.busy and (scene is TownScene or scene is ZoneScene or scene is StartingAreaScene):
			return scene
		if scene is RewardsScreen:
			await _take_rewards(scene as RewardsScreen)
		elif scene is BattleScreen and (scene as BattleScreen).mode == BattleScreen.Mode.OVER and (scene as BattleScreen)._result_shown:
			(scene as BattleScreen)._continue()
		await driver.seconds(0.3)
		elapsed += 0.3
	return null


# ---- 3. One zone, played ---------------------------------------------------------------------------------------------------------------------


func _zone(_town: TownScene, zone_id: String) -> TownScene:
	_current_zone = zone_id
	var town: TownScene = await _live_town()
	if town == null:
		return null
	var main_id: String = QuestDefinitions.zone_main_id(zone_id)
	# The gatekeeper: walk up, E, the duel; a loss: walk up again.
	var tries: int = 0
	while not Gatekeepers.is_cleared(Session.flags, zone_id) and tries < STRICT_TRIES:
		tries += 1
		await _clear_overlays(town)
		_tend_deck("before %s gatekeeper try %d" % [zone_id, tries])
		await _walk_up(town, "npc_%s" % zone_id)
		await driver.tap_key(KEY_E)
		await _dismiss_dialogue(town.dialogue)
		var battle: BattleScreen = await _wait_for_short(BattleScreen) as BattleScreen
		if battle == null:
			_issue("BLOCKER", "%s: talking to the gatekeeper started no duel (try %d)" % [zone_id, tries])
			continue
		await _win(battle, "%s gatekeeper (try %d)" % [zone_id, tries])
		town = await _wait_for(TownScene) as TownScene
		if town == null:
			return null
		await driver.seconds(1.5)
		await _dismiss_dialogue(town.dialogue)
		await _dismiss_popups()
	if not Gatekeepers.is_cleared(Session.flags, zone_id):
		_issue("BLOCKER", "%s gatekeeper not beaten in %d tries" % [zone_id, tries])
		return town
	if not Session.flag(StringName(PathDirection.FLAG)):
		town = await _path_direction(town)
	# Down the road into the zone, on foot from wherever the hero is.
	var mouth: Vector3 = town.town.anchors["portal_%s_mouth" % zone_id] as Vector3
	var out: Vector3 = TownBuilder.PORTAL_OUT[zone_id] as Vector3
	await _clear_overlays(town)
	await _route_walk(town, mouth + out * 1.5, "the road to %s" % zone_id, 0.6)
	if get_tree().current_scene == town:
		await _walk_to(town, mouth + out * 3.0, 4.0)
	var zone: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	_step(zone != null and zone.def.id == zone_id, "%s: walking down the road enters the zone" % zone_id)
	if zone == null:
		_issue("BLOCKER", "%s: the road did not lead into the zone" % zone_id)
		return await _to_town()
	await driver.seconds(2.0)
	await _settle(zone, 2.0)
	await _dismiss_popups()
	await _save_load("enter_%s" % zone_id, ZoneScene)
	zone = get_tree().current_scene as ZoneScene
	# A favour, played: the zone's side-dungeon quest where it has one, else the first favour - talk, follow its markers, hand it in.
	zone = await _favour(zone, zone_id)
	if zone == null:
		return await _to_town()
	# The main dungeon: walk to its door, E, Enter, play every node.
	var nth_dungeon: String = (["D-HOG", "D-HFA", "D-TTK", "D-ROT"] as Array[String])[mini(Session.completed_zone_count(), 3)]
	await _go_and_use(zone, "main_dungeon", "%s main dungeon door" % zone_id)
	await _settle(zone, 4.0)
	var main_map: Node = await _wait_for_short(DungeonMapScreen)
	_step(main_map != null, "%s: the main dungeon opens from its door" % zone_id)
	if main_map == null:
		_issue("BLOCKER", "%s: the main dungeon door did not open" % zone_id)
		Session.begin_zone_visit(zone_id)
		Session.enter_main_dungeon()
		main_map = await _wait_for(DungeonMapScreen)
	await _boss_for_real(func() -> bool: return Session.is_zone_completed(zone_id), "%s boss" % zone_id, nth_dungeon)
	_step(Session.is_zone_completed(zone_id), "%s: beating the boss frees the zone" % zone_id)
	_step(Session.quest_log.is_completed(main_id), "%s: its main quest line completes" % zone_id)
	_chapter("Zone %d: %s freed" % [Session.completed_zone_count(), zone_id])
	# Back to town on foot: the zone's exit.
	town = await _leave_to_town()
	if town == null:
		return null
	await _dismiss_popups()
	await _walk_up(town, "elder")
	await driver.tap_key(KEY_E)
	await _click_through(town)
	_step(Session.pending_memory() == 0, "%s: Maren gives back a memory fragment" % zone_id)
	var reloaded: Node = await _save_load("town_after_%s" % zone_id, TownScene)
	if reloaded is TownScene:
		town = reloaded as TownScene
	if town._npcs.has("rescuer"):
		await _walk_up(town, "rescuer")
		await driver.tap_key(KEY_E)
		await _click_through(town)
	return town


## A favour for the locals, done by play. Returns the zone scene (or null if it was lost).
func _favour(zone: ZoneScene, zone_id: String) -> ZoneScene:
	var side_quest: String = str(QuestDefinitions.ZONE_SIDE_QUEST.get(zone_id, ""))
	var side_plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone(zone_id)
	var use_side: bool = side_plan != null and side_quest != "" and zone_id != "beefcake"
	var quest_id: String = side_quest if use_side else str((FAVOURS[zone_id] as Dictionary)["quest"])
	var giver: Array = ZoneQuestDefinitions.GIVERS.get(quest_id, []) as Array
	if giver.size() != 2:
		_issue("GUESS", "%s: no giver for %s" % [zone_id, quest_id])
		return zone
	var giver_spot: String = str(giver[1])
	await _go_and_use(zone, giver_spot, "%s favour giver (%s)" % [zone_id, quest_id])
	await _settle(zone, 3.0)
	if not Session.quest_log.is_active(quest_id) and not Session.quest_log.is_completed(quest_id):
		# a first talk can be a long greeting; the offer comes on the next
		await _go_and_use(zone, giver_spot, "%s favour giver, again" % zone_id, false)
		await _settle(zone, 3.0)
	if not Session.quest_log.is_active(quest_id) and not Session.quest_log.is_completed(quest_id):
		_issue("BLOCKER", "%s: %s was not offered by %s" % [zone_id, quest_id, giver_spot])
		return zone
	Session.quest_log.track(quest_id)
	_ui("Quest log: tracked %s" % quest_id)
	if use_side:
		zone = await _side_dungeon(zone, zone_id, quest_id, side_plan)
	else:
		zone = await _follow_quest(zone, quest_id, 600.0)
	if zone == null:
		return null
	if not Session.quest_log.is_completed(quest_id):
		await _go_and_use(zone, giver_spot, "%s favour turn-in" % zone_id)
		await _settle(zone, 3.0)
	_step(Session.quest_log.is_completed(quest_id), "%s: the favour %s is done by play" % [zone_id, quest_id])
	if not Session.quest_log.is_completed(quest_id):
		_issue("BLOCKER", "%s: %s not finished by play (steps %s) - finished by its flags" % [zone_id, quest_id, _steps_met(quest_id)])
		if quest_id == str((FAVOURS[zone_id] as Dictionary)["quest"]):
			_finish_favour(quest_id)
		Session.turn_in_quest(quest_id)
	var gear: String = str(QuestDefinitions.MIDPOINT_GEAR[zone_id])
	_step(Session.owned_equipment_ids().has(gear), "%s: a favour done pays the midpoint gear (%s)" % [zone_id, gear])
	return get_tree().current_scene as ZoneScene


## The zone's side dungeon: its quest opens it; walk to its entrance, E, Enter, play it, hand the quest in.
func _side_dungeon(zone: ZoneScene, zone_id: String, quest_id: String, plan: DungeonCatalog.Blueprint) -> ZoneScene:
	# the side quest's own steps first (follow its markers) until the dungeon is open
	if not Session.side_unlocked(plan.id):
		zone = await _follow_quest(zone, quest_id, 420.0, func() -> bool: return Session.side_unlocked(plan.id))
		if zone == null:
			return null
	if not Session.side_unlocked(plan.id):
		_issue("BLOCKER", "%s: the side dungeon %s did not open by play (quest steps %s)" % [zone_id, plan.id, _steps_met(quest_id)])
		return zone
	await _go_and_use(zone, "mini_dungeon", "%s side dungeon door" % zone_id)
	await _settle(zone, 4.0)
	var map: Node = await _wait_for_short(DungeonMapScreen)
	if map == null:
		_issue("BLOCKER", "%s: the side dungeon door did not open" % zone_id)
		return zone
	await _boss_for_real(func() -> bool: return Session.flag(Session.side_cleared_flag(plan)), "%s side dungeon %s" % [zone_id, plan.id], plan.id)
	var back: Node = await _wait_for_walkable()
	await driver.seconds(1.0)
	if back != null:
		await _settle(back, 2.0)
	_chapter("%s side dungeon %s" % [zone_id, plan.id])
	return back as ZoneScene


## Follows a quest's markers in the current zone: walks to the nearest marked place of its current step, presses E (or walks into a
## roamer), plays what that opens. Stops when the quest is done (or `until` says so), or nothing marks the step.
func _follow_quest(zone: ZoneScene, quest_id: String, limit: float, until: Callable = Callable()) -> ZoneScene:
	var started: int = Time.get_ticks_msec()
	var tried: Dictionary = {}
	while float(Time.get_ticks_msec() - started) / 1000.0 < limit:
		var here: Node = get_tree().current_scene
		if here is BattleScreen:
			await _win(here as BattleScreen, "%s (a step's fight)" % quest_id)
			here = await _wait_for_walkable()
		elif here is DungeonMapScreen:
			await _boss_for_real(func() -> bool: return not Session.in_dungeon(), "%s (a step's dungeon)" % quest_id, Session.dungeon_key)
			here = await _wait_for_walkable()
		if not (here is ZoneScene):
			return here as ZoneScene
		zone = here as ZoneScene
		await _settle(zone, 1.0)
		if Session.quest_log.is_completed(quest_id) or (until.is_valid() and until.call()):
			return zone
		var quest: QuestData = QuestCatalog.find(quest_id)
		var step: int = Session.quest_log.current_index(quest, Session.unlock_state()) if quest != null else -1
		# every place this quest's step marks in this zone
		var places: Array[Vector3] = []
		var spot_ids: Array[String] = []
		for target: Dictionary in QuestMarkers.all_targets(zone.def.id, Session.quest_log, Session.unlock_state()):
			if str(target.get("quest", "")) != quest_id:
				continue
			var where: Dictionary = zone.quest_markers.resolve.call(str(target["spot"])) as Dictionary
			if where.has("many"):
				for entry: Variant in where["many"] as Array:
					places.append((entry as Dictionary)["pos"] as Vector3)
					spot_ids.append(str(target["spot"]))
			elif not where.is_empty():
				places.append(where["pos"] as Vector3)
				spot_ids.append(str(target["spot"]))
		if places.is_empty():
			# a turn-in: the giver's "?"
			var giver: Array = ZoneQuestDefinitions.GIVERS.get(quest_id, []) as Array
			if quest != null and Session.quest_log.is_active(quest_id) and step >= quest.objectives.size() and giver.size() == 2:
				await _go_and_use(zone, str(giver[1]), "%s turn-in" % quest_id)
				await _settle(zone, 3.0)
				continue
			_issue("MARKER", "%s step %d (%s): nothing marked in %s" % [quest_id, step, quest.objectives[step].text if quest != null and step >= 0 and step < quest.objectives.size() else "?", zone.def.id])
			return zone
		var from: Vector3 = zone.player.position
		var best: int = -1
		for i: int in range(places.size()):
			var key: String = "%d|%.0f|%.0f" % [step, places[i].x, places[i].z]
			if int(tried.get(key, 0)) >= 2:
				continue
			if best < 0 or places[i].distance_to(from) < places[best].distance_to(from):
				best = i
		if best < 0:
			_issue("GUESS", "%s step %d: every marked place tried twice without progress" % [quest_id, step])
			return zone
		var key_best: String = "%d|%.0f|%.0f" % [step, places[best].x, places[best].z]
		tried[key_best] = int(tried.get(key_best, 0)) + 1
		await _route_walk(zone, places[best], "%s step %d (%s)" % [quest_id, step, spot_ids[best]], 0.9)
		if get_tree().current_scene == zone:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.5)
			await _settle(zone, 3.0)
			await _close_screens_if_any(zone)
	_issue("GUESS", "%s: not done after %.0f s of following its markers (steps %s)" % [quest_id, limit, _steps_met(quest_id)])
	return get_tree().current_scene as ZoneScene


func _close_screens_if_any(zone: Variant) -> void:
	if not is_instance_valid(zone) or not (zone is ZoneScene):
		return
	if zone._overlay != null and is_instance_valid(zone._overlay):
		await _close_screens()


## Leaves a zone on foot through its exit (E, Leave).
func _leave_to_town() -> TownScene:
	var scene: Node = await _wait_for_walkable()
	if scene is TownScene:
		return scene as TownScene
	if scene is ZoneScene:
		var zone: ZoneScene = scene as ZoneScene
		await _settle(zone, 2.0)
		await _dismiss_popups()
		await _go_and_use(zone, "exit", "the way back to town", false)
		await driver.seconds(0.5)
		var leave: Button = driver.find_button("Leave")
		if leave != null:
			await driver.click(driver.button_center(leave))
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_issue("TRAPPED", "the zone's exit did not lead to town; went by the scene call")
		return await _to_town()
	await driver.seconds(2.0)
	await _settle(town, 2.0)
	await _dismiss_popups()
	return town


# ---- 5. The Capital, played ----------------------------------------------------------------------------------------------------------------


func _capital_and_castle() -> void:
	if _arg("resume", "").is_empty():
		await _save_progress("capital_ready")
	var town: TownScene = get_tree().current_scene as TownScene
	if town == null:
		town = await _leave_to_town()
	if town == null:
		return
	var mouth: Vector3 = town.town.anchors["portal_final_mouth"] as Vector3
	await _clear_overlays(town)
	await _route_walk(town, mouth + Vector3(0.0, 0.0, -1.5), "the imperial road to the Capital", 0.6)
	if get_tree().current_scene == town:
		await _walk_to(town, mouth + Vector3(0.0, 0.0, -3.0), 4.0)
	var capital: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	_step(capital != null and capital.def.id == CapitalZone.ID, "the imperial road enters the Capital")
	if capital == null:
		_issue("BLOCKER", "the imperial road did not lead to the Capital")
		return
	await driver.seconds(2.0)
	await _settle(capital, 3.0)
	await _dismiss_popups()
	_step(CapitalDebuffs.active(Session.flags).is_empty(), "with all four zones free, every broken service is restored")
	# Under the Capital: Spotless at the gate, the manhole, Fig Sly
	var tries: int = 0
	while not Session.flag(StringName(CapitalZone.FLAG_INSIDE)) and not Session.flag(StringName(CapitalZone.FLAG_HUB_KNOWN)) and tries < STRICT_TRIES:
		tries += 1
		capital = get_tree().current_scene as ZoneScene
		if capital == null:
			capital = await _wait_for(ZoneScene) as ZoneScene
		await _go_and_use(capital, "spotless", "Captain Spotless at the great gate")
		await _settle(capital, 3.0)
		var battle: BattleScreen = await _wait_for_short(BattleScreen) as BattleScreen
		if battle != null:
			await _win(battle, "Captain Spotless (try %d)" % tries)
			await _wait_for_walkable()
			await driver.seconds(1.5)
		else:
			break
	capital = await _wait_for(ZoneScene) as ZoneScene
	await _settle(capital, 2.0)
	_chapter("The Capital: through the gate")
	if not Session.flag(StringName(CapitalZone.FLAG_HUB_KNOWN)):
		await _go_and_use(capital, "manhole", "the manhole on the Gate Plaza")
		await _settle(capital, 4.0)
		capital = await _wait_for(ZoneScene) as ZoneScene
		await driver.seconds(1.0)
		await _settle(capital, 2.0)
	_step(Session.flag(StringName(CapitalZone.FLAG_HUB_KNOWN)), "strict: the manhole leads to the Crease")
	if not Session.flag(StringName(QuestDefinitions.FLAG_BLACK_MARKET_SEEN)):
		await _go_and_use(capital, "fig", "Fig Sly's Black Market")
		await _settle(capital, 3.0)
		await _close_screens()
	_step(Session.flag(StringName(QuestDefinitions.FLAG_BLACK_MARKET_SEEN)), "strict: Fig Sly's Black Market is browsed")
	_tend_deck("before the castle")
	_chapter("The Capital: the Crease")
	# The castle: walk to its door (from the Crease that means back up), E, Enter.
	capital = get_tree().current_scene as ZoneScene
	await _go_and_use(capital, "castle_door", "Primm's Castle door")
	await _settle(capital, 4.0)
	var castle: DungeonMapScreen = await _wait_for_short(DungeonMapScreen) as DungeonMapScreen
	if castle == null:
		_issue("BLOCKER", "the castle door did not open the castle")
		Session.begin_zone_visit(CapitalZone.ID)
		Session.enter_main_dungeon()
		castle = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	_step(castle != null, "the castle opens")
	if castle != null:
		await driver.seconds(1.5)
		await _dismiss_dialogue(castle._dialogue)
	await _boss_for_real(func() -> bool: return Session.flag(&"primm_defeated"), "Primm", "D-PC")
	_step(Session.flag(&"primm_defeated"), "Primm is defeated")
	_chapter("The castle and Primm")
	var ending: Node = await _wait_for(EndingScreen)
	if ending == null:
		_issue("BLOCKER", "the ending did not start by itself after Primm")
		return
	await _shot("p_ending")
	await _play_ending(ending as EndingScreen)
	await _after_the_ending()


## The ending's beats, the credits, the postgame card - with E and clicks only - until the game is back in the Capital.
func _play_ending(ending: EndingScreen) -> void:
	var started: int = Time.get_ticks_msec()
	var credits_seen: bool = false
	while float(Time.get_ticks_msec() - started) / 1000.0 < 900.0:
		var scene: Node = get_tree().current_scene
		if scene is ZoneScene and not SceneManager.busy:
			break
		if is_instance_valid(ending) and ending._credits_running and not credits_seen:
			credits_seen = true
			print("%s: CREDITS start after %.0f s of ending" % [TAG, float(Time.get_ticks_msec() - started) / 1000.0])
			await _shot("p_credits")
		if driver.find_button("Continue") != null:
			await driver.click(driver.button_center(driver.find_button("Continue")))
		elif not credits_seen:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.8 if not credits_seen else 2.0)
	_step(credits_seen, "strict: the credits roll after the ending")
	_step(get_tree().current_scene is ZoneScene, "strict: after the credits the game returns to the world by itself")
	if not (get_tree().current_scene is ZoneScene):
		_issue("BLOCKER", "after the credits the game did not return to the world in 15 minutes (scene %s)" % _where())
	_chapter("The ending and the credits")


## After the credits: the funeral in Grave Row through Old Hob, back to Crosspath on foot, Brannoch's gate, Maren, then the postgame's
## first step (the tracked quest: Under the Forest).
func _after_the_ending() -> void:
	var capital: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	if capital == null:
		Session.return_from_ending()
		_issue("BLOCKER", "no Capital after the ending; returned by the call")
		capital = await _wait_for(ZoneScene) as ZoneScene
		if capital == null:
			return
	await driver.seconds(2.0)
	await _settle(capital, 3.0)
	await _dismiss_popups()
	var tracked: String = Session.quest_log.tracked_id()
	print("%s: after the credits the tracked quest is %s" % [TAG, tracked])
	_step(OldHob.funeral_waiting(Session.flags), "the royal funeral waits in Grave Row")
	await _go_and_use(capital, ZoneScene.OLD_HOB_KEY, "Old Hob in Grave Row (the funeral)")
	var guard: int = 0
	while guard < 40 and not Session.flag(&"royal_funeral_seen"):
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.3)
	_step(Session.flag(&"royal_funeral_seen"), "the royal funeral plays")
	var town: TownScene = await _leave_to_town()
	if town == null:
		return
	await _walk_up(town, "guard")
	await driver.tap_key(KEY_E)
	await _click_through(town)
	_step(Session.flag(&"isla_home"), "Isla walks home through her father's gate")
	await _walk_up(town, "elder")
	await driver.tap_key(KEY_E)
	await _click_through(town)
	_step(Session.flag(&"maren_capture_seen"), "Maren has news of the capture")
	# the first postgame step: whatever the tracker shows now, followed in town
	var now_tracked: String = Session.quest_log.tracked_id()
	print("%s: postgame tracked quest: %s" % [TAG, now_tracked])
	await _walk_up(town, "rift_station")
	await driver.tap_key(KEY_E)
	await _dismiss_dialogue(town.dialogue)
	_step(Session.flag(&"rip_forest_tip"), "postgame: Rip tells of the forest (the first postgame step)")
	await _close_screens()
	_chapter("Postgame: the first step")


func _postgame() -> void:
	pass  # Part 1 of Nov 17 stops at the first postgame step (the rest is the late-game critic's)


func _undercroft(town: TownScene) -> void:
	pass  # an optional side room: not on the story's path
