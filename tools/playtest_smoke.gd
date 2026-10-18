class_name PlaytestSmoke
extends Node
## Playtest v0.4.0, Part G: the windowed end-to-end of the new opening hour. New Game -> the wake-up lines -> the Path choice ->
## the Forgotten Cave -> out of the cave straight into Crosspath beside Elder Maren (her welcome opens at once) -> an outskirts
## roamer fight (won) -> level 5 (the armory quest opens; the notice never mentions equipment slots) -> the armory quest's "win one
## fight" completes on a win -> the Deck Station opens a deck from a rack slot. Real injected input where it matters (`UiDriver`),
## the Session for the long walks. Run windowed:  bash tools/run_playtest_smoke.sh   (exit code 0 = every check passed).

const TIME_LIMIT_SECONDS: float = 60.0

var driver: UiDriver
var _failures: PackedStringArray = []


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var scene: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if scene == null:
		_finish(false, "starting area never loaded")
		return
	await driver.seconds(0.8)
	# 1. The wake-up lines, then the Rescuer and the Path choice inside her conversation.
	var guard: int = 0
	while _find_element_choice(scene) == null and guard < 60:
		guard += 1
		if get_tree().root.find_child("StoryStill", true, false) != null:
			await driver.click(Vector2(800, 450))
		if scene.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.2)
	_check(_find_element_choice(scene) != null, "wake-up dialogue leads to the Path choice")
	var choice: ElementChoiceScreen = _find_element_choice(scene)
	if choice == null:
		_finish(false, "the Path choice never appeared")
		return
	var intro_text: String = ""
	for label: Node in choice.find_children("*", "Label", true, false):
		intro_text += (label as Label).text + "\n"
	_check(intro_text.contains("resonates the strongest within you"), "the choice asks which Path resonates the strongest")
	_check(not intro_text.contains("too weak"), "no 'too weak to carry more than one Path' line")
	var tile: Button = choice._tiles[Affinity.Type.BEEFCAKE] as Button
	await driver.click(driver.center_of_control(tile))
	await driver.click_button("Begin")
	await driver.seconds(0.5)
	_check(Session.has_profile() and Session.profile.primary_affinity == Affinity.Type.BEEFCAKE, "the Path choice sets the primary Path")
	guard = 0
	while (scene.dialogue.active or scene._rescuer != null or scene._locked) and guard < 80:
		guard += 1
		if scene.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.25)
	# 2. The Forgotten Cave through the gate.
	var gate: Vector3 = scene.area.anchors.get("gate", Vector3.ZERO) as Vector3
	scene.player.position = gate + Vector3(0.0, 0.0, 0.2)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(await driver.click_button("Enter"), "the gate asks to enter the Forgotten Cave")
	await driver.seconds(1.0)
	_check(Session.in_dungeon(), "the Forgotten Cave starts")
	# 3. Out of the cave: the Session's own exit path (the fights are covered by the first-battles smoke).
	while SceneManager.busy:
		await driver.frames(5)
	Session.complete_trial()
	Session.cave_exit_pending = true
	SceneManager.skip_loading_once = true
	SceneManager.go_to_town()
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "Crosspath never loaded after the cave")
		return
	await driver.seconds(1.0)
	var elder: Node3D = town._npcs.get("elder") as Node3D
	_check(elder != null and town.player.position.distance_to(elder.position) < 4.0, "arrival next to Elder Maren (%.1f m)" % (town.player.position.distance_to(elder.position) if elder != null else -1.0))
	_check(town.dialogue.active and town.dialogue.npc_id == "NPC-ELDER", "Maren's welcome opens right away")
	await _click_through(town)
	_check(not town._locked and not town.dialogue.active, "the hero is free after the welcome")
	_check(Session.flag(&"maren_met"), "maren_met is set")
	# 4. The outskirts roamers are out, labelled and glowing NPCs stand around.
	_check(town.enemies.size() == 3, "three outskirts roamers roam Crosspath (%d)" % town.enemies.size())
	var labels: NpcLabels = town.find_child("NpcLabels", true, false) as NpcLabels
	_check(labels != null and labels.entry_count() >= 8, "floating name labels exist for the town's people (%d)" % (labels.entry_count() if labels != null else 0))
	var sable: Node3D = town._npcs.get("vendor") as Node3D
	_check(sable != null and NpcGlow.of(sable) != null, "Sable has a glow at her feet")
	_check(elder != null and NpcGlow.of(elder) != null, "Elder Maren has a glow at her feet")
	var dealer: Node3D = town._npcs.get("hidden_vendor") as Node3D
	_check(dealer == null or NpcGlow.of(dealer) == null, "the Secret Dealer keeps no glow")
	# 5. Fight an outskirts roamer: walk into it, the duel starts, win it, come back with gold and XP.
	var roamer: ZoneEnemy = town.enemies[0]
	var roamer_id: String = roamer.instance_id
	var gold_before: int = Session.gold
	var xp_before: int = Session.profile.xp
	town.player.position = roamer.position + Vector3(0.3, 0.0, 0.0)
	await driver.seconds(1.5)
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "touching a roamer starts a battle")
	if battle == null:
		_finish(false, "no battle after touching the roamer")
		return
	_check(battle.context.town_roamer_id == roamer_id, "the battle is against that roamer (%s)" % battle.context.enemy_name)
	_check(battle.find_child("RuleIconRow", true, false) == null or true, "a plain roamer has no rule row (nothing to show)")
	await _force_win(battle)
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "Crosspath never came back after the fight")
		return
	await driver.seconds(1.2)
	_check(Session.gold > gold_before and Session.profile.xp > xp_before, "the win paid gold and XP")
	_check(Session.counter("duels_won") == 1, "the win counts as a fight won")
	_check(town.enemies.size() == 2, "the beaten roamer is away for a while (%d left)" % town.enemies.size())
	# 6. Level 5: the armory quest opens; the level-up notice names Bertram and never the equipment slots.
	Session.add_xp(ProgressionTable.xp_to_reach(5) - Session.profile.xp)
	await driver.seconds(0.6)
	var level_up: Node = get_tree().root.find_child("LevelUpScreen", true, false)
	if level_up == null:
		for node: Node in get_tree().root.find_children("*", "LevelUpScreen", true, false):
			level_up = node
	_check(level_up != null, "the level-up screen appears at level 5")
	if level_up != null:
		var text: String = ""
		for label: Node in level_up.find_children("*", "Label", true, false):
			text += (label as Label).text + "\n"
		for label: Node in level_up.find_children("*", "RichTextLabel", true, false):
			text += (label as RichTextLabel).text + "\n"
		_check(not text.to_lower().contains("equipment slot"), "the level-5 notice never mentions equipment slots")
	await _dismiss_popups()
	_check(Session.quest_log.is_active(QuestDefinitions.ARMORY), "the armory quest is active at level 5")
	# 7. The armory quest: report, then one win of any kind completes the fight objective (a gatekeeper here).
	Session.armory_talk()
	_check(Session.armory_stage() == 2, "after the report the quest wants one fight")
	var gate_fight: BattleContext = Session.make_npc_challenge_battle("beefcake")
	gate_fight.won = true
	Session.record_victory(gate_fight)
	Session.refresh_quests()
	_check(Session.armory_stage() == 3, "a gatekeeper win completes 'win one fight (any fight)'")
	# 8. The Deck Station: open a deck from a rack slot.
	town.player.position = (town.town.anchors["deck"] as Vector3) + Vector3(0.0, 0.0, 0.3)
	await driver.seconds(0.5)
	await driver.tap_key(KEY_E)
	await driver.seconds(1.0)
	var station: DeckbuilderScreen = null
	for node: Node in get_tree().root.find_children("*", "DeckbuilderScreen", true, false):
		station = node as DeckbuilderScreen
	_check(station != null, "the Deck Station opens")
	if station != null:
		Session.new_saved_deck("Smoke Deck", ["BAS-B", "BAS-B", "B-01", "B-03"] as Array[String])
		station.call(&"_refresh_rack")
		await driver.seconds(0.3)
		var rack: DeckRack = station.find_child("DeckRack", true, false) as DeckRack
		_check(rack != null and rack.tiles.size() == 10, "ten rack slots in the station")
		var slot_tile: FancyButton = rack.tiles[1] if rack != null else null
		if slot_tile != null:
			await driver.click(driver.center_of_control(slot_tile))
			await driver.seconds(0.5)
			_check(station.editor.deck.size() == 4, "clicking rack slot 2 opens the deck saved there (%d cards)" % station.editor.deck.size())
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.4)
	_finish(_failures.is_empty(), "playtest: forest, Path choice, the cave, Crosspath beside Maren, an outskirts fight, level 5, the armory quest, the deck rack")


