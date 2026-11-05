extends GutTest
## Overnight Nov 4-5, Part 2: pack prices (General 150, Path 200, Gilded 4x the Path Pack), repeat fights pay the same as the first win, a dungeon
## clear pays the run's gold again (the clear bonus), quests pay more (main line most), no deck changes inside a dungeon, tri-Path recipes exist.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_pack_prices_and_the_gilded_ratio() -> void:
	assert_eq(PackCatalog.find("general_1").price, 150)
	var path_pack: PackData = PackCatalog.find("path_beefcake")
	var gilded: PackData = PackCatalog.find("gilded_beefcake")
	assert_eq(path_pack.price, 200)
	assert_eq(gilded.price, path_pack.price * 4, "the Gilded Pack keeps its old 4x ratio to the Path Pack (600 : 150)")
	assert_lt(PackCatalog.find("general_1").price, Economy.card_price(CardEnums.Rarity.COMMON) * 2, "a pack of several cards stays the bargain")


func test_a_repeat_fight_pays_what_the_first_win_paid() -> void:
	assert_eq(Economy.fight_gold(40, true), Economy.fight_gold(40, false))
	assert_eq(Economy.fight_gold(40, true), 40)


func test_a_cleared_run_pays_its_gold_again() -> void:
	Session.zone_run = ZoneRun.enter("beefcake", Session.profile, Session.deck)
	Session.dungeon_map = MainDungeons.build_map("beefcake")
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	Session.gold = 0
	Session.add_gold(35)
	Session.add_gold(60)
	assert_eq(Session.run.gold_earned, 95, "the run counts what it paid")
	assert_eq(Session.clear_bonus_preview(40), 135, "the boss's own gold counts too")
	var result: Dictionary = Session.resolve_main_dungeon(true)
	assert_eq(int(result.get("clear_bonus", 0)), 95)
	assert_gte(Session.gold, 95 + 95, "the run's gold doubled (plus the clear's own rewards)")


func test_a_retreat_pays_no_clear_bonus() -> void:
	Session.zone_run = ZoneRun.enter("beefcake", Session.profile, Session.deck)
	Session.dungeon_map = MainDungeons.build_map("beefcake")
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	Session.add_gold(50)
	var result: Dictionary = Session.resolve_main_dungeon(false)
	assert_false(result.has("clear_bonus"))


func test_gold_outside_a_dungeon_does_not_count() -> void:
	Session.run = null
	Session.add_gold(100)
	assert_eq(Session.clear_bonus_preview(), 0)


func test_quests_pay_more_and_the_main_line_most() -> void:
	var main: QuestData = QuestCatalog.find(QuestDefinitions.UNDER_THE_FOREST)
	assert_eq(main.reward_gold, 350, "200 authored, x1.75 for the main line")
	assert_eq(QuestCatalog.gold_scale(main), QuestCatalog.MAIN_GOLD_SCALE)
	for quest: QuestData in QuestCatalog.all():
		if not quest.is_main():
			assert_between(QuestCatalog.gold_scale(quest), 1.5, 1.6, quest.id)


func test_the_dungeon_map_has_no_deck_editor() -> void:
	assert_false(ResourceLoader.exists("res://ui/dungeon/dungeon_deckbuilder_screen.gd"), "the in-dungeon Deck Station is gone")
	var source: String = FileAccess.get_file_as_string("res://ui/dungeon/dungeon_map_screen.gd")
	assert_false(source.contains("_open_deck_builder"), "no code path opens a deck editor from the map")
	assert_false(source.contains("open_deck"), "the B hotkey does nothing on the map")


func test_cards_won_in_a_dungeon_go_to_the_collection_except_in_the_tutorial_cave() -> void:
	Session.main_dungeon_active = true
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	assert_false(Session.rewards_go_to_deck(), "a zone dungeon's pick goes to the collection")


func test_every_trio_of_paths_has_tri_path_cards() -> void:
	var paths: Array[Affinity.Type] = Affinity.colored_types()
	for skip: int in range(paths.size()):
		var trio: Array[Affinity.Type] = []
		for index: int in range(paths.size()):
			if index != skip:
				trio.append(paths[index])
		assert_gt(Alchemy.tri_path_pool(Session.content, trio).size(), 0, "a tri-Path brew of %s finds cards" % str(trio))
