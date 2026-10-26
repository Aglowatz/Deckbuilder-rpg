class_name GamepadSmoke
extends Node
## Controller support (Oct 26): the opening hour played with simulated controller events only (`PadDriver`; no key, no mouse event is sent).
## New Game -> the wake-up lines (A) -> the Path choice (D-pad + A) -> the gate (stick walk + A, the confirm box) -> the Forgotten Cave (the
## Session's exit, like the playtest smoke) -> Crosspath: Maren's welcome (A), a stick walk, Sable's shop (category, a card bought, B back out),
## Tilly, Pip, Maren -> the pack step (D-pad Up opens the HUD menu, Packs, a pack opened) -> the Deck Station (a rack slot by pad, B out) -> the
## store room ghosts: a real duel turn by pad (the opening hand kept, a card played, combat, end turn) then the win -> Maren and level 5 ->
## Bertram, a roamer, the gear -> the Character screen (Y), the Quest Log (D-pad Left, bumpers), the map (View), the pause menu (Start) with
## Settings > Controls, B back out. Long walks are teleports (as in the playtest smoke); every press is a pad press.
## Run windowed:  bash tools/run_gamepad_smoke.sh   (exit code 0 = every check passed; screenshots in _screenshots/gamepad/).

const TIME_LIMIT_SECONDS: float = 60.0
const TAG: String = "gamepad_smoke"

var pad: PadDriver
var _failures: PackedStringArray = []
var _started_msec: int = -1
## Every key / mouse event that reached the game (there must be none: the smoke is pad-only).
var _foreign_events: int = 0


