extends PlayScript
## Nov 27 day (Part A): the random-play soak bot. Plays the real game in a window with random but valid choices, segment after segment:
## the title (settings, load, credits), a new game, the world (Crosspath's people, shops, Auntie Alembic, Pip, the deck station, the
## Bestiary; the four zones and the Capital), the Shuffle House (its four modes, the Shuffled Halls, the Puzzle Tables), zone drafts,
## dungeons and their events, single fights, and a save -> load round trip in the middle of it all. Every step it watches for:
##   - script errors (an engine Logger), and softlocks (a screen whose buttons and keys change nothing, or a screen with no input left);
##   - UI off the screen, buttons on top of each other, text cut off by its box;
##   - placeholder art (the Godot icon, "placeholder"/"missing" textures, a patch of pure magenta on screen);
##   - a save that does not load back the same (to_dict -> from_dict -> to_dict, and a snapshot saved, loaded and resumed).
## The first frame of each new problem is kept, with the seed and the log:
##   bash tools/soak_bot.sh <seed> [minutes] [WxH]   -> docs/overnight_shots/nov27/soak/seed<seed>_<WxH>/ (soak.log, issues.md, *.jpg)
## Never writes the player's saves or settings (--no-save); snapshots go to user://dev_saves/soak_*.json and are deleted at the end.

const LOGGER_SCRIPT: String = "res://tools/soak_bot_logger.gd"
## Button texts the bot never presses (leaving the game, files on disk, the window itself, key capture).
const DENY: Array[String] = ["copy", "restore", "rename", "start over", "quit", "exit game", "exit to desktop", "delete", "erase", "overwrite", "report a problem", "folder", "rebind", "reset all", "reset to default", "fullscreen", "windowed", "borderless", "resolution", "window", "monitor", "v-sync", "vsync", "send report", "copy log", "restore defaults", "safe mode", "new game"]
## Words that close a screen (the bot presses these less often, so it goes deeper first).
const CLOSE_WORDS: Array[String] = ["back", "close", "leave", "done", "cancel", "return", "exit", "not now", "no thanks", "later", "skip", "continue", "ok", "got it"]
## Town spots the bot never uses (dev shortcuts that rewrite the game state).
const SPOT_DENY: Array[String] = ["dev_shrine", "feats"]
## Hotkeys a player presses in the world and on screens.
const KEYS: Array[Key] = [KEY_ESCAPE, KEY_E, KEY_SPACE, KEY_TAB, KEY_M, KEY_I, KEY_J, KEY_C, KEY_K, KEY_Q, KEY_ENTER, KEY_1, KEY_2]
## Scripts of the boxes that hold the game while text is read (clicked through).
const TALK_SCRIPTS: Array[String] = ["DialogueBox", "StoryStillScreen", "CutsceneScreen", "EndingScreen"]
## Error text that is engine noise, not the game's (leaks at exit, shader cache).
const NOISE: Array[String] = ["leaked", "RID allocations", "still in use", "ObjectDB instances", "Pages in use", "shader cache", "BUG: Unreferenced", "resources still in use"]
const SEGMENTS: Array[String] = ["title", "newgame", "town", "town", "zone", "shuffle", "zone_draft", "dungeon", "dungeon", "fight", "fight", "save", "save"]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var seed_value: int = 1
var _issues: Array[Dictionary] = []
var _seen_keys: Dictionary = {}
var _pending_errors: Array[String] = []
var _logger: Object = null
var _segment: String = ""
var _step: int = 0
var _stuck: int = 0
var _last_signature: String = ""
var _last_layout_signature: String = ""
var _counts: Dictionary = {}
var _deadline_msec: int = 0


func run() -> void:
	_started_msec = Time.get_ticks_msec()
	var args: Dictionary = _parse_args()
	seed_value = int(args.get("seed", "1"))
	rng.seed = seed_value
	seed(seed_value)
	_out_dir = str(args.get("out", "res://docs/overnight_shots/nov27/soak/seed%d" % seed_value))
	_limit = float(args.get("limit", "1500"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))
	_log_file = FileAccess.open(ProjectSettings.globalize_path(_out_dir + "/soak.log"), FileAccess.WRITE)
	driver = UiDriver.new(get_tree())
	Session.save_enabled = false
	if not SaveGuard.test_mode():
		_say("soak: refusing to run - the save guard is off (start through tools/soak_bot.sh, which passes --no-save and WAYWARD_TEST_SAVES=1)")
		_finish()
		return
	SceneManager.show_loading_screens = rng.randf() < 0.5
	_install_logger()
	await driver.frames(5)
	_say("soak: seed %d, limit %.0f s, window %s, loading screens %s" % [seed_value, _limit, str(get_window().size), str(SceneManager.show_loading_screens)])
	SceneManager.go_to_title()
	await driver.seconds(2.0)
	await _segment_title()
	var order: Array[String] = SEGMENTS.duplicate()
	var only: String = str(args.get("only", ""))
	while _elapsed() < _limit:
		if not only.is_empty():
			await _run_segment(only)
			continue
		if order.is_empty():
			order = SEGMENTS.duplicate()
			order.erase("title")
		var pick: String = order.pop_at(rng.randi_range(0, order.size() - 1))
		await _run_segment(pick)
	_finish_soak()


