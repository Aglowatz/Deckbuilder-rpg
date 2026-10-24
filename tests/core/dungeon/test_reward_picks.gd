extends GutTest
## Overnight Oct 23, Part 4: the themed card pick after an elite or boss (RewardPicks).

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func test_three_distinct_cards_never_a_legendary_and_no_early_epic_from_an_elite() -> void:
	for seed_value: int in range(1, 40):
		var picks: Array[CardData] = RewardPicks.choose(content, _rng(seed_value), [Affinity.Type.BEEFCAKE] as Array[Affinity.Type], Affinity.Type.GOURMAND, 4, false, false)
		assert_eq(picks.size(), 3)
		var ids: Dictionary = {}
		for card: CardData in picks:
			ids[card.id] = true
			assert_ne(card.rarity, CardEnums.Rarity.LEGENDARY, "Legendaries stay the bosses' prizes")
			assert_ne(card.rarity, CardEnums.Rarity.EPIC, "no Epics from an elite before level %d" % RewardPicks.EPIC_LEVEL)
			assert_false(card.is_infrastructure())
		assert_eq(ids.size(), 3, "no repeats")


func test_picks_lean_to_the_encounters_paths() -> void:
	var on_theme: int = 0
	var total: int = 0
	for seed_value: int in range(1, 60):
		for card: CardData in RewardPicks.choose(content, _rng(seed_value), [Affinity.Type.REFUSEMANCER] as Array[Affinity.Type], Affinity.Type.BEEFCAKE, 12, true, false):
			total += 1
			if card.is_on_path(Affinity.Type.REFUSEMANCER) or card.is_on_path(Affinity.Type.BEEFCAKE):
				on_theme += 1
	assert_gt(float(on_theme) / float(total), 0.6, "most picks are on the foe's or the player's Path")


func test_two_path_cards_only_when_their_paths_fit() -> void:
	var gb: CardData = content.card("GB-01")
	var paths_gb: Array[Affinity.Type] = [Affinity.Type.GOURMAND, Affinity.Type.BEEFCAKE]
	assert_gt(RewardPicks.path_weight(gb, paths_gb, Affinity.Type.NECROCRAT), 0.0, "a Gourmand-Beefcake foe can offer its two-Path cards")
	assert_eq(RewardPicks.path_weight(gb, [Affinity.Type.NECROCRAT] as Array[Affinity.Type], Affinity.Type.REFUSEMANCER), 0.0, "never off-theme two-Path cards")


func test_a_repeat_fight_offers_two_mostly_common_cards() -> void:
	var picks: Array[CardData] = RewardPicks.choose(content, _rng(5), [Affinity.Type.NECROCRAT] as Array[Affinity.Type], Affinity.Type.NECROCRAT, 20, true, true)
	assert_eq(picks.size(), RewardPicks.REPEAT_COUNT)
	for card: CardData in picks:
		assert_true(card.rarity == CardEnums.Rarity.COMMON or card.rarity == CardEnums.Rarity.UNCOMMON)


func test_capped_cards_are_left_out_while_others_remain() -> void:
	var owned: Dictionary = {}
	var caps: Dictionary = {}
	for card: CardData in content.cards.values():
		if card.is_on_path(Affinity.Type.BEEFCAKE) and card.rarity == CardEnums.Rarity.COMMON:
			owned[card.id] = 3
			caps[card.id] = 3
	for seed_value: int in range(1, 20):
		for card: CardData in RewardPicks.choose(content, _rng(seed_value), [Affinity.Type.BEEFCAKE] as Array[Affinity.Type], Affinity.Type.BEEFCAKE, 6, false, false, owned, caps):
			assert_false(owned.has(card.id), "%s is at its cap" % card.id)


func test_deck_paths_reads_the_foes_paths() -> void:
	var deck: Deck = ZoneDecks.from_recipe(content, "test", EnemyDecks.recipe("gourmand_beefcake", 16))
	var paths: Array[Affinity.Type] = RewardPicks.deck_paths(deck)
	assert_true(paths.has(Affinity.Type.GOURMAND))
	assert_true(paths.has(Affinity.Type.BEEFCAKE))
