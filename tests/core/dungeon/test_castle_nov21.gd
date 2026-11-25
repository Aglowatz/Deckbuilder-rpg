extends GutTest
## Fable Nov 21 castle, Parts 2 to 5: the layered map of Primm's Castle (rows, forward links, routes that cross, no run sees every
## room), the four ally rooms and what each leader's help does against Primm, the Pantry Mimic, the castle's rules (Perfect Order is
## in test_dungeon_rules.gd) and Primm's opening hand.

const K := DungeonMap.Kind
## The rows of the layout, by room number (tools/castle_nov21.py is the table the dungeon list's cell is written from).
const ROWS: Array = [[1], [2, 3], [4, 5, 6, 7], [8, 9, 10], [11, 12, 13], [14, 15, 16, 17], [18, 19, 20, 21], [22]]
const ALLY_ROOMS: Array[int] = [2, 8, 11, 14]

var _map: DungeonMap
var _def: MainDungeonDef


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	DungeonCatalog.reset()
	MainDungeons.reset()
	_def = MainDungeons.def(PrimmsCastleDungeon.ZONE_ID)
	_map = MainDungeons.build_map(PrimmsCastleDungeon.ZONE_ID)


func after_each() -> void:
	Session.main_dungeon_active = false
	Session.run = null


func _room(number: int) -> DungeonMap.MapNode:
	for node: DungeonMap.MapNode in _map.nodes:
		if node.number == number:
			return node
	return null


func _row_of(number: int) -> int:
	for row: int in range(ROWS.size()):
		if (ROWS[row] as Array).has(number):
			return row
	return -1


## Every route from the gate to the Model Room, as lists of room numbers.
func _routes() -> Array[Array]:
	var found: Array[Array] = []
	_walk(_map.node(0), [] as Array[int], found)
	return found


func _walk(node: DungeonMap.MapNode, so_far: Array[int], found: Array[Array]) -> void:
	var path: Array[int] = so_far.duplicate()
	path.append(node.number)
	if node.kind == K.BOSS:
		found.append(path)
		return
	for next_id: int in node.next:
		_walk(_map.node(next_id), path, found)


func _is_heal(number: int) -> bool:
	var node: DungeonMap.MapNode = _room(number)
	if node.kind == K.SHRINE:
		return true
	var plan: DungeonCatalog.BlueprintNode = DungeonCatalog.find("D-PC").node(number)
	return plan != null and plan.type == "heal"  # the Garden: "heal for a cost" (a choice room on the map)


func _start_castle_run() -> void:
	Session.begin_zone_visit(CapitalZone.ID)
	Session.dungeon_key = CapitalZone.ID
	Session.dungeon_map = MainDungeons.build_map(CapitalZone.ID)
	_map = Session.dungeon_map
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	Session.boss_phase = 0
	Session.boss_phase_pending = false
	Session.boss_boons_given = false


func _free(zones: Array[String]) -> void:
	for zone_id: String in zones:
		Session.complete_zone(zone_id)


func _keep_hands(game: GameState) -> void:
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())


func _has(modifiers: ModifierSet, kind: Modifier.Kind) -> bool:
	return modifiers.has(kind)


# ---- Part 2: the map -------------------------------------------------------------------------------------------------------------


func test_the_layout_is_the_gate_six_rows_and_the_model_room() -> void:
	assert_eq(_map.problems(), [] as Array[String], "a sound map")
	assert_eq(_map.nodes.size(), 22)
	var sizes: Array[int] = []
	for row: Array in ROWS:
		sizes.append(row.size())
	assert_eq(sizes, [1, 2, 4, 3, 3, 4, 4, 1] as Array[int])
	assert_eq(_room(1).kind, K.START)
	assert_eq(_room(1).title, "Castle Gate")
	assert_eq(_room(22).kind, K.BOSS)
	assert_eq(_room(22).title, "The Model Room")
	for node: DungeonMap.MapNode in _map.nodes:
		assert_gte(_row_of(node.number), 0, "%s is in a row" % node.title)
		assert_eq(node.id, node.number - 1, "ids follow the room numbers")


