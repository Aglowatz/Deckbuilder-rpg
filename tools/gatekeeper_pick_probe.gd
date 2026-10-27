extends Node
## Fixes Oct 27, Part 1: wins each zone gatekeeper through the real `Session.complete_battle` path, back in Crosspath plays what follows
## like a player (dialogue, level-up, the card pick) with one input device (PICK_MODE=mouse|key|pad) and logs what was on screen when,
## and whether a card was actually picked. Run windowed:  bash tools/run_gatekeeper_pick_probe.sh [mouse|key|pad]
## The first-battles smoke hands over to it (`run_after_battle`): a gatekeeper fight it played and won, picked by mouse, then a second
## gatekeeper picked by pad.

var TAG: String = "gatekeeper_pick_probe"
## Lines the smoke printed before handing over, and its failures (this node quits the game).
var prior_report: PackedStringArray = []

## UiDriver and PadDriver, loaded by path (they are tools, not in an exported pack: the exported check loads this file from disk).
var mouse: Variant
var pad: Variant
var mode: String = "mouse"
var _failures: PackedStringArray = []


func run() -> void:
	mode = OS.get_environment("PICK_MODE") if not OS.get_environment("PICK_MODE").is_empty() else "mouse"
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	mouse = _tool("ui_driver.gd").new(get_tree())
	pad = _tool("pad_driver.gd").new(get_tree())
	var town: TownScene = await _wait_for_town()
	if town == null:
		_finish("Crosspath never loaded")
		return
	await mouse.seconds(1.0)
	await _settle(town)
	for id: String in CorruptedNpcs.IDS:
		await _one(id)
	_finish("")


## The first-battles smoke's ending: `won` (a gatekeeper fight the smoke played, already won) is completed from the battle and picked by
## mouse; then `second_id` is won and picked by pad.
func run_after_battle(won: BattleContext, second_id: String, failures: PackedStringArray) -> void:
	_failures = failures
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	mouse = _tool("ui_driver.gd").new(get_tree())
	pad = _tool("pad_driver.gd").new(get_tree())
	mode = "mouse"
	await _one(won.town_npc_id, won)
	mode = "pad"
	await _one(second_id)
	_finish("")


func _one(id: String, won: BattleContext = null) -> void:
	var context: BattleContext = won
	if context == null:
		context = Session.make_npc_challenge_battle(id)
		Session.pending_battle = null
		context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
		context.game._end_game(0, false)
		context.won = true
	var owned_before: Dictionary = _owned()
	# The probe stands in town when it ends the fight (the game is in the battle scene): hold the old town so it cannot open the queued box
	# in the frames before it is replaced.
	var old_town: TownScene = get_tree().current_scene as TownScene
	if old_town != null:
		old_town._locked = true
		old_town.set_process(false)
	Session.complete_battle(context)
	await mouse.frames(5)
	var town: TownScene = await _wait_for_town()
	if town == null:
		_fail("%s: Crosspath never came back" % id)
		return
	var picked: CardData = null
	var saw_pick: bool = false
	var pick_closed_unpicked: bool = false
	var watched: RewardPopup = null
	var elapsed: float = 0.0
	var last_state: String = ""
	while elapsed < 25.0:
		var state: String = "dialogue=%s overlay=%s popups=%d level_ups=%d locked=%s results_pending=%s top=%s" % [town.dialogue.active, _name(town._overlay), Session.pending_popups.size(), Session.pending_level_ups.size(), town._locked, town.get("_results_pending"), _name(PadFocus.top_root(get_tree()))]
		if state != last_state:
			print("%s: [%s %.1fs] %s" % [TAG, id, elapsed, state])
			last_state = state
		var popup: RewardPopup = town._overlay as RewardPopup if is_instance_valid(town._overlay) else null
		if watched != null and not is_instance_valid(watched) and watched.summary.picked == null:
			pick_closed_unpicked = true
		if popup != null and not popup.summary.card_choices.is_empty() and popup != watched:
			watched = popup
			saw_pick = true
			print("%s: [%s %.1fs] pick box: %d cards (%s), overlay=%s dialogue=%s level_up_open=%s" % [TAG, id, elapsed, popup.summary.card_choices.size(), _ids(popup.summary.card_choices), _name(town._overlay), town.dialogue.active, _has(LevelUpScreen)])
			await mouse.seconds(PopupFrame.GUARD_TIME + 0.3)
			await _shot("%s_%s_pick_open" % [mode, id])
			if is_instance_valid(popup):
				await _pick_second(popup)
				if is_instance_valid(popup):
					picked = popup.summary.picked
					print("%s: [%s] after the %s pick: picked=%s" % [TAG, id, mode, picked.id if picked != null else "none"])
					await _shot("%s_%s_picked" % [mode, id])
					await _confirm(popup.frame.button)
			elapsed += 1.0
			continue
		if town.dialogue.active:
			await _advance()
		elif _top_popup() != null:
			var other: RewardPopup = town._overlay as RewardPopup
			print("%s: [%s %.1fs] other box: %s %s" % [TAG, id, elapsed, _name(_top_popup()), ("'%s' kind %d, %d choices" % [other.summary.title, other.summary.kind, other.summary.card_choices.size()]) if other != null else ""])
			await _confirm(null)
		elif saw_pick and not town._locked:
			break
		await mouse.seconds(0.3)
		elapsed += 0.4
	var gained: PackedStringArray = []
	var now: Dictionary = _owned()
	for card_id: Variant in now.keys():
		if int(now[card_id]) > int(owned_before.get(card_id, 0)):
			gained.append(str(card_id))
	print("%s: [%s] result: saw_pick=%s picked=%s closed_unpicked=%s cards_gained=%s" % [TAG, id, saw_pick, picked.id if picked != null else "none", pick_closed_unpicked, ",".join(gained)])
	if not saw_pick:
		_fail("%s: no pick box" % id)
	elif picked == null or not gained.has(picked.id):
		_fail("%s: the %s pick did not add a card" % [id, mode])
	await _settle(town)


