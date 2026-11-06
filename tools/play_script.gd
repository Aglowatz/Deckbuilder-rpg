class_name PlayScript
extends Node
## Fresh eyes Oct 30: a generic "play script" driver. Plays the real game from the title screen with injected keys, mouse clicks and
## screenshots, following a plain text script, so a reviewer can play like a new player without writing GDScript. Windowed:
##   bash tools/play.sh <script.txt> [run_name]     -> _screenshots/play/<run_name>/<shot>.png + play.log
## One command per line, `#` comments. Coordinates are SCREENSHOT pixels (the window, 1600x900 by default), not canvas units.
##   wait <seconds>                 let the game run
##   key <Name>                     tap a key: E, Space, Escape, Enter, W, Tab, F10, Up, Down, Left, Right, 1 ...
##   hold <Name>[+<Name>] <seconds> hold one or more keys (walking: hold W 2, hold W+A 1.5)
##   click <x> <y>                  left click; rclick <x> <y> right click; move <x> <y> hover
##   drag <x1> <y1> <x2> <y2>       drag and drop (playing a card)
##   button <text>                  click the first visible button whose text contains <text>
##   shot <name>                    save a screenshot
##   dump                           print every visible label and button (text + screenshot position) to the log
##   scene                          print the current scene and the hero's state (level, gold, hp)
##   pilot <seconds>                let a simple built-in player play the current battle for up to that long (mulligan, plays, attacks, blocks)
##   skip_dialogue [max]            tap E until no dialogue box / story still / popup is open (max taps, default 40)
##   dev <action> ...               debug shortcuts: level N | gold N | autowin on|off | win | lose | heal | travel town|forest|capital|arena |
##                                  travel zone <id> | travel dungeon <id> [node] | encounter <spec_id> | quest <id> <step> | freed <zone> |
##                                  gate <zone> | card <id> | item <id> | gear <id> | slots | packs <id> <n> | encounters <query> (list) |
##                                  save <name> / load <name> (a snapshot in user://dev_saves, so a later run can continue where this one stopped) |
##                                  goto <spot id> (the hero onto a talk / use spot of the current zone or town; then `key E`)
##   log <text>                     write a note to the log
## The run stops after --limit seconds (default 900) or at the end of the script; every line is echoed to play.log with a timestamp.

const DEFAULT_LIMIT: float = 900.0

var driver: UiDriver
var _out_dir: String = "res://_screenshots/play/run"
var _log_lines: PackedStringArray = []
var _started_msec: int = 0
var _limit: float = DEFAULT_LIMIT
var _lines: PackedStringArray = []
var _log_file: FileAccess = null


func run() -> void:
	_started_msec = Time.get_ticks_msec()
	var args: Dictionary = _parse_args()
	var script_path: String = str(args.get("script", ""))
	_out_dir = str(args.get("out", _out_dir))
	_limit = float(args.get("limit", DEFAULT_LIMIT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))
	var text: String = FileAccess.get_file_as_string(script_path)
	if text.is_empty():
		_say("play: no script at %s" % script_path)
		_finish()
		return
	_lines = text.split("\n")
	driver = UiDriver.new(get_tree())
	Session.save_enabled = false
	await driver.frames(5)
	SceneManager.go_to_title()
	await driver.seconds(1.5)
	for raw: String in _lines:
		if float(Time.get_ticks_msec() - _started_msec) / 1000.0 > _limit:
			_say("play: time limit reached")
			break
		var line: String = raw.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		_say("> " + line)
		await _run_line(line)
	_finish()


func _parse_args() -> Dictionary:
	var result: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--") and arg.contains("="):
			var parts: PackedStringArray = arg.trim_prefix("--").split("=", true, 1)
			result[parts[0]] = parts[1]
	return result


