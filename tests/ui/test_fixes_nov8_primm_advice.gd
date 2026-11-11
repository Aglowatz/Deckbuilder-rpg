extends GutTest
## Fixes Nov 8 (owner): Primm's phases get plain one-line explanations, and the Deck Station gives "Primm deck" advice when the castle is next.


func test_the_phase_rules_say_it_plainly() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(PrimmBoss.ZONE_ID)
	assert_eq(story.text("boss.phase.standardization.rule"), "Every unit starts as a 3/3, so cheap units are as good as big ones; boons and buffs still add on top. You may play two cards a turn.")
	assert_string_contains(story.text("boss.phase.reflection.rule"), "copy of your own deck")
	assert_string_contains(story.text("boss.phase.unraveling.rule"), "loses 1 HP every turn")


func test_the_deck_station_advises_a_primm_deck_only_when_the_castle_is_next() -> void:
	var cards: Array[CardData] = [Session.content.card("C-01"), Session.content.card("C-02")]
	assert_eq(DeckbuilderScreen.primm_advice(cards, {}), "", "not before the castle")
	var flags: Dictionary = {str(CapitalZone.FLAG_GATE_OPEN): true}
	assert_string_contains(DeckbuilderScreen.primm_advice(cards, flags), "Primm deck")
	flags["primm_defeated"] = true
	assert_eq(DeckbuilderScreen.primm_advice(cards, flags), "", "not after he falls")