func test_every_exit_follows_the_layout() -> void:
	# No impossible jumps: every exit leads into the very next row, forward on the painted map, and every room but the gate has a way in.
	for node: DungeonMap.MapNode in _map.nodes:
		var row: int = _row_of(node.number)
		if node.kind != K.BOSS:
			assert_between(node.next.size(), 1, 3, "%s has one to three exits" % node.title)
		for next_id: int in node.next:
			var target: DungeonMap.MapNode = _map.node(next_id)
			assert_eq(_row_of(target.number), row + 1, "%s -> %s is one row on" % [node.title, target.title])
			assert_gt(target.id, node.id, "and forward")
			if target.kind != K.BOSS:
				assert_lt(target.position.y, node.position.y, "%s -> %s climbs on the painted map (Nov 25: the portrait cutaway)" % [node.title, target.title])
		if node.kind != K.START:
			assert_gte(_map.incoming(node.id).size(), 1, "%s can be reached" % node.title)
		assert_eq(node.return_to, -1, "%s: nothing doubles back" % node.title)


func test_the_exits_match_the_dungeon_list() -> void:
	# The game's map is the dungeon list's D-PC cell, link for link.
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-PC")
	for planned: DungeonCatalog.BlueprintNode in plan.nodes:
		var node: DungeonMap.MapNode = _room(planned.number)
		assert_eq(node.title, planned.node_name)
		var exits: Array[int] = []
		for next_id: int in node.next:
			exits.append(_map.node(next_id).number)
		assert_eq(exits, planned.next, planned.node_name)
		assert_false(planned.side, "%s is no side branch" % planned.node_name)


func test_many_routes_and_no_run_sees_every_room() -> void:
	var routes: Array[Array] = _routes()
	assert_gte(routes.size(), 40, "many routes (%d)" % routes.size())
	var seen: Dictionary = {}
	for route: Array in routes:
		assert_eq(route.size(), 8, "the gate, six rooms and the Model Room")
		for number: Variant in route:
			seen[number] = true
	assert_eq(seen.size(), 22, "every room lies on some route")
	# the routes cross: the Hall of Mirrors and the Ministry of Correction are reached from both sides
	assert_gte(_map.incoming(_room(9).id).size(), 4)
	assert_gte(_map.incoming(_room(12).id).size(), 3)


func test_each_row_offers_a_real_choice_of_room_kinds() -> void:
	for row: int in range(1, 7):
		var kinds: Dictionary = {}
		for number: Variant in ROWS[row] as Array:
			var node: DungeonMap.MapNode = _room(int(number))
			kinds["fight" if DungeonMap.is_battle_kind(node.kind) else str(node.kind)] = true
		assert_gte(kinds.size(), 2 if row > 1 else 1, "row %d mixes room kinds" % row)
	var count: Dictionary = {}
	for node: DungeonMap.MapNode in _map.nodes:
		count[node.kind] = int(count.get(node.kind, 0)) + 1
	assert_eq(int(count.get(K.TREASURE, 0)), 3, "three treasure rooms")
	assert_eq(int(count.get(K.SHRINE, 0)), 1, "one full heal: the Resistance Safe Room")
	assert_eq(_room(16).title, "Resistance Safe Room")
	assert_gte(int(count.get(K.ELITE, 0)), 4, "hard fights with better rewards")
	assert_gte(int(count.get(K.EVENT, 0)), 4, "choice rooms")


func test_heal_rooms_are_rare() -> void:
	# The Safe Room (a full heal) and the Garden (6 HP for a cost): at most two on any route, and most routes pass one or none.
	assert_true(_is_heal(16) and _is_heal(7))
	var garden: DungeonEvent = _def.event(_room(7).event_id)
	assert_eq(garden.choices.size(), 3, "pay, take the drawback, or walk on")
	var most: int = 0
	for route: Array in _routes():
		var heals: int = 0
		for number: Variant in route:
			heals += 1 if _is_heal(int(number)) else 0
		most = maxi(most, heals)
	assert_eq(most, 2)


func test_all_four_ally_rooms_fit_in_one_run_that_skips_heals_and_most_treasure() -> void:
	var with_all: int = 0
	for route: Array in _routes():
		var allies: int = 0
		var heals: int = 0
		var treasure: int = 0
		for number: Variant in route:
			allies += 1 if ALLY_ROOMS.has(int(number)) else 0
			heals += 1 if _is_heal(int(number)) else 0
			treasure += 1 if _room(int(number)).kind == K.TREASURE else 0
		if allies == 4:
			with_all += 1
			assert_eq(heals, 0, "the all-allies route passes no heal room: %s" % str(route))
			assert_lte(treasure, 1, "and at most one treasure room: %s" % str(route))
	assert_gte(with_all, 1, "all four leaders can be reached in one run")
	assert_lte(with_all, 6, "but only on a few of the routes (%d)" % with_all)


