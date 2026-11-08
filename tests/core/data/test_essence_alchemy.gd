extends GutTest
## Part F: essence from extra copies, the Alchemist's crafting, and the multi-Path (dual-Path) cards: deck rules,
## costs, the AI and zone effects.

var A: Affinity.Type = Affinity.Type.BEEFCAKE
var B: Affinity.Type = Affinity.Type.GOURMAND
var C: Affinity.Type = Affinity.Type.REFUSEMANCER
var D: Affinity.Type = Affinity.Type.NECROCRAT


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(A)
	# Start every test from an empty collection so copy counts are exact.
	Session.profile.owned_cards.clear()
	Session.profile.essence.clear()


func _card(id: String, color: Affinity.Type, rarity: CardEnums.Rarity) -> CardData:
	var card: CardData = CardBuilder.unit(id, id.capitalize(), color, 1, [] as Array[Affinity.Type], 1, 1)
	card.rarity = rarity
	return card


func _dual(id: String, first: Affinity.Type, second: Affinity.Type, rarity: CardEnums.Rarity = CardEnums.Rarity.COMMON) -> CardData:
	var card: CardData = CardBuilder.unit(id, id.capitalize(), first, 1, [first, second] as Array[Affinity.Type], 2, 2)
	card.color2 = second
	card.rarity = rarity
	return card


# ---- Essence ----------------------------------------------------------------------------------------


func test_three_copies_are_kept_the_fourth_becomes_essence() -> void:
	var card: CardData = _card("firebolt_x", A, CardEnums.Rarity.COMMON)
	for i: int in range(3):
		Session.add_cards([card] as Array[CardData])
	assert_eq(Session.owned_count(card.id), 3)
	assert_eq(Session.profile.essence_of(A), 0)
	var notices: Array[String] = Session.add_cards([card] as Array[CardData])
	assert_eq(Session.owned_count(card.id), 3, "the fourth copy is not kept")
	assert_eq(Session.profile.essence_of(A), 2, "a common extra copy is worth 2 essence of its Path (Oct 29: doubled)")
	assert_eq(notices.size(), 1)
	assert_true(notices[0].contains("converted into 2 Beefcake essence"), notices[0])


func test_essence_scales_with_rarity() -> void:
	var expected: Dictionary = {CardEnums.Rarity.COMMON: 2, CardEnums.Rarity.UNCOMMON: 4, CardEnums.Rarity.EPIC: 8, CardEnums.Rarity.LEGENDARY: 16}
	for rarity: CardEnums.Rarity in expected.keys():
		Session.profile.owned_cards.clear()
		Session.profile.essence.clear()
		var card: CardData = _card("r_%d" % int(rarity), C, rarity)
		for i: int in range(Session.copy_cap(card) + 1):
			Session.add_cards([card] as Array[CardData])
		assert_eq(Session.profile.essence_of(C), int(expected[rarity]), "rarity %d" % int(rarity))
	assert_lt(Essence.value_for(CardEnums.Rarity.COMMON), Essence.value_for(CardEnums.Rarity.LEGENDARY))


func test_the_conversion_fires_a_notification_with_the_message_and_amount() -> void:
	var card: CardData = _card("notify", D, CardEnums.Rarity.EPIC)
	for i: int in range(Session.copy_cap(card)):
		Session.add_cards([card] as Array[CardData])
	watch_signals(EventBus)
	Session.add_cards([card] as Array[CardData])
	assert_signal_emitted(EventBus, "essence_converted")
	var params: Array = get_signal_parameters(EventBus, "essence_converted")
	assert_true(str(params[0]).contains("Necrocrat essence"))
	assert_eq(int((params[1] as Dictionary)[D]), 8)
	assert_eq(int(params[2]), 0)


func test_the_toast_layer_shows_the_notification() -> void:
	var card: CardData = _card("toasty", A, CardEnums.Rarity.COMMON)
	for i: int in range(5):
		Session.add_cards([card] as Array[CardData])
	assert_true(Session.toasts.history.back().contains("Extra copy of"), "the global toast layer shows the conversion")


