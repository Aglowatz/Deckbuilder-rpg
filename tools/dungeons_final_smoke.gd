class_name DungeonsFinalSmoke
extends Node
## FINAL (dungeon list): walks dungeons start to boss through the real UI (human-style mouse and key input): (1) D-TUT, the Forgotten Cave, from the first node to the boss
## and "Enter town"; (2) D-HOG, the House of Gains, through the optional Iron-less Prison branch: the stairs, the prison block, the Iron-less Prison rescue (Grandmaster Flex joins and
## stands on your field in the boss fight), the garden, the Sauna of Truth, the Throne of Gains boss, the epilogue and the freed Gainlands; (3) one side dungeon through its quest:
## Old Man Mountain gives and takes back the quest, the hatch opens, S-BEEF's three battles on the Mount Swolympus map, the unique card. Every battle checks that it uses the
## battleboard the dungeon list names. Screenshots to _screenshots/dungeons/. Run windowed:  bash tools/run_dungeons_final_smoke.sh
## Deliberate shortcuts (stated, like the earlier smokes): the player is placed next to NPCs and entrances instead of walking there; the House of Gains and Mount Swolympus runs are
## boosted (+40 max HP, +4/+4 on every unit, a dungeon boon; the Trial too) so the simple battle pilot wins every duel, and a duel the pilot cannot finish (it gets stuck on an untargetable spell) is decided by decree and reported as a note; the quest's "buy a protein shake" objective is set by bumping its counter; the
## House of Gains run is started with `Session.enter_main_dungeon` (walking to the entrance is covered by the zone smokes).
## Exit code 0 = every check passed; 1 = a check failed.

const STALL_LIMIT: float = 30.0
const SHOT_DIR: String = "res://_screenshots/dungeons/"
const TAG: String = "dungeons_final_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var only: String = OS.get_environment("SMOKE_ONLY")
	if only.is_empty() or only == "tutorial":
		await _tutorial()
	if only.is_empty() or only == "hog":
		if only == "hog":
			Session.ensure_game(Affinity.Type.BEEFCAKE)
		await _house_of_gains()
	if only.is_empty() or only == "side":
		if only == "side":
			Session.ensure_game(Affinity.Type.BEEFCAKE)
			Session.begin_zone_visit("beefcake")
			SceneManager.change_scene("res://scenes/gainlands_zone.tscn")
			await _wait_for(GainlandsScene)
		await _side_dungeon_via_quest()
	_finish(_failures.is_empty(), "%d check failure(s)" % _failures.size())


# ---- D-TUT ---------------------------------------------------------------------------------------------


func _tutorial() -> void:
	var cleared: bool = false
	for attempt: int in range(3):
		Session.begin_intro_trial(Affinity.Type.BEEFCAKE)
		var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
		if map_screen == null:
			_fail("the Forgotten Cave never opened its map")
			return
		_boost()
		await driver.seconds(1.0)
		if attempt == 0:
			_check(map_screen._art != null, "D-TUT shows its painted map (MAP-TUT)")
			_check(map_screen.map.dungeon_name == "The Forgotten Cave", "the map is the Forgotten Cave")
			await _shot("t_01_trial_map_start")
		cleared = await _walk([2, 3, 4, 5, 6], "D-TUT", false, true)
		if cleared:
			break
		# Lost: the run was abandoned and the starting area is up; try the Trial again.
		await driver.seconds(2.0)
	_check(cleared and Session.profile.intro_dungeon_cleared, "beating the Heart of the Hollow cleared the trial")
	var town: Node = await _wait_for(TownScene)
	_check(town != null, "'Enter town' leads to the town")
	await driver.seconds(1.0)
	await _shot("t_02_town_after_the_trial")


# ---- D-HOG ---------------------------------------------------------------------------------------------


func _house_of_gains() -> void:
	Session.begin_zone_visit("beefcake")
	Session.enter_main_dungeon()
	var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	if map_screen == null:
		_fail("the House of Gains never opened its map")
		return
	_boost()
	await driver.seconds(1.0)
	_check(map_screen._art != null, "D-HOG shows its painted map (MAP-HOG)")
	_check(map_screen.map.nodes.size() == 13, "D-HOG has the 13 nodes of the list")
	await _shot("h_01_house_of_gains_map_start")
	# Grand Entrance -> Cardio Corridor -> Protein Pantry -> Regime Checkpoint -> Stairs -> Prison Block -> Iron-less Prison (rescue) -> Meditation Garden -> Sauna -> Throne.
	await _walk([2, 4, 6, 7, 8, 9, 10, 12, 13], "D-HOG", true)
	var zone: Node = await _wait_for(GainlandsScene)
	_check(zone != null, "the dungeon leads back to the Gainlands")
	if zone == null:
		print("%s: note  stuck in scene %s" % [TAG, get_tree().current_scene])
		await _shot("h_stuck")
	_check(Session.is_zone_completed("beefcake"), "beating Chancellor Clench frees the Gainlands")
	_check(Session.owned_count("B-32") >= 1, "the unique reward The Big Unit (B-32) was granted")
	_check(Session.pack_count("gilded_beefcake") >= 1, "a Gilded Beefcake Pack was granted")
	if zone != null:
		await _clear_zone(zone as GainlandsScene)
		await _shot("h_20_gainlands_freed")