func test_few_rooms_give_something_that_lasts_to_primm() -> void:
	# Part 2.4: the permanent stat boons are mostly cut. Lasting boons with numbers: the Ward Cells, the Archive, the Mimic's hoard.
	var lasting: Array[String] = []
	for id: Variant in _def.events.keys():
		var event: DungeonEvent = _def.events[id] as DungeonEvent
		for choice: DungeonEvent.Choice in event.choices:
			for outcome: DungeonEvent.Outcome in choice.outcomes:
				if outcome.kind == DungeonEvent.OutcomeKind.BOON and outcome.boon != null and outcome.boon.fights_left == 0 and not BoonText.is_curse(outcome.boon):
					if not lasting.has(str(id)):
						lasting.append(str(id))
	lasting.sort()
	assert_eq(lasting, ["pc_corrected_citizens", "pc_early_journals", "pc_mimic_larder"] as Array[String])
	var most: int = 0
	for route: Array in _routes():
		var rooms: int = 0
		for number: Variant in route:
			rooms += 1 if [2, 10, 15].has(int(number)) else 0
		most = maxi(most, rooms)
	assert_lte(most, 2, "at most two of them on one route")


func test_the_whole_castle_map_is_known_from_the_gate() -> void:
	assert_true(DungeonMapScreen.ROUTE_PLANNING.has("D-PC"))


# ---- Part 3: the allies ----------------------------------------------------------------------------------------------------------


func test_the_ally_rooms_are_the_pantry_and_three_wings() -> void:
	assert_eq(CastleAllies.zone_of_room("final", 2), "gourmand")
	assert_eq(CastleAllies.zone_of_room("final", 8), "beefcake")
	assert_eq(CastleAllies.zone_of_room("final", 11), "necrocrat")
	assert_eq(CastleAllies.zone_of_room("final", 14), "refusemancer")
	assert_eq(CastleAllies.zone_of_room("final", 9), "")
	assert_eq(CastleAllies.zone_of_room("beefcake", 8), "", "only in the castle")
	for number: int in ALLY_ROOMS:
		assert_true(DungeonMap.is_battle_kind(_room(number).kind), "%s is a fight" % _room(number).title)
		assert_false(EncounterModifiers.rules(_room(number).enemy_name).is_empty(), "%s has a twist" % _room(number).enemy_name)


func test_a_won_ally_room_earns_the_leader_only_when_the_zone_is_freed() -> void:
	_start_castle_run()
	assert_eq(CastleAllies.win_room(Session.run, Session.flags, "final", 8), "", "the Gainlands are not free: nobody is there")
	assert_eq(CastleAllies.earned(Session.run), [] as Array[String])
	_free(["beefcake"] as Array[String])
	assert_eq(CastleAllies.win_room(Session.run, Session.flags, "final", 8), "beefcake")
	assert_eq(CastleAllies.earned(Session.run), ["beefcake"] as Array[String])
	CastleAllies.win_room(Session.run, Session.flags, "final", 8)
	assert_eq(CastleAllies.earned(Session.run).size(), 1, "once")
	assert_eq(CastleAllies.win_room(Session.run, Session.flags, "final", 9), "", "an ordinary room earns nobody")


func test_an_ally_room_without_its_leader_pays_a_fair_reward_instead() -> void:
	_start_castle_run()
	var context: BattleContext = BattleContext.new()
	context.node_id = _room(14).id
	var offer: RewardOffer = RewardOffer.new()
	offer.gold = 30
	Session._castle_room_won(context, offer)
	assert_eq(offer.gold, 30 + CastleAllies.FAIR_REWARD_GOLD)
	assert_false(CastleAllies.has_ally(Session.run, "refusemancer"))
	_free(["refusemancer"] as Array[String])
	var second: RewardOffer = RewardOffer.new()
	second.gold = 30
	Session._castle_room_won(context, second)
	assert_eq(second.gold, 30, "with the leader there the reward is the help")
	assert_true(CastleAllies.has_ally(Session.run, "refusemancer"))
	# an ordinary fight is untouched
	context.node_id = _room(12).id
	var third: RewardOffer = RewardOffer.new()
	Session._castle_room_won(context, third)
	assert_eq(third.gold, 0)


