extends GutTest
## New brief, Part B: engine-level coverage for every new Modifier.Kind hook added for the 10
## equipment pieces. Tests exercise the generic engine hooks directly (a `ModifierSource` built
## in-test, exactly like `tests/core/dungeon/test_modifiers_and_decks.gd` already does for the
## older modifier kinds) rather than only through the named pieces - `tests/core/data/
## test_progression.gd` covers a couple of the real pieces end to end (Thorned Loincloth) on top
## of this. See docs/design/open_questions.md D92.

const NO_PIPS: Array[Affinity.Type] = []


func _source(mods: Array[Modifier]) -> ModifierSource:
	return CardBuilder.modifier_source("Test Gear", ModifierSource.SourceKind.EQUIPMENT, mods)


## A game where player 0 has `p0_mods` and player 1 has `p1_mods`. `clear_hands` wipes the dealt
## opening hands (and whatever turn 1 already drew) afterwards for a blank slate - turned off by
## tests that specifically want to observe turn-1 draw behavior (e.g. FIRST_TURN_EXTRA_DRAW),
## since `keep_hand` (below) already triggers turn 1 the instant both players have kept.
## `random_first_player` sets GameOptions.first_player = -1 (the real-match convention, D17) so
## ALWAYS_FIRST's coin-flip fallback has something to override - GameOptions.first_player defaults
## to 0 (always player 0), which would otherwise mask the modifier entirely.
func _game(p0_mods: Array[Modifier] = [], p1_mods: Array[Modifier] = [], seed_value: int = 1, clear_hands: bool = true, random_first_player: bool = false) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	if random_first_player:
		options.first_player = -1
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [_source(p0_mods)] as Array[ModifierSource], "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [_source(p1_mods)] as Array[ModifierSource], "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	if clear_hands:
		for player: PlayerState in game.players:
			player.hand.clear()
	return game


func _effect_mod(kind: Modifier.Kind, op: CardEnums.EffectOp, amount: int, target: CardEnums.TargetKind) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	var effect: EffectData = EffectData.new()
	effect.op = op
	effect.amount = amount
	effect.target = target
	modifier.effect = effect
	return modifier


# ---- Wicked Dagger / Solid Plate: STAT_CHANGE (already-generic mechanism) ---------------------


func test_stat_change_any_color_buffs_both_power_and_defense() -> void:
	var game: GameState = _game([
		CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0),
		CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1),
	])
	var unit: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	assert_eq(game.get_attack(unit), 3, "Wicked Dagger's +1 attack")
	assert_eq(game.get_defense(unit), 3, "Solid Plate's +1 defense")


# ---- Flamethrower: START_OF_TURN_EFFECT -------------------------------------------------------


func test_start_of_turn_effect_damages_every_opposing_unit() -> void:
	var game: GameState = _game([_effect_mod(Modifier.Kind.START_OF_TURN_EFFECT, CardEnums.EffectOp.DEAL_DAMAGE, 1, CardEnums.TargetKind.ALL_ENEMY_UNITS)])
	var enemy_a: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	var enemy_b: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 1))
	var mine: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	GameFactory.pass_turn(game) # ends P0's turn 1, begins P1's turn 2
	GameFactory.pass_turn(game) # ends P1's turn 2, begins P0's turn 3 - fires the effect
	assert_eq(game.active, 0)
	assert_eq(enemy_a.damage, 1, "opposing unit took the Flamethrower tick")
	assert_false(game.players[1].field.has(enemy_b), "the 2/1 died to the 1 damage")
	assert_eq(mine.damage, 0, "the owner's own unit is untouched")


func test_start_of_turn_effect_does_not_fire_on_the_opponents_turn() -> void:
	var game: GameState = _game([_effect_mod(Modifier.Kind.START_OF_TURN_EFFECT, CardEnums.EffectOp.DEAL_DAMAGE, 1, CardEnums.TargetKind.ALL_ENEMY_UNITS)])
	var enemy: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	GameFactory.pass_turn(game) # P1's turn begins - P1 does not have the modifier
	assert_eq(game.active, 1)
	assert_eq(enemy.damage, 0)