func test_neutral_extras_become_gold() -> void:
	var card: CardData = _card("neutral_x", Affinity.Type.NEUTRAL, CardEnums.Rarity.UNCOMMON)
	for i: int in range(Session.copy_cap(card)):
		Session.add_cards([card] as Array[CardData])
	var gold_before: int = Session.gold
	var notices: Array[String] = Session.add_cards([card] as Array[CardData])
	assert_eq(Session.gold, gold_before + Essence.gold_for(CardEnums.Rarity.UNCOMMON))
	assert_eq(Session.owned_count(card.id), Session.copy_cap(card))
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
	for i: int in range(Session.copy_cap(card) + 1):
		Session.add_cards([card] as Array[CardData])
	assert_eq(Session.profile.essence_of(A), 4)
	assert_eq(Session.profile.essence_of(D), 4)
	var odd: CardData = _dual("odd", B, C, CardEnums.Rarity.UNCOMMON)
	var half: Dictionary = Essence.conversion(odd)["essence"] as Dictionary
	assert_eq(int(half[B]) + int(half[C]), Essence.value_for(CardEnums.Rarity.UNCOMMON))


func test_essence_comes_from_every_way_of_gaining_cards_and_is_saved() -> void:
	var card: CardData = _card("rewarded", C, CardEnums.Rarity.COMMON)
	for i: int in range(Session.copy_cap(card)):
		Session.add_cards([card] as Array[CardData])
	var offer: RewardOffer = RewardOffer.new()
	offer.taken = card
	Session.pending_reward = offer
	Session.apply_rewards()
	assert_eq(Session.profile.essence_of(C), 2, "a reward pick beyond the cap converts too")
	var data: Dictionary = Session.to_dict()
	Session.new_game()
	Session.ensure_game(A)
	assert_true(Session.from_dict(data))
	assert_eq(Session.profile.essence_of(C), 2, "essence survives a save and load")


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


## Fix pass Nov 4 (B), Part 4.2: a brew spends only what it needs (it used to take ALL the essence of both Paths).
func test_crafting_trades_the_needed_essence_of_both_paths_and_gold_for_a_dual_card() -> void:
	var profile: PlayerProfile = Session.profile
	profile.set_essence(A, 17)
	profile.set_essence(D, 12)
	profile.set_essence(B, 5)
	Session.gold = 250
	var result: Alchemy.Result = Session.craft_dual_card(A, D)
	assert_true(result.ok, result.reason)
	assert_true(result.card.is_multipath())
	assert_true(result.card.is_on_path(A) and result.card.is_on_path(D), "a Beefcake / Necrocrat card")
	assert_eq(profile.essence_of(A), 17 - Alchemy.MIN_ESSENCE_PER_PATH, "only the needed essence is spent")
	assert_eq(profile.essence_of(D), 12 - Alchemy.MIN_ESSENCE_PER_PATH)
	assert_eq(profile.essence_of(B), 5, "other Paths are untouched")
	assert_eq(Session.gold, 250 - Alchemy.GOLD_COST)
	assert_eq(Session.owned_count(result.card.id), 1, "the card joins the collection")
	assert_eq(Session.counter("cards_crafted"), 1)


## Fix pass Nov 4 (B), Part 4.2: a brew spends only what it needs. Fixes Nov 8: a craft needs 2 of each Path and 40 gold (was 6 and 100).
func test_a_craft_spends_only_what_it_needs() -> void:
	var profile: PlayerProfile = Session.profile
	profile.set_essence(A, 18)
	profile.set_essence(D, 18)
	Session.gold = 500
	assert_eq(Alchemy.MIN_ESSENCE_PER_PATH, 2)
	assert_eq(Alchemy.GOLD_COST, 40, "crafting costs 40 gold")
	var result: Alchemy.Result = Session.craft_dual_card(A, D)
	assert_true(result.ok, result.reason)
	assert_eq(profile.essence_of(A), 16)
	assert_eq(profile.essence_of(D), 16)
	assert_eq(Session.gold, 460)
	assert_eq(int(result.essence_spent[A]), 2)


