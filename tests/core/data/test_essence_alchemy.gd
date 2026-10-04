extends GutTest
## Part F: essence from extra copies, the Alchemist's crafting, and the multi-Path (dual-Path) cards: deck rules,
## costs, the AI and zone effects.

var A: Affinity.Type = Affinity.Type.A
var B: Affinity.Type = Affinity.Type.B
var C: Affinity.Type = Affinity.Type.C
var D: Affinity.Type = Affinity.Type.D


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(A)
	# Start every test from an empty collection so copy counts are exact.
	Session.profile.owned_cards.clear()
	Session.profile.essence.clear()


func _card(id: String, color: Affinity.Type, rarity: CardEnums.Rarity) -> CardData:
	var card: CardData = CardBuilder.creature(id, id.capitalize(), color, 1, [] as Array[Affinity.Type], 1, 1)
	card.rarity = rarity
	return card


func _dual(id: String, first: Affinity.Type, second: Affinity.Type, rarity: CardEnums.Rarity = CardEnums.Rarity.COMMON) -> CardData:
	var card: CardData = CardBuilder.creature(id, id.capitalize(), first, 1, [first, second] as Array[Affinity.Type], 2, 2)
	card.color2 = second
	card.rarity = rarity
	return card


# ---- Essence ----------------------------------------------------------------------------------------


func test_four_copies_are_kept_the_fifth_becomes_essence() -> void:
	var card: CardData = _card("firebolt_x", A, CardEnums.Rarity.COMMON)
	for i: int in range(4):
		Session.add_cards([card] as Array[CardData])
	assert_eq(Session.owned_count(card.id), 4)
	assert_eq(Session.profile.essence_of(A), 0)
	var notices: Array[String] = Session.add_cards([card] as Array[CardData])
	assert_eq(Session.owned_count(card.id), 4, "the fifth copy is not kept")
	assert_eq(Session.profile.essence_of(A), 1, "a common extra copy is worth 1 essence of its Path")
	assert_eq(notices.size(), 1)
	assert_true(notices[0].contains("converted into 1 Beefcake essence"), notices[0])


func test_essence_scales_with_rarity() -> void:
	var expected: Dictionary = {CardEnums.Rarity.COMMON: 1, CardEnums.Rarity.UNCOMMON: 2, CardEnums.Rarity.EPIC: 4, CardEnums.Rarity.LEGENDARY: 8}
	for rarity: CardEnums.Rarity in expected.keys():
		Session.profile.owned_cards.clear()
		Session.profile.essence.clear()
		var card: CardData = _card("r_%d" % int(rarity), C, rarity)
		for i: int in range(5):
			Session.add_cards([card] as Array[CardData])
		assert_eq(Session.profile.essence_of(C), int(expected[rarity]), "rarity %d" % int(rarity))
	assert_lt(Essence.value_for(CardEnums.Rarity.COMMON), Essence.value_for(CardEnums.Rarity.LEGENDARY))


func test_the_conversion_fires_a_notification_with_the_message_and_amount() -> void:
	var card: CardData = _card("notify", D, CardEnums.Rarity.EPIC)
	for i: int in range(4):
		Session.add_cards([card] as Array[CardData])
	watch_signals(EventBus)
	Session.add_cards([card] as Array[CardData])
	assert_signal_emitted(EventBus, "essence_converted")
	var params: Array = get_signal_parameters(EventBus, "essence_converted")
	assert_true(str(params[0]).contains("Necrocrat essence"))
	assert_eq(int((params[1] as Dictionary)[D]), 4)
	assert_eq(int(params[2]), 0)


func test_the_toast_layer_shows_the_notification() -> void:
	var card: CardData = _card("toasty", A, CardEnums.Rarity.COMMON)
	for i: int in range(5):
		Session.add_cards([card] as Array[CardData])
	assert_true(Session.toasts.history.back().contains("Extra copy of"), "the global toast layer shows the conversion")


