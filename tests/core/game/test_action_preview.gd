extends GutTest
## Overnight Oct 30-31, Part 4: the preview of the player's OWN targeted action (a damage or buff card aimed at a unit or a player): the
## numbers match the real result, the real game never changes, and nothing of the opponent's is played or read.

const Trig := CardEnums.Trigger
const Tgt := CardEnums.TargetKind
const Op := CardEnums.EffectOp
const NO_PIPS: Array[Affinity.Type] = []


func _spell(target: CardEnums.TargetKind, op: CardEnums.EffectOp, amount: int, amount2: int = 0) -> CardData:
	var card: CardData = CardBuilder.spell("test_spell", "Test Spell", Affinity.Type.BEEFCAKE, 0, NO_PIPS)
	CardBuilder.with_effect(card, CardBuilder.effect(Trig.ON_ENTER, target, op, amount, amount2, CardEnums.Duration.PERMANENT))
	return card


func _game() -> GameState:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_infrastructure_cards(game, 0, 6)
	GameFactory.add_infrastructure_cards(game, 1, 6)
	return game


func test_damage_on_a_unit_shows_the_hp_left_and_leaves_the_game_alone() -> void:
	var game: GameState = _game()
	var victim: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 5))
	var bolt: CardInstance = GameFactory.add_to_hand(game, 0, _spell(Tgt.CHOSEN_UNIT_ENEMY, Op.DEAL_DAMAGE, 2))
	var preview: Dictionary = CombatPreview.predict_action(game, 0, GameAction.play_card(0, bolt.uid, victim.uid))
	assert_true(bool(preview["valid"]))
	var entry: Dictionary = (preview["units"] as Dictionary)[victim.uid] as Dictionary
	assert_eq(int(entry["damage"]), 2)
	assert_eq(int(entry["hp_left"]), 3, "5 defense - 2 = 3 left")
	assert_false(bool(entry["dies"]))
	assert_eq(CombatPreview.badge_text(entry), "-2 (3 left)")
	assert_eq(victim.damage, 0, "the real unit is untouched")
	assert_not_null(game.players[0].find_hand(bolt.uid), "the card is still in the hand")
	assert_true(game.play_card(0, bolt.uid, victim.uid))
	assert_eq(victim.damage, 2, "the real result agrees")


func test_lethal_damage_on_a_unit_marks_it_dead() -> void:
	var game: GameState = _game()
	var victim: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	var bolt: CardInstance = GameFactory.add_to_hand(game, 0, _spell(Tgt.CHOSEN_UNIT_ENEMY, Op.DEAL_DAMAGE, 3))
	var preview: Dictionary = CombatPreview.predict_action(game, 0, GameAction.play_card(0, bolt.uid, victim.uid))
	var entry: Dictionary = (preview["units"] as Dictionary)[victim.uid] as Dictionary
	assert_true(bool(entry["dies"]))
	assert_eq(int(entry["damage"]), 2, "the damage it can take: its 2 HP")


func test_damage_to_the_opponent_counts_for_lethal() -> void:
	var game: GameState = _game()
	game.players[1].hp = 3
	var bolt: CardInstance = GameFactory.add_to_hand(game, 0, _spell(Tgt.CHOSEN_PLAYER, Op.DEAL_DAMAGE, 3))
	var preview: Dictionary = CombatPreview.predict_action(game, 0, GameAction.play_card(0, bolt.uid, Targets.player(1)))
	assert_eq(int((preview["players"] as Array)[1]), 3)
	assert_true(int((preview["players"] as Array)[1]) >= game.players[1].hp, "lethal")
	assert_eq(game.players[1].hp, 3, "the real opponent is untouched")


func test_a_buff_shows_the_new_stats() -> void:
	var game: GameState = _game()
	var friend: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	var buff: CardInstance = GameFactory.add_to_hand(game, 0, _spell(Tgt.CHOSEN_UNIT_ALLY, Op.BUFF, 2, 1))
	var preview: Dictionary = CombatPreview.predict_action(game, 0, GameAction.play_card(0, buff.uid, friend.uid))
	var entry: Dictionary = (preview["units"] as Dictionary)[friend.uid] as Dictionary
	assert_eq(int(entry["attack"]), 4)
	assert_eq(int(entry["defense"]), 3)
	assert_eq(CombatPreview.badge_text(entry), "+2/+1 -> 4/3")
	assert_eq(game.get_attack(friend), 2, "the real unit is untouched")


func test_only_the_viewers_own_action_is_previewed() -> void:
	var game: GameState = _game()
	var victim: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 5))
	var bolt: CardInstance = GameFactory.add_to_hand(game, 1, _spell(Tgt.CHOSEN_UNIT_ENEMY, Op.DEAL_DAMAGE, 2))
	var preview: Dictionary = CombatPreview.predict_action(game, 0, GameAction.play_card(1, bolt.uid, victim.uid))
	assert_false(bool(preview["valid"]), "an opponent's action is never played out for the viewer")


func test_an_illegal_target_gives_no_preview() -> void:
	var game: GameState = _game()
	var friend: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 5))
	var bolt: CardInstance = GameFactory.add_to_hand(game, 0, _spell(Tgt.CHOSEN_UNIT_ENEMY, Op.DEAL_DAMAGE, 2))
	var preview: Dictionary = CombatPreview.predict_action(game, 0, GameAction.play_card(0, bolt.uid, friend.uid))
	assert_false(bool(preview["valid"]))
