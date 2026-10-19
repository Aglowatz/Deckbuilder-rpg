extends GutTest
## Daytime Oct 19: the one-sided encounter rules reach the real duels outside the dungeon maps (Shiro, the arena, the gatekeepers,
## Primm's phases) - before, Shiro's and the arena's rules only existed in the balance sim (and Shiro's not even there).


func before_each() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_shiro_duel_carries_and_lists_his_rules() -> void:
	var context: BattleContext = Session.make_ninja_battle()
	assert_eq(context.encounter_rules.size(), EncounterModifiers.rules(NinjaBoss.RULES_KEY).size())
	assert_gt(context.encounter_rules.size(), 0, "town:ninja has rules")
	assert_true(context.game.players[1].modifiers.has(Modifier.Kind.STAT_CHANGE), "Smoke and Mirrors is on his seat")
	assert_false(context.game.players[0].modifiers.has(Modifier.Kind.STAT_CHANGE), "and not on yours")


func test_grand_bellows_duel_carries_his_rules() -> void:
	var context: BattleContext = Session.make_arena_battle("arena_marshal")
	var names: Array[String] = []
	for rule: EncounterModifiers.Rule in context.encounter_rules:
		names.append(rule.name)
	assert_has(names, "Crowd Favourite")
	assert_has(names, "Heckling Crowd")
	assert_true(context.game.players[1].modifiers.has(Modifier.Kind.STAT_CHANGE))


func test_gatekeeper_duel_lists_its_rules() -> void:
	var context: BattleContext = Session.make_npc_challenge_battle("necrocrat")
	assert_eq(context.encounter_rules.size(), EncounterModifiers.rules("town:npc:necrocrat").size())


func test_primm_phase_rules_have_their_own_keys() -> void:
	assert_eq(PrimmBoss.rules_key(0), "Primm (standardization)")
	assert_gt(EncounterModifiers.rules(PrimmBoss.rules_key(0)).size(), 0, "phase 1 has a boss rule (Royal Guard)")
	assert_eq(EncounterModifiers.rules(PrimmBoss.rules_key(1)).size(), 0)


func test_every_rule_key_parses() -> void:
	EncounterModifiers.reset()
	EncounterModifiers.rules(NinjaBoss.RULES_KEY)
	assert_eq(EncounterModifiers._problems.size(), 0, ", ".join(EncounterModifiers._problems))


func test_every_rule_icon_exists() -> void:
	var parsed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(EncounterModifiers.PATH)) as Dictionary
	for key: String in parsed.keys():
		if key.begins_with("_"):
			continue
		for rule: Dictionary in parsed[key]:
			if rule.has("icon"):
				assert_true(ResourceLoader.exists("%s%s.svg" % [CardIcons.BASE, str(rule["icon"])]), "%s: icon %s exists" % [key, rule["icon"]])
