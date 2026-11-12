extends GutTest
## Fable Nov 12c (A1): the Hollow Well is an offer - "Sacrifice a random card from your deck for the rest of this dungeon: heal 4 HP."
## The card is back when the dungeon ends (won, lost or left); the player may leave it; nothing at full HP or with the smallest deck;
## once per run; a save taken mid-dungeon still holds the whole deck.

const NO_PIPS: Array[Affinity.Type] = []


func before_each() -> void:
	Session.new_game()


func after_all() -> void:
	Session.new_game()


func _rng(seed_value: int = 1) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _cards(count: int) -> Array[CardData]:
	var result: Array[CardData] = []
	for index: int in range(count):
		result.append(CardBuilder.unit("well_%d" % index, "Well Card %d" % index, Affinity.Type.BEEFCAKE, 1 + index % 4, NO_PIPS, 1, 1))
	return result


## A run of `count` distinct cards whose minimum deck size is `count - spare`.
func _run(count: int = 12, spare: int = 5) -> DungeonRun:
	var deck: Deck = Deck.new()
	deck.cards = _cards(count)
	var waiver: ModifierSource = ModifierSource.new()
	waiver.source_kind = ModifierSource.SourceKind.DUNGEON
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.MIN_DECK_SIZE
	modifier.value = (count - spare) - DeckValidator.MIN_DECK_SIZE
	waiver.modifiers = [modifier] as Array[Modifier]
	return DungeonRun.enter(PlayerProfile.new(), deck, [waiver] as Array[ModifierSource])


func _accept() -> ChallengeChoice:
	var choice: ChallengeChoice = ChallengeChoice.new()
	choice.accept = true
	return choice


func test_the_rule_and_the_data_file_agree() -> void:
	var well: ChallengeData = ChallengeExamples.hollow_well()
	assert_eq(well.kind, ChallengeData.Kind.RANDOM_SACRIFICE)
	assert_eq(ChallengeExamples.WELL_RULE, "Sacrifice a random card from your deck for the rest of this dungeon: heal 4 HP.")
	var saved: ChallengeData = load("res://data/encounters/challenges/hollow_well.tres") as ChallengeData
	assert_eq(saved.kind, ChallengeData.Kind.RANDOM_SACRIFICE, "the game loads the well from this file")
	assert_true(saved.on_failure.is_empty(), "an offer has no failure")
	assert_eq(ChallengeResolver.heal_preview(saved, null), 4)
	var kinds: Array[int] = []
	for outcome: ChallengeOutcome in saved.on_success:
		kinds.append(outcome.kind)
	assert_eq(kinds, [ChallengeOutcome.Kind.LOSE_CARD, ChallengeOutcome.Kind.HEAL] as Array[int])


func test_it_takes_one_random_card_and_heals_four() -> void:
	var run: DungeonRun = _run()
	run.lose_hp(6)
	var hp: int = run.hp
	var before: Array[CardData] = run.current_deck().cards.duplicate()
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.hollow_well(), run, _rng(), _accept())
	assert_true(result.success)
	assert_false(result.declined)
	assert_eq(result.lost_cards.size(), 1)
	assert_true(before.has(result.lost_cards[0]), "a card of the dungeon deck")
	assert_eq(run.current_deck().size(), before.size() - 1)
	assert_false(run.current_deck().cards.has(result.lost_cards[0]), "gone for the rest of the run")
	assert_eq(result.hp_healed, 4)
	assert_eq(run.hp, hp + 4)


func test_the_pick_is_random_over_the_whole_deck() -> void:
	var seen: Dictionary = {}
	for seed_value: int in range(1, 60):
		var run: DungeonRun = _run()
		run.lose_hp(5)
		var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.hollow_well(), run, _rng(seed_value), _accept())
		seen[result.lost_cards[0].id] = true
	assert_gt(seen.size(), 6, "many different cards over many seeds, not always the cheapest or the first")