func _elapsed() -> float:
	return float(Time.get_ticks_msec() - _started_msec) / 1000.0


# ---- Segments ---------------------------------------------------------------------------------------------------------------------


func _run_segment(name: String) -> void:
	_segment = name
	_counts[name] = int(_counts.get(name, 0)) + 1
	_say("soak: segment %s (%d) at %.0f s" % [name, int(_counts[name]), _elapsed()])
	_deadline_msec = Time.get_ticks_msec() + int(rng.randf_range(90.0, 200.0) * 1000.0)
	match name:
		"title":
			await _segment_title()
		"newgame":
			await _segment_newgame()
		"town":
			await _segment_town()
		"zone":
			await _segment_zone()
		"shuffle":
			await _segment_shuffle()
		"zone_draft":
			await _segment_zone_draft()
		"dungeon":
			await _segment_dungeon()
		"fight":
			await _segment_fight()
		"save":
			await _segment_save()
	await _flush_errors()


func _time_left() -> bool:
	return Time.get_ticks_msec() < _deadline_msec and _elapsed() < _limit


func _segment_title() -> void:
	_segment = "title"
	SceneManager.go_to_title()
	await driver.seconds(1.5)
	await _explore(rng.randi_range(10, 25), true)


func _segment_newgame() -> void:
	Session.save_enabled = false
	Session.new_game()
	SceneManager.go_to_start_area()
	await driver.seconds(4.0)
	while _time_left():
		if rng.randf() < 0.5:
			await _random_walk()
		await _explore(rng.randi_range(4, 10))


## A random game state for the world: a Path, a level, gold, some packs and items, gates beaten and zones freed at random.
func _random_state(min_level: int, max_level: int) -> void:
	Session.save_enabled = false
	Session.new_game()
	var paths: Array[Affinity.Type] = Affinity.colored_types()
	Session.ensure_game(paths[rng.randi_range(0, paths.size() - 1)])
	for flag: String in ["rescuer_met", "trial_cleared", "elder_greeted", "intro_done"]:
		Session.set_flag(StringName(flag))
	DevActions.set_level(rng.randi_range(min_level, max_level), true)
	DevActions.add_gold(rng.randi_range(0, 3000))
	for zone_id: String in ZoneDefs.ids():
		if rng.randf() < 0.5:
			DevActions.set_gatekeeper(zone_id, true)
		if rng.randf() < 0.3:
			DevActions.set_zone_freed(zone_id, true)
	if rng.randf() < 0.25:
		DevActions.set_primm_defeated(true)
	if rng.randf() < 0.5:
		DevActions.unlock_deck_slots()
	var items: Array = Session.content.items.keys()
	for i: int in range(rng.randi_range(0, 3)):
		if not items.is_empty():
			DevActions.add_item(str(items[rng.randi_range(0, items.size() - 1)]))
	var gear: Array[EquipmentData] = DevActions.equipment_choices()
	for i: int in range(rng.randi_range(0, 4)):
		if not gear.is_empty():
			DevActions.add_equipment(gear[rng.randi_range(0, gear.size() - 1)].id)
	_say("  state: %s level %d gold %d" % [Affinity.display_name(Session.profile.primary_affinity), Session.profile.level, Session.gold])


func _segment_town() -> void:
	await _random_state(3, 25)
	DevActions.travel_town()
	await _wait_scene(8.0)
	while _time_left():
		var roll: float = rng.randf()
		if roll < 0.55:
			await _use_random_spot()
		elif roll < 0.75:
			await _random_walk()
		await _explore(rng.randi_range(4, 12))


func _segment_zone() -> void:
	await _random_state(6, 25)
	var zones: Array[String] = ZoneDefs.ids()
	zones.append(CapitalZone.ID)
	var zone_id: String = zones[rng.randi_range(0, zones.size() - 1)]
	if zone_id == CapitalZone.ID:
		DevActions.travel_capital_inside()
	else:
		DevActions.travel_zone(zone_id)
	_say("  zone %s" % zone_id)
	await _wait_scene(10.0)
	while _time_left():
		var roll: float = rng.randf()
		if roll < 0.55:
			await _use_random_spot()
		elif roll < 0.8:
			await _random_walk()
		await _explore(rng.randi_range(4, 12))


func _segment_shuffle() -> void:
	await _random_state(14, 25)
	DevActions.draft("unlock", "", null)
	Session.set_flag(MultiPathLock.FLAG_UNLOCKED)
	DevActions.travel_town()
	await _wait_scene(8.0)
	var scene: Node = get_tree().current_scene
	if scene != null and scene.has_method("_use_shuffle_house"):
		_say("  goto: %s" % _goto_spot(TownShuffleHouse.KEY))
		await driver.seconds(0.5)
		scene.call("_use_shuffle_house")
	await driver.seconds(1.5)
	while _time_left():
		await _explore(rng.randi_range(8, 16))
		if not _overlay_open() and _time_left():
			scene = get_tree().current_scene
			if scene != null and scene.has_method("_use_shuffle_house"):
				scene.call("_use_shuffle_house")
				await driver.seconds(1.0)