func test_neutral_extras_become_gold() -> void:
	var card: CardData = _card("neutral_x", Affinity.Type.NEUTRAL, CardEnums.Rarity.UNCOMMON)
	for i: int in range(4):
		Session.add_cards([card] as Array[CardData])
	var gold_before: int = Session.gold
	var notices: Array[String] = Session.add_cards([card] as Array[CardData])
	assert_eq(Session.gold, gold_before + Essence.gold_for(CardEnums.Rarity.UNCOMMON))
	assert_eq(Session.owned_count(card.id), 4)
	assert_true(notices[0].contains("gold"))
	assert_eq(Session.profile.total_essence(), 0, "neutral cards never make essence")


func test_infrastructure_is_unlimited_and_never_converts() -> void:
	var infra: CardData = CardBuilder.infra(A)
	for i: int in range(10):
		Session.add_cards([infra] as Array[CardData])
	assert_eq(Session.owned_count(infra.id), 10)
	assert_eq(Session.profile.total_essence(), 0)


func test_a_dual_path_extra_splits_its_essence_between_both_paths() -> void:
	var card: CardData = _dual("split", A, D, CardEnums.Rarity.EPIC)
	for i: int in range(5):
		Session.add_cards([card] as Array[CardData])
	assert_eq(Session.profile.essence_of(A), 2)
	assert_eq(Session.profile.essence_of(D), 2)
	var odd: CardData = _dual("odd", B, C, CardEnums.Rarity.UNCOMMON)
	var half: Dictionary = Essence.conversion(odd)["essence"] as Dictionary
	assert_eq(int(half[B]) + int(half[C]), Essence.value_for(CardEnums.Rarity.UNCOMMON))


func test_essence_comes_from_every_way_of_gaining_cards_and_is_saved() -> void:
	var card: CardData = _card("rewarded", C, CardEnums.Rarity.COMMON)
	for i: int in range(4):
		Session.add_cards([card] as Array[CardData])
	var offer: RewardOffer = RewardOffer.new()
	offer.taken = card
	Session.pending_reward = offer
	Session.apply_rewards()
	assert_eq(Session.profile.essence_of(C), 1, "a reward pick beyond 4 copies converts too")
	var data: Dictionary = Session.to_dict()
	Session.new_game()
	Session.ensure_game(A)
	assert_true(Session.from_dict(data))
	assert_eq(Session.profile.essence_of(C), 1, "essence survives a save and load")


# ---- The Alchemist --------------------------------------------------------------------------------------


func test_crafting_needs_enough_essence_of_two_paths_and_gold() -> void:
	var profile: PlayerProfile = Session.profile
	assert_false(Alchemy.can_craft_something(profile))
	profile.set_essence(A, Alchemy.MIN_ESSENCE_PER_PATH)
	assert_false(Alchemy.can_craft_something(profile), "one Path is not enough")
	profile.set_essence(D, Alchemy.MIN_ESSENCE_PER_PATH - 1)
	assert_false(Alchemy.can_craft(profile, 999, A, D))
	profile.set_essence(D, Alchemy.MIN_ESSENCE_PER_PATH)
	assert_true(Alchemy.can_craft_something(profile))
	assert_true(Alchemy.can_craft(profile, Alchemy.GOLD_COST, A, D))
	assert_false(Alchemy.can_craft(profile, Alchemy.GOLD_COST - 1, A, D), "and the gold")
	assert_false(Alchemy.can_craft(profile, 999, A, A), "two different Paths")
	assert_eq(Alchemy.eligible_paths(profile), [A, D] as Array[Affinity.Type])


func test_crafting_trades_all_essence_of_both_paths_and_gold_for_a_dual_card() -> void:
	var profile: PlayerProfile = Session.profile
	profile.set_essence(A, 17)
	profile.set_essence(D, 12)
	profile.set_essence(B, 5)
	Session.gold = 250
	var result: Alchemy.Result = Session.craft_dual_card(A, D)
	assert_true(result.ok, result.reason)
	assert_true(result.card.is_multipath())
	assert_true(result.card.is_on_path(A) and result.card.is_on_path(D), "a Beefcake / Necrocrat card")
	assert_eq(profile.essence_of(A), 0, "ALL essence of both Paths is spent")
	assert_eq(profile.essence_of(D), 0)
	assert_eq(profile.essence_of(B), 5, "other Paths are untouched")
	assert_eq(Session.gold, 250 - Alchemy.GOLD_COST)
	assert_eq(Session.owned_count(result.card.id), 1, "the card joins the collection")
	assert_eq(Session.counter("cards_crafted"), 1)


