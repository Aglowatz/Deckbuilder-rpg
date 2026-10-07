extends GutTest
## Brief 16, Group B: Shiro Swindle and the five giant chests - theft rules, per-chest taunts, the fifth-chest hint, the hidden quest, the duel, the rewards
## and the save round-trip.

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.profile = CampaignStart.new_profile(_content, Affinity.Type.BEEFCAKE)
	Session.deck = CampaignStart.starter_deck(_content, Affinity.Type.BEEFCAKE)
	Session.gold = 200


func test_he_steals_fifty_or_everything() -> void:
	assert_eq(NinjaBoss.steal_amount(500), 50)
	assert_eq(NinjaBoss.steal_amount(50), 50)
	assert_eq(NinjaBoss.steal_amount(37), 37, "less than 50: all of it")
	assert_eq(NinjaBoss.steal_amount(0), 0)


func test_every_chest_has_its_own_taunt_and_only_the_fifth_adds_the_hint() -> void:
	var seen: Dictionary = {}
	for chest_id: String in NinjaBoss.CHEST_IDS:
		var lines: Array[String] = NinjaBoss.taunt_lines(chest_id, false)
		assert_gt(lines.size(), 1, "%s has a taunt" % chest_id)
		var text: String = " ".join(lines)
		assert_false(seen.has(text), "%s: a unique taunt" % chest_id)
		seen[text] = true
		assert_true(text.to_lower().contains("oldest trick"), "%s mocks the player for the oldest trick in the book" % chest_id)
		var fifth: Array[String] = NinjaBoss.taunt_lines(chest_id, true)
		assert_eq(fifth.size(), lines.size() + NinjaBoss.FINAL_HINT.size())
		assert_true(" ".join(fifth).contains("where it all began"))
		assert_false(text.contains("where it all began"), "no hint before the fifth chest")


func test_the_five_chests_are_the_town_and_the_four_zones() -> void:
	assert_eq(NinjaBoss.CHEST_IDS.size(), 5)
	assert_eq(NinjaBoss.CHEST_IDS[0], NinjaBoss.ORIGINAL_CHEST)
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer"]:
		assert_true(NinjaBoss.CHEST_IDS.has(zone_id), zone_id)
		assert_true(ZoneDefs.has_def(zone_id))


func test_opening_a_chest_takes_gold_starts_the_quest_and_counts() -> void:
	assert_false(Session.quest_log.is_active(NinjaBoss.QUEST_ID), "the quest is hidden before the first chest")
	var result: Dictionary = Session.open_giant_chest("beefcake")
	assert_eq(int(result["stolen"]), 50)
	assert_eq(Session.gold, 150)
	assert_eq(int(result["count"]), 1)
	assert_true(bool(result["first"]))
	assert_false(bool(result["is_fifth"]))
	assert_true(Session.quest_log.is_active(NinjaBoss.QUEST_ID), "the quest log gets the entry after the first chest")
	assert_eq(Session.counter(NinjaBoss.COUNTER_STOLEN), 50)
	assert_true(Session.ninja_chest_opened("beefcake"))
	var quest: QuestData = QuestCatalog.find(NinjaBoss.QUEST_ID)
	assert_not_null(quest)
	assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()), Vector2i(1, 5), "1/5 chests")


func test_a_chest_only_opens_once() -> void:
	Session.open_giant_chest("town")
	var again: Dictionary = Session.open_giant_chest("town")
	assert_true(again.is_empty(), "opened chests stay open and never steal twice")
	assert_eq(Session.gold, 150)


func test_with_less_than_fifty_gold_he_takes_all_of_it() -> void:
	Session.gold = 20
	var result: Dictionary = Session.open_giant_chest("gourmand")
	assert_eq(int(result["stolen"]), 20)
	assert_eq(Session.gold, 0)
	Session.gold = 0
	var broke: Dictionary = Session.open_giant_chest("necrocrat")
	assert_eq(int(broke["stolen"]), 0)


func test_the_fifth_chest_is_fifth_in_any_order_and_arms_the_original() -> void:
	var order: Array[String] = ["refusemancer", "beefcake", "town", "gourmand", "necrocrat"]
	for index: int in range(order.size()):
		assert_false(Session.ninja_ready(), "not ready after %d" % index)
		var result: Dictionary = Session.open_giant_chest(order[index])
		assert_eq(bool(result["is_fifth"]), index == order.size() - 1)
	assert_true(Session.ninja_ready(), "all five opened: the original chest closes and glows")
	assert_eq(Session.counter(NinjaBoss.COUNTER_STOLEN), 200, "200 gold: four thefts of 50, then nothing left to take")
	var quest: QuestData = QuestCatalog.find(NinjaBoss.QUEST_ID)
	assert_true(Session.quest_log.objective_met(quest, 0, Session.unlock_state()))
	assert_false(Session.quest_log.is_completed(NinjaBoss.QUEST_ID), "the fight is still ahead")