## Picks the second card with the probe's input device.
func _pick_second(popup: RewardPopup) -> void:
	var tile: Control = popup.find_child("Pick_1", true, false) as Control
	if tile == null:
		_fail("no Pick_1 tile")
		return
	match mode:
		"mouse":
			await mouse.click(tile.get_global_rect().get_center())
		"key":
			await mouse.tap_key(KEY_RIGHT)  # the first card
			await mouse.frames(3)
			await mouse.tap_key(KEY_RIGHT)  # the second
		"pad":
			var reached: bool = await pad.focus_until(func(control: Control) -> bool: return control == tile, JOY_BUTTON_DPAD_RIGHT, 6)
			if not reached:
				await pad.focus_until(func(control: Control) -> bool: return control == tile, JOY_BUTTON_DPAD_UP, 4)
				await pad.focus_until(func(control: Control) -> bool: return control == tile, JOY_BUTTON_DPAD_RIGHT, 4)
			print("%s: pad focus on %s" % [TAG, _name(get_viewport().gui_get_focus_owner())])
			await pad.tap(JOY_BUTTON_A)
	await mouse.seconds(0.4)


func _confirm(button: Button) -> void:
	match mode:
		"mouse":
			if button == null:
				var root: Control = _top_popup()
				button = mouse.find_button("Continue", root) if root != null else null
			if button != null:
				await mouse.click(button.get_global_rect().get_center())
			else:
				await mouse.click(Vector2(960, 1000))
		"key":
			await mouse.tap_key(KEY_ENTER)
		"pad":
			if button != null:
				await pad.focus_until(func(control: Control) -> bool: return control == button, JOY_BUTTON_DPAD_DOWN, 4)
			await pad.tap(JOY_BUTTON_A)
	await mouse.seconds(0.5)


func _advance() -> void:
	match mode:
		"mouse":
			var town: TownScene = get_tree().current_scene as TownScene
			var panel: Control = town.dialogue._panel if town != null else null
			var at: Vector2 = panel.get_global_rect().get_center() if panel != null and panel.is_visible_in_tree() else Vector2(800, 450)
			await mouse.move_to(at)
			var hovered: Control = get_viewport().gui_get_hovered_control()
			print("%s: dialogue click at %s hovers %s (%s)" % [TAG, at, _name(hovered), hovered.get_path() if hovered != null else ""])
			await mouse.click(at)
		"key":
			await mouse.tap_key(KEY_ENTER)
		"pad":
			await pad.tap(JOY_BUTTON_A)


func _settle(town: TownScene) -> void:
	for _i: int in range(40):
		if not town.dialogue.active and _top_popup() == null and not town._locked:
			return
		if town.dialogue.active:
			await _advance()
		elif _top_popup() != null:
			await _confirm(null)
		await mouse.seconds(0.3)


func _top_popup() -> Control:
	var root: Control = PadFocus.top_root(get_tree())
	if root is PopupFrame or root is LevelUpScreen or root is RewardPopup or (root != null and root.find_child("PopupFrame", true, false) != null):
		return root
	return null


func _reward_popup() -> RewardPopup:
	for node: Node in get_tree().root.find_children("*", "RewardPopup", true, false):
		return node as RewardPopup
	for node: Node in get_tree().root.find_children("RewardPopup", "", true, false):
		if node is RewardPopup:
			return node as RewardPopup
	return null


func _has(kind: Variant) -> bool:
	for node: Node in get_tree().root.find_children("*", "", true, false):
		if is_instance_of(node, kind):
			return true
	return false


func _owned() -> Dictionary:
	var result: Dictionary = {}
	for source: Dictionary in [Session.content.cards, Session.content.multipath_cards]:
		for id: Variant in source.keys():
			result[id] = Session.profile.owned_copies(str(id))
	return result


func _ids(cards: Array[CardData]) -> String:
	var ids: PackedStringArray = []
	for card: CardData in cards:
		ids.append(card.id)
	return ",".join(ids)


func _name(node: Variant) -> String:
	if node == null or not is_instance_valid(node):
		return "none"
	var script: Script = (node as Object).get_script() as Script
	var global: String = script.get_global_name() if script != null else ""
	return "%s(%s)" % [global if not global.is_empty() else (node as Object).get_class(), (node as Node).name]


func _wait_for_town() -> TownScene:
	for _i: int in range(600):
		var scene: Node = get_tree().current_scene
		if scene is TownScene and not SceneManager.busy and (scene as TownScene)._built:
			return scene as TownScene
		await mouse.frames(5)
	return null


func _shot(shot_name: String) -> void:
	await mouse.frames(3)
	var path: String = ProjectSettings.globalize_path("res://_screenshots/gatekeeper_pick/%s.png" % shot_name)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	get_viewport().get_texture().get_image().save_png(path)
	print("%s: screenshot -> %s" % [TAG, path])


func _fail(message: String) -> void:
	_failures.append(message)
	print("%s: FAIL  %s" % [TAG, message])


func _finish(reason: String) -> void:
	for line: String in prior_report:
		print("%s: %s" % [TAG, line])
	for failure: String in _failures:
		print("%s: FAIL - %s" % [TAG, failure])
	var ok: bool = reason.is_empty() and _failures.is_empty()
	print("%s: %s %s (%d failures)" % [TAG, "OK" if ok else "FAILED", reason, _failures.size()])
	get_tree().quit(0 if ok else 1)


func _tool(file: String) -> GDScript:
	return load((get_script() as Script).resource_path.get_base_dir().path_join(file)) as GDScript
