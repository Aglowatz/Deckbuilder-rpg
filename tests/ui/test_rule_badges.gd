extends GutTest
## Playtest v0.4.0 Part F: every rule that bends a fight (zone effects, dungeon rules, boons, the Capital's services, one-sided encounter
## rules) is one list of badges with an icon and a tooltip (`RuleBadges`), drawn as a persistent icon row (`RuleIconRow`) on the node map,
## in the dungeon brief and in the battle HUD. The enemy's intent is never part of it.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_zone_effects_become_a_buff_and_a_debuff_badge() -> void:
	var badges: Array[RuleBadges.Badge] = RuleBadges.for_zone(GainlandsZone.ID)
	assert_eq(badges.size(), 2)
	assert_eq(badges[0].kind, "zone_buff")
	assert_true(badges[0].is_good())
	assert_eq(badges[1].kind, "zone_debuff")
	assert_false(badges[1].is_good())
	assert_eq(badges[0].side, RuleBadges.SIDE_BOTH)
	assert_true(badges[0].tooltip().contains("Applies to you and to the enemy."))
	assert_true(RuleBadges.for_zone("").is_empty())


func test_dungeon_rules_become_badges_with_icons_and_node_limits() -> void:
	var all_rules: Array[RuleBadges.Badge] = RuleBadges.for_dungeon(HouseOfGainsDungeon.ZONE_ID)
	assert_eq(all_rules.size(), 2, "Pump Iron and the Iron-less Prison")
	assert_eq(all_rules[0].name, "Pump Iron")
	assert_eq(all_rules[0].side, RuleBadges.SIDE_PLAYER)
	assert_true(all_rules[0].is_good())
	assert_eq(all_rules[0].icon, "lorc/muscle-up")
	assert_eq(all_rules[1].side, RuleBadges.SIDE_BOTH)
	var at_node_one: Array[RuleBadges.Badge] = RuleBadges.for_dungeon(HouseOfGainsDungeon.ZONE_ID, 1)
	assert_eq(at_node_one.size(), 1, "the prison rule only applies on its nodes")
	var at_prison: Array[RuleBadges.Badge] = RuleBadges.for_dungeon(HouseOfGainsDungeon.ZONE_ID, 8)
	assert_eq(at_prison.size(), 2)
	for key: String in ["D-TTK", "D-HFA", "D-ROT", "D-PC", "S-BEEF", "S-GOUR", "S-NECRO", "S-REF", "S-CAP", "S-TOWN", "S-IRON"]:
		for badge: RuleBadges.Badge in RuleBadges.for_dungeon(key):
			assert_true(RuleBadges.DUNGEON_ICONS.has(badge.name), "%s has its own icon (%s)" % [badge.name, key])
			assert_not_null(CardIcons.named(badge.icon), "%s's icon %s exists" % [badge.name, badge.icon])


func test_boons_capital_services_and_encounter_rules() -> void:
	var boon: ModifierSource = ModifierSource.new()
	boon.source_name = "Flex's Blessing"
	boon.source_kind = ModifierSource.SourceKind.BOON
	var plain: ModifierSource = ModifierSource.new()
	plain.source_name = "zone"
	plain.source_kind = ModifierSource.SourceKind.ZONE
	var boons: Array[RuleBadges.Badge] = RuleBadges.for_boons([boon, plain] as Array[ModifierSource])
	assert_eq(boons.size(), 1, "only the boons")
	assert_eq(boons[0].name, "Flex's Blessing")
	assert_true(boons[0].is_good())
	assert_eq(RuleBadges.for_capital({}).size(), 4, "every service is broken until its zone is freed")
	for badge: RuleBadges.Badge in RuleBadges.for_capital({}):
		assert_eq(badge.kind, "capital")
		assert_false(badge.is_good())
	var freed: Dictionary = {}
	for zone_id: String in ZoneDefs.ids():
		freed[str(ZoneCompletion.flag_name(zone_id))] = true
	assert_true(RuleBadges.for_capital(freed).is_empty(), "no broken services once every zone is free")
	var rules: Array[EncounterModifiers.Rule] = EncounterModifiers.rules("zone:gourmand:casserole")
	var encounter: Array[RuleBadges.Badge] = RuleBadges.for_encounter(rules)
	assert_false(encounter.is_empty(), "the Casserole's rule")
	for badge: RuleBadges.Badge in encounter:
		assert_true(badge.kind == "encounter" or badge.kind == "scripted", "a rule or (Oct 23) a scripted event")
		assert_true(badge.side == RuleBadges.SIDE_ENEMY or badge.side == RuleBadges.SIDE_PLAYER, "one-sided")
	var names: Dictionary = {}
	for badge: RuleBadges.Badge in encounter:
		assert_false(names.has(badge.name), "a rule split over modifiers is one badge")
		names[badge.name] = true


