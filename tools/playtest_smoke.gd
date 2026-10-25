class_name PlaytestSmoke
extends Node
## Playtest v0.4.0, Part G / Oct 20, Part 4: the windowed end-to-end of the opening hour. New Game -> the wake-up lines -> the Path choice ->
## the Forgotten Cave -> Crosspath beside Elder Maren (her welcome opens at once; Meet the Merchants is the only quest) -> Sable, a card
## bought, Tilly, Pip -> Maren -> the Deck Station (a rack slot, a deck saved) -> Maren -> the store room ghosts (won) -> Maren: level 5
## and the armory quest -> Bertram, an outskirts roamer won, the gear -> the story's main quests appear. Real injected input where it matters (`UiDriver`),
## the Session for the long walks. Run windowed:  bash tools/run_playtest_smoke.sh   (exit code 0 = every check passed).

const TIME_LIMIT_SECONDS: float = 60.0

var driver: UiDriver
var _failures: PackedStringArray = []
## Fixes Oct 25, Part 9: PLAYTEST_AUTOWIN=1 runs the opening hour with the Dev Menu's auto-win on (every battle won at once through the real result).
var _auto_win: bool = OS.get_environment("PLAYTEST_AUTOWIN") == "1"


func run() -> void:
	_started_msec = Time.get_ticks_msec()
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	if _auto_win:
		DevActions.set_auto_win(true)
		SceneManager.dev_menu._refresh_auto_win_badge()
		_check(DevActions.auto_win_enabled() and SceneManager.dev_menu._auto_win_badge.visible, "auto-win is on, with its AUTO-WIN badge")
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
	_check(intro_text.contains("Pick the Path that feels like you"), "the choice asks for the Path that feels like you (Oct 22 short intro)")
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
	Session.add_xp(int(TrialOfTheHollow.total_tutorial_rewards()["xp"]))  # the cave's three fights pay this on the real walk (skipped here)
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
	# 4. Oct 20: out of the cave the only quest is Maren's Meet the Merchants (no story quests or markers yet).
	_check(Session.quest_log.active.size() == 1 and Session.quest_log.active[0] == QuestDefinitions.MERCHANTS, "the only active quest is Meet the Merchants (%s)" % ", ".join(Session.quest_log.active))
	var labels: NpcLabels = town.find_child("NpcLabels", true, false) as NpcLabels
	_check(labels != null and labels.entry_count() >= 8, "floating name labels exist for the town's people (%d)" % (labels.entry_count() if labels != null else 0))
	var sable: Node3D = town._npcs.get("vendor") as Node3D
	_check(sable != null and NpcGlow.of(sable) != null, "Sable has a glow at her feet")
	_check(elder != null and NpcGlow.of(elder) != null, "Elder Maren has a glow at her feet")
	await _shot("p4_arrival_tracker")
	# 5. Meet the Merchants: Sable (and a card bought from her stock), Tilly, Pip; then back to Maren.
	await _talk(town, "vendor")
	var vendor: VendorScreen = get_tree().root.find_child("*VendorScreen*", true, false) as VendorScreen
	for node: Node in get_tree().root.find_children("*", "VendorScreen", true, false):
		vendor = node as VendorScreen
	_check(vendor != null, "talking to Sable opens her shop")
	if vendor != null:
		var bought: bool = false
		for entry: VendorStockEntry in vendor.stock.entries:
			var card: CardData = Session.card_by_id(entry.card_id)
			if card != null and Session.effective_price(CardPricing.price(card)) <= Session.gold:
				vendor._buy(card)
				bought = true
				break
		_check(bought and Session.counter("cards_bought") >= 1, "a card bought from Sable")
	await _close_overlays(town)
	await _talk(town, "item_vendor")
	await _close_overlays(town)
	await _talk(town, "tailor")
	await _close_overlays(town)
	var merchants: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	_check(Session.quest_log.is_ready_to_turn_in(merchants, Session.unlock_state()), "every merchant met: hand it to Maren")
	await _talk(town, "elder")
	await _dismiss_popups()
	_check(Session.quest_log.is_completed(QuestDefinitions.MERCHANTS), "Maren takes Meet the Merchants back")
	_check(Session.quest_log.is_active(QuestDefinitions.FIRST_DECK_EDIT), "and gives Make It Yours in the same talk")
	# Fixes Oct 25, Parts 6-7: the quest update banner, then the pack step - a pack given, the Menu and its Packs entry glowing, a pack opened.
	await driver.seconds(0.6)
	var notices: QuestNoticeLayer = SceneManager.quest_notices
	_check(notices != null and (not notices.current.is_empty() or notices.queued() > 0), "a quest update banner for Make It Yours")
	# Meet the Merchants' "complete" banner plays first; Make It Yours' "start" follows it.
	for _guard: int in range(40):
		if notices == null or str(notices.current.get("quest", "")) == QuestDefinitions.FIRST_DECK_EDIT:
			break
		await driver.seconds(0.25)
	if notices != null and not notices.current.is_empty():
		_check(str(notices.current["line"]).contains("Open a pack"), "the banner names the new objective (%s)" % str(notices.current["line"]))
		await _shot25("quest_update_popup")
	# The Merchants level-up may already have given a Path pack; Maren gives a General Pack only to a hero with none.
	_check(Session.profile.total_packs() >= 1, "the hero has a pack to open (%d)" % Session.profile.total_packs())
	_check(town.hud.packs_hint_shown(), "the Menu button glows for the pack step")
	town.hud.toggle_menu()
	await driver.seconds(0.5)
	await _shot25("pack_step_marker")
	town.hud.close_menu()
	town._open_packs()
	await driver.seconds(0.8)
	var open_button: Button = get_tree().root.find_child("Open_*", true, false) as Button
	_check(open_button != null, "the Packs screen lists the pack")
	if open_button != null:
		await driver.click(driver.center_of_control(open_button))
		await driver.seconds(1.0)
	for _guard: int in range(10):
		if get_tree().root.find_children("*", "PackOpeningScreen", true, false).is_empty():
			break
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.5)
	await _close_overlays(town)
	_check(Session.flag(StringName(QuestDefinitions.FIRST_PACK_FLAG)) and not town.hud.packs_hint_shown(), "opening the pack completes the step and the glow goes")
	# 6. Make It Yours: the Deck Station, a deck opened from a rack slot, the deck saved to a slot; back to Maren.
	await _deck_station(town)
	Session.save_deck_to_slot(0, Session.deck, "Main")
	_check(Session.flag(&"deck_edited"), "the deck is saved to a slot")
	await _talk(town, "elder")
	await _dismiss_popups()
	_check(Session.quest_log.is_completed(QuestDefinitions.FIRST_DECK_EDIT), "Maren takes Make It Yours back")
	_check(Session.quest_log.is_active(QuestDefinitions.GHOSTS), "and sends the hero to Tilly's store room")
	_check(Session.armory_stage() == 0, "Bertram is still shut")
	# 7. The store room: the ghosts talk, the duel starts at the door (rule icon on the HUD), a win clears it.
	await _talk(town, StoreroomGhosts.SPOT_ID, false)
	await _shot("p4_storeroom_ghosts")
	await _click_through(town)
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null and battle.context.storeroom_battle, "the store room door starts the ghost duel")
	if battle == null:
		_finish(false, "no battle at the store room door")
		return
	await driver.seconds(2.5)
	_check(battle.context.rule_badges.size() == 1 and battle.find_child("RuleIconRow", true, false) != null, "the Haunted Inventory rule shows with its icon")
	await _shot("p4_ghost_battle")
	await _force_win(battle)
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "Crosspath never came back after the ghosts")
		return
	await driver.seconds(1.0)
	_check(town.dialogue.active, "the ghosts say their piece after the fight")
	await _click_through(town)
	await _dismiss_popups()
	_check(Session.flag(StoreroomGhosts.FLAG_CLEARED), "the store room is clear")
	_check(Session.profile.level < ProgressionTable.ARMORY_LEVEL, "not level 5 yet (level %d, %d XP)" % [Session.profile.level, Session.profile.xp])
	# 8. Back to Maren: level 5 with the hand-in, and the armory quest in the same talk.
	await _talk(town, "elder", false)
	await _shot("p4_maren_ghosts_ready")
	await _click_through(town)
	await driver.seconds(0.6)
	var level_up: Node = null
	for node: Node in get_tree().root.find_children("*", "LevelUpScreen", true, false):
		level_up = node
	await _dismiss_popups()
	_check(Session.profile.level == ProgressionTable.ARMORY_LEVEL, "level 5 as Maren takes the ghost quest back (%d XP)" % Session.profile.xp)
	_check(Session.quest_log.is_active(QuestDefinitions.ARMORY), "Maren sends the hero to Bertram")
	_check(not Session.quest_log.is_active(QuestDefinitions.zone_main_id("beefcake")), "the story quests still wait")
	# 9. The armory: report to Bertram, win a fight (an outskirts roamer), collect the gear.
	await _talk(town, "equipment_vendor")
	_check(Session.armory_stage() == 2, "after the report Bertram wants one fight")
	# Fixes Oct 25, Part 4: he points at the outskirts, and the step's marker does too
	_check(" ".join(StoryText.shared().get_lines("quest.armory.start")).contains("edges of town"), "Bertram says enemies roam the edges of town")
	Session.quest_log.track(QuestDefinitions.ARMORY)
	var target: Dictionary = QuestMarkers.objective_target("town", Session.quest_log, Session.unlock_state())
	_check(str(target.get("spot", "")) == QuestDefinitions.OUTSKIRTS_SPOT and not town._outskirts_spot().is_empty(), "the 'win one fight' marker points at the outskirts")
	var roamer: ZoneEnemy = town.enemies[0]
	town.player.position = roamer.position + Vector3(0.3, 0.0, 0.0)
	await driver.seconds(1.5)
	var roamer_battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(roamer_battle != null and not roamer_battle.context.town_roamer_id.is_empty(), "touching an outskirts roamer starts a duel")
	if roamer_battle == null:
		_finish(false, "no roamer battle")
		return
	await _force_win(roamer_battle)
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "Crosspath never came back after the roamer")
		return
	await driver.seconds(1.0)
	await _dismiss_popups()
	_check(Session.armory_stage() == 3, "a won fight completes 'win one fight (any fight)'")
	await _talk(town, "equipment_vendor")
	await _close_overlays(town)
	await _dismiss_popups()
	_check(Session.quest_log.is_completed(QuestDefinitions.ARMORY) and Session.gear_unlocked(), "the Starter Blade and every equipment slot")
	# 10. Only now: the story's main quests.
	for zone_id: String in Gatekeepers.IDS:
		_check(Session.quest_log.is_active(QuestDefinitions.zone_main_id(zone_id)), "%s's main line appears after the armory quest" % zone_id)
	_check(not Session.quests_offered_by(QuestDefinitions.BRANNOCH).is_empty(), "Brannoch now offers the Capital's quest")
	# Fixes Oct 25, Part 8: the hero's own Path zone first - its gatekeeper quest is tracked, and Maren explains why
	var own: String = PathDirection.own_main_quest(Session.profile.primary_affinity)
	_check(Session.quest_log.tracked_id() == own, "the own Path's gatekeeper quest is tracked (%s)" % Session.quest_log.tracked_id())
	_check(PathDirection.due(Session.quest_log, Session.flags, Session.profile.primary_affinity), "Maren has the Path talk ready")
	await _talk(town, "elder", false)
	await driver.seconds(0.4)
	await _shot25("maren_path_direction")
	await _click_through(town)
	_check(Session.flag(StringName(PathDirection.FLAG)) and Session.quest_log.tracked_id() == own, "Maren sends the hero to their own Path's zone")
	await driver.seconds(0.8)
	await _shot("p4_story_quests")
	_finish(_failures.is_empty(), "playtest: forest, Path choice, the cave, Maren, the merchants and a card, the Deck Station, the store room ghosts, level 5, Bertram's quest, then the story quests")


