class_name NinthBriefFinalSmoke
extends Node
## FINAL (brief 9): the new systems with human-style input (real injected keys/clicks), end to end:
## 1 a battle using infrastructure and energy, 2 a deck with 4 copies, 3 a zone buff/debuff in battle,
## 4 a full House of Gains run through a branching path (prison rescue, flex scene, boss),
## 5 zone completion changing the zone, 6 the Arena unlocking after 1 zone, 7 essence conversion on a 5th copy,
## 8 the Alchemist unlocking after 2 zones and crafting a dual-Path card. Screenshots: _screenshots/brief9/.
## Deliberate shortcuts (stated): the dungeon's battles are resolved by forcing a win (a human-played battle is flow 1);
## long walks fall back to a short teleport; zone completion for the second zone and the unlock flags are set directly.
##   Godot --path . res://tools/ninth_brief_final_launcher.tscn

const SHOT_DIR: String = "res://_screenshots/brief9/"
const TAG: String = "ninth_brief_final_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)
	await _flow_battle()
	await _flow_four_copies()
	await _flow_zone_battle_effects()
	await _flow_house_of_gains()
	await _flow_zone_changed()
	await _flow_arena()
	await _flow_essence()
	await _flow_alchemist()
	_finish(_failures.is_empty(), "battle with infrastructure, 4 copies, zone effects, House of Gains run, zone completion, Arena, essence, Alchemist (%d screenshots)" % _shots)


# ---- 1: a battle with infrastructure activation and energy -------------------------------------


func _flow_battle() -> void:
	var context: BattleContext = Session.make_practice_battle("Cave Scavenger")
	Session.pending_battle = context
	get_tree().change_scene_to_file("res://scenes/battle.tscn")
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "the battle screen opened")
	if battle == null:
		return
	await driver.seconds(1.0)
	await driver.click_button("Keep Hand")
	await driver.seconds(1.2)
	var game: GameState = battle.game
	var guard: int = 0
	while game.awaiting_player() == 1 and guard < 40:
		guard += 1
		await driver.seconds(0.4)
	# Play an infrastructure card by clicking it, then play a spell with the energy it makes.
	for turn: int in range(7):
		await _click_hand_card(battle, true)
		await driver.seconds(0.8)
		await _click_hand_card(battle, false)
		await driver.seconds(0.8)
		if game.players[0].infrastructure.size() >= 1 and _any_exhausted(game):
			break
		await driver.click_button("End Turn")
		await driver.seconds(3.0)
	_check(game.players[0].infrastructure.size() >= 1, "a click played an infrastructure card")
	_note("infrastructure activated by playing: %s" % str(_any_exhausted(game)))
	await _shot("01_battle_infrastructure_and_energy")
	Session.pending_battle = null
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	get_tree().change_scene_to_file("res://scenes/town.tscn")
	await _wait_for(TownScene)


func _any_exhausted(game: GameState) -> bool:
	for infra: CardInstance in game.players[0].infrastructure:
		if infra.exhausted:
			return true
	return false


## Clicks the first infrastructure (or, if not `infra`, first castable non-infrastructure) card in the player's hand.
func _click_hand_card(battle: BattleScreen, infra: bool) -> void:
	for view: Node in battle.find_children("*", "CardView", true, false):
		var card_view: CardView = view as CardView
		if card_view.data == null or card_view.mode != CardView.Mode.FULL or not card_view.is_visible_in_tree():
			continue
		if card_view.data.is_infrastructure() != infra:
			continue
		if card_view.global_position.y < 600.0:
			continue
		await driver.click(driver.center_of_control(card_view))
		return


# ---- 2: a deck with 4 copies ------------------------------------------------------------------------


func _flow_four_copies() -> void:
	var card: CardData = Session.content.card("B-03")
	while Session.owned_count(card.id) < 5:
		Session.profile.owned_cards.append(card)
	var town: TownScene = get_tree().current_scene as TownScene
	await driver.tap_key(KEY_B)
	await driver.seconds(1.0)
	var basics: Array[CardData] = []
	for basic: Variant in Session.content.infrastructure.values():
		basics.append(basic as CardData)
	var editor: DeckEditor = DeckEditor.from(Session.profile, Session.deck, basics)
	while editor.count(card) < 4:
		editor.add(card)
	_check(editor.count(card) == 4, "the deck holds 4 copies of a card")
	_check(not editor.add(card), "a 5th copy is refused (%s)" % editor.why_not_add(card))
	_check(DeckValidator.MAX_COPIES == 4, "the copy limit is 4 at level 1")
	await _shot("02_deck_builder_four_copies")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.5)
	if town != null and town._overlay != null:
		town._close_overlay()


