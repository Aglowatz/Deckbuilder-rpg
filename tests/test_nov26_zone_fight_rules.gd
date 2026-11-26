extends GutTest
## Nov 26 day (Part C): every zone dungeon fight (the four zones' main dungeons and Primm's Castle) has a rule set of its own; the
## postgame is untouched. Written by tools/nov26_zone_fight_rules.py; the list: docs/design/zone_fight_rules.md.

const DUNGEONS: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer", "final"]
const POSTGAME: Array[String] = ["D-LAB", "S-GALLERY", "S-BEEF"]

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func before_each() -> void:
	EncounterModifiers.reset()


func _fights(key: String) -> Array[DungeonMap.MapNode]:
	var result: Array[DungeonMap.MapNode] = []
	var map: DungeonMap = MainDungeons.build_map(key)
	for node: DungeonMap.MapNode in map.nodes:
		if not node.enemy_name.is_empty() and node.enemy_name != PrimmBoss.BOSS_FOE:
			result.append(node)
	return result


func _rule_names(foe: String) -> Array[String]:
	var names: Array[String] = []
	for rule: EncounterModifiers.Rule in EncounterModifiers.rules(foe):
		if rule.hidden:
			continue  # the older "Hidden trait ?" chip stands for any unseen trigger; it is not a rule of the fight
		names.append(rule.name)
	names.sort()
	return names


func test_the_rules_load_cleanly() -> void:
	EncounterModifiers.keys()
	assert_eq(EncounterModifiers.problems(), [] as Array[String])


func test_every_zone_dungeon_fight_has_rules_of_its_own() -> void:
	var counted: int = 0
	for key: String in DUNGEONS:
		for node: DungeonMap.MapNode in _fights(key):
			counted += 1
			assert_true(EncounterModifiers.has_rules(node.enemy_name) or EncounterScripts.has_script(node.enemy_name),
				"%s room %d (%s) has a rule or a scripted beat" % [key, node.number, node.enemy_name])
			assert_false(RuleBadges.for_encounter(EncounterModifiers.rules(node.enemy_name)).is_empty(), "%s: the Before the fight panel lists them" % node.enemy_name)
	assert_gte(counted, 30, "the five dungeons' fights")


func test_no_dungeon_repeats_an_archetype_and_rule_set_more_than_twice() -> void:
	for key: String in DUNGEONS:
		var seen: Dictionary = {}
		for node: DungeonMap.MapNode in _fights(key):
			# the deck's identity: its non-basic cards (an archetype trimmed or mixed keeps them)
			var recipe: Dictionary = MainDungeons.enemy_recipe(key, node.enemy_name)
			var ids: Array = recipe.keys().filter(func(id: Variant) -> bool: return not str(id).begins_with("INF") and not str(id).begins_with("BASIC"))
			ids.sort()
			var combo: String = "%s|%s" % [",".join(PackedStringArray(ids)), ",".join(_rule_names(node.enemy_name))]
			seen[combo] = int(seen.get(combo, 0)) + 1
			assert_lte(int(seen[combo]), 2, "%s: the same deck and rules more than twice (room %d)" % [key, node.number])
	var content_block: Dictionary = DungeonCatalog.content_for("D-HOG")
	var bruisers: int = 0
	for room: Variant in (content_block.get("foes", {}) as Dictionary).keys():
		var foe: Variant = (content_block["foes"] as Dictionary)[room]
		if foe is Dictionary and str((foe as Dictionary).get("deck", "")) == "beefcake_bruisers":
			bruisers += 1
	assert_lte(bruisers, 2, "the House of Gains no longer has beefcake_bruisers three times")


func test_no_effect_is_most_of_a_dungeon() -> void:
	for key: String in DUNGEONS:
		var fights: Array[DungeonMap.MapNode] = _fights(key)
		var by_name: Dictionary = {}
		for node: DungeonMap.MapNode in fights:
			for rule_name: String in _rule_names(node.enemy_name):
				by_name[rule_name] = int(by_name.get(rule_name, 0)) + 1
		for rule_name: Variant in by_name.keys():
			assert_lte(int(by_name[rule_name]) * 2, fights.size(), "%s: %s is on at most half the fights" % [key, str(rule_name)])


func test_every_new_rule_has_a_counterweight_and_hard_rules_show_red() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters/modifiers.json")) as Dictionary
	var foes: int = 0
	for foe: Variant in data.keys():
		if not (data[foe] is Array):
			continue
		var added: Array = (data[foe] as Array).filter(func(r: Variant) -> bool: return r is Dictionary and bool((r as Dictionary).get("nov26", false)))
		if added.is_empty():
			continue
		foes += 1
		var helps: bool = false
		for rule: Variant in added:
			var spec: Dictionary = rule as Dictionary
			if str(spec.get("side", "enemy")) == "player" and not bool(spec.get("harmful", false)):
				helps = true
		assert_true(helps or EncounterScripts.has_script(str(foe)), "%s: something the player can use" % str(foe))
		for badge: RuleBadges.Badge in RuleBadges.for_encounter(EncounterModifiers.rules(str(foe))):
			if badge.name in ["Lights Out", "Forms Only", "Do Not Touch", "Correction Quota", "Bad Air"]:
				assert_false(badge.good, "%s is drawn as harmful" % badge.name)
	assert_gte(foes, 18)