# ---- Helpers ----------------------------------------------------------------------------


## Walks up to a town spot and presses E; `through` clicks through the dialogue that follows.
func _talk(town: TownScene, spot_id: String, through: bool = true) -> void:
	for spot: Variant in town.spots:
		if str(spot.id) == spot_id:
			town.player.position = (spot.position as Vector3) + Vector3(0.0, 0.0, 0.3)
	await driver.seconds(0.5)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	if through:
		await _click_through(town)


func _close_overlays(town: TownScene) -> void:
	for _guard: int in range(8):
		if town._overlay == null:
			break
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.4)


## The Deck Station opens and a deck saved in a rack slot opens from it.
func _deck_station(town: TownScene) -> void:
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
	await _close_overlays(town)


func _shot(shot_name: String) -> void:
	await driver.frames(3)
	var path: String = ProjectSettings.globalize_path("res://_screenshots/oct20d/%s.png" % shot_name)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	get_viewport().get_texture().get_image().save_png(path)
	print("playtest_smoke: screenshot -> %s.png" % shot_name)


## Fixes Oct 25: the screenshots of this brief.
func _shot25(shot_name: String) -> void:
	await driver.frames(3)
	var path: String = ProjectSettings.globalize_path("res://_screenshots/oct25/%s.png" % shot_name)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	get_viewport().get_texture().get_image().save_png(path)
	print("playtest_smoke: screenshot -> oct25/%s.png" % shot_name)


