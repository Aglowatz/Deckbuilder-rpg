extends GutTest
## Fable Nov 21 castle, Part 5.1: the battle's rules panel. The fight's own rules are listed in a panel that scrolls inside itself and
## never reaches the battle log, the items or the player's plate; what the run brought (allies, boons, curses) folds into one line that
## opens the full list.


func _badge(kind: String, name: String, text: String = "A rule that does a thing to one side of the table for the whole fight.") -> RuleBadges.Badge:
	var badge: RuleBadges.Badge = RuleBadges.special(name, text, "lorc/crossed-swords", [] as Array[Modifier])
	badge.kind = kind
	return badge


func _many() -> Array[RuleBadges.Badge]:
	var badges: Array[RuleBadges.Badge] = []
	for index: int in range(9):
		badges.append(_badge("encounter", "Rule %d" % index))
	for index: int in range(3):
		badges.append(_badge("ally", "Ally %d" % index))
	for index: int in range(4):
		badges.append(_badge("boon", "Boon %d" % index))
	badges.append(_badge("curse", "Curse 0"))
	return badges


func test_the_run_effects_fold_into_one_line() -> void:
	assert_eq(RuleIconRow.run_summary(_many()), "Run effects: 3 allies, 4 boons, 1 curse")
	assert_eq(RuleIconRow.run_summary([_badge("ally", "A"), _badge("curse", "C"), _badge("curse", "D")] as Array[RuleBadges.Badge]), "Run effects: 1 ally, 2 curses")
	assert_eq(RuleIconRow.run_summary([_badge("encounter", "E")] as Array[RuleBadges.Badge]), "", "a fight's own rules are no run effect")


func test_the_panel_lists_the_fights_rules_and_one_run_line() -> void:
	var row: RuleIconRow = RuleIconRow.make_battle(_many(), 438.0)
	add_child_autofree(row)
	await wait_frames(2)
	assert_eq(row.run_badges().size(), 8)
	for index: int in range(9):
		assert_not_null(row.find_child("Line_Rule_%d" % index, true, false), "rule %d is a line of the panel" % index)
	assert_null(row.find_child("Line_Boon_0", true, false), "a boon is not a line of its own")
	assert_null(row.find_child("Line_Ally_0", true, false))
	var button: Button = row.find_child("RunEffects", true, false) as Button
	assert_not_null(button)
	assert_true(button.text.begins_with("Run effects: 3 allies, 4 boons, 1 curse"), button.text)
	assert_eq(button.focus_mode, Control.FOCUS_ALL, "the controller can stop on it")


func test_a_long_list_scrolls_inside_the_panel_and_keeps_its_height() -> void:
	var limit: float = 438.0
	var row: RuleIconRow = RuleIconRow.make_battle(_many(), limit)
	add_child_autofree(row)
	await wait_frames(2)
	var scroll: ScrollContainer = row.find_child("RuleScroll", true, false) as ScrollContainer
	assert_not_null(scroll, "nine rules do not fit: the list has its own scroll bar")
	assert_lte(row.custom_minimum_size.y, limit + 0.5, "the panel is never taller than its room")
	assert_eq(scroll.horizontal_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED)
	# a short list needs no bar
	var short: RuleIconRow = RuleIconRow.make_battle([_badge("encounter", "Only"), _badge("boon", "B")] as Array[RuleBadges.Badge], limit)
	add_child_autofree(short)
	await wait_frames(1)
	assert_null(short.find_child("RuleScroll", true, false))
	assert_lt(short.custom_minimum_size.y, 120.0)


func test_the_run_line_opens_the_full_list() -> void:
	var row: RuleIconRow = RuleIconRow.make_battle(_many(), 438.0)
	add_child_autofree(row)
	await wait_frames(2)
	assert_false(row.run_effects_open())
	var button: Button = row.find_child("RunEffects", true, false) as Button
	button.mouse_entered.emit()
	assert_true(row.run_effects_open(), "hover opens it")
	var panel: Control = row.find_child("RunEffectsPanel", true, false) as Control
	var words: String = ""
	for label: Node in panel.find_children("*", "Label", true, false):
		words += (label as Label).text + "\n"
	for name: String in ["Ally 0", "Ally 2", "Boon 3", "Curse 0"]:
		assert_true(words.contains(name), "%s is in the list" % name)
	button.mouse_exited.emit()
	assert_false(row.run_effects_open(), "and leaving closes it")
	row.toggle_run_effects()
	assert_true(row.run_effects_open(), "a click (or the Rules key) pins it open")
	button.mouse_exited.emit()
	assert_true(row.run_effects_open())
	row.toggle_run_effects()
	assert_false(row.run_effects_open())
	button.focus_entered.emit()
	assert_true(row.run_effects_open(), "controller focus opens it")
	button.focus_exited.emit()
	assert_false(row.run_effects_open())


func test_in_primms_fight_the_panel_stays_above_the_log_the_items_and_the_plate() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	for zone_id: String in CastleAllies.ZONES:
		Session.complete_zone(zone_id)
	Session.begin_zone_visit(CapitalZone.ID)
	Session.dungeon_key = CapitalZone.ID
	Session.dungeon_map = MainDungeons.build_map(CapitalZone.ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	Session.boss_phase = 0
	for number: int in [2, 8, 11, 14]:
		CastleAllies.win_room(Session.run, Session.flags, "final", number)
	# a run that picked up a great deal on the way (the owner's last one carried about ten)
	for index: int in range(6):
		Session.run.add_dungeon_source(DungeonBuilder.boon_from("Boon %d|max_hp=1" % index))
	for index: int in range(3):
		Session.run.add_dungeon_source(DungeonBuilder.boon_from("Curse %d|max_hp=-1" % index))
	var context: BattleContext = Session.make_dungeon_battle(Session.dungeon_map.boss())
	var hud: BattleHud = BattleHud.new()
	add_child_autofree(hud)
	hud.set_rule_badges(context.rule_badges)
	await wait_frames(2)
	var row: RuleIconRow = hud.rule_row
	assert_not_null(row)
	assert_lte(row.position.y + row.custom_minimum_size.y, BattleHud.RULES_BOTTOM + 0.5, "the panel ends above the battle log (646), the items (700) and the plate (884)")
	assert_eq(RuleIconRow.run_summary(context.rule_badges), "Run effects: 4 allies, 6 boons, 3 curses")
	assert_eq(row.run_badges().size(), 13)
	# Primm's own rules are still lines of the panel
	var phase_line: bool = false
	for line: Node in row.find_children("Line_*", "HBoxContainer", true, false):
		phase_line = phase_line or str(line.name).contains("Standardization")
	assert_true(phase_line, "the phase's rule")
	assert_not_null(row.find_child("Line_Perfect_Order", true, false))
	Session.main_dungeon_active = false
	Session.run = null