## Fixes Nov 8: the cauldron favours multi-Path cards you do not own yet, so finishing a set takes one brew per card.
func test_the_cauldron_brews_missing_cards_first() -> void:
	var profile: PlayerProfile = Session.profile
	var pool: Array[CardData] = Alchemy.possible_cards(Session.content, A, D)
	if pool.size() < 2:
		pass_test("no pool for this pair")
		return
	var seen: Dictionary = {}
	for i: int in range(pool.size()):
		profile.set_essence(A, 18)
		profile.set_essence(D, 18)
		Session.gold = 500
		var result: Alchemy.Result = Session.craft_dual_card(A, D)
		assert_true(result.ok, result.reason)
		assert_false(seen.has(result.card.id), "no repeat while cards are missing (%s)" % result.card.id)
		seen[result.card.id] = true


func test_essence_is_capped_per_path() -> void:
	# Fixes Nov 8: the cap is 60 (room to save for a run of crafts; it was three crafts' worth, 18).
	var profile: PlayerProfile = Session.profile
	var cap: int = Alchemy.ESSENCE_CAP_PER_PATH
	profile.set_essence(A, 0)
	profile.add_essence(A, cap + 30)
	assert_eq(profile.essence_of(A), cap, "a Path holds at most the cap")
	profile.add_essence(A, 2)
	assert_eq(profile.essence_of(A), cap)


func test_the_alembic_quest_pays_a_starter_jar_of_every_path_on_the_first_visit() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.ALEMBIC)
	assert_not_null(quest)
	assert_true(quest.auto_give)
	assert_eq(quest.objectives.size(), 2)
	assert_false(Session.visit_alchemist(), "nothing before the quest is given")
	Session.quest_log.active.append(QuestDefinitions.ALEMBIC)  # (its real trigger is two freed zones)
	for path: Affinity.Type in Affinity.colored_types():
		Session.profile.set_essence(path, 0)
	assert_true(Session.visit_alchemist())
	for path: Affinity.Type in Affinity.colored_types():
		assert_eq(Session.profile.essence_of(path), Alchemy.MIN_ESSENCE_PER_PATH, "the minimum of every Path")
	assert_true(Alchemy.can_craft_something(Session.profile), "enough for one brew of any two")
	assert_false(Session.visit_alchemist(), "once only")
	assert_eq(Session.profile.essence_of(A), Alchemy.MIN_ESSENCE_PER_PATH)


func test_a_failed_craft_costs_nothing() -> void:
	var profile: PlayerProfile = Session.profile
	profile.set_essence(A, 20)
	profile.set_essence(B, Alchemy.MIN_ESSENCE_PER_PATH - 1)  # one short
	Session.gold = 500
	var result: Alchemy.Result = Session.craft_dual_card(A, B)
	assert_false(result.ok)
	assert_false(result.reason.is_empty())
	assert_eq(profile.essence_of(A), 20)
	assert_eq(Session.gold, 500)


const PATH_PAIRS: Array = [
	[Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND], [Affinity.Type.BEEFCAKE, Affinity.Type.REFUSEMANCER], [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT],
	[Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER], [Affinity.Type.GOURMAND, Affinity.Type.NECROCRAT], [Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT],
]


func test_every_pair_of_paths_can_be_crafted_into_one_of_its_cards() -> void:
	for pair: Array in PATH_PAIRS:
		var first: Affinity.Type = pair[0] as Affinity.Type
		var second: Affinity.Type = pair[1] as Affinity.Type
		var possible: Array[CardData] = Alchemy.possible_cards(Session.content, first, second)
		assert_gte(possible.size(), 4, "%d/%d has several cards" % [int(first), int(second)])
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


func test_tri_path_crafting_opens_in_the_postgame() -> void:
	assert_eq(Alchemy.max_craft_paths(Session.profile), 2)
	assert_false(Alchemy.tri_path_unlocked(Session.profile))
	Session.profile.postgame_unlocked = true
	assert_true(Alchemy.tri_path_unlocked(Session.profile))
	assert_eq(Alchemy.max_craft_paths(Session.profile), 3)
	assert_false(Alchemy.tri_path_cards(Session.content, [A, B, C] as Array[Affinity.Type]).is_empty(), "tri-Path cards exist")