func _segment_zone_draft() -> void:
	await _random_state(5, 20)
	var zones: Array[String] = ZoneDefs.ids()
	var zone_id: String = zones[rng.randi_range(0, zones.size() - 1)]
	DevActions.travel_zone(zone_id)
	await _wait_scene(10.0)
	_say("  %s" % DevActions.draft("open", "", get_tree().current_scene))
	await driver.seconds(1.0)
	while _time_left():
		await _explore(rng.randi_range(8, 16))
		if not _overlay_open() and _time_left():
			_say("  %s" % DevActions.draft("open", "", get_tree().current_scene))
			await driver.seconds(1.0)


func _segment_dungeon() -> void:
	await _random_state(5, 25)
	var ids: Array = DevActions.dungeon_choices().keys()
	var dungeon_id: String = str(ids[rng.randi_range(0, ids.size() - 1)])
	_say("  %s" % DevActions.travel_dungeon(dungeon_id))
	await _wait_scene(10.0)
	while _time_left():
		await _explore(rng.randi_range(8, 16))


func _segment_fight() -> void:
	await _random_state(3, 25)
	DevActions.travel_town()
	await _wait_scene(8.0)
	var specs: Array[EncounterSpec] = DevActions.find_encounters("", 2000)
	if specs.is_empty():
		_say("  no encounters")
		return
	var spec: EncounterSpec = specs[rng.randi_range(0, specs.size() - 1)]
	_say("  fight %s (%s)" % [spec.id, spec.enemy_name])
	_say("  %s" % DevActions.start_encounter(spec.id))
	await driver.seconds(3.0)
	while _time_left():
		await _explore(rng.randi_range(6, 12))
		if _find_battle() == null and not _overlay_open():
			break


## The save round trip: the game as a dictionary, loaded back and written again, must come out the same; then a snapshot is saved,
## loaded and resumed, and the hero must come back with the same level, gold, deck, collection, quests and flags.
func _segment_save() -> void:
	if not Session.has_profile():
		await _random_state(3, 25)
		DevActions.travel_town()
		await _wait_scene(8.0)
	await _explore(rng.randi_range(3, 8))
	await _save_roundtrip()
	await _explore(rng.randi_range(3, 8))


func _save_roundtrip() -> void:
	if not Session.has_profile() or _find_battle() != null or Session.draft != null and Session._draft_real_profile != null:
		_say("  save: skipped (no profile, or mid-fight)")
		return
	var before: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	if not Session.from_dict(before.duplicate(true)):
		_issue("save", "from_dict refused a dictionary the game just wrote", "save:from_dict")
		return
	var again: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	# A first load may add flags (its one-time migrations: the story beats, the own Path); it must keep everything the player has. A
	# second round trip must then change nothing at all.
	var diffs: Array[String] = []
	for line: String in _diff(_stable(before), _stable(again), ""):
		if not (line.begins_with("flags.") and line.ends_with("(new)")):
			diffs.append(line)
	if not Session.from_dict(again.duplicate(true)):
		_issue("save", "from_dict refused a dictionary it had just loaded", "save:from_dict2")
		return
	var third: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	for line: String in _diff(again, third, ""):
		diffs.append("second load: " + line)
	var migrated: Array[String] = _diff(before, again, "")
	if not migrated.is_empty() and diffs.is_empty():
		_say("  save: the first load migrated %s" % ", ".join(migrated.slice(0, 6)))
	if not diffs.is_empty():
		_dump_json("save_before_%d.json" % _step, before)
		_dump_json("save_after_%d.json" % _step, third)
		_issue("save", "to_dict -> from_dict -> to_dict differs: %s" % ", ".join(diffs.slice(0, 8)), "save:dict:" + ",".join(diffs.slice(0, 3)))
	var name: String = "soak_%d" % seed_value
	_say("  save: %s" % DevActions.save_snapshot(name))
	var stable_before: Dictionary = _stable(Session.to_dict())
	_say("  load: %s" % DevActions.load_snapshot(name))
	await _wait_scene(12.0)
	await _explore(2)
	var stable_after: Dictionary = _stable(Session.to_dict())
	var load_diffs: Array[String] = _diff(stable_before, stable_after, "")
	if not load_diffs.is_empty():
		_issue("save", "a snapshot loaded back differently: %s" % ", ".join(load_diffs.slice(0, 8)), "save:snapshot:" + ",".join(load_diffs.slice(0, 3)))
	else:
		_say("  save: round trip ok")


func _dump_json(file_name: String, data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(ProjectSettings.globalize_path("%s/%s" % [_out_dir, file_name]), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "	", true))
		file.close()


## The parts of a save a load must keep exactly (not the clock, the location or the "last seen" bookkeeping).
func _stable(data: Dictionary) -> Dictionary:
	var keep: Dictionary = {}
	for key: String in ["level", "xp", "gold", "deck", "decks", "active_deck", "owned", "owned_equipment", "equipped", "equipped_items", "owned_items", "packs", "flags", "quests", "completed_quests", "cleared_dungeons", "essence", "primary", "cosmetics", "postgame", "found_secrets", "earned_cards"]:
		if data.has(key):
			keep[key] = data[key]
	return JSON.parse_string(JSON.stringify(keep)) as Dictionary


