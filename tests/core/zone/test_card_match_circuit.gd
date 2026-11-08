extends GutTest
## Overnight Nov 7-8, Part 6.3: the Cardsharp's Circuit - a card-art matching table in each Path zone, one questline, Dex's Lucky Spats
## (boots: the slot with the fewest pieces) whose rule draws a copy of the turn's first non-Infrastructure card.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_every_path_zone_has_dex_and_a_table_of_its_own_cards() -> void:
	for zone_id: String in CardMatchCircuit.ZONES:
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		var has_spot: bool = false
		for spot: Dictionary in def.spots:
			has_spot = has_spot or str(spot.get("kind", "")) == "cardsharp"
		assert_true(has_spot, "%s: Dex's spot" % zone_id)
		var ids: Array[String] = CardMatchCircuit.card_ids(zone_id, Session.content)
		assert_eq(ids.size(), MatchGame.PAIRS, "%s: eight pairs" % zone_id)
		for id: String in ids:
			assert_eq(Session.content.card(id).paths()[0], ZoneEffects.path_of(zone_id), "%s is a %s card" % [id, zone_id])
	assert_eq(CardMatchCircuit.card_ids(CardMatchCircuit.FINAL, Session.content).size(), MatchGame.PAIRS, "the final table: two of every Path")


func test_the_circuit_quest_runs_four_tables_then_the_final() -> void:
	var flags: Dictionary = {}
	assert_false(CardMatchCircuit.record(flags, "beefcake", true, CardMatchCircuit.TARGET_MOVES + 1), "over Dex's score")
	assert_true(CardMatchCircuit.record(flags, "beefcake", true, CardMatchCircuit.TARGET_MOVES))
	assert_false(CardMatchCircuit.record(flags, CardMatchCircuit.FINAL, true, 8), "the final waits for all four")
	for zone_id: String in ["necrocrat", "gourmand", "refusemancer"]:
		CardMatchCircuit.record(flags, zone_id, true, 10)
	assert_true(CardMatchCircuit.final_open(flags))
	assert_true(CardMatchCircuit.record(flags, CardMatchCircuit.FINAL, true, CardMatchCircuit.FINAL_TARGET_MOVES))
	var quest: QuestData = QuestCatalog.find(CardMatchCircuit.QUEST_ID)
	assert_not_null(quest)
	assert_eq(quest.objectives.size(), 5)
	assert_has(quest.reward_equipment_ids, CardMatchCircuit.PRIZE_ID)


func test_the_prize_is_boots_the_slot_with_the_fewest_pieces() -> void:
	var counts: Dictionary = {}
	for piece: EquipmentData in GearCatalog.all_pieces(Session.content):
		if piece.id != CardMatchCircuit.PRIZE_ID:
			counts[piece.slot] = int(counts.get(piece.slot, 0)) + 1
	var prize: EquipmentData = Session.content.equipment_piece(CardMatchCircuit.PRIZE_ID)
	assert_not_null(prize)
	for slot: Variant in counts.keys():
		assert_lte(int(counts[prize.slot]), int(counts[slot]), "boots had the fewest")
	assert_eq(prize.modifiers[0].kind, Modifier.Kind.DRAW_COPY_FIRST_PLAY)


func test_the_first_non_infrastructure_card_draws_a_copy_once_per_turn() -> void:
	var game: GameState = GameState.new()
	var player: PlayerState = PlayerState.new()
	game.players = [player, PlayerState.new()]
	player.modifiers.add_source(CardBuilder.modifier_source("Spats", ModifierSource.SourceKind.EQUIPMENT, [CardBuilder.modifier(Modifier.Kind.DRAW_COPY_FIRST_PLAY, 1)] as Array[Modifier]))
	var card: CardData = Session.content.card("B-10")
	var played: CardInstance = game.create_instance(card, 0)
	player.deck.append(game.create_instance(Session.content.card("C-01"), 0))
	player.deck.append(game.create_instance(card, 0))
	game._echo_first_play(0, played)
	assert_eq(player.hand.size(), 1, "the copy was drawn")
	assert_eq(player.hand[0].data.id, "B-10")
	player.deck.append(game.create_instance(card, 0))
	game._echo_first_play(0, game.create_instance(card, 0))
	assert_eq(player.hand.size(), 1, "only the first card each turn")
	var game2: GameState = GameState.new()
	var p2: PlayerState = PlayerState.new()
	game2.players = [p2, PlayerState.new()]
	p2.modifiers.add_source(CardBuilder.modifier_source("Spats", ModifierSource.SourceKind.EQUIPMENT, [CardBuilder.modifier(Modifier.Kind.DRAW_COPY_FIRST_PLAY, 1)] as Array[Modifier]))
	game2._echo_first_play(0, game2.create_instance(card, 0))
	assert_eq(p2.hand.size(), 0, "no copy in the deck: nothing happens")
