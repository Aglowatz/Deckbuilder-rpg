class_name OnboardingTiming
extends Node
## Daytime Oct 19, Part 3: times the opening from the title screen's New Game to the first saved deck edit (the "Make It Yours" quest),
## with real input: clicks on the title and the Path choice, E for every dialogue line (each line is let finish typing first, the way a
## reader would), WASD walking (the hero's real speed) to the cave gate and from Maren to the Deck Station, a click on a collection card
## and Save Deck -> a rack slot. The Forgotten Cave's three duels are won by decree (the first-battles smoke plays them for real); the
## cave's time is added from a model (below), and a reading-speed model turns the dialogue into a person's minutes.
## Prints one line per segment and writes the totals to _screenshots/onboarding_timing.json.
##   bash tools/run_onboarding_timing.sh

## A reader: ~3.5 words per second (210 wpm) plus half a second to press on; the typewriter is the floor.
const WORDS_PER_SECOND: float = 3.5
const PRESS_SECONDS: float = 0.5
## The cave for a person (minutes): three duels (the first-battles smoke: 9 / 13 / 5 turns, 46 / 35 / 13 s at bot pace) with ~12 s of
## thinking per own turn, the map clicks, the Hollow Well, the shrine and three reward picks.
const CAVE_DUEL_TURNS: Array[int] = [9, 13, 5]
const CAVE_DUEL_BOT_SECONDS: Array[float] = [46.0, 35.0, 13.0]
const THINK_SECONDS_PER_OWN_TURN: float = 12.0
const CAVE_EXTRA_SECONDS: float = 90.0
const CAVE_CLICKS: int = 3 * 14 + 12
const TIME_LIMIT_SECONDS: float = 60.0

var driver: UiDriver
var _held_keys: Dictionary = {}
var _segments: Array[Dictionary] = []
var _segment: Dictionary = {}
var _clicks: int = 0
var _stills_clicks: int = 0
var _lines: int = 0
var _read_seconds: float = 0.0
var _busy_seconds: float = 0.0
var _failures: PackedStringArray = []
var _started_msec: int = 0
## ONBOARD_PATH=necrocrat (beefcake, gourmand, refusemancer) picks the Path; Beefcake by default.
var _path: Affinity.Type = Affinity.Type.BEEFCAKE


