extends GutTest
## Fable Nov 15 (Part 4): every fight shows every rule in effect. `RuleAuditSweep` builds every fight of the game with the Session's own
## makers; `RuleAudit.unshown` lists the modifiers on its seats that no shown badge covers. This fails when an encounter applies a
## modifier that has no displayed rule. The sweep's rows are written to `_logs/rule_audit.json` (the report's table).


func after_each() -> void:
	Session.save_enabled = true


func test_no_encounter_applies_a_rule_it_does_not_show() -> void:
	var rows: Array[Dictionary] = RuleAuditSweep.run()
	assert_gt(rows.size(), 100, "the sweep covers the game's fights (%d)" % rows.size())
	var bad: int = 0
	for row: Dictionary in rows:
		var missing: Array = row["missing"] as Array
		if not missing.is_empty():
			bad += 1
		assert_true(missing.is_empty(), "%s (%s) applies rules it does not show: %s" % [str(row["where"]), str(row["foe"]), " | ".join(PackedStringArray(missing))])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_logs"))
	var file: FileAccess = FileAccess.open("res://_logs/rule_audit.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(rows, "\t"))
		file.close()
	gut.p("rule audit: %d fights, %d with a rule that is applied and not shown" % [rows.size(), bad])


func test_the_audit_sees_a_rule_without_a_badge() -> void:
	# the audit itself: a +1/+1 put on the foe's seat with no badge is reported; with its badge it is not
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var boost: Modifier = CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1)
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 7
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(Session.deck, Session.profile, [] as Array[ModifierSource], "You"))
	var foe: PlayerSetup = PlayerSetup.create(Session.deck, null, [] as Array[ModifierSource], "Foe")
	foe.modifiers.add_source(CardBuilder.modifier_source("A secret drill", ModifierSource.SourceKind.ZONE, [boost] as Array[Modifier]))
	game.add_player(foe)
	var context: BattleContext = BattleContext.new()
	context.game = game
	var missing: Array[String] = RuleAudit.unshown(context)
	assert_eq(missing.size(), 1, "the unshown +1/+1 is found")
	assert_string_contains(missing[0] if not missing.is_empty() else "", "A secret drill")
	context.rule_badges = [RuleBadges.special("Drill", "Their units get +1/+1.", RuleBadges.DEFAULT_ICON, [boost] as Array[Modifier])] as Array[RuleBadges.Badge]
	assert_true(RuleAudit.unshown(context).is_empty(), "with its badge the rule is shown")
	# the player's own gear is never a rule of the fight
	var geared: ModifierSet = ModifierSet.new()
	geared.add_source(CardBuilder.modifier_source("A sword", ModifierSource.SourceKind.EQUIPMENT, [boost] as Array[Modifier]))
	assert_true(RuleAudit.applied(geared).is_empty())


func test_hidden_traits_are_listed_as_hidden() -> void:
	# a fight with scripted triggers the save has not seen yet shows a "Hidden trait ?" chip for them, never nothing
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var checked: int = 0
	for key: String in EncounterModifiers.keys():
		var hidden: int = 0
		for rule: EncounterModifiers.Rule in EncounterModifiers.rules(key):
			if rule.hidden:
				hidden += 1
		if hidden == 0:
			continue
		checked += 1
		var chips: int = 0
		for badge: RuleBadges.Badge in RuleBadges.for_encounter(EncounterModifiers.rules(key)):
			if badge.hidden:
				chips += 1
				assert_eq(badge.name, EncounterScripts.HIDDEN_NAME, "%s: named as a hidden trait" % key)
				assert_eq(badge.refs.size(), hidden, "%s: the chip stands for every hidden trigger" % key)
		assert_eq(chips, 1, "%s: one Hidden trait chip" % key)
	gut.p("hidden traits: %d encounters checked" % checked)


func test_the_correction_officer_by_a_rift_names_its_buff() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.zone_run = ZoneRun.enter(CapitalZone.ID, Session.profile, Session.deck)
	# away from a rift: no buff, no badge
	Session.zone_empower_next = false
	var plain: BattleContext = Session.make_zone_battle(CapitalEnemies.OFFICER, "t")
	assert_false(plain.rift_empowered)
	assert_eq(plain.game.players[1].modifiers.stat_bonus(Affinity.Type.NEUTRAL), Vector2i.ZERO, "no +1/+1 away from a rift")
	for badge: RuleBadges.Badge in plain.rule_badges:
		assert_ne(badge.name, CapitalRifts.EMPOWER_NAME)
	assert_true(RuleBadges.fight_specific(plain.rule_badges).is_empty(), "so the fight starts at once, with no card")
	# beside an open rift: +1/+1 on its units (the usual stat bonus, so the numbers show green over the base), more HP, and the rule named
	Session.zone_empower_next = true
	var context: BattleContext = Session.make_zone_battle(CapitalEnemies.OFFICER, "t")
	assert_true(context.rift_empowered)
	assert_false(Session.zone_empower_next, "the flag is used once")
	assert_eq(context.game.players[1].modifiers.stat_bonus(Affinity.Type.NEUTRAL), Vector2i(CapitalRifts.EMPOWER_STAT, CapitalRifts.EMPOWER_STAT), "their units get +1/+1")
	assert_eq(context.game.players[0].modifiers.stat_bonus(Affinity.Type.NEUTRAL), Vector2i.ZERO, "yours do not")
	assert_eq(context.game.players[1].hp, plain.game.players[1].hp + CapitalRifts.EMPOWER_HP)
	var named: RuleBadges.Badge = null
	for badge: RuleBadges.Badge in context.rule_badges:
		if badge.name == CapitalRifts.EMPOWER_NAME:
			named = badge
	assert_not_null(named, "the fight's rule icons carry Rift-Empowered")
	if named != null:
		assert_string_contains(named.text, "+1/+1")
		assert_string_contains(named.tooltip(), "Applies to the enemy only.")
		assert_eq(named.side, RuleBadges.SIDE_ENEMY)
	var own: Array[RuleBadges.Badge] = RuleBadges.fight_specific(context.rule_badges)
	assert_eq(own.size(), 1, "the roamer's fight has a rule of its own, so the Before the fight card shows")
	assert_true(FileAccess.get_file_as_string("res://world/zone/zone_scene.gd").contains("RulesBrief.open(self, context.rule_badges, \"Before the fight: %s\""), "the zone scene opens the card for such a roamer")


func test_the_early_zone_ease_is_a_shown_rule() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	# the Dump as a first zone: three places early
	var badge: RuleBadges.Badge = ZoneOrderEase.badge("refusemancer", 0)
	assert_not_null(badge)
	assert_true(badge.good, "it helps the player: a green badge")
	assert_eq(badge.color(), Color("6fbf73"))
	assert_string_contains(badge.text, "-2 attack")
	assert_string_contains(badge.text, "less HP")
	assert_null(ZoneOrderEase.badge("beefcake", 3), "none once the zone is on time")
	assert_null(ZoneOrderEase.badge("refusemancer", 0, true), "none in a freed zone")
	assert_true(RuleBadges.fight_specific([badge] as Array[RuleBadges.Badge]).is_empty(), "true of every fight of the visit: it never pops the card by itself")
