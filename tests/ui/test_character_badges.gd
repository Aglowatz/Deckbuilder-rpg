extends GutTest
## Overnight Oct 17 (Phase 2 cycle 4, UI consistency): the three spare painted frames on the Character screen show level, Path and deck;
## the art gear slots keep the gold focus ring; the Alchemist explains essence with the live copy caps.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_spare_frames_show_level_path_and_deck() -> void:
	var screen: CharacterScreen = CharacterScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	if not (UiArt.has("UI-BG-CHARACTER") and UiArt.has("UI-SLOT-EQUIP")):
		pass_test("no character art: the plain layout has no spare frames")
		return
	for kind: String in ["level", "path", "deck"]:
		assert_not_null(screen.find_child("Badge_%s" % kind, true, false), kind)
	var labels: Array[String] = []
	for node: Node in (screen.find_child("Badge_deck", true, false) as Node).find_children("*", "Label", true, false):
		labels.append((node as Label).text)
	assert_has(labels, str(Session.deck.size()))
	var path_badge: Node = screen.find_child("Badge_path", true, false)
	var path_caption: Label = path_badge.find_children("*", "Label", true, false)[0] as Label
	assert_eq(path_caption.text, UIStyle.affinity_name(Affinity.Type.BEEFCAKE))


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
