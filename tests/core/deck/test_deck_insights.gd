extends GutTest
## Overnight Oct 30-31, Part 7: the Deck Station's reads - the cost curve, the Path mix, the type counts, "works well with" from the rules
## (a Resource maker and a Resource user), and "Suggest a deck" (legal size, copy caps, owned copies only, the chosen Paths only).

const NO_PIPS: Array[Affinity.Type] = []


func _unit(id: String, cost: int, path: Affinity.Type = Affinity.Type.BEEFCAKE, rules: String = "", rarity: CardEnums.Rarity = CardEnums.Rarity.COMMON) -> CardData:
	var card: CardData = CardBuilder.unit(id, id, path, cost, NO_PIPS, 2, 2)
	card.rules_text = rules
	card.rarity = rarity
	return card


func _infra(path: Affinity.Type) -> CardData:
	return GameFactory.infra(path)


func test_curve_mix_and_types() -> void:
	var cards: Array[CardData] = [_unit("a", 1), _unit("b", 2), _unit("c", 2), _unit("d", 9), _infra(Affinity.Type.BEEFCAKE)]
	var curve: Array[int] = DeckInsights.cost_curve(cards)
	assert_eq(curve.size(), DeckInsights.CURVE_BUCKETS)
	assert_eq(curve[1], 1)
	assert_eq(curve[2], 2)
	assert_eq(curve[DeckInsights.CURVE_BUCKETS - 1], 1, "9 goes in 7+")
	var sum: int = 0
	for value: int in curve:
		sum += value
	assert_eq(sum, 4, "Infrastructure is not on the curve")
	assert_eq(int(DeckInsights.path_mix(cards).get(int(Affinity.Type.BEEFCAKE), 0)), 5)
	var types: Dictionary = DeckInsights.type_counts(cards)
	assert_eq(int(types.get(int(CardEnums.CardType.UNIT), 0)), 4)
	assert_eq(int(types.get("infrastructure", 0)), 1)


func test_a_resource_maker_goes_with_a_resource_user() -> void:
	var maker: CardData = _unit("maker", 2, Affinity.Type.BEEFCAKE, "When this enters, create an Iron.")
	var user: CardData = _unit("user", 3, Affinity.Type.BEEFCAKE, "Spend an Iron: this gets +2/+0.")
	var plain: CardData = _unit("plain", 2)
	assert_true(DeckInsights.themes(maker).has("make:iron"))
	assert_true(DeckInsights.themes(user).has("use:iron"))
	var partners: Array[Dictionary] = DeckInsights.works_well_with(maker, [user, plain] as Array[CardData])
	assert_eq(partners.size(), 1, "only a real reason counts")
	assert_eq((partners[0]["card"] as CardData).id, "user")
	assert_string_contains(str(partners[0]["why"]), "Iron")


func test_suggest_builds_a_legal_deck_from_owned_copies() -> void:
	var owned: Array[CardData] = []
	for index: int in range(30):
		var card: CardData = _unit("b%d" % index, 1 + index % 5)
		owned.append(card)
		owned.append(card)  # two copies of each
	var other: CardData = _unit("n0", 2, Affinity.Type.NECROCRAT)
	owned.append(other)
	var epic: CardData = _unit("epic", 4, Affinity.Type.BEEFCAKE, "", CardEnums.Rarity.EPIC)
	for _copy: int in range(4):
		owned.append(epic)
	var infra: Array[CardData] = [_infra(Affinity.Type.BEEFCAKE), _infra(Affinity.Type.NECROCRAT)]
	var level: int = 5
	var deck: Deck = DeckInsights.suggest(owned, [Affinity.Type.BEEFCAKE] as Array[Affinity.Type], level, infra, 45)
	assert_eq(deck.size(), 45)
	assert_eq(deck.count_of("n0"), 0, "only the chosen Path (and Colorless)")
	assert_eq(deck.count_of("epic"), CopyCaps.for_card(epic, level), "an Epic in, up to its cap")
	for card: CardData in deck.cards:
		if card.is_infrastructure():
			assert_eq(card.color, Affinity.Type.BEEFCAKE, "Infrastructure of the chosen Path")
			continue
		var copies: int = 0
		for owned_card: CardData in owned:
			if owned_card.id == card.id:
				copies += 1
		assert_true(deck.count_of(card.id) <= copies, "%s: never more than owned" % card.id)
		assert_true(deck.count_of(card.id) <= CopyCaps.for_card(card, level), "%s: within the cap" % card.id)
	var infra_count: int = 0
	for card: CardData in deck.cards:
		if card.is_infrastructure():
			infra_count += 1
	assert_almost_eq(infra_count, 19, 2, "about the starters' share of Infrastructure")


func test_suggest_with_two_paths_splits_the_infrastructure() -> void:
	var owned: Array[CardData] = []
	for index: int in range(15):
		var b: CardData = _unit("b%d" % index, 2)
		b.colored_pips = [Affinity.Type.BEEFCAKE] as Array[Affinity.Type]
		var n: CardData = _unit("n%d" % index, 2, Affinity.Type.NECROCRAT)
		n.colored_pips = [Affinity.Type.NECROCRAT] as Array[Affinity.Type]
		owned.append_array([b, b, n, n])
	var infra: Array[CardData] = [_infra(Affinity.Type.BEEFCAKE), _infra(Affinity.Type.NECROCRAT)]
	var deck: Deck = DeckInsights.suggest(owned, [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT] as Array[Affinity.Type], 8, infra, 45)
	assert_eq(deck.size(), 45)
	var by_path: Dictionary = {}
	for card: CardData in deck.cards:
		if card.is_infrastructure():
			by_path[int(card.color)] = int(by_path.get(int(card.color), 0)) + 1
	assert_eq(by_path.size(), 2, "both Paths get Infrastructure")