func run() -> void:
	_started_msec = Time.get_ticks_msec()
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	pad = PadDriver.new(get_tree())
	await pad.frames(10)
	var scene: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if scene == null:
		_finish(false, "starting area never loaded")
		return
	await pad.seconds(0.8)
	await pad.tap(JOY_BUTTON_A)
	_check(InputDevice.using_pad(), "the first pad press switches the prompts to the controller")
	_check(Keybinds.first_key(&"interact") == "A" and PromptText.render("[E]") == "[A]", "prompts name the pad's buttons")
	var hints: Label = scene.find_child("HintLine", true, false) as Label
	_check(hints != null and hints.text.contains("Left stick"), "the hint line speaks controller (%s)" % (hints.text if hints != null else "none"))
	# 1. The wake-up lines with A, then the Path choice with the D-pad.
	var guard: int = 0
	while _find_element_choice(scene) == null and guard < 80:
		guard += 1
		await pad.tap(JOY_BUTTON_A)
		await pad.seconds(0.2)
	var choice: ElementChoiceScreen = _find_element_choice(scene)
	_check(choice != null, "A through the wake-up lines reaches the Path choice")
	if choice == null:
		_finish(false, "the Path choice never appeared")
		return
	await pad.seconds(0.4)
	var tile: Button = choice._tiles[Affinity.Type.BEEFCAKE] as Button
	var on_tile: bool = await pad.focus_to(func(control: Control) -> bool: return control == tile, 8)
	_check(on_tile, "the D-pad walks the Path tiles to Beefcake")
	await pad.tap(JOY_BUTTON_A)
	await pad.seconds(0.3)
	var begin: bool = await pad.press_button("Begin")
	_check(begin, "Begin is reachable with the D-pad")
	await pad.seconds(0.6)
	_check(Session.has_profile() and Session.profile.primary_affinity == Affinity.Type.BEEFCAKE, "the pad's Path choice sets the primary Path")
	await _through(func() -> bool: return scene.dialogue.active or scene._rescuer != null or scene._locked, func() -> void: pass)
	# 2. The gate: a stick walk next to it, A, and the confirm box's Enter.
	var gate: Vector3 = scene.area.anchors.get("gate", Vector3.ZERO) as Vector3
	scene.player.position = gate + Vector3(0.0, 0.0, 2.4)
	await pad.seconds(0.3)
	var before: Vector3 = scene.player.position
	await pad.walk(Vector2(0.0, -1.0), 0.6)
	_check(scene.player.position.distance_to(before) > 0.5, "the left stick walks the hero (%.2f m)" % scene.player.position.distance_to(before))
	scene.player.position = gate + Vector3(0.0, 0.0, 0.2)
	await pad.seconds(0.4)
	await _shot("01_gate_prompt")
	await pad.tap(JOY_BUTTON_A)
	await pad.seconds(0.5)
	_check(PadFocus.top_root(get_tree()) is ConfirmDialog, "A at the gate asks to enter")
	var entered: bool = await pad.press_button("Enter")
	_check(entered, "the confirm box's Enter by pad")
	await pad.seconds(1.0)
	_check(Session.in_dungeon(), "the Forgotten Cave starts")
	while SceneManager.busy:
		await pad.frames(5)
	# 3. Out of the cave (the Session's exit, as in the playtest smoke).
	Session.add_xp(int(TrialOfTheHollow.total_tutorial_rewards()["xp"]))
	Session.complete_trial()
	Session.cave_exit_pending = true
	SceneManager.skip_loading_once = true
	SceneManager.go_to_town()
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "Crosspath never loaded after the cave")
		return
	await pad.seconds(1.0)
	_check(town.dialogue.active and town.dialogue.npc_id == "NPC-ELDER", "Maren's welcome opens")
	await _shot("02_maren_welcome")
	await _talk_through(town)
	_check(not town._locked and not town.dialogue.active, "A through Maren's welcome frees the hero")
	var start: Vector3 = town.player.position
	var farthest: float = 0.0
	for direction: Vector2 in [Vector2(0.0, 1.0), Vector2(-1.0, 0.0), Vector2(0.0, -1.0), Vector2(1.0, 0.0)]:
		await pad.walk(direction, 0.4)
		farthest = maxf(farthest, town.player.position.distance_to(start))
	_check(farthest > 0.3, "the stick walks in Crosspath (%.2f m)" % farthest)
	# A half-tilted stick walks slower than a full one (the same way, back and forth).
	var half_start: Vector3 = town.player.position
	await pad.walk(Vector2(0.0, 0.5), 0.5)
	var half: float = town.player.position.distance_to(half_start)
	var full_start: Vector3 = town.player.position
	await pad.walk(Vector2(0.0, -1.0), 0.5)
	var full: float = town.player.position.distance_to(full_start)
	_check(half > 0.05 and full > half * 1.2, "a half-tilted stick walks slower (%.2f m vs %.2f m)" % [half, full])
	# 4. Meet the Merchants: Sable's shop by pad (the Cards category, a card bought), Tilly, Pip.
	await _talk(town, "vendor")
	var vendor: VendorScreen = null
	for node: Node in get_tree().root.find_children("*", "VendorScreen", true, false):
		vendor = node as VendorScreen
	_check(vendor != null and vendor.is_on_picker(), "Sable's shop opens on its categories")
	if vendor != null:
		await pad.seconds(0.5)
		_check(get_viewport().gui_get_focus_owner() != null and vendor.is_ancestor_of(get_viewport().gui_get_focus_owner()), "the shop has the pad's focus")
		var cards: bool = await pad.press_button("Cards")
		_check(cards and not vendor.is_on_picker(), "the Cards category by pad")
		await pad.seconds(0.8)
		var affordable: Callable = func(control: Control) -> bool:
			if not control is CardView or (control as CardView).data == null:
				return false
			var data: CardData = (control as CardView).data
			return CardPricing.is_for_sale(data, Session.owned_count(data.id), Session.copy_cap(data)) and Session.effective_price(CardPricing.price(data)) <= Session.gold
		var found: bool = await pad.focus_to(affordable, 30)
		_check(found, "the D-pad reaches a card Sable sells that the hero can afford")
		await _shot("03_sable_card_focused")
		await pad.tap(JOY_BUTTON_A)
		await pad.seconds(0.4)
		_check(PadFocus.top_root(get_tree()) is ConfirmDialog, "A on the card asks to buy it")
		await pad.press_button("Buy")
		await pad.seconds(0.4)
		_check(Session.counter("cards_bought") >= 1, "a card bought from Sable by pad")
		await pad.tap(JOY_BUTTON_B)
		await pad.seconds(0.4)
		_check(vendor.is_inside_tree() and vendor.is_on_picker(), "B steps back to the categories")
	await _close_overlays(town)
	_check(town._overlay == null, "B leaves the shop")
	await _talk(town, "item_vendor")
	await _close_overlays(town)
	await _talk(town, "tailor")
	await _close_overlays(town)
	await _talk(town, "elder")
	await _dismiss_popups()
	_check(Session.quest_log.is_completed(QuestDefinitions.MERCHANTS), "Maren takes Meet the Merchants back")
	# 5. The pack step: D-pad Up opens the HUD menu focused; Packs; open the pack; A through it.
	await pad.seconds(0.6)
	await _wait_notices()
	await pad.tap(JOY_BUTTON_DPAD_UP)
	await pad.seconds(0.3)
	_check(town.hud.is_menu_open(), "D-pad Up opens the HUD menu")
	await _shot("04_hud_menu")
	var packs: bool = await pad.press_button("Packs")
	_check(packs, "the menu's Packs entry by pad")
	await pad.seconds(0.8)
	await _shot("05a_packs_screen")
	var opened: bool = await pad.press_button("Open")
	_check(opened, "the Packs screen's Open by pad")
	await pad.seconds(1.0)
	for _guard: int in range(30):
		if get_tree().root.find_children("*", "PackOpeningScreen", true, false).is_empty():
			break
		var done: Button = _focused_button()
		if done != null and (done.text == "Done" or done.text.begins_with("Open another")):
			await _shot("05_pack_summary")
			await pad.press_button("Done")
		else:
			await pad.tap(JOY_BUTTON_A)
		await pad.seconds(0.4)
	await _close_overlays(town)
	_check(Session.flag(StringName(QuestDefinitions.FIRST_PACK_FLAG)), "a pack opened by pad")
	# 6. Make It Yours: the Deck Station by A, a rack slot, B out.
	town.player.position = (town.town.anchors["deck"] as Vector3) + Vector3(0.0, 0.0, 0.3)
	await pad.seconds(0.5)
	await pad.tap(JOY_BUTTON_A)
	await pad.seconds(1.0)
	var station: DeckbuilderScreen = null
	for node: Node in get_tree().root.find_children("*", "DeckbuilderScreen", true, false):
		station = node as DeckbuilderScreen
	_check(station != null, "A at the Deck Station opens it")
	if station != null:
		Session.new_saved_deck("Smoke Deck", ["BAS-B", "BAS-B", "B-01", "B-03"] as Array[String])
		station.call(&"_refresh_rack")
		await pad.seconds(0.3)
		var rack: DeckRack = station.find_child("DeckRack", true, false) as DeckRack
		var slot: Control = rack.tiles[1] if rack != null else null
		var on_slot: bool = await pad.focus_to(func(control: Control) -> bool: return control == slot, 30)
		if not on_slot:
			on_slot = await pad.focus_to(func(control: Control) -> bool: return control == slot, 20)
		_check(on_slot, "the D-pad reaches rack slot 2")
		await pad.tap(JOY_BUTTON_A)
		await pad.seconds(0.5)
		_check(station.editor.deck.size() == 4, "A on rack slot 2 opens the deck saved there (%d cards)" % station.editor.deck.size())
		await _shot("06_deck_station")
		var card_focus: bool = await pad.focus_to(func(control: Control) -> bool: return control is CardView, 20)
		_check(card_focus, "the collection's cards take the pad focus")
		var before_size: int = station.editor.deck.size()
		await pad.tap(JOY_BUTTON_A)
		await pad.seconds(0.3)
		_check(station.editor.deck.size() == before_size + 1, "A adds the focused card to the deck")
		await pad.tap(JOY_BUTTON_X)
		await pad.seconds(0.3)
		_check(station.editor.deck.size() == before_size, "X takes one out again")
		await pad.tap(JOY_BUTTON_B)
		await pad.seconds(0.4)
		var confirm: Node = PadFocus.top_root(get_tree())
		_check(confirm is ConfirmDialog, "B with unsaved changes asks first")
		if confirm is ConfirmDialog:
			var discarded: bool = await pad.press_button("Discard")
			_check(discarded, "Discard by pad leaves the station")
			await pad.seconds(0.4)
	await _close_overlays(town)
	Session.save_deck_to_slot(0, Session.deck, "Main")
	await _talk(town, "elder")
	await _dismiss_popups()
	_check(Session.quest_log.is_active(QuestDefinitions.GHOSTS), "Maren sends the hero to the store room")
	# 7. The store room ghosts: one real turn by pad, then the win.
	await _talk(town, StoreroomGhosts.SPOT_ID, false)
	await _talk_through(town)
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null and battle.context.storeroom_battle, "the store room door starts the ghost duel")
	if battle == null:
		_finish(false, "no battle at the store room door")
		return
	await _pad_turn(battle)
	await _force_win(battle)
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "Crosspath never came back after the ghosts")
		return
	await pad.seconds(1.0)
	await _talk_through(town)
	await _dismiss_popups()
	await _talk(town, "elder", false)
	await _talk_through(town)
	await pad.seconds(0.6)
	await _dismiss_popups()
	_check(Session.profile.level == ProgressionTable.ARMORY_LEVEL, "level 5 at Maren")
	_check(Session.quest_log.is_active(QuestDefinitions.ARMORY), "Maren sends the hero to Bertram")
	# 8. The armory: Bertram, a roamer, the gear.
	await _talk(town, "equipment_vendor")
	await _close_overlays(town)
	var roamer: ZoneEnemy = town.enemies[0]
	town.player.position = roamer.position + Vector3(0.3, 0.0, 0.0)
	await pad.seconds(1.5)
	var roamer_battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(roamer_battle != null, "touching a roamer starts a duel")
	if roamer_battle == null:
		_finish(false, "no roamer battle")
		return
	await _force_win(roamer_battle)
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "Crosspath never came back after the roamer")
		return
	await pad.seconds(1.0)
	await _dismiss_popups()
	await _talk(town, "equipment_vendor")
	await _close_overlays(town)
	await _dismiss_popups()
	_check(Session.quest_log.is_completed(QuestDefinitions.ARMORY) and Session.gear_unlocked(), "the gear by pad")
	# 9. The menus by their pad buttons.
	await pad.tap(JOY_BUTTON_Y)
	await pad.seconds(0.8)
	_check(town._overlay is CharacterScreen, "Y opens the Character screen")
	await _shot("07_character_screen")
	await pad.flick(Vector2(0.0, 1.0))
	await pad.seconds(0.2)
	_check(get_viewport().gui_get_focus_owner() != null and town._overlay != null and town._overlay.is_ancestor_of(get_viewport().gui_get_focus_owner()), "the Character screen holds the focus")
	await _close_overlays(town)
	await pad.tap(JOY_BUTTON_DPAD_LEFT)
	await pad.seconds(0.8)
	_check(town._overlay is QuestLogScreen, "D-pad Left opens the Quest Log")
	var tab_before: int = (town._overlay as QuestLogScreen)._tab if town._overlay is QuestLogScreen else -1
	await pad.tap(JOY_BUTTON_RIGHT_SHOULDER)
	await pad.seconds(0.3)
	_check(town._overlay is QuestLogScreen and (town._overlay as QuestLogScreen)._tab != tab_before, "RB switches the Quest Log's tab")
	await _shot("08_quest_log")
	await _close_overlays(town)
	await pad.tap(JOY_BUTTON_BACK)
	await pad.seconds(0.8)
	_check(town._overlay is FullMapScreen, "View opens the map")
	await _close_overlays(town)
	await pad.tap(JOY_BUTTON_START)
	await pad.seconds(0.5)
	var paused: bool = get_tree().paused
	_check(paused, "Start pauses")
	var focused: Button = _focused_button()
	_check(focused != null and focused.text == "Resume", "the pause menu focuses Resume")
	var settings: bool = await pad.press_button("Settings")
	_check(settings, "Settings by pad")
	await pad.seconds(0.3)
	var controls: bool = await pad.press_button("Controls")
	_check(controls, "the Controls page by pad")
	await pad.seconds(0.3)
	var pad_slot: Button = get_tree().root.find_child("Key_open_map", true, false).find_child("PadSlot", true, false) as Button if get_tree().root.find_child("Key_open_map", true, false) != null else null
	_check(pad_slot != null and pad_slot.text == "View", "the Controls page lists the map on View")
	await _shot("09_settings_controls")
	await pad.tap(JOY_BUTTON_B)
	await pad.seconds(0.3)
	focused = _focused_button()
	_check(get_tree().root.find_children("*", "SettingsPanel", true, false).is_empty() or focused != null and focused.text == "Settings", "B leaves the settings")
	await pad.tap(JOY_BUTTON_B)
	await pad.seconds(0.4)
	_check(not get_tree().paused, "B closes the pause menu")
	_check(_foreign_events == 0, "no key or mouse event reached the game (%d)" % _foreign_events)
	_check(pad.sent > 100, "%d pad events sent" % pad.sent)
	_finish(_failures.is_empty(), "gamepad: the Path choice, the gate, Maren, Sable's shop, a pack, the Deck Station, a ghost duel turn, level 5, Bertram, the menus, the pause menu")


