extends GutTest
## Part G: the Grand Clashatorium - encounters, puzzle battles, restricted decks and rules, the arena equipment's new
## modifier hooks, first-clear prizes, the unlock rule, the colosseum and the UI.

var A: Affinity.Type = Affinity.Type.A


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(A)


func _equipment(id: String) -> EquipmentData:
	return Session.content.equipment_piece(id)


func _game_with_gear(piece: EquipmentData, starting_life: int = -1) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 5
	options.free_mulligan = false
	var profile: PlayerProfile = PlayerProfile.new()
	var gear: Array[ModifierSource] = []
	if piece != null:
		gear.append(piece)
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), profile, gear, "Gladiator")
	if starting_life > 0:
		setup.starting_life = starting_life
	var game: GameState = GameState.new(options)
	game.add_player(setup)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	return game


# ---- The encounters ----------------------------------------------------------------------------------


func test_there_are_eight_encounters_in_three_tiers_mixing_battles_and_puzzles() -> void:
	var all: Array[ArenaEncounter] = ArenaDefs.all()
	assert_eq(all.size(), 8)
	assert_eq(ArenaDefs.in_tier(1).size(), 3)
	assert_eq(ArenaDefs.in_tier(2).size(), 3)
	assert_eq(ArenaDefs.in_tier(3).size(), 2)
	var puzzles: int = 0
	var goals: Dictionary = {}
	for encounter: ArenaEncounter in all:
		if encounter.is_puzzle():
			puzzles += 1
		goals[encounter.goal] = true
	assert_gte(puzzles, 3)
	assert_lt(puzzles, all.size(), "challenging battles too")
	assert_true(goals.has(ArenaEncounter.Goal.WIN_THIS_TURN))
	assert_true(goals.has(ArenaEncounter.Goal.SURVIVE_TURNS))
	var restricted: int = 0
	var rule_fights: int = 0
	for encounter: ArenaEncounter in all:
		if encounter.uses_restricted_deck():
			restricted += 1
		if not encounter.player_rules.is_empty():
			rule_fights += 1
	assert_gte(restricted, 2, "restricted decks")
	assert_eq(rule_fights, 1, "win without casting creatures")
	assert_not_null(ArenaDefs.find("arena_marshal"))
	assert_null(ArenaDefs.find("nope"))


func test_every_deck_card_preset_prize_and_text_resolves() -> void:
	var story: StoryText = StoryText.shared()
	for encounter: ArenaEncounter in ArenaDefs.all():
		for key: String in [encounter.title_key(), encounter.blurb_key(), encounter.rules_key()]:
			assert_true(story.has_text(key), key)
		for recipe: Dictionary in [encounter.enemy_recipe, encounter.player_recipe]:
			for card_id: Variant in recipe.keys():
				if not str(card_id).begins_with("infrastructure:"):
					assert_not_null(Session.content.card(str(card_id)), "%s uses %s" % [encounter.id, str(card_id)])
		for side: Variant in encounter.preset.keys():
			for zone: String in ["hand", "battlefield", "graveyard"]:
				for card_id: Variant in ((encounter.preset[side] as Dictionary).get(zone, {}) as Dictionary).keys():
					assert_not_null(Session.content.card(str(card_id)), "%s preset %s" % [encounter.id, str(card_id)])
		var reward: Dictionary = encounter.reward
		assert_false(reward.is_empty(), "%s has a prize" % encounter.id)
		if reward.has("equipment"):
			assert_not_null(_equipment(str(reward["equipment"])), str(reward["equipment"]))
		if reward.has("item"):
			assert_not_null(Session.content.item(str(reward["item"])))
	for tier: int in range(1, 4):
		assert_true(story.has_text("arena.tier.%d" % tier))


func test_the_prizes_include_four_exclusive_equipment_gold_and_essence() -> void:
	var equipment_ids: Dictionary = {}
	var has_gold: bool = false
	var has_essence: bool = false
	for encounter: ArenaEncounter in ArenaDefs.all():
		if encounter.reward.has("equipment"):
			equipment_ids[str(encounter.reward["equipment"])] = true
		has_gold = has_gold or encounter.reward.has("gold")
		has_essence = has_essence or encounter.reward.has("essence")
	assert_eq(equipment_ids.size(), 4)
	for id: String in ArenaContent.IDS:
		assert_true(equipment_ids.has(id), id)
	assert_true(has_gold and has_essence)