func _force_win(battle: BattleScreen) -> void:
	if _auto_win:
		await _auto_won(battle)
		return
	var context: BattleContext = battle.context
	await driver.seconds(0.8)
	if context == null:
		return
	context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
	context.game._end_game(0, false)
	context.won = true
	Session.complete_battle(context)
	await driver.seconds(1.0)


## Auto-win: the battle ends by itself as a win; the real result panel's Continue takes the hero back.
func _auto_won(battle: BattleScreen) -> void:
	for _guard: int in range(40):
		if battle.game.is_over() and driver.find_button("Continue") != null:
			break
		await driver.seconds(0.25)
	_check(battle.game.is_over() and battle.game.winner == 0, "auto-win: %s won at once" % battle.context.enemy_name)
	await driver.click_button("Continue")
	await driver.seconds(1.0)


func _click_through(town: TownScene) -> void:
	var guard: int = 0
	while guard < 60 and is_instance_valid(town) and town.is_inside_tree() and (town.dialogue.active or town._locked):
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


## Overnight Oct 18, Phase 2 cycle 31: every line carries the seconds since the smoke started, so the opening hour's pace can be read (a bot's
## pace - it never waits to read - so read it as the minimum, not a player's time).
var _started_msec: int = -1


func _elapsed() -> String:
	if _started_msec < 0:
		_started_msec = Time.get_ticks_msec()
	return "%5.1fs" % (float(Time.get_ticks_msec() - _started_msec) / 1000.0)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("playtest_smoke: ok    [%s] %s" % [_elapsed(), message])
	else:
		_failures.append(message)
		print("playtest_smoke: FAIL  ", message)
		push_error("playtest_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("playtest_smoke: %s - %s (%s)" % ["OK" if ok else "FAILED", reason, _elapsed()])
	get_tree().quit(0 if ok else 1)
