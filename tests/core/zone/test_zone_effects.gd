extends GutTest
## Part C: zone-wide buffs and debuffs through the Modifier pipeline, applied to both sides.

const ZONES: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer"]

var A: Affinity.Type = Affinity.Type.A
var B: Affinity.Type = Affinity.Type.B
var C: Affinity.Type = Affinity.Type.C
var D: Affinity.Type = Affinity.Type.D


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func _game_in(zone_id: String) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 1
	var game: GameState = GameState.new(options)
	var source: ModifierSource = ZoneEffects.source_for(zone_id)
	var extra: Array[ModifierSource] = [] as Array[ModifierSource]
	if source != null:
		extra.append(source)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, extra, "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, extra, "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	for player: PlayerState in game.players:
		player.hand.clear()
	return game


func _creature(game: GameState, owner: int, color: Affinity.Type, power: int = 2, toughness: int = 2) -> CardInstance:
	return GameFactory.add_to_battlefield(game, owner, GameFactory.vanilla(power, toughness, 1, color), true)


func test_every_zone_has_a_buff_for_its_path_and_a_debuff_for_the_rival() -> void:
	for zone_id: String in ZONES:
		var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id)
		assert_not_null(effect, zone_id)
		assert_eq(effect.buff.color, int(effect.path))
		assert_eq(effect.debuff.color, int(effect.rival))
		assert_ne(effect.path, effect.rival)
		assert_eq(ZoneEffects.rival_of(effect.rival), effect.path, "rivalries are symmetric")
	assert_eq(ZoneEffects.rival_of(A), D, "Beefcake vs Necrocrat")
	assert_eq(ZoneEffects.rival_of(B), C, "Gourmand vs Refusemancer")
	assert_null(ZoneEffects.for_zone("nowhere"))


func test_each_zone_has_named_flavored_effects_and_a_tooltip() -> void:
	for zone_id: String in ZONES:
		var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id)
		for text: String in [effect.buff_name(), effect.debuff_name(), effect.buff_flavor(), effect.debuff_flavor()]:
			assert_false(text.is_empty() or text.begins_with("[missing"), "%s has its effect text in the story file" % zone_id)
		assert_true(effect.tooltip().contains(effect.buff_name()))
		assert_true(effect.tooltip().contains(effect.debuff_name()))
		assert_true(effect.buff_mechanic().contains(Affinity.display_name(effect.path)))
		assert_true(effect.debuff_mechanic().contains(Affinity.display_name(effect.rival)))


func test_gainlands_buff_beefcake_power_for_both_sides() -> void:
	var game: GameState = _game_in(GainlandsZone.ID)
	var mine: CardInstance = _creature(game, 0, A)
	var theirs: CardInstance = _creature(game, 1, A)
	assert_eq(game.get_power(mine), 3)
	assert_eq(game.get_power(theirs), 3, "the enemy gets the buff too")
	assert_eq(game.get_toughness(mine), 2)
	assert_eq(game.get_power(_creature(game, 0, B)), 2, "other Paths are unaffected")


func test_gainlands_processing_time_necrocrat_creatures_enter_exhausted() -> void:
	var game: GameState = _game_in(GainlandsZone.ID)
	GameFactory.add_infrastructure_cards(game, 0, 3, D)
	var necro: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1, D))
	var other: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1, A))
	assert_true(game.cast(0, necro.uid))
	assert_true(game.cast(0, other.uid))
	assert_true(necro.exhausted, "a Necrocrat creature enters exhausted (it cannot block)")
	assert_false(other.exhausted, "a Beefcake creature does not")


