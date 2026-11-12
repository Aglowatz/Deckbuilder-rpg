extends GutTest
## Fable Nov 12c (A3): nothing the player reads says a deck holds 4 copies of a card. The rule is "up to 3 copies of any one card,
## depending on your level", and every text that names numbers matches `CopyCaps`.

const PLAYER_TEXT: Array[String] = [
	"res://data/loading/loading_tips.txt",
	"res://data/story/intro_story.tres",
	"res://ui/town/vendor_screen.gd",
	"res://ui/town/alchemist_screen.gd",
	"res://ui/town/deckbuilder_screen.gd",
	"res://ui/screens/glossary_panel.gd",
	"res://core/data/copy_caps.gd",
	"res://core/dungeon/deck_validator.gd",
	"res://docs/design/combat_rules.md",
	"res://docs/design/progression.md",
	"res://docs/design/essence_and_alchemy.md",
]
const WRONG: Array[String] = ["4 copies", "four copies", "4-copy", "four-copy", "beyond your fourth", "up to 4 of", "up to four of"]


func test_no_text_says_four_copies() -> void:
	for path: String in PLAYER_TEXT:
		var text: String = FileAccess.get_file_as_string(path).to_lower()
		assert_false(text.is_empty(), "%s is read" % path)
		for wrong: String in WRONG:
			if path.ends_with("alchemist_screen.gd") and wrong == "four-copy":
				continue  # a code comment that says the old four-copy rule was replaced
			assert_false(text.contains(wrong), "%s says '%s'" % [path, wrong])


func test_the_rule_names_three_and_the_real_caps() -> void:
	assert_eq(CopyCaps.absolute_max(), 3)
	assert_eq(CopyCaps.RULE, "You can have up to 3 copies of any one card, depending on your level.")
	assert_eq(CopyCaps.rule_text(1), "%s At level 1: Common 3, Uncommon 2, Epic 1, Legendary 1. Infrastructure has no limit." % CopyCaps.RULE)
	assert_string_contains(CopyCaps.rule_text(30), "Common 3, Uncommon 3, Epic 3, Legendary 3")
	for level: int in range(1, 31):
		for rarity: int in range(CardEnums.Rarity.size()):
			assert_between(CopyCaps.cap_for(rarity as CardEnums.Rarity, level), 1, 3, "level %d rarity %d" % [level, rarity])


func test_the_loading_tip_states_the_rule() -> void:
	var tips: String = FileAccess.get_file_as_string("res://data/loading/loading_tips.txt")
	assert_string_contains(tips, CopyCaps.RULE)
