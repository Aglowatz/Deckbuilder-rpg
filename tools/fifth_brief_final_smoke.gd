class_name FifthBriefFinalSmoke
extends Node
## FINAL (fifth brief): the D.N.A. flow with human-style input, end to end: town quests appear in
## the tracker -> talk to a vendor (quest progress) -> enter the D.N.A. -> get hit by the fast
## courier (life drops) -> touch a slow enemy (real battle, life carries) -> heal at the hub ->
## buy a Necrocrat card -> quiz master -> matching game -> puzzle -> mini dungeon -> open a chest.
## Screenshots every new area/screen to _screenshots/brief5/. Run windowed:
##   Godot --path . res://tools/fifth_brief_final_launcher.tscn
## Deliberate shortcuts (stated, like the earlier smokes): the Necrocrat gate flag is set directly
## (beating Corwyn is covered by the corrupted-NPC smoke); long walks fall back to a short teleport
## when the crude no-pathfinding mover gets stuck behind a wall; the player teleports next to an
## enemy so it notices them quickly.
## Exit code 0 = every check passed; 1 = a check failed.

const STALL_LIMIT: float = 25.0
const SHOT_DIR: String = "res://_screenshots/brief5/"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.D)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)

	await _quests_in_tracker(town)
	await _talk_to_a_vendor(town)
	var zone: DnaScene = await _enter_the_dna(town)
	if zone == null:
		_finish(false, "never reached the D.N.A.")
		return
	await _tour_the_zone(zone)
	await _get_hit_by_the_courier(zone)
	zone = await _touch_a_slow_enemy(zone)
	await _heal_at_the_hub(zone)
	await _buy_a_necrocrat_card(zone)
	await _quiz_master(zone)
	await _matching_game(zone)
	await _puzzle(zone)
	await _open_a_chest(zone)
	zone = await _mini_dungeon(zone)
	await _final_state(zone)
	_finish(_failures.is_empty(), "town quests -> vendor -> D.N.A. -> courier hit -> slow-enemy battle -> heal -> buy card -> quiz -> matching -> puzzle -> chest -> mini dungeon (%d screenshots)" % _shots)


# ---- Steps ------------------------------------------------------------------------------


func _quests_in_tracker(town: TownScene) -> void:
	_check(Session.quest_log.is_active(QuestDefinitions.MERCHANTS), "Meet the Merchants was auto-given on first town entry")
	_check(Session.quest_log.is_active(QuestDefinitions.PATHS), "Clear the Paths was auto-given on first town entry")
	var tracker: QuestTracker = _find_node(town.hud, QuestTracker) as QuestTracker
	_check(tracker != null and tracker.visible, "the quest tracker is on the town HUD")
	var text: String = _all_label_text(tracker)
	_check(text.contains("Meet the Merchants") or text.contains("Clear the Paths"), "the tracker lists the active quests (%s)" % text.replace("\n", " | ").left(80))
	await _shot("e_01_town_quest_tracker")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.4)
	_check(town._overlay is QuestLogScreen, "J opens the Quest Log")
	await _shot("e_02_quest_log")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.3)
	_check(town._overlay == null, "J closes the Quest Log again")


func _talk_to_a_vendor(town: TownScene) -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	var before: int = Session.quest_log.objectives_met_count(quest, Session.unlock_state())
	await _walk_to(town, town.town.anchors["npc_market"] as Vector3, 1.5)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue(town.dialogue)
	await driver.seconds(0.4)
	_check(town._overlay is VendorScreen, "talking to Sable opens the card vendor")
	await driver.click_button("Got it")
	await driver.click_button("Leave")
	await driver.seconds(0.4)
	var after: int = Session.quest_log.objectives_met_count(quest, Session.unlock_state())
	_check(after == before + 1, "talking to the card vendor advanced Meet the Merchants (%d -> %d)" % [before, after])
	await _shot("e_03_town_quest_progress")


func _enter_the_dna(town: TownScene) -> DnaScene:
	Session.set_flag(CorruptedNpcs.unlock_flag(DnaZone.ID))
	var anchor: Vector3 = town.town.anchors["portal_necrocrat"] as Vector3
	await _walk_to(town, anchor, 1.6)
	await driver.frames(4)
	await _shot("e_04_town_necrocrat_gate")
	await driver.tap_key(KEY_E)
	var zone: DnaScene = await _wait_for(DnaScene) as DnaScene
	_check(zone != null, "the Necrocrat gate leads into the D.N.A.")
	if zone != null:
		await driver.seconds(1.0)
		_check(Session.zone_run != null and Session.zone_run.life == Session.zone_run.max_life(), "entering starts at full zone life")
		await _shot("e_05_dna_lobby_arrival")
	return zone


