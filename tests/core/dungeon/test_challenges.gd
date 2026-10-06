extends GutTest

const NO_PIPS: Array[Affinity.Type] = []


func _rng(seed_value: int = 1) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _unit(attack: int, cost: int = 2, id: String = "") -> CardData:
	var name: String = id if id != "" else "cr_%d_%d" % [attack, cost]
	return CardBuilder.unit(name, name, Affinity.Type.BEEFCAKE, cost, NO_PIPS, attack, attack)


func _spell(cost: int = 2, id: String = "sp") -> CardData:
	return CardBuilder.spell("%s_%d" % [id, cost], id, Affinity.Type.BEEFCAKE, cost, NO_PIPS)


func _run(cards: Array[CardData]) -> DungeonRun:
	var deck: Deck = Deck.new()
	deck.cards = cards
	return DungeonRun.enter(PlayerProfile.new(), deck)


func _repeat(card: CardData, count: int) -> Array[CardData]:
	var result: Array[CardData] = []
	for i: int in range(count):
		result.append(card)
	return result


func _pool() -> Array[CardData]:
	return [_spell(1, "reward_a"), _spell(2, "reward_b")] as Array[CardData]


# ---- Test of Might: first unit attack ---------------------------------------------


func test_first_unit_power_success_grants_boon() -> void:
	var run: DungeonRun = _run(_repeat(_unit(4), 10))
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.test_of_might(), run, _rng())
	assert_true(result.success)
	assert_eq(result.revealed.size(), 1)
	assert_eq(result.boons.size(), 1)
	assert_eq(run.max_hp(), 12)
	assert_eq(run.hp, 12)


func test_first_unit_power_failure_costs_hp() -> void:
	var run: DungeonRun = _run(_repeat(_unit(1), 10))
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.test_of_might(), run, _rng())
	assert_false(result.success)
	assert_eq(result.hp_lost, 3)
	assert_eq(run.hp, 7)


func test_first_unit_skips_non_units_when_revealing() -> void:
	var cards: Array[CardData] = _repeat(_spell(), 6)
	cards.append(_unit(5))
	var run: DungeonRun = _run(cards)
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.test_of_might(), run, _rng(3))
	assert_true(result.success)
	assert_eq(result.revealed.back().id, "cr_5_2")
	assert_true(result.revealed.size() >= 1)


func test_first_unit_with_no_units_in_deck_fails() -> void:
	var run: DungeonRun = _run(_repeat(_spell(), 5))
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.test_of_might(), run, _rng())
	assert_false(result.success)
	assert_eq(result.revealed.size(), 5)


# ---- Hollow Well: infrastructure count ---------------------------------------------------------


func test_top_five_infrastructure_count_success_heals() -> void:
	var run: DungeonRun = _run(_repeat(CardBuilder.infra(Affinity.Type.BEEFCAKE), 10))
	run.lose_hp(6)
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.hollow_well(), run, _rng())
	assert_true(result.success)
	assert_eq(result.revealed.size(), 5)
	assert_eq(result.hp_healed, 4)
	assert_eq(run.hp, 8)


func test_top_five_infrastructure_count_failure_loses_the_priciest_revealed_card() -> void:
	var cards: Array[CardData] = _repeat(_unit(3, 4, "pricey"), 3)
	cards.append_array(_repeat(_unit(1, 1, "cheap"), 3))
	var run: DungeonRun = _run(cards)
	var before: int = run.current_deck().size()
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.hollow_well(), run, _rng())
	assert_false(result.success)
	assert_eq(result.lost_cards.size(), 1)
	assert_eq(run.current_deck().size(), before - 1)
	var priciest: int = 0
	for card: CardData in result.revealed:
		priciest = maxi(priciest, card.energy_value())
	assert_eq(result.lost_cards[0].energy_value(), priciest)


func test_lose_card_never_takes_basic_infrastructure() -> void:
	var cards: Array[CardData] = _repeat(CardBuilder.infra(Affinity.Type.BEEFCAKE), 3)
	var challenge: ChallengeData = ChallengeExamples.hollow_well()
	challenge.threshold = 99
	var run: DungeonRun = _run(cards)
	var outcome: ChallengeResult = ChallengeResolver.resolve(challenge, run, _rng())
	assert_eq(outcome.lost_cards.size(), 0)
	assert_eq(run.current_deck().size(), 3)


# ---- Scholar's Riddle: type count ----------------------------------------------------


func test_type_count_success_gains_a_card_from_the_pool() -> void:
	var run: DungeonRun = _run(_repeat(_spell(), 10))
	var pool: Array[CardData] = _pool()
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.scholars_riddle(pool), run, _rng())
	assert_true(result.success)
	assert_eq(result.gained_cards.size(), 1)
	assert_true(pool.has(result.gained_cards[0]))
	assert_eq(run.current_deck().size(), 11)


func test_type_count_failure_loses_hp() -> void:
	var run: DungeonRun = _run(_repeat(_unit(1), 10))
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.scholars_riddle(_pool()), run, _rng())
	assert_false(result.success)
	assert_eq(run.hp, 8)


# ---- Weighing Scale: total cost ------------------------------------------------------