func test_the_postgame_is_untouched() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters/modifiers.json")) as Dictionary
	for key: String in POSTGAME:
		var map: DungeonMap = MainDungeons.build_map(key)
		for node: DungeonMap.MapNode in map.nodes:
			if node.enemy_name.is_empty() or not (data.get(node.enemy_name) is Array):
				continue
			for rule: Variant in data[node.enemy_name] as Array:
				assert_false(bool((rule as Dictionary).get("nov26", false)), "%s: no Nov 26 rule in the postgame" % node.enemy_name)


func test_new_scripted_beats_have_lines() -> void:
	for foe: String in ["Expediter of the Pass", "Resurrection Permits Zombie", "Executive Elevator Operator", "Thorn Maze Stalker", "Gallery Curator"]:
		var found: bool = false
		for trigger: EncounterScripts.Trigger in EncounterScripts.triggers(foe):
			if trigger.id.begins_with("zf_"):
				found = true
				assert_false(trigger.line.is_empty(), "%s %s has a line" % [foe, trigger.id])
		assert_true(found, "%s has its new beat" % foe)


func _duel(foe: String) -> GameState:
	var game: GameState = GameState.new(GameOptions.new())
	game.options.rng_seed = 5
	var sources: Array[ModifierSource] = []
	var source: ModifierSource = EncounterModifiers.player_source(foe)
	if source != null:
		sources.append(source)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, sources, "Hero"))
	var enemy: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], foe)
	EncounterModifiers.apply_to_enemy(enemy, foe)
	game.add_player(enemy)
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	return game


func test_rules_land_where_they_say() -> void:
	var brawler: GameState = _duel("Cell Block Brawler")
	assert_eq(brawler.players[0].non_infrastructure_play_cap, 2, "Lights Out: two cards a turn for the hero")
	assert_lt(brawler.players[1].non_infrastructure_play_cap, 0, "the Brawler is not capped")
	var cook: GameState = _duel("Frozen Line Cook")
	assert_eq(cook.players[1].units().size(), 2, "two Ice Blocks on the Cook's side")
	for unit: CardInstance in cook.players[1].units():
		assert_eq(cook.get_defense(unit), 4)
		assert_true(cook.unit_has_keyword(unit, CardEnums.Keyword.WALLFLOWER))
	var sous: GameState = _duel("Prep Station Sous-Chef")
	assert_eq(sous.resource_count(0, ResourceKind.Kind.INGREDIENT), 2, "Staff Meal: the hero's Ingredients")
	assert_eq(sous.resource_count(1, ResourceKind.Kind.INGREDIENT), 2)
	var clerk: GameState = _duel("Returns Clerk")
	assert_eq(clerk.resource_count(0, ResourceKind.Kind.CONTRACT), 1, "Receipt Kept")
	var guard: GameState = _duel("Trophy Hall Honor Guard")
	assert_eq(guard.players[1].units().size(), 1, "the Trophy Case")


func test_deck_checks_and_rewards() -> void:
	var sprinter: GameState = _duel("Treadmill Sprinter")
	var fast: CardInstance = GameFactory.add_to_field(sprinter, 0, GameFactory.vanilla(2, 2))
	fast.data.keywords = [CardEnums.Keyword.HUSTLE] as Array[CardEnums.Keyword]
	assert_eq(sprinter.get_attack(fast), 3, "Interval Training: a Hustle unit of yours gets +1 attack")
	var theirs: CardInstance = GameFactory.add_to_field(sprinter, 1, GameFactory.vanilla(2, 2))
	# the grant lands as a unit enters play (GameState._apply_static_equipment_grants); the test helper skips that step, so check the seat
	assert_true(sprinter.players[1].modifiers.keyword_grants_for(Modifier.Kind.GRANT_KEYWORD_TO_UNITS, theirs.data).has(CardEnums.Keyword.HUSTLE), "Treadmill: the Sprinter's units have Hustle")
	assert_false(sprinter.players[0].modifiers.keyword_grants_for(Modifier.Kind.GRANT_KEYWORD_TO_UNITS, fast.data).has(CardEnums.Keyword.HUSTLE), "not the hero's")
	var lifter: GameState = _duel("Courtyard Lifter")
	assert_true(lifter.players[0].modifiers.has(Modifier.Kind.COST_CHANGE), "Free Weights on the hero's seat")
	var intake: GameState = _duel("Intake Clerk")
	assert_true(intake.players[0].modifiers.has(Modifier.Kind.BANNED_CARD_TYPE), "Forms Only: no Tools for the hero")
	assert_false(intake.players[1].modifiers.has(Modifier.Kind.BANNED_CARD_TYPE))
	var tunnel: GameState = _duel("Rot Tunnel Horror")
	assert_true(ResourceRules.blocked(tunnel, ResourceKind.Kind.GARBAGE), "Bad Air: no Garbage")
	var golem: GameState = _duel("Assembly Line Golem")
	assert_true(golem.players[1].modifiers.has(Modifier.Kind.RETALIATE_ON_ATTACK), "Quality Control sits on the Golem's seat (it hits attackers)")


func test_the_deck_changes_break_up_repeats() -> void:
	assert_eq(str((DungeonCatalog.content_for("D-HOG")["foes"] as Dictionary)["8"]["deck"]), "necrocrat_beefcake")
	assert_eq(str((DungeonCatalog.content_for("D-PC")["foes"] as Dictionary)["5"]["deck"]), "gourmand_refusemancer")