func _process(delta: float) -> void:
	if SceneManager.busy:
		_busy_seconds += delta


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = true
	var wanted: String = OS.get_environment("ONBOARD_PATH").to_lower()
	for path: Affinity.Type in Affinity.colored_types():
		if Affinity.display_name(path).to_lower() == wanted:
			_path = path
	print("onboarding: Path %s" % Affinity.display_name(_path))
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	_started_msec = Time.get_ticks_msec()
	# 1. Title -> New Game (a first-time player has no saves; this PC may, so the overwrite question is answered and counted apart).
	_begin("title -> New Game")
	var title: Node = await _wait_for_name("TitleScreen")
	if title == null:
		_finish(false, "the title screen never showed")
		return
	await driver.seconds(1.0)
	await _click_text("New Game")
	if driver.find_button("Start Over") != null:
		await _click_text("Start Over")
		_segment["note"] = "this PC has saves: the overwrite question added one click"
	var scene: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if scene == null:
		_finish(false, "the starting forest never loaded")
		return
	_end()
	# 2. The wake-up lines and the Rescuer up to the Path choice.
	_begin("forest: wake-up -> Path choice")
	var guard: int = 0
	while _find_element_choice(scene) == null and guard < 200:
		guard += 1
		var still: StoryStillScreen = get_tree().root.find_child("StoryStill", true, false) as StoryStillScreen
		if still != null and still.dialogue != null and still.dialogue.active:
			_stills_clicks += 1
			await _read_and_press(still.dialogue)
		elif still != null:
			pass
		elif scene.dialogue.active:
			await _read_and_press(scene.dialogue)
		await driver.seconds(0.15)
	var choice: ElementChoiceScreen = _find_element_choice(scene)
	print("onboarding: %d of those lines were the opening still's captions" % _stills_clicks)
	_check(choice != null, "the Path choice appears")
	if choice == null:
		_finish(false, "no Path choice")
		return
	_end()
	_begin("Path choice")
	var text: String = ""
	for label: Node in choice.find_children("*", "Label", true, false):
		if (label as Label).is_visible_in_tree():
			text += (label as Label).text + " "
	print("onboarding: Path choice shows %d words" % text.split(" ", false).size())
	_read(text)
	await _click(driver.center_of_control(choice._tiles[_path] as Button))
	await _click_text("Begin")
	await driver.seconds(0.5)
	_end()
	_begin("forest: after the choice -> free to walk")
	guard = 0
	while (scene.dialogue.active or scene._rescuer != null or scene._locked) and guard < 200:
		guard += 1
		if scene.dialogue.active:
			await _read_and_press(scene.dialogue)
		elif driver.find_button("Continue") != null:
			await _click_text("Continue")
		await driver.seconds(0.2)
	_end()
	# 3. Walk to the gate and enter the cave.
	_begin("forest: walk to the cave gate")
	var gate: Vector3 = scene.area.anchors.get("gate", Vector3.ZERO) as Vector3
	_segment["walk_m"] = scene.player.position.distance_to(gate)
	await _walk_to(scene, gate + Vector3(0.0, 0.0, 0.6), 40.0)
	_finish_walk(scene, gate + Vector3(0.0, 0.0, 0.2))
	await driver.seconds(0.8)
	_clicks += 1
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	if driver.find_button("Enter") == null:
		_clicks += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.6)
	_shot("onboarding_gate")
	_check(await _click_text("Enter"), "the gate asks to enter the Forgotten Cave")
	await driver.seconds(1.0)
	_check(Session.in_dungeon(), "the Forgotten Cave starts")
	_end()
	# 4. The cave: modelled (see the constants); the bot leaves through the Session's own exit.
	_begin("the Forgotten Cave (modelled)")
	while SceneManager.busy:
		await driver.frames(5)
	# The cave's three reward picks, the way apply_rewards adds them (collection + the run's deck).
	var reward_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	reward_rng.seed = 19
	for _pick: int in range(3):
		var picks: Array[CardData] = RewardGenerator.card_choices_for_color(Session.content, _path, reward_rng, 3, false)
		if not picks.is_empty():
			Session.add_cards([picks[0]] as Array[CardData])
			if Session.run != null:
				Session.run.gain_card(picks[0])
	Session.complete_trial()
	Session.cave_exit_pending = true
	SceneManager.go_to_town()
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "Crosspath never loaded")
		return
	var cave_seconds: float = CAVE_EXTRA_SECONDS
	for index: int in range(CAVE_DUEL_TURNS.size()):
		cave_seconds += CAVE_DUEL_BOT_SECONDS[index] + THINK_SECONDS_PER_OWN_TURN * ceilf(float(CAVE_DUEL_TURNS[index]) / 2.0)
	_segment["model_seconds"] = cave_seconds
	_clicks += CAVE_CLICKS
	_end()
	# 5. Crosspath: Maren's welcome.
	_begin("Crosspath: Maren's welcome")
	await driver.seconds(0.5)
	guard = 0
	while guard < 200 and (town.dialogue.active or town._locked):
		guard += 1
		if driver.find_button("Continue") != null:
			await _click_text("Continue")
		elif town.dialogue.active:
			await _read_and_press(town.dialogue)
		await driver.seconds(0.2)
	_check(Session.quest_log.is_active(QuestDefinitions.FIRST_DECK_EDIT), "Make It Yours is active after the cave")
	_end()
	# 6. Walk to the Deck Station, open it, add a card, Save Deck -> slot 1.
	_begin("Crosspath: walk to the Deck Station")
	var station_spot: Vector3 = town.town.anchors["deck"] as Vector3
	_segment["walk_m"] = town.player.position.distance_to(station_spot)
	await _walk_to(town, station_spot + Vector3(0.0, 0.0, 0.8), 60.0)
	_finish_walk(town, station_spot + Vector3(0.0, 0.0, 0.8))
	await driver.seconds(0.3)
	_clicks += 1
	await driver.tap_key(KEY_E)
	_end()
	_begin("Deck Station: first edit + save")
	var station: DeckbuilderScreen = null
	for _wait: int in range(120):
		for node: Node in get_tree().root.find_children("*", "DeckbuilderScreen", true, false):
			station = node as DeckbuilderScreen
		if station != null:
			break
		await driver.frames(2)
	_check(station != null, "the Deck Station opens")
	if station == null:
		_finish(false, "no Deck Station")
		return
	while station.call(&"is_building"):
		await driver.frames(2)
	await driver.seconds(0.5)
	# The first-visit tip ("Building a deck") sits over the collection: read it, Got it.
	if driver.find_button("Got it") != null:
		var tip_text: String = ""
		for label: Node in station.get_tree().root.find_children("*", "RichTextLabel", true, false):
			if (label as RichTextLabel).is_visible_in_tree() and (label as RichTextLabel).get_parsed_text().contains("deck"):
				tip_text += (label as RichTextLabel).get_parsed_text() + " "
		_read(tip_text)
		await _click_text("Got it")
		await driver.seconds(0.3)
	var tile: Control = null
	for child: Node in station._grid.get_children():
		if (child as Control).visible:
			tile = child as Control
			break
	if tile != null:
		await _click(driver.center_of_control(tile))
		await driver.seconds(0.4)
	_shot("onboarding_station")
	print("onboarding: deck station: %d cards, dirty %s" % [station.editor.deck.size(), str(station._dirty)])
	await _click(driver.center_of_control(station._save_button))
	await driver.seconds(0.4)
	var rack: DeckRack = station.find_child("DeckRack", true, false) as DeckRack
	print("onboarding: save mode %s, rack %s" % [str(station.in_save_mode()), str(rack != null)])
	if rack != null and station.in_save_mode():
		await _click(driver.center_of_control(rack.tiles[0]))
		await driver.seconds(0.5)
		if not Session.flag(&"deck_edited") and station.in_save_mode():
			print("onboarding: the slot click did not save; calling _on_save_slot(0)")
			station.call(&"_on_save_slot", 0)
			await driver.seconds(0.4)
	if not Session.flag(&"deck_edited") and driver.find_button("Overwrite") != null:
		await _click_text("Overwrite")
		await driver.seconds(0.4)
	_check(Session.flag(&"deck_edited"), "the deck is saved (deck_edited)")
	_check(Session.profile.primary_affinity == _path, "the hero is a %s" % Affinity.display_name(_path))
	_end()
	_report()
	_finish(_failures.is_empty(), "onboarding timed: title -> first deck edit")