func test_the_scenes_play_only_with_the_leader_there() -> void:
	for zone_id: String in CastleAllies.ZONES:
		var number: int = CastleAllies.room_of(zone_id)
		assert_eq(CastleAllies.scene_before(Session.flags, "final", number), "", "%s is not free" % zone_id)
		assert_eq(CastleAllies.scene_after(Session.flags, "final", number), "")
	_free(CastleAllies.ZONES)
	var speakers: Dictionary = {"beefcake": "NPC-FLEX", "gourmand": "NPC-ESCOFFINA", "necrocrat": "NPC-AGNES", "refusemancer": "NPC-COMPOSTELLA"}
	var scenes: Dictionary = (JSON.parse_string(FileAccess.get_file_as_string("res://data/story/story_scenes.json")) as Dictionary)["scenes"] as Dictionary
	for zone_id: String in CastleAllies.ZONES:
		var number: int = CastleAllies.room_of(zone_id)
		for scene_id: String in [CastleAllies.scene_before(Session.flags, "final", number), CastleAllies.scene_after(Session.flags, "final", number)]:
			assert_true(StoryScenes.has(scene_id), "%s exists" % scene_id)
			var steps: Array = (scenes[scene_id] as Dictionary)["steps"] as Array
			assert_between(steps.size(), 3, 6, "%s is a short scene" % scene_id)
			var leader_speaks: bool = false
			for step: Variant in steps:
				leader_speaks = leader_speaks or str((step as Array)[0]) == str(speakers[zone_id])
				assert_true(NpcRegistry.find(str((step as Array)[0])) != null or str((step as Array)[0]) == "", "a known speaker in %s" % scene_id)
			assert_true(leader_speaks, "%s: the leader speaks" % scene_id)
		assert_eq(CastleAllies.scene_before(Session.flags, "final", 9), "", "no scene in an ordinary room")


func test_each_leaders_help_is_the_owners_table() -> void:
	var flex: Array[Modifier] = CastleAllies.help_modifiers("beefcake")
	assert_eq(flex.size(), 1)
	assert_eq(flex[0].kind, Modifier.Kind.ARRIVING_UNIT)
	assert_eq(flex[0].value, 2, "from turn 2")
	assert_eq(flex[0].tokens[0].id, "T-15", "Grandmaster Flex's own token")
	var chef: Array[Modifier] = CastleAllies.help_modifiers("gourmand")
	assert_eq([chef[0].kind, chef[0].value], [Modifier.Kind.EXTRA_DRAWS, 1], "draw 1 extra card each turn")
	var agnes: Array[Modifier] = CastleAllies.help_modifiers("necrocrat")
	assert_eq([agnes[0].kind, agnes[0].value], [Modifier.Kind.NON_UNIT_COST_CHANGE, -1], "non-unit cards cost 1 less")
	var dump: Array[Modifier] = CastleAllies.help_modifiers("refusemancer")
	assert_eq([dump[0].kind, dump[0].value, dump[0].value2, dump[0].color], [Modifier.Kind.STAT_CHANGE, 1, 1, Modifier.ANY_COLOR], "all your units get +1/+1")
	for zone_id: String in CastleAllies.ZONES:
		assert_false(CastleAllies.help_text(zone_id).is_empty())
		assert_false(str(CastleAllies.OBJECTIVES[zone_id]).is_empty())