func _tour_the_zone(zone: DnaScene) -> void:
	for place: String in ["breakroom_center", "farm_a_aisle", "farm_b_center", "mail_center", "maze_entrance", "bank_center", "records_center", "exec_center"]:
		zone.player.position = zone.builder.anchor(place)
		zone._camera.position = zone.player.position + DnaScene.CAMERA_OFFSET
		zone._spawn_grace = 30.0
		zone._invulnerable = 30.0
		await driver.seconds(0.9)
		await _shot("e_06_area_%s" % place)
	for leftover: ZoneEnemy in zone.enemies:
		leftover.cooldown = 0.0
	zone._spawn_grace = 0.0
	zone._invulnerable = 0.0
	zone.player.position = zone.builder.anchor("spawn")
	zone._camera.position = zone.player.position + DnaScene.CAMERA_OFFSET


func _find_enemy(zone: DnaScene, type: String) -> ZoneEnemy:
	for enemy: ZoneEnemy in zone.enemies:
		if enemy.info.id == type:
			return enemy
	return null


## A walkable spot 3-4 m from `center` with a clear line of sight to it.
func _spot_near(zone: DnaScene, center: Vector3) -> Vector3:
	for distance: float in [3.0, 3.5, 4.0, 2.5]:
		for angle: int in range(0, 360, 30):
			var candidate: Vector3 = center + Vector3(cos(deg_to_rad(float(angle))), 0.0, sin(deg_to_rad(float(angle)))) * distance
			if zone.builder.is_walkable(candidate) and zone.builder.has_line_of_sight(candidate, center):
				return candidate
	return center


func _get_hit_by_the_courier(zone: DnaScene) -> void:
	var courier: ZoneEnemy = _find_enemy(zone, DnaEnemies.COURIER)
	_check(courier != null, "a Speedy Ghost Courier roams the zone")
	if courier == null:
		return
	var start_life: int = Session.zone_run.life
	courier.cooldown = 0.0
	courier.state = ZoneEnemy.State.PATROL
	var saved_ranges: Dictionary = {}
	for other: ZoneEnemy in zone.enemies:
		if other != courier:
			other.cooldown = 600.0
			other.state = ZoneEnemy.State.PATROL
			saved_ranges[other] = other.info.aggro_range
			other.info.aggro_range = 0.0
	zone.player.position = courier.position + Vector3(3.0, 0.0, 0.0)
	if not zone.builder.is_walkable(zone.player.position):
		zone.player.position = courier.position + Vector3(-3.0, 0.0, 0.0)
	zone._camera.position = zone.player.position + DnaScene.CAMERA_OFFSET
	zone._spawn_grace = 0.0
	zone._invulnerable = 0.0
	await driver.frames(3)
	await _shot("e_07_courier_approaching")
	var waited: float = 0.0
	while Session.zone_run.life >= start_life and waited < 12.0:
		await driver.frames(3)
		waited += 3.0 / 60.0
	_check(Session.zone_run.life == start_life - DnaEnemies.COURIER_DAMAGE, "the courier hit for exactly 2 (life %d -> %d)" % [start_life, Session.zone_run.life])
	_check(zone.life_bar._last_life == Session.zone_run.life, "the HUD life bar shows the new life")
	await driver.frames(4)
	await _shot("e_08_courier_hit_flash_and_life")
	_check(zone._invulnerable > 0.0, "the hit grants a short invulnerability window")
	for other: ZoneEnemy in zone.enemies:
		if other != courier:
			other.cooldown = 0.0
			other.info.aggro_range = float(saved_ranges.get(other, other.info.aggro_range))
	zone._invulnerable = 0.0
	# Leave the courier's reach for the next step.
	zone.player.position = zone.builder.anchor("breakroom_center")
	await driver.seconds(0.5)


