extends GutTest
## Fable Nov 20, Part 2: the Rusty Grave Shovel (Toxic and Swat), Hortensia Clipwell's Topiaries (enter at their printed 1/2), the garden
## rule (Wild Growth: one random unit of the turn's player gets +1/+1 on that player's own turn), and the choice before the Rotheart
## (give blood: -5 HP, you take the first turn).

const CLIPWELL: String = "Hortensia Clipwell, Royal Groundskeeper"


func before_each() -> void:
	EncounterModifiers.reset()


func after_all() -> void:
	EncounterModifiers.reset()


func _game(p0_mods: Array[Modifier], p1_sources: Array[ModifierSource], first_player: int = 0, seed_value: int = 1) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = first_player
	var game: GameState = GameState.new(options)
	var hero_sources: Array[ModifierSource] = []
	if not p0_mods.is_empty():
		hero_sources.append(CardBuilder.modifier_source("Hero rules", ModifierSource.SourceKind.DUNGEON, p0_mods))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, hero_sources, "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, p1_sources, "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	return game


# ---- 2.1 the Rusty Grave Shovel ---------------------------------------------------------------------------------------------------


func test_the_shovel_gives_toxic_and_swat_and_no_stats() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var shovel: CardData = content.card("NR-05")
	assert_eq(shovel.display_name, "Rusty Grave Shovel")
	assert_eq(shovel.rules_text, "Exhaust: attach to target unit you control. Attached unit gets Toxic and Swat.")
	assert_eq(shovel.colored_pips.size(), 2, "its cost is unchanged: (N)(R)")
	assert_eq(shovel.script_text.strip_edges(), "attach\nhost => kw(toxic,swat)")
	var pen: CardData = content.card("N-08")
	assert_string_contains(pen.rules_text, "+1/+0 and Toxic")
	assert_false(shovel.rules_text.contains("+1"), "no stat bonus: it is no longer a second Corporate-Approved Pen")


# ---- 2.2 Hortensia Clipwell -------------------------------------------------------------------------------------------------------


func test_clipwells_topiaries_enter_at_their_printed_one_two() -> void:
	var source: ModifierSource = EncounterModifiers.enemy_source(CLIPWELL)
	assert_not_null(source)
	for modifier: Modifier in source.modifiers:
		assert_ne(modifier.kind, Modifier.Kind.TOKEN_STAT_CHANGE, "no token buff on her seat (Prize Topiary is gone)")
	var game: GameState = _game([] as Array[Modifier], [source] as Array[ModifierSource])
	var spec: Dictionary = {}
	var scripts: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters/encounter_scripts.json")) as Dictionary
	for trigger: Variant in scripts[CLIPWELL] as Array:
		for effect: Variant in (trigger as Dictionary)["effects"] as Array:
			if str((effect as Dictionary).get("kind", "")) == "summon":
				spec = effect as Dictionary
	assert_eq(spec.get("token_stats"), [1.0, 2.0], "the script summons 1/2 Topiaries")
	var data: CardData = EncounterModifiers._token_of(spec, CLIPWELL)
	assert_eq(data.display_name, "Topiary")
	assert_eq([data.attack, data.defense], [1, 2], "printed 1/2")
	var topiary: CardInstance = game.create_token(1, data)
	assert_eq([game.get_attack(topiary), game.get_defense(topiary)], [1, 2], "a Topiary enters as a 1/2: no stacked buffs")
	# her real units still get Royal Groundskeeper's +1/+1
	var gardener: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	assert_eq([game.get_attack(gardener), game.get_defense(gardener)], [3, 3], "Royal Groundskeeper still helps her own units")
	var text: String = ""
	for rule: EncounterModifiers.Rule in EncounterModifiers.rules(CLIPWELL):
		text += rule.text + " "
	assert_string_contains(text, "1/2")
	assert_false(text.contains("Prize Topiary"))