func test_the_help_counts_in_every_phase_of_primms_fight_and_nowhere_else() -> void:
	_start_castle_run()
	_free(CastleAllies.ZONES)
	for number: int in ALLY_ROOMS:
		CastleAllies.win_room(Session.run, Session.flags, "final", number)
	# an ordinary castle fight: the markers add nothing
	var plain: BattleContext = Session.make_dungeon_battle(_room(12))
	assert_false(_has(plain.game.players[0].modifiers, Modifier.Kind.ARRIVING_UNIT))
	assert_false(_has(plain.game.players[0].modifiers, Modifier.Kind.NON_UNIT_COST_CHANGE))
	assert_eq(plain.game.players[0].modifiers.sum(Modifier.Kind.EXTRA_DRAWS), 0)
	for phase_index: int in range(PrimmBoss.PHASES):
		Session.boss_phase = phase_index
		var context: BattleContext = Session.make_dungeon_battle(_map.boss())
		var mine: ModifierSet = context.game.players[0].modifiers
		assert_true(_has(mine, Modifier.Kind.ARRIVING_UNIT), "phase %d: Flex" % phase_index)
		assert_eq(mine.sum(Modifier.Kind.EXTRA_DRAWS), 1, "phase %d: the Grand Chef" % phase_index)
		assert_eq(mine.sum(Modifier.Kind.NON_UNIT_COST_CHANGE), -1, "phase %d: Agnes" % phase_index)
		var names: Array[String] = []
		for badge: RuleBadges.Badge in context.rule_badges:
			names.append(badge.name)
		for zone_id: String in CastleAllies.ZONES:
			assert_has(names, str(CastleAllies.HELP_NAMES[zone_id]), "phase %d shows %s" % [phase_index, zone_id])
	Session.boss_phase = 0


func test_no_help_without_allies() -> void:
	_start_castle_run()
	_free(CastleAllies.ZONES)
	var context: BattleContext = Session.make_dungeon_battle(_map.boss())
	assert_false(_has(context.game.players[0].modifiers, Modifier.Kind.ARRIVING_UNIT), "freed zones alone lend nothing")
	for badge: RuleBadges.Badge in context.rule_badges:
		assert_false(CastleAllies.HELP_NAMES.values().has(badge.name))


func test_flex_joins_at_the_start_of_your_second_turn() -> void:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 5
	options.first_player = 0
	var game: GameState = GameState.new(options)
	var help: Array[ModifierSource] = [CastleAllies.help_source(["beefcake"] as Array[String])] as Array[ModifierSource]
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, help, "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "P1"))
	game.start()
	_keep_hands(game)
	assert_eq(game.players[0].units().size(), 0, "not on turn 1")
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_eq(game.players[0].turns_taken, 2)
	var units: Array[CardInstance] = game.players[0].units()
	assert_eq(units.size(), 1, "Flex walks in")
	assert_eq(units[0].data.id, "T-15")
	assert_eq([units[0].data.attack, units[0].data.defense], [CastleAllies.FLEX_ATTACK, CastleAllies.FLEX_DEFENSE])
	assert_false(units[0].just_arrived, "ready to fight")
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_eq(game.players[0].units().size(), 1, "once")
	assert_eq(game.players[1].units().size(), 0)


func test_agnes_cuts_the_generic_cost_of_non_unit_cards() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[0].modifiers.add_source(CastleAllies.help_source(["necrocrat"] as Array[String]))
	var spell: CardData = CardBuilder.spell("agnes_spell", "Spell", Affinity.Type.NECROCRAT, 2, [Affinity.Type.NECROCRAT] as Array[Affinity.Type])
	var free_spell: CardData = CardBuilder.spell("agnes_free", "Free", Affinity.Type.NECROCRAT, 0, [Affinity.Type.NECROCRAT] as Array[Affinity.Type])
	var unit: CardData = GameFactory.vanilla(2, 2, 2)
	assert_eq(game.generic_cost_for(0, spell), 1, "2 generic -> 1")
	assert_eq(game.pips_for(0, spell).size(), 1, "the Path pip is still owed")
	assert_eq(game.generic_cost_for(0, free_spell), 0, "never below 0")
	assert_eq(game.generic_cost_for(0, unit), 2, "units are not cheaper")
	assert_eq(game.generic_cost_for(0, GameFactory.infra()), 0)
	assert_eq(game.generic_cost_for(1, spell), 2, "the opponent pays in full")


func test_the_dumps_leader_gives_every_unit_plus_one_plus_one() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[0].modifiers.add_source(CastleAllies.help_source(["refusemancer"] as Array[String]))
	var mine: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2, 1, Affinity.Type.NECROCRAT))
	var theirs: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2, 1))
	assert_eq([game.get_attack(mine), game.get_defense(mine)], [3, 3])
	assert_eq([game.get_attack(theirs), game.get_defense(theirs)], [2, 2])