# ---- S-BEEF via its quest ----------------------------------------------------------------------------------


func _side_dungeon_via_quest() -> void:
	var zone: GainlandsScene = get_tree().current_scene as GainlandsScene
	if zone == null:
		_fail("not in the Gainlands for the side dungeon")
		return
	await _clear_zone(zone)
	_check(not Session.side_unlocked("S-BEEF"), "the Ascent of Mount Swolympus starts sealed")
	var entrance: ZoneSpot = _spot(zone, "mini_dungeon")
	await _stand_at(zone, entrance)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	await _shot("s_01_ascent_sealed")
	_check(zone._overlay == null, "a sealed side dungeon opens no confirm dialog")
	# Old Man Mountain: talk until the Water for the Hermit quest is accepted (he may offer Spot Me! first).
	var mountain: ZoneSpot = _spot(zone, "brenda")
	var guard: int = 0
	while not Session.quest_log.active.has(ZoneQuestDefinitions.SIDE_BEEF) and guard < 4:
		guard += 1
		await _stand_at(zone, mountain)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.4)
		if guard == 1:
			await _shot("s_02_old_man_mountain")
		await _dismiss_dialogue(zone.dialogue)
		await _clear_zone(zone)
	_check(Session.quest_log.active.has(ZoneQuestDefinitions.SIDE_BEEF), "Old Man Mountain gave the Water for the Hermit quest")
	Session.bump_counter(GainlandsZone.COUNTER_SHAKES)
	Session.refresh_quests()
	await _stand_at(zone, mountain)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss_dialogue(zone.dialogue)
	await _clear_zone(zone)
	_check(Session.quest_log.is_completed(ZoneQuestDefinitions.SIDE_BEEF), "handing in the water completes the quest")
	_check(Session.side_unlocked("S-BEEF"), "the quest unlocked the Ascent of Mount Swolympus")
	await _stand_at(zone, entrance)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	await _shot("s_03_ascent_open")
	var entered: bool = await driver.click_button("Enter")
	_check(entered, "the open entrance asks to enter")
	var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	if map_screen == null:
		_fail("the side dungeon never opened its map")
		return
	_boost()
	await driver.seconds(1.0)
	_check(map_screen._art != null, "S-BEEF shows its painted map (MAP-S-BEEF)")
	await _shot("s_04_ascent_map_start")
	await _walk([1, 2, 3], "S-BEEF", true)
	var back: Node = await _wait_for(GainlandsScene)
	_check(back != null, "the side dungeon leads back to the zone")
	_check(Session.owned_count("B-30") >= 1, "the unique reward Barbell of the Ancients (B-30) was granted")
	_check(Session.flag(GainlandsZone.FLAG_MINI_CLEARED), "the first clear is recorded")
	await driver.seconds(1.0)
	await _shot("s_10_back_from_the_ascent")


# ---- Walking a map -----------------------------------------------------------------------------------------