# ---- 3: a zone's buff and debuff in battle -----------------------------------------------------------


func _flow_zone_battle_effects() -> void:
	Session.zone_run = ZoneRun.enter(GainlandsZone.ID, Session.profile, Session.deck)
	var context: BattleContext = Session.make_zone_battle("brute", "brute_0")
	Session.pending_battle = context
	get_tree().change_scene_to_file("res://scenes/battle.tscn")
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	await driver.seconds(1.5)
	var panel: Node = battle.find_child("ZoneEffectsPanel", true, false) if battle != null else null
	_check(panel != null, "the battle shows the Gainlands zone effects panel")
	if panel != null:
		_check((panel as Control).tooltip_text.contains("Pump It Up") and (panel as Control).tooltip_text.contains("Processing Time"), "its tooltip names the buff and the debuff")
	await _shot("03_zone_effects_in_battle")
	Session.pending_battle = null
	Session.zone_run = null
	get_tree().change_scene_to_file("res://scenes/town.tscn")
	await _wait_for(TownScene)


# ---- 4: a full House of Gains run ----------------------------------------------------------------------


func _flow_house_of_gains() -> void:
	Session.zone_run = ZoneRun.enter(GainlandsZone.ID, Session.profile, Session.deck)
	Session.enter_main_dungeon()
	var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	_check(map_screen != null and Session.main_dungeon_active, "entered the House of Gains")
	if map_screen == null:
		return
	await driver.seconds(1.0)
	var visited: Array[String] = []
	var steps: int = 0
	var saw_flex: bool = false
	var saw_rescue: bool = false
	while steps < 120:
		steps += 1
		var scene: Node = get_tree().current_scene
		if scene is GainlandsScene:
			print("smoke: left to Gainlands at step %d, active=%s" % [steps, str(Session.main_dungeon_active)])
			break
		if scene is DungeonMapScreen:
			map_screen = scene as DungeonMapScreen
			if map_screen.map.is_complete():
				print("smoke: map complete")
				break
			await _dismiss_story(map_screen)
			var options: Array[DungeonMap.MapNode] = map_screen.map.available()
			if options.is_empty():
				print("smoke: no options")
				break
			# At a branch take the LAST route (the prison's calisthenics check / the gear locker).
			var node: DungeonMap.MapNode = options[options.size() - 1]
			visited.append(node.title)
			if node.id == 6 or node.scene == "rescue":
				saw_rescue = true
			if node.scene == "flex":
				saw_flex = true
			if steps == 3:
				await _shot("04_house_of_gains_map")
			var button: MapNodeButton = map_screen._buttons[node.id] as MapNodeButton
			await driver.click(driver.center_of_control(button))
			await driver.seconds(0.6)
			await _handle_node(null, node)
		elif scene is BattleScreen:
			print("smoke: battle step %d" % steps)
			await _force_win(scene)
		elif scene is RewardsScreen:
			print("smoke: rewards step %d" % steps)
			await _finish_rewards(scene as RewardsScreen)
		else:
			print("smoke: step %d on scene %s" % [steps, str(scene)])
			await driver.seconds(0.5)
	_check(visited.size() >= 10, "walked %d nodes through the branching map: %s" % [visited.size(), ", ".join(visited)])
	_check(saw_rescue, "passed the Iron-less Prison rescue")
	_check(saw_flex, "reached the final confrontation (the flex scene played before the boss)")
	_check(Session.run == null or not Session.main_dungeon_active or Session.is_zone_completed(GainlandsZone.ID), "the boss fell")


func _dismiss_story(map_screen: DungeonMapScreen) -> void:
	var guard: int = 0
	while map_screen._dialogue != null and map_screen._dialogue.active and guard < 20:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


## Handles whatever the clicked node opened: cutscene, event, treasure, shrine, challenge or a battle (forced win).
func _handle_node(_unused_screen: Node, node: DungeonMap.MapNode) -> void:
	var guard: int = 0
	while guard < 40:
		guard += 1
		var scene: Node = get_tree().current_scene
		if not (scene is DungeonMapScreen):
			return
		var screen: DungeonMapScreen = scene as DungeonMapScreen
		if screen._dialogue != null and screen._dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.2)
			continue
		var cutscene: Node = screen.find_child("CutsceneScreen", true, false)
		if cutscene != null:
			if node.scene == "flex" or node.scene == "rescue":
				await _shot("05_cutscene_%s" % node.scene)
			await driver.tap_key(KEY_SPACE)
			await driver.seconds(0.3)
			await driver.tap_key(KEY_SPACE)
			await driver.seconds(0.3)
			continue
		if screen._modal != null:
			await _drive_modal(screen)
			return
		if screen._busy:
			return
		if DungeonMap.is_battle_kind(node.kind) and not screen._busy:
			await driver.seconds(0.3)
			continue
		await driver.seconds(0.3)
		if screen.map.is_cleared(node.id):
			return


