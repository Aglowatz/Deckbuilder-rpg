extends GutTest

var _content: ContentSet
var _defined: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()
	_defined = ContentDefinitions.build()


func _count_color(color: Affinity.Type) -> int:
	var count: int = 0
	for card: CardData in _content.cards.values():
		if card.color == color:
			count += 1
	return count


# ---- The generated .tres content -----------------------------------------------------


func test_forty_placeholder_cards_split_by_color() -> void:
	assert_eq(_content.cards.size(), 40)
	assert_eq(_count_color(Affinity.Type.NEUTRAL), 10)
	assert_eq(_count_color(Affinity.Type.A), 8)
	assert_eq(_count_color(Affinity.Type.B), 8)
	assert_eq(_count_color(Affinity.Type.C), 7)
	assert_eq(_count_color(Affinity.Type.D), 7)


func test_basic_lands_for_every_color_and_a_token() -> void:
	assert_eq(_content.lands.size(), 4, "one basic land per color, no neutral land")
	for color: Affinity.Type in Affinity.colored_types():
		var land: CardData = _content.lands[int(color)]
		assert_true(land.is_land())
		assert_true(land.is_basic)
		assert_eq(land.color, color)
	assert_eq(_content.tokens.size(), 1)
	assert_true(_content.card("token_spirit").is_token)


func test_saved_files_match_the_code_definitions() -> void:
	assert_eq(_content.cards.size(), _defined.cards.size())
	for id: Variant in _defined.cards.keys():
		assert_true(_content.cards.has(id), "missing .tres for %s (run tools/generate_content.gd)" % id)
		var defined: CardData = _defined.cards[id]
		var saved: CardData = _content.cards[id]
		assert_eq(saved.display_name, defined.display_name)
		assert_eq(saved.color, defined.color)
		assert_eq(saved.generic_cost, defined.generic_cost)
		assert_eq(saved.colored_pips, defined.colored_pips)
		assert_eq(saved.power, defined.power)
		assert_eq(saved.toughness, defined.toughness)
		assert_eq(saved.keywords, defined.keywords)
		assert_eq(saved.effects.size(), defined.effects.size())
	assert_eq(_content.decks.size(), _defined.decks.size())
	assert_eq(_content.challenges.size(), 6)
	assert_eq(_content.personalities.size(), 4)


func test_every_card_is_well_formed() -> void:
	for card: CardData in _content.cards.values():
		assert_ne(card.id, "")
		assert_ne(card.display_name, "")
		for pip: Affinity.Type in card.colored_pips:
			assert_eq(pip, card.color, "%s pips must match its color" % card.id)
		if card.color == Affinity.Type.NEUTRAL:
			assert_eq(card.colored_pips.size(), 0, "neutral cards cost generic mana only")
		if not card.effects.is_empty() or not card.keywords.is_empty():
			assert_ne(card.rules_text, "", "%s needs rules text" % card.id)
		if card.is_creature():
			assert_gt(card.toughness, 0)
		assert_ne(card.type, CardEnums.CardType.LAND)


func test_each_color_uses_its_identity_keywords() -> void:
	var has: Callable = func(color: Affinity.Type, keyword: CardEnums.Keyword) -> bool:
		for card: CardData in _content.cards.values():
			if card.color == color and card.has_keyword(keyword):
				return true
		return false
	assert_true(has.call(Affinity.Type.A, CardEnums.Keyword.HASTE))
	assert_true(has.call(Affinity.Type.A, CardEnums.Keyword.FIRST_STRIKE))
	assert_true(has.call(Affinity.Type.B, CardEnums.Keyword.FLYING))
	assert_true(has.call(Affinity.Type.B, CardEnums.Keyword.REACH))
	assert_true(has.call(Affinity.Type.C, CardEnums.Keyword.TRAMPLE))
	assert_true(has.call(Affinity.Type.C, CardEnums.Keyword.GUARD))
	assert_true(has.call(Affinity.Type.D, CardEnums.Keyword.LIFESTEAL))
	assert_true(has.call(Affinity.Type.NEUTRAL, CardEnums.Keyword.FLYING))


func test_content_covers_every_keyword_trigger_and_operation_family() -> void:
	var keywords: Dictionary = {}
	var triggers: Dictionary = {}
	var ops: Dictionary = {}
	for card: CardData in _content.cards.values():
		for keyword: CardEnums.Keyword in card.keywords:
			keywords[keyword] = true
		for effect: EffectData in card.effects:
			triggers[effect.trigger] = true
			ops[effect.op] = true
	assert_eq(keywords.size(), CardEnums.Keyword.size(), "all 8 keywords appear on some card")
	for trigger: CardEnums.Trigger in [
		CardEnums.Trigger.ON_ENTER, CardEnums.Trigger.ON_DEATH, CardEnums.Trigger.ON_ATTACK,
		CardEnums.Trigger.START_OF_TURN, CardEnums.Trigger.TRAP_OPPONENT_ATTACKS, CardEnums.Trigger.TRAP_OPPONENT_CREATURE,
	]:
		assert_true(triggers.has(trigger), "trigger %d used" % trigger)
	for op: CardEnums.EffectOp in [
		CardEnums.EffectOp.DEAL_DAMAGE, CardEnums.EffectOp.DRAW, CardEnums.EffectOp.DISCARD, CardEnums.EffectOp.DESTROY,
		CardEnums.EffectOp.BUFF, CardEnums.EffectOp.SUMMON_TOKEN, CardEnums.EffectOp.RETURN_TO_HAND,
		CardEnums.EffectOp.GAIN_LIFE, CardEnums.EffectOp.LOSE_LIFE,
	]:
		assert_true(ops.has(op), "operation %d used" % op)


