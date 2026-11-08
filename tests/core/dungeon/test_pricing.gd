extends GutTest


func test_prices_scale_with_rarity_and_cost() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var sellsword: CardData = content.card("C-01")
	var colossus: CardData = content.card("R-33")
	assert_true(CardPricing.price(colossus) > CardPricing.price(sellsword))
	assert_eq(CardPricing.price(sellsword), Economy.card_price(sellsword.rarity), "Oct 29: priced by rarity alone")
	assert_eq(CardPricing.price(colossus), Economy.CARD_PRICE[int(colossus.rarity)])
	assert_eq(Economy.CARD_PRICE, [50, 100, 250, 500] as Array[int], "Overnight Nov 7-8: a Common costs 50, ratio 1 : 2 : 5 : 10")
	assert_eq(Economy.CARD_PRICE[0], 50)


func test_sale_limits() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	assert_true(CardPricing.is_for_sale(content.card("B-03"), 0))
	assert_false(CardPricing.is_for_sale(content.card("B-03"), 3))
	assert_false(CardPricing.is_for_sale(content.card("T-16"), 0))


func test_equipment_is_a_saving_goal() -> void:
	# Fix pass Nov 4 (Part 2.2): 4-6 shop pieces per no-grind playthrough (docs/balance/gold_economy_nov3.md); every tier dearer than the last.
	for rarity: EquipmentData.Rarity in [EquipmentData.Rarity.COMMON, EquipmentData.Rarity.UNCOMMON, EquipmentData.Rarity.RARE]:
		for tier: int in range(1, 4):
			assert_lte(Economy.gear_price(rarity, tier), Economy.gear_price(rarity, tier + 1))
	assert_eq(Economy.gear_price(EquipmentData.Rarity.COMMON, 1), 250, "Overnight Nov 7-8: the cheapest piece costs 250 (five Commons)")
	assert_gte(Economy.gear_price(EquipmentData.Rarity.UNCOMMON, 1), Economy.gear_price(EquipmentData.Rarity.COMMON, 4))
	assert_gt(Economy.gear_price(EquipmentData.Rarity.RARE, 1), Economy.gear_price(EquipmentData.Rarity.UNCOMMON, 4))
	for entry: EquipmentVendorEntry in EquipmentVendorScreen.default_stock().entries:
		assert_gte(entry.price, 250, "%s is a real purchase" % entry.equipment_id)