func test_the_heal_is_capped_at_max_hp() -> void:
	var run: DungeonRun = _run()
	run.lose_hp(2)
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.hollow_well(), run, _rng(), _accept())
	assert_eq(result.hp_healed, 2)
	assert_eq(run.hp, run.max_hp())
	assert_eq(ChallengeResolver.heal_preview(ChallengeExamples.hollow_well(), run), 0, "nothing left to mend")


func test_the_card_is_back_when_the_run_ends() -> void:
	var run: DungeonRun = _run()
	run.lose_hp(5)
	var base: Array[CardData] = run.base_deck.cards.duplicate()
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.hollow_well(), run, _rng(), _accept())
	var taken: CardData = result.lost_cards[0]
	assert_eq(run.base_deck.cards, base, "the player's own deck is never touched")
	assert_true(run.deck_after_run().cards.has(taken), "the deck the run hands back holds it again")
	assert_eq(run.deck_after_run().size(), base.size())
	run.failed = true
	assert_true(run.deck_after_run().cards.has(taken), "after a loss too")


func test_leaving_it_changes_nothing() -> void:
	var run: DungeonRun = _run()
	run.lose_hp(5)
	var hp: int = run.hp
	var choice: ChallengeChoice = ChallengeChoice.new()
	choice.accept = false
	var result: ChallengeResult = ChallengeResolver.resolve(ChallengeExamples.hollow_well(), run, _rng(), choice)
	assert_true(result.declined)
	assert_eq(run.hp, hp)
	assert_eq(run.current_deck().size(), 12)
	assert_true(run.used_challenges.is_empty(), "leaving it does not use it up")


func test_full_hp_closes_the_offer() -> void:
	var run: DungeonRun = _run()
	var well: ChallengeData = ChallengeExamples.hollow_well()
	assert_eq(ChallengeResolver.offer_block(well, run), ChallengeResolver.Block.FULL_HP)
	assert_eq(ChallengeResolver.block_button_text(ChallengeResolver.Block.FULL_HP), "You're at full HP")
	var result: ChallengeResult = ChallengeResolver.resolve(well, run, _rng(), _accept())
	assert_true(result.declined, "pressing through takes nothing")
	assert_eq(run.current_deck().size(), 12)


func test_the_minimum_deck_size_closes_the_offer_and_says_why() -> void:
	var run: DungeonRun = _run(12, 0)
	run.lose_hp(5)
	var well: ChallengeData = ChallengeExamples.hollow_well()
	assert_eq(run.min_deck_size(), 12)
	assert_eq(ChallengeResolver.offer_block(well, run), ChallengeResolver.Block.MIN_DECK)
	assert_string_contains(ChallengeResolver.block_reason(ChallengeResolver.Block.MIN_DECK, run), "at least 12 cards")
	var result: ChallengeResult = ChallengeResolver.resolve(well, run, _rng(), _accept())
	assert_true(result.declined)
	assert_eq(run.current_deck().size(), 12)
	assert_eq(run.hp, run.max_hp() - 5)
	var roomy: DungeonRun = _run(12, 1)
	roomy.lose_hp(5)
	assert_eq(ChallengeResolver.offer_block(well, roomy), ChallengeResolver.Block.NONE, "one card over the minimum is enough")


func test_once_per_dungeon_run() -> void:
	var run: DungeonRun = _run()
	run.lose_hp(9)
	var well: ChallengeData = ChallengeExamples.hollow_well()
	assert_true(ChallengeResolver.resolve(well, run, _rng(), _accept()).success)
	assert_eq(ChallengeResolver.offer_block(well, run), ChallengeResolver.Block.USED)
	var again: ChallengeResult = ChallengeResolver.resolve(well, run, _rng(2), _accept())
	assert_true(again.declined)
	assert_eq(run.current_deck().size(), 11, "one card, not two")
	var fresh: DungeonRun = _run()
	fresh.lose_hp(9)
	assert_eq(ChallengeResolver.offer_block(well, fresh), ChallengeResolver.Block.NONE, "a new run of the dungeon offers it again")


