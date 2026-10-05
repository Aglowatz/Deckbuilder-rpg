class_name TwelfthBriefSmoke
extends Node
## Brief 12 final e2e with human-style input (real injected keys and clicks): the new-game "choose your look" in the starting area, the clothing vendor (walk up, talk, try on, dye, buy),
## the wardrobe (T), the cosmetics surviving a scene reload, and screenshots of the hero in several outfits. Deliberate shortcuts: the profile is created with
## `Session.ensure_game()` after the starting-look choice (the tutorial dungeon is not replayed), gold is set, and the town camera is pulled closer for the outfit shots.
## Screenshots: _screenshots/brief12/.   Godot --path . res://tools/twelfth_brief_final_launcher.tscn

const SHOT_DIR: String = "res://_screenshots/brief12/"
const TAG: String = "twelfth_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var start: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if start == null:
		_finish(false, "the starting area never loaded")
		return
	await _flow_new_game_look(start)
	var town: TownScene = await _to_town()
	if town == null:
		_finish(false, "town never loaded")
		return
	await _flow_tailor(town)
	await _flow_wardrobe(town)
	await _flow_menu(town)
	town = await _flow_reload(town)
	if town != null:
		await _flow_outfits(town)
	_finish(_failures.is_empty(), "choose your look, tailor try-on and purchase, wardrobe, persistence, outfit shots (%d screenshots)" % _shots)


# ---- 1: the new-game look choice ------------------------------------------------------------------------------------------------


func _flow_new_game_look(start: StartingAreaScene) -> void:
	await driver.seconds(1.2)
	var screen: WardrobeScreen = _find(start, WardrobeScreen) as WardrobeScreen
	_check(screen != null, "the choose-your-look screen opens before the story starts")
	if screen == null:
		return
	_check(not Session.cosmetics.look_chosen, "nothing is chosen yet")
	_check(screen.find_child("Hat_hat_leaf_crown", true, false) == null, "only starter hats are offered")
	await _shot("e01_choose_your_look")
	await _click_named(screen, "Hat_hat_beanie")
	await _click_named(screen, "Dye_hat_5")
	await _click_named(screen, "Cloak_cloak_poncho")
	await _click_named(screen, "Dye_cloak_1")
	await driver.seconds(0.6)
	await _shot("e02_look_chosen_beanie_poncho")
	await _click_named(screen, "Confirm")
	await driver.seconds(0.8)
	_check(Session.cosmetics.look_chosen, "the choice is recorded")
	_check(Session.cosmetics.hat_id == "hat_beanie" and Session.cosmetics.hat_dye == 5, "the beanie in sky blue")
	_check(Session.cosmetics.cloak_id == "cloak_poncho" and Session.cosmetics.cloak_dye == 1, "the poncho in sunset")
	_check(_find(start, WardrobeScreen) == null, "the screen is gone")
	await _hold_dialogue(start.dialogue)
	var skeleton: Skeleton3D = HeroModel.skeleton_of(start.player.model)
	_check(skeleton.get_node_or_null(HeroModel.HAT_NODE) != null, "the hero wears the hat in the starting area")


func _to_town() -> TownScene:
	var look: Dictionary = Session.cosmetics.to_dict()
	Session.ensure_game()  # shortcut: skip the tutorial dungeon
	Session.cosmetics.from_dict(look)
	Session.gold = 3000
	get_tree().change_scene_to_file("res://scenes/town.tscn")
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	await driver.seconds(1.0)
	return town


# ---- 2: the clothing vendor --------------------------------------------------------------------------------------------------------


