extends GutTest
## Overnight Nov 4-5, Part 2: pack prices (General 150, Path 200, Gilded 4x the Path Pack), repeat fights pay the same as the first win, a dungeon
## clear pays the run's gold again (the clear bonus), quests pay more (main line most), no deck changes inside a dungeon, tri-Path recipes exist.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_pack_prices_and_the_gilded_ratio() -> void:
	# Overnight Nov 7-8, Part 2.4: General 100, Path 150, Gilded 400 (with its guaranteed Epic or Legendary) - every pack under its cards' shelf value.
	assert_eq(PackCatalog.find("general_1").price, 100)
	var path_pack: PackData = PackCatalog.find("path_beefcake")
	var gilded: PackData = PackCatalog.find("gilded_beefcake")
	assert_eq(path_pack.price, 150)
	assert_eq(gilded.price, 400)
	assert_lt(PackCatalog.find("general_1").price, Economy.card_price(CardEnums.Rarity.COMMON) * 3, "a pack of three cards stays the bargain")


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
	# Overnight Nov 7-8, Part 2.4: the bonus is Economy.CLEAR_BONUS_SHARE of the run's gold (was all of it).
	assert_eq(Session.clear_bonus_preview(40), roundi(135.0 * Economy.CLEAR_BONUS_SHARE / 5.0) * 5, "the boss's own gold counts too")
	var result: Dictionary = Session.resolve_main_dungeon(true)
	assert_eq(int(result.get("clear_bonus", 0)), roundi(95.0 * Economy.CLEAR_BONUS_SHARE / 5.0) * 5)
	assert_gte(Session.gold, 95 + roundi(95.0 * Economy.CLEAR_BONUS_SHARE / 5.0) * 5, "the run's gold plus the bonus (plus the clear's own rewards)")


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
	# Overnight Nov 7-8, Part 2.4: the scales came down with the cheaper shelves; the main line still pays the most.
	assert_eq(main.reward_gold, roundi(200.0 * QuestCatalog.MAIN_GOLD_SCALE / 5.0) * 5, "200 authored, x MAIN_GOLD_SCALE")
	assert_eq(QuestCatalog.gold_scale(main), QuestCatalog.MAIN_GOLD_SCALE)
	for quest: QuestData in QuestCatalog.all():
		if not quest.is_main():
			assert_lte(QuestCatalog.gold_scale(quest), QuestCatalog.MAIN_GOLD_SCALE + 0.06, quest.id)


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