func _diff(a: Variant, b: Variant, path: String) -> Array[String]:
	var out: Array[String] = []
	if a is Dictionary and b is Dictionary:
		for key: Variant in (a as Dictionary).keys():
			if not (b as Dictionary).has(key):
				out.append(path + str(key) + " (gone)")
			else:
				out.append_array(_diff((a as Dictionary)[key], (b as Dictionary)[key], path + str(key) + "."))
		for key: Variant in (b as Dictionary).keys():
			if not (a as Dictionary).has(key):
				out.append(path + str(key) + " (new)")
	elif a is Array and b is Array:
		if (a as Array).size() != (b as Array).size():
			out.append(path.trim_suffix(".") + " (%d -> %d items)" % [(a as Array).size(), (b as Array).size()])
		elif JSON.stringify(a) != JSON.stringify(b):
			out.append(path.trim_suffix(".") + " (order or values)")
	elif typeof(a) != typeof(b) and not (a is float or a is int) or str(a) != str(b):
		out.append(path.trim_suffix(".") + " (%s -> %s)" % [str(a).left(30), str(b).left(30)])
	return out


# ---- World actions ----------------------------------------------------------------------------------------------------------------


func _wait_scene(max_seconds: float) -> void:
	var waited: float = 0.0
	await driver.seconds(1.0)
	while waited < max_seconds and SceneManager.busy_seconds() > 0.0:
		await driver.seconds(0.5)
		waited += 0.5
	await driver.seconds(1.0)


func _use_random_spot() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null or not ("spots" in scene) or _overlay_open() or _find_battle() != null:
		return
	var spots: Array = scene.get("spots") as Array
	if spots.is_empty():
		return
	var spot: Object = spots[rng.randi_range(0, spots.size() - 1)] as Object
	var id: String = str(spot.get("id"))
	if id in SPOT_DENY:
		return
	_say("  spot %s: %s" % [id, _goto_spot(id)])
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.8)


func _random_walk() -> void:
	if _overlay_open() or _find_battle() != null:
		return
	var keys: Array[Key] = [KEY_W, KEY_A, KEY_S, KEY_D]
	var first: Key = keys[rng.randi_range(0, 3)]
	var second: Key = keys[rng.randi_range(0, 3)]
	await driver.key(first, true)
	if second != first:
		await driver.key(second, true)
	await driver.seconds(rng.randf_range(0.4, 2.0))
	await driver.key(first, false)
	await driver.key(second, false)
	await driver.frames(2)


# ---- The random explorer ----------------------------------------------------------------------------------------------------------


## `steps` random actions on whatever is on screen: a battle is played (randomly) to its end; talk is clicked through; otherwise a
## random visible button (or map node, or card) is clicked, or a random hotkey pressed. Each step is checked for problems.
func _explore(steps: int, title: bool = false) -> void:
	for i: int in range(steps):
		if _elapsed() > _limit:
			return
		_step += 1
		var battle: BattleScreen = _find_battle()
		if battle != null and battle.mode != BattleScreen.Mode.OVER:
			await _play_battle(battle)
			continue
		if _talk_open():
			await driver.click(_canvas_center())
			await driver.tap_key(KEY_E)
			await driver.seconds(0.3)
			await _after_step()
			continue
		var candidates: Array[Control] = _candidates()
		var roll: float = rng.randf()
		if candidates.is_empty() or roll < 0.08:
			var code: Key = KEYS[rng.randi_range(0, KEYS.size() - 1)]
			if title and code == KEY_ESCAPE:
				code = KEY_DOWN
			_say("  [%d] key %s" % [_step, OS.get_keycode_string(code)])
			await driver.tap_key(code)
		elif roll < 0.12 and not candidates.is_empty():
			var hovered: Control = candidates[rng.randi_range(0, candidates.size() - 1)]
			await driver.move_to(hovered.get_global_rect().get_center())
			await driver.seconds(0.3)
		else:
			var target: Control = _weighted_pick(candidates)
			_say("  [%d] click %s" % [_step, _describe(target)])
			if target is LineEdit:
				(target as LineEdit).grab_focus()
				(target as LineEdit).text = ["", "a", "zz", "Test 1"][rng.randi_range(0, 3)]
				(target as LineEdit).text_changed.emit((target as LineEdit).text)
			else:
				await driver.click(target.get_global_rect().get_center())
		await driver.seconds(rng.randf_range(0.25, 0.7))
		await _after_step()


func _canvas_center() -> Vector2:
	return get_tree().root.get_visible_rect().size * 0.5


func _talk_open() -> bool:
	for node: Node in get_tree().root.find_children("*", "Control", true, false):
		if node.get_script() == null or not (node as Control).is_visible_in_tree():
			continue
		if str(node.get_script().get_global_name()) in TALK_SCRIPTS:
			return true
	return false


func _overlay_open() -> bool:
	for node: Node in get_tree().root.find_children("*", "OverlayScreen", true, false):
		if (node as Control).is_visible_in_tree():
			return true
	return false


