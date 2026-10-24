extends GutTest
## Overnight Oct 23, Part 1: scripted mid-fight events (EncounterScripts) - HP thresholds, turn triggers with their warning the turn
## before, unit-death and unit-count conditions, each effect kind, once-only firing, the AI's look-ahead copies, the shipped data.

const KEY: String = "test:scripted_boss"


func before_each() -> void:
	EncounterScripts.reset()
	EncounterModifiers.reset()


func after_all() -> void:
	EncounterScripts.reset()


func _trigger(spec: Dictionary) -> EncounterScripts.Trigger:
	var made: EncounterScripts.Trigger = EncounterScripts.build_trigger(spec, KEY)
	assert_not_null(made, "the trigger builds: %s" % str(spec))
	return made


## A started game where seat 1 (the foe) carries the script `triggers` under KEY.
func _game(triggers: Array[EncounterScripts.Trigger], foe_hp: int = 20) -> GameState:
	EncounterScripts.register(KEY, triggers)
	var source: ModifierSource = ModifierSource.new()
	source.source_name = "test"
	source.modifiers = [EncounterScripts.carrier(KEY)] as Array[Modifier]
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 11
	options.first_player = 0
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "P0"))
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), null, [source] as Array[ModifierSource], "P1")
	setup.starting_hp = foe_hp
	game.add_player(setup)
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	return game


func _count(game: GameState, type: GameEvent.Type) -> int:
	return GameFactory.count_events(game, type)


func test_an_hp_threshold_fires_once_when_crossed() -> void:
	var game: GameState = _game([_trigger({"id": "half", "name": "Second Wind", "text": "At half health it heals 3.",
		"when": {"type": "hp_below", "pct": 50}, "effects": [{"kind": "heal", "amount": 3}]})], 20)
	assert_eq(game.script_runs.size(), 1, "the foe's seat carries the script")
	game.deal_damage_to_player(0, 1, 9)
	assert_eq(game.players[1].hp, 11, "above half: nothing yet")
	assert_eq(_count(game, GameEvent.Type.SCRIPT_TRIGGERED), 0)
	game.deal_damage_to_player(0, 1, 2)
	game.check_state()
	assert_eq(game.players[1].hp, 12, "9 HP is under half of 20: it healed 3")
	assert_eq(_count(game, GameEvent.Type.SCRIPT_TRIGGERED), 1)
	game.deal_damage_to_player(0, 1, 5)
	game.check_state()
	assert_eq(game.players[1].hp, 7, "never twice")
	assert_eq(_count(game, GameEvent.Type.SCRIPT_TRIGGERED), 1)


func test_heal_can_go_back_up_to_a_boss_starting_hp_above_max() -> void:
	var game: GameState = _game([_trigger({"name": "Mend", "when": {"type": "hp_below", "pct": 50}, "effects": [{"kind": "heal", "amount": 10}]})], 40)
	game.deal_damage_to_player(0, 1, 25)
	game.check_state()
	assert_eq(game.players[1].hp, 25, "15 + 10, even though the profile's max HP is lower than the boss's 40")


func test_a_turn_trigger_warns_the_turn_before_and_fires_on_the_foes_turn() -> void:
	var game: GameState = _game([_trigger({"id": "t3", "name": "Reinforcements", "warn": "Next turn: the guard arrives.",
		"when": {"type": "turn", "turn": 3}, "effects": [{"kind": "summon", "token": "T-21", "count": 2}]})])
	# P0 goes first: P0 t1, P1 t1, P0 t2, P1 t2, P0 t3 (warning), P1 t3 (fires).
	for i: int in range(3):
		GameFactory.pass_turn(game)
	assert_eq(game.players[1].turns_taken, 2)
	assert_eq(_count(game, GameEvent.Type.SCRIPT_WARNING), 0, "no warning yet")
	GameFactory.pass_turn(game)
	assert_eq(game.active, 0)
	assert_eq(_count(game, GameEvent.Type.SCRIPT_WARNING), 1, "the warning comes at the start of the player's turn before")
	var warning: GameEvent = null
	for event: GameEvent in game.events:
		if event.type == GameEvent.Type.SCRIPT_WARNING:
			warning = event
	assert_eq(warning.detail, "Next turn: the guard arrives.")
	assert_eq(game.players[1].units().size(), 0)
	GameFactory.pass_turn(game)
	assert_eq(game.players[1].turns_taken, 3)
	assert_eq(game.players[1].units().size(), 2, "two Patchwork Bodies on its third turn")
	assert_eq(_count(game, GameEvent.Type.SCRIPT_TRIGGERED), 1)