func test_the_map_tooltip_names_the_objective_and_the_help() -> void:
	_start_castle_run()
	var lines: Array[String] = CastleAllies.room_lines(Session.flags, Session.run, "final", 8)
	assert_true(lines[0].begins_with("Objective: Hold the line"))
	assert_true(lines[1].contains("Nobody waits here") and lines[1].contains("the Gainlands"), lines[1])
	_free(["beefcake"] as Array[String])
	lines = CastleAllies.room_lines(Session.flags, Session.run, "final", 8)
	assert_true(lines[1].contains("Grandmaster Flex is here") and lines[1].contains("joins your side"), lines[1])
	CastleAllies.win_room(Session.run, Session.flags, "final", 8)
	lines = CastleAllies.room_lines(Session.flags, Session.run, "final", 8)
	assert_true(lines[1].contains("will help against Primm"), lines[1])
	assert_eq(CastleAllies.room_lines(Session.flags, Session.run, "final", 9), [] as Array[String])
	# the marker reads as what it will do in the run's boon list
	assert_true(BoonText.describe(CastleAllies.marker("gourmand")).to_lower().contains("against primm"), BoonText.describe(CastleAllies.marker("gourmand")))
	assert_false(BoonText.is_curse(CastleAllies.marker("gourmand")))


# ---- The ally fights' twists ---------------------------------------------------------------------------------------------------


func _fight(number: int) -> GameState:
	_start_castle_run()
	var context: BattleContext = Session.make_dungeon_battle(_room(number))
	_keep_hands(context.game)
	return context.game


func _pass_until_foe_turn(game: GameState, turn: int) -> void:
	var guard: int = 0
	while not game.is_over() and game.players[1].turns_taken < turn and guard < 60:
		guard += 1
		GameFactory.pass_turn(game)


func _tokens(game: GameState, seat: int, id: String) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in game.players[seat].field:
		if card.data.id == id:
			result.append(card)
	return result


func test_hold_the_line_two_trainees_and_the_barracks_gives_up() -> void:
	var game: GameState = _fight(8)
	var trainees: Array[CardInstance] = _tokens(game, 0, "PC-TRAINEE")
	assert_eq(trainees.size(), 2, "two Captured Trainees on your side from the start")
	assert_eq([trainees[0].data.attack, trainees[0].data.defense, trainees[0].data.display_name], [0, 3, "Captured Trainee"])
	assert_false(trainees[0].data.art_override.is_empty())
	assert_true(ResourceLoader.exists(trainees[0].data.art_override))
	game.destroy_unit(trainees[0])
	_pass_until_foe_turn(game, 5)
	assert_false(game.is_over(), "not yet at the Sergeant's 5th turn")
	_pass_until_foe_turn(game, 6)
	assert_true(game.is_over(), "the 6th turn begins with a trainee alive")
	assert_eq(game.winner, 0, "you win")


func test_hold_the_line_is_off_once_both_trainees_are_gone() -> void:
	var game: GameState = _fight(8)
	for trainee: CardInstance in _tokens(game, 0, "PC-TRAINEE"):
		game.destroy_unit(trainee)
	_pass_until_foe_turn(game, 7)
	assert_false(game.is_over(), "no trainee, no surrender: the Sergeant must be beaten")


func test_plumes_filing_deadline_ends_the_duel() -> void:
	var game: GameState = _fight(11)
	_pass_until_foe_turn(game, 11)
	assert_false(game.is_over(), "eleven turns are yours")
	_pass_until_foe_turn(game, 12)
	assert_true(game.is_over())
	assert_eq(game.winner, 1, "the office closes: the duel is lost")


func test_the_gardeners_three_statues_and_the_vault_is_yours() -> void:
	var game: GameState = _fight(14)
	var statues: Array[CardInstance] = _tokens(game, 1, "PC-STATUE")
	assert_eq(statues.size(), 3)
	assert_eq([game.get_attack(statues[0]), game.get_defense(statues[0])], [0, 4], "Waxed and Polished leaves the statues alone")
	game.destroy_unit(statues[0])
	game.destroy_unit(statues[1])
	game.check_state()
	assert_false(game.is_over(), "two down")
	game.destroy_unit(statues[2])
	game.check_state()
	assert_true(game.is_over())
	assert_eq(game.winner, 0, "all three destroyed: you win")


# ---- Part 4: the Pantry Mimic ----------------------------------------------------------------------------------------------------