## Every control a player could press right now: visible, enabled buttons on the screen, dungeon map nodes and cards, text boxes. When
## a modal screen is open only its own controls count (what lies under it cannot be clicked).
func _candidates() -> Array[Control]:
	var result: Array[Control] = []
	var view: Rect2 = get_tree().root.get_visible_rect()
	var top: Node = _top_layer()
	var start: Node = top if top != null else get_tree().root
	for node: Node in start.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if not control.is_visible_in_tree() or control.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			continue
		var clickable: bool = false
		if control is BaseButton:
			clickable = not (control as BaseButton).disabled
		elif control is LineEdit:
			clickable = (control as LineEdit).editable and rng.randf() < 0.3
		elif control.get_script() != null and str(control.get_script().get_global_name()) in ["MapNodeButton", "CardView"]:
			clickable = true
		if not clickable:
			continue
		var rect: Rect2 = control.get_global_rect()
		if rect.size.x < 4.0 or rect.size.y < 4.0 or not view.has_point(rect.get_center()) or _clipped_away(control):
			continue
		var text: String = _text_of(control).to_lower()
		var denied: bool = false
		for word: String in DENY:
			if text.contains(word):
				denied = true
				break
		if not denied:
			result.append(control)
	return result


## The topmost modal layer on screen (an overlay screen, a pop-up, a dialog), or null for the plain scene.
func _top_layer() -> Node:
	var best: Node = null
	var best_layer: int = -1000
	for node: Node in get_tree().root.find_children("*", "", true, false):
		if not (node is Control) or not (node as Control).is_visible_in_tree():
			continue
		var script_name: String = str(node.get_script().get_global_name()) if node.get_script() != null else ""
		if not (node is OverlayScreen or node is AcceptDialog or script_name in ["PopupFrame", "RewardPopup", "ConfirmDialog", "PauseMenu", "SettingsPanel", "GlossaryPanel", "LevelUpScreen", "FeedbackForm", "RulesBrief"]):
			continue
		var layer: int = 0
		var parent: Node = node.get_parent()
		while parent != null:
			if parent is CanvasLayer:
				layer = (parent as CanvasLayer).layer
				break
			parent = parent.get_parent()
		# later in the tree draws on top within one layer
		if layer >= best_layer:
			best_layer = layer
			best = node
	return best


func _clipped_away(control: Control) -> bool:
	var rect: Rect2 = control.get_global_rect()
	var parent: Node = control.get_parent()
	while parent != null and parent is Control:
		var holder: Control = parent as Control
		if holder.clip_contents or holder is ScrollContainer:
			if not holder.get_global_rect().has_point(rect.get_center()):
				return true
		parent = parent.get_parent()
	return false


func _text_of(control: Control) -> String:
	if control is Button:
		return (control as Button).text
	if control is LineEdit:
		return (control as LineEdit).placeholder_text
	return str(control.name)


func _describe(control: Control) -> String:
	var text: String = _text_of(control).strip_edges().replace("\n", " / ")
	return "%s '%s' (%s)" % [control.get_class() if control.get_script() == null else str(control.get_script().get_global_name()), text.left(50), str(control.name)]


func _weighted_pick(candidates: Array[Control]) -> Control:
	var weights: Array[float] = []
	var total: float = 0.0
	for control: Control in candidates:
		var text: String = _text_of(control).to_lower()
		var weight: float = 1.0
		for word: String in CLOSE_WORDS:
			if text.begins_with(word) or text == word:
				weight = 0.35
				break
		# after a long time on one screen, leaving gets likelier
		if _stuck > 12 and weight < 1.0:
			weight = 3.0
		weights.append(weight)
		total += weight
	var roll: float = rng.randf() * total
	for index: int in range(candidates.size()):
		roll -= weights[index]
		if roll <= 0.0:
			return candidates[index]
	return candidates[-1]


# ---- Battles ----------------------------------------------------------------------------------------------------------------------