# ---- Preset puzzles ------------------------------------------------------------------------------------


func _puzzle_game(encounter_id: String) -> GameState:
	var encounter: ArenaEncounter = ArenaDefs.find(encounter_id)
	return ArenaScenario.build_game(Session.content, encounter, Session.profile, Session.deck, 11)


func _hand_card(game: GameState, card_id: String) -> CardInstance:
	for card: CardInstance in game.players[0].hand:
		if card.data.id == card_id:
			return card
	return null


func _creature(game: GameState, player: int, card_id: String) -> CardInstance:
	for card: CardInstance in game.players[player].battlefield:
		if card.data.id == card_id:
			return card
	return null


func test_lethal_lunch_starts_on_the_preset_board() -> void:
	var game: GameState = _puzzle_game("arena_lethal_lunch")
	assert_eq(game.active, 0)
	assert_eq(game.turn, 1)
	assert_eq(game.players[1].life, 10)
	assert_eq(game.players[0].infrastructure.size(), 4)
	assert_eq(game.players[0].hand.size(), 3)
	assert_not_null(_creature(game, 0, "raider"))
	assert_not_null(_creature(game, 1, "sellsword"))
	assert_false(_creature(game, 0, "raider").summoning_sick, "preset creatures are ready to attack")


func test_lethal_lunch_has_a_win_this_turn_solution() -> void:
	var game: GameState = _puzzle_game("arena_lethal_lunch")
	var blocker: CardInstance = _creature(game, 1, "sellsword")
	assert_true(game.cast(0, _hand_card(game, "firebolt").uid, blocker.uid), "firebolt the only blocker")
	assert_true(game.cast(0, _hand_card(game, "warcry").uid), "pump the team")
	var attackers: Array[int] = [_creature(game, 0, "raider").uid, _creature(game, 0, "beefcake_imp").uid]
	assert_true(game.advance_phase(), "to combat")
	assert_true(game.declare_attackers(attackers))
	if not game.is_over():
		game.declare_blockers({})
	assert_true(game.is_over())
	assert_eq(game.winner, 0)
	assert_true(ArenaDefs.find("arena_lethal_lunch").player_won(game))


func test_lethal_lunch_is_lost_when_the_turn_ends_without_lethal() -> void:
	var game: GameState = _puzzle_game("arena_lethal_lunch")
	var steps: int = 0
	while not game.is_over() and steps < 20:
		steps += 1
		game.apply_action(GameAction.pass_phase(game.awaiting_player()))
	assert_true(game.is_over(), "the one-turn clock ended the game")
	assert_false(ArenaDefs.find("arena_lethal_lunch").player_won(game), "failing the puzzle is a loss")


func test_zero_to_hero_solution_clears_both_blockers_then_pumps() -> void:
	var game: GameState = _puzzle_game("arena_zero_to_hero")
	var sellsword: CardInstance = _creature(game, 1, "sellsword")
	var bat: CardInstance = _creature(game, 1, "cave_bat")
	assert_true(game.cast(0, _hand_card(game, "firebolt").uid, sellsword.uid))
	assert_true(game.cast(0, _hand_card(game, "rusty_curse").uid, bat.uid))
	assert_true(game.cast(0, _hand_card(game, "warcry").uid))
	assert_true(game.advance_phase())
	var attackers: Array[int] = [_creature(game, 0, "raider").uid, _creature(game, 0, "blade_dancer").uid, _creature(game, 0, "beefcake_imp").uid]
	assert_true(game.declare_attackers(attackers))
	if not game.is_over():
		game.declare_blockers({})
	assert_true(game.is_over())
	assert_true(ArenaDefs.find("arena_zero_to_hero").player_won(game))


func test_zero_to_hero_cannot_be_won_by_skipping_the_blockers() -> void:
	var game: GameState = _puzzle_game("arena_zero_to_hero")
	assert_true(game.cast(0, _hand_card(game, "warcry").uid))
	assert_true(game.advance_phase())
	var attackers: Array[int] = [_creature(game, 0, "raider").uid, _creature(game, 0, "blade_dancer").uid, _creature(game, 0, "beefcake_imp").uid]
	game.declare_attackers(attackers)
	if not game.is_over():
		var blocks: Dictionary = AIPlayer.new(AIPersonality.balanced()).choose_blocks(game, 1)
		game.declare_blockers(blocks)
	assert_ne(game.winner, 0, "blockers stop lethal: the puzzle needs the removal first")