func test_dna_buffs_necrocrat_toughness_and_taxes_beefcake_cards() -> void:
	var game: GameState = _game_in(DnaZone.ID)
	assert_eq(game.get_toughness(_creature(game, 0, D)), 3)
	assert_eq(game.get_toughness(_creature(game, 1, D)), 3, "both sides")
	var beef: CardData = GameFactory.vanilla(1, 1, 2, A)
	assert_eq(game.generic_cost_for(0, beef), 3, "Unauthorized Activity: +1 generic cost")
	assert_eq(game.generic_cost_for(1, beef), 3)
	assert_eq(game.generic_cost_for(0, GameFactory.vanilla(1, 1, 2, D)), 2, "Necrocrat cost is unchanged")


func test_buffet_buffs_gourmand_and_debuffs_refusemancer_power() -> void:
	var game: GameState = _game_in(BuffetZone.ID)
	var gourmand: CardInstance = _creature(game, 0, B)
	assert_eq(game.get_power(gourmand), 3)
	assert_eq(game.get_toughness(gourmand), 3)
	assert_eq(game.get_power(_creature(game, 1, C)), 1, "Dress Code Violation: -1 power on Refusemancers")


func test_dump_buffs_refusemancer_toughness_and_debuffs_gourmand_toughness() -> void:
	var game: GameState = _game_in(HeapZone.ID)
	assert_eq(game.get_toughness(_creature(game, 0, C)), 4)
	assert_eq(game.get_toughness(_creature(game, 1, B)), 1, "Spoilage: -1 toughness on Gourmands")


func test_a_debuff_never_kills_a_one_toughness_creature_by_itself() -> void:
	var game: GameState = _game_in(HeapZone.ID)
	var tiny: CardInstance = _creature(game, 0, B, 1, 1)
	assert_eq(game.get_toughness(tiny), 1, "floored at 1")


func test_outside_a_zone_nothing_changes() -> void:
	var game: GameState = _game_in("")
	assert_eq(game.get_power(_creature(game, 0, A)), 2)
	assert_eq(game.generic_cost_for(0, GameFactory.vanilla(1, 1, 2, A)), 2)


func test_a_real_zone_battle_applies_the_effects_to_player_and_enemy() -> void:
	Session.ensure_game(A)
	Session.zone_run = ZoneRun.enter(GainlandsZone.ID, Session.profile, Session.deck)
	var context: BattleContext = Session.make_zone_battle("brute", "brute_1")
	assert_eq(context.zone_id, GainlandsZone.ID)
	for player: PlayerState in context.game.players:
		assert_eq(player.modifiers.stat_bonus(A), Vector2i(1, 0), "both seats carry Pump It Up")
		assert_true(player.modifiers.sum_for_color(Modifier.Kind.ENTER_EXHAUSTED, D) > 0, "both seats carry Processing Time")
	Session.zone_run = null


func test_zone_dungeon_battles_carry_the_zone_effects_too() -> void:
	Session.ensure_game(A)
	Session.zone_run = ZoneRun.enter(DnaZone.ID, Session.profile, Session.deck)
	Session.dungeon_map = MiniDungeon.build_map(DnaZone.ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.mini_active = true
	var node: DungeonMap.MapNode = Session.dungeon_map.available()[0]
	var context: BattleContext = Session.make_dungeon_battle(node)
	assert_eq(context.zone_id, DnaZone.ID)
	for player: PlayerState in context.game.players:
		assert_eq(player.modifiers.sum_for_color(Modifier.Kind.COST_CHANGE, A), 1)
	Session.mini_active = false
	Session.run = null
	Session.dungeon_map = null
	Session.zone_run = null


func test_the_battle_hud_shows_the_zone_effects_panel() -> void:
	var effect: ZoneEffects.Effect = ZoneEffects.for_zone(GainlandsZone.ID)
	var panel: ZoneEffectsPanel = ZoneEffectsPanel.make(effect, "The Gainlands")
	add_child_autofree(panel)
	assert_true(panel.tooltip_text.contains("Pump It Up"))
	assert_true(panel.tooltip_text.contains("Processing Time"))
	assert_true(panel.tooltip_text.contains("you and to the enemy"))