func _run_line(line: String) -> void:
	var parts: PackedStringArray = line.split(" ", false)
	var command: String = parts[0].to_lower()
	var rest: String = line.substr(parts[0].length()).strip_edges()
	match command:
		"wait":
			await driver.seconds(float(parts[1]) if parts.size() > 1 else 1.0)
		"key":
			var code: Key = _keycode(parts[1] if parts.size() > 1 else "E")
			if code == KEY_NONE:
				_say("  unknown key %s" % rest)
			else:
				await driver.tap_key(code)
				await driver.frames(2)
		"hold":
			var codes: Array[Key] = []
			for name: String in (parts[1] if parts.size() > 1 else "W").split("+", false):
				var code: Key = _keycode(name)
				if code != KEY_NONE:
					codes.append(code)
			for code: Key in codes:
				await driver.key(code, true)
			await driver.seconds(float(parts[2]) if parts.size() > 2 else 1.0)
			for code: Key in codes:
				await driver.key(code, false)
			await driver.frames(2)
		"click":
			await driver.click(_canvas(parts))
		"rclick":
			await driver.click(_canvas(parts), MOUSE_BUTTON_RIGHT)
		"move":
			await driver.move_to(_canvas(parts))
		"drag":
			if parts.size() >= 5:
				await driver.drag(_canvas(parts), _canvas(parts, 3))
		"button":
			var found: bool = await driver.click_button(rest)
			_say("  button %s: %s" % [rest, "clicked" if found else "NOT FOUND"])
		"shot":
			await _shot(rest if not rest.is_empty() else "shot")
		"dump":
			_dump()
		"scene":
			_scene_info()
		"perf":
			_perf_info()
		"pilot":
			await _pilot(float(parts[1]) if parts.size() > 1 else 60.0)
		"skip_dialogue":
			await _skip_dialogue(int(parts[1]) if parts.size() > 1 else 40)
		"dev":
			await _dev(parts)
		"log":
			pass
		_:
			_say("  unknown command %s" % command)


## Screenshot pixels -> canvas units (the window is scaled from the 1920x1080 design canvas).
func _canvas(parts: PackedStringArray, offset: int = 1) -> Vector2:
	var px: Vector2 = Vector2(float(parts[offset]), float(parts[offset + 1])) if parts.size() > offset + 1 else Vector2(800, 450)
	return get_tree().root.get_final_transform().affine_inverse() * px


func _keycode(name: String) -> Key:
	var candidates: Array[String] = [name, name.to_upper(), name.capitalize(), name.to_lower()]
	var aliases: Dictionary = {"esc": "Escape", "return": "Enter", "spacebar": "Space", "pgup": "PageUp", "pgdn": "PageDown"}
	if aliases.has(name.to_lower()):
		candidates.push_front(str(aliases[name.to_lower()]))
	for candidate: String in candidates:
		var code: Key = OS.find_keycode_from_string(candidate)
		if code != KEY_NONE:
			return code
	return KEY_NONE


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_tree().root.get_texture().get_image()
	var path: String = "%s/%s.png" % [_out_dir, name.validate_filename()]
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	_say("  shot %s (%s)" % [path, "ok" if error == OK else error_string(error)])


func _dump() -> void:
	var transform: Transform2D = get_tree().root.get_final_transform()
	var count: int = 0
	for node: Node in get_tree().root.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if control == null or not control.is_visible_in_tree():
			continue
		var text: String = ""
		var kind: String = ""
		if control is Button:
			text = (control as Button).text
			kind = "button"
		elif control is Label:
			text = (control as Label).text
			kind = "label"
		elif control is RichTextLabel:
			text = (control as RichTextLabel).get_parsed_text()
			kind = "rich"
		if text.strip_edges().is_empty():
			continue
		var center: Vector2 = transform * control.get_global_rect().get_center()
		var line: String = text.strip_edges().replace("\n", " / ")
		if line.length() > 160:
			line = line.substr(0, 160) + "..."
		_say("  [%s @ %d,%d] %s" % [kind, int(center.x), int(center.y), line])
		count += 1
		if count >= 120:
			_say("  ... (more)")
			break
	if count == 0:
		_say("  (no visible text)")


## Critic pass Nov 6: memory and frame rate right now (for the tech critic): static memory, video memory, FPS, the process frame time.
func _perf_info() -> void:
	var out: Array = []
	OS.execute("tasklist", ["/FI", "PID eq %d" % OS.get_process_id(), "/FO", "CSV", "/NH"], out)
	var working_set: String = str(out[0]).strip_edges().split("\",\"")[-1].replace("\"", "") if out.size() > 0 else "?"
	_say("  perf process_working_set %s" % working_set)
	_say("  perf static_mb %.0f peak_static_mb %.0f video_mb %.0f fps %d frame_ms %.1f objects %d nodes %d" % [OS.get_static_memory_usage() / 1048576.0, OS.get_static_memory_peak_usage() / 1048576.0, Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, Engine.get_frames_per_second(), Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, int(Performance.get_monitor(Performance.OBJECT_COUNT)), int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))])