func test_a_failed_craft_costs_nothing() -> void:
	var profile: PlayerProfile = Session.profile
	profile.set_essence(A, 20)
	profile.set_essence(B, 4)
	Session.gold = 500
	var result: Alchemy.Result = Session.craft_dual_card(A, B)
	assert_false(result.ok)
	assert_false(result.reason.is_empty())
	assert_eq(profile.essence_of(A), 20)
	assert_eq(Session.gold, 500)


func test_every_pair_of_paths_can_be_crafted_into_one_of_its_four_cards() -> void:
	for pair: Array in MultipathContent.PAIRS:
		var first: Affinity.Type = pair[0] as Affinity.Type
		var second: Affinity.Type = pair[1] as Affinity.Type
		var possible: Array[CardData] = Alchemy.possible_cards(Session.content, first, second)
		assert_eq(possible.size(), 4, "%d/%d has 4 cards" % [int(first), int(second)])
		for seed_value: int in range(6):
			Session.profile.set_essence(first, 30)
			Session.profile.set_essence(second, 30)
			var rng: RandomNumberGenerator = RandomNumberGenerator.new()
			rng.seed = seed_value
			var result: Alchemy.Result = Alchemy.craft(Session.content, Session.profile, 500, first, second, rng)
			assert_true(result.ok)
			assert_true(possible.has(result.card), "%s is one of the pair's cards" % result.card.id)


func test_more_essence_improves_the_odds_of_rare_cards() -> void:
	var low: Array[int] = Alchemy.weights_for(2 * Alchemy.MIN_ESSENCE_PER_PATH)
	var high: Array[int] = Alchemy.weights_for(2 * Alchemy.MIN_ESSENCE_PER_PATH + 50)
	assert_gt(high[CardEnums.Rarity.LEGENDARY], low[CardEnums.Rarity.LEGENDARY])
	assert_gt(high[CardEnums.Rarity.EPIC], low[CardEnums.Rarity.EPIC])
	assert_lt(high[CardEnums.Rarity.COMMON], low[CardEnums.Rarity.COMMON])
	assert_gte(high[CardEnums.Rarity.COMMON], 1, "common never drops out entirely")


func test_crafting_is_deterministic_for_a_seed() -> void:
	var picks: Array[String] = []
	for attempt: int in range(2):
		Session.profile.set_essence(A, 25)
		Session.profile.set_essence(C, 25)
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 99
		picks.append(Alchemy.craft(Session.content, Session.profile, 500, A, C, rng).card.id)
	assert_eq(picks[0], picks[1])


func test_tri_path_crafting_is_only_a_postgame_hook() -> void:
	assert_eq(Alchemy.max_craft_paths(Session.profile), 2)
	assert_false(Alchemy.tri_path_unlocked(Session.profile))
	Session.profile.postgame_unlocked = true
	assert_true(Alchemy.tri_path_unlocked(Session.profile))
	assert_eq(Alchemy.max_craft_paths(Session.profile), 3)
	assert_true(Alchemy.tri_path_cards(Session.content, [A, B, C] as Array[Affinity.Type]).is_empty(), "no tri-Path cards yet")


func test_the_alchemist_screen_lists_essence_and_enables_craft() -> void:
	Session.profile.set_essence(A, 14)
	Session.profile.set_essence(D, 11)
	Session.gold = 300
	var screen: AlchemistScreen = AlchemistScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	var craft: FancyButton = screen.find_child("CraftButton", true, false) as FancyButton
	assert_true(craft.disabled, "nothing chosen yet")
	((screen.find_child("EssenceRow%d" % int(A), true, false)) as Button).pressed.emit()
	((screen.find_child("EssenceRow%d" % int(D), true, false)) as Button).pressed.emit()
	await wait_frames(2)
	assert_false(craft.disabled, "two eligible Paths chosen")
	assert_eq(((screen.find_child("EssenceRow%d" % int(B), true, false)) as Button).disabled, false)
	watch_signals(screen)
	craft.pressed.emit()
	await wait_seconds(2.3)
	assert_signal_emitted(screen, "crafted")
	assert_eq(Session.profile.essence_of(A), 0)
	assert_not_null(screen.find_child("CraftResult", true, false))


