extends CardTestBase
## Group A: every card that targets a Refuse Pile gets exactly the legal cards (right pile, card type, cost/Path limits), the
## same list the targeting viewer shows and the AI chooses from.


## The card spec's refuse declarations: [{card, ability, decl}].
func _refuse_declarations() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for data: CardData in CardSet.all_cards():
		for ability: CardAbility in data.abilities():
			for decl: CardAbility.TargetDecl in ability.targets:
				if decl.spec.has_zone("refuse"):
					result.append({"card": data, "ability": ability, "decl": decl})
	return result


## A pile stocked with a unit of cost 1 / 3 / 5, a spell, a tool and a Necrocrat unit, for both players.
func _stock(game: GameState) -> void:
	for owner: int in range(2):
		for id: String in ["B-01", "N-07", "N-28", "C-25", "N-17", "GN-11"]:
			_bury(game, owner, id)
		_bury(game, owner, "R-14")


## What a spec means for one card, worked out independently of TargetResolver.
func _expected(spec: TargetSpec, card: CardInstance, controller: int) -> bool:
	if spec.side == "mine" and card.owner != controller:
		return false
	if spec.side == "opp" and card.owner == controller:
		return false
	if not spec.types.is_empty() and not spec.types.has("card"):
		var type_ok: bool = false
		for word: String in spec.types:
			match word:
				"unit":
					type_ok = type_ok or card.data.is_unit()
				"spell":
					type_ok = type_ok or card.data.type == CardEnums.CardType.SPELL
				"tool":
					type_ok = type_ok or card.data.is_tool()
				"wonder":
					type_ok = type_ok or card.data.is_wonder()
				"infra":
					type_ok = type_ok or card.data.is_infrastructure()
				"trap":
					type_ok = type_ok or card.data.type == CardEnums.CardType.TRAP
		if not type_ok:
			return false
	for filter: Dictionary in spec.filters:
		if str(filter.get("key", "")) == "cost" and filter["value"] is int:
			if not TargetSpec.compare(card.data.energy_value(), str(filter["op"]), int(filter["value"])):
				return false
		elif str(filter.get("key", "")) == "path":
			if not card.data.is_on_path(Affinity.from_symbol(str(filter["value"]))):
				return false
		else:
			fail_test("refuse filter %s on %s is not covered by this test; extend _expected" % [str(filter), spec.raw])
	return true


func test_there_are_cards_that_target_a_refuse_pile() -> void:
	assert_gt(_refuse_declarations().size(), 10, "the card set has many Refuse Pile targeting cards")


func test_every_refuse_pile_card_offers_exactly_the_legal_targets() -> void:
	for entry: Dictionary in _refuse_declarations():
		var data: CardData = entry["card"] as CardData
		var decl: CardAbility.TargetDecl = entry["decl"] as CardAbility.TargetDecl
		var game: GameState = _game()
		_stock(game)
		var source: CardInstance = game.create_instance(data, 0)
		game.players[0].hand.append(source)
		var ctx: AbilityContext = AbilityContext.make(game, entry["ability"] as CardAbility, source, 0)
		var legal: Array[int] = TargetResolver.legal_targets(decl, ctx)
		var expected: Array[int] = []
		for player: PlayerState in game.players:
			for card: CardInstance in player.refuse_pile:
				if _expected(decl.spec, card, 0):
					expected.append(card.uid)
		legal.sort()
		expected.sort()
		assert_eq(legal, expected, "%s (%s): legal Refuse Pile targets for '%s'" % [data.display_name, data.id, decl.spec.raw])
		for uid: int in legal:
			var found: CardInstance = game.find_card(uid)
			assert_not_null(found, "%s offers a real card" % data.id)
			var in_pile: bool = game.players[0].refuse_pile.has(found) or game.players[1].refuse_pile.has(found)
			assert_true(in_pile, "%s only offers cards that are in a Refuse Pile" % data.id)


func test_pile_side_follows_mine_opp_and_any() -> void:
	var saw_mine: bool = false
	var saw_any: bool = false
	for entry: Dictionary in _refuse_declarations():
		var decl: CardAbility.TargetDecl = entry["decl"] as CardAbility.TargetDecl
		var game: GameState = _game()
		_stock(game)
		var source: CardInstance = game.create_instance(entry["card"] as CardData, 0)
		var ctx: AbilityContext = AbilityContext.make(game, entry["ability"] as CardAbility, source, 0)
		var owners: Dictionary = {}
		for uid: int in TargetResolver.legal_targets(decl, ctx):
			owners[game.find_card(uid).owner] = true
		if decl.spec.side == "mine":
			saw_mine = true
			assert_false(owners.has(1), "%s: 'mine' never reaches the opponent's Refuse Pile" % (entry["card"] as CardData).id)
		elif decl.spec.side == "":
			saw_any = true
			assert_true(owners.has(0) and owners.has(1), "%s: 'any' offers both piles" % (entry["card"] as CardData).id)
	assert_true(saw_mine and saw_any, "the set has both own-pile and any-pile cards")


