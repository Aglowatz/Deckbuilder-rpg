extends GutTest
## Fable Nov 21 castle, Part 9.1: the Arena's approved rows (the bold row of each battle in docs/balance_report_nov21.md, section 2).


func _rule(key: String, rule_name: String) -> EncounterModifiers.Rule:
	for rule: EncounterModifiers.Rule in EncounterModifiers.rules(key):
		if rule.name == rule_name:
			return rule
	return null


func _stat(key: String, rule_name: String) -> Array[int]:
	var rule: EncounterModifiers.Rule = _rule(key, rule_name)
	if rule == null:
		return [] as Array[int]
	for modifier: Modifier in rule.modifiers:
		if modifier.kind == Modifier.Kind.STAT_CHANGE:
			return [modifier.value, modifier.value2] as Array[int]
	return [] as Array[int]


func test_row_1_the_gladiator_rookie() -> void:
	assert_eq(ArenaDefs.find("arena_warmup").enemy_hp, 20, "14 -> 20 HP")
	assert_eq(AIPlayer.SKILL_OVERRIDES["Gladiator Rookie"], AIPlayer.Skill.ELITE, "plays at Elite skill")
	assert_eq(_stat("arena:arena_warmup", "Home Crowd"), [1, 1] as Array[int])


func test_row_2_the_sandbag_sentinel() -> void:
	var bout: ArenaEncounter = ArenaDefs.find("arena_neutral_mile")
	assert_eq(bout.enemy_hp, 20, "13 -> 20 HP")
	assert_eq(bout.enemy_ai, "Defensive", "it stays Defensive")
	assert_eq(AIPlayer.SKILL_OVERRIDES["Sandbag Sentinel"], AIPlayer.Skill.ELITE)
	assert_eq(_stat("arena:arena_neutral_mile", "Packed Sand"), [0, 2] as Array[int])


func test_row_3_the_cardboard_colossus() -> void:
	assert_eq(ArenaDefs.find("arena_spells_only").enemy_hp, 10, "6 -> 10 HP: five Flex on 'Em, not three")


func test_row_4_the_champion_of_the_four_fists() -> void:
	var bout: ArenaEncounter = ArenaDefs.find("arena_four_fists")
	assert_eq(bout.enemy_hp, 40, "33 -> 40 HP")
	assert_eq(int(bout.enemy_recipe.get("INF-11", 0)), 3, "three Old Kingdom Crossroads: it can pay for its four Paths")
	assert_eq(_stat("arena:arena_four_fists", "Four Fists"), [2, 2] as Array[int], "the simulated row: +1/+1 on top of the +1/+1 it had")


func test_row_5_announcer_grand_bellows() -> void:
	assert_eq(ArenaDefs.find("arena_marshal").enemy_hp, 64, "46 -> 64 HP")
	assert_eq(_stat("arena:arena_marshal", "Crowd Favourite"), [2, 1] as Array[int], "his old rule stays")
	# Fable Nov 22 night: "The Crowd Roars" (+1/+1) is off again (64 HP stays): with his scripted events the row was won 25 % of the time
	for rule: Variant in (JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters/modifiers.json")) as Dictionary)["arena:arena_marshal"] as Array:
		assert_ne(str((rule as Dictionary).get("name", "")), "The Crowd Roars")


func test_row_6_the_four_fists_unbound() -> void:
	var bout: ArenaEncounter = ArenaDefs.find("arena_four_fists_unbound")
	assert_eq(bout.enemy_hp, 80, "54 -> 80 HP")
	assert_eq(int(bout.enemy_recipe.get("INF-11", 0)), 3)
	assert_eq(_stat("arena:arena_four_fists_unbound", "Unbound"), [4, 4] as Array[int])
	var hand: EncounterModifiers.Rule = _rule("arena:arena_four_fists_unbound", "Ready for You")
	assert_not_null(hand, "one more opening card")
	if hand != null:
		assert_eq([hand.modifiers[0].kind, hand.modifiers[0].value], [Modifier.Kind.OPENING_HAND_SIZE, 1])


func test_the_rules_reach_the_bout_in_the_game() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var game: GameState = ArenaScenario.build_game(Session.content, ArenaDefs.find("arena_four_fists_unbound"), Session.profile, Session.deck, 11)
	assert_eq(game.players[1].modifiers.sum(Modifier.Kind.OPENING_HAND_SIZE), 1)
	assert_eq(game.players[1].hp, 80)
