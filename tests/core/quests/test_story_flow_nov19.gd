extends GutTest
## Overnight Nov 19 (Parts 2 and 3): the main quest after each zone and Auntie Alembic's opening, intro quest, essence and brewing rules.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _objective_texts(quest: QuestData) -> Array[String]:
	var texts: Array[String] = []
	for objective: QuestObjective in quest.objectives:
		texts.append(objective.text)
	return texts


# ---- Part 2.2: the Fragments steps -------------------------------------------------------------------------------------------


func test_fragments_have_a_free_step_and_a_talk_step_per_memory() -> void:
	var quest: QuestData = QuestCatalog.find(MemoryDefs.QUEST_ID)
	assert_eq(quest.objectives.size(), MemoryDefs.COUNT * 2)
	var texts: Array[String] = _objective_texts(quest)
	assert_eq(texts[0], "A first memory: free a zone")
	assert_eq(texts[1], "A first memory: talk to Elder Maren")


func test_freeing_a_zone_ticks_its_step_at_once_and_maren_is_next() -> void:
	var quest: QuestData = QuestCatalog.find(MemoryDefs.QUEST_ID)
	var state: UnlockState = Session.unlock_state()
	assert_false(Condition.met(quest.objectives[0].condition, state))
	Session.complete_zone("gourmand")
	state = Session.unlock_state()
	assert_true(Condition.met(quest.objectives[0].condition, state), "Free a zone is ticked as soon as the zone is freed")
	assert_false(Condition.met(quest.objectives[1].condition, state), "Talk to Elder Maren is the open step")
	assert_eq(Session.pending_memory(), 1, "Maren's scene waits")
	Session.recover_memory(1)
	assert_true(Condition.met(quest.objectives[1].condition, Session.unlock_state()))


# ---- Part 3.1-3.2: Alembic opens with the first zone; her intro quest is MAIN ------------------------------------------------


func test_alembic_opens_after_the_first_freed_zone() -> void:
	assert_false(Session.alchemist_unlocked())
	Session.complete_zone("beefcake")
	assert_true(Session.alchemist_unlocked(), "one zone is enough")
	assert_true(Session.vendor_is_new("alchemist"), "her shop is marked NEW on the map")


func test_the_locked_note_never_says_free_a_zone() -> void:
	var text: String = " ".join(StoryText.shared().get_lines("town.alchemist.locked")).to_lower()
	assert_false(text.contains("zone"), text)
	assert_true(text.contains("come back later"))


func test_the_intro_quest_is_main_and_given_when_maren_sends_you() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.ALEMBIC)
	assert_eq(quest.category, QuestData.Category.MAIN)
	assert_false(Condition.met(quest.prerequisite, Session.unlock_state()))
	Session.set_flag(StringName(QuestDefinitions.FLAG_SENT_TO_ALEMBIC))
	assert_true(Condition.met(quest.prerequisite, Session.unlock_state()), "Maren's send-off opens it")
	assert_false(StoryText.shared().get_lines("memory.1.alembic").is_empty(), "Maren's lines that send the hero")


# ---- Part 3.3-3.6: essence -------------------------------------------------------------------------------------------------


func test_the_gift_adds_six_of_every_path_capped_at_eighteen() -> void:
	Session.quest_log.active.append(QuestDefinitions.ALEMBIC)
	Session.profile.set_essence(Affinity.Type.BEEFCAKE, 4)
	Session.profile.set_essence(Affinity.Type.GOURMAND, 15)
	Session.profile.set_essence(Affinity.Type.NECROCRAT, 0)
	assert_true(Session.visit_alchemist())
	assert_eq(Session.profile.essence_of(Affinity.Type.BEEFCAKE), 10, "added, never replaced")
	assert_eq(Session.profile.essence_of(Affinity.Type.GOURMAND), 18, "up to the cap")
	assert_eq(Session.profile.essence_of(Affinity.Type.NECROCRAT), 6)


func test_a_brew_costs_six_of_each_path() -> void:
	assert_eq(Alchemy.MIN_ESSENCE_PER_PATH, 6)
	assert_eq(Alchemy.ESSENCE_CAP_PER_PATH, 18)
	Session.profile.set_essence(Affinity.Type.BEEFCAKE, 5)
	Session.profile.set_essence(Affinity.Type.GOURMAND, 6)
	assert_ne(Alchemy.problem(Session.profile, 999, Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND), "", "5 is one short")
	Session.profile.set_essence(Affinity.Type.BEEFCAKE, 6)
	assert_eq(Alchemy.problem(Session.profile, 999, Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND), "")


func test_old_saves_are_clamped_to_eighteen() -> void:
	Session.profile.essence[int(Affinity.Type.REFUSEMANCER)] = 44
	assert_eq(Session.migrate_essence_cap(), 26)
	assert_eq(Session.profile.essence_of(Affinity.Type.REFUSEMANCER), 18)


func test_a_full_jar_says_so() -> void:
	var card: CardData = null
	for each: CardData in Session.content.cards.values():
		if each.paths().size() == 1 and not each.is_unlimited() and not each.is_token and each.paths()[0] == Affinity.Type.BEEFCAKE:
			card = each
			break
	assert_not_null(card)
	Session.profile.set_essence(Affinity.Type.BEEFCAKE, 18)
	var cards: Array[CardData] = [card, card, card, card]
	var notices: Array[String] = Session.add_cards(cards)
	assert_false(notices.is_empty())
	assert_string_contains(notices.back(), "full")
	assert_eq(Session.profile.essence_of(Affinity.Type.BEEFCAKE), 18)


func test_the_instructions_name_the_third_copy_the_cost_and_the_cap() -> void:
	var text: String = AlchemistScreen.instructions()
	assert_string_contains(text, "beyond your third")
	assert_string_contains(text, "6 essence")
	assert_string_contains(text, "18")


# ---- Part 2.8: unlock notes name the vendor, the map marks it ---------------------------------------------------------------


func test_level_unlocks_name_the_vendor_and_mark_the_map() -> void:
	var lines: Array[String] = UnlockDigest.level_unlocks(ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL)
	assert_true(" ".join(lines).contains("Bertram"), str(lines))
	Session.add_xp(ProgressionTable.xp_to_reach(ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL))
	assert_true(Session.vendor_is_new("equipment_vendor"))
	var stock: EquipmentVendorData = EquipmentVendorScreen.default_stock()
	assert_true(stock.available_equipment_ids(Session.unlock_state()).has("flamethrower"), "the advanced rack is really in stock")


func test_freeing_the_dna_names_the_shop_and_its_new_piece() -> void:
	var line: String = ZoneScene.freed_shop_line(ZoneDefs.get_def("necrocrat"))
	assert_string_contains(line, "Notary Seal")
	assert_string_contains(line, "Ledgerbone")
	Session.complete_zone("necrocrat")
	assert_true(Session.vendor_is_new("zone_necrocrat"))
	var ids: Array[String] = ExpansionGear.zone_vendor_stock("necrocrat").available_equipment_ids(Session.unlock_state())
	assert_true(ids.has("notary_seal"), "really in the shop's stock: %s" % str(ids))


func test_freeing_a_zone_marks_the_pack_vendor() -> void:
	Session.mark_vendor_new("pack_vendor")
	assert_true(Session.vendor_is_new("pack_vendor"))
	Session.clear_vendor_new("pack_vendor")
	assert_false(Session.vendor_is_new("pack_vendor"))