## A battle played with random but legal choices: the built-in pilot plays most decisions; at random the bot instead ends its turn
## early, attacks with a random few, uses an item, opens a pile or hovers a card. After a random length the fight is won or lost
## by decree (both outcomes' screens get visited).
func _play_battle(battle: BattleScreen) -> void:
	_say("  [%d] battle: %s" % [_step, battle.context.enemy_name if battle.context != null else "?"])
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	var length: float = rng.randf_range(10.0, 60.0)
	var started: int = Time.get_ticks_msec()
	var last_turn: int = -1
	var still: int = 0
	var over_since: int = -1
	while is_instance_valid(battle) and battle.mode != BattleScreen.Mode.OVER and float(Time.get_ticks_msec() - started) / 1000.0 < length:
		if _elapsed() > _limit:
			return
		# the game has ended but the screen never reached its result (a hang after the last blow)
		if battle.game != null and battle.game.is_over():
			if over_since < 0:
				over_since = Time.get_ticks_msec()
			elif Time.get_ticks_msec() - over_since > 15000:
				_issue("softlock", "the duel ended but the battle screen never finished (mode %d, busy %s, banner waiting %s)" % [battle.mode, str(battle.busy), str(battle.script_banner != null and battle.script_banner.is_waiting())], "battle_over_hang:%d" % battle.mode)
				break
		if battle.busy or battle.mode == BattleScreen.Mode.WAITING:
			if await BattlePilot.answer_event(driver, battle):
				continue
			await driver.seconds(0.2)
			still += 1
			# the opponent's card pop-up waits for a click when Settings say "Wait for click" (the bot may have chosen that)
			if still % 10 == 0:
				await driver.tap_key(KEY_SPACE)
			if still > 300:
				_issue("softlock", "the battle stayed busy for a minute (mode %d, turn %d)" % [battle.mode, battle.game.turn if battle.game != null else -1], "battle_busy:" + str(battle.context.enemy_name if battle.context != null else ""))
				break
			continue
		var tip: Button = driver.find_button("Got it")
		if tip != null:
			await driver.click(driver.button_center(tip))
			await driver.seconds(0.2)
		var roll: float = rng.randf()
		if battle.mode == BattleScreen.Mode.MAIN and roll < 0.08:
			var end_turn: Button = driver.find_button("End Turn", battle)
			if end_turn != null:
				await driver.click(driver.button_center(end_turn))
		elif battle.mode == BattleScreen.Mode.MAIN and roll < 0.16:
			var extras: Array[Control] = []
			for control: Control in _candidates():
				if control is Button and not (control as Button).text.contains("End Turn"):
					extras.append(control)
			if not extras.is_empty():
				var extra: Control = extras[rng.randi_range(0, extras.size() - 1)]
				_say("  [%d] battle extra: %s" % [_step, _describe(extra)])
				await driver.click(extra.get_global_rect().get_center())
				await driver.seconds(0.4)
				if _overlay_open() or driver.find_button("Close") != null:
					await driver.tap_key(KEY_ESCAPE)
		elif battle.mode == BattleScreen.Mode.ATTACK and roll < 0.4:
			for card: CardInstance in battle.game.possible_attackers(0):
				if rng.randf() < 0.5:
					await driver.click(driver.center_of_control(battle.board.view_for(card.uid)))
			var attack: Button = driver.find_button("Attack with")
			if attack == null:
				attack = driver.find_button("No Attack")
			if attack != null:
				await driver.click(driver.button_center(attack))
		else:
			await pilot.act()
		await driver.seconds(0.2)
		for node: Node in battle.find_children("*", "Button", true, false):
			var confirm: Button = node as Button
			if confirm.is_visible_in_tree() and confirm.text.strip_edges() == "End Turn":
				await driver.click(driver.button_center(confirm))
				break
		await _after_step(true)
		if battle.game != null and battle.game.turn != last_turn:
			last_turn = battle.game.turn
			still = 0
		else:
			still += 1
			if still == 40:
				pilot.skip_hand()
			if still == 60:
				var skip: Button = driver.find_button("Skip tips")
				if skip != null:
					await driver.click(driver.button_center(skip))
			if still > 150:
				_issue("softlock", "a battle turn did not move in 150 decisions (mode %d, turn %d)" % [battle.mode, last_turn], "battle_stuck:%d" % battle.mode)
				break
	if is_instance_valid(battle) and battle.mode != BattleScreen.Mode.OVER:
		var won: bool = rng.randf() < 0.6
		_say("  battle: decided by decree (%s; mode %d, busy %s, over %s)" % ["win" if won else "loss", battle.mode, str(battle.busy), str(battle.game != null and battle.game.is_over())])
		DevActions.end_battle(battle, won)
	await driver.seconds(2.0)
	if is_instance_valid(battle) and battle.is_visible_in_tree() and battle.mode != BattleScreen.Mode.OVER:
		_say("  battle: after the decree, mode %d, busy %s, over %s" % [battle.mode, str(battle.busy), str(battle.game != null and battle.game.is_over())])


# ---- Checks -----------------------------------------------------------------------------------------------------------------------


func _after_step(in_battle: bool = false) -> void:
	await _flush_errors()
	var signature: String = _signature()
	if signature == _last_signature:
		_stuck += 1
	else:
		_stuck = 0
		_last_signature = signature
	if not in_battle and _stuck > 0 and _stuck % 25 == 0:
		await _try_close()
	if signature != _last_layout_signature:
		_last_layout_signature = signature
		await driver.frames(2)
		_check_layout()
		await _check_magenta()


## What is on screen, in short: the scene, the top layer and the visible button texts.
func _signature() -> String:
	var scene: Node = get_tree().current_scene
	var top: Node = _top_layer()
	var parts: Array[String] = [str(scene.name) if scene != null else "-", str(top.get_script().get_global_name()) if top != null and top.get_script() != null else (top.get_class() if top != null else "-")]
	var texts: Array[String] = []
	for control: Control in _candidates_quiet():
		texts.append(_text_of(control).left(24))
	texts.sort()
	parts.append("|".join(texts.slice(0, 40)))
	return "#".join(parts)


func _candidates_quiet() -> Array[Control]:
	var saved: int = rng.state
	var list: Array[Control] = _candidates()
	rng.state = saved
	return list


## The same screen for 25 steps: Escape, then any button that closes; a screen that will not go is a softlock.
func _try_close() -> void:
	var before: String = _signature()
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.5)
	if _signature() != before:
		return
	for control: Control in _candidates():
		var text: String = _text_of(control).to_lower()
		for word: String in CLOSE_WORDS:
			if text.begins_with(word):
				await driver.click(control.get_global_rect().get_center())
				await driver.seconds(0.5)
				if _signature() != before:
					return
	if _stuck >= 75:
		var top: Node = _top_layer()
		var what: String = str(top.get_script().get_global_name()) if top != null and top.get_script() != null else (str(get_tree().current_scene.name) if get_tree().current_scene != null else "-")
		var count: int = _candidates().size()
		_issue("softlock", "%s: 75 steps with nothing changing (%d buttons, Escape and every close button tried)" % [what, count], "stuck:" + what)
		await _recover()