# ---- Cheater's Dice: ALWAYS_FIRST + OPENING_HAND_SIZE ------------------------------------------


func test_always_first_modifier_picks_that_player_to_go_first() -> void:
	for seed_value: int in range(1, 6):
		var game: GameState = _game([], [CardBuilder.modifier(Modifier.Kind.ALWAYS_FIRST, 1)], seed_value, true, true)
		assert_eq(game.first_player, 1, "seed %d: player 1 has ALWAYS_FIRST" % seed_value)
		assert_eq(game.active, 1)


func test_always_first_falls_back_to_a_coin_flip_if_both_players_have_it() -> void:
	var seen: Dictionary = {}
	for seed_value: int in range(1, 30):
		var game: GameState = _game(
			[CardBuilder.modifier(Modifier.Kind.ALWAYS_FIRST, 1)],
			[CardBuilder.modifier(Modifier.Kind.ALWAYS_FIRST, 1)],
			seed_value, true, true,
		)
		seen[game.first_player] = true
	assert_eq(seen.size(), 2, "both players wanting to go first should still let either actually go first across seeds")


# ---- Traveler's Boots: FIRST_TURN_EXTRA_DRAW ---------------------------------------------------


func test_first_turn_extra_draw_applies_even_on_the_games_very_first_turn() -> void:
	# Compared against a baseline (same seed, no modifier) rather than an absolute hand size,
	# since turn 1 also deals a normal opening hand before any of this runs.
	var baseline: GameState = _game([], [], 1, false)
	var boosted: GameState = _game([CardBuilder.modifier(Modifier.Kind.FIRST_TURN_EXTRA_DRAW, 1)], [], 1, false)
	assert_eq(boosted.active, 0)
	assert_eq(boosted.players[0].hand.size(), baseline.players[0].hand.size() + 1, "turn 1 normally draws 0 (first player skips it) - the modifier still grants 1 extra")


func test_first_turn_extra_draw_does_not_apply_again_on_a_later_turn() -> void:
	var baseline: GameState = _game([], [], 1, false)
	var boosted: GameState = _game([CardBuilder.modifier(Modifier.Kind.FIRST_TURN_EXTRA_DRAW, 1)], [], 1, false)
	for game: GameState in [baseline, boosted]:
		GameFactory.pass_turn(game) # P1's turn
		GameFactory.pass_turn(game) # P0's turn 3 (P0's second turn)
	assert_eq(boosted.active, 0)
	assert_eq(boosted.players[0].hand.size(), baseline.players[0].hand.size() + 1, "still only +1 total - no repeat bonus on turn 3")


func test_first_turn_extra_draw_also_applies_to_whoever_goes_second() -> void:
	var baseline: GameState = _game([], [], 1, false)
	var boosted: GameState = _game([], [CardBuilder.modifier(Modifier.Kind.FIRST_TURN_EXTRA_DRAW, 1)], 1, false)
	for game: GameState in [baseline, boosted]:
		GameFactory.pass_turn(game) # P1's first turn begins
	assert_eq(boosted.active, 1)
	assert_eq(boosted.players[1].hand.size(), baseline.players[1].hand.size() + 1, "normal turn-2 draw plus the modifier's +1")


# ---- Hover Boots: GRANT_KEYWORD_TO_CREATURES + CANNOT_BLOCK ------------------------------------


## Note: GameFactory.add_to_field() deliberately bypasses _enter_field() (so tests can
## place board fixtures without triggering ON_ENTER etc.) - that also skips the equipment-grant
## hook these two tests target, so both play a real unit from hand instead, exactly like a
## real game would.
func test_grant_keyword_to_units_gives_flying_to_a_newly_entered_unit() -> void:
	var game: GameState = _game([CardBuilder.modifier(Modifier.Kind.GRANT_KEYWORD_TO_UNITS, int(CardEnums.Keyword.FLYING))])
	GameFactory.add_infrastructure_cards(game, 0, 1)
	var hand_card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2))
	assert_true(game.play_card(0, hand_card.uid))
	var unit: CardInstance = game.players[0].find_field(hand_card.uid)
	assert_true(unit.has_keyword(CardEnums.Keyword.FLYING))
	var unaffected: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	assert_false(unaffected.has_keyword(CardEnums.Keyword.FLYING), "the opponent's unit is unaffected")