# ---- Decks -----------------------------------------------------------------------------


func test_five_sample_decks_are_legal() -> void:
	assert_eq(_content.decks.size(), 5)
	var profile: PlayerProfile = PlayerProfile.new()
	for deck: Deck in _content.decks:
		assert_eq(deck.size(), 45, deck.deck_name)
		assert_eq(deck.land_count(), 17, deck.deck_name)
		var issues: Array[DeckValidator.Issue] = DeckValidator.validate(deck, profile)
		for issue: DeckValidator.Issue in issues:
			fail_test("%s: %s" % [deck.deck_name, issue.message])
		assert_true(deck.colors().size() <= 2)


func test_deck_color_coverage() -> void:
	var appearances: Dictionary = {}
	for deck: Deck in _content.decks:
		if deck.deck_name == CampaignStart.STARTER_DECK_NAME:
			continue
		assert_eq(deck.colors().size(), 2, deck.deck_name)
		for color: Affinity.Type in deck.colors():
			appearances[color] = int(appearances.get(color, 0)) + 1
	for color: Affinity.Type in Affinity.colored_types():
		assert_eq(appearances[color], 2, "every color is in two of the pair decks")


func test_decks_only_use_cards_from_the_library() -> void:
	for deck: Deck in _content.decks:
		for card: CardData in deck.cards:
			assert_true(card.is_land() or _content.cards.has(card.id), "%s: unknown card %s" % [deck.deck_name, card.id])


func test_neutral_starter_spells_are_all_neutral() -> void:
	var starter: Deck = _content.deck("Wanderer's Pack")
	assert_not_null(starter)
	for card: CardData in starter.cards:
		if not card.is_land():
			assert_eq(card.color, Affinity.Type.NEUTRAL, card.id)
	assert_eq(starter.colors().size(), 1, "only its lands carry a color")


# ---- Every card actually works in a game -----------------------------------------------


func _prepared_game() -> GameState:
	var game: GameState = GameFactory.blank_game(3)
	for color: Affinity.Type in Affinity.colored_types():
		GameFactory.add_lands(game, 0, 3, color)
	GameFactory.add_lands(game, 1, 6, Affinity.Type.A)
	GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(2, 2))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2))
	GameFactory.add_to_hand(game, 1, GameFactory.vanilla(1, 1))
	GameFactory.add_to_hand(game, 1, GameFactory.vanilla(1, 1))
	return game


func test_every_card_can_be_cast_and_resolved() -> void:
	for card: CardData in _content.cards.values():
		var game: GameState = _prepared_game()
		var instance: CardInstance = GameFactory.add_to_hand(game, 0, card)
		var target: int = 0
		for effect: EffectData in card.effects:
			if effect.trigger == CardEnums.Trigger.ON_ENTER and effect.needs_chosen_target():
				target = game.legal_targets(0, effect, instance.uid)[0]
				break
		assert_true(game.cast(0, instance.uid, target), "cast %s" % card.id)
		assert_false(game.is_over(), "%s did not end the game" % card.id)
		match card.type:
			CardEnums.CardType.CREATURE, CardEnums.CardType.ARTIFACT:
				assert_eq(game.players[0].find_battlefield(instance.uid), instance, card.id)
			CardEnums.CardType.TRAP:
				assert_eq(game.players[0].traps.size(), 1, card.id)
			CardEnums.CardType.SPELL:
				assert_eq(game.players[0].graveyard.size(), 1 + (1 if card.id == "dark_bargain" else 0), card.id)


func test_every_trap_fires_when_its_condition_is_met() -> void:
	var trap_ids: Array[String] = ["pitfall", "scorching_ward", "snare"]
	for id: String in trap_ids:
		var game: GameState = _prepared_game()
		var trap: CardInstance = GameFactory.add_to_hand(game, 0, _content.card(id))
		assert_true(game.cast(0, trap.uid), id)
		GameFactory.pass_turn(game)
		var raider: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2))
		if id == "snare":
			var bait: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(1, 1, 1))
			game.cast(1, bait.uid)
			assert_eq(game.players[1].find_battlefield(bait.uid), null, "snare destroyed the new creature")
		else:
			game.advance_phase()
			game.declare_attackers([raider.uid] as Array[int])
			assert_eq(GameFactory.count_events(game, GameEvent.Type.TRAP_TRIGGERED), 1, id)
		assert_eq(game.players[0].traps.size(), 0, id)


func test_challenge_files_resolve_against_a_real_deck() -> void:
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), _content.decks[0])
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	for challenge: ChallengeData in _content.challenges:
		var result: ChallengeResult = ChallengeResolver.resolve(challenge, run, rng)
		assert_eq(result.challenge_id, challenge.id)
		run.heal(99)
	assert_false(run.failed)
