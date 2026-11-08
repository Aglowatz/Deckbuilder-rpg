extends GutTest
## Overnight Nov 7-8, Part 2: the friendlier economy - Commons 50 (1 : 2 : 5 : 10), the cheapest gear 250, packs still a good deal, the intro
## checkpoint (one more gear piece + 4 Commons + 2 items after the armory quest), late fights paying more, the Extra Pocket's two item uses.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func test_card_prices_start_at_50_and_keep_the_ratio() -> void:
	assert_eq(Economy.card_price(CardEnums.Rarity.COMMON), 50)
	assert_eq(Economy.card_price(CardEnums.Rarity.UNCOMMON), 100)
	assert_eq(Economy.card_price(CardEnums.Rarity.EPIC), 250)
	assert_eq(Economy.card_price(CardEnums.Rarity.LEGENDARY), 500)


func test_the_cheapest_gear_on_sale_costs_250() -> void:
	var cheapest: int = 1 << 30
	for rarity: Variant in [EquipmentData.Rarity.COMMON, EquipmentData.Rarity.UNCOMMON, EquipmentData.Rarity.RARE]:
		for tier: int in range(1, 5):
			cheapest = mini(cheapest, Economy.gear_price(rarity as EquipmentData.Rarity, tier))
	assert_eq(cheapest, 250)
	assert_lt(Economy.gear_price(EquipmentData.Rarity.COMMON, 4), Economy.gear_price(EquipmentData.Rarity.RARE, 1), "rarity outranks tier")


func test_packs_cost_less_than_their_cards_at_shelf_prices() -> void:
	for pack: PackData in PackCatalog.all():
		var per_card: float = 0.0
		var total_weight: int = 0
		for index: int in range(pack.rarity_weights.size()):
			per_card += float(pack.rarity_weights[index]) * float(Economy.CARD_PRICE[index])
			total_weight += pack.rarity_weights[index]
		var value: float = per_card / float(maxi(1, total_weight)) * float(pack.card_count)
		assert_lt(float(pack.price), value * 0.95, "%s: %d for about %d of cards" % [pack.id, pack.price, int(value)])


## The no-grind player's gold when the armory quest completes: start, the cave, levels 2-5, Maren's errands, the store room, one roamer and
## the cave feats, less the one card Meet the Merchants asks for. It must cover a second gear piece, four Commons and two items.
func test_the_armory_checkpoint_affords_gear_four_commons_and_two_items() -> void:
	var gold: int = Session.STARTING_GOLD + int(TrialOfTheHollow.total_tutorial_rewards()["gold"])
	for level: int in range(2, 6):
		for grant: Variant in LevelTrack.level_entry(level).get("grants", []) as Array:
			if str((grant as Dictionary).get("kind", "")) == "gold":
				gold += int((grant as Dictionary).get("amount", 0))
	for quest_id: String in [QuestDefinitions.MERCHANTS, QuestDefinitions.FIRST_DECK_EDIT, QuestDefinitions.GHOSTS, QuestDefinitions.ARMORY]:
		gold += QuestCatalog.find(quest_id).reward_gold
	gold += StoreroomGhosts.GOLD + Economy.roamer_gold("town") + 35  # the cave's two feats
	gold -= Economy.card_price(CardEnums.Rarity.COMMON)  # Meet the Merchants: buy a card
	var need: int = Economy.gear_price(EquipmentData.Rarity.COMMON, 1) + 4 * Economy.card_price(CardEnums.Rarity.COMMON) + Economy.item_price("healing_salve") * 2
	assert_gte(gold, need, "checkpoint gold %d covers %d" % [gold, need])
	assert_lt(gold, need + 400, "and not much more (%d)" % gold)


func test_late_fights_pay_more_by_level() -> void:
	assert_eq(Economy.late_gold(100, 17), 100, "unchanged below level 18")
	assert_gt(Economy.late_gold(100, 21), Economy.late_gold(100, 18))
	assert_gt(Economy.late_gold(100, 25), Economy.late_gold(100, 21))
	assert_gt(Economy.roamer_gold("final"), Economy.ROAMER_GOLD[5], "the Capital's roamers pay more")
	assert_eq(Economy.roamer_gold("beefcake"), Economy.ROAMER_GOLD[1], "an early zone's do not")


func test_the_extra_pocket_lets_each_item_be_used_twice() -> void:
	var pocket: EquipmentData = Session.content.equipment_piece("extra_pocket")
	assert_not_null(pocket)
	assert_string_contains(pocket.description, "twice per battle")
	assert_eq(pocket.modifiers[0].kind, Modifier.Kind.ITEM_USES_PER_BATTLE)
	var game: GameState = GameState.new()
	game.players = [PlayerState.new(), PlayerState.new()]
	game.players[0].index = 0
	var item: ItemData = Session.content.item("healing_salve")
	game.items_used[0][item.id] = 1
	assert_true(game.item_used(0, item), "one use without the pocket")
	game.players[0].item_uses_per_battle = 2
	assert_false(game.item_used(0, item), "a second use with it")
	game.items_used[0][item.id] = 2
	assert_true(game.item_used(0, item), "and no third")