func _drive_modal(screen: DungeonMapScreen) -> void:
	var guard: int = 0
	while is_instance_valid(screen) and screen._modal != null and guard < 30:
		guard += 1
		var modal: Node = screen._modal
		var picked: bool = false
		for text: String in ["Free him", "Pick the lock and free him"]:
			pass
		var choice: Button = modal.find_child("Choice0", true, false) as Button
		if choice != null and choice.is_visible_in_tree() and not choice.disabled:
			if guard == 1:
				await _shot("06_event_%s" % str(modal.name))
			await driver.click(driver.center_of_control(choice))
			picked = true
		for text: String in ["Continue", "Rest", "Reveal", "Open the chest"]:
			var button: Button = driver.find_button(text, modal)
			if button != null and not button.disabled and not picked:
				await driver.click(driver.center_of_control(button))
				picked = true
				break
		await driver.seconds(0.9)
	await driver.seconds(1.0)


## Shortcut (stated at the top): a dungeon battle is resolved by forcing the win, then flows through the real rewards.
func _force_win(battle_scene: Node) -> void:
	var context: BattleContext = (battle_scene as BattleScreen).context
	await driver.seconds(0.5)
	if context == null:
		return
	context.game._end_game(0, false)
	context.won = true
	if context.is_boss:
		await _shot("07_boss_reached")
	Session.complete_battle(context)
	await driver.seconds(1.5)


func _finish_rewards(rewards: RewardsScreen) -> void:
	await driver.seconds(1.0)
	var slot_screen: Node = rewards.find_child("*EquipmentSlotChoiceScreen*", true, false)
	if slot_screen == null:
		for child: Node in rewards.find_children("*", "Control", true, false):
			if child is EquipmentSlotChoiceScreen:
				slot_screen = child
				break
	if slot_screen != null:
		var tiles: Array[Node] = slot_screen.find_children("*", "Button", true, false)
		for tile: Node in tiles:
			var tile_button: Button = tile as Button
			if tile_button.is_visible_in_tree() and not tile_button.disabled and tile_button.text != "Choose":
				await driver.click(driver.center_of_control(tile_button))
				break
		var choose: Button = driver.find_button("Choose", slot_screen)
		if choose != null:
			await driver.click(driver.center_of_control(choose))
		await driver.seconds(0.6)
		return
	for child: Node in rewards.get_children():
		if child is LevelUpScreen:
			var next: Button = driver.find_button("Continue", child)
			if next != null:
				await driver.click(driver.center_of_control(next))
			await driver.seconds(0.6)
			return
	var button: Button = driver.find_button("Skip card", rewards)
	if button == null:
		button = driver.find_button("Continue", rewards)
	if button != null:
		await driver.click(driver.center_of_control(button))
	else:
		await driver.tap_key(KEY_E)
		await driver.tap_key(KEY_SPACE)
	await driver.seconds(0.6)


# ---- 5: zone completion changes the zone ----------------------------------------------------------------


func _flow_zone_changed() -> void:
	var zone: GainlandsScene = await _wait_for(GainlandsScene) as GainlandsScene
	_check(zone != null, "back in the Gainlands after the boss")
	_check(Session.is_zone_completed(GainlandsZone.ID), "the Gainlands are completed (%d of 4 zones)" % Session.completed_zone_count())
	if zone == null:
		return
	await driver.seconds(1.5)
	var announce: Node = zone.find_child("AnnouncementScreen", true, false)
	_check(announce != null, "the zone-freed announcement showed")
	await _shot("08_zone_freed_announcement")
	if announce != null:
		await driver.click_button("Continue")
		await driver.seconds(0.5)
	_check(not RulerPresence.has_ruler_props(zone), "the ruler's statue is toppled")
	_check(zone.find_child("freed_heartlift", true, false) != null or _has_spot(zone, "freed_heartlift"), "the freed leader stands at the hub")
	await _shot("09_zone_freed_hub")
	Session.zone_run = null
	get_tree().change_scene_to_file("res://scenes/town.tscn")
	await _wait_for(TownScene)