func test_the_echo_of_clipwell_trims_one_two_topiaries_too() -> void:
	var source: ModifierSource = EncounterModifiers.enemy_source("Echo of Hortensia Clipwell")
	var timed: Modifier = null
	for modifier: Modifier in source.modifiers:
		assert_ne(modifier.kind, Modifier.Kind.TOKEN_STAT_CHANGE)
		if modifier.kind == Modifier.Kind.TIMED_SUMMON:
			timed = modifier
	assert_not_null(timed)
	assert_eq([timed.tokens[0].attack, timed.tokens[0].defense], [1, 2])
	assert_eq(timed.tokens[0].display_name, "Topiary")


func test_the_garden_rule_grows_one_random_unit_of_the_turns_player() -> void:
	var rule: Dictionary = DungeonRules.rules("refusemancer")[0] as Dictionary
	assert_eq(str(rule["name"]), "Wild Growth")
	assert_string_contains(str(rule["text"]), "At the start of each player's own turn, one random unit that player controls gets +1/+1.")
	var growth: Array[Modifier] = [CardBuilder.modifier(Modifier.Kind.OVERGROWTH, 1)]
	var shared: ModifierSource = CardBuilder.modifier_source("Rules", ModifierSource.SourceKind.DUNGEON, growth)
	var game: GameState = _game(growth, [shared] as Array[ModifierSource])
	var mine: Array[CardInstance] = []
	var theirs: Array[CardInstance] = []
	for _n: int in range(3):
		mine.append(GameFactory.add_to_field(game, 0, GameFactory.vanilla(1, 4)))
		theirs.append(GameFactory.add_to_field(game, 1, GameFactory.vanilla(1, 4)))
	var before_mine: int = _total(game, mine)
	var before_theirs: int = _total(game, theirs)
	GameFactory.pass_turn(game)  # P1's turn starts
	assert_eq(_total(game, theirs), before_theirs + 1, "exactly one of P1's units grew by +1 attack")
	assert_eq(_total(game, mine), before_mine, "none of P0's units grew on P1's turn")
	GameFactory.pass_turn(game)  # P0's turn starts
	assert_eq(_total(game, mine), before_mine + 1, "exactly one of P0's units grew on P0's own turn")
	assert_eq(_total(game, theirs), before_theirs + 1, "and P1's did not grow again")
	var defense_sum: int = 0
	for unit: CardInstance in mine:
		defense_sum += game.get_defense(unit)
	assert_eq(defense_sum, 13, "+1 defense with it")


func test_the_garden_rule_spreads_over_the_units_at_random_and_has_no_other_home() -> void:
	var seen: Dictionary = {}
	for seed_value: int in range(1, 13):
		var growth: Array[Modifier] = [CardBuilder.modifier(Modifier.Kind.OVERGROWTH, 1)]
		var game: GameState = _game(growth, [] as Array[ModifierSource], 0, seed_value)
		var mine: Array[CardInstance] = []
		for _n: int in range(3):
			mine.append(GameFactory.add_to_field(game, 0, GameFactory.vanilla(1, 4)))
		GameFactory.pass_turn(game)
		GameFactory.pass_turn(game)
		for index: int in range(3):
			if mine[index].overgrowth_stacks > 0:
				seen[index] = true
	assert_gt(seen.size(), 1, "not always the same unit")
	# the old "every unit grows every turn" wording is nowhere in the rules data any more
	for path: String in ["res://core/dungeon/dungeon_rules.gd", "res://data/dungeons/dungeons.json", "res://data/encounters/modifiers.json", "res://data/encounters/encounter_scripts.json", "res://core/arena/arena_defs.gd", "res://core/arena/arena_content.gd"]:
		var text: String = FileAccess.get_file_as_string(path)
		assert_false(text.contains("each unit gets a buff"), path)
		assert_false(text.contains("up to 3 per unit"), path)


func _total(game: GameState, units: Array[CardInstance]) -> int:
	var total: int = 0
	for unit: CardInstance in units:
		total += game.get_attack(unit)
	return total


# ---- 2.3 the choice before the Rotheart --------------------------------------------------------------------------------------------


