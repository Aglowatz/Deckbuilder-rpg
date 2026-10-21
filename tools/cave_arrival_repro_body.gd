extends Node
## v0.4.2 hotfix: the cave-to-Crosspath arrival, played like a tester would - New Game on a Path, the Forgotten Cave's nodes (duels are
## decided at once through the real result panel), the rewards screens, "Step outside", then Crosspath: Maren's welcome is pressed
## through and the hero must walk. Measures the load (click -> town revealed) and every frame after the fade-in. Self-contained (no
## UiDriver, no class_name) so it runs against an EXPORTED pack too, loaded by tools/cave_arrival_repro.gd once the autoloads exist.
##   CAVE_PATH  = beefcake | gourmand | refusemancer | necrocrat
##   CAVE_MODE  = normal | levelups | speed2x | continue | mash
##   bash tools/run_cave_arrival_repro.sh [pck]

const TAG: String = "cave_arrival"
const TMP: String = "user://cave_arrival_repro"
const STALL_MS: float = 200.0

var _failures: PackedStringArray = []
var _mouse: Vector2 = Vector2(960, 540)
var _mode: String = "normal"
var _path_name: String = "beefcake"
var _mashing: bool = false
var _frame_watch: bool = false
var _last_usec: int = 0
var _worst_ms: float = 0.0
var _stalls: int = 0
var _frame_count: int = 0
var _sum_ms: float = 0.0
var _clicked_msec: int = -1
var _revealed_msec: int = -1
var _modals_seen: PackedStringArray = []
var _started_msec: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_usec()
	if _frame_watch and _last_usec > 0:
		var ms: float = float(now - _last_usec) / 1000.0
		_frame_count += 1
		_sum_ms += ms
		_worst_ms = maxf(_worst_ms, ms)
		if ms > STALL_MS:
			_stalls += 1
			print("%s: stall %.0f ms at %.2f s after the fade-in" % [TAG, ms, float(Time.get_ticks_msec() - _revealed_msec) / 1000.0])
	_last_usec = now


func _run() -> void:
	_started_msec = Time.get_ticks_msec()
	await get_tree().process_frame
	_mode = OS.get_environment("CAVE_MODE") if not OS.get_environment("CAVE_MODE").is_empty() else "normal"
	_path_name = OS.get_environment("CAVE_PATH") if not OS.get_environment("CAVE_PATH").is_empty() else "beefcake"
	print("%s: path=%s mode=%s version=%s" % [TAG, _path_name, _mode, ProjectSettings.get_setting("application/config/version", "?")])
	SaveSlots.dir = "%s/saves/" % TMP
	for slot: int in range(0, 6):
		SaveSlots.delete(slot)
	Session.save_enabled = _mode == "continue"
	if _mode == "speed2x":
		Settings.battle_speed = 2  # BATTLE_SPEEDS[2] = 2x
	var color: int = _path_color(_path_name)
	Session.new_game()
	Session.choose_starting_path(color as Affinity.Type)
	Session.begin_trial()
	var ok: bool = await _walk_cave()
	if not ok:
		_finish()
		return
	await _arrival()
	_finish()


func _path_color(name_text: String) -> int:
	match name_text:
		"gourmand":
			return Affinity.Type.GOURMAND
		"refusemancer":
			return Affinity.Type.REFUSEMANCER
		"necrocrat":
			return Affinity.Type.NECROCRAT
	return Affinity.Type.BEEFCAKE


# ---- The cave -------------------------------------------------------------------------------------------------