# ---- Helpers ----------------------------------------------------------------------------


## One turn of a real duel by pad: the opening hand kept, playable cards played from where the cursor starts, X to combat, X again, End Turn.
func _pad_turn(battle: BattleScreen) -> void:
	for _guard: int in range(40):
		if battle.mode == BattleScreen.Mode.MULLIGAN and PadFocus.top_root(get_tree()) != null:
			break
		await pad.seconds(0.25)
	await _shot("10_battle_mulligan")
	await pad.tap(JOY_BUTTON_DPAD_DOWN)
	var kept: bool = await pad.press_button("Keep")
	_check(kept, "Keep Hand by pad")
	for _guard: int in range(60):
		if battle.mode == BattleScreen.Mode.MAIN and not battle.busy and PadFocus.top_root(get_tree()) == null:
			break
		if PadFocus.top_root(get_tree()) != null:
			await pad.tap(JOY_BUTTON_A)  # a tip's "Got it", a confirm
		await pad.seconds(0.25)
	_check(battle.mode == BattleScreen.Mode.MAIN, "the duel reaches the main phase")
	await pad.seconds(0.4)
	_check(battle.pad.active() and not battle.pad.current().is_empty(), "the battle cursor is up")
	await _shot("11_battle_cursor")
	var played: int = 0
	for _step: int in range(3):
		battle.pad.reset()
		await pad.frames(2)
		if str(battle.pad.cursor.get("kind", "")) != "card":
			break
		var before: int = battle.game.players[0].hand.size()
		await pad.tap(JOY_BUTTON_A)
		await pad.seconds(1.2)
		if battle.mode == BattleScreen.Mode.TARGETING:
			await _shot("12_battle_target")
			await pad.tap(JOY_BUTTON_A)
			await pad.seconds(1.2)
		if battle.game.players[0].hand.size() < before:
			played += 1
		else:
			break
	_check(played >= 1, "A on the cursor plays cards (%d)" % played)
	await pad.tap(JOY_BUTTON_DPAD_RIGHT)
	await pad.tap(JOY_BUTTON_Y)
	_check(not battle.pad.details, "Y hides the card details")
	await pad.tap(JOY_BUTTON_Y)
	await pad.tap(JOY_BUTTON_X)
	await pad.seconds(1.5)
	if battle.mode == BattleScreen.Mode.ATTACK:
		await pad.tap(JOY_BUTTON_X)
		await pad.seconds(2.5)
	await pad.tap(JOY_BUTTON_X)
	await pad.seconds(0.8)
	if PadFocus.top_root(get_tree()) is ConfirmDialog:
		await _shot("13_end_turn_confirm")
		await pad.press_button("End Turn")
	for _guard: int in range(60):
		if battle.game.turn >= 2 and battle.game.active == 0 or battle.game.is_over():
			break
		if battle.mode == BattleScreen.Mode.BLOCK and not battle.busy:
			await pad.tap(JOY_BUTTON_X)  # no blocks
		await pad.seconds(0.3)
	_check(battle.game.turn >= 2, "the pad ended the turn and the enemy played (turn %d)" % battle.game.turn)


