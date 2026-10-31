extends GutTest
## Fresh eyes round 2 (Oct 31): a zone rule and a boss rule of the same name print as one line in the "Before the fight" card.


func _badge(kind: String, rule_name: String, text: String) -> RuleBadges.Badge:
	var badge: RuleBadges.Badge = RuleBadges.Badge.new()
	badge.kind = kind
	badge.name = rule_name
	badge.text = text
	return badge


func test_same_name_folds_into_one_line() -> void:
	var badges: Array[RuleBadges.Badge] = [
		_badge("dungeon", "Red Tape Everywhere", "Start each battle with one Red Tape."),
		_badge("boss", "Processing Time", "Each player's first spell each turn costs 1 more."),
		_badge("boss", "Red Tape Everywhere", "Starts the duel with 3 Red Tape.\nMore detail."),
	]
	var distinct: Array[RuleBadges.Badge] = RulesBrief.distinct_by_name(badges)
	assert_eq(distinct.size(), 2, "one line per name")
	assert_eq(RulesBrief.line_text(distinct[0], badges), "Red Tape Everywhere: Start each battle with one Red Tape. Also: Starts the duel with 3 Red Tape.")
	assert_eq(RulesBrief.line_text(distinct[1], badges), "Processing Time: Each player's first spell each turn costs 1 more.")


func test_identical_texts_print_once() -> void:
	var badges: Array[RuleBadges.Badge] = [_badge("zone", "Fog", "Hidden hands."), _badge("dungeon", "Fog", "Hidden hands.")]
	assert_eq(RulesBrief.line_text(badges[0], badges), "Fog: Hidden hands.")
