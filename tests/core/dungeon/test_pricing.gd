extends GutTest


func test_prices_scale_with_rarity_and_cost() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var sellsword: CardData = content.card("C-01")
	var colossus: CardData = content.card("R-33")
	assert_true(CardPricing.price(colossus) > CardPricing.price(sellsword))
	assert_eq(CardPricing.price(sellsword), Economy.card_price(sellsword.rarity), "Oct 29: priced by rarity alone")
	assert_eq(CardPricing.price(colossus), 300)


func test_sale_limits() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	assert_true(CardPricing.is_for_sale(content.card("B-03"), 0))
	assert_false(CardPricing.is_for_sale(content.card("B-03"), 3))
	assert_false(CardPricing.is_for_sale(content.card("T-16"), 0))