func test_a_dungeon_battle_carries_its_badges_and_a_town_fight_only_its_encounter_rules() -> void:
	Session.add_xp(ProgressionTable.xp_to_reach(7) - Session.profile.xp)
	Session.set_flag(CorruptedNpcs.unlock_flag("beefcake"))
	Session.zone_run = ZoneRun.enter(GainlandsZone.ID, Session.profile, Session.deck)
	# The run as enter_main_dungeon sets it up, minus the scene change.
	Session.dungeon_key = GainlandsZone.ID
	Session.dungeon_map = MainDungeons.build_map(GainlandsZone.ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	var node: DungeonMap.MapNode = null
	for candidate: DungeonMap.MapNode in Session.dungeon_map.nodes:
		if candidate.kind == DungeonMap.Kind.BATTLE:
			node = candidate
			break
	assert_not_null(node)
	var context: BattleContext = Session.make_dungeon_battle(node)
	var kinds: Dictionary = {}
	for badge: RuleBadges.Badge in context.rule_badges:
		kinds[badge.kind] = true
	assert_true(kinds.has("zone_buff") and kinds.has("zone_debuff"), "the zone effects")
	assert_true(kinds.has("dungeon"), "the House of Gains' rules")
	Session.main_dungeon_active = false
	Session.run = null
	Session.dungeon_map = null
	var town: BattleContext = Session.make_town_battle(TownEnemies.CLERK, "town_clerk")
	for badge: RuleBadges.Badge in town.rule_badges:
		assert_eq(badge.kind, "encounter", "an outskirts fight has no zone or dungeon rules")


func test_the_icon_row_draws_one_icon_per_badge_and_opens_the_full_list() -> void:
	var badges: Array[RuleBadges.Badge] = RuleBadges.for_zone(GainlandsZone.ID)
	badges.append_array(RuleBadges.for_dungeon(HouseOfGainsDungeon.ZONE_ID))
	var row: RuleIconRow = RuleIconRow.make(badges, "Rules of the House of Gains")
	add_child_autofree(row)
	await wait_process_frames(2)
	var buttons: Array[Node] = row.find_children("Badge_*", "Button", true, false)
	assert_eq(buttons.size(), badges.size())
	assert_false(row.is_open())
	row.toggle_panel()
	assert_true(row.is_open(), "clicking opens the full list")
	var panel: Node = row.find_child("RulesPanel", true, false)
	assert_not_null(panel)
	row.toggle_panel()
	assert_false(row.is_open())
	var compact: RuleIconRow = RuleIconRow.make(badges, "", true)
	add_child_autofree(compact)
	await wait_process_frames(1)
	assert_eq(compact.find_children("Badge_*", "Button", true, false).size(), badges.size())


func test_the_battle_hud_keeps_a_persistent_icon_row() -> void:
	var context: BattleContext = Session.make_town_battle(TownEnemies.HOUND, "town_hound")
	var hud: BattleHud = BattleHud.new()
	add_child_autofree(hud)
	hud.setup(context.game, context.enemy_name, context.enemy_icon)
	var badges: Array[RuleBadges.Badge] = RuleBadges.for_zone(GainlandsZone.ID)
	hud.set_rule_badges(badges)
	await wait_process_frames(1)
	assert_not_null(hud.find_child("RuleIconRow", true, false), "the HUD shows the rule icon row")
	assert_null(hud.find_child("ZoneEffectsPanel", true, false), "the old text panel is gone from the HUD")