func test_the_old_tests_helpers_say_nothing_for_an_offer() -> void:
	var well: ChallengeData = ChallengeExamples.hollow_well()
	assert_eq(ChallengeResolver.rule_text(well), "")
	assert_eq(ChallengeResolver.explain(well, ChallengeResult.new()), "")


# ---- The session: the tutorial's first clear, leaving, and a save taken mid-dungeon ------------------------------------------


func _well() -> ChallengeData:
	for candidate: ChallengeData in Session.content.challenges:
		if candidate.id == TrialOfTheHollow.CHALLENGE_ID:
			return candidate
	return null


func _enter_cave() -> void:
	Session.choose_starting_path(Affinity.Type.BEEFCAKE)
	Session.dungeon_map = TrialOfTheHollow.build_map()
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [TrialOfTheHollow.deck_size_waiver()] as Array[ModifierSource])


func test_clearing_the_cave_gives_the_card_back() -> void:
	_enter_cave()
	var ids: Array[String] = DeckBox.ids_of(Session.deck)
	Session.run.lose_hp(5)
	var result: ChallengeResult = ChallengeResolver.resolve(_well(), Session.run, _rng(), _accept())
	assert_eq(result.lost_cards.size(), 1)
	assert_eq(Session.run.current_deck().size(), ids.size() - 1, "the fights that follow are played without it")
	Session.complete_trial()
	var after: Array[String] = DeckBox.ids_of(Session.deck)
	ids.sort()
	after.sort()
	assert_eq(after, ids, "the deck that walks into Crosspath holds every card, the well's included")


func test_leaving_or_losing_the_cave_gives_the_card_back() -> void:
	_enter_cave()
	var ids: Array[String] = DeckBox.ids_of(Session.deck)
	Session.run.lose_hp(5)
	ChallengeResolver.resolve(_well(), Session.run, _rng(), _accept())
	Session.run.failed = true
	Session.run = null  # what `abandon_run` does with it (it then changes scene)
	Session.dungeon_map = null
	assert_eq(DeckBox.ids_of(Session.deck), ids, "the deck is whole")
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [TrialOfTheHollow.deck_size_waiver()] as Array[ModifierSource])
	Session.run.lose_hp(5)
	assert_eq(ChallengeResolver.offer_block(_well(), Session.run), ChallengeResolver.Block.NONE, "and the next run's well is open again")


func test_a_save_taken_mid_dungeon_resumes_with_the_whole_deck() -> void:
	_enter_cave()
	var ids: Array[String] = DeckBox.ids_of(Session.deck)
	Session.run.lose_hp(5)
	ChallengeResolver.resolve(_well(), Session.run, _rng(), _accept())
	var saved: Dictionary = Session.to_dict().duplicate(true)
	Session.new_game()
	assert_true(Session.from_dict(saved))
	assert_eq(DeckBox.ids_of(Session.deck), ids, "the saved deck never lost the card")
	assert_null(Session.run, "a dungeon run is not saved: the cave starts again from its mouth, the well with it")
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [TrialOfTheHollow.deck_size_waiver()] as Array[ModifierSource])
	assert_eq(Session.run.current_deck().size(), ids.size())
	assert_true(Session.run.used_challenges.is_empty())


func test_the_screen_words() -> void:
	var screen: ChallengeScreen = ChallengeScreen.new()
	screen.challenge = ChallengeExamples.hollow_well()
	assert_true(screen.is_offer())
	assert_eq(screen.offer_rule_text(), ChallengeExamples.WELL_RULE)
	var card: CardData = _cards(1)[0]
	assert_eq(screen.taken_text(card), "The well takes Well Card 0. It returns when you leave the cave.")
	screen.free()