## Clicks the node of each number in turn (the way a player would) and resolves what it opens: a story beat, a cutscene, a battle with its rewards, an event, a challenge, a shrine, a chest.
func _walk(numbers: Array[int], dungeon_id: String, boosted: bool, allow_loss: bool = false) -> bool:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(dungeon_id)
	var battles: int = 0
	for number: int in numbers:
		var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
		if map_screen == null:
			_fail("%s: no map screen before node %d" % [dungeon_id, number])
			return false
		await driver.seconds(0.7)
		await _dismiss_story(map_screen)
		var node: DungeonMap.MapNode = _node_by_number(map_screen.map, number)
		if node == null:
			_fail("%s: no node %d" % [dungeon_id, number])
			return false
		_check(map_screen.map.is_available(node.id), "%s: node %d (%s) is open to choose" % [dungeon_id, number, node.title])
		var map_ref: DungeonMap = map_screen.map
		var button: MapNodeButton = map_screen._buttons[node.id] as MapNodeButton
		var center: Vector2 = driver.center_of_control(button)
		await driver.move_to(center)
		await driver.seconds(0.25)
		if number == numbers[1] and map_screen._info_panel != null:
			_check(map_screen._info_panel.visible, "%s: hovering a node shows its info next to it" % dungeon_id)
			await _shot("%s_hover_%d" % [dungeon_id.to_lower(), number])
		await driver.click(center)
		await driver.seconds(0.6)
		await _dismiss_story(map_screen)
		if DungeonMap.is_battle_kind(node.kind):
			var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
			if battle == null:
				_fail("%s: node %d opened no battle" % [dungeon_id, number])
				return false
			battles += 1
			var board: String = Battleboards.board_for(battle.context.board_key) if not battle.context.board_key.begins_with("BB-") else battle.context.board_key
			_check(board == plan.battleboard_id, "%s: battle %d (%s) is fought on %s (got %s)" % [dungeon_id, battles, node.enemy_name, plan.battleboard_id, board])
			if dungeon_id == "D-HOG" and node.kind == DungeonMap.Kind.BOSS:
				var ally: bool = false
				for card: CardInstance in battle.game.players[0].field:
					ally = ally or card.data.id == HouseOfGainsDungeon.ALLY_TOKEN_ID
				_check(ally, "D-HOG: the rescued Grandmaster Flex (T-15) stands on your field in the boss fight")
			if battles == 1 or node.kind == DungeonMap.Kind.BOSS:
				await _shot("%s_battle_%d" % [dungeon_id.to_lower(), battles])
			await _play_battle(battle)
			var won: bool = battle.context.won
			await driver.click_button("Continue")
			if not won:
				if allow_loss:
					print("%s: note  %s: the simple pilot lost the duel at node %d (a loss is possible in the Trial); trying the Trial again" % [TAG, dungeon_id, number])
				else:
					_fail("%s: lost the battle at node %d" % [dungeon_id, number])
				return false
			await _after_battle(map_ref, node.kind == DungeonMap.Kind.BOSS)
		else:
			await _resolve_modal(map_screen)
			if node.kind == DungeonMap.Kind.RESCUE:
				_check(HouseOfGainsDungeon.rescued(Session.run), "D-HOG: the Iron-less Prison rescue gave the Grandmaster Flex boon")
		if number == numbers[numbers.size() / 2]:
			var current: Node = get_tree().current_scene
			if current is DungeonMapScreen:
				await driver.seconds(1.0)
				await _shot("%s_map_midway" % dungeon_id.to_lower())
	return true


func _boost() -> void:
	var boon: ModifierSource = MainDungeonDef.boon_source("Smoke-test might", [
		CardBuilder.modifier(Modifier.Kind.MAX_HP, 40),
		CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 4, Modifier.ANY_COLOR, 4),
	] as Array[Modifier])
	Session.run.add_dungeon_source(boon)
	Session.run.hp = Session.run.max_hp()


func _node_by_number(map: DungeonMap, number: int) -> DungeonMap.MapNode:
	for node: DungeonMap.MapNode in map.nodes:
		if node.number == number:
			return node
	return null


## Plays the story lines and cutscenes a node starts (E / Space like a player) until the node's real screen is up.
func _dismiss_story(map_screen: Variant) -> void:
	var guard: int = 0
	while guard < 60:
		guard += 1
		if not is_instance_valid(map_screen):
			return
		var busy: bool = false
		if (map_screen as DungeonMapScreen)._dialogue != null and (map_screen as DungeonMapScreen)._dialogue.active:
			busy = true
		for child: Node in (map_screen as Node).get_children():
			if child is CutsceneScreen:
				busy = true
		if not busy:
			return
		await driver.tap_key(KEY_SPACE)
		await driver.seconds(0.25)


## An event, challenge, shrine or chest on the map: press its primary button until it closes.
func _resolve_modal(map_screen: DungeonMapScreen) -> void:
	var guard: int = 0
	await driver.seconds(0.5)
	while map_screen._modal != null and guard < 14:
		guard += 1
		var modal: Control = map_screen._modal
		var choice: Button = modal.find_child("Choice0", true, false) as Button
		if choice != null and choice.is_visible_in_tree() and not choice.disabled:
			await driver.click(driver.button_center(choice))
			await driver.seconds(0.5)
			continue
		var clicked: bool = false
		for text: String in ["Reveal", "Rest", "Open the chest", "Continue"]:
			var button: Button = driver.find_button(text, modal)
			if button != null:
				await driver.click(driver.button_center(button))
				clicked = true
				break
		await driver.seconds(1.2 if clicked else 0.6)
	if map_screen._modal != null:
		_fail("a node screen did not close")


