extends GutTest

const Trig := CardEnums.Trigger
const Tgt := CardEnums.TargetKind
const Op := CardEnums.EffectOp
const NO_PIPS: Array[Affinity.Type] = []


func _trap(trigger: CardEnums.Trigger, target: CardEnums.TargetKind, op: CardEnums.EffectOp, amount: int = 0) -> CardData:
	var card: CardData = CardBuilder.trap("test_trap", "Test Trap", Affinity.Type.A, 1, NO_PIPS)
	CardBuilder.with_effect(card, CardBuilder.effect(trigger, target, op, amount))
	return card


## P0 sets `trap_data`, then it is P1's main phase 1 with 4 lands and nothing else.
func _set_trap_then_opponent_turn(trap_data: CardData) -> GameState:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 2)
	GameFactory.add_lands(game, 1, 4)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, trap_data)
	assert_true(game.cast(0, card.uid))
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	return game


func test_setting_a_trap_is_face_down_and_uses_a_card_slot() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 1)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, _trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY))
	assert_true(game.cast(0, card.uid))
	assert_eq(game.players[0].traps.size(), 1)
	assert_true(card.face_down)
	assert_eq(game.players[0].graveyard.size(), 0)


func test_traps_can_only_be_set_on_your_own_turn_in_main_phase() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 1, 2)
	var theirs: CardInstance = GameFactory.add_to_hand(game, 1, _trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY))
	assert_false(game.cast(1, theirs.uid), "not P1's turn")
	GameFactory.add_lands(game, 0, 2)
	var mine: CardInstance = GameFactory.add_to_hand(game, 0, _trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY))
	game.advance_phase()
	assert_false(game.cast(0, mine.uid), "not in combat")


func test_attack_trap_destroys_the_strongest_attacker_before_blocks() -> void:
	var game: GameState = _set_trap_then_opponent_turn(_trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY))
	var small: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	var big: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(4, 4))
	game.advance_phase()
	game.declare_attackers([small.uid, big.uid] as Array[int])
	assert_eq(game.players[1].battlefield.size(), 1)
	assert_eq(game.players[1].battlefield[0], small)
	assert_eq(game.attackers, [small.uid] as Array[int])
	assert_eq(game.players[0].traps.size(), 0)
	assert_eq(game.players[0].graveyard.size(), 1, "spent trap goes to the graveyard")
	assert_eq(GameFactory.count_events(game, GameEvent.Type.TRAP_TRIGGERED), 1)
	game.declare_blockers({})
	assert_eq(game.players[0].life, 9)


func test_attack_trap_killing_the_only_attacker_ends_combat() -> void:
	var game: GameState = _set_trap_then_opponent_turn(_trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY))
	var lone: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2))
	game.advance_phase()
	game.declare_attackers([lone.uid] as Array[int])
	assert_eq(game.phase, GameState.Phase.MAIN2)
	assert_eq(game.players[0].life, 10)


func test_attack_trap_hitting_all_attackers() -> void:
	var game: GameState = _set_trap_then_opponent_turn(_trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.ALL_ATTACKERS, Op.DEAL_DAMAGE, 1))
	var a: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	var b: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2))
	game.advance_phase()
	game.declare_attackers([a.uid, b.uid] as Array[int])
	assert_eq(game.players[1].battlefield.size(), 1)
	assert_eq(b.damage, 1)


func test_trap_only_triggers_once() -> void:
	var game: GameState = _set_trap_then_opponent_turn(_trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY))
	var a: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	game.advance_phase()
	game.declare_attackers([a.uid] as Array[int])
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	var b: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	game.advance_phase()
	assert_true(game.declare_attackers([b.uid] as Array[int]))
	assert_eq(game.players[1].battlefield.size(), 1, "second attacker was not destroyed")
	assert_eq(GameFactory.count_events(game, GameEvent.Type.TRAP_TRIGGERED), 1)