func _recover() -> void:
	_say("  recover: back to Crosspath")
	get_tree().paused = false
	var battle: BattleScreen = _find_battle()
	if battle != null and battle.mode != BattleScreen.Mode.OVER:
		DevActions.end_battle(battle, false)
		await driver.seconds(2.0)
	for node: Node in get_tree().root.find_children("*", "OverlayScreen", true, false):
		node.queue_free()
	if Session.has_profile():
		DevActions.travel_town()
	else:
		SceneManager.go_to_title()
	await _wait_scene(8.0)
	_stuck = 0


## Controls off the screen, buttons on top of one another, text cut off by its box, the Godot icon or a placeholder texture.
func _check_layout() -> void:
	var view: Rect2 = get_tree().root.get_visible_rect().grow(2.0)
	var top: Node = _top_layer()
	var start: Node = top if top != null else get_tree().root
	var buttons: Array[Control] = []
	for node: Node in start.find_children("*", "", true, false):
		if node is Control:
			var control: Control = node as Control
			if not control.is_visible_in_tree() or control.modulate.a < 0.05 or _in_scroll(control) or _fading(control) or _in_card(control):
				continue
			var rect: Rect2 = control.get_global_rect()
			var has_text: bool = (control is Button and not (control as Button).text.strip_edges().is_empty()) or (control is Label and not (control as Label).text.strip_edges().is_empty())
			if has_text and rect.size.x > 2.0 and not view.encloses(rect) and rect.intersects(view):
				_issue("offscreen", "%s runs off the screen (%s)" % [_describe(control), str(rect)], "off:" + _key_path(control.get_parent()))
			elif has_text and rect.size.x > 2.0 and not rect.intersects(view) and control is Button and not (control as Button).disabled:
				_issue("offscreen", "%s is entirely off the screen (%s)" % [_describe(control), str(rect)], "off:" + _key_path(control))
			if control is Label:
				var label: Label = control as Label
				if not label.text.strip_edges().is_empty() and not label.clip_text and label.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and label.autowrap_mode != TextServer.AUTOWRAP_OFF and label.max_lines_visible < 0 and label.get_line_count() > label.get_visible_line_count() and label.get_visible_line_count() > 0:
					_issue("text", "'%s' needs %d lines but its box shows %d (%s)" % [label.text.strip_edges().left(60).replace("\n", " "), label.get_line_count(), label.get_visible_line_count(), _key_path(label)], "text:" + _key_path(label))
			elif control is RichTextLabel:
				var rich: RichTextLabel = control as RichTextLabel
				if not rich.fit_content and not rich.scroll_active and rich.size.y > 4.0 and rich.get_content_height() > rich.size.y + 6.0:
					_issue("text", "'%s' is %d px tall in a %d px box (%s)" % [rich.get_parsed_text().strip_edges().left(60).replace("\n", " "), rich.get_content_height(), int(rich.size.y), _key_path(rich)], "text:" + _key_path(rich))
			if control is BaseButton and control is Button and not (control as Button).text.strip_edges().is_empty() and not (control as BaseButton).disabled:
				buttons.append(control)
			_check_texture(control)
		elif node is Sprite2D and (node as Sprite2D).is_visible_in_tree():
			_check_texture_resource((node as Sprite2D).texture, node)
	# buttons covering one another (siblings in one layer; a button inside another is fine)
	for i: int in range(buttons.size()):
		for j: int in range(i + 1, buttons.size()):
			var a: Control = buttons[i]
			var b: Control = buttons[j]
			if a.is_ancestor_of(b) or b.is_ancestor_of(a) or not _near_relatives(a, b):
				continue
			var overlap: Rect2 = a.get_global_rect().intersection(b.get_global_rect())
			var smaller: float = minf(a.get_global_rect().get_area(), b.get_global_rect().get_area())
			if smaller > 1.0 and overlap.get_area() > smaller * 0.4:
				_issue("overlap", "%s and %s overlap (%d%% of the smaller)" % [_describe(a), _describe(b), int(overlap.get_area() / smaller * 100.0)], "overlap:" + _key_path(a) + "+" + _key_path(b))


## Two buttons of one panel (their common ancestor at most three levels above each): a panel stacked over another (the Load page over
## the pause menu) hides what is under it, so buttons of different panels are not judged as overlapping.
func _near_relatives(a: Node, b: Node) -> bool:
	var up: Node = a.get_parent()
	for depth: int in range(3):
		if up == null:
			return false
		if up.is_ancestor_of(b):
			var walk: Node = b.get_parent()
			for other: int in range(3):
				if walk == up:
					return true
				walk = walk.get_parent() if walk != null else null
			return false
		up = up.get_parent()
	return false


## A card's own labels (a hand card peeks over the bottom edge by design).
func _in_card(control: Control) -> bool:
	var node: Node = control
	while node != null:
		if node.get_script() != null and str(node.get_script().get_global_name()) == "CardView":
			return true
		node = node.get_parent()
	return false


func _in_scroll(control: Control) -> bool:
	var parent: Node = control.get_parent()
	while parent != null and parent is Control:
		if parent is ScrollContainer or (parent as Control).clip_contents:
			return true
		parent = parent.get_parent()
	return false