func test_the_heart_roots_offer_blood_or_nothing() -> void:
	var content: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json")) as Dictionary
	var choices: Array = ((((content["dungeons"] as Dictionary)["D-ROT"] as Dictionary)["events"] as Dictionary)["12"] as Dictionary)["choices"] as Array
	assert_eq(choices.size(), 2)
	assert_eq(str((choices[0] as Array)[0]), "Give blood to distract the Rotheart")
	assert_eq(str((choices[1] as Array)[0]), "Walk on")
	assert_eq((choices[1] as Array).slice(2), ["nothing"], "Walk on does nothing")
	var def: MainDungeonDef = MainDungeons.def("refusemancer")
	var blood: DungeonEvent.Choice = DungeonEvent.Choice.new()
	for token: Variant in (choices[0] as Array).slice(2):
		blood.outcomes.append(DungeonBuilder.event_outcome(str(token), def))
	assert_eq(blood.hint(), "-5 HP; you take the first turn in the fight", "one set of brackets, as the owner wrote it")
	assert_false(blood.hint().contains("("), "no brackets inside the button's brackets")
	var damage: int = 0
	var boon: ModifierSource = null
	for outcome: DungeonEvent.Outcome in blood.outcomes:
		if outcome.kind == DungeonEvent.OutcomeKind.DAMAGE:
			damage = outcome.amount
		if outcome.kind == DungeonEvent.OutcomeKind.BOON:
			boon = outcome.boon
	assert_eq(damage, 5)
	assert_not_null(boon)
	assert_eq(boon.fights_left, 1, "the next fight only: the Rotheart")
	assert_false(boon.for_enemy)
	assert_eq(boon.modifiers[0].kind, Modifier.Kind.ALWAYS_FIRST)
	assert_eq(BoonText.short(boon), "you take the first turn in the next fight")
	var walk: DungeonEvent.Choice = DungeonEvent.Choice.new()
	walk.outcomes.append(DungeonBuilder.event_outcome("nothing", def))
	assert_eq(walk.hint(), "", "Walk on shows no brackets at all")


func test_no_choice_button_nests_brackets() -> void:
	var def: MainDungeonDef = MainDungeons.def("refusemancer")
	var boon: DungeonEvent.Outcome = DungeonBuilder.event_outcome("boon:Lucky Towel|max_hp=2", def)
	assert_false(boon.describe().contains("("), boon.describe())
	assert_true(boon.describe().begins_with("boon: Lucky Towel"))


func _first_player(sources: Array[ModifierSource], seed_value: int) -> int:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = -1  # the coin flip, as every dungeon fight sets it
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, sources, "Hero"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "The Rotheart"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	return game.active


func test_giving_blood_really_gives_the_first_turn() -> void:
	var boon: ModifierSource = DungeonBuilder.boon_from("Blood for the Roots|first=1,next=1")
	var foe_first: int = 0
	for seed_value: int in range(1, 21):
		assert_eq(_first_player([boon] as Array[ModifierSource], seed_value), 0, "seed %d: the hero takes the first turn" % seed_value)
		foe_first += 1 if _first_player([] as Array[ModifierSource], seed_value) == 1 else 0
	assert_gt(foe_first, 0, "without it the coin decides: the foe starts in some of the 20 seeds")


func test_the_blood_boon_reaches_the_rotheart_fight_in_a_real_run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	var hp_before: int = run.hp
	var def: MainDungeonDef = MainDungeons.def("refusemancer")
	var event: DungeonEvent = DungeonEvent.make("heart_roots_test")
	var choice: DungeonEvent.Choice = DungeonEvent.Choice.new()
	for token: String in ["hint:-5 HP; you take the first turn in the fight", "damage:5", "boon:Blood for the Roots|first=1,next=1"]:
		choice.outcomes.append(DungeonBuilder.event_outcome(token, def))
	event.choices.append(choice)
	var result: EventResolver.Result = EventResolver.resolve(event, 0, run, ContentLibrary.load_all(), 0)
	assert_eq(run.hp, hp_before - 5, "-5 HP")
	assert_eq(result.boons.size(), 1)
	var mods: ModifierSet = ModifierPipeline.build(null, null, run.dungeon_sources)
	assert_true(mods.has(Modifier.Kind.ALWAYS_FIRST), "the run carries 'you take the first turn' onto the player's seat in the next fight")
	run.tick_timed_sources()
	assert_true(run.dungeon_sources.is_empty(), "gone after that one fight")
