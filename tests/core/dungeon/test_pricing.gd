extends GutTest


func test_prices_scale_with_rarity_and_cost() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var sellsword: CardData = content.card("C-01")
	var colossus: CardData = content.card("R-33")
	assert_true(CardPricing.price(colossus) > CardPricing.price(sellsword))
	assert_eq(CardPricing.price(sellsword), 15 + sellsword.energy_value() * 5)


func test_sale_limits() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	assert_true(CardPricing.is_for_sale(content.card("B-03"), 0))
	assert_false(CardPricing.is_for_sale(content.card("B-03"), 3))
	assert_false(CardPricing.is_for_sale(content.card("T-16"), 0))
