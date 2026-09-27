extends GutTest

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func test_one_offer_per_affinity_in_order() -> void:
	var offers: Array[ElementChoice.Offer] = ElementChoice.offers(_content)
	assert_eq(offers.size(), Affinity.colored_types().size())
	for index: int in range(offers.size()):
		assert_eq(offers[index].affinity, Affinity.colored_types()[index])


func test_every_offer_has_text_and_sample_cards_of_its_own_color() -> void:
	for offer: ElementChoice.Offer in ElementChoice.offers(_content):
		assert_true(not offer.identity.is_empty(), "identity")
		assert_true(not offer.playstyle.is_empty(), "playstyle")
		assert_false(offer.sample_cards.is_empty(), "sample_cards")
		for card: CardData in offer.sample_cards:
			assert_eq(card.color, offer.affinity, "%s should be %s" % [card.id, Affinity.display_name(offer.affinity)])


func test_offer_for_matches_offers_and_is_null_for_neutral() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		assert_eq(ElementChoice.offer_for(_content, color).affinity, color)
	assert_null(ElementChoice.offer_for(_content, Affinity.Type.NEUTRAL))