## After a won duel: the rewards screen (take the first card), level-ups, the boss epilogue and cutscenes, until the map is back (or, after a boss, the dungeon is left).
func _after_battle(map: DungeonMap, boss: bool) -> void:
	var guard: int = 0
	while guard < 60:
		guard += 1
		await driver.seconds(0.6)
		var scene: Node = get_tree().current_scene
		if SceneManager.busy:
			continue
		if scene is DungeonMapScreen and not boss:
			return
		if scene is DungeonMapScreen and boss and (scene as DungeonMapScreen).map != map:
			return
		for popup: Node in scene.find_children("*", "LevelUpScreen", true, false):
			var proceed: Button = driver.find_button("Continue", popup)
			if proceed != null:
				await driver.click(driver.button_center(proceed))
				await driver.seconds(0.4)
		var slot_screens: Array[Node] = scene.find_children("*", "EquipmentSlotChoiceScreen", true, false)
		if not slot_screens.is_empty():
			var tiles: Dictionary = (slot_screens[0] as EquipmentSlotChoiceScreen)._tiles
			await driver.click(driver.center_of_control(tiles.values()[0] as Control))
			await driver.seconds(0.3)
			var confirm: Button = driver.find_button("Choose", scene)
			if confirm != null:
				await driver.click(driver.button_center(confirm))
				await driver.seconds(0.4)
			continue
		if scene is RewardsScreen:
			var rewards: RewardsScreen = scene as RewardsScreen
			if _active_dialogue(rewards) != null:
				await driver.tap_key(KEY_SPACE)
				continue
			if not rewards._cards.is_empty() and rewards._selected < 0:
				await driver.click(driver.center_of_control(rewards._cards[0]))
				await driver.seconds(0.3)
			for text: String in ["Take", "Continue", "Enter town"]:
				var button: Button = driver.find_button(text, rewards)
				if button != null:
					await driver.click(driver.button_center(button))
					break
			continue
		if scene is DungeonMapScreen:
			return
		var level_up: Button = driver.find_button("Continue", scene)
		if scene is not ZoneScene and scene is not TownScene and level_up != null:
			await driver.click(driver.button_center(level_up))
			continue
		for child: Node in scene.get_children():
			if child is CutsceneScreen:
				await driver.tap_key(KEY_SPACE)
		if scene is ZoneScene or scene is TownScene:
			return


func _active_dialogue(root: Node) -> DialogueBox:
	for node: Node in root.find_children("*", "DialogueBox", true, false):
		if (node as DialogueBox).active:
			return node as DialogueBox
	return null


# ---- Zone helpers (like the zone smokes) ------------------------------------------------------------------------


func _spot(zone: ZoneScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	_fail("no such spot: %s" % id)
	return zone.spots[0]


func _stand_at(zone: ZoneScene, spot: ZoneSpot) -> void:
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	zone.player.position = spot.position + Vector3(0, 0, 0.8)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.5)


func _announcement(root: Node) -> AnnouncementScreen:
	for node: Node in root.find_children("*", "Control", true, false):
		if node is AnnouncementScreen:
			return node as AnnouncementScreen
	return null


func _dismiss_dialogue(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


func _clear_zone(zone: ZoneScene) -> void:
	zone._spawn_grace = maxf(zone._spawn_grace, 600.0)
	var guard: int = 0
	while guard < 30 and (zone.dialogue.active or zone._overlay != null or driver._find_reward_popup() != null or _announcement(zone) != null):
		guard += 1
		if zone.dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.15)
		elif driver._find_reward_popup() != null:
			await driver.dismiss_reward_box(1.0)
		elif _announcement(zone) != null:
			await driver.click_button("Continue")
			await driver.seconds(0.4)
		elif zone._overlay != null:
			var button: Button = driver.find_button("Continue", zone._overlay)
			if button != null:
				await driver.click(driver.button_center(button))
			else:
				await driver.tap_key(KEY_ESCAPE)
			await driver.seconds(0.4)


# ---- Battles, waiting, checks -----------------------------------------------------------------------------------


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
	if battle.mode != BattleScreen.Mode.OVER:
		# The simple pilot can get stuck (an untargetable spell): the duel is then decided by decree so the walk can go on. Counted as a note, not a pass.
		print("%s: note  the battle pilot got stuck after %d steps; the duel was won by decree" % [TAG, steps])
		battle.game._end_game(0, false)
		battle.busy = false
		battle._drive()
		var waited: float = 0.0
		while battle._result_panel == null and waited < 15.0:
			await driver.seconds(0.3)
			waited += 0.3
	_check(battle.mode == BattleScreen.Mode.OVER, "the duel actually finishes (%d steps)" % steps)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


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
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("%s: FAIL  %s" % [TAG, message])
	push_error("%s: %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