## Walks up to a town spot (a teleport beside it) and presses A; `through` taps A through the talk that follows.
func _talk(town: TownScene, spot_id: String, through: bool = true) -> void:
	for spot: Variant in town.spots:
		if str(spot.id) == spot_id:
			town.player.position = (spot.position as Vector3) + Vector3(0.0, 0.0, 0.3)
	await pad.seconds(0.5)
	await pad.tap(JOY_BUTTON_A)
	await pad.seconds(0.5)
	if through:
		await _talk_through(town)


func _talk_through(town: TownScene) -> void:
	var guard: int = 0
	while guard < 60 and is_instance_valid(town) and town.is_inside_tree() and (town.dialogue.active or town._locked) and town._overlay == null and not _popup_up():
		guard += 1
		await pad.tap(JOY_BUTTON_A)
		await pad.seconds(0.3)


func _through(busy: Callable, _after: Callable) -> void:
	var guard: int = 0
	while guard < 80 and bool(busy.call()):
		guard += 1
		await pad.tap(JOY_BUTTON_A)
		await pad.seconds(0.25)


func _close_overlays(town: TownScene) -> void:
	for _guard: int in range(8):
		if town._overlay == null and not (PadFocus.top_root(get_tree()) is ConfirmDialog):
			break
		await pad.tap(JOY_BUTTON_B)
		await pad.seconds(0.4)