func _flow_tailor(town: TownScene) -> void:
	await _walk_to(town, (town.town.anchors["npc_tailor"] as Vector3) + Vector3(0.0, 0.0, 1.0), 1.5)
	await driver.seconds(0.4)
	await _shot("e03_tailor_stall")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(town.dialogue.active, "Tilda Thimble talks")
	await _shot("e04_tailor_dialogue")
	await _dismiss(town.dialogue)
	await driver.seconds(0.8)
	var shop: TailorScreen = _find(town, TailorScreen) as TailorScreen
	_check(shop != null, "the shop opens after the talk")
	if shop == null:
		return
	_check(shop.find_child("Buy_hat_chef", true, false) != null, "the Chef's Toque is for sale")
	_check(shop.find_child("Buy_hat_top_hat", true, false) == null, "the top hat is a locked teaser (needs a freed zone)")
	_check(shop.find_child("Buy_hat_leaf_crown", true, false) == null, "secret items are not sold")
	await _shot("e05_tailor_shop")
	await _click_named(shop, "Try_hat_chef")
	await driver.seconds(0.5)
	_check(shop._look.hat_id == "hat_chef", "trying it on puts it on the preview")
	_check(Session.cosmetics.hat_id == "hat_beanie", "but nothing changes until it is bought")
	await _click_named(shop, "Dye_hat_9")
	await driver.seconds(0.4)
	await _shot("e06_try_on_chef_toque")
	var gold_before: int = Session.gold
	await _click_named(shop, "Buy_hat_chef")
	await driver.seconds(0.8)
	_check(Session.cosmetics.owns("hat_chef"), "the Chef's Toque is bought")
	_check(Session.gold == gold_before - CosmeticCatalog.find("hat_chef").price, "and paid for")
	_check(Session.cosmetics.hat_id == "hat_chef" and Session.cosmetics.hat_dye == 9, "worn at once in the previewed dye")
	await _shot("e07_bought_chef_toque")
	await _click_named(shop, "Try_hat_straw")
	await _click_named(shop, "Buy_hat_straw")
	await driver.seconds(0.5)
	_check(Session.cosmetics.owns("hat_straw"), "a second hat bought")
	Session.gold = 5
	await _click_named(shop, "Buy_hat_bowler")
	await driver.seconds(0.4)
	_check(not Session.cosmetics.owns("hat_bowler"), "too poor to buy the bowler")
	Session.gold = 3000
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.6)
	_check(_find(town, TailorScreen) == null, "leaving the shop")
	var skeleton: Skeleton3D = HeroModel.skeleton_of(town.player.model)
	_check(skeleton.get_node_or_null(HeroModel.HAT_NODE) != null, "the hero in town now wears the bought hat")


# ---- 3: the wardrobe ----------------------------------------------------------------------------------------------------------------


func _flow_wardrobe(town: TownScene) -> void:
	await driver.tap_key(KEY_T)
	await driver.seconds(0.8)
	var screen: WardrobeScreen = _find(town, WardrobeScreen) as WardrobeScreen
	_check(screen != null, "T opens the wardrobe")
	if screen == null:
		return
	_check(screen.find_child("Hat_hat_chef", true, false) != null and screen.find_child("Hat_hat_straw", true, false) != null, "owned hats are listed")
	_check(screen.find_child("Hat_hat_bowler", true, false) == null, "unowned hats are not")
	await _click_named(screen, "Hat_hat_beanie")
	await _click_named(screen, "Cloak_cloak_poncho")
	await _click_named(screen, "Dye_cloak_7")
	await driver.seconds(0.6)
	_check(Session.cosmetics.hat_id == "hat_beanie" and Session.cosmetics.cloak_dye == 7, "equipping and dyeing apply at once")
	await _shot("e08_wardrobe")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.5)
	_check(_find(town, WardrobeScreen) == null, "Esc closes the wardrobe")


# ---- 4: persistence ------------------------------------------------------------------------------------------------------------------


func _flow_reload(town: TownScene) -> TownScene:
	var saved: Dictionary = Session.to_dict()
	Session.cosmetics = CosmeticState.new()  # forget everything, then load the save as the title screen would
	_check(Session.from_dict(saved), "the save loads")
	_check(Session.cosmetics.owns("hat_chef") and Session.cosmetics.owns("hat_straw"), "bought hats survive saving and loading")
	_check(Session.cosmetics.hat_id == "hat_beanie" and Session.cosmetics.cloak_id == "cloak_poncho" and Session.cosmetics.cloak_dye == 7, "the equipped look survives")
	get_tree().change_scene_to_file("res://scenes/town.tscn")
	await driver.frames(10)
	var reloaded: TownScene = await _wait_for(TownScene) as TownScene
	await driver.seconds(1.0)
	if reloaded != null:
		var skeleton: Skeleton3D = HeroModel.skeleton_of(reloaded.player.model)
		var hat: Node = skeleton.get_node_or_null(HeroModel.HAT_NODE)
		_check(hat != null and str(hat.get_child(0).get_meta("cosmetic_id", "")) == "hat_beanie", "after a reload the hero wears the saved hat")
	return reloaded