# ---- The 24 dual-Path cards -------------------------------------------------------------------------------


func test_there_are_four_dual_cards_for_each_of_the_six_pairs() -> void:
	assert_eq(Session.content.multipath_cards.size(), 24)
	for pair: Array in MultipathContent.PAIRS:
		var ids: Array[String] = MultipathContent.ids_for(pair[0] as Affinity.Type, pair[1] as Affinity.Type, Session.content.multipath_cards)
		assert_eq(ids.size(), 4)
		var rarities: Dictionary = {}
		for card_id: String in ids:
			var card: CardData = Session.content.card(card_id)
			rarities[card.rarity] = true
			assert_true(card.is_multipath())
			assert_eq(card.colored_pips.size() >= 2, true)
			assert_true(card.colored_pips.has(card.color) and card.colored_pips.has(card.color2), "%s needs energy from both Paths" % card_id)
			assert_false(Session.content.cards.has(card_id), "dual cards are never ordinary rewards or vendor stock")
		assert_eq(rarities.size(), 4, "one of each rarity per pair")


func test_dual_cards_load_from_data_with_both_paths() -> void:
	var loaded: ContentSet = ContentLibrary.load_all()
	assert_eq(loaded.multipath_cards.size(), 24)
	for card: CardData in loaded.multipath_cards.values():
		assert_ne(card.color2, Affinity.Type.NEUTRAL, card.id)
		assert_ne(card.color2, card.color)


func test_a_dual_card_needs_energy_from_both_paths() -> void:
	var game: GameState = GameFactory.blank_game()
	var card: CardInstance = GameFactory.add_to_hand(game, 0, _dual("both", A, D))
	GameFactory.add_infrastructure_cards(game, 0, 3, A)
	assert_false(game.can_cast(0, card.uid), "three Beefcake infrastructure cannot pay a Necrocrat pip")
	GameFactory.add_infrastructure_cards(game, 0, 1, D)
	assert_true(game.can_cast(0, card.uid))
	assert_true(game.cast(0, card.uid))
	assert_eq(game.players[0].ready_infrastructure().size(), 1, "paid with one infrastructure of each Path plus one generic")
	for infra: CardInstance in game.players[0].infrastructure:
		if infra.data.color == D:
			assert_true(infra.exhausted, "the Necrocrat infrastructure was activated")


func test_the_ai_casts_a_dual_card_once_it_has_both_paths() -> void:
	var game: GameState = GameFactory.blank_game()
	var card: CardInstance = GameFactory.add_to_hand(game, 0, _dual("aicast", B, C))
	GameFactory.add_infrastructure_cards(game, 0, 1, B)
	GameFactory.add_infrastructure_cards(game, 0, 2, C)
	var action: GameAction = AIPlayer.new(AIPersonality.balanced()).choose_action(game)
	assert_eq(action.type, GameAction.Type.CAST)
	assert_eq(action.card_uid, card.uid)


func test_the_ai_plays_the_infrastructure_a_dual_card_needs() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_to_hand(game, 0, _dual("needs", A, D))
	GameFactory.add_infrastructure_cards(game, 0, 1, A)
	GameFactory.add_to_hand(game, 0, GameFactory.infra(B))
	var wanted: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.infra(D))
	assert_eq(AIPlayer.new(AIPersonality.balanced()).choose_action(game).card_uid, wanted.uid)


# ---- Deck rules --------------------------------------------------------------------------------------------


func _deck(cards: Array[CardData]) -> Deck:
	var deck: Deck = Deck.new()
	deck.cards = cards
	return deck


func test_a_dual_card_counts_as_both_paths_for_the_deck_limit() -> void:
	var infra_a: CardData = CardBuilder.infra(A)
	var deck: Deck = _deck([infra_a, _dual("ad", A, D)] as Array[CardData])
	assert_eq(deck.colors().size(), 2, "A infrastructure + an A/D card = two Paths")
	assert_true(deck.colors().has(A) and deck.colors().has(D))
	var big: Deck = _deck([CardBuilder.infra(A), CardBuilder.infra(B), _dual("cd", C, D)] as Array[CardData])
	assert_eq(big.colors().size(), 4)
	var padded: Array[CardData] = []
	for i: int in range(45):
		padded.append(big.cards[i % 3])
	var profile: PlayerProfile = PlayerProfile.new()
	assert_true(DeckValidator.has_problem(DeckValidator.validate(_deck(padded), profile), DeckValidator.Problem.TOO_MANY_COLORS), "4 Paths exceed the 2-Path limit")
	profile.postgame_unlocked = true
	assert_false(DeckValidator.has_problem(DeckValidator.validate(_deck(padded), profile), DeckValidator.Problem.TOO_MANY_COLORS), "postgame allows 4")