func test_hold_the_line_is_won_by_surviving_not_by_killing() -> void:
	var encounter: ArenaEncounter = ArenaDefs.find("arena_hold_the_line")
	assert_eq(encounter.first_player, 1, "the enemy moves first")
	assert_eq(encounter.turn_limit(), 5, "the enemy's 3rd turn is game turn 5")
	var game: GameState = _puzzle_game("arena_hold_the_line")
	assert_eq(game.active, 1)
	# A drawn game (the clock ran out) with the player alive is a win; a dead player is not.
	game._end_game(-1, true)
	assert_true(encounter.player_won(game))
	var dead: GameState = _puzzle_game("arena_hold_the_line")
	dead.players[0].life = 0
	dead._end_game(1, false)
	assert_false(encounter.player_won(dead))


func _ai_plays(game: GameState, ai: AIPlayer, enemy_ai: AIPlayer) -> void:
	var steps: int = 0
	while not game.is_over() and steps < 3000:
		steps += 1
		var who: int = game.awaiting_player()
		var action: GameAction = (ai if who == 0 else enemy_ai).choose_action(game)
		if not game.apply_action(action):
			if not game.apply_action(GameAction.pass_phase(who)):
				break


func test_hold_the_line_is_survivable() -> void:
	var encounter: ArenaEncounter = ArenaDefs.find("arena_hold_the_line")
	var wins: int = 0
	for seed_value: int in range(1, 13):
		var game: GameState = ArenaScenario.build_game(Session.content, encounter, Session.profile, Session.deck, seed_value)
		_ai_plays(game, AIPlayer.new(AIPersonality.defensive()), AIPlayer.new(AIPersonality.aggressive()))
		assert_true(game.is_over())
		if encounter.player_won(game):
			wins += 1
	assert_gt(wins, 0, "a competent player can hold the line (%d of 12 seeds)" % wins)


func test_no_creature_casts_blocks_creatures_but_not_spells() -> void:
	var encounter: ArenaEncounter = ArenaDefs.find("arena_spells_only")
	var game: GameState = ArenaScenario.build_game(Session.content, encounter, Session.profile, Session.deck, 3)
	var creature: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, Session.content.card("flame_burst"))
	GameFactory.add_infrastructure_cards(game, 0, 4, A)
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	game.active = 0
	assert_false(game.can_cast(0, creature.uid), "creatures cannot be cast this duel")
	assert_true(game.can_cast(0, spell.uid), "spells can")


func test_spells_only_is_winnable_with_the_restricted_deck() -> void:
	var encounter: ArenaEncounter = ArenaDefs.find("arena_spells_only")
	var kit: Deck = ArenaScenario.player_deck(Session.content, encounter, Session.deck)
	assert_ne(kit, Session.deck, "the restricted kit replaces the player's deck")
	var wins: int = 0
	for seed_value: int in range(1, 13):
		var game: GameState = ArenaScenario.build_game(Session.content, encounter, Session.profile, Session.deck, seed_value)
		_ai_plays(game, AIPlayer.new(AIPersonality.aggressive()), AIPlayer.new(AIPersonality.balanced()))
		if encounter.player_won(game):
			wins += 1
	assert_gt(wins, 0, "burning the Colossus down with spells alone works (%d of 12 seeds)" % wins)


func test_the_neutral_mile_uses_only_the_gladiators_kit() -> void:
	var encounter: ArenaEncounter = ArenaDefs.find("arena_neutral_mile")
	var game: GameState = ArenaScenario.build_game(Session.content, encounter, Session.profile, Session.deck, 2)
	var seen: Dictionary = {}
	for zone: Array[CardInstance] in [game.players[0].hand, game.players[0].library]:
		for card: CardInstance in zone:
			if not card.data.is_infrastructure():
				seen[card.data.color] = true
	assert_eq(seen.keys(), [Affinity.Type.NEUTRAL], "only neutral spells in the kit")


# ---- The arena equipment's new hooks -----------------------------------------------------------------------------


func test_champions_laurels_gain_life_and_draw_at_the_start_of_the_duel() -> void:
	var plain: GameState = _game_with_gear(null, 5)
	var geared: GameState = _game_with_gear(_equipment("champions_laurels"), 5)
	assert_eq(geared.players[0].life, plain.players[0].life + 4)
	assert_eq(geared.players[0].hand.size() + geared.players[0].library.size(), plain.players[0].hand.size() + plain.players[0].library.size())
	assert_eq(geared.players[0].hand.size(), plain.players[0].hand.size() + 1, "and drew an extra card")