func test_the_gilded_pantry_is_an_optional_fight_against_the_mimic() -> void:
	var pantry: DungeonMap.MapNode = _room(2)
	assert_eq(pantry.title, "Gilded Pantry")
	assert_eq(pantry.kind, K.ELITE)
	assert_eq(pantry.enemy_name, "The Pantry Mimic")
	# optional: the gate has another way on
	assert_eq(_map.node(0).next.size(), 2)
	var foe: MainDungeonDef.Foe = _def.foe("The Pantry Mimic")
	var gourmand: int = 0
	var cards: int = 0
	for key: Variant in foe.recipe.keys():
		var card: CardData = Session.content.card(str(key))
		if card != null and not card.is_infrastructure():
			cards += int(foe.recipe[key])
			gourmand += int(foe.recipe[key]) if card.is_on_path(Affinity.Type.GOURMAND) else 0
	assert_gt(gourmand * 2, cards, "a Gourmand deck")
	assert_not_null(Bestiary.find("The Pantry Mimic"), "in the Collection Book")


func test_the_mimic_copies_the_first_unit_you_play_each_turn() -> void:
	var game: GameState = _fight(2)
	assert_true(_has(game.players[0].modifiers, Modifier.Kind.MIRROR_FIRST_UNIT))
	assert_true(_has(game.players[0].modifiers, Modifier.Kind.MIRRORS), "and the room is under Mirrors")
	if game.active != 0:
		GameFactory.pass_turn(game)
	game.players[0].hand.clear()
	GameFactory.add_infrastructure_cards(game, 0, 4)
	var unit: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 3, 1))
	var before: int = game.players[1].units().size()
	assert_true(game.play_card(0, unit.uid))
	var theirs: Array[CardInstance] = game.players[1].units()
	assert_eq(theirs.size(), before + 1, "a copy stands on the Mimic's side")
	assert_eq(theirs[theirs.size() - 1].data.display_name, unit.data.display_name)


func test_beating_the_mimic_pays_a_gilded_pack_and_a_choice_of_one_boon() -> void:
	_start_castle_run()
	var packs_before: int = Session.profile.pack_count(CastleAllies.SPOILS_PACK) if Session.profile.has_method("pack_count") else -1
	var context: BattleContext = BattleContext.new()
	context.node_id = _room(2).id
	var offer: RewardOffer = RewardOffer.new()
	Session._castle_room_won(context, offer)
	if packs_before >= 0:
		assert_eq(Session.profile.pack_count(CastleAllies.SPOILS_PACK), packs_before + 1, "a Gilded Pack")
	assert_eq(offer.gold, CastleAllies.FAIR_REWARD_GOLD, "the Buffet is not free: the fair reward as well")
	var spoils: DungeonEvent = _def.event(CastleAllies.SPOILS_EVENT)
	assert_not_null(spoils)
	assert_eq(spoils.choices.size(), 3)
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	assert_false(story.text(spoils.title_key()).begins_with("[missing"))
	for index: int in range(3):
		assert_false(story.text(spoils.choice_key(index)).begins_with("[missing"))
		assert_false(story.text(spoils.result_key(index)).begins_with("[missing"))
		var outcomes: Array[DungeonEvent.Outcome] = spoils.choices[index].outcomes
		assert_eq(outcomes.size(), 1, "a reward: one boon, no drawback")
		assert_eq(outcomes[0].kind, DungeonEvent.OutcomeKind.BOON)
		assert_false(BoonText.is_curse(outcomes[0].boon))
		assert_eq(outcomes[0].boon.fights_left, 0, "it lasts to the last fight")
	var hp_before: int = Session.run.max_hp()
	assert_true(Session.resolve_dungeon_event(spoils, 0).ok)
	assert_eq(Session.run.max_hp(), hp_before + PrimmsCastleDungeon.SPOILS_MAX_HP)


func test_with_the_buffet_freed_the_pantry_is_also_the_grand_chefs_room() -> void:
	_start_castle_run()
	_free(["gourmand"] as Array[String])
	assert_eq(CastleAllies.scene_before(Session.flags, "final", 2), "pc_ally_gourmand_before")
	var context: BattleContext = BattleContext.new()
	context.node_id = _room(2).id
	var offer: RewardOffer = RewardOffer.new()
	Session._castle_room_won(context, offer)
	assert_eq(offer.gold, 0)
	assert_true(CastleAllies.has_ally(Session.run, "gourmand"))


