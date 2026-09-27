extends GutTest


func test_prices_scale_with_rarity_and_cost() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var sellsword: CardData = content.card("sellsword")
	var colossus: CardData = content.card("thornback_colossus")
	assert_true(CardPricing.price(colossus) > CardPricing.price(sellsword))
	assert_eq(CardPricing.price(sellsword), 15 + 2 * 5)


func test_sale_limits() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	assert_true(CardPricing.is_for_sale(content.card("firebolt"), 0))
	assert_false(CardPricing.is_for_sale(content.card("firebolt"), 3))
	assert_false(CardPricing.is_for_sale(content.card("token_spirit"), 0))