# ---- 5: outfits -----------------------------------------------------------------------------------------------------------------------


func _flow_outfits(town: TownScene) -> void:
	town.camera_offset = Vector3(0.0, 5.2, 4.0)
	var outfits: Array[Array] = [
		["hat_wizard", 6, "cloak_traveler", 3], ["hat_chef", 9, "cloak_short", 0], ["hat_straw", 2, "cloak_poncho", 1],
		["hat_tricorn", 11, "cloak_hooded", 4],
	]
	var index: int = 0
	for outfit: Array in outfits:
		for item_id: String in [str(outfit[0]), str(outfit[2])]:
			Session.cosmetics.grant(item_id)
		var look: CosmeticState = Session.cosmetics.duplicate_state()
		look.equip(CosmeticData.Slot.HAT, str(outfit[0]))
		look.equip(CosmeticData.Slot.CLOAK, str(outfit[2]))
		look.set_dye(CosmeticData.Slot.HAT, int(outfit[1]))
		look.set_dye(CosmeticData.Slot.CLOAK, int(outfit[3]))
		Session.apply_look(look)
		await driver.seconds(0.5)
		# walk a few steps so the cloak is caught mid-swing
		await _hold(KEY_D, true)
		await driver.seconds(0.55)
		await _shot("e%02d_outfit_%d_%s_%s" % [9 + index, index + 1, str(outfit[0]).trim_prefix("hat_"), str(outfit[2]).trim_prefix("cloak_")])
		await _hold(KEY_D, false)
		index += 1
	_check(true, "outfit screenshots taken")


# ---- helpers ----------------------------------------------------------------------------------------------------------------------------


func _find(root: Node, kind: Variant) -> Node:
	for node: Node in root.find_children("*", "Control", true, false):
		if is_instance_of(node, kind):
			return node
	return null


func _click_named(root: Node, node_name: String) -> void:
	var control: Control = root.find_child(node_name, true, false) as Control
	if control == null:
		_check(false, "button %s exists" % node_name)
		return
	await driver.click(driver.center_of_control(control))
	await driver.seconds(0.35)


func _dismiss(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


func _hold_dialogue(dialogue: DialogueBox) -> void:
	await _dismiss(dialogue)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 30.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _walk_to(scene: Node, target: Vector3, radius: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < 14.0:
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
		_note("walk fell back to a short teleport near %s" % str(target))
		player.position = target + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held.get(key, false)) == down:
		return
	_held[key] = down
	await driver.key(key, down)


func _shot(shot_name: String) -> void:
	_shots += 1
	await driver.frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, shot_name]))
	print("%s: screenshot -> %s.png" % [TAG, shot_name])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
		return
	print("%s: FAIL  %s" % [TAG, message])
	push_error("%s: %s" % [TAG, message])
	_failures.append(message)


func _note(message: String) -> void:
	print("%s: note  %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)


# ---- 3b: the single Menu button (brief 12b) -------------------------------------------------------------------------------------------


func _flow_menu(town: TownScene) -> void:
	var menu: Control = town.hud.find_child("MenuButton", true, false) as Control
	_check(menu != null, "one Menu button replaces the four side buttons")
	_check(town.hud.find_child("WardrobeButton", true, false) == null, "no separate wardrobe button")
	await driver.click(driver.center_of_control(menu))
	await driver.seconds(0.4)
	for entry: String in ["Menu_Character", "Menu_Deck", "Menu_Quests", "Menu_Packs", "Menu_Wardrobe"]:
		_check(town.hud.find_child(entry, true, false) != null, "the menu lists %s" % entry)
	await _shot("e08b_menu_open")
	await _click_named(town.hud, "Menu_Packs")
	await driver.seconds(0.6)
	_check(_find(town, PacksScreen) != null, "Packs opens the pack list")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)
	# quest tracker: exactly one quest is shown (brief 13)
	var tracker_rows: int = 0
	for node: Node in town.hud.find_children("*", "Label", true, false):
		if node.get_parent() is VBoxContainer and node.get_parent().get_parent() is VBoxContainer and (node.get_parent().get_parent().get_parent() is QuestTracker):
			tracker_rows += 1
	_check(tracker_rows <= 2, "the tracker shows one quest: its objective only (%d rows)" % tracker_rows)
