extends GutTest
## Fixes Nov 8 (owner): Primm's phases get plain one-line explanations. (The Deck Station's "Primm deck" advice was removed on Nov 16b with every other hint in the deck column.)


func test_the_phase_rules_say_it_plainly() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(PrimmBoss.ZONE_ID)
	assert_eq(story.text("boss.phase.standardization.rule"), "Every unit starts as a 3/3, so cheap units are as good as big ones; boons and buffs still add on top. You may play two cards a turn.")
	assert_string_contains(story.text("boss.phase.reflection.rule"), "copy of your own deck")
	assert_string_contains(story.text("boss.phase.unraveling.rule"), "loses 1 HP every turn")