func test_the_crowd_pleasers_cape_heals_when_you_declare_attackers() -> void:
	var game: GameState = _game_with_gear(_equipment("crowd_pleasers_cape"), 5)
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(2, 2, 1), true)
	game.players[0].life = 5
	assert_true(game.advance_phase())
	assert_true(game.declare_attackers([attacker.uid] as Array[int]))
	assert_eq(game.players[0].life, 6, "+1 life for declaring an attack")


func test_the_gladiators_net_shrinks_enemy_creatures_as_they_enter() -> void:
	var game: GameState = _game_with_gear(_equipment("gladiators_net"))
	game.players[1].hand.clear()
	var foe_card: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(2, 2, 1))
	GameFactory.add_infrastructure_cards(game, 1, 2, A)
	game.active = 1
	game.phase = GameState.Phase.MAIN1
	assert_true(game.cast(1, foe_card.uid))
	assert_eq(game.get_power(foe_card), 1)
	assert_eq(game.get_toughness(foe_card), 1, "-1/-1 permanently")
	var mine: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 1))
	GameFactory.add_infrastructure_cards(game, 0, 2, A)
	game.active = 0
	game.phase = GameState.Phase.MAIN1
	assert_true(game.cast(0, mine.uid))
	assert_eq(game.get_power(mine), 2, "your own creatures are untouched")


func test_the_bloodsand_boots_draw_when_you_are_dealt_damage() -> void:
	var game: GameState = _game_with_gear(_equipment("bloodsand_boots"))
	var before: int = game.players[0].hand.size()
	game.deal_damage_to_player(0, 0, 2)
	assert_eq(game.players[0].hand.size(), before + 1, "dealt damage draws a card")
	game.lose_life(0, 1)
	assert_eq(game.players[0].hand.size(), before + 1, "mere life loss does not")


func test_arena_equipment_is_exclusive_and_has_icons_and_tooltips() -> void:
	for id: String in ArenaContent.IDS:
		var piece: EquipmentData = _equipment(id)
		assert_not_null(piece, id)
		assert_false(piece.flavor_text.is_empty())
		assert_true(piece.tooltip_text().contains(piece.description))
		assert_false(Session.content.equipment.has(id), "%s is never sold by the equipment vendor" % id)
	assert_eq(ArenaContent.IDS.size(), 4)


# ---- Prizes and unlocking ----------------------------------------------------------------------------------------


func _win(encounter_id: String) -> Dictionary:
	var context: BattleContext = Session.make_arena_battle(encounter_id)
	context.game._end_game(0, false)
	return Session.resolve_arena_battle(context)


func test_the_arena_opens_after_the_first_zone_is_completed() -> void:
	assert_false(Session.arena_unlocked())
	Session.complete_zone("beefcake")
	assert_true(Session.arena_unlocked())


func test_first_clear_pays_the_prize_once_then_only_replay_gold() -> void:
	Session.profile.essence.clear()
	var gold_before: int = Session.gold
	var first: Dictionary = _win("arena_warmup")
	assert_true(bool(first["first_clear"]))
	assert_true(Session.is_arena_cleared("arena_warmup"))
	assert_eq(Session.arena_cleared_count(), 1)
	assert_gte(Session.gold, gold_before + 90)
	assert_eq(Session.profile.essence_of(A), 5, "essence of the player's own Path")
	var gold_mid: int = Session.gold
	var again: Dictionary = _win("arena_warmup")
	assert_false(bool(again["first_clear"]))
	assert_eq(Session.gold, gold_mid + 15, "a replay pays only the small flat gold")
	assert_eq(Session.profile.essence_of(A), 5, "no second prize")


func test_equipment_prizes_are_granted_and_equippable() -> void:
	var result: Dictionary = _win("arena_hold_the_line")
	assert_eq(str((result["reward"] as Dictionary)["equipment"]), "champions_laurels")
	var piece: EquipmentData = _equipment("champions_laurels")
	assert_true(Session.profile.owned_equipment.has(piece))
	Session.profile.equipment_slots.append(EquipmentData.Slot.HELM)
	assert_true(Session.profile.equip(piece))