# ---- Part 5.4: Primm's opening hand ----------------------------------------------------------------------------------------------


func test_primm_opens_every_phase_with_eight_cards() -> void:
	assert_eq(PrimmBoss.OPENING_HAND, 8)
	_start_castle_run()
	for phase_index: int in range(PrimmBoss.PHASES):
		Session.boss_phase = phase_index
		var context: BattleContext = Session.make_dungeon_battle(_map.boss())
		assert_eq(context.game.players[1].opening_hand_size, 8, "phase %d" % phase_index)
		assert_eq(context.game.players[0].opening_hand_size, Session.profile.base_opening_hand() + Session.run.modifiers().sum(Modifier.Kind.OPENING_HAND_SIZE), "yours is unchanged")
	Session.boss_phase = 0


func test_the_objectives_are_never_a_hidden_trait() -> void:
	var before: bool = EncounterScripts.hide_unseen
	EncounterScripts.hide_unseen = true
	for pair: Array in [["Coup Barracks Sergeant", "hold"], ["Percival Plume, Deputy Minister of Good News", "deadline"], ["Seed Vault Gardener", "polish"]]:
		EncounterScripts.triggers(str(pair[0]))
		assert_false(EncounterScripts.is_hidden(str(pair[0]), str(pair[1])), "%s: the objective is told from the start" % str(pair[0]))
	EncounterScripts.hide_unseen = before


# ---- Part 6: "A Plan for Everyone" (Primm prepares for the leaders you bring) ---------------------------------------------------


func test_primm_has_more_hp_for_each_leader_and_a_guard_to_answer_flex() -> void:
	for index: int in range(PrimmBoss.PHASES):
		assert_eq(PrimmBoss.hp_for(index, 0), PrimmBoss.phase(index).hp, "alone: his own HP")
		assert_eq(PrimmBoss.hp_for(index, 4), PrimmBoss.phase(index).hp + 4 * PrimmBoss.HP_PER_LEADER)
	assert_eq(PrimmBoss.guards_for([] as Array[String]), 0)
	assert_eq(PrimmBoss.guards_for(["gourmand"] as Array[String]), 0, "no guard for a leader who puts no unit on the table")
	assert_eq(PrimmBoss.guards_for(["beefcake"] as Array[String]), 1, "a Militia to answer Grandmaster Flex")
	assert_eq(PrimmBoss.guards_for(["gourmand", "necrocrat", "refusemancer"] as Array[String]), 0)
	assert_eq(PrimmBoss.guards_for(CastleAllies.ZONES), 2, "and one more when all four came")
	assert_null(PrimmBoss.plan_source(["necrocrat"] as Array[String]))
	assert_true(PrimmBoss.plan_text(CastleAllies.ZONES).contains("+%d now" % (4 * PrimmBoss.HP_PER_LEADER)))


func test_the_plan_is_in_the_fight_and_on_a_badge() -> void:
	_start_castle_run()
	var alone: BattleContext = Session.make_dungeon_battle(_map.boss())
	_keep_hands(alone.game)  # the guards are posted after the opening hands
	assert_eq(alone.game.players[1].hp, PrimmBoss.phase(0).hp)
	for badge: RuleBadges.Badge in alone.rule_badges:
		assert_ne(badge.name, PrimmBoss.PLAN_RULE_NAME, "alone: no plan")
	var militia_alone: int = alone.game.players[1].units().size()
	_free(CastleAllies.ZONES)
	for number: int in ALLY_ROOMS:
		CastleAllies.win_room(Session.run, Session.flags, "final", number)
	var together: BattleContext = Session.make_dungeon_battle(_map.boss())
	_keep_hands(together.game)
	assert_eq(together.game.players[1].hp, PrimmBoss.phase(0).hp + 4 * PrimmBoss.HP_PER_LEADER)
	assert_eq(together.game.players[1].units().size(), militia_alone + 2, "two more guards on his side")
	var named: bool = false
	for badge: RuleBadges.Badge in together.rule_badges:
		if badge.name == PrimmBoss.PLAN_RULE_NAME:
			named = true
			assert_eq(badge.side, RuleBadges.SIDE_ENEMY)
			assert_true(badge.text.contains("Grandmaster Flex"))
	assert_true(named, "the plan is a rule badge in his fight")