func test_cannot_block_modifier_unit_can_never_be_declared_as_blocker() -> void:
	var game: GameState = _game([], [CardBuilder.modifier(Modifier.Kind.CANNOT_BLOCK, 1)])
	var attacker: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	GameFactory.add_infrastructure_cards(game, 1, 1)
	var grounded_in_hand: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(5, 5))
	GameFactory.pass_turn(game) # P1's main phase, so P1 can play
	assert_true(game.play_card(1, grounded_in_hand.uid))
	var grounded: CardInstance = game.players[1].find_field(grounded_in_hand.uid)
	assert_true(grounded.cannot_block)
	assert_false(CombatResolver.possible_blockers(game, 1).has(grounded), "cannot appear as a possible blocker at all")
	GameFactory.pass_turn(game) # back to P0's turn, so P0 can attack
	attacker.summoning_sick = false
	game.advance_phase() # MAIN1 -> COMBAT
	assert_true(game.declare_attackers([attacker.uid]))
	assert_false(game.declare_blockers({attacker.uid: grounded.uid}), "cannot be assigned as a blocker either")


# ---- Big Brain Beret: MAX_NON_INFRASTRUCTURE_CASTS_PER_TURN ---------------------------------------------


func test_non_infrastructure_play_cap_blocks_a_second_non_infrastructure_card_but_allows_a_infrastructure() -> void:
	var game: GameState = _game([CardBuilder.modifier(Modifier.Kind.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN, 1)])
	GameFactory.add_infrastructure_cards(game, 0, 3)
	var first: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	var second: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	var infra: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.infra())
	assert_true(game.play_card(0, first.uid))
	assert_false(game.can_play_card(0, second.uid), "the one-non-infrastructure-card-per-turn cap")
	assert_true(game.can_play_infrastructure(0, infra.uid), "playing an infrastructure is unaffected by the cap")
	assert_true(game.play_infrastructure(0, infra.uid))


func test_non_infrastructure_play_cap_resets_next_turn() -> void:
	var game: GameState = _game([CardBuilder.modifier(Modifier.Kind.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN, 1)])
	GameFactory.add_infrastructure_cards(game, 0, 2)
	var first: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	assert_true(game.play_card(0, first.uid))
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_eq(game.active, 0)
	var second: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	assert_true(game.can_play_card(0, second.uid), "a fresh turn resets the cap")


# ---- Thorned Loincloth: RETALIATE_ON_ATTACK ----------------------------------------------------


func test_retaliate_on_attack_damages_the_attacker_when_declared() -> void:
	var game: GameState = _game([_effect_mod(Modifier.Kind.RETALIATE_ON_ATTACK, CardEnums.EffectOp.DEAL_DAMAGE, 1, CardEnums.TargetKind.ALL_ATTACKERS)])
	# P0 (the defender-to-be, holding Thorned Loincloth) passes the turn to P1, who attacks P0.
	var attacker: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(3, 3))
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	game.advance_phase() # MAIN1 -> COMBAT
	assert_true(game.declare_attackers([attacker.uid]))
	assert_eq(attacker.damage, 1, "Thorned Loincloth retaliates for 1 the instant the attack is declared")


func test_retaliate_on_attack_fires_even_if_the_attacker_is_ultimately_unblocked() -> void:
	var game: GameState = _game([_effect_mod(Modifier.Kind.RETALIATE_ON_ATTACK, CardEnums.EffectOp.DEAL_DAMAGE, 5, CardEnums.TargetKind.ALL_ATTACKERS)])
	var attacker: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	GameFactory.pass_turn(game)
	game.advance_phase()
	assert_true(game.declare_attackers([attacker.uid]))
	assert_false(game.players[1].field.has(attacker), "5 damage on a 2/2 kills it before it even connects")
