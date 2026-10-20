extends GutTest
## Oct 20, Part 4: the early-game main chain. Out of the cave the only quest is Maren's Meet the Merchants; handing each errand back gives
## the next (Make It Yours, the store room ghosts, the armory); the chain's XP brings a normal new hero to level 5 as the ghost quest is
## handed in; Bertram stays shut until Maren sends the hero; the story's main quests appear only once the armory quest is done; old saves
## past this point keep their quests.

var _cave_xp: int = 0


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.GOURMAND)
	Session.level_track_grants = false
	# Walking out of the Forgotten Cave: its battles' XP and the cleared flag (the real run pays the same, `TrialOfTheHollow`).
	_cave_xp = int(TrialOfTheHollow.total_tutorial_rewards()["xp"])
	Session.add_xp(_cave_xp)
	Session.set_flag(&"trial_cleared")
	Session.offer_auto_quests()


func _story_quests() -> Array[String]:
	var ids: Array[String] = [QuestDefinitions.FREE_ZONES, MemoryDefs.QUEST_ID, ZoneQuestDefinitions.SIDE_TOWN]
	for zone_id: String in Gatekeepers.IDS:
		ids.append(QuestDefinitions.zone_main_id(zone_id))
	return ids


func _any_story_quest_on_offer() -> bool:
	var state: UnlockState = Session.unlock_state()
	for quest_id: String in _story_quests():
		if Session.quest_log.is_active(quest_id) or Session.quest_log.can_start(QuestCatalog.find(quest_id), state):
			return true
	return false


func _hand_in(quest_id: String) -> void:
	assert_true(Session.quest_log.is_ready_to_turn_in(QuestCatalog.find(quest_id), Session.unlock_state()), "%s is ready for Maren" % quest_id)
	assert_true(Session.turn_in_quest(quest_id), "%s handed in" % quest_id)


func _take_from_maren(quest_id: String) -> void:
	assert_true(Session.quests_offered_by(QuestDefinitions.MAREN).has(QuestCatalog.find(quest_id)), "Maren offers %s" % quest_id)
	assert_true(Session.start_quest(quest_id))


func _win_storeroom() -> void:
	var context: BattleContext = Session.make_storeroom_battle()
	context.won = true
	Session.record_victory(context)
	Session.resolve_storeroom_battle(context)


func test_out_of_the_cave_the_only_quest_is_marens() -> void:
	assert_eq(Session.quest_log.active, [QuestDefinitions.MERCHANTS] as Array[String], "only Meet the Merchants")
	assert_false(_any_story_quest_on_offer(), "no zone line, Fragments, Brannoch or the well yet")
	assert_true(Session.quests_offered_by(QuestDefinitions.BRANNOCH).is_empty())
	assert_eq(Session.armory_stage(), 0, "Bertram is shut")


func test_the_whole_chain_in_order_reaches_level_5_and_then_opens_the_story() -> void:
	# 1. Meet the Merchants: the vendors on the square and a card bought.
	Session.set_flag(&"vendor_seen")
	Session.bump_counter("cards_bought")
	Session.set_flag(&"item_vendor_seen")
	Session.set_flag(&"tailor_seen")
	_hand_in(QuestDefinitions.MERCHANTS)
	# 2. Make It Yours.
	_take_from_maren(QuestDefinitions.FIRST_DECK_EDIT)
	assert_false(Session.quests_offered_by(QuestDefinitions.MAREN).has(QuestCatalog.find(QuestDefinitions.GHOSTS)), "one errand at a time")
	Session.save_deck_to_slot(0, Session.deck, "Mine")
	_hand_in(QuestDefinitions.FIRST_DECK_EDIT)
	# 3. The store room ghosts.
	_take_from_maren(QuestDefinitions.GHOSTS)
	assert_lt(Session.profile.level, ProgressionTable.ARMORY_LEVEL, "not level 5 before the ghost quest is handed in")
	_win_storeroom()
	assert_true(Session.flag(StoreroomGhosts.FLAG_CLEARED))
	assert_lt(Session.profile.level, ProgressionTable.ARMORY_LEVEL, "the fight alone does not do it")
	assert_false(_any_story_quest_on_offer(), "still no story quests")
	_hand_in(QuestDefinitions.GHOSTS)
	assert_eq(Session.profile.level, ProgressionTable.ARMORY_LEVEL, "level 5 as Maren takes the ghost quest back (XP %d)" % Session.profile.xp)
	# 4. The armory, from Maren.
	assert_eq(Session.armory_stage(), 0, "Bertram is still shut until the quest starts")
	_take_from_maren(QuestDefinitions.ARMORY)
	assert_eq(Session.armory_talk(), 1, "report to Bertram")
	assert_false(_any_story_quest_on_offer(), "the story waits for the armory quest")
	Session.note_duel_won()
	Session.refresh_quests()
	Session.armory_talk()
	assert_true(Session.quest_log.is_completed(QuestDefinitions.ARMORY))
	assert_true(Session.gear_unlocked())
	# 5. The story's main quests appear at once.
	for zone_id: String in Gatekeepers.IDS:
		assert_true(Session.quest_log.is_active(QuestDefinitions.zone_main_id(zone_id)), "%s's line is active" % zone_id)
	assert_true(Session.quest_log.is_active(MemoryDefs.QUEST_ID))
	assert_true(Session.quests_offered_by(QuestDefinitions.BRANNOCH).has(QuestCatalog.find(QuestDefinitions.FREE_ZONES)), "Brannoch offers the Capital's quest")


