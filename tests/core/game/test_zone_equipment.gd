extends GutTest
## Brief 8, Part C: the four new modifier hooks (END_OF_TURN_EFFECT, ON_CREATURE_ENTER_EFFECT, LIFE_GAIN_BONUS,
## ON_ALLY_DEATH_EFFECT) and the four zone equipment pieces built on them, plus how each is obtained.


func _source(mods: Array[Modifier]) -> ModifierSource:
	return CardBuilder.modifier_source("Test Gear", ModifierSource.SourceKind.EQUIPMENT, mods)


func _game(p0_mods: Array[Modifier] = []) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 3
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [_source(p0_mods)] as Array[ModifierSource], "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	for player: PlayerState in game.players:
		player.hand.clear()
	return game


func _piece_mods(id: String) -> Array[Modifier]:
	var piece: EquipmentData = ProgressionContent.zone_equipment()[id] as EquipmentData
	return piece.modifiers


# ---- The four pieces exist, with varied slots, icons and flavor ---------------------------------------


func test_each_zone_has_one_more_piece_in_a_different_slot() -> void:
	var pieces: Dictionary = ProgressionContent.zone_equipment()
	var expected: Dictionary = {
		"compliance_clipboard": EquipmentData.Slot.RELIC,
		"spotters_barbell": EquipmentData.Slot.WEAPON,
		"head_chef_toque": EquipmentData.Slot.HELM,
		"compost_boots": EquipmentData.Slot.BOOTS,
	}
	var slots: Dictionary = {}
	for id: String in expected.keys():
		assert_true(pieces.has(id), "%s exists" % id)
		var piece: EquipmentData = pieces[id] as EquipmentData
		assert_eq(piece.slot, expected[id])
		assert_false(piece.description.is_empty(), "%s has a description" % id)
		assert_false(piece.flavor_text.is_empty(), "%s has flavor text" % id)
		assert_true(piece.tooltip_text().contains(piece.flavor_text), "the tooltip shows the flavor")
		assert_true(CardIcons.BY_EQUIPMENT_ID.has(id), "%s has an icon" % id)
		assert_not_null(CardIcons.for_equipment(piece), "%s icon loads" % id)
		assert_eq(piece.modifiers.size(), 1)
		slots[piece.slot] = true
	assert_eq(slots.size(), 4, "four different slots")
	for id: String in ["head_chef_ladle", "seed_satchel", "swole_belt", "courier_lanyard"]:
		assert_true(CardIcons.BY_EQUIPMENT_ID.has(id), "the puzzle reward %s has an icon too" % id)


func test_each_piece_uses_a_different_new_hook() -> void:
	var kinds: Dictionary = {}
	for id: String in ["compliance_clipboard", "spotters_barbell", "head_chef_toque", "compost_boots"]:
		kinds[(_piece_mods(id)[0] as Modifier).kind] = true
	assert_eq(kinds.size(), 4)
	assert_true(kinds.has(Modifier.Kind.END_OF_TURN_EFFECT))
	assert_true(kinds.has(Modifier.Kind.ON_UNIT_ENTER_EFFECT))
	assert_true(kinds.has(Modifier.Kind.HP_GAIN_BONUS))
	assert_true(kinds.has(Modifier.Kind.ON_ALLY_DEATH_EFFECT))


# ---- The hooks ----------------------------------------------------------------------------------------------


func test_compliance_clipboard_drains_the_opponent_at_the_end_of_your_turn_only() -> void:
	var game: GameState = _game(_piece_mods("compliance_clipboard"))
	var before: int = game.players[1].hp
	assert_eq(game.active, 0)
	GameFactory.pass_turn(game)
	assert_eq(game.players[1].hp, before - 1, "the opponent lost 1 HP when my turn ended")
	assert_eq(game.players[0].hp, game.players[0].max_hp, "I lost nothing")
	GameFactory.pass_turn(game)
	assert_eq(game.players[1].hp, before - 1, "their turn ending does nothing for me")
	GameFactory.pass_turn(game)
	assert_eq(game.players[1].hp, before - 2, "it fires every one of my turns")


func test_spotters_barbell_hits_the_opponent_whenever_a_unit_enters() -> void:
	var game: GameState = _game(_piece_mods("spotters_barbell"))
	var before: int = game.players[1].hp
	game.create_token(0, GameFactory.vanilla(1, 1))
	assert_eq(game.players[1].hp, before - 1, "one unit entered: 1 damage")
	game.create_token(0, GameFactory.vanilla(1, 1))
	assert_eq(game.players[1].hp, before - 2)
	game.create_token(1, GameFactory.vanilla(1, 1))
	assert_eq(game.players[1].hp, before - 2, "the opponent's unit entering does not count")


func test_head_chefs_toque_adds_one_to_every_hp_gain() -> void:
	var game: GameState = _game(_piece_mods("head_chef_toque"))
	game.players[0].hp = 5
	game.gain_hp(0, 2)
	assert_eq(game.players[0].hp, 8, "2 + 1 extra")
	game.gain_hp(0, 0)
	assert_eq(game.players[0].hp, 8, "gaining nothing stays nothing")
	game.players[1].hp = 5
	game.gain_hp(1, 2)
	assert_eq(game.players[1].hp, 7, "the opponent has no toque")


func test_compost_boots_grow_your_units_when_one_of_yours_dies() -> void:
	var game: GameState = _game(_piece_mods("compost_boots"))
	var survivor: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	var doomed: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(1, 1))
	var enemy: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(1, 1))
	var defense: int = game.get_defense(survivor)
	game.destroy_unit(doomed)
	assert_eq(game.get_defense(survivor), defense + 1, "the survivor grew +0/+1 permanently")
	game.destroy_unit(enemy)
	assert_eq(game.get_defense(survivor), defense + 1, "an enemy dying does nothing")


# ---- Getting them ---------------------------------------------------------------------------------------------


func test_each_piece_is_a_quest_reward_in_its_own_zone_and_nowhere_in_the_equipment_vendor() -> void:
	var rewards: Dictionary = {
		"dna_audit": "compliance_clipboard", "gain_lanes": "spotters_barbell",
		"buf_pie": "head_chef_toque", "heap_dam": "compost_boots",
	}
	for quest_id: String in rewards.keys():
		var quest: QuestData = QuestCatalog.find(quest_id)
		assert_not_null(quest, "quest %s exists" % quest_id)
		assert_true(quest.reward_equipment_ids.has(rewards[quest_id]), "%s rewards %s" % [quest_id, rewards[quest_id]])
	for id: Variant in rewards.values():
		assert_false(Session.content.equipment.has(str(id)), "%s is not sold by the equipment vendor" % str(id))
		assert_not_null(Session.content.equipment_piece(str(id)), "%s resolves through the content set" % str(id))


func test_turning_in_the_quest_grants_the_piece_once() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	var piece: EquipmentData = Session.content.equipment_piece("head_chef_toque")
	assert_false(Session.profile.owned_equipment.has(piece))
	assert_true(Session.grant_equipment(piece))
	assert_true(Session.profile.owned_equipment.has(piece))
	assert_false(Session.grant_equipment(piece), "one time only")
