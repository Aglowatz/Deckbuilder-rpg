extends GutTest
## Overnight Nov 19 (Part 1.2-1.5): scripted events are a pop-up with a plain description, an opponent's spell or trap waits to be
## read (setting: wait for click / 4 s), the Arena's rules are lines in "Rules of this fight" (no banner), and a roamer that hurts
## the hero on touch unlocks its Bestiary entry with a note.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_scripted_event_description_is_plain() -> void:
	var trigger: EncounterScripts.Trigger = EncounterScripts.Trigger.new()
	trigger.name = "Noted."
	trigger.text = "At half health Vellum files an objection: he gains a Contract."
	trigger.banner = "Vellum gains a Contract."
	var text: String = ScriptEventBanner.describe(trigger)
	assert_true(text.begins_with("Vellum gains a Contract."), text)
	assert_false(text.contains("At half health"), "the lead-in is dropped")


func test_scripted_event_waits_for_a_click() -> void:
	var banner: ScriptEventBanner = ScriptEventBanner.new()
	add_child_autofree(banner)
	var trigger: EncounterScripts.Trigger = EncounterScripts.Trigger.new()
	trigger.name = "Noted."
	trigger.text = "At half health: he gains a Contract."
	trigger.banner = "Vellum gains a Contract."
	trigger.line = "Noted."
	banner.show_event(trigger, "Undersecretary Vellum", 1.0, true)
	await wait_seconds(0.4)
	assert_true(banner.is_waiting(), "the pop-up stays until it is closed")
	banner.close()
	assert_false(banner.is_waiting())


func test_opponent_cards_setting_defaults_to_wait_for_click() -> void:
	assert_eq(Settings.OPPONENT_CARD_NAMES.size(), 2)
	assert_eq(Settings.OPPONENT_CARD_NAMES[0], "Wait for click")
	assert_eq(Settings.OPPONENT_CARD_SECONDS, 4.0)


func test_arena_rules_start_with_the_bout() -> void:
	for encounter: ArenaEncounter in ArenaDefs.all():
		var badges: Array[RuleBadges.Badge] = ArenaScenario.player_rule_badges(encounter)
		assert_false(badges.is_empty(), encounter.id)
		assert_eq(badges[0].kind, "arena", "%s: the bout's own line comes first" % encounter.id)
		assert_false(badges[0].text.is_empty(), encounter.id)


func test_rules_list_shows_readable_lines() -> void:
	var encounter: ArenaEncounter = ArenaDefs.all()[0]
	var badges: Array[RuleBadges.Badge] = ArenaScenario.player_rule_badges(encounter)
	var row: RuleIconRow = RuleIconRow.make(badges, "Rules of this fight", false, true)
	add_child_autofree(row)
	assert_not_null(row.find_child("Line_*", true, false), "one line per rule")
	var text: RichTextLabel = row.find_child("Text", true, false) as RichTextLabel
	assert_not_null(text)
	assert_true(text.text.contains(badges[0].name), "the line names the rule")
	assert_not_null(row.find_child("Badge_*", true, false), "the icon keeps its hover")


func test_a_damaging_roamer_unlocks_its_entry() -> void:
	assert_false(Bestiary.is_known(Session.counters, "Runaway Meatball"))
	Session.bestiary_meet("Runaway Meatball")
	assert_true(Bestiary.is_known(Session.counters, "Runaway Meatball"))
	assert_eq(Session.last_new_bestiary, "Runaway Meatball", "a first meeting is announced")
	Session.last_new_bestiary = ""
	Session.bestiary_meet("Runaway Meatball")
	assert_eq(Session.last_new_bestiary, "", "only the first time")