func _dismiss_popups() -> void:
	for _guard: int in range(16):
		var root: Control = PadFocus.top_root(get_tree())
		if root is PopupFrame or root is LevelUpScreen or root is RewardPopup or (root != null and root.find_child("PopupFrame", true, false) != null):
			await pad.tap(JOY_BUTTON_A)
		else:
			break
		await pad.seconds(0.5)


func _wait_notices() -> void:
	for _guard: int in range(40):
		var notices: QuestNoticeLayer = SceneManager.quest_notices
		if notices == null or (notices.current.is_empty() and notices.queued() == 0):
			return
		await pad.seconds(0.25)


func _popup_up() -> bool:
	var root: Control = PadFocus.top_root(get_tree())
	return root is PopupFrame or root is LevelUpScreen or root is ConfirmDialog


func _focused_button() -> Button:
	return get_viewport().gui_get_focus_owner() as Button


func _force_win(battle: BattleScreen) -> void:
	var context: BattleContext = battle.context
	await pad.seconds(0.8)
	if context == null:
		return
	context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
	context.game._end_game(0, false)
	context.won = true
	Session.complete_battle(context)
	await pad.seconds(1.0)


func _shot(shot_name: String) -> void:
	await pad.frames(3)
	var path: String = ProjectSettings.globalize_path("res://_screenshots/gamepad/%s.png" % shot_name)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	get_viewport().get_texture().get_image().save_png(path)
	print("%s: screenshot -> %s.png" % [TAG, shot_name])


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < TIME_LIMIT_SECONDS:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await pad.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _find_element_choice(scene: StartingAreaScene) -> ElementChoiceScreen:
	for child: Node in scene._overlay_layer.get_children():
		if child is ElementChoiceScreen:
			return child as ElementChoiceScreen
	return null


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		_foreign_events += 1


func _elapsed() -> String:
	return "%5.1fs" % (float(Time.get_ticks_msec() - _started_msec) / 1000.0)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    [%s] %s" % [TAG, _elapsed(), message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])
		push_error("%s: %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s (%s)" % [TAG, "OK" if ok else "FAILED", reason, _elapsed()])
	get_tree().quit(0 if ok else 1)