func _scene_info() -> void:
	var scene: Node = get_tree().current_scene
	var state: String = "no game"
	if Session.profile != null:
		state = "level %d, gold %d" % [Session.profile.level, Session.gold]
		if Session.zone_run != null:
			state += ", run hp %d/%d" % [Session.zone_run.hp, Session.zone_run.max_hp()]
	_say("  scene %s (%s); %s" % [scene.name if scene != null else "-", scene.get_class() if scene != null else "-", state])
	# Fable pass Nov 1: in a zone, where the hero stands and the spots within 4 m (their distance and E reach), so a walk script can be aimed.
	if scene is ZoneScene:
		_say("  " + (scene as ZoneScene).where_am_i())
	elif scene is TownScene:
		_say("  " + (scene as TownScene).where_am_i())


func _find_battle() -> BattleScreen:
	for node: Node in get_tree().root.find_children("*", "BattleScreen", true, false):
		if node is BattleScreen and (node as BattleScreen).is_visible_in_tree():
			return node as BattleScreen
	if get_tree().current_scene is BattleScreen:
		return get_tree().current_scene as BattleScreen
	return null


func _pilot(seconds: float) -> void:
	var battle: BattleScreen = _find_battle()
	if battle == null:
		_say("  pilot: no battle on screen")
		return
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	var started: int = Time.get_ticks_msec()
	var steps: int = 0
	var last_turn: int = -1
	var stuck: int = 0
	while is_instance_valid(battle) and battle.mode != BattleScreen.Mode.OVER and float(Time.get_ticks_msec() - started) / 1000.0 < seconds:
		if battle.busy or battle.mode == BattleScreen.Mode.WAITING:
			await driver.seconds(0.2)
			continue
		# A tutorial tip reads like a player would, then presses Got it; a tip that holds the duel (the tutorial waits for a click the
		# simple player never makes) is skipped once nothing has moved for a while.
		var got_it: Button = driver.find_button("Got it")
		if got_it != null:
			await driver.seconds(0.6)
			await driver.click(driver.button_center(got_it))
			await driver.seconds(0.3)
		var confirm: Button = driver.find_button("End Turn", battle)
		await pilot.act()
		steps += 1
		await driver.seconds(0.25)
		# The end-turn confirm box ("End your turn?" with its own End Turn button, next to the HUD's "End Turn  [Space]"): confirm it.
		for node: Node in get_tree().root.find_children("*", "Button", true, false):
			var dialog: Button = node as Button
			if dialog != confirm and dialog.is_visible_in_tree() and dialog.text.strip_edges() == "End Turn":
				await driver.click(driver.button_center(dialog))
				await driver.seconds(0.2)
				break
		if battle.game != null and battle.game.turn != last_turn:
			last_turn = battle.game.turn
			stuck = 0
		else:
			stuck += 1
		if stuck == 40:
			var skip: Button = driver.find_button("Skip tips")
			if skip != null:
				_say("  pilot: the turn is held by a tip; pressing Skip tips")
				await driver.click(driver.button_center(skip))
		if stuck > 120:
			_say("  pilot: stuck on turn %d" % last_turn)
			break
	_say("  pilot: %d decisions, battle %s" % [steps, "over" if not is_instance_valid(battle) or battle.mode == BattleScreen.Mode.OVER else "still running"])


func _skip_dialogue(max_taps: int) -> void:
	var taps: int = 0
	while taps < max_taps:
		var busy: bool = false
		for node: Node in get_tree().root.find_children("*", "", true, false):
			if not (node is CanvasItem) or not (node as CanvasItem).is_visible_in_tree():
				continue
			var cls: String = node.get_class()
			var script_name: String = str(node.get_script().get_global_name()) if node.get_script() != null else ""
			if script_name in ["DialogueBox", "StoryStillScreen", "PopupFrame", "RewardPopup", "CutsceneScreen", "EndingScreen"] or cls == "AcceptDialog":
				busy = true
				break
		if not busy:
			break
		if await driver.dismiss_reward_box(0.05):
			taps += 1
			continue
		await driver.click(Vector2(960, 540))
		await driver.tap_key(KEY_E)
		await driver.seconds(0.35)
		taps += 1
	_say("  skip_dialogue: %d taps" % taps)