func test_grave_shift_worker_only_offers_units_costing_two_or_less() -> void:
	var game: GameState = _game()
	var cheap: CardInstance = _bury(game, 0, "B-01")
	var pricey: CardInstance = _bury(game, 0, "N-28")
	var spell: CardInstance = _bury(game, 0, "N-17")
	var worker: CardInstance = game.create_instance(CardSet.card("N-07"), 0)
	game.players[0].hand.append(worker)
	var ability: CardAbility = game.play_ability_of(worker.data)
	var legal: Array[int] = game.legal_play_targets(0, worker.uid, 0)
	assert_not_null(ability)
	assert_true(cheap.data.energy_value() <= 2 and pricey.data.energy_value() > 2)
	assert_true(legal.has(cheap.uid))
	assert_false(legal.has(pricey.uid), "a cost 4 unit is over the limit")
	assert_false(legal.has(spell.uid), "a spell is not a unit")


func test_lich_reaches_the_opponents_refuse_pile_and_takes_the_unit() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	var mine: CardInstance = _bury(game, 0, "B-01")
	var theirs: CardInstance = _bury(game, 1, "B-01")
	var lich: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("N-28"))
	var legal: Array[int] = game.legal_play_targets(0, lich.uid, 0)
	assert_true(legal.has(mine.uid) and legal.has(theirs.uid), "both piles are offered")
	assert_true(game.play_card(0, lich.uid, theirs.uid), "choosing the opponent's card works")
	assert_true(game.players[0].field.has(theirs), "it entered under your control")
	assert_false(game.players[1].refuse_pile.has(theirs))
	assert_true(game.players[0].refuse_pile.has(mine), "the card you did not choose stays put")


func test_return_target_unit_to_hand_from_your_refuse_pile() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	var dead: CardInstance = _bury(game, 0, "B-01")
	var enemy_dead: CardInstance = _bury(game, 1, "B-01")
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("N-17"))
	var legal: Array[int] = game.legal_play_targets(0, spell.uid, 0)
	assert_eq(legal, [dead.uid] as Array[int], "only your own unit: not the enemy's, not a spell")
	assert_true(game.play_card(0, spell.uid, dead.uid))
	assert_true(game.players[0].hand.has(dead), "returned to hand")
	assert_true(game.players[1].refuse_pile.has(enemy_dead))


func test_reinstate_spell_picks_a_unit_from_your_pile() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	var dead: CardInstance = _bury(game, 0, "B-01")
	_bury(game, 0, "N-17")
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("GN-11"))
	assert_eq(game.legal_play_targets(0, spell.uid, 0), [dead.uid] as Array[int])
	assert_true(game.play_card(0, spell.uid, dead.uid))
	assert_true(game.players[0].field.has(dead), "reinstated onto the field")


func test_shred_takes_up_to_three_cards_from_either_pile() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	var a: CardInstance = _bury(game, 0, "B-01")
	var b: CardInstance = _bury(game, 1, "B-01")
	var c: CardInstance = _bury(game, 1, "N-17")
	var d: CardInstance = _bury(game, 0, "N-07")
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("C-25"))
	var legal: Array[int] = game.legal_play_targets(0, spell.uid, 0)
	assert_eq(legal.size(), 4, "every card of both piles can be chosen")
	assert_true(game.play_card(0, spell.uid, a.uid, [] as Array[int], [b.uid, c.uid] as Array[int]))
	assert_false(game.players[0].refuse_pile.has(a))
	assert_false(game.players[1].refuse_pile.has(b))
	assert_false(game.players[1].refuse_pile.has(c))
	assert_true(game.players[0].refuse_pile.has(d), "the fourth card was not chosen")


func test_a_spell_cannot_be_played_when_its_pile_has_no_legal_target() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	_bury(game, 1, "B-01")
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("N-17"))
	assert_true(game.legal_play_targets(0, spell.uid, 0).is_empty(), "only the enemy pile has a unit")
	assert_false(game.can_play_card(0, spell.uid), "no legal target: not playable")


func test_ai_only_plays_refuse_pile_spells_on_legal_targets() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	_bury(game, 0, "B-01")
	_bury(game, 0, "N-17")
	_bury(game, 1, "B-01")
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("N-17"))
	var checked: int = 0
	for action: GameAction in game.legal_actions():
		if action.type == GameAction.Type.PLAY and action.card_uid == spell.uid:
			checked += 1
			var target: CardInstance = game.find_card(action.target)
			assert_not_null(target)
			assert_eq(target.owner, 0, "the AI's option is in its own pile")
			assert_true(target.data.is_unit(), "and a unit")
	assert_gt(checked, 0, "the AI is offered the spell")


func test_ai_chooses_from_the_same_pile_cards_the_viewer_lists() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	var dead: CardInstance = _bury(game, 0, "N-28")
	_bury(game, 0, "N-17")
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("GN-11"))
	var viewer_options: Array[int] = game.legal_play_targets(0, spell.uid, 0)
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var action: GameAction = ai.choose_action(game)
	if action.type == GameAction.Type.PLAY and action.card_uid == spell.uid:
		assert_true(viewer_options.has(action.target), "the AI's pick is one of the viewer's legal cards")
		assert_eq(action.target, dead.uid)
