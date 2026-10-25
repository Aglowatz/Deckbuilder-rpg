extends GutTest
## Oct 20, Part 1: the Dev Menu (F10). It never exists in a release build, and its actions go through the real systems (levels, gold,
## cards and copy caps, quest steps, dungeon maps, encounters, snapshots).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_a_release_build_never_gets_a_dev_menu() -> void:
	assert_false(DevTools.menu_enabled(false), "release build: no Dev Menu")
	assert_null(DevMenu.install(get_tree(), false), "install adds nothing in a release build")
	assert_true(DevTools.menu_enabled(true), "debug build: the Dev Menu exists")


func test_the_debug_menu_builds_every_tab() -> void:
	var menu: DevMenu = DevMenu.new()
	add_child_autofree(menu)
	await wait_process_frames(2)
	for index: int in range(DevMenu.TABS.size()):
		menu.show_page(index)
		await wait_process_frames(1)
		assert_gt(menu._body.get_child_count(), 0, "tab %s has content" % DevMenu.TABS[index])
	menu.open_menu()
	assert_true(menu.is_open())
	menu.close_menu()
	assert_false(menu.is_open())
	assert_false(get_tree().paused, "closing the menu unpauses the world")


func test_levels_silently_and_for_real() -> void:
	DevActions.set_level(8, true)
	assert_eq(Session.profile.level, 8)
	assert_eq(Session.profile.xp, ProgressionTable.xp_to_reach(8))
	DevActions.set_level(3, true)
	assert_eq(Session.profile.level, 3, "silent can go down")
	var gold_before: int = Session.gold
	DevActions.set_level(6, false)
	assert_eq(Session.profile.level, 6)
	assert_false(Session.pending_level_ups.is_empty(), "real level-ups queue the level-up box")
	assert_gte(Session.gold, gold_before)


func test_gold_packs_items_gear_and_slots() -> void:
	var gold: int = Session.gold
	DevActions.add_gold(1000)
	assert_eq(Session.gold, gold + 1000)
	var pack: PackData = PackCatalog.all()[0]
	var packs: int = Session.pack_count(pack.id)
	DevActions.add_packs(pack.id, 2)
	assert_eq(Session.pack_count(pack.id), packs + 2)
	var piece: EquipmentData = DevActions.equipment_choices()[0]
	DevActions.add_equipment(piece.id)
	assert_true(Session.profile.owned_equipment.has(piece))
	DevActions.unlock_deck_slots()
	assert_eq(Session.deck_capacity(), DeckSlots.SLOT_COUNT)


func test_cards_respect_copy_caps_unless_told_not_to() -> void:
	var card: CardData = DevActions.find_cards("", 400).filter(func(c: CardData) -> bool: return not c.is_unlimited())[0]
	while not Session.at_copy_cap(card):
		DevActions.add_card(card.id, false)
	var owned: int = Session.profile.owned_copies(card.id)
	DevActions.add_card(card.id, false)
	assert_eq(Session.profile.owned_copies(card.id), owned, "at the cap the menu refuses")
	DevActions.add_card(card.id, true)
	assert_eq(Session.profile.owned_copies(card.id), owned + 1, "Ignore caps adds past it")
	assert_false(DevActions.find_cards(card.display_name.substr(0, 4)).is_empty(), "search by name finds it")


func test_quest_steps_can_be_set_forward_and_back() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("beefcake"))
	DevActions.set_quest_step(quest.id, 2)
	var state: UnlockState = Session.unlock_state()
	assert_true(Session.quest_log.is_active(quest.id))
	assert_eq(Session.quest_log.current_index(quest, state), 2, "two steps met")
	assert_true(Session.quest_log.milestone_paid(quest.id, 0), "a step set by hand never pays its step reward")
	DevActions.set_quest_step(quest.id, 0)
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 0, "and back to the first step")


func test_a_quest_set_past_its_last_step_completes_through_the_quest_system() -> void:
	DevActions.set_quest_step(OldWellQuest.QUEST_ID, QuestCatalog.find(OldWellQuest.QUEST_ID).objectives.size())
	assert_true(Session.quest_log.is_completed(OldWellQuest.QUEST_ID))


func test_every_dungeon_has_a_map_and_the_boss_can_be_reached() -> void:
	for id: String in DungeonCatalog.ids():
		var map: DungeonMap = DevActions.preview_map(id)
		assert_not_null(map, "%s builds a map" % id)
		if map == null or map.boss() == null:
			continue
		DevActions.walk_map_to(map, map.boss().id)
		assert_true(map.is_available(map.boss().id), "%s: the walk ends next to the boss" % id)


func test_zone_and_primm_toggles() -> void:
	DevActions.set_gatekeeper("gourmand", true)
	assert_true(Session.flag(CorruptedNpcs.unlock_flag("gourmand")))
	DevActions.set_zone_freed("gourmand", true)
	assert_true(Session.is_zone_completed("gourmand"))
	DevActions.set_zone_freed("gourmand", false)
	assert_false(Session.is_zone_completed("gourmand"))
	DevActions.set_primm_defeated(true)
	assert_true(Session.profile.postgame_unlocked)
	DevActions.set_primm_defeated(false)
	assert_false(Session.profile.postgame_unlocked)


func test_any_encounter_builds_a_battle_with_any_starting_deck() -> void:
	var specs: Array[EncounterSpec] = DevActions.find_encounters("tutorial", 3)
	specs.append_array(DevActions.find_encounters("boss", 2))
	assert_false(specs.is_empty())
	for spec: EncounterSpec in specs:
		for deck: int in [DevActions.DECK_MINE, Affinity.Type.NECROCRAT]:
			var context: BattleContext = DevActions.make_encounter_battle(spec.id, deck)
			assert_not_null(context, spec.id)
			if context != null:
				assert_true(context.dev_battle)
				assert_eq(context.game.players.size(), 2)


func test_snapshots_save_and_list() -> void:
	var line: String = DevActions.save_snapshot("gut test snapshot")
	assert_string_contains(line, "saved")
	assert_true(DevActions.snapshots().has("gut_test_snapshot"))
	var data: Dictionary = SaveSystem.read(DevActions.snapshot_path("gut test snapshot"))
	assert_eq(int((data.get("profile", data) as Dictionary).size() > 0), 1)
	DevActions.delete_snapshot("gut test snapshot")
	assert_false(DevActions.snapshots().has("gut_test_snapshot"))


## Fixes Oct 25, Part 5: the auto-win toggle wins a battle at once through the real result, and never exists in a release build.
func test_auto_win_is_debug_only() -> void:
	DevActions.set_auto_win(true)
	assert_true(DevActions.auto_win_enabled(true), "debug build: on")
	assert_false(DevActions.auto_win_enabled(false), "release build: never on, whatever the toggle says")
	DevActions.set_auto_win(false)
	assert_false(DevActions.auto_win_enabled(true))


func test_auto_win_ends_a_battle_as_a_win() -> void:
	var specs: Array[EncounterSpec] = DevActions.find_encounters("tutorial", 1)
	assert_false(specs.is_empty())
	Session.pending_battle = DevActions.make_encounter_battle(specs[0].id, DevActions.DECK_MINE)
	var game: GameState = Session.pending_battle.game
	DevActions.set_auto_win(true)
	var screen: Node = (load("res://scenes/battle.tscn") as PackedScene).instantiate()
	add_child_autofree(screen)
	await wait_process_frames(4)
	DevActions.set_auto_win(false)
	assert_true(game.is_over(), "the battle ended at once")
	assert_eq(game.winner, 0, "as a win for the hero")
