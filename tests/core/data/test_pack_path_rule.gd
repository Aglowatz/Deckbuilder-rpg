extends GutTest
## Brief 16, Group H: a Path Pack or a Gilded Pack always contains at least one card from its Path (and keeps its other guarantees).

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _on_path(cards: Array[CardData], path: Affinity.Type) -> bool:
	for card: CardData in cards:
		if card.is_on_path(path):
			return true
	return false


func test_every_path_and_gilded_pack_holds_a_card_of_its_path_for_thousands_of_rolls() -> void:
	for path: Affinity.Type in Affinity.colored_types():
		for pack_id: String in [PackRules.path_pack_id(path), PackRules.gilded_pack_id(path)]:
			var pack: PackData = PackCatalog.find(pack_id)
			assert_not_null(pack)
			var misses: int = 0
			for seed_value: int in range(1500):
				var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
				if not _on_path(cards, path):
					misses += 1
			assert_eq(misses, 0, "%s: every roll has a card of its Path" % pack_id)


func test_gilded_packs_keep_their_epic_guarantee() -> void:
	for path: Affinity.Type in Affinity.colored_types():
		var pack: PackData = PackCatalog.find(PackRules.gilded_pack_id(path))
		for seed_value: int in range(800):
			var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
			var strong: bool = false
			for card: CardData in cards:
				strong = strong or card.rarity == CardEnums.Rarity.EPIC or card.rarity == CardEnums.Rarity.LEGENDARY
			assert_true(strong and _on_path(cards, path), "gilded %s seed %d: an Epic+ and a Path card" % [Affinity.display_name(path), seed_value])


func test_the_rule_rescues_a_pack_whose_pool_is_mostly_neutral() -> void:
	# A Path Pack whose odds only ever pick neutral cards still gets its Path card.
	var path: Affinity.Type = Affinity.Type.NECROCRAT
	var pack: PackData = PackCatalog.find(PackRules.path_pack_id(path)).duplicate() as PackData
	pack.pool_paths = [path] as Array[Affinity.Type]
	pack.include_neutral = true
	pack.card_count = 3
	var neutral_only_hits: int = 0
	for seed_value: int in range(600):
		var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
		assert_eq(cards.size(), 3)
		assert_true(_on_path(cards, path))
		var neutrals: int = 0
		for card: CardData in cards:
			if card.paths().is_empty():
				neutrals += 1
		if neutrals == 2:
			neutral_only_hits += 1
	assert_gt(neutral_only_hits, 0, "packs with two neutral cards still occur: the rule only fixes the all-neutral ones")


func test_a_one_card_gilded_pack_is_an_epic_card_of_its_path() -> void:
	var path: Affinity.Type = Affinity.Type.GOURMAND
	var pack: PackData = PackCatalog.find(PackRules.gilded_pack_id(path)).duplicate() as PackData
	pack.card_count = 1
	for seed_value: int in range(300):
		var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
		assert_eq(cards.size(), 1)
		assert_true(cards[0].is_on_path(path), "the single card is of the Path")
		assert_true(cards[0].rarity == CardEnums.Rarity.EPIC or cards[0].rarity == CardEnums.Rarity.LEGENDARY, "and Epic or better")


func test_other_pack_kinds_are_not_forced_onto_a_path() -> void:
	var prismatic: PackData = PackCatalog.find("prismatic")
	var general: PackData = PackCatalog.find("general_1")
	assert_false(prismatic.is_path_pack())
	assert_false(general.is_path_pack())
	# They still roll normally (no crash, right size).
	assert_eq(PackRoller.roll(prismatic, content, _rng(1)).size(), prismatic.card_count)
	assert_eq(PackRoller.roll(general, content, _rng(1)).size(), general.card_count)


func test_the_pack_doc_states_the_rule() -> void:
	var text: String = FileAccess.get_file_as_string("res://docs/design/packs.md")
	assert_true(text.contains("at least one card from its Path"), "docs/design/packs.md lists the Path guarantee")