## Oct 31: the tri-Path recipes. Every trio of Paths brews into one of its own tri-Path cards; the brew takes ALL essence of the three
## Paths plus TRI_GOLD_COST, and is refused before the postgame, with two Paths, a repeated Path, too little essence or gold.
func test_every_trio_of_paths_brews_into_one_of_its_tri_path_cards() -> void:
	var trios: Array = [[A, B, C], [A, B, D], [A, C, D], [B, C, D]]
	Session.profile.postgame_unlocked = true
	for trio: Array in trios:
		var paths: Array[Affinity.Type] = []
		paths.assign(trio)
		for path: Affinity.Type in Affinity.colored_types():
			Session.profile.set_essence(path, 0)
		for path: Affinity.Type in paths:
			Session.profile.set_essence(path, 20)
		Session.gold = Alchemy.TRI_GOLD_COST + 5
		var result: Alchemy.Result = Session.craft_tri_card(paths)
		assert_true(result.ok, "%s: %s" % [trio, result.reason])
		assert_eq(result.card.paths().size(), 3, "a tri-Path card")
		for path: Affinity.Type in paths:
			assert_true(result.card.is_on_path(path))
			assert_eq(Session.profile.essence_of(path), 20 - Alchemy.MIN_ESSENCE_PER_PATH, "only the needed essence of the three Paths is spent")
		assert_eq(Session.gold, 5)
		assert_false(CardAvailability.is_enemy_only(result.card))


func test_the_tri_path_brew_refuses_bad_trades_and_costs_nothing() -> void:
	var profile: PlayerProfile = Session.profile
	var trio: Array[Affinity.Type] = [A, B, C]
	for path: Affinity.Type in trio:
		profile.set_essence(path, Alchemy.MIN_ESSENCE_PER_PATH)
	assert_false(Alchemy.tri_problem(profile, 999, trio).is_empty(), "not before the postgame")
	profile.postgame_unlocked = true
	assert_eq(Alchemy.tri_problem(profile, Alchemy.TRI_GOLD_COST, trio), "")
	assert_false(Alchemy.tri_problem(profile, Alchemy.TRI_GOLD_COST - 1, trio).is_empty(), "and the gold")
	assert_false(Alchemy.tri_problem(profile, 999, [A, A, B] as Array[Affinity.Type]).is_empty(), "three different Paths")
	assert_false(Alchemy.tri_problem(profile, 999, [A, B] as Array[Affinity.Type]).is_empty(), "three, not two")
	profile.set_essence(C, Alchemy.MIN_ESSENCE_PER_PATH - 1)
	Session.gold = 999
	var result: Alchemy.Result = Session.craft_tri_card(trio)
	assert_false(result.ok)
	assert_eq(profile.essence_of(A), Alchemy.MIN_ESSENCE_PER_PATH, "a failed brew spends nothing")
	assert_eq(Session.gold, 999)


func test_the_alchemist_screen_takes_three_paths_in_the_postgame() -> void:
	Session.profile.postgame_unlocked = true
	for path: Affinity.Type in [A, B, C]:
		Session.profile.set_essence(path, 12)
	Session.gold = Alchemy.TRI_GOLD_COST
	var screen: AlchemistScreen = AlchemistScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	for path: Affinity.Type in [A, B, C]:
		((screen.find_child("EssenceRow%d" % int(path), true, false)) as Button).pressed.emit()
	await wait_frames(2)
	var craft: FancyButton = screen.find_child("CraftButton", true, false) as FancyButton
	assert_false(craft.disabled, "three eligible Paths chosen")
	craft.pressed.emit()
	assert_eq(Session.gold, 0, "the tri-Path brew was paid")
	assert_eq(Session.profile.essence_of(B), 12 - Alchemy.MIN_ESSENCE_PER_PATH)


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
	assert_eq(Session.profile.essence_of(A), 14 - Alchemy.MIN_ESSENCE_PER_PATH)
	assert_not_null(screen.find_child("CraftResult", true, false))


# ---- The 24 dual-Path cards -------------------------------------------------------------------------------


