extends GutTest


func test_offers_distinct_cards() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var profile: PlayerProfile = CampaignStart.new_profile(content, Affinity.Type.B)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	for i: int in range(30):
		var cards: Array[CardData] = RewardGenerator.card_choices(content, profile, rng, 3)
		assert_eq(cards.size(), 3)
		assert_ne(cards[0].id, cards[1].id)
		assert_ne(cards[1].id, cards[2].id)
		assert_ne(cards[0].id, cards[2].id)
		for card: CardData in cards:
			assert_false(card.is_token or card.is_land())


func test_favours_primary_color_and_neutral() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var profile: PlayerProfile = CampaignStart.new_profile(content, Affinity.Type.C)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	var favoured: int = 0
	var total: int = 0
	for i: int in range(200):
		for card: CardData in RewardGenerator.card_choices(content, profile, rng, 3):
			total += 1
			if card.color == Affinity.Type.C or card.color == Affinity.Type.NEUTRAL:
				favoured += 1
	assert_true(float(favoured) / float(total) > 0.6, "favoured share %f" % (float(favoured) / float(total)))


func test_deterministic_for_seed() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var profile: PlayerProfile = CampaignStart.new_profile(content, Affinity.Type.A)
	var a: RandomNumberGenerator = RandomNumberGenerator.new()
	a.seed = 5
	var b: RandomNumberGenerator = RandomNumberGenerator.new()
	b.seed = 5
	var first: Array[CardData] = RewardGenerator.card_choices(content, profile, a)
	var second: Array[CardData] = RewardGenerator.card_choices(content, profile, b)
	for index: int in range(3):
		assert_eq(first[index].id, second[index].id)