func test_the_duel_uses_the_town_battleboard_with_a_trap_deck() -> void:
	var context: BattleContext = Session.make_ninja_battle()
	assert_true(context.is_ninja_boss)
	assert_eq(context.board_key, "town")
	assert_eq(context.enemy_name, "Shiro Swindle")
	var deck: Deck = NinjaBoss.deck(_content)
	assert_gte(deck.size(), 44, "a full deck")
	var traps: int = 0
	for card: CardData in deck.cards:
		if card.type == CardEnums.CardType.TRAP:
			traps += 1
	assert_gte(traps, 8, "a trap deck: it is all about tricks")
	for id: Variant in NinjaBoss.DECK_RECIPE.keys():
		assert_not_null(_content.card(str(id)), "card %s exists" % str(id))
	assert_eq(context.game.players[1].hp, NinjaBoss.STARTING_HP)


func test_winning_returns_the_gold_pays_three_gilded_packs_and_ends_the_quest() -> void:
	for chest_id: String in NinjaBoss.CHEST_IDS:
		Session.open_giant_chest(chest_id)
	assert_eq(Session.gold, 0, "200 gold: four thefts of 50, the fifth chest finds an empty purse")
	var stolen: int = Session.counter(NinjaBoss.COUNTER_STOLEN)
	var gold_before: int = Session.gold
	Session.pending_popups.clear()
	var result: Dictionary = Session.apply_ninja_win()
	assert_eq(int(result["gold_returned"]), stolen)
	assert_eq(Session.gold, gold_before + stolen)
	assert_eq((result["packs"] as Array).size(), 3)
	for pack_id: Variant in result["packs"] as Array:
		assert_true(str(pack_id).begins_with("gilded_"), "Gilded Packs")
	assert_true(Session.ninja_defeated())
	assert_true(Session.quest_log.is_completed(NinjaBoss.QUEST_ID), "the questline ends")
	assert_false(Session.ninja_ready(), "the chest stays open for good")
	assert_eq(Session.counter(NinjaBoss.COUNTER_STOLEN), 0)


func test_reward_paths_cover_random_paths() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	var seen: Dictionary = {}
	for i: int in range(40):
		for path: Affinity.Type in NinjaBoss.reward_paths(rng):
			seen[path] = true
			assert_ne(path, Affinity.Type.NEUTRAL)
	assert_gte(seen.size(), 3, "random Paths")


func test_progress_survives_a_save_round_trip() -> void:
	Session.open_giant_chest("town")
	Session.open_giant_chest("dna_placeholder_never_valid")
	Session.open_giant_chest("necrocrat")
	var data: Dictionary = Session.to_dict()
	var json: Dictionary = JSON.parse_string(JSON.stringify(data)) as Dictionary
	Session.new_game()
	assert_true(Session.from_dict(json))
	assert_true(Session.ninja_chest_opened("town"))
	assert_true(Session.ninja_chest_opened("necrocrat"))
	assert_false(Session.ninja_chest_opened("beefcake"))
	assert_eq(Session.ninja_chests_opened(), 2)
	assert_eq(Session.counter(NinjaBoss.COUNTER_STOLEN), 100)
	assert_true(Session.quest_log.is_active(NinjaBoss.QUEST_ID))


func test_the_npc_has_a_placeholder_portrait_until_art_exists() -> void:
	NpcRegistry.reset()
	Portraits.reset()
	var entry: NpcRegistry.Entry = NpcRegistry.find(NinjaBoss.NPC_ID)
	assert_not_null(entry)
	assert_eq(entry.short_name(), "Shiro Swindle")
	assert_eq(NpcRegistry.resolve_speaker("Shiro Swindle"), NinjaBoss.NPC_ID)
	var texture: Texture2D = Portraits.texture_for(NinjaBoss.NPC_ID)
	assert_not_null(texture, "a code-drawn placeholder")
	assert_eq(texture.get_width(), PortraitPlaceholders.WIDTH * PortraitPlaceholders.SCALE)
	assert_false(Portraits.has_portrait(NinjaBoss.NPC_ID), "the art pipeline still reports the real art as missing")
