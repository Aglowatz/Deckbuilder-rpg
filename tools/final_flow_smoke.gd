class_name FinalFlowSmoke
extends Node
## FINAL: the whole new brief's flow with human-style input, end to end - skip tunnel (Part D) ->
## choose an element -> town -> the dev shrine (Part E) up to level 5 (popup each time, plus the
## equipment-slot choice screen at level 5) -> character screen shows the newly-unlocked slot
## (Part C) -> a real battle with an equipped item, checking its hover tooltip (Part B) -> win it
## -> a level-up popup fires again after the win (Part A, same screen as every other source).
## Screenshots every new/changed screen along the way to _screenshots/ (git-ignored).
## Uses the same launcher pattern as tools/e2e_demo.gd/e2e_launcher.gd (added to get_tree().root
## directly, so it survives the starting-area -> town scene change) - see
## tools/final_flow_launcher.gd. Run windowed (real viewport needed for injected input):
##   Godot --path . res://tools/final_flow_launcher.tscn
## Exit code 0 = every check passed; 1 = a check failed.

const STALL_LIMIT: float = 20.0

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	driver = UiDriver.new(get_tree())
	await driver.frames(10)

	await _skip_tutorial_via_tunnel()
	var town: TownScene = await _wait_for(TownScene)
	_check(town != null, "the tunnel leads to town")
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)
	_shot(town, "final_01_town_after_tunnel_skip")

	await _visit_dev_shrine_until_level_five(town)
	_check(Session.profile.level >= 5, "dev-shrine visits reach at least level 5 (got %d)" % Session.profile.level)
	_check(Session.profile.has_equipment_slot(EquipmentData.Slot.HELM), "the level-5 equipment choice unlocked a slot")

	await _check_character_screen_shows_unlocked_slot(town)

	var item: ItemData = _equip_a_test_item()
	_nudge_xp_to_cross_a_level_on_the_next_win()

	var battle_town: TownScene = await _fight_and_win_corrupted_npc(town, item)
	_check(battle_town != null, "returned to town after the fight")
	if battle_town == null:
		_finish(false, "did not return to town after the fight")
		return

	await _dismiss_dialogue_on(battle_town.dialogue)
	await driver.seconds(0.4)
	_check(battle_town._overlay is LevelUpScreen, "winning while crossing a level shows the level-up popup again")
	if battle_town._overlay is LevelUpScreen:
		_shot(battle_town, "final_05_levelup_after_battle_win")
		await _drive_level_up(battle_town)

	_finish(_failures.is_empty(), "skip tunnel -> element -> town -> 5x dev shrine -> character screen -> battle with equipped item -> win -> level-up popup")


# ---- Steps ------------------------------------------------------------------------------


func _skip_tutorial_via_tunnel() -> void:
	var starting: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	_check(starting != null, "starting area loads")
	if starting == null:
		return
	await _dismiss_dialogue_on(starting.dialogue)
	var tunnel: Vector3 = starting.area.anchors.get("tunnel", Vector3.ZERO) as Vector3
	await _walk_to_position(starting, tunnel, StartingAreaScene.TUNNEL_RADIUS)
	await driver.frames(3)
	_check(starting._prompt_panel.visible and starting._prompt_label.text.contains("tunnel"), "the hidden tunnel's prompt shows up close")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss_dialogue_on(starting.dialogue)
	var choice: ElementChoiceScreen = null
	for child: Node in starting._overlay_layer.get_children():
		if child is ElementChoiceScreen:
			choice = child as ElementChoiceScreen
	_check(choice != null, "the tunnel offers the same element choice as the real gate")
	if choice == null:
		return
	var tile: Button = choice._tiles[Affinity.Type.A] as Button
	await driver.click(driver.center_of_control(tile))
	await driver.click_button("Begin")
	await driver.seconds(0.6)
	_check(not Session.in_dungeon(), "the tunnel skips the tutorial dungeon")
	_check(Session.deck != null and Session.deck.size() == 45, "the tunnel grants a full 45-card deck")


## Each visit grants exactly one level (Session.grant_dev_level), but a fresh profile starts at
## level 1, so reaching level 5 takes 4 visits, not 5 - looping on the actual level (with a safety
## cap) rather than a hardcoded visit count so this cannot go stale if that ever changes.
func _visit_dev_shrine_until_level_five(town: TownScene) -> void:
	_check(town.town.anchors.has("dev_shrine"), "the dev shrine exists (a debug build)")
	var visits: int = 0
	while Session.profile.level < 5 and visits < 10:
		visits += 1
		await _walk_to(town, "dev_shrine")
		await driver.frames(3)
		_check(town.hud._prompt_label.text.contains("Dev Shrine"), "the dev shrine's prompt shows up close")
		await driver.tap_key(KEY_E)
		await driver.seconds(0.5)
		var will_hit_five: bool = Session.profile.level == 5
		if town._overlay is LevelUpScreen and will_hit_five:
			await driver.frames(3)
			_shot(town, "final_02_shrine_level5_popup")
		await _drive_level_up(town)
		await driver.frames(10)
	_check(visits <= 5, "reaching level 5 took a sane number of shrine visits (%d)" % visits)


func _check_character_screen_shows_unlocked_slot(town: TownScene) -> void:
	await driver.tap_key(KEY_C)
	await driver.seconds(0.4)
	_check(town._overlay is CharacterScreen, "the C hotkey opens the character screen")
	if town._overlay is CharacterScreen:
		var char_screen: CharacterScreen = town._overlay as CharacterScreen
		var slot_button: Button = char_screen._equipment_slot_buttons[EquipmentData.Slot.HELM] as Button
		_check(not slot_button.disabled, "the character screen shows the newly-unlocked Helm slot as unlocked")
		_shot(town, "final_03_character_screen_unlocked_slot")
		await driver.click_button("Close (Esc)")
		await driver.seconds(0.3)