# ---- Measuring -------------------------------------------------------------------------------


func _begin(name: String) -> void:
	_segment = {"name": name, "start": Time.get_ticks_msec(), "clicks0": _clicks, "lines0": _lines, "read0": _read_seconds, "busy0": _busy_seconds}


func _end() -> void:
	var bot: float = float(Time.get_ticks_msec() - int(_segment["start"])) / 1000.0
	var row: Dictionary = {
		"name": _segment["name"], "bot_seconds": snappedf(bot, 0.1), "clicks": _clicks - int(_segment["clicks0"]),
		"dialogue_lines": _lines - int(_segment["lines0"]), "reading_seconds": snappedf(_read_seconds - float(_segment["read0"]), 0.1),
		"dead_seconds": snappedf(_busy_seconds - float(_segment["busy0"]), 0.1),
	}
	for key: String in ["walk_m", "walk_model_s", "model_seconds", "note"]:
		if _segment.has(key):
			row[key] = _segment[key]
	# A person: the bot's time (walking, waits, typewriters, loading) plus the reading the bot skips, or the cave model.
	row["person_seconds"] = snappedf(float(row.get("model_seconds", bot + float(row["reading_seconds"]) + float(row.get("walk_model_s", 0.0)))), 0.1)
	_segments.append(row)
	print("onboarding: %-40s bot %5.1fs  person ~%5.1fs  clicks %3d  lines %3d  dead %4.1fs%s" % [
		row["name"], row["bot_seconds"], row["person_seconds"], row["clicks"], row["dialogue_lines"], row["dead_seconds"],
		("  (%s)" % row["note"]) if row.has("note") else ""])