func _touch_a_slow_enemy(zone: DnaScene) -> DnaScene:
	var enemy: ZoneEnemy = _find_enemy(zone, DnaEnemies.INTERN)
	_check(enemy != null, "a Zombie Intern roams the zone")
	if enemy == null:
		return zone
	var enemy_id: String = enemy.instance_id
	var life_before: int = Session.zone_run.life
	zone.player.position = _spot_near(zone, enemy.position)
	zone._camera.position = zone.player.position + DnaScene.CAMERA_OFFSET
	zone._spawn_grace = 0.0
	zone._invulnerable = 5.0
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "touching a slow enemy starts a card battle")
	if battle == null:
		return zone
	_check(battle.context.zone_battle, "it is a zone battle")
	_check(battle.game.players[0].life == life_before, "the battle starts at the persisted zone life (%d)" % life_before)
	await _shot("e_09_zone_battle_necrocrat_deck")
	await _play_battle(battle)
	var life_end: int = battle.game.players[0].life
	var won: bool = battle.context.won
	await _shot("e_10_zone_battle_result")
	await driver.click_button("Continue")
	zone = await _wait_for(DnaScene) as DnaScene
	await driver.seconds(1.0)
	if zone != null:
		_check(Session.zone_run != null, "back in the zone after the battle")
		if won:
			_check(Session.zone_run.life == life_end, "life after the battle is what was left, with no free heal (%d)" % life_end)
			_check(not _enemy_exists(zone, enemy_id), "the defeated enemy is gone")
		else:
			_check(Session.zone_run.life == Session.zone_run.max_life(), "a loss wakes you at the hub at full life")
			_check(not Session.zone_log.is_empty(), "the paperwork fee was logged (%s)" % Session.zone_log[Session.zone_log.size() - 1])
		await _clear_popups(zone)
		await _shot("e_11_back_in_zone_after_battle")
	_note("zone battle result this run: %s" % ("won" if won else "lost (woke at hub, fee paid)"))
	return zone


func _enemy_exists(zone: DnaScene, instance_id: String) -> bool:
	for enemy: ZoneEnemy in zone.enemies:
		if enemy.instance_id == instance_id:
			return true
	return false


func _heal_at_the_hub(zone: DnaScene) -> void:
	await _clear_popups(zone)
	# Make sure there is something to heal (a battle won unhurt would leave full life).
	if Session.zone_run.life >= Session.zone_run.max_life():
		Session.zone_run.damage(3)
		EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	var hurt: int = Session.zone_run.life
	zone.player.position = zone.builder.anchor("lobby_center")
	zone._spawn_grace = 5.0
	await _walk_to(zone, zone.builder.anchor("heal"), 1.5)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(hurt < Session.zone_run.max_life() and Session.zone_run.life == Session.zone_run.max_life(), "resting on the Breakroom Couch heals to full (%d -> %d)" % [hurt, Session.zone_run.life])
	await _shot("e_12_hub_heal_couch")