## Granting/equipping directly (not bought from the vendor) is deliberate test setup, not a
## shortcut around a real feature - Part B/F's item bar and vendor purchase flow are already
## covered by their own tests; this step only needs *an* equipped item to check its tooltip in a
## real battle.
func _equip_a_test_item() -> ItemData:
	var item: ItemData = Session.content.item("healing_draught")
	Session.add_item(item)
	Session.profile.equip_item_id(item)
	Session.save_game()
	return item


## Also deliberate test setup (same spirit as tools/e2e_demo.gd's D58: "forces one battle's XP
## high enough to cross ... a level"): sets the profile's XP right at the edge of the next level so
## the upcoming battle's real reward XP is what actually crosses it, not a bigger jump than a real
## fight could cause.
func _nudge_xp_to_cross_a_level_on_the_next_win() -> void:
	var next_level_xp: int = ProgressionTable.xp_to_reach(Session.profile.level + 1)
	Session.profile.xp = maxi(Session.profile.xp, next_level_xp - CorruptedNpcs.reward_xp())
	Session.save_game()


func _fight_and_win_corrupted_npc(town: TownScene, item: ItemData) -> TownScene:
	var won: bool = false
	var attempts: int = 0
	var current_town: TownScene = town
	while not won and attempts < 6:
		attempts += 1
		await _walk_to(current_town, "npc_beefcake")
		await driver.frames(3)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.3)
		await _dismiss_dialogue_on(current_town.dialogue)
		var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
		_check(battle != null, "the corrupted NPC fight actually starts")
		if battle == null:
			return null
		if attempts == 1:
			_check(battle.item_bar != null, "the equipped item shows in the battle item bar")
			if battle.item_bar != null:
				_check(battle.item_bar._items[0] == item, "the equipped item is the one in the item bar")
				_check(battle.item_bar._slots[0].tooltip_text == item.tooltip_text(), "hovering the equipped item's slot shows its full tooltip (name, effect, targeting)")
				_shot(battle, "final_04_battle_equipped_item_tooltip")
		won = await _play_battle_to_completion(battle)
		await driver.click_button("Continue")
		current_town = await _wait_for(TownScene) as TownScene
		await driver.frames(5)
	_check(won, "eventually won the corrupted NPC challenge (it can always be retried, win or lose)")
	return current_town


func _play_battle_to_completion(battle: BattleScreen) -> bool:
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	battle.board.speed = 10.0
	var steps: int = 0
	var last_progress: int = 0
	while steps < 4000:
		steps += 1
		if battle.mode == BattleScreen.Mode.OVER and battle._result_panel != null:
			break
		if battle.busy or battle.mode == BattleScreen.Mode.WAITING:
			await driver.frames(4)
			continue
		var before: int = battle.game.events.size()
		await pilot.act()
		await driver.frames(3)
		if battle.game.events.size() != before:
			last_progress = steps
		if steps - last_progress > 60:
			break
	_check(battle.mode == BattleScreen.Mode.OVER, "the duel actually finishes (%d steps)" % steps)
	return battle.context.won


## Drives a LevelUpScreen (one popup per level, then any equipment choice / card offer) through to
## completion - reused for the dev shrine and the post-battle popup alike, since it is the exact
## same screen either way (Part A).
func _drive_level_up(town: TownScene) -> void:
	var guard: int = 0
	while town._overlay is LevelUpScreen and guard < 20:
		guard += 1
		var level_up: LevelUpScreen = town._overlay as LevelUpScreen
		if level_up._child_screen is EquipmentSlotChoiceScreen:
			var choice: EquipmentSlotChoiceScreen = level_up._child_screen as EquipmentSlotChoiceScreen
			var tile: Button = choice._tiles.values()[0] as Button
			await driver.click(driver.center_of_control(tile))
			await driver.seconds(0.2)
			await driver.click_button("Choose")
			await driver.seconds(0.5)
			continue
		var skip_button: Button = driver.find_button("Skip", level_up)
		if skip_button != null:
			await driver.click(driver.button_center(skip_button))
			await driver.seconds(0.4)
			continue
		var continue_button: Button = driver.find_button("Continue", level_up)
		if continue_button != null:
			await driver.click(driver.button_center(continue_button))
			await driver.seconds(0.4)
			continue
		await driver.frames(5)
	await driver.frames(3)


# ---- Helpers ------------------------------------------------------------------------------


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _dismiss_dialogue_on(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 20:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


func _walk_to(town: TownScene, spot_id: String) -> void:
	var spot: TownScene.Spot = null
	for candidate: TownScene.Spot in town.spots:
		if candidate.id == spot_id:
			spot = candidate
	if spot == null:
		_fail("no such spot: %s" % spot_id)
		return
	await _walk_to_position(town, spot.position, spot.radius)


## Shared by the starting area (Node3D `player`) and town (also `player`) - both scenes use the
## same TownPlayer class and the same WASD-hold convention.
func _walk_to_position(scene: Node, target: Vector3, radius: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < 9.0:
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
		player.position = target + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _shot(scene: Node, name: String) -> void:
	_shots += 1
	await driver.frames(2)
	DirAccess.make_dir_recursive_absolute("res://_screenshots")
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("res://_screenshots/%s.png" % name))
	print("final_flow_smoke: screenshot -> %s.png" % name)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("final_flow_smoke: ok    ", message)
	else:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("final_flow_smoke: FAIL  ", message)
	push_error("final_flow_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("final_flow_smoke: %s - %s (%d screenshots)" % ["OK" if ok else "FAILED", reason, _shots])
	get_tree().quit(0 if ok else 1)
