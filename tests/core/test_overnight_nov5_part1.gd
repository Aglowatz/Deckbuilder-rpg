extends GutTest
## Overnight Nov 4-5, Part 1 (the critic's list, docs/review/critic_nov4b.md): an NPC speaks to the newest quest step of theirs, Old Man Mountain
## says the gate hint himself, the Alchemist's Craft button shows its cost and why it is off, the zone lines close after Primm and "Under the
## Forest" is tracked, a used-up item slot is not an empty one, long nameplates fit, and the House of Gains rules no longer repeat themselves.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_an_npc_speaks_to_the_newest_active_quest_of_theirs_first() -> void:
	Session.quest_log.active.clear()
	Session.quest_log.active.append("gain_spot_me")
	Session.quest_log.active.append(ZoneQuestDefinitions.SIDE_BEEF)
	var active: Array[QuestData] = Session.quests_active_for(GainlandsZone.NPC_BRENDA)
	assert_eq(active.size(), 2)
	assert_eq(active[0].id, ZoneQuestDefinitions.SIDE_BEEF, "the shake errand, not the old Spot Gary one")


func test_old_man_mountain_says_the_gate_hint_in_his_own_first_talk() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(GainlandsZone.ID)
	assert_string_contains(" ".join(story.get_lines("npc.brenda.intro")), "when the kingdom is whole again")


func test_alchemy_reasons_read_like_the_button() -> void:
	var profile: PlayerProfile = Session.profile
	profile.set_essence(Affinity.Type.BEEFCAKE, 12)
	profile.set_essence(Affinity.Type.NECROCRAT, 0)
	assert_eq(Alchemy.problem(profile, 999, Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT), "Need %d more Necrocrat essence" % Alchemy.MIN_ESSENCE_PER_PATH)
	profile.set_essence(Affinity.Type.NECROCRAT, Alchemy.MIN_ESSENCE_PER_PATH)
	assert_eq(Alchemy.problem(profile, 0, Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT), "Need %d gold" % Alchemy.GOLD_COST)


func test_the_craft_button_shows_its_cost_and_why_it_is_off() -> void:
	Session.profile.set_essence(Affinity.Type.BEEFCAKE, 18)
	Session.profile.set_essence(Affinity.Type.NECROCRAT, Alchemy.MIN_ESSENCE_PER_PATH - 1)
	Session.gold = 500
	var screen: AlchemistScreen = AlchemistScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	var craft: FancyButton = screen.find_child("CraftButton", true, false) as FancyButton
	assert_true(craft.disabled)
	assert_string_contains(craft.text, "Craft — %d gold, %d + %d" % [Alchemy.GOLD_COST, Alchemy.MIN_ESSENCE_PER_PATH, Alchemy.MIN_ESSENCE_PER_PATH])
	assert_string_contains(craft.text, "Pick two Paths")
	for path: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT]:
		((screen.find_child("EssenceRow%d" % int(path), true, false)) as Button).pressed.emit()
	await wait_frames(2)
	assert_true(craft.disabled)
	assert_string_contains(craft.text, "Need 1 more Necrocrat essence")
	var row: Button = screen.find_child("EssenceRow%d" % int(Affinity.Type.BEEFCAKE), true, false) as Button
	assert_true((row.find_child("Selected", true, false) as Label).visible, "a chosen jar is marked Selected")
	Session.profile.set_essence(Affinity.Type.NECROCRAT, 18)
	screen._refresh()
	assert_false(craft.disabled)
	assert_false(craft.text.contains("\n"), "no reason line when it can be pressed")


func test_primms_fall_closes_the_zone_lines_and_tracks_under_the_forest() -> void:
	var gourmand_main: String = QuestDefinitions.zone_main_id("gourmand")
	Session.quest_log.active.append(gourmand_main)
	Session.quest_log.track(gourmand_main)
	Session.unlock_postgame()
	assert_false(Session.quest_log.is_active(gourmand_main), "no zone line left at 0/4 after Primm")
	assert_true(Session.quest_log.is_active(QuestDefinitions.UNDER_THE_FOREST))
	assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.UNDER_THE_FOREST, "the tracker switches by itself")