func _report() -> void:
	var person: float = 0.0
	var clicks: int = 0
	var lines: int = 0
	var dead: float = 0.0
	for row: Dictionary in _segments:
		person += float(row["person_seconds"])
		clicks += int(row["clicks"])
		lines += int(row["dialogue_lines"])
		dead += float(row["dead_seconds"])
	var bot_total: float = float(Time.get_ticks_msec() - _started_msec) / 1000.0
	print("onboarding: TOTAL person ~%.1f min, bot %.1f s, %d clicks/keys, %d dialogue lines, %.1f s loading/fades" % [person / 60.0, bot_total, clicks, lines, dead])
	var file: FileAccess = FileAccess.open("res://_screenshots/onboarding_timing.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"segments": _segments, "person_minutes": snappedf(person / 60.0, 0.1), "bot_seconds": snappedf(bot_total, 0.1),
			"clicks": clicks, "dialogue_lines": lines, "dead_seconds": snappedf(dead, 0.1)}, "\t"))
		file.close()


func _read(text: String) -> void:
	_read_seconds += float(text.split(" ", false).size()) / WORDS_PER_SECOND


## Lets the line finish typing (as a reader would), counts its reading time, then presses E.
func _read_and_press(box: DialogueBox) -> void:
	var waited: int = 0
	while box.active and box._text.visible_ratio < 1.0 and waited < 600:
		await driver.frames(2)
		waited += 1
	if not box.active:
		return
	var line: String = box._text.text
	var words: float = float(line.split(" ", false).size())
	_read_seconds += maxf(0.0, words / WORDS_PER_SECOND - float(waited * 2) / 60.0) + PRESS_SECONDS
	_lines += 1
	_clicks += 1
	await driver.tap_key(KEY_E)


func _click(pos: Vector2) -> void:
	_clicks += 1
	await driver.click(pos)


func _click_text(text: String) -> bool:
	var button: Button = driver.find_button(text)
	if button == null:
		return false
	_clicks += 1
	return await driver.click_button(text)


## When the straight-line walk stops short (a building or a fence in the way), the rest of the way is modelled at the hero's walking
## speed with a 1.4x detour factor, and the hero is placed there (the bot does not path-find).
func _finish_walk(scene: Node, target: Vector3) -> void:
	var player: Node3D = scene.player
	var left: float = Vector2(target.x - player.position.x, target.z - player.position.z).length()
	if left <= 1.5:
		return
	var seconds: float = left * 1.4 / TownPlayer.SPEED
	_segment["walk_model_s"] = snappedf(seconds, 0.1)
	_segment["note"] = "straight walk stopped %.1f m short; +%.1f s modelled" % [left, seconds]
	player.position = Vector3(target.x, player.position.y, target.z)


# ---- Walking and waiting ---------------------------------------------------------------------


func _walk_to(scene: Node, target: Vector3, limit: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	var last: Vector3 = player.position
	var still: float = 0.0
	while elapsed < limit:
		if get_tree().current_scene != scene or not is_instance_valid(player):
			break
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < 0.5:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
		still = still + 2.0 / 60.0 if player.position.distance_to(last) < 0.01 else 0.0
		last = player.position
		if still > 2.0:
			break
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < TIME_LIMIT_SECONDS:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _wait_for_name(class_text: String) -> Node:
	var elapsed: float = 0.0
	while elapsed < TIME_LIMIT_SECONDS:
		var scene: Node = get_tree().current_scene
		if scene != null and scene.get_script() != null and (scene.get_script() as Script).get_global_name() == class_text:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _find_element_choice(scene: StartingAreaScene) -> ElementChoiceScreen:
	for child: Node in scene._overlay_layer.get_children():
		if child is ElementChoiceScreen:
			return child as ElementChoiceScreen
	return null


func _shot(name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	if image != null:
		image.save_png("res://_screenshots/%s.png" % name)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("onboarding: ok    ", message)
	else:
		_failures.append(message)
		print("onboarding: FAIL  ", message)
		push_error("onboarding: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("onboarding: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