## A control mid-tween (sliding in or out) is not judged: its parent chain is not at rest.
func _fading(control: Control) -> bool:
	var node: Node = control
	while node != null and node is CanvasItem:
		if (node as CanvasItem).modulate.a < 0.95:
			return true
		node = node.get_parent()
	return false


func _check_texture(control: Control) -> void:
	if control is TextureRect:
		_check_texture_resource((control as TextureRect).texture, control)
	elif control is TextureButton:
		_check_texture_resource((control as TextureButton).texture_normal, control)
	elif control is Button:
		_check_texture_resource((control as Button).icon, control)
	elif control is NinePatchRect:
		_check_texture_resource((control as NinePatchRect).texture, control)


func _check_texture_resource(texture: Texture2D, owner_node: Node) -> void:
	if texture == null:
		return
	var path: String = texture.resource_path.to_lower()
	if path.is_empty() and texture is AtlasTexture and (texture as AtlasTexture).atlas != null:
		path = (texture as AtlasTexture).atlas.resource_path.to_lower()
	if path.ends_with("icon.svg") or path.contains("placeholder") or path.contains("missing") or path.contains("godot_icon"):
		_issue("art", "%s shows %s" % [str(owner_node.get_path()).right(90), path], "art:" + path + ":" + _key_path(owner_node))


## Pure magenta (the colour of a missing texture) over more than 0.2 % of the screen.
func _check_magenta() -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_tree().root.get_texture().get_image()
	if image == null:
		return
	image.resize(image.get_width() / 8, image.get_height() / 8, Image.INTERPOLATE_NEAREST)
	var hits: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color = image.get_pixel(x, y)
			if c.r > 0.94 and c.g < 0.08 and c.b > 0.94:
				hits += 1
	var share: float = float(hits) / float(maxi(1, image.get_width() * image.get_height()))
	if share > 0.002:
		_issue("art", "pure magenta on %.1f %% of the screen (a missing texture?)" % (share * 100.0), "magenta:" + _signature().left(60))


## A node path without numbers (one issue per kind of control, not per copy).
func _key_path(node: Node) -> String:
	var parts: Array[String] = []
	var walk: Node = node
	var depth: int = 0
	while walk != null and depth < 5:
		var name_text: String = str(walk.name)
		var cleaned: String = ""
		for ch: String in name_text:
			if not ch.is_valid_int() and ch != "@":
				cleaned += ch
		parts.push_front(cleaned)
		walk = walk.get_parent()
		depth += 1
	return "/".join(parts)


# ---- Errors and issues ------------------------------------------------------------------------------------------------------------


func _install_logger() -> void:
	var script: GDScript = load(LOGGER_SCRIPT) as GDScript
	if script == null:
		return
	_logger = script.new()
	_logger.set("bot", self)
	OS.add_logger(_logger as Logger)


## Called by the logger (deferred to the main thread).
func record(kind: String, text: String) -> void:
	if kind != "error":
		return
	for word: String in NOISE:
		if text.contains(word):
			return
	_pending_errors.append(text)


func _flush_errors() -> void:
	while not _pending_errors.is_empty():
		var text: String = _pending_errors.pop_front()
		_issue("error", text, "err:" + text.left(120))


func _issue(kind: String, text: String, key: String) -> void:
	var full_key: String = kind + ":" + key
	if _seen_keys.has(full_key):
		_seen_keys[full_key] = int(_seen_keys[full_key]) + 1
		return
	_seen_keys[full_key] = 1
	var shot: String = "%s_%02d_%s.jpg" % [kind, _issues.size() + 1, _segment]
	_issues.append({"kind": kind, "text": text, "key": full_key, "segment": _segment, "step": _step, "at": _elapsed(), "shot": shot})
	_say("ISSUE %s [%s step %d]: %s" % [kind, _segment, _step, text])
	await RenderingServer.frame_post_draw
	var image: Image = get_tree().root.get_texture().get_image()
	if image != null:
		image.save_jpg(ProjectSettings.globalize_path("%s/%s" % [_out_dir, shot]), 0.8)


func _finish_soak() -> void:
	DevActions.delete_snapshot("soak_%d" % seed_value)
	var lines: Array[String] = ["# Soak bot, seed %d, window %s, %.0f s, %d steps" % [seed_value, str(get_window().size), _elapsed(), _step], "", "Segments: %s" % str(_counts), "", "| # | Kind | Segment | Step | Seen | Problem | Frame |", "|---|---|---|---:|---:|---|---|"]
	var index: int = 0
	for issue: Dictionary in _issues:
		index += 1
		lines.append("| %d | %s | %s | %d | %d | %s | %s |" % [index, issue["kind"], issue["segment"], int(issue["step"]), int(_seen_keys.get(issue["key"], 1)), str(issue["text"]).replace("|", "/"), issue["shot"]])
	if _issues.is_empty():
		lines.append("| - | none | | | | | |")
	var file: FileAccess = FileAccess.open(ProjectSettings.globalize_path(_out_dir + "/issues.md"), FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(lines) + "\n")
		file.close()
	_say("soak: done, %d steps, %d distinct issues" % [_step, _issues.size()])
	if _logger != null:
		OS.remove_logger(_logger as Logger)
	_finish()
