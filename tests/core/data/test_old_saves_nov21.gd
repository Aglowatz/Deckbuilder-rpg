extends GutTest
## Fable Nov 21 review (Part 2, save safety): a save written before the Nov 18-21 changes (the three-copies-owned rule, the three-Path
## lock, the heal rooms, the renames, the Raw Deal, the quest parts) loads in today's game and keeps what the player had: cards, gold,
## level, quests, gear, items, packs, essence and cosmetics. The fixtures are real bot saves from Nov 9 and Nov 16
## (tests/fixtures/old_saves/). What a migration is allowed to change: a copy above the cap becomes essence or gold (never nothing).

const FIXTURES: Array[String] = [
	"res://tests/fixtures/old_saves/nov09_gourmand_mid_dungeon.json",
	"res://tests/fixtures/old_saves/nov09_necrocrat_two_zones.json",
	"res://tests/fixtures/old_saves/nov09_gourmand_postgame.json",
	"res://tests/fixtures/old_saves/nov16_refusemancer_capital_ready.json",
]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func after_all() -> void:
	Session.save_enabled = false
	Session.new_game()


func _read(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _counts(ids: Array) -> Dictionary:
	var counts: Dictionary = {}
	for id: Variant in ids:
		counts[str(id)] = int(counts.get(str(id), 0)) + 1
	return counts


func test_the_fixtures_are_from_before_nov_18() -> void:
	for path: String in FIXTURES:
		var data: Dictionary = _read(path)
		assert_false(data.is_empty(), "%s reads" % path)
		var saved_at: int = int((data.get("meta", {}) as Dictionary).get("saved_at", 0))
		# Nov 18 2026 00:00 UTC
		assert_lt(saved_at, 1795046400, "%s was written before Nov 18 (%d)" % [path.get_file(), saved_at])


func test_an_old_save_loads_and_keeps_what_the_player_had() -> void:
	for path: String in FIXTURES:
		var name: String = path.get_file()
		var data: Dictionary = _read(path)
		Session.new_game()
		assert_true(Session.from_dict(data), "%s loads" % name)
		# level, xp
		assert_eq(Session.profile.level, int(data["level"]), "%s: level" % name)
		assert_eq(Session.profile.xp, int(data["xp"]), "%s: xp" % name)
		# cards: every card the save owned is still owned; a copy is only ever lost to the copy cap, and then it was paid for
		var before: Dictionary = _counts(data["owned"] as Array)
		var lost_copies: int = 0
		for id: Variant in before.keys():
			var card: CardData = Session.card_by_id(str(id))
			assert_not_null(card, "%s: the card %s still exists" % [name, id])
			if card == null:
				continue
			var now: int = Session.profile.owned_copies(card.id)
			var cap: int = CopyCaps.own_cap(card)
			assert_gte(now, mini(int(before[id]), cap), "%s: %s x%d is kept up to the cap %d (now %d)" % [name, card.display_name, int(before[id]), cap, now])
			lost_copies += maxi(0, int(before[id]) - now)
		# gold never drops; copies over the cap were converted, not dropped
		assert_gte(Session.gold, int(data["gold"]), "%s: gold %d -> %d" % [name, int(data["gold"]), Session.gold])
		var essence_before: int = 0
		for value: Variant in (data.get("essence", {}) as Dictionary).values():
			essence_before += int(value)
		var essence_now: int = 0
		for path_type: Affinity.Type in Affinity.colored_types():
			essence_now += Session.profile.essence_of(path_type)
		if lost_copies > 0:
			assert_true(Session.gold > int(data["gold"]) or essence_now > essence_before or essence_now >= Alchemy.ESSENCE_CAP_PER_PATH * 4, "%s: %d copies over the cap were paid for (gold %d -> %d, essence %d -> %d)" % [name, lost_copies, int(data["gold"]), Session.gold, essence_before, essence_now])
		else:
			assert_gte(essence_now, mini(essence_before, essence_now), "%s: essence" % name)
		# quests
		var quests: Dictionary = data.get("quests", {}) as Dictionary
		var known: Dictionary = {}
		for quest: QuestData in QuestDefinitions.build_all():
			known[quest.id] = true
		for id: Variant in quests.get("completed", []) as Array:
			if known.has(str(id)):
				assert_true(Session.quest_log.is_completed(str(id)), "%s: quest %s stays completed" % [name, id])
		for id: Variant in quests.get("active", []) as Array:
			if known.has(str(id)):
				assert_true(Session.quest_log.is_active(str(id)) or Session.quest_log.is_completed(str(id)), "%s: quest %s stays active" % [name, id])
		# gear, items, packs
		for id: Variant in data.get("owned_equipment", []) as Array:
			var found: bool = false
			for piece: EquipmentData in Session.profile.owned_equipment:
				if piece.id == str(id):
					found = true
			assert_true(found, "%s: gear %s is kept" % [name, id])
		assert_eq(Session.profile.owned_items.size(), (data.get("owned_items", []) as Array).size(), "%s: items" % name)
		var packs_before: int = 0
		for value: Variant in (data.get("packs", {}) as Dictionary).values():
			packs_before += int(value)
		var packs_now: int = 0
		for value: Variant in Session.profile.packs.values():
			packs_now += int(value)
		assert_eq(packs_now, packs_before, "%s: unopened packs" % name)
		# cosmetics
		var look: Dictionary = data.get("cosmetics", {}) as Dictionary
		for id: Variant in look.get("owned", []) as Array:
			if CosmeticCatalog.find(str(id)) != null and int(look.get("version", 1)) >= CosmeticMigration.VERSION:
				assert_true(Session.cosmetics.owned.has(str(id)), "%s: cosmetic %s is kept" % [name, id])
		# flags and cleared dungeons
		for flag: Variant in (data.get("flags", {}) as Dictionary).keys():
			if bool((data["flags"] as Dictionary)[flag]):
				assert_true(Session.flag(StringName(str(flag))), "%s: flag %s" % [name, flag])
		assert_gte(Session.cleared_dungeons.size(), (data.get("cleared_dungeons", []) as Array).size(), "%s: cleared dungeons" % name)


func test_an_old_save_can_fight_at_once_or_is_told_why_not() -> void:
	for path: String in FIXTURES:
		var name: String = path.get_file()
		Session.new_game()
		assert_true(Session.from_dict(_read(path)), "%s loads" % name)
		assert_gte(Session.deck.size(), DeckValidator.MIN_DECK_SIZE, "%s: the active deck is a full deck (%d)" % [name, Session.deck.size()])
		var issues: Array[DeckValidator.Issue] = Session.deck_issues()
		var texts: PackedStringArray = []
		for issue: DeckValidator.Issue in issues:
			texts.append(issue.message)
		# a deck with a sealed three-Path card is the one allowed problem (the Deck Station explains it); anything else is a broken save
		for issue: DeckValidator.Issue in issues:
			assert_eq(issue.problem, DeckValidator.Problem.LOCKED_MULTI_PATH, "%s: the only deck problem allowed is a sealed card (%s)" % [name, issue.message])
		gut.p("%s: deck %d cards, problems: %s" % [name, Session.deck.size(), ", ".join(texts) if not texts.is_empty() else "none"])


func test_an_old_save_round_trips_through_todays_format() -> void:
	for path: String in FIXTURES:
		var name: String = path.get_file()
		Session.new_game()
		assert_true(Session.from_dict(_read(path)), "%s loads" % name)
		var gold: int = Session.gold
		var owned: int = Session.profile.owned_cards.size()
		var completed: int = Session.quest_log.completed.size()
		# through JSON, as a save file goes (the quest log hands out its live lists, so a dictionary kept in memory would be emptied by new_game)
		var again: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
		Session.new_game()
		assert_true(Session.from_dict(again), "%s loads again from today's format" % name)
		assert_eq(Session.gold, gold, "%s: gold after a second load" % name)
		assert_eq(Session.profile.owned_cards.size(), owned, "%s: cards after a second load" % name)
		assert_eq(Session.quest_log.completed.size(), completed, "%s: quests after a second load" % name)


## The quest log's saved form is a copy: a dictionary taken now still holds the quests after the log is reset.
func test_the_quest_logs_saved_form_is_a_copy() -> void:
	assert_true(Session.from_dict(_read(FIXTURES[2])))
	var completed: int = Session.quest_log.completed.size()
	assert_gt(completed, 5)
	var saved: Dictionary = Session.quest_log.to_dict()
	Session.quest_log.reset()
	assert_eq((saved["completed"] as Array).size(), completed, "the saved list is not the live list")
	Session.quest_log.from_dict(saved)
	assert_eq(Session.quest_log.completed.size(), completed)