func _walk_cave() -> bool:
	var saved_mid_cave: bool = false
	var levels_primed: bool = false
	var guard: int = 0
	while guard < 400:
		guard += 1
		await _seconds(0.3)
		if SceneManager.busy:
			continue
		var scene: Node = get_tree().current_scene
		if scene == null:
			continue
		if scene is TownScene:
			return true
		var dialogue: DialogueBox = _active_dialogue(scene)
		if dialogue != null:
			await _tap_key(KEY_SPACE)
			continue
		if _click_first(scene, ["Continue", "Choose"], "LevelUpScreen"):
			await _seconds(0.3)
			continue
		var slot_screens: Array[Node] = scene.find_children("*", "EquipmentSlotChoiceScreen", true, false)
		if not slot_screens.is_empty():
			var tiles: Dictionary = slot_screens[0].get("_tiles") as Dictionary
			await _click(_center(tiles.values()[0] as Control))
			await _seconds(0.3)
			var choose: Button = _find_button("Choose", scene)
			if choose != null:
				await _click(_center(choose))
			continue
		if scene is BattleScreen:
			await _decide_battle(scene as BattleScreen)
			continue
		if scene is RewardsScreen:
			var rewards: RewardsScreen = scene as RewardsScreen
			var cards: Array = rewards.get("_cards") as Array
			if cards != null and not cards.is_empty() and int(rewards.get("_selected")) < 0:
				await _click(_center(cards[0] as Control))
				await _seconds(0.3)
			var outside: Button = _find_button("Step outside", rewards)
			if outside != null:
				if _mode == "levelups" and not levels_primed:
					# Several level-ups waiting as the town appears, plus a reward box (a finished-quest style popup).
					levels_primed = true
					Session.pending_level_ups.append_array(Session.add_xp(600))
					print("%s: primed %d pending level-ups" % [TAG, Session.pending_level_ups.size()])
				_clicked_msec = Time.get_ticks_msec()
				SceneManager.revealed.connect(_on_revealed, CONNECT_ONE_SHOT)
				if _mode == "mash":
					_mash.call_deferred()
				await _click(_center(outside))
				continue
			for text: String in ["Take", "Continue", "Skip"]:
				var button: Button = _find_button(text, rewards)
				if button != null:
					await _click(_center(button))
					break
			continue
		if scene is DungeonMapScreen:
			var map_screen: DungeonMapScreen = scene as DungeonMapScreen
			if _mode == "continue" and not saved_mid_cave and _completed_count(map_screen.map) >= 1:
				saved_mid_cave = true
				await _continue_from_save()
				continue
			if await _resolve_modal(map_screen):
				continue
			var node_id: int = _next_node(map_screen.map)
			if node_id < 0:
				continue
			var button: Control = (map_screen.get("_buttons") as Dictionary).get(node_id) as Control
			if button != null:
				await _click(_center(button))
				await _seconds(0.6)
			continue
		if scene is StartingAreaScene and not (_mode == "continue" and not saved_mid_cave):
			_fail("the cave run ended in the starting area (a duel lost?)")
			return false
	_fail("the cave walk never reached Crosspath (stuck on %s)" % (get_tree().current_scene.name if get_tree().current_scene != null else "none"))
	return false


func _completed_count(map: DungeonMap) -> int:
	var count: int = 0
	for node: DungeonMap.MapNode in map.nodes:
		if map.is_cleared(node.id):
			count += 1
	return count


func _next_node(map: DungeonMap) -> int:
	for node: DungeonMap.MapNode in map.nodes:
		if map.is_available(node.id) and not map.is_cleared(node.id):
			return node.id
	return -1


## An event / challenge / chest on the map: its first choice or primary button. Returns true when one was open.
func _resolve_modal(map_screen: DungeonMapScreen) -> bool:
	var modal: Control = map_screen.get("_modal") as Control
	if modal == null:
		return false
	var choice: Button = modal.find_child("Choice0", true, false) as Button
	if choice != null and choice.is_visible_in_tree() and not choice.disabled:
		await _click(_center(choice))
		await _seconds(0.5)
		return true
	for text: String in ["Reveal", "Rest", "Open the chest", "Continue", "Take", "Leave"]:
		var button: Button = _find_button(text, modal)
		if button != null:
			await _click(_center(button))
			await _seconds(0.6)
			return true
	await _seconds(0.4)
	return true


## A duel decided at once through the real result panel and its Continue button (the duels themselves are other smokes' business).
func _decide_battle(battle: BattleScreen) -> void:
	await _seconds(1.5)
	if not is_instance_valid(battle) or battle.game == null:
		return
	battle.game.players[0].hp = maxi(battle.game.players[0].hp, 1)
	battle.game._end_game(0, false)
	battle.busy = false
	battle._drive()
	var waited: float = 0.0
	while is_instance_valid(battle) and battle.get("_result_panel") == null and waited < 15.0:
		await _seconds(0.3)
		waited += 0.3
	await _seconds(0.5)
	var proceed: Button = _find_button("Continue", battle) if is_instance_valid(battle) else null
	if proceed != null:
		await _click(_center(proceed))