func test_a_timed_summon_rule_also_warns_the_turn_before() -> void:
	var rule: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "Temp Agency", "text": "every 2nd turn", "kind": "timed_summon", "token": "T-21", "every": 2})
	var game: GameState = _game([_trigger({"name": "Unused", "when": {"type": "hp_below", "pct": 1}, "effects": [{"kind": "heal", "amount": 1}]})])
	for modifier: Modifier in rule.modifiers:
		game.players[1].modifiers.add(modifier)
	GameFactory.pass_turn(game)  # P1 t1
	GameFactory.pass_turn(game)  # P0 t2: P1's 2nd turn is next
	assert_eq(_count(game, GameEvent.Type.SCRIPT_WARNING), 1, "warned before the timed summon")


func test_unit_deaths_and_unit_counts() -> void:
	var game: GameState = _game([
		_trigger({"id": "grief", "name": "Grief", "when": {"type": "units_died", "count": 2, "side": "own"}, "effects": [{"kind": "buff", "atk": 1, "def": 1}]}),
		_trigger({"id": "crowd", "name": "Outnumbered", "when": {"type": "foe_units_at_least", "count": 3}, "effects": [{"kind": "shield", "amount": 4}]}),
	])
	var a: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(1, 1))
	var b: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(1, 1))
	var survivor: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	game.destroy_unit(a)
	game.check_state()
	assert_eq(game.get_attack(survivor), 2, "one death is not enough")
	game.destroy_unit(b)
	game.check_state()
	assert_eq(game.get_attack(survivor), 3, "two of its units died: the rest get +1/+1")
	assert_eq(game.get_defense(survivor), 3)
	for i: int in range(3):
		GameFactory.add_to_field(game, 0, GameFactory.vanilla(1, 1))
	game.check_state()
	assert_eq(game.players[1].shield, 4, "three units on the player's side: a 4-point shield")
	game.deal_damage_to_player(0, 1, 6)
	assert_eq(game.players[1].hp, 18, "the shield soaks 4 of 6")
	assert_eq(game.players[1].shield, 0)


func test_a_phase_change_replaces_a_rule() -> void:
	var game: GameState = _game([_trigger({"id": "phase2", "name": "Phase Two", "when": {"type": "hp_below", "pct": 50},
		"effects": [{"kind": "remove_rule", "name": "Calm"}, {"kind": "rule", "rule": {"name": "Fury", "text": "+2/+0", "kind": "stat", "atk": 2, "def": 0}}]})])
	var calm: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "Calm", "text": "+0/+2", "kind": "stat", "atk": 0, "def": 2})
	for modifier: Modifier in calm.modifiers:
		game.players[1].modifiers.add(modifier)
	var unit: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	assert_eq(game.get_defense(unit), 4)
	game.deal_damage_to_player(0, 1, 10)
	game.check_state()
	assert_eq(game.get_defense(unit), 2, "Calm is gone")
	assert_eq(game.get_attack(unit), 4, "Fury is in")


func test_cards_resources_debuffs_exhaust_damage_and_draws() -> void:
	var game: GameState = _game([_trigger({"id": "all", "name": "Everything", "when": {"type": "hp_below", "pct": 90}, "effects": [
		{"kind": "card", "card": "B-01", "to": "hand"},
		{"kind": "card", "card": "B-01", "to": "deck", "count": 2},
		{"kind": "resources", "resource": "iron", "count": 2},
		{"kind": "debuff_foes", "atk": 1, "def": 0},
		{"kind": "exhaust_foes", "count": 1},
		{"kind": "damage", "amount": 2},
		{"kind": "draw", "count": 1},
	]})])
	var big: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(4, 4))
	var small: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(1, 1))
	var hp_before: int = game.players[0].hp
	var hand_before: int = game.players[1].hand.size()
	var deck_before: int = game.players[1].deck.size()
	game.deal_damage_to_player(0, 1, 3)
	game.check_state()
	assert_eq(game.players[1].hand.size(), hand_before + 2, "the signature card plus one draw")
	assert_eq(game.players[1].deck.size(), deck_before + 2 - 1, "two shuffled in, one drawn")
	assert_eq(game.resource_count(1, ResourceKind.Kind.IRON), 2)
	assert_eq(game.get_attack(big), 3, "-1/-0 until the foe's next turn")
	assert_true(big.exhausted, "the strongest ready unit is exhausted")
	assert_false(small.exhausted)
	assert_eq(game.players[0].hp, hp_before - 2)