func test_the_chain_xp_adds_up_to_level_5_exactly_at_the_ghost_hand_in() -> void:
	var before_hand_in: int = _cave_xp + int(QuestDefinitions.CHAIN_XP[QuestDefinitions.MERCHANTS]) + int(QuestDefinitions.CHAIN_XP[QuestDefinitions.FIRST_DECK_EDIT]) + StoreroomGhosts.XP
	assert_lt(before_hand_in, ProgressionTable.xp_to_reach(5), "level 4 until the hand-in (%d XP)" % before_hand_in)
	assert_gte(before_hand_in + int(QuestDefinitions.CHAIN_XP[QuestDefinitions.GHOSTS]), ProgressionTable.xp_to_reach(5), "level 5 with it")


func test_grinding_to_level_5_early_does_not_start_the_armory() -> void:
	Session.add_xp(ProgressionTable.xp_to_reach(6) - Session.profile.xp)
	assert_false(Session.quest_log.is_active(QuestDefinitions.ARMORY))
	assert_eq(Session.armory_stage(), 0, "Bertram stays shut at level 6")
	assert_false(Session.quests_offered_by(QuestDefinitions.MAREN).has(QuestCatalog.find(QuestDefinitions.ARMORY)), "Maren sends you only after the ghosts")


func test_the_ghost_rule_adds_a_plain_1_1_ghost_token_each_ghost_turn() -> void:
	var rules: Array[EncounterModifiers.Rule] = EncounterModifiers.rules(StoreroomGhosts.RULES_KEY)
	assert_eq(rules.size(), 1)
	assert_eq(rules[0].text, "At the start of each of the ghosts' turns, a 1/1 Ghost token joins them.")
	assert_true(rules[0].is_enemy_side(), "one-sided: the ghosts' rule")
	var context: BattleContext = Session.make_storeroom_battle()
	assert_eq(context.rule_badges.size(), 1, "shown with the encounter-rule icon")
	var ghosts: PlayerState = context.game.players[1]
	var timed: Modifier = null
	for modifier: Modifier in ghosts.modifiers.modifiers:
		if modifier.kind == Modifier.Kind.TIMED_SUMMON:
			timed = modifier
	assert_not_null(timed, "the ghosts summon on their turns")
	if timed != null:
		assert_eq(timed.value, 1, "every turn")
		var token: CardData = timed.tokens[0]
		assert_eq(token.display_name, "Ghost")
		assert_eq([token.attack, token.defense], [1, 1])
		assert_true(token.keywords.is_empty(), "a plain 1/1: no Flying")
	assert_eq(context.game.players[1].hp, StoreroomGhosts.HP)


func test_a_lost_storeroom_fight_changes_nothing() -> void:
	var context: BattleContext = Session.make_storeroom_battle()
	context.won = false
	Session.resolve_storeroom_battle(context)
	assert_false(Session.flag(StoreroomGhosts.FLAG_CLEARED))


func test_old_saves_past_this_point_keep_their_quests() -> void:
	Session.quest_log.reset()
	Session.quest_log.active.assign([QuestDefinitions.MERCHANTS, QuestDefinitions.zone_main_id("beefcake"), MemoryDefs.QUEST_ID])
	var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	(data["quests"] as Dictionary)["version"] = 2
	(data["flags"] as Dictionary).erase(QuestDefinitions.LEGACY_FLAG)
	assert_true(Session.from_dict(data))
	assert_true(Session.flag(StringName(QuestDefinitions.LEGACY_FLAG)), "an old save out of the cave is past the chain")
	assert_true(Session.quest_log.is_active(QuestDefinitions.zone_main_id("beefcake")), "it keeps its zone line")
	assert_true(Session.quest_log.is_active(MemoryDefs.QUEST_ID))
	Session.offer_auto_quests()
	assert_true(Session.quest_log.is_active(QuestDefinitions.zone_main_id("necrocrat")), "and keeps getting the story quests")


func test_an_old_save_still_in_the_cave_gets_the_new_chain() -> void:
	Session.quest_log.reset()
	Session.flags.erase("trial_cleared")
	var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	(data["quests"] as Dictionary)["version"] = 2
	assert_true(Session.from_dict(data))
	assert_false(Session.flag(StringName(QuestDefinitions.LEGACY_FLAG)))
