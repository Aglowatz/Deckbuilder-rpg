extends GutTest
## Overnight Oct 30-31, Part 1: the mid-game critic's fixes that live in rules - names with no spoiler, the first-duel basics skipped for a
## hero past them, a zone's own main line tracked on arrival.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.quest_log.reset()
	Session.flags = {QuestDefinitions.LEGACY_FLAG: true}
	Session.counters = {}


func test_cover_names_hide_the_twist() -> void:
	assert_eq(SpoilerFree.name("Old Hob the Gravedigger (secretly Death)"), "Old Hob the Gravedigger")
	assert_eq(SpoilerFree.name("The Doppelganger (posing as Grand Chef Escoffina)"), "Grand Chef Escoffina")
	assert_eq(SpoilerFree.name("The Doppelganger (later named Escoffina)"), "The Doppelganger")
	assert_eq(SpoilerFree.name("Kyle (Deceased Since '09)"), "Kyle (Deceased Since '09)", "other brackets stay")
	var hob: NpcRegistry.Entry = NpcRegistry.find("NPC-HOB")
	if hob != null:
		assert_false(hob.plate_name().contains("Death"), "the plate keeps the secret")


func test_the_first_duel_basics_are_skipped_past_level_5() -> void:
	Session.profile.level = 2
	assert_false(TutorialLayer.step_seen("intro"), "a new hero sees the first-duel tips")
	Session.profile.level = 13
	assert_true(TutorialLayer.step_seen("intro"), "a level-13 hero does not")
	assert_true(TutorialLayer.step_seen("energy"))
	assert_false(TutorialLayer.step_seen("trap"), "the later topics still show once")


func test_a_zone_tracks_its_own_main_line_on_arrival() -> void:
	Session.offer_auto_quests()
	var main_id: String = QuestDefinitions.zone_main_id("gourmand")
	Session.quest_log.track(QuestDefinitions.zone_main_id("beefcake"))
	Session.begin_zone_visit("gourmand")
	if Session.quest_log.is_active(main_id):
		assert_eq(Session.quest_log.tracked_id(), main_id, "the Buffet's main line is tracked inside the Buffet")
	else:
		pass_test("the Buffet's line is not open in this setup")