func _buy_a_necrocrat_card(zone: DnaScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "pip")
	await _walk_to(zone, zone.builder.anchor("pip") + Vector3(0, 0, -0.6), spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("e_13_pip_quest_offer_dialogue")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(Session.quest_log.is_active(ZoneQuestDefinitions.AUDIT), "Pip handed out the Compliance Audit quest")
	_check(zone._overlay is VendorScreen, "Pip opens the Requisitions vendor")
	if not (zone._overlay is VendorScreen):
		return
	await driver.click_button("Got it")
	var tile: Control = _find_meta_tile(zone._overlay, "card_id", "cubicle_zombie")
	_check(tile != null, "Cubicle Zombie is for sale")
	var owned_before: int = Session.owned_count("cubicle_zombie")
	if tile != null:
		await driver.click(tile.get_global_rect().position + Vector2(60, 90))
		await driver.seconds(0.3)
		await _shot("e_14_vendor_buy_confirm")
		await driver.click_button("Buy")
		await driver.seconds(0.4)
	_check(Session.owned_count("cubicle_zombie") == owned_before + 1, "buying adds the Necrocrat card to the collection")
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _quiz_master(zone: DnaScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "quiz")
	var gold_before: int = Session.gold
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(zone._overlay is QuizScreen, "the quiz master opens the quiz")
	if not (zone._overlay is QuizScreen):
		return
	var story: ZoneStoryText = ZoneStoryText.shared()
	var shot_done: bool = false
	for question: Dictionary in story.quiz_questions:
		var correct_text: String = str((question["a"] as Array)[int(question["correct"])])
		var button: Button = driver.find_button(correct_text, zone._overlay)
		_check(button != null, "the right answer is on screen: %s" % correct_text)
		if not shot_done:
			shot_done = true
			await _shot("e_15_quiz_question")
		if button != null:
			await driver.click(driver.button_center(button))
			await driver.seconds(0.3)
	await _shot("e_16_quiz_result")
	_check(Session.flag(DnaZone.FLAG_QUIZ_DONE), "finishing the quiz sets the quiz flag")
	_check(Session.gold > gold_before, "a perfect score paid out (%d -> %d gold)" % [gold_before, Session.gold])
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _matching_game(zone: DnaScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "matching")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("e_17_skylar_dialogue")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(zone._overlay is MatchGameScreen, "Skylar launches the matching game")
	if not (zone._overlay is MatchGameScreen):
		return
	var screen: MatchGameScreen = zone._overlay as MatchGameScreen
	var gold_before: int = Session.gold
	await _shot("e_18_matching_start")
	# Human-style clicks on the real card buttons (the smoke knows the layout, a player would
	# remember it): flip a miss first so the board shows a mismatch, then clear every pair.
	var game: MatchGame = screen.game
	var other: int = 1
	while game.cards[other] == game.cards[0]:
		other += 1
	await driver.click(driver.center_of_control(screen._buttons[0]))
	await driver.click(driver.center_of_control(screen._buttons[other]))
	await driver.seconds(0.2)
	await _shot("e_19_matching_mismatch_flipped")
	await driver.seconds(0.9)
	for icon: int in range(MatchGame.PAIRS):
		var a: int = game.cards.find(icon)
		var b: int = game.cards.find(icon, a + 1)
		await driver.click(driver.center_of_control(screen._buttons[a]))
		await driver.click(driver.center_of_control(screen._buttons[b]))
		await driver.seconds(0.4)
		if icon == 3:
			await _shot("e_20_matching_midway")
	await driver.seconds(0.5)
	_check(game.is_won(), "all 8 pairs found within the move limit (%d moves)" % game.moves)
	_check(Session.gold > gold_before and Session.flag(DnaZone.FLAG_MATCH_FIRST), "the win paid out with the one-time first-win bonus")
	await _shot("e_21_matching_result")
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _puzzle(zone: DnaScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "puzzle")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(zone._overlay is TubePuzzleScreen, "the routing terminal opens the puzzle")
	if not (zone._overlay is TubePuzzleScreen):
		return
	var screen: TubePuzzleScreen = zone._overlay as TubePuzzleScreen
	await _shot("e_22_puzzle_start")
	# A wrong attempt first (all junctions left), to show a failed run and the reset button.
	await driver.click_button("Send capsules")
	await driver.seconds(9.0)
	_check(not Session.flag(DnaZone.FLAG_PUZZLE_SOLVED), "the all-left setup does not solve it")
	await _shot("e_23_puzzle_wrong_attempt")
	await driver.click_button("Reset")
	await driver.seconds(0.3)
	for index: int in range(TubePuzzle.JUNCTIONS):
		if TubePuzzle.SOLUTION[index] == 1:
			await driver.click(driver.button_center(screen._buttons[index]))
			await driver.seconds(0.15)
	await _shot("e_24_puzzle_solution_set")
	var piece: EquipmentData = Session.content.equipment_piece("courier_lanyard")
	_check(not Session.profile.owned_equipment.has(piece), "the lanyard is not owned before solving")
	await driver.click_button("Send capsules")
	await driver.seconds(9.0)
	_check(Session.flag(DnaZone.FLAG_PUZZLE_SOLVED), "the right setup solves the puzzle")
	_check(Session.profile.owned_equipment.has(piece), "solving rewards the Soul Courier's Lanyard")
	await _shot("e_25_puzzle_solved")
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _open_a_chest(zone: DnaScene) -> void:
	await _clear_popups(zone)
	var id: String = "chest_exec"
	var pos: Vector3 = zone.builder.layout.chests[id] as Vector3
	var gold_before: int = Session.gold
	zone.player.position = pos + Vector3(2.5, 0, 0.5)
	zone._spawn_grace = 20.0
	zone._invulnerable = 20.0
	await driver.frames(4)
	await _walk_to(zone, pos, DnaScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	await _shot("e_26_chest_prompt_only_no_marker")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.found_secret("dna_%s" % id), "opening the stash marks its secret found")
	_check(Session.gold > gold_before, "the stash paid gold (%d -> %d)" % [gold_before, Session.gold])
	await _shot("e_27_chest_opened")


func _mini_dungeon(zone: DnaScene) -> DnaScene:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "mini_dungeon")
	zone._spawn_grace = 20.0
	zone._invulnerable = 20.0
	zone.player.position = zone.builder.anchor("bank_center")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await _shot("e_28_elevator_bank_mini_dungeon")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _shot("e_29_mini_dungeon_prompt")
	var life_at_entry: int = Session.zone_run.life
	await driver.click_button("Go down")
	var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	_check(map_screen != null, "the mini dungeon opens the node map")
	if map_screen == null:
		return zone
	_check(Session.mini_active and Session.run.life == life_at_entry, "the run starts at the zone's current life (%d)" % life_at_entry)
	await driver.seconds(1.2)
	await _shot("e_30_mini_dungeon_map")
	var battles: int = 0
	var left_dungeon: bool = false
	while battles < MiniDungeon.BATTLE_COUNT:
		map_screen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
		if map_screen == null:
			break
		await driver.seconds(0.6)
		var available: Array[DungeonMap.MapNode] = Session.dungeon_map.available()
		if available.is_empty():
			break
		var button: MapNodeButton = map_screen._buttons[available[0].id] as MapNodeButton
		var life_before: int = Session.run.life
		await driver.click(driver.center_of_control(button))
		var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
		if battle == null:
			break
		battles += 1
		_check(battle.game.players[0].life == life_before, "mini dungeon battle %d starts at the carried life (%d)" % [battles, life_before])
		if battles == 1:
			await _shot("e_31_mini_dungeon_battle_1")
		await _play_battle(battle)
		var won: bool = battle.context.won
		await driver.click_button("Continue")
		if not won:
			left_dungeon = true
			break
		var next: Node = await _wait_scene_either()
		if next is RewardsScreen:
			await driver.seconds(1.2)
			if battles == MiniDungeon.BATTLE_COUNT:
				await _shot("e_32_mini_dungeon_final_reward")
			await driver.click_button("Continue")
			await driver.seconds(0.6)
			if get_tree().current_scene is DnaScene:
				left_dungeon = true
				break
	zone = await _wait_for(DnaScene) as DnaScene
	await driver.seconds(1.0)
	if zone != null:
		await _shot("e_33_back_from_mini_dungeon")
	_check(not Session.mini_active, "the mini dungeon run ended and returned to the zone")
	if Session.flag(DnaZone.FLAG_MINI_DUNGEON_CLEARED):
		_check(Session.owned_count(MiniDungeon.REWARD_CARD_ID) == 1, "clearing it granted the unique Deceased CEO card")
	_note("mini dungeon: %d battle(s) fought, cleared=%s (a loss wakes you at the hub; the clear path is unit-tested)" % [battles, str(Session.flag(DnaZone.FLAG_MINI_DUNGEON_CLEARED))])
	return zone


