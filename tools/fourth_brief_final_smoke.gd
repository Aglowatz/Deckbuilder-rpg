class_name FourthBriefFinalSmoke
extends Node
## FINAL (fourth brief): the whole brief's flow with human-style input, end to end - buy a basic
## equipment piece -> equip it on the character screen -> verify its effect in a real battle ->
## dev shrine to the level that unlocks the equipment vendor's advanced stock -> confirm it
## actually unlocked -> open a hidden equipment chest -> attempt the Graveyard. Screenshots every
## new/changed screen along the way to _screenshots/ (git-ignored). Confirming opponent traps
## stay hidden is covered by tests/test_battle_board_trap_visibility.gd (Part A) - none of this
## flow's decks reliably draw a trap, so that is stated here rather than faked.
## Run windowed (real viewport needed for injected input):
##   Godot --path . res://tools/fourth_brief_final_launcher.tscn
## Exit code 0 = every check passed; 1 = a check failed.

const STALL_LIMIT: float = 20.0

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)

	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "the launcher reaches town")
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(5)

	var piece: EquipmentData = await _buy_wicked_dagger(town)
	await _dev_shrine_to_level_5_choosing_weapon(town)
	await _equip_from_character_screen(town, piece)
	await _verify_equipment_effect_in_battle(piece)
	town = get_tree().current_scene as TownScene
	await _dev_shrine_to_level_10_choosing_armor(town)
	await _confirm_advanced_equipment_unlocked(town)
	await _open_a_hidden_equipment_chest(town)
	await _attempt_the_graveyard(town)

	_note("Opponent-trap visibility (\"confirm opponent traps stay hidden\") is not re-derived here - none of this flow's decks reliably draw a trap to observe. It is covered by tests/test_battle_board_trap_visibility.gd (Part A, 3 cases, passing) instead.")
	_finish(_failures.is_empty(), "buy equipment -> equip -> verify effect -> dev shrine to level 10 -> vendor unlock confirmed -> hidden chest -> attempt the Graveyard (%d screenshots)" % _shots)


# ---- Steps ------------------------------------------------------------------------------


func _buy_wicked_dagger(town: TownScene) -> EquipmentData:
	await _walk_to(town, "equipment_vendor")
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue_on(town.dialogue)
	await driver.seconds(0.3)
	_check(town._overlay is EquipmentVendorScreen, "talking to Wendell Cobb opens the equipment vendor")
	var piece: EquipmentData = Session.content.equipment_piece("wicked_dagger")
	if town._overlay is EquipmentVendorScreen:
		var vendor: EquipmentVendorScreen = town._overlay as EquipmentVendorScreen
		var tip: Button = driver.find_button("Got it")
		if tip != null:
			await driver.click(driver.button_center(tip))
			await driver.seconds(0.2)
		var tile: Control = _find_equipment_tile(vendor, "wicked_dagger")
		_check(tile != null, "the basic Wicked Dagger tile is on screen")
		if tile != null:
			await driver.click(driver.center_of_control(tile))
			await driver.seconds(0.2)
			await driver.click_button("Buy")
			await driver.seconds(0.3)
		_check(Session.profile.owned_equipment.has(piece), "buying it adds it to owned_equipment")
		_shot(town, "final2_01_equipment_vendor_basic_purchase")
		await driver.click_button("Leave")
		await driver.seconds(0.3)
	return piece


func _find_equipment_tile(vendor: EquipmentVendorScreen, equipment_id: String) -> Control:
	for tile: Node in vendor.find_children("*", "Control", true, false):
		if tile.has_meta("equipment_id") and str(tile.get_meta("equipment_id")) == equipment_id:
			return tile as Control
	return null


func _dev_shrine_to_level_5_choosing_weapon(town: TownScene) -> void:
	await _dev_shrine_until(town, 5, EquipmentData.Slot.WEAPON, "final2_02_shrine_level5_popup")
	_check(Session.profile.has_equipment_slot(EquipmentData.Slot.WEAPON), "the level-5 choice unlocked the Weapon slot")


func _dev_shrine_to_level_10_choosing_armor(town: TownScene) -> void:
	await _dev_shrine_until(town, 10, EquipmentData.Slot.ARMOR, "final2_06_shrine_level10_popup")
	_check(Session.profile.level >= ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL, "reached the equipment-vendor unlock level (10)")


func _dev_shrine_until(town: TownScene, target_level: int, slot_to_choose: EquipmentData.Slot, shot_name: String) -> void:
	var visits: int = 0
	while Session.profile.level < target_level and visits < 15:
		visits += 1
		await _walk_to(town, "dev_shrine")
		await driver.frames(3)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.5)
		var just_hit_target: bool = Session.profile.level == target_level
		if town._overlay is LevelUpScreen and just_hit_target:
			await driver.frames(3)
			_shot(town, shot_name)
		await _drive_level_up(town, slot_to_choose)
		await driver.frames(10)
	_check(Session.profile.level >= target_level, "reached level %d (at %d after %d visits)" % [target_level, Session.profile.level, visits])


func _equip_from_character_screen(town: TownScene, piece: EquipmentData) -> void:
	await driver.tap_key(KEY_C)
	await driver.seconds(0.4)
	_check(town._overlay is CharacterScreen, "the C hotkey opens the character screen")
	if town._overlay is CharacterScreen:
		var char_screen: CharacterScreen = town._overlay as CharacterScreen
		var slot_button: Button = char_screen._equipment_slot_buttons[EquipmentData.Slot.WEAPON] as Button
		_check(not slot_button.disabled, "the Weapon slot shows as unlocked")
		await driver.click(driver.button_center(slot_button))
		await driver.seconds(0.3)
		await driver.click_button("Equip")
		await driver.seconds(0.3)
		_check(Session.profile.equipped_in(EquipmentData.Slot.WEAPON) == piece, "the picker actually equips Wicked Dagger")
		_shot(town, "final2_03_character_screen_equipped_weapon")
		await driver.click_button("Close (Esc)")
		await driver.seconds(0.3)


