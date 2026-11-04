extends GutTest
## Fix pass Nov 4 (B), Part 2.2-2.4: the House of Gains. The Descent (bribe 40 gold / 3 HP / a random card gone for the run), the Rescue (Flex at your
## side in the final battle is the only boon: no stats, no max HP; his ally is a 3/5) and the tougher Cell Block Brawler (stronger deck, more HP,
## the Smuggled Weights rule beside "Iron can't be used").


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.zone_run = ZoneRun.enter("beefcake", Session.profile, Session.deck)
	Session.dungeon_key = "beefcake"
	Session.dungeon_map = MainDungeons.build_map("beefcake")
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.run.hp = Session.zone_run.hp
	Session.main_dungeon_active = true


func after_each() -> void:
	Session.main_dungeon_active = false
	Session.run = null
	Session.dungeon_map = null
	Session.zone_run = null


func _descent() -> DungeonEvent:
	return MainDungeons.def("beefcake").event("hg_descent")


func test_the_descent_offers_bribe_overpower_and_distract() -> void:
	var event: DungeonEvent = _descent()
	assert_eq(event.choices.size(), 3)
	var story: ZoneStoryText = ZoneStoryText.for_zone("beefcake")
	assert_eq(story.text(event.choice_key(0)), "Bribe the guard")
	assert_eq(story.text(event.choice_key(1)), "Overpower the guard")
	assert_eq(story.text(event.choice_key(2)), "Distract the guard")
	assert_eq(event.choices[0].gold_cost(), 40, "the bribe is 40 gold")
	assert_string_contains(story.text(event.result_key(2)), "{card}", "the distraction's result names the card")


func test_the_bribe_needs_40_gold_and_takes_exactly_that() -> void:
	Session.gold = 39
	var refused: EventResolver.Result = Session.resolve_dungeon_event(_descent(), 0)
	assert_false(refused.ok, "greyed out below 40 gold")
	assert_string_contains(refused.reason, "40")
	assert_eq(Session.gold, 39)
	Session.gold = 100
	var paid: EventResolver.Result = Session.resolve_dungeon_event(_descent(), 0)
	assert_true(paid.ok)
	assert_eq(Session.gold, 60)


func test_overpowering_the_guard_costs_3_hp() -> void:
	Session.run.hp = 15
	var result: EventResolver.Result = Session.resolve_dungeon_event(_descent(), 1)
	assert_eq(result.hp_delta, -3)
	assert_eq(Session.run.hp, 12)


func test_distracting_the_guard_loses_one_card_for_this_run_only() -> void:
	var before: int = Session.run.current_deck().cards.size()
	var collection_before: int = Session.profile.collection.size() if "collection" in Session.profile else 0
	var result: EventResolver.Result = Session.resolve_dungeon_event(_descent(), 2)
	assert_true(result.ok)
	assert_eq(result.lost_cards.size(), 1, "one card goes")
	var lost: CardData = result.lost_cards[0]
	assert_false(lost.is_basic, "a real card, not a basic")
	assert_eq(Session.run.current_deck().cards.size(), before - 1, "gone from this run's deck")
	assert_true(Session.deck.cards.has(lost), "the saved deck keeps it: it comes back after the run")
	if "collection" in Session.profile:
		assert_eq(Session.profile.collection.size(), collection_before, "the collection is untouched")


func test_the_rescue_is_only_flex_at_your_side() -> void:
	var rescue: DungeonEvent = MainDungeons.def("beefcake").event("hg_rescue")
	var boon: ModifierSource = rescue.choices[0].outcomes[0].boon
	assert_eq(boon.modifiers.size(), 0, "no +1/+1, no +3 max HP")
	assert_eq(rescue.choices[0].hint(), "boon: %s (Grandmaster Flex fights beside you in the final battle)" % HouseOfGainsDungeon.BOON_NAME)
	var flex: CardData = TokenRegistry.data(HouseOfGainsDungeon.ALLY_TOKEN_ID)
	assert_eq(flex.attack, 3)
	assert_eq(flex.defense, 5)


func test_the_cell_block_brawler_is_a_mid_dungeon_elite() -> void:
	var foe: MainDungeonDef.Foe = MainDungeons.def("beefcake").foe("Cell Block Brawler")
	assert_not_null(foe)
	assert_gte(foe.hp, 16, "more HP (was 13)")
	var rules: Array[EncounterModifiers.Rule] = EncounterModifiers.rules("Cell Block Brawler")
	var names: Array[String] = []
	for rule: EncounterModifiers.Rule in rules:
		names.append(rule.name)
	assert_has(names, "Smuggled Weights", "a prison rule of his own")
	var iron_rule: bool = false
	for rule: Dictionary in DungeonRules.rules("beefcake"):
		if str(rule.get("name", "")) == "Iron-less Prison":
			iron_rule = true
	assert_true(iron_rule, "beside the Iron-less Prison rule")