func test_look_ahead_copies_fire_on_their_own() -> void:
	var game: GameState = _game([_trigger({"id": "half", "name": "Rage", "when": {"type": "hp_below", "pct": 50},
		"effects": [{"kind": "rule", "rule": {"name": "Rage", "text": "+1/+0", "kind": "stat", "atk": 1, "def": 0}}]})])
	var unit: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	var copy: GameState = game.clone()
	copy.deal_damage_to_player(0, 1, 15)
	copy.check_state()
	assert_eq(copy.get_attack(copy.players[1].find_field(unit.uid)), 3, "the copy fired its trigger")
	assert_eq(game.get_attack(unit), 2, "the real game's rules are untouched")
	assert_true((game.script_runs[0] as EncounterScripts.Run).fired.is_empty(), "and its trigger has not fired")


func test_a_seat_without_a_script_costs_nothing() -> void:
	var game: GameState = GameFactory.new_game(4)
	assert_true(game.script_runs.is_empty())


func test_scripted_triggers_are_listed_with_the_rules_and_ride_on_the_enemy_source() -> void:
	EncounterScripts.register(KEY, [_trigger({"name": "Big Finish", "text": "At 25% health: something big.", "when": {"type": "hp_below", "pct": 25}, "effects": [{"kind": "heal", "amount": 2}]})])
	var rules: Array[EncounterModifiers.Rule] = EncounterModifiers.rules(KEY)
	assert_eq(rules.size(), 1)
	assert_true(rules[0].scripted)
	assert_string_contains(rules[0].tooltip(), "Scripted event")
	var badges: Array[RuleBadges.Badge] = RuleBadges.for_encounter(rules)
	assert_eq(badges[0].kind, "scripted")
	var source: ModifierSource = EncounterModifiers.enemy_source(KEY)
	assert_not_null(source, "a script alone still makes an enemy source")
	assert_eq(source.modifiers[0].kind, Modifier.Kind.ENCOUNTER_SCRIPT)
	assert_null(EncounterModifiers.player_source(KEY), "nothing on the player's seat")


func test_the_shipped_scripts_load_cleanly() -> void:
	assert_eq(EncounterScripts.problems(), [] as Array[String], "no unknown conditions, effects, tokens, cards or rules")
	for key: String in EncounterScripts.keys():
		for each: EncounterScripts.Trigger in EncounterScripts.triggers(key):
			assert_false(each.text.is_empty(), "%s/%s telegraphs what can happen" % [key, each.id])
			assert_false(each.line.is_empty(), "%s/%s has a line" % [key, each.id])
			if each.when_type == "turn":
				assert_false(each.warn.is_empty(), "%s/%s has its one-line warning" % [key, each.id])


func test_every_scripted_boss_shows_its_moves_in_the_bestiary() -> void:
	var aliased: Dictionary = {"capital:quota": true}
	for keys: Variant in EncounterScripts.ENTRY_KEYS.values():
		for key: Variant in keys as Array:
			aliased[str(key)] = true
	for key: String in EncounterScripts.keys():
		if aliased.has(key) or key.begins_with("arena:"):
			continue
		assert_not_null(Bestiary.find(key), "%s has a Bestiary entry for its signature moves" % key)
	assert_eq(EncounterScripts.triggers_for_entry("Corrupted Wanderers").size(), 4, "the four gatekeepers share one entry")
	assert_eq(EncounterScripts.triggers_for_entry("Primm, His Perfection").size(), 3)