func _final_state(zone: DnaScene) -> void:
	if zone == null:
		return
	await driver.tap_key(KEY_J)
	await driver.seconds(0.4)
	await _shot("e_34_quest_log_in_zone")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.3)
	_check(not Session.zone_log.is_empty() or Session.counter("paperwork_fees_paid") == 0, "paperwork fee log is consistent")


# ---- Helpers ------------------------------------------------------------------------------


func _play_battle(battle: BattleScreen) -> void:
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	battle.board.speed = 10.0
	var steps: int = 0
	var last_progress: int = 0
	while steps < 6000:
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


func _wait_scene_either() -> Node:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene != null and not SceneManager.busy and (scene is RewardsScreen or scene is DnaScene):
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _spot(zone: DnaScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	_fail("no such spot: %s" % id)
	return zone.spots[0]


func _find_meta_tile(root: Node, meta: String, value: String) -> Control:
	for node: Node in root.find_children("*", "Control", true, false):
		if node.has_meta(meta) and str(node.get_meta(meta)) == value:
			return node as Control
	return null


func _find_node(root: Node, kind: Variant) -> Node:
	for node: Node in root.find_children("*", "", true, false):
		if is_instance_of(node, kind):
			return node
	return null


func _all_label_text(root: Node) -> String:
	var parts: PackedStringArray = []
	for node: Node in root.find_children("*", "Label", true, false):
		parts.append((node as Label).text)
	return "\n".join(parts)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _dismiss_dialogue(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 30:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


## Closes whatever is blocking the world: a dialogue, a level-up popup (earned from quiz/quest XP).
func _clear_popups(zone: DnaScene) -> void:
	zone._spawn_grace = 600.0
	var guard: int = 0
	while guard < 20 and (zone.dialogue.active or zone._overlay is LevelUpScreen):
		guard += 1
		if zone.dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.15)
		else:
			await driver.click_button("Continue")
			await driver.seconds(0.4)


func _walk_to(scene: Node, target: Vector3, radius: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < 10.0:
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


func _shot(name: String) -> void:
	_shots += 1
	await driver.frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, name]))
	print("fifth_brief_final_smoke: screenshot -> %s.png" % name)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("fifth_brief_final_smoke: ok    ", message)
	else:
		_fail(message)


func _note(message: String) -> void:
	print("fifth_brief_final_smoke: note  ", message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("fifth_brief_final_smoke: FAIL  ", message)
	push_error("fifth_brief_final_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("fifth_brief_final_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