func _dev(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		return
	var what: String = parts[1].to_lower()
	var arg: String = parts[2] if parts.size() > 2 else ""
	var arg2: String = parts[3] if parts.size() > 3 else ""
	var battle: BattleScreen = _find_battle()
	var result: String = ""
	match what:
		"newgame":
			# Overnight Oct 31 - Nov 1: a fresh game as the title's New Game starts one, without the campaign slot screen (every slot on the
			# dev PC holds a save; this driver never saves, so no slot is touched).
			Session.save_enabled = false
			Session.new_game()
			SceneManager.go_to_start_area()
			result = "New game started (no slot touched, saving off)"
		"level":
			result = DevActions.set_level(int(arg), true)
		"gold":
			result = DevActions.add_gold(int(arg))
		"autowin":
			result = DevActions.set_auto_win(arg == "on")
		"win":
			result = DevActions.end_battle(battle, true) if battle != null else "no battle"
		"lose":
			result = DevActions.end_battle(battle, false) if battle != null else "no battle"
		"heal":
			result = DevActions.full_heal(battle)
		"travel":
			match arg:
				"town":
					result = DevActions.travel_town()
				"forest":
					result = DevActions.travel_forest()
				"capital":
					result = DevActions.travel_capital_inside()
				"arena":
					result = DevActions.travel_arena()
				"zone":
					result = DevActions.travel_zone(arg2)
				"dungeon":
					result = DevActions.travel_dungeon(arg2, int(parts[4]) if parts.size() > 4 else -1)
				_:
					result = "unknown travel target %s" % arg
			await driver.seconds(3.0)
		"encounters":
			var found: Array[EncounterSpec] = DevActions.find_encounters(arg, 60)
			for spec: EncounterSpec in found:
				_say("  %s  (%s) %s" % [spec.id, spec.group, spec.enemy_name])
			result = "%d encounters match %s" % [found.size(), arg]
		"encounter":
			var matches: Array[EncounterSpec] = DevActions.find_encounters(arg, 5)
			if matches.is_empty():
				result = "no encounter matches %s" % arg
			else:
				result = DevActions.start_encounter(matches[0].id)
				await driver.seconds(3.0)
		"quest":
			result = DevActions.set_quest_step(arg, int(arg2))
		"freed":
			result = DevActions.set_zone_freed(arg, true)
		"gate":
			result = DevActions.set_gatekeeper(arg, true)
		"card":
			result = DevActions.add_card(arg, false)
		"item":
			result = DevActions.add_item(arg)
		"gear":
			result = DevActions.add_equipment(arg)
		"slots":
			result = DevActions.unlock_deck_slots()
		"packs":
			result = DevActions.add_packs(arg, int(arg2) if not arg2.is_empty() else 1)
		"flag":
			# Fresh eyes round 2 (Oct 31): `dev flag trial_cleared` (or `... off`) - a snapshot taken before the cave was cleared resumes in the
			# forest (`Session.resume_loaded_game`), where the town hotkeys are dead; the mid-game snapshot sets this flag.
			Session.set_flag(StringName(arg), arg2 != "off" and arg2 != "0")
			result = "flag %s = %s" % [arg, str(Session.flag(StringName(arg)))]
		"hand", "energy", "play":
			# Fix pass Nov 4: `dev hand <card id>` puts a card in your battle hand, `dev energy` lays one of every basic infrastructure,
			# `dev play <card id>` plays that hand card as a click would (Peek and other choices then show their real panels).
			if battle == null:
				result = "no battle"
			elif what == "hand":
				var data: CardData = Session.content.card(arg)
				if data == null:
					result = "no card %s" % arg
				else:
					battle.game.players[0].hand.append(battle.game.create_instance(data, 0))
					battle.board.register_all()
					battle.board.sync_state(false)
					battle.board.layout(false)
					result = "%s in hand" % data.display_name
			elif what == "energy":
				for number: int in range(1, 12):
					var infra: CardData = load("res://data/cards/INF-%02d.tres" % number) as CardData
					if infra != null:
						battle.game.players[0].infrastructure.append(battle.game.create_instance(infra, 0))
				battle.board.register_all()
				battle.board.sync_state(false)
				battle.board.layout(false)
				battle.hud.refresh_all()
				result = "energy laid"
			else:
				result = "no %s in hand" % arg
				for card: CardInstance in battle.game.players[0].hand:
					if card.data.id == arg:
						battle._try_play(card.uid)
						result = "played %s" % card.data.display_name
						break
				await driver.seconds(1.5)
		"goto":
			# Batch 11 (Nov 2): `dev goto <spot id>` stands the hero on a talk / use spot of the current zone or town (then `key E` uses it), the
			# walk smokes' shortcut for long legs; the camera follows at once.
			result = _goto_spot(arg)
		"essence":
			# Fix pass Nov 4 (B): `dev essence <path> <n>` sets that Path's essence (Auntie Alembic's crafting check)
			var essence_path: Affinity.Type = Affinity.Type.NEUTRAL
			for candidate: Affinity.Type in Affinity.colored_types():
				if Affinity.display_name(candidate).to_lower() == arg.to_lower():
					essence_path = candidate
			if essence_path == Affinity.Type.NEUTRAL or Session.profile == null:
				result = "essence: unknown Path %s" % arg
			else:
				Session.profile.set_essence(essence_path, int(arg2))
				result = "%s essence = %d" % [arg, Session.profile.essence_of(essence_path)]
		"shiro":
			# Fix pass Nov 4 (B): `dev shiro` opens the five giant chests (the hidden quest) and starts the duel with Shiro Swindle
			for chest_id: String in NinjaBoss.CHEST_IDS:
				Session.open_giant_chest(chest_id)
			Session.pending_popups.clear()
			Session.challenge_ninja()
			result = "Shiro: chests opened, duel started"
		"postgame":
			result = DevActions.set_primm_defeated(true)
		"tp":
			# Fix pass Nov 4 (B): `dev tp <x> <z>` stands the hero at a world position (ground height from the map), camera following - for edge shots
			result = _teleport(arg, arg2)
		"secret":
			# Batch 11: `dev secret harbor_chest` - a found secret (the Secret Dealer's alley opens on the next town load)
			Session.discover_secret(arg)
			result = "secret %s found" % arg
		"save":
			result = DevActions.save_snapshot(arg)
		"load":
			result = DevActions.load_snapshot(arg)
			await driver.seconds(3.0)
		_:
			result = "unknown dev action %s" % what
	_say("  dev: %s" % result)
	await driver.seconds(0.5)


## The hero onto the spot `id` of the current scene (a ZoneScene or the TownScene: both keep `spots`, `player`, `_camera`, `camera_offset`).
func _goto_spot(id: String) -> String:
	var scene: Node = get_tree().current_scene
	if scene == null or not ("spots" in scene) or not ("player" in scene):
		return "goto: no spots in this scene"
	for spot: Variant in scene.get("spots") as Array:
		if str(spot.get("id")) != id:
			continue
		var player: Node3D = scene.get("player") as Node3D
		player.position = spot.get("position") as Vector3
		var camera: Camera3D = scene.get("_camera") as Camera3D
		if camera != null:
			camera.position = player.position + CameraRig.shape(scene.get("camera_offset") as Vector3)
		return "goto %s at %s" % [id, str(player.position)]
	return "goto: no spot %s here" % id


func _teleport(x_text: String, z_text: String) -> String:
	var scene: Node = get_tree().current_scene
	if scene == null or not ("player" in scene):
		return "tp: no hero here"
	var x: float = float(x_text)
	var z: float = float(z_text)
	var player: Node3D = scene.get("player") as Node3D
	var map: Variant = scene.get("builder") if "builder" in scene else null
	var y: float = player.position.y
	if map != null and (map as Object).has_method("height_at"):
		y = float((map as Object).call("height_at", Vector3(x, 0.0, z)))
	player.position = Vector3(x, y, z)
	var camera: Camera3D = scene.get("_camera") as Camera3D
	if camera != null:
		camera.position = player.position + CameraRig.shape((scene.get("camera_offset") if "camera_offset" in scene else scene.get("_camera_offset")) as Vector3)
	return "tp to %s" % str(player.position)


func _say(text: String) -> void:
	var stamp: String = "%6.1f" % (float(Time.get_ticks_msec() - _started_msec) / 1000.0)
	var line: String = "%s %s" % [stamp, text]
	print("play: " + text)
	_log_lines.append(line)
	# Written as it goes, so a run killed at its time limit keeps its log.
	if _log_file == null:
		_log_file = FileAccess.open("%s/play.log" % _out_dir, FileAccess.WRITE)
	if _log_file != null:
		_log_file.store_line(line)
		_log_file.flush()


func _finish() -> void:
	_say("play: done")
	if _log_file != null:
		_log_file.close()
	get_tree().quit(0)