## Continue from a save made inside the cave: the autosave, the title, Continue.
func _continue_from_save() -> void:
	Session.save_game()
	print("%s: saved inside the cave; back to the title" % TAG)
	SceneManager.go_to_title()
	await _seconds(2.5)
	var proceed: Button = _find_button("Continue")
	if proceed == null:
		_fail("no Continue button on the title after a cave save")
		return
	await _click(_center(proceed))
	await _seconds(3.0)
	# A save inside the cave resumes in the forest (the run itself is not saved): back through the gate, like the player.
	_check(get_tree().current_scene is StartingAreaScene and Session.has_profile(), "Continue from the cave save resumes in the forest with the Path kept")
	Session.begin_trial()
	await _seconds(2.0)
	_check(Session.in_dungeon(), "back into the Forgotten Cave")


# ---- Crosspath ------------------------------------------------------------------------------------------------


func _on_revealed() -> void:
	_revealed_msec = Time.get_ticks_msec()
	_frame_watch = true
	_last_usec = Time.get_ticks_usec()


func _arrival() -> void:
	var town: TownScene = get_tree().current_scene as TownScene
	var waited: float = 0.0
	while _revealed_msec < 0 and waited < 30.0:
		await _seconds(0.1)
		waited += 0.1
	_check(_revealed_msec >= 0, "the town is revealed after 'Step outside'")
	print("%s: load %d ms (click -> fade-in)" % [TAG, _revealed_msec - _clicked_msec])
	await _seconds(1.0)
	_dump_state(town, "1 s after the fade-in")
	# Press through everything the arrival shows, like a player: Continue buttons, then E for dialogue.
	var guard: int = 0
	while guard < 150 and is_instance_valid(town) and (bool(town.get("_locked")) or town.dialogue.active):
		guard += 1
		if get_tree().paused:
			# Something the mashing opened (the pause menu, its settings): back out like a player.
			if not _click_first(get_tree().root, ["Back", "Resume", "Close"], ""):
				await _tap_key(KEY_ESCAPE)
			await _seconds(0.4)
			continue
		var what: String = _modal_name(town)
		if _modals_seen.is_empty() or _modals_seen[_modals_seen.size() - 1] != what:
			_modals_seen.append(what)
		if not _click_first(town, ["Continue", "Next level", "Choose", "Close", "OK", "Got it"], ""):
			if town.dialogue.active:
				await _tap_key(KEY_E)
			else:
				await _tap_key(KEY_ENTER)
		await _seconds(0.25)
	print("%s: arrival showed, in order: %s" % [TAG, " -> ".join(_modals_seen)])
	_frame_watch = false
	if not is_instance_valid(town):
		_fail("the town went away during the arrival")
		return
	_dump_state(town, "after pressing through")
	if bool(town.get("_locked")) or get_tree().paused:
		var shot: String = ProjectSettings.globalize_path("%s/stuck_%s_%s.png" % [TMP, _path_name, _mode])
		DirAccess.make_dir_recursive_absolute(shot.get_base_dir())
		get_viewport().get_texture().get_image().save_png(shot)
		print("%s: stuck - screenshot %s" % [TAG, shot])
		for node: Node in get_tree().root.find_children("*", "CanvasLayer", true, false):
			var layer: CanvasLayer = node as CanvasLayer
			if layer.visible and layer.get_child_count() > 0:
				print("%s:   layer %s (%d) %s children=%d" % [TAG, layer.name, layer.layer, layer.get_script().get_global_name() if layer.get_script() != null else layer.get_class(), layer.get_child_count()])
	_check(not bool(town.get("_locked")) and not town.dialogue.active, "the hero is free after the arrival (locked=%s, dialogue=%s)" % [town.get("_locked"), town.dialogue.active])
	var start: Vector3 = town.player.position
	await _key(KEY_S, true)
	await _seconds(0.8)
	await _key(KEY_S, false)
	var moved: float = town.player.position.distance_to(start)
	_check(moved > 0.3, "the hero walks after the arrival (%.2f m)" % moved)
	_check(Session.flag(&"maren_met"), "maren_met is set")
	var average: float = _sum_ms / maxf(1.0, float(_frame_count))
	print("%s: frames after the fade-in: %d, average %.1f ms, worst %.0f ms, stalls over %d ms: %d" % [TAG, _frame_count, average, _worst_ms, int(STALL_MS), _stalls])
	_check(_worst_ms <= STALL_MS, "no frame over %d ms after the fade-in (worst %.0f ms)" % [int(STALL_MS), _worst_ms])