func test_the_deck_builder_refuses_a_dual_card_that_would_break_the_path_limit() -> void:
	var profile: PlayerProfile = Session.profile
	var ab: CardData = _dual("owned_ab", A, B)
	var cd: CardData = _dual("owned_cd", C, D)
	var ad: CardData = _dual("owned_ad", A, D)
	profile.owned_cards.append_array([ab, cd, ad] as Array[CardData])
	var deck: Deck = _deck([CardBuilder.infra(A), CardBuilder.infra(B)] as Array[CardData])
	var editor: DeckEditor = DeckEditor.from(profile, deck, [CardBuilder.infra(A), CardBuilder.infra(B)] as Array[CardData])
	assert_eq(editor.why_not_add(ab), "", "A/B fits a deck already on A and B")
	assert_true(editor.why_not_add(cd).contains("both of its Paths"), "C/D needs two more Paths: " + editor.why_not_add(cd))
	assert_true(editor.why_not_add(ad).contains("both of its Paths"), "A/D would add a third Path")
	assert_true(editor.add(ab))


func test_dual_cards_obey_the_four_copy_limit() -> void:
	var card: CardData = _dual("limit", A, B)
	for i: int in range(6):
		Session.add_cards([card] as Array[CardData])
	assert_eq(Session.owned_count(card.id), 4)
	var deck: Deck = Deck.new()
	for i: int in range(5):
		deck.cards.append(card)
	assert_true(DeckValidator.has_problem(DeckValidator.validate(deck, Session.profile), DeckValidator.Problem.TOO_MANY_COPIES))


# ---- Zone effects and visuals --------------------------------------------------------------------------------


func test_a_dual_card_receives_the_zone_effects_of_both_its_paths() -> void:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 1
	var game: GameState = GameState.new(options)
	var source: ModifierSource = ZoneEffects.source_for(GainlandsZone.ID)
	var extra: Array[ModifierSource] = [source] as Array[ModifierSource]
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, extra, "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, extra, "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	game.players[0].hand.clear()
	var card: CardInstance = GameFactory.add_to_battlefield(game, 0, _dual("rival", A, D), true)
	assert_eq(game.get_power(card), 3, "Pump It Up (Beefcake) buffs it...")
	GameFactory.add_infrastructure_cards(game, 0, 3, A)
	GameFactory.add_infrastructure_cards(game, 0, 3, D)
	var second: CardInstance = GameFactory.add_to_hand(game, 0, _dual("rival2", A, D))
	assert_true(game.cast(0, second.uid))
	assert_true(second.exhausted, "...and Processing Time (Necrocrat) makes it enter exhausted")


func test_the_card_frame_shows_both_paths() -> void:
	var card: CardData = _dual("framed", A, D, CardEnums.Rarity.EPIC)
	var view: CardView = CardView.create(card)
	add_child_autofree(view)
	await wait_frames(2)
	assert_true(view.dual)
	assert_ne(view.accent, view.accent2)
	var plain: CardView = CardView.create(_card("single", A, CardEnums.Rarity.COMMON))
	add_child_autofree(plain)
	await wait_frames(2)
	assert_false(plain.dual)
	var gems: int = 0
	for child: Node in view.get_children():
		if child is Panel and (child as Panel).size == Vector2(22, 22):
			gems += 1
	assert_eq(gems, 2, "two Path gems on the art")


func test_a_dual_card_shows_in_both_path_filters() -> void:
	var filter: CardFilterBar = CardFilterBar.new()
	var card: CardData = _dual("filtered", B, D)
	filter.affinity_filter = int(B)
	assert_true(filter.matches(card))
	filter.affinity_filter = int(D)
	assert_true(filter.matches(card))
	filter.affinity_filter = int(A)
	assert_false(filter.matches(card))
	filter.free()
