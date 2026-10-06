extends GutTest
## Pack sources: a zone dungeon's Path Pack on every clear, the first-clear bonus and Pack Vendor unlock, quest and minigame pack rewards,
## and the reward text.

const ZONES: Array[String] = ["beefcake", "gourmand", "refusemancer", "necrocrat"]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.profile.packs.clear()


func after_each() -> void:
	Session.main_dungeon_active = false
	Session.run = null
	Session.dungeon_map = null
	Session.zone_run = null
	for zone_id: String in ZONES:
		ZoneStoryText.set_zone_freed(zone_id, false)


func _enter(zone_id: String) -> void:
	Session.zone_run = ZoneRun.enter(zone_id, Session.profile, Session.deck)
	Session.dungeon_map = MainDungeons.build_map(zone_id)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.run.hp = Session.zone_run.hp
	Session.main_dungeon_active = true


func test_every_clear_awards_the_path_pack_and_the_first_adds_a_bonus() -> void:
	var config: PackConfig = PackCatalog.config()
	for zone_id: String in ZONES:
		after_each()
		before_each()
		var path: Affinity.Type = PackRules.path_for_zone(zone_id)
		var path_pack_id: String = PackRules.path_pack_id(path)
		var gilded_id: String = PackRules.gilded_pack_id(path)
		_enter(zone_id)
		var gold_before: int = Session.gold
		var first: Dictionary = Session.resolve_main_dungeon(true)
		assert_eq(Session.pack_count(path_pack_id), config.dungeon_pack_count, "%s: the Path Pack" % zone_id)
		assert_eq(Session.pack_count(gilded_id), config.first_clear_gilded_packs, "%s: a Gilded Pack on the first clear" % zone_id)
		assert_eq(int(first["bonus_gold"]), config.first_clear_bonus_gold)
		assert_gte(Session.gold, gold_before + config.first_clear_bonus_gold + MainDungeons.def(zone_id).reward_gold)
		assert_eq(int(first["bonus_xp"]), config.first_clear_bonus_xp)
		assert_eq(str(first["vendor_unlock"]), PackCatalog.find(path_pack_id).display_name)
		assert_true(Session.is_zone_completed(zone_id))
		# The Pack Vendor now stocks that Path's pack.
		var stocked: Array[String] = []
		for pack: PackData in PackShop.stocked(PackData.VENDOR_PACK, Session.unlock_state()):
			stocked.append(pack.id)
		assert_true(stocked.has(path_pack_id), "%s: the Pack Vendor stocks it" % zone_id)
		# Replays: the Path Pack again, but not the first-clear extras.
		_enter(zone_id)
		var second: Dictionary = Session.resolve_main_dungeon(true)
		assert_eq(Session.pack_count(path_pack_id), config.dungeon_pack_count * 2, "%s: every clear pays the Path Pack" % zone_id)
		assert_eq(Session.pack_count(gilded_id), config.first_clear_gilded_packs, "%s: the Gilded Pack only once" % zone_id)
		assert_false(second.has("bonus_gold"))
		assert_eq(PackRewards.dungeon_lines(second, StoryText.shared()).size(), 1)


func test_a_lost_run_or_a_retreat_pays_no_pack() -> void:
	_enter("beefcake")
	Session.run.hp = 0
	Session.resolve_main_dungeon(false, true)
	assert_eq(Session.profile.total_packs(), 0)
	_enter("beefcake")
	Session.resolve_main_dungeon(false)
	assert_eq(Session.profile.total_packs(), 0)


func test_the_first_clear_text_names_the_packs_the_bonus_and_the_vendor() -> void:
	_enter("necrocrat")
	var result: Dictionary = Session.resolve_main_dungeon(true)
	var lines: Array[String] = PackRewards.dungeon_lines(result, StoryText.shared())
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0], "Necrocrat Pack")
	assert_string_contains(lines[1], "Gilded Necrocrat Pack")
	assert_string_contains(lines[1], "gold")
	assert_string_contains(lines[2], "Necrocrat Pack")
	assert_false(lines[0].begins_with("[missing"))


func test_the_dungeon_packs_can_be_opened_and_follow_their_pool_rules() -> void:
	_enter("gourmand")
	Session.resolve_main_dungeon(true)
	var gilded: PackOpening = Session.open_pack("gilded_gourmand")
	assert_true(gilded.cards().any(func(card: CardData) -> bool: return card.rarity >= CardEnums.Rarity.EPIC), "the Gilded Pack has an Epic or better")
	var plain: PackOpening = Session.open_pack("path_gourmand")
	for card: CardData in plain.cards():
		assert_true(card.color == Affinity.Type.GOURMAND or card.color == Affinity.Type.NEUTRAL)


# ---- Quests and minigames --------------------------------------------------------------------------------


func test_every_zone_gives_at_least_two_quest_packs() -> void:
	var by_path: Dictionary = {}
	for quest: QuestData in QuestCatalog.all():
		for pack_id: String in quest.reward_pack_ids:
			assert_not_null(PackCatalog.find(pack_id), "%s: a real pack" % quest.id)
			by_path[pack_id] = int(by_path.get(pack_id, 0)) + 1
	for path: Affinity.Type in Affinity.colored_types():
		assert_gte(int(by_path.get(PackRules.path_pack_id(path), 0)), 2, "%s quests give packs" % Affinity.display_name(path))


func test_completing_a_quest_pays_its_pack_and_the_summary_shows_it() -> void:
	var quest: QuestData = QuestCatalog.find("dna_audit")
	assert_false(quest.reward_pack_ids.is_empty())
	assert_string_contains(quest.reward_summary(), "Necrocrat Pack")
	assert_true(Session.start_quest("dna_audit"))
	assert_true(Session.complete_quest("dna_audit"))
	assert_eq(Session.pack_count("path_necrocrat"), 1)


func test_each_zones_minigame_pays_a_path_pack_on_the_first_win_only() -> void:
	var games: Dictionary = {
		"necrocrat": func(stars: int) -> Dictionary: return MatchGame.apply_result(stars),
		"beefcake": func(stars: int) -> Dictionary: return RepGame.apply_result(stars),
		"gourmand": func(stars: int) -> Dictionary: return OrderGame.apply_result(stars),
		"refusemancer": func(stars: int) -> Dictionary: return SortGame.apply_result(stars),
	}
	for zone_id: String in games.keys():
		Session.zone_run = ZoneRun.enter(zone_id, Session.profile, Session.deck)
		var play: Callable = games[zone_id] as Callable
		var pack_id: String = PackRules.path_pack_id(PackRules.path_for_zone(zone_id))
		var first: Dictionary = play.call(2)
		assert_true(bool(first["first_win"]), zone_id)
		assert_eq(str(first.get("pack", "")), pack_id, "%s: a first win pays the pack" % zone_id)
		assert_eq(Session.pack_count(pack_id), 1)
		assert_string_contains(PackRewards.minigame_text(first), "Pack")
		var again: Dictionary = play.call(2)
		assert_false(again.has("pack"))
		assert_eq(Session.pack_count(pack_id), 1, "%s: only the first win" % zone_id)
		var lost: Dictionary = play.call(0)
		assert_false(lost.has("pack"))
	Session.zone_run = null
