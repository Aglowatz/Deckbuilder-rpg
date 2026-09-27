extends GutTest

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func test_one_offer_per_affinity_in_order() -> void:
	var offers: Array[StartingDecks.Offer] = StartingDecks.offers(_content)
	assert_eq(offers.size(), Affinity.colored_types().size())
	for index: int in range(offers.size()):
		assert_eq(offers[index].affinity, Affinity.colored_types()[index])


func test_every_offer_has_text_and_key_cards_of_its_own_color() -> void:
	for offer: StartingDecks.Offer in StartingDecks.offers(_content):
		assert_true(not offer.deck_name.is_empty(), "deck_name")
		assert_true(not offer.identity.is_empty(), "identity")
		assert_true(not offer.playstyle.is_empty(), "playstyle")
		assert_false(offer.key_cards.is_empty(), "key_cards")
		for card: CardData in offer.key_cards:
			assert_eq(card.color, offer.affinity, "%s should be %s" % [card.id, Affinity.display_name(offer.affinity)])


func test_offer_for_matches_offers_and_is_null_for_neutral() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		assert_eq(StartingDecks.offer_for(_content, color).deck_name, StartingDecks.deck_for(_content, color).deck_name)
	assert_null(StartingDecks.offer_for(_content, Affinity.Type.NEUTRAL))
	assert_null(StartingDecks.deck_for(_content, Affinity.Type.NEUTRAL))


func test_deck_for_is_a_legal_45_card_two_color_deck() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		var deck: Deck = StartingDecks.deck_for(_content, color)
		assert_eq(deck.size(), 45, Affinity.display_name(color))
		assert_true(deck.colors().has(color), "the deck's primary color is among its colors")
		var profile: PlayerProfile = PlayerProfile.new()
		profile.owned_cards = deck.cards.duplicate()
		assert_true(DeckValidator.is_valid(deck, profile, null, true), Affinity.display_name(color))


func test_key_cards_are_actually_in_their_deck() -> void:
	for offer: StartingDecks.Offer in StartingDecks.offers(_content):
		var deck: Deck = StartingDecks.deck_for(_content, offer.affinity)
		for card: CardData in offer.key_cards:
			assert_true(deck.cards.has(card), "%s should be in %s" % [card.id, deck.deck_name])


func test_deck_for_returns_an_independent_copy_each_time() -> void:
	var first: Deck = StartingDecks.deck_for(_content, Affinity.Type.A)
	var second: Deck = StartingDecks.deck_for(_content, Affinity.Type.A)
	assert_ne(first, second)
	first.cards.clear()
	assert_eq(second.size(), 45, "clearing one copy must not affect another or the library deck")