func test_each_of_the_six_pairs_has_dual_cards_of_every_rarity() -> void:
	for pair: Array in PATH_PAIRS:
		var cards: Array[CardData] = Alchemy.possible_cards(Session.content, pair[0] as Affinity.Type, pair[1] as Affinity.Type)
		var rarities: Dictionary = {}
		for card: CardData in cards:
			rarities[card.rarity] = true
			assert_true(card.is_multipath())
			assert_false(Session.content.cards.has(card.id), "dual cards are never ordinary rewards or vendor stock")
		# Cards Oct 27: the Necrocrat / Beefcake pair's Legendary is Chancellor Clench's own card (ENEMY-ONLY), so that pair crafts two rarities.
		var necro_beef: bool = pair.has(Affinity.Type.NECROCRAT) and pair.has(Affinity.Type.BEEFCAKE)
		assert_gte(rarities.size(), 2 if necro_beef else 3, "several rarities per pair")


func test_dual_cards_load_from_data_with_both_paths() -> void:
	var loaded: ContentSet = ContentLibrary.load_all()
	for card: CardData in loaded.multipath_cards.values():
		assert_gte(card.paths().size(), 2, card.id)


func test_a_dual_card_needs_energy_from_both_paths() -> void:
	var game: GameState = GameFactory.blank_game()
	var card: CardInstance = GameFactory.add_to_hand(game, 0, _dual("both", A, D))
	GameFactory.add_infrastructure_cards(game, 0, 3, A)
	assert_false(game.can_play_card(0, card.uid), "three Beefcake infrastructure cannot pay a Necrocrat pip")
	GameFactory.add_infrastructure_cards(game, 0, 1, D)
	assert_true(game.can_play_card(0, card.uid))
	assert_true(game.play_card(0, card.uid))
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
	assert_eq(action.type, GameAction.Type.PLAY)
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
	profile.zones_freed = 1
	assert_true(DeckValidator.has_problem(DeckValidator.validate(_deck(padded), profile), DeckValidator.Problem.TOO_MANY_COLORS), "4 Paths exceed the 2-Path limit")
	profile.postgame_unlocked = true
	assert_false(DeckValidator.has_problem(DeckValidator.validate(_deck(padded), profile), DeckValidator.Problem.TOO_MANY_COLORS), "postgame allows 4")


func test_the_deck_builder_refuses_a_dual_card_that_would_break_the_path_limit() -> void:
	var profile: PlayerProfile = Session.profile
	profile.zones_freed = 1
	var ab: CardData = _dual("owned_ab", A, B)
	var cd: CardData = _dual("owned_cd", C, D)
	var ad: CardData = _dual("owned_ad", A, D)
	profile.owned_cards.append_array([ab, cd, ad] as Array[CardData])
	var deck: Deck = _deck([CardBuilder.infra(A), CardBuilder.infra(B)] as Array[CardData])
	var editor: DeckEditor = DeckEditor.from(profile, deck, [CardBuilder.infra(A), CardBuilder.infra(B)] as Array[CardData])
	assert_eq(editor.why_not_add(ab), "", "A/B fits a deck already on A and B")
	assert_true(editor.why_not_add(cd).contains("needs two Paths"), "C/D needs two more Paths: " + editor.why_not_add(cd))
	assert_true(editor.why_not_add(ad).contains("two Paths"), "A/D would add a third Path")
	assert_true(editor.add(ab))


func test_dual_cards_obey_the_copy_cap() -> void:
	var card: CardData = _dual("limit", A, B)
	for i: int in range(6):
		Session.add_cards([card] as Array[CardData])
	assert_eq(Session.owned_count(card.id), 3)
	var deck: Deck = Deck.new()
	for i: int in range(4):
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
	var card: CardInstance = GameFactory.add_to_field(game, 0, _dual("rival", A, D), true)
	assert_eq(game.get_attack(card), 3, "Pump It Up (Beefcake) buffs it...")
	GameFactory.add_infrastructure_cards(game, 0, 3, A)
	GameFactory.add_infrastructure_cards(game, 0, 3, D)
	var second: CardInstance = GameFactory.add_to_hand(game, 0, _dual("rival2", A, D))
	assert_true(game.play_card(0, second.uid))
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
	if UiArt.has(view.frame_id()):
		assert_eq(view.frame_id(), "UI-FRAME-MULTI", "a multi-Path card wears the multi-Path frame")
		return
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