func _modal_name(town: TownScene) -> String:
	var overlay: Control = town.get("_overlay") as Control
	if overlay != null and is_instance_valid(overlay):
		return overlay.get_class() if overlay.get_script() == null else str((overlay.get_script() as Script).get_global_name())
	if town.dialogue.active:
		return "Dialogue(%s)" % town.dialogue.npc_id
	return "locked(nothing open)"


func _dump_state(town: TownScene, when: String) -> void:
	if not is_instance_valid(town):
		return
	var layers: PackedStringArray = []
	var overlay_layer: Control = town.get("_overlay_layer") as Control
	if overlay_layer != null:
		for child: Node in overlay_layer.get_children():
			layers.append(str(child.name))
	var focus: Control = get_viewport().gui_get_focus_owner()
	print("%s: state %s: locked=%s dialogue=%s(%s) overlay=%s layer=[%s] busy=%s paused=%s time_scale=%.2f input=%s pending_levels=%d pending_popups=%d focus=%s" % [
		TAG, when, town.get("_locked"), town.dialogue.active, town.dialogue.npc_id, _modal_name(town), ", ".join(layers), SceneManager.busy,
		get_tree().paused, Engine.time_scale, town.player.input_enabled, Session.pending_level_ups.size(), Session.pending_popups.size(),
		focus.name if focus != null else "none"])


## Rapid keys and clicks from the click on "Step outside" until 3 s after the fade-in, like an impatient player.
func _mash() -> void:
	_mashing = true
	var keys: Array[Key] = [KEY_E, KEY_SPACE, KEY_ENTER, KEY_ESCAPE, KEY_E, KEY_Q, KEY_J, KEY_C, KEY_M, KEY_TAB, KEY_W, KEY_E]
	var index: int = 0
	while _mashing:
		var key_code: Key = keys[index % keys.size()]
		index += 1
		await _tap_key(key_code)
		if index % 3 == 0:
			await _click(Vector2(960 + (index % 7) * 40, 540 + (index % 5) * 30))
		if _revealed_msec > 0 and Time.get_ticks_msec() - _revealed_msec > 3000:
			_mashing = false
		if Time.get_ticks_msec() - _clicked_msec > 30000:
			_mashing = false
	print("%s: stopped mashing (%d presses)" % [TAG, index])
	# Close whatever the mashing opened (a pause menu, a quest log) so the press-through starts from a game screen.
	await _seconds(0.3)


# ---- Input and lookup (inlined: the export leaves tools/ out) ---------------------------------------------------


func _click_first(root: Node, texts: Array[String], under_class: String) -> bool:
	var roots: Array[Node] = [root]
	if not under_class.is_empty():
		roots = root.find_children("*", under_class, true, false)
	for start: Node in roots:
		for text: String in texts:
			var button: Button = _find_button(text, start)
			if button != null:
				_click(_center(button))
				return true
	return false


func _find_button(text: String, root: Node = null) -> Button:
	var start: Node = root if root != null else get_tree().root
	for node: Node in start.find_children("*", "Button", true, false):
		var button: Button = node as Button
		if button.is_visible_in_tree() and not button.disabled and button.text.contains(text):
			return button
	return null


func _active_dialogue(root: Node) -> DialogueBox:
	for node: Node in root.find_children("*", "DialogueBox", true, false):
		if (node as DialogueBox).active:
			return node as DialogueBox
	return null


func _center(control: Control) -> Vector2:
	return control.get_global_transform() * (control.size * 0.5)


func _win(pos: Vector2) -> Vector2:
	return get_tree().root.get_final_transform() * pos


func _click(pos: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = _win(pos)
	motion.global_position = _win(pos)
	motion.relative = _win(pos) - _win(_mouse)
	_mouse = pos
	Input.parse_input_event(motion)
	await get_tree().process_frame
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = _win(pos)
		event.global_position = _win(pos)
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		Input.parse_input_event(event)
		await get_tree().process_frame


func _key(keycode: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	Input.parse_input_event(event)
	await get_tree().process_frame


func _tap_key(keycode: Key) -> void:
	await _key(keycode, true)
	await _key(keycode, false)


func _seconds(duration: float) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("%s: FAIL  %s" % [TAG, message])


func _finish() -> void:
	Settings.battle_speed = 0
	var elapsed: float = float(Time.get_ticks_msec() - _started_msec) / 1000.0
	print("%s: %s - %d failure(s) (%.0f s)" % [TAG, "OK" if _failures.is_empty() else "FAILED", _failures.size(), elapsed])
	get_tree().quit(0 if _failures.is_empty() else 1)