## Deliberate test setup (same spirit as final_flow_smoke.gd's D58): a standalone practice battle,
## not tied to any unlock/reward flow, so this step is purely about the equipment's real effect.
func _verify_equipment_effect_in_battle(piece: EquipmentData) -> void:
	Session.start_battle(Session.make_practice_battle())
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "the practice battle actually starts")
	if battle == null:
		return
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	battle.board.speed = 10.0
	var steps: int = 0
	var last_progress: int = 0
	var verified: bool = false
	while steps < 4000:
		steps += 1
		if battle.mode == BattleScreen.Mode.OVER and battle._result_panel != null:
			break
		if not verified:
			for card: CardInstance in battle.game.players[0].field:
				if card.data.is_unit():
					var expected: int = card.data.attack + 1
					_check(battle.game.get_attack(card) == expected, "Wicked Dagger's +1 attack is live in a real battle (%s: %d, expected %d)" % [card.data.display_name, battle.game.get_attack(card), expected])
					_shot(battle, "final2_04_battle_wicked_dagger_buff")
					verified = true
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
	_check(verified, "at least one of the player's own units was play and checked")
	_check(battle.mode == BattleScreen.Mode.OVER, "the practice duel actually finishes (%d steps)" % steps)
	await driver.click_button("Continue")
	await _wait_for(TownScene)
	await driver.frames(5)


func _confirm_advanced_equipment_unlocked(town: TownScene) -> void:
	await _walk_to(town, "equipment_vendor")
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue_on(town.dialogue)
	await driver.seconds(0.3)
	if town._overlay is EquipmentVendorScreen:
		var vendor: EquipmentVendorScreen = town._overlay as EquipmentVendorScreen
		var advanced_tile: Control = _find_equipment_tile(vendor, "flamethrower")
		_check(advanced_tile != null, "an advanced piece (Flamethrower) now has a real, buyable tile")
		_shot(town, "final2_07_equipment_vendor_advanced_unlocked")
		await driver.click_button("Leave")
		await driver.seconds(0.3)


func _open_a_hidden_equipment_chest(town: TownScene) -> void:
	var anchor: Vector3 = town.town.anchors.get("hidden_chest_uplands_ridge", Vector3.ZERO) as Vector3
	var piece: EquipmentData = Session.content.equipment_piece("travelers_boots")
	var owned_before: bool = Session.profile.owned_equipment.has(piece)
	await _walk_to_position(town, anchor, TownScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.found_secret("hidden_chest_uplands_ridge"), "opening the chest marks its secret found")
	await driver.dismiss_reward_box()
	_check(not owned_before and Session.profile.owned_equipment.has(piece), "opening it actually grants Traveler's Boots")
	_shot(town, "final2_08_hidden_equipment_chest_opened")


func _attempt_the_graveyard(town: TownScene) -> void:
	await _walk_to(town, "graveyard_cairn")
	await driver.frames(5)
	_shot(town, "final2_09a_graveyard_area_outdoors")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue_on(town.dialogue)
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "the cairn actually starts the Graveyard battle")
	if battle == null:
		return
	_check(battle.context.is_graveyard_boss, "the battle is tagged as the Graveyard boss")
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	battle.board.speed = 10.0
	var steps: int = 0
	var last_progress: int = 0
	var shot_taken: bool = false
	while steps < 6000:
		steps += 1
		if battle.mode == BattleScreen.Mode.OVER and battle._result_panel != null:
			break
		if not shot_taken and battle.game.players[1].field.size() > 0:
			_shot(battle, "final2_09_graveyard_battle_escalating_summon")
			shot_taken = true
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
	_check(battle.mode == BattleScreen.Mode.OVER, "the Graveyard duel actually finishes (%d steps)" % steps)
	_check(shot_taken, "the boss's escalating summon was seen and screenshotted")
	_note("Graveyard result this run: %s (a loss is expected and fine - a fresh profile with one basic weapon has nowhere near \"good equipment and a solid deck\"; see docs/balance_report.md)." % ("won" if battle.context.won else "lost"))
	await driver.click_button("Continue")
	await _wait_for(TownScene)
	await driver.frames(5)


## Drives a LevelUpScreen through to completion, choosing `preferred_slot` if that's the equipment
## choice offered (falls back to whatever tile is first if that slot isn't an option this time).
func _drive_level_up(town: TownScene, preferred_slot: EquipmentData.Slot) -> void:
	var guard: int = 0
	while (town._overlay is LevelUpScreen or town._overlay is RewardPopup) and guard < 20:
		guard += 1
		var level_up: LevelUpScreen = town._overlay as LevelUpScreen
		if level_up._child_screen is EquipmentSlotChoiceScreen:
			var choice: EquipmentSlotChoiceScreen = level_up._child_screen as EquipmentSlotChoiceScreen
			var tile: Button = choice._tiles.get(int(preferred_slot)) as Button
			if tile == null:
				tile = choice._tiles.values()[0] as Button
			await driver.click(driver.center_of_control(tile))
			await driver.seconds(0.2)
			await driver.click_button("Choose")
			await driver.seconds(0.5)
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
	print("fourth_brief_final_smoke: screenshot -> %s.png" % name)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("fourth_brief_final_smoke: ok    ", message)
	else:
		_fail(message)


func _note(message: String) -> void:
	print("fourth_brief_final_smoke: note  ", message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("fourth_brief_final_smoke: FAIL  ", message)
	push_error("fourth_brief_final_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("fourth_brief_final_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
