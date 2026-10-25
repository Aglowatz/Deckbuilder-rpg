extends GutTest
## Fixes Oct 25, Part 8: after the armory quest Maren sends the Wanderer to their own Path's zone first. Her lines name the zone's
## vendor, its buff and the rival Path's debuff (the real ZoneEffects names and numbers) and the two rivalries; that zone's main line
## (its gatekeeper) is the tracked quest. Old saves past the gatekeeper never hear it.

const PATHS: Array[Affinity.Type] = [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]


func _through_the_armory(path: Affinity.Type) -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(path)
	Session.level_track_grants = false
	Session.set_flag(&"trial_cleared")
	Session.offer_auto_quests()
	for quest_id: String in [QuestDefinitions.MERCHANTS, QuestDefinitions.FIRST_DECK_EDIT, QuestDefinitions.GHOSTS]:
		if not Session.quest_log.is_active(quest_id):
			Session.start_quest(quest_id)
		Session.quest_log.complete(quest_id)
	Session.start_quest(QuestDefinitions.ARMORY)
	Session.armory_talk()
	Session.note_duel_won()
	Session.refresh_quests()
	Session.armory_talk()
	Session.refresh_quests()


func after_each() -> void:
	Session.save_enabled = true


func test_the_story_opens_on_the_players_own_path_zone() -> void:
	for path: Affinity.Type in PATHS:
		_through_the_armory(path)
		assert_true(Session.quest_log.is_completed(QuestDefinitions.ARMORY))
		var own: String = PathDirection.own_main_quest(path)
		assert_eq(own, QuestDefinitions.zone_main_id(PathDirection.zone_of(path)))
		assert_eq(Session.quest_log.tracked_id(), own, "%s: its own zone's line is tracked" % Affinity.display_name(path))
		assert_true(PathDirection.due(Session.quest_log, Session.flags, path), "Maren has something to say")
		Session.take_path_direction()
		assert_false(PathDirection.due(Session.quest_log, Session.flags, path), "said once")
		assert_eq(Session.quest_log.tracked_id(), own)


func test_marens_lines_use_the_real_zone_effects() -> void:
	for path: Affinity.Type in PATHS:
		var zone_id: String = PathDirection.zone_of(path)
		var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id)
		var text: String = "\n".join(PathDirection.lines(path))
		assert_false(text.contains("{"), "every token filled: %s" % text)
		for needed: String in [ZoneDefs.get_def(zone_id).display_name, str(PathDirection.VENDORS[zone_id]), effect.buff_name(), effect.buff_mechanic(),
				effect.debuff_name(), effect.debuff_mechanic(), Affinity.display_name(ZoneEffects.rival_of(path)), "Beefcake against Necrocrat", "Gourmand against Refusemancer"]:
			assert_string_contains(text, needed, "%s's talk names %s" % [Affinity.display_name(path), needed])


func test_maren_first_errand_still_leads_when_everything_starts_at_once() -> void:
	# A game set up without the trial gate (tools, old debug saves) gets every auto quest in one batch: Maren's errand stays tracked.
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)
	Session.offer_auto_quests()
	if Session.quest_log.is_active(QuestDefinitions.MERCHANTS):
		assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.MERCHANTS)
	else:
		pass_test("the trial gate held the batch back")


func test_a_save_past_its_gatekeeper_is_not_sent_back() -> void:
	_through_the_armory(Affinity.Type.GOURMAND)
	Session.set_flag(CorruptedNpcs.unlock_flag("gourmand"))
	assert_false(PathDirection.due(Session.quest_log, Session.flags, Affinity.Type.GOURMAND))


func test_the_glossary_explains_rivals_and_every_zone() -> void:
	var text: String = ""
	for entry: Array in GlossaryPanel.entries(GlossaryPanel.TABS.find("Zones")):
		text += "%s %s\n" % [entry[0], entry[1]]
	assert_string_contains(text, "Beefcake and Necrocrat")
	for zone_id: String in Gatekeepers.IDS:
		assert_string_contains(text, ZoneEffects.for_zone(zone_id).buff_line())
		assert_string_contains(text, ZoneEffects.for_zone(zone_id).debuff_line())


func test_a_path_zone_title_card_lists_its_effects() -> void:
	var card: ZoneTitleCard = ZoneTitleCard.make(Areas.GAINLANDS)
	if card == null:
		pass_test("no banner art in this checkout")
		return
	assert_eq(card.effects_zone, GainlandsZone.ID)
	card.free()