func test_creature_cast_trap_destroys_it_before_its_enter_effect() -> void:
	var game: GameState = _set_trap_then_opponent_turn(_trap(Trig.TRAP_OPPONENT_CREATURE, Tgt.TRIGGERING_CARD, Op.DESTROY))
	var draw: EffectData = CardBuilder.effect(Trig.ON_ENTER, Tgt.CONTROLLER, Op.DRAW, 1)
	var data: CardData = CardBuilder.creature("c", "C", Affinity.Type.A, 1, NO_PIPS, 2, 2)
	CardBuilder.with_effect(data, draw)
	var card: CardInstance = GameFactory.add_to_hand(game, 1, data)
	var hand_before: int = game.players[1].hand.size()
	assert_true(game.cast(1, card.uid))
	assert_eq(game.players[1].battlefield.size(), 0)
	assert_eq(game.players[1].hand.size(), hand_before - 1, "no card drawn: the trap fired first")


func test_spell_cast_trap_punishes_the_caster() -> void:
	var game: GameState = _set_trap_then_opponent_turn(_trap(Trig.TRAP_OPPONENT_SPELL, Tgt.OPPONENT, Op.DEAL_DAMAGE, 3))
	var spell: CardData = CardBuilder.spell("s", "S", Affinity.Type.A, 1, NO_PIPS)
	var card: CardInstance = GameFactory.add_to_hand(game, 1, spell)
	game.cast(1, card.uid)
	assert_eq(game.players[1].life, 7, "the trap's controller's opponent (the caster) takes 3")


func test_player_damaged_trap_retaliates_against_the_damage_source() -> void:
	var game: GameState = _set_trap_then_opponent_turn(_trap(Trig.TRAP_PLAYER_DAMAGED, Tgt.TRIGGERING_CARD, Op.DEAL_DAMAGE, 5))
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 3))
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	game.declare_blockers({})
	assert_eq(game.players[0].life, 8)
	assert_eq(game.players[1].battlefield.size(), 0, "attacker took 5 from the trap")


func test_traps_do_not_fire_on_their_owners_own_actions() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 4)
	var trap: CardInstance = GameFactory.add_to_hand(game, 0, _trap(Trig.TRAP_OPPONENT_CREATURE, Tgt.TRIGGERING_CARD, Op.DESTROY))
	game.cast(0, trap.uid)
	var mine: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	assert_true(game.cast(0, mine.uid))
	assert_eq(game.players[0].battlefield.size(), 1)
	assert_eq(game.players[0].traps.size(), 1)


func test_two_traps_can_trigger_on_the_same_event() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 4)
	GameFactory.add_lands(game, 1, 4)
	for i: int in range(2):
		var trap: CardInstance = GameFactory.add_to_hand(game, 0, _trap(Trig.TRAP_OPPONENT_SPELL, Tgt.OPPONENT, Op.DEAL_DAMAGE, 1))
		game.cast(0, trap.uid)
	GameFactory.pass_turn(game)
	var spell: CardInstance = GameFactory.add_to_hand(game, 1, CardBuilder.spell("s", "S", Affinity.Type.A, 0, NO_PIPS))
	game.cast(1, spell.uid)
	assert_eq(game.players[1].life, 8)


func test_ai_clone_can_hide_traps() -> void:
	var game: GameState = _set_trap_then_opponent_turn(_trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY))
	var hidden: GameState = game.clone(false, 0)
	var attacker: CardInstance = GameFactory.add_to_battlefield(hidden, 1, GameFactory.vanilla(1, 1))
	hidden.advance_phase()
	hidden.declare_attackers([attacker.uid] as Array[int])
	assert_eq(hidden.players[1].battlefield.size(), 1, "clone with hidden trap: attacker lives")


func test_at_most_three_traps_can_be_set() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 6)
	var cards: Array[CardInstance] = []
	for i: int in range(4):
		cards.append(GameFactory.add_to_hand(game, 0, _trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY)))
	for i: int in range(3):
		assert_true(game.cast(0, cards[i].uid), "trap %d can be set" % i)
	assert_false(game.can_cast(0, cards[3].uid), "a fourth trap cannot be set")
	assert_false(game.cast(0, cards[3].uid))
	assert_eq(game.players[0].traps.size(), GameState.MAX_TRAPS)


func test_max_traps_is_a_modifiable_stat_not_a_hardcoded_limit() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 8)
	game.players[0].max_traps = GameState.MAX_TRAPS + 1
	var cards: Array[CardInstance] = []
	for i: int in range(4):
		cards.append(GameFactory.add_to_hand(game, 0, _trap(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY)))
	for i: int in range(4):
		assert_true(game.cast(0, cards[i].uid), "trap %d can be set with a raised cap" % i)
	assert_eq(game.players[0].traps.size(), GameState.MAX_TRAPS + 1)