func test_losing_pays_nothing_and_can_be_retried() -> void:
	var context: BattleContext = Session.make_arena_battle("arena_marshal")
	context.game._end_game(1, false)
	var gold_before: int = Session.gold
	var result: Dictionary = Session.resolve_arena_battle(context)
	assert_false(bool(result["won"]))
	assert_false(Session.is_arena_cleared("arena_marshal"))
	assert_eq(Session.gold, gold_before)
	assert_true(_win("arena_marshal")["first_clear"], "and the retry still pays")


func test_cleared_state_is_saved() -> void:
	_win("arena_lethal_lunch")
	var data: Dictionary = Session.to_dict()
	Session.new_game()
	Session.ensure_game(A)
	assert_false(Session.is_arena_cleared("arena_lethal_lunch"))
	assert_true(Session.from_dict(data))
	assert_true(Session.is_arena_cleared("arena_lethal_lunch"))


func test_the_four_fists_pays_essence_of_every_path() -> void:
	Session.profile.essence.clear()
	_win("arena_four_fists")
	for path: Affinity.Type in Affinity.colored_types():
		assert_eq(Session.profile.essence_of(path), 4)


# ---- The building and the UI ---------------------------------------------------------------------------------------


func test_the_colosseum_is_built_with_a_gate_and_spot_in_the_town() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var building: Node3D = ArenaBuilding.build(root, Vector3.ZERO)
	assert_gt(building.get_child_count(), 80, "a ring of arches, seats, banners")
	var town: TownBuilder = TownBuilder.new()
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	town.build(parent, false)
	assert_true(town.anchors.has("arena") and town.anchors.has("arena_gate") and town.anchors.has("alchemist"))
	var gate: Vector3 = town.anchors["arena_gate"] as Vector3
	assert_true(town.is_walkable(town.anchors["arena"] as Vector3, 0.3), "the spot in front of the gate can be reached")
	assert_false(town.is_walkable(gate + Vector3(0, 0, 1.6), 0.3), "the colosseum itself is solid")


func test_the_arena_screen_lists_every_encounter_with_status_and_prize() -> void:
	Session.complete_zone("beefcake")
	_win("arena_warmup")
	var screen: ArenaScreen = ArenaScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	for encounter: ArenaEncounter in ArenaDefs.all():
		var row: Node = screen.find_child("ArenaRow_%s" % encounter.id, true, false)
		assert_not_null(row, encounter.id)
		assert_not_null(row.find_child("Fight_%s" % encounter.id, true, false))
	var cleared_row: Node = screen.find_child("ArenaRow_arena_warmup", true, false)
	assert_eq((cleared_row.find_child("Status", true, false) as Label).text, "CLEARED")
	var new_row: Node = screen.find_child("ArenaRow_arena_marshal", true, false)
	assert_eq((new_row.find_child("Status", true, false) as Label).text, "NEW")
	assert_true((new_row.find_child("PrizeText", true, false) as Label).text.contains("Bloodsand Boots"))
	watch_signals(screen)
	(new_row.find_child("Fight_arena_marshal", true, false) as FancyButton).pressed.emit()
	assert_signal_emitted_with_parameters(screen, "fight_chosen", ["arena_marshal"])
	assert_true((screen.find_child("Tier1", true, false) as Label).text == "Bronze Sand")


func test_the_result_banner_announces_the_prize() -> void:
	var result: Dictionary = _win("arena_marshal")
	var screen: ArenaScreen = ArenaScreen.new()
	screen.result = result
	add_child_autofree(screen)
	await wait_frames(3)
	assert_not_null(screen.find_child("ArenaResultBanner", true, false))
	assert_true((screen.find_child("ArenaPrizeLine", true, false) as Label).text.contains("Bloodsand Boots"))


func test_the_battle_hud_shows_the_arena_rules_banner() -> void:
	var game: GameState = _puzzle_game("arena_lethal_lunch")
	var hud: BattleHud = BattleHud.new()
	add_child_autofree(hud)
	hud.setup(game, "Lunch Rush", "lorc/imp")
	hud.set_arena_banner("arena_lethal_lunch")
	await wait_frames(2)
	var banner: Node = hud.find_child("ArenaBanner", true, false)
	assert_not_null(banner)
	var texts: PackedStringArray = []
	for label: Node in banner.find_children("*", "Label", true, false):
		texts.append((label as Label).text)
	assert_true("\n".join(texts).contains("win THIS turn"))