func test_a_freed_zone_finishes_its_line_without_the_favour() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("necrocrat"))
	Session.set_flag(StringName(str(ZoneCompletion.flag_name("necrocrat"))))
	assert_true(Session.quest_log.objective_met(quest, 2, Session.unlock_state()), "the favour step counts once the zone is free")


func test_a_used_up_item_leaves_a_spent_slot_not_an_empty_one() -> void:
	var profile: PlayerProfile = Session.profile
	var item: ItemData = Session.content.items.values()[0] as ItemData
	Session.add_item(item, 1)
	assert_true(profile.equip_item_id(item, 0))
	profile.spend_item_charge(item)
	assert_eq(profile.item_in_slot(0), "", "the item is gone")
	assert_eq(profile.spent_item_in_slot(0), item.id, "but the slot remembers it was used")
	Session.add_item(item, 1)
	profile.equip_item_id(item, 0)
	assert_eq(profile.spent_item_in_slot(0), "", "equipping fills it again")
	profile.unequip_item_id(item)
	profile.spent_item_slots["1"] = item.id
	Session.profile = profile
	var data: Dictionary = Session.to_dict()
	Session.from_dict(data)
	assert_eq(Session.profile.spent_item_in_slot(1), item.id, "saved and loaded")


func test_long_names_with_titles_fit_the_nameplate() -> void:
	var box: DialogueBox = DialogueBox.new()
	add_child_autofree(box)
	await wait_frames(2)
	for name: String in ["Rip Tearson, Rift Technician", "Bertram", "Grandmaster Flex", "Archdruid Compostella", "Agnes Overdue, Head Archivist"]:
		box.start(name, ["Hello."] as Array[String])
		await wait_frames(1)
		var label: Label = box._speaker
		var font_size: int = label.get_theme_font_size("font_size")
		assert_gte(font_size, 14, name)
		assert_lte(box._speaker_width(font_size), label.size.x + 0.5, "%s fits its plate" % name)
		box.hide()


func test_the_house_of_gains_rules_do_not_repeat_themselves() -> void:
	var names: Array[String] = []
	for rule: Dictionary in DungeonRules._entries("D-HOG"):
		names.append(str(rule["name"]))
	assert_has(names, "Home Gym", "renamed from Pump Iron (the zone's own rule is Pump It Up)")
	var text: String = FileAccess.get_file_as_string("res://data/encounters/modifiers.json")
	var data: Dictionary = JSON.parse_string(text) as Dictionary
	var brawler: Dictionary = (data["Cell Block Brawler"] as Array)[0] as Dictionary
	assert_false(str(brawler["text"]).contains("Iron in the prison"), "Iron-less Prison already says it")


## The real win path: the castle's boss falls (`resolve_main_dungeon`, what the Victory panel calls) on a save with two zone lines unfinished.
func test_beating_primm_in_the_castle_settles_the_quest_log() -> void:
	for zone_id: String in ["gourmand", "refusemancer"]:
		Session.quest_log.active.append(QuestDefinitions.zone_main_id(zone_id))
	Session.quest_log.track(QuestDefinitions.zone_main_id("refusemancer"))
	Session.zone_run = ZoneRun.enter(CapitalZone.ID, Session.profile, Session.deck)
	Session.dungeon_map = MainDungeons.build_map(CapitalZone.ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	var result: Dictionary = Session.resolve_main_dungeon(true)
	assert_eq(str(result.get("kind", "")), "primm_defeated")
	for zone_id: String in Gatekeepers.IDS:
		assert_false(Session.quest_log.is_active(QuestDefinitions.zone_main_id(zone_id)), "%s's line is closed" % zone_id)
	assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.UNDER_THE_FOREST)
