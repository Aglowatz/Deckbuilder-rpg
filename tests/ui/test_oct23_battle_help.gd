extends GutTest
## Overnight Oct 23: boss entrances (BossIntros), status help in the battle tooltip (StatusInfo) and the pause menu's Glossary.


func test_every_intro_has_a_title_and_a_line_and_known_sting() -> void:
	assert_gt(BossIntros.keys().size(), 25, "bosses, lieutenants and gatekeepers")
	for key: String in BossIntros.keys():
		var intro: Dictionary = BossIntros.find(key)
		assert_false(intro.is_empty(), key)
		assert_false(str(intro["title"]).is_empty(), "%s has a title" % key)
		assert_false(str(intro["line"]).is_empty(), "%s has an opening line" % key)
		assert_lt(str(intro["line"]).length(), 160, "%s: the line fits one box" % key)
		assert_true(AudioRegistry.has_id(str(intro["sting"])), "%s: sting %s exists" % [key, str(intro["sting"])])


func test_names_with_titles_and_phases_match() -> void:
	var clench: Dictionary = BossIntros.find("Chancellor Clench, Iron Regent")
	assert_eq(str(clench["name"]), "Chancellor Clench")
	var primm: Dictionary = BossIntros.find("Primm - Standardization")
	assert_eq(str(primm["name"]), "Primm")
	assert_string_contains(str(primm["title"]), "Standardization")
	assert_true(BossIntros.find("Cave Scavenger").is_empty(), "ordinary foes have no entrance")
	assert_true(BossIntros.find("Brick Bronson").has("color"))


func test_every_scripted_boss_has_an_entrance() -> void:
	for name: String in ["Chancellor Clench, Iron Regent", "The Doppelganger", "Mortimer Grimsby, CE-No", "Compostella, the Rotheart",
			"Brick Bronson", "Prudence Pallor", "Moss Mulligan", "Chef Fennel Gravois", "Vivienne Quota, Minister of Efficiency",
			"Hortensia Clipwell, Royal Groundskeeper", "Percival Plume, Deputy Minister of Good News", "Colonel Cornelius Crumb, Director of Culinary Defense"]:
		assert_false(BossIntros.find(name).is_empty(), name)


func test_status_entries_explain_exhaustion_red_tape_pumps_and_tokens() -> void:
	var game: GameState = GameFactory.blank_game(3)
	var unit: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(3, 3))
	assert_eq(StatusInfo.entries(game, unit).size(), 0, "a plain ready unit has nothing to explain")
	game.exhaust_unit(unit, true)
	game.change_stats_until_turn_of(unit, -2, 0, 1)
	game.change_stats(unit, 1, 1, true)
	game.change_stats(unit, 2, 0, false)
	var titles: Array[String] = []
	var texts: String = ""
	for entry: Array in StatusInfo.entries(game, unit):
		titles.append(str(entry[0]))
		texts += str(entry[1]) + "\n"
	assert_has(titles, "Exhausted")
	assert_has(titles, "Red Tape")
	assert_has(titles, "Until end of turn")
	assert_has(titles, "Changed for good")
	assert_string_contains(texts, "skip its next refresh")
	assert_string_contains(texts, "-2/-0 until the start of the enemy's next turn (1 turn left)")
	var token: CardInstance = game.create_token(1, TokenRegistry.data("T-21"))
	var token_titles: Array[String] = []
	for entry: Array in StatusInfo.entries(game, token):
		token_titles.append(str(entry[0]))
	assert_has(token_titles, "Token")


func test_the_glossary_has_every_tab_filled() -> void:
	for index: int in range(GlossaryPanel.TABS.size()):
		assert_gt(GlossaryPanel.entries(index).size(), 2, "tab %s" % GlossaryPanel.TABS[index])
	var keywords: Array[Array] = GlossaryPanel.entries(0)
	assert_eq(keywords.size(), KeywordInfo.KEYWORD_TEXT.size(), "every keyword")
	var rules: String = ""
	for entry: Array in GlossaryPanel.entries(GlossaryPanel.TABS.find("Rule icons")):
		rules += str(entry[1])
	assert_string_contains(rules, "scripted", "the amber scripted-event icons are explained")