func test_total_cost_threshold() -> void:
	var heavy: DungeonRun = _run(_repeat(_unit(2, 4), 10))
	var win: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.weighing_scale(), heavy, _rng())
	assert_true(win.success)
	assert_eq(heavy.max_hp(), 10)
	assert_eq(heavy.modifiers().sum(Modifier.Kind.MAX_HAND_SIZE), 1)
	var light: DungeonRun = _run(_repeat(_unit(1, 1), 10))
	var lose: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.weighing_scale(), light, _rng())
	assert_false(lose.success)
	assert_eq(light.hp, 8)


# ---- Altar of Sacrifice: choose a card -----------------------------------------------


func test_sacrifice_uses_the_players_choice() -> void:
	var keep: CardData = _unit(5, 5, "keep")
	var give: CardData = _unit(1, 1, "give")
	var cards: Array[CardData] = [keep, give, keep]
	var run: DungeonRun = _run(cards)
	var choice: ChallengeChoice = ChallengeChoice.new()
	choice.sacrifice_card = keep
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.altar_of_sacrifice(), run, _rng(), choice)
	assert_true(result.success)
	assert_eq(result.lost_cards, [keep] as Array[CardData])
	assert_eq(run.current_deck().count_of("keep"), 1)
	assert_eq(run.max_hp(), 13)
	assert_eq(run.hp, 13)


func test_sacrifice_defaults_to_the_cheapest_non_basic_card() -> void:
	var cards: Array[CardData] = [_unit(5, 5, "big"), _unit(1, 1, "small"), CardBuilder.infra(Affinity.Type.BEEFCAKE)]
	var run: DungeonRun = _run(cards)
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.altar_of_sacrifice(), run, _rng())
	assert_eq(result.lost_cards[0].id, "small")


func test_sacrifice_of_a_card_not_in_the_deck_falls_back_to_default() -> void:
	var run: DungeonRun = _run([_unit(2, 2, "only")] as Array[CardData])
	var choice: ChallengeChoice = ChallengeChoice.new()
	choice.sacrifice_card = _unit(9, 9, "ghost")
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.altar_of_sacrifice(), run, _rng(), choice)
	assert_eq(result.lost_cards[0].id, "only")


func test_sacrifice_with_nothing_to_give_fails_without_outcomes() -> void:
	var run: DungeonRun = _run(_repeat(CardBuilder.infra(Affinity.Type.BEEFCAKE), 3))
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.altar_of_sacrifice(), run, _rng())
	assert_false(result.success)
	assert_eq(result.outcomes.size(), 0)


# ---- Toll Keeper: pay HP -----------------------------------------------------------


func test_pay_hp_accepted_gains_card_and_loses_hp() -> void:
	var run: DungeonRun = _run(_repeat(_unit(1), 5))
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.toll_keeper(_pool()), run, _rng())
	assert_true(result.success)
	assert_eq(run.hp, 6)
	assert_eq(result.gained_cards.size(), 1)


func test_pay_hp_declined_does_nothing() -> void:
	var run: DungeonRun = _run(_repeat(_unit(1), 5))
	var choice: ChallengeChoice = ChallengeChoice.new()
	choice.accept = false
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.toll_keeper(_pool()), run, _rng(), choice)
	assert_true(result.declined)
	assert_false(result.success)
	assert_eq(run.hp, 10)
	assert_eq(run.current_deck().size(), 5)


func test_pay_hp_cannot_be_afforded_at_low_hp() -> void:
	var run: DungeonRun = _run(_repeat(_unit(1), 5))
	run.lose_hp(6)
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.toll_keeper(_pool()), run, _rng())
	assert_true(result.declined, "4 HP left; cannot pay 4 and survive")
	assert_eq(run.hp, 4)
	assert_false(run.failed)


# ---- Data -----------------------------------------------------------------------------


func test_six_examples_cover_every_challenge_kind() -> void:
	var examples: Array[ChallengeData] = ChallengeExamples.all(_pool())
	assert_eq(examples.size(), 6)
	var kinds: Dictionary = {}
	for challenge: ChallengeData in examples:
		kinds[challenge.kind] = true
		assert_ne(challenge.id, "")
		assert_true(challenge.on_success.size() > 0)
	assert_eq(kinds.size(), 6)


func test_challenges_round_trip_through_tres() -> void:
	var path: String = "user://test_challenge.tres"
	var challenge: ChallengeData = ChallengeExamples.test_of_might()
	assert_eq(ResourceSaver.save(challenge, path), OK)
	var loaded: ChallengeData = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as ChallengeData
	assert_eq(loaded.id, "test_of_might")
	assert_eq(loaded.on_success[0].boon.modifiers[0].value, 2)
	var run: DungeonRun = _run(_repeat(_unit(4), 5))
	assert_true(ChallengeResolver.resolve(loaded, run, _rng()).success)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_results_are_deterministic_for_a_seed() -> void:
	var cards: Array[CardData] = []
	for i: int in range(20):
		cards.append(_unit(i % 6, 2, "c%d" % i))
	var first: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.test_of_might(), _run(cards), _rng(7))
	var second: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.test_of_might(), _run(cards), _rng(7))
	assert_eq(first.revealed.size(), second.revealed.size())
	assert_eq(first.revealed.back().id, second.revealed.back().id)
