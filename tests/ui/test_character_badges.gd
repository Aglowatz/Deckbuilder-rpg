extends GutTest
## Overnight Oct 17 (Phase 2 cycle 4, UI consistency), changed Oct 19 night: level, Path and deck are on the Character screen's stats panel;
## the art gear slots keep the gold focus ring; the Alchemist explains essence with the live copy caps.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_alchemist_blurb_uses_the_copy_caps() -> void:
	var screen: AlchemistScreen = AlchemistScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	var found: bool = false
	for node: Node in screen.find_children("*", "Label", true, false):
		var text: String = (node as Label).text
		assert_false(text.contains("beyond the fourth"), "the old four-copy rule is gone")
		if text.contains("%d Common" % CopyCaps.cap_for(CardEnums.Rarity.COMMON, Session.profile.level)):
			found = true
	assert_true(found, "the blurb names the current caps")