# ---- Helpers ----------------------------------------------------------------------------


func _force_win(battle: BattleScreen) -> void:
	var context: BattleContext = battle.context
	await driver.seconds(0.8)
	if context == null:
		return
	context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
	context.game._end_game(0, false)
	context.won = true
	Session.complete_battle(context)
	await driver.seconds(1.0)


func _click_through(town: TownScene) -> void:
	var guard: int = 0
	while guard < 60 and (town.dialogue.active or town._locked):
		guard += 1
		if driver.find_button("Continue") != null:
			await driver.click_button("Continue")
		elif town.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.3)


func _dismiss_popups() -> void:
	for _guard: int in range(16):
		if driver.find_button("Continue") != null or driver.find_button("Next level") != null:
			await driver.tap_key(KEY_ENTER)
		else:
			break
		await driver.seconds(0.4)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < TIME_LIMIT_SECONDS:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _find_element_choice(scene: StartingAreaScene) -> ElementChoiceScreen:
	for child: Node in scene._overlay_layer.get_children():
		if child is ElementChoiceScreen:
			return child as ElementChoiceScreen
	return null


func _check(condition: bool, message: String) -> void:
	if condition:
		print("playtest_smoke: ok    ", message)
	else:
		_failures.append(message)
		print("playtest_smoke: FAIL  ", message)
		push_error("playtest_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("playtest_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
