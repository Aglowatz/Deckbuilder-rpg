extends GutTest
## Overnight Oct 19 (Phase 2): once a gatekeeper's zone is freed they say so (`gate.<zone>.freed`), instead of replaying the lines from the day
## they were beaten; the old keys stay as they were (old saves, the beaten-but-not-freed state).


func test_every_gatekeeper_has_freed_lines_of_their_own() -> void:
	var story: StoryText = StoryText.shared()
	for id: String in Gatekeepers.IDS:
		var freed: Array[String] = story.npc_freed_lines(id)
		assert_gte(freed.size(), 2, "%s says something once the zone is free" % id)
		assert_ne(freed, story.npc_victory_lines(id), "%s's freed lines are new" % id)
		assert_false("\n".join(freed).contains("[missing text"), id)


func test_an_unknown_gatekeeper_falls_back_to_the_victory_lines() -> void:
	var story: StoryText = StoryText.shared()
	assert_eq(story.npc_freed_lines("nobody"), story.npc_victory_lines("nobody"))
