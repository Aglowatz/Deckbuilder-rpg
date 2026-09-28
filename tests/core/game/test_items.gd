extends GutTest
## New brief, Part F: GameState.can_use_item/use_item - resolving an equipped item's effect
## against a live duel. Items are gear, not cards: no mana cost, no hand/battlefield involvement.

func _item(op: CardEnums.EffectOp, target: CardEnums.TargetKind, amount: int, amount2: int = 0, duration: CardEnums.Duration = CardEnums.Duration.PERMANENT) -> ItemData:
	var data: ItemData = ItemData.new()
	data.id = "test_item"
	data.display_name = "Test Item"
	data.uses = 1
	data.effect = CardBuilder.effect(CardEnums.Trigger.ON_ENTER, target, op, amount, amount2, duration)
	return data


func test_heals_the_player() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[0].life = 5
	var item: ItemData = _item(CardEnums.EffectOp.GAIN_LIFE, CardEnums.TargetKind.CONTROLLER, 4)
	assert_true(game.can_use_item(0, item))
	assert_true(game.use_item(0, item))
	assert_eq(game.players[0].life, 9)


func test_draws_a_card() -> void:
	var game: GameState = GameFactory.blank_game()
	var before: int = game.players[0].hand.size()
	var item: ItemData = _item(CardEnums.EffectOp.DRAW, CardEnums.TargetKind.CONTROLLER, 1)
	assert_true(game.use_item(0, item))
	assert_eq(game.players[0].hand.size(), before + 1)


func test_only_usable_in_the_items_owners_main_phase() -> void:
	var game: GameState = GameFactory.blank_game()
	var item: ItemData = _item(CardEnums.EffectOp.GAIN_LIFE, CardEnums.TargetKind.CONTROLLER, 4)
	assert_true(game.can_use_item(0, item), "player 0's own main phase")
	assert_false(game.can_use_item(1, item), "not player 1's turn")
	game.advance_phase()
	assert_false(game.can_use_item(0, item), "no longer main phase (combat)")


func test_deal_damage_to_a_chosen_creature() -> void:
	var game: GameState = GameFactory.blank_game()
	var creature: CardInstance = GameFactory.add_to_battlefield(game, 1, CardBuilder.creature("foe", "Foe", Affinity.Type.A, 1, [], 3, 5))
	var item: ItemData = _item(CardEnums.EffectOp.DEAL_DAMAGE, CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY, 3)
	assert_true(game.can_use_item(0, item))
	assert_true(game.use_item(0, item, creature.uid))
	assert_eq(creature.damage, 3)


func test_targeted_item_with_no_legal_target_cannot_be_used() -> void:
	var game: GameState = GameFactory.blank_game()
	var item: ItemData = _item(CardEnums.EffectOp.DEAL_DAMAGE, CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY, 3)
	assert_false(game.can_use_item(0, item), "no enemy creatures on board")
	assert_false(game.use_item(0, item, 1))


func test_targeted_item_rejects_an_illegal_target() -> void:
	var game: GameState = GameFactory.blank_game()
	var ally: CardInstance = GameFactory.add_to_battlefield(game, 0, CardBuilder.creature("ally", "Ally", Affinity.Type.A, 1, [], 2, 2))
	var item: ItemData = _item(CardEnums.EffectOp.DEAL_DAMAGE, CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY, 3)
	assert_false(game.use_item(0, item, ally.uid), "ally is not a legal enemy target")


## New brief, Part F: every real item in the content set actually resolves - not just the
## hand-built fixtures above. A board with a creature on each side covers every target kind the
## 13 items use (CONTROLLER/OPPONENT auto-resolve; CHOSEN_CREATURE_ALLY/ENEMY need one to pick).
func test_every_real_item_resolves_without_crashing() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	assert_gt(content.items.size(), 0, "content should have items to test")
	for id: Variant in content.items.keys():
		var item: ItemData = content.item(str(id))
		var game: GameState = GameFactory.blank_game()
		var ally: CardInstance = GameFactory.add_to_battlefield(game, 0, CardBuilder.creature("ally", "Ally", Affinity.Type.A, 1, [], 2, 2))
		GameFactory.add_to_battlefield(game, 1, CardBuilder.creature("foe", "Foe", Affinity.Type.A, 1, [], 2, 2))
		var target: int = 0
		if item.effect.needs_chosen_target():
			var options: Array[int] = game.legal_targets(0, item.effect, 0)
			assert_false(options.is_empty(), "%s should have a legal target on a normal board" % item.id)
			if options.is_empty():
				continue
			target = options[0]
		assert_true(game.can_use_item(0, item), "%s should be usable in the owner's main phase" % item.id)
		assert_true(game.use_item(0, item, target), "%s should resolve" % item.id)


func test_buff_a_creature_for_the_turn() -> void:
	var game: GameState = GameFactory.blank_game()
	var creature: CardInstance = GameFactory.add_to_battlefield(game, 0, CardBuilder.creature("mine", "Mine", Affinity.Type.A, 1, [], 2, 2))
	var item: ItemData = _item(CardEnums.EffectOp.BUFF, CardEnums.TargetKind.CHOSEN_CREATURE_ALLY, 2, 2, CardEnums.Duration.END_OF_TURN)
	assert_true(game.use_item(0, item, creature.uid))
	assert_eq(game.get_power(creature), 4)
	assert_eq(game.get_toughness(creature), 4)
	assert_eq(creature.power_bonus, 0, "END_OF_TURN duration should not be permanent")