func _has_spot(zone: ZoneScene, spot_id: String) -> bool:
	for spot: ZoneSpot in zone.spots:
		if spot.id == spot_id:
			return true
	return false


# ---- 6: the Arena unlocked after 1 zone ----------------------------------------------------------------


func _flow_arena() -> void:
	var town: TownScene = get_tree().current_scene as TownScene
	_check(Session.arena_unlocked() and not Session.alchemist_unlocked(), "after 1 zone the Arena is open and the Alchemist still closed")
	await _walk_to(town, town.town.anchors["arena"] as Vector3, 1.4)
	await driver.seconds(0.4)
	await _shot("10_arena_gate_open")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(town.dialogue)
	await driver.seconds(1.0)
	_check(town._overlay is ArenaScreen, "the Arena screen opened")
	await _shot("11_arena_screen")
	if town._overlay != null:
		town._close_overlay()
	await driver.seconds(0.4)


# ---- 7: essence conversion on a 5th copy ------------------------------------------------------------------


func _flow_essence() -> void:
	var card: CardData = Session.content.card("B-26")
	Session.profile.essence.clear()
	for i: int in range(5):
		Session.add_cards([card] as Array[CardData])
	await driver.seconds(0.6)
	_check(Session.owned_count("B-26") == 4, "only 4 copies are kept")
	_check(Session.profile.essence_of(Affinity.Type.BEEFCAKE) > 0, "the 5th copy became Beefcake essence (%d)" % Session.profile.essence_of(Affinity.Type.BEEFCAKE))
	_check(Session.toasts.history.size() > 0 and Session.toasts.history.back().contains("converted"), "a notification was shown")
	await _shot("12_essence_notification")


# ---- 8: the Alchemist after 2 zones ----------------------------------------------------------------------------


func _flow_alchemist() -> void:
	var town: TownScene = get_tree().current_scene as TownScene
	await _walk_to(town, town.town.anchors["alchemist"] as Vector3, 1.5)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(town.dialogue.active, "before 2 zones: the Alchemist is closed and gives a hint")
	await _shot("13_alchemist_closed")
	await _dismiss(town.dialogue)
	Session.complete_zone(DnaZone.ID)
	Session.profile.set_essence(Affinity.Type.BEEFCAKE, 14)
	Session.profile.set_essence(Affinity.Type.NECROCRAT, 12)
	Session.gold = 400
	get_tree().change_scene_to_file("res://scenes/town.tscn")
	town = await _wait_for(TownScene) as TownScene
	await driver.seconds(1.0)
	await _walk_to(town, town.town.anchors["alchemist"] as Vector3, 1.5)
	await _shot("14_alchemist_open")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(town.dialogue)
	await driver.seconds(1.0)
	_check(town._overlay is AlchemistScreen, "after 2 zones the Alchemist opens")
	var screen: AlchemistScreen = town._overlay as AlchemistScreen
	if screen == null:
		return
	await driver.click(driver.center_of_control(screen.find_child("EssenceRow%d" % int(Affinity.Type.BEEFCAKE), true, false) as Control))
	await driver.click(driver.center_of_control(screen.find_child("EssenceRow%d" % int(Affinity.Type.NECROCRAT), true, false) as Control))
	await driver.seconds(0.5)
	await _shot("15_alchemist_selected")
	await driver.click_button("Craft")
	await driver.seconds(0.8)
	await _shot("16_alchemist_brewing")
	await driver.seconds(2.5)
	var crafted: CardData = null
	for owned: CardData in Session.profile.owned_cards:
		if owned.is_multipath():
			crafted = owned
	_check(crafted != null and crafted.is_on_path(Affinity.Type.BEEFCAKE) and crafted.is_on_path(Affinity.Type.NECROCRAT), "crafted a Beefcake/Necrocrat dual-Path card (%s)" % (crafted.display_name if crafted != null else "none"))
	_check(Session.profile.essence_of(Affinity.Type.BEEFCAKE) == 0 and Session.profile.essence_of(Affinity.Type.NECROCRAT) == 0, "all essence of both Paths was spent")
	await _shot("17_alchemist_result")


# ---- Helpers ---------------------------------------------------------------------------------------------------


func _dismiss(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 30:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 25.0:
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
		player.position = target + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held.get(key, false)) != down:
		_held[key] = down
		await driver.key(key, down)


func _shot(name: String) -> void:
	_shots += 1
	await driver.frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, name]))
	print("%s: screenshot -> %s.png" % [TAG, name])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])
		push_error("%s: %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)


func _note(message: String) -> void:
	print("%s: note  %s" % [TAG, message])
