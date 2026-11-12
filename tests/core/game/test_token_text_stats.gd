extends GutTest
## Fable Nov 12c (A5): where a text states a token's numbers ("a 1/1 Snack token", "a 3/3 Poo Golem"), the token really has them -
## in the data, and on the board in the fight the text belongs to (Chef Fennel Gravois's Snack stood as a 0/1 under the zone-order ease).

const TEXT_FILES: Array[String] = [
	"res://data/encounters/encounter_scripts.json",
	"res://data/encounters/modifiers.json",
	"res://data/encounters/boss_intros.json",
	"res://data/dungeons/dungeon_content.json",
]


func before_each() -> void:
	Session.new_game()


func after_all() -> void:
	Session.new_game()


## Token display name -> data, the longest names first (so "Chef's Special Golem" wins over a shorter name inside it).
func _tokens() -> Array[CardData]:
	var result: Array[CardData] = []
	for value: Variant in Session.content.tokens.values():
		var token: CardData = value as CardData
		if token != null and token.is_unit():
			result.append(token)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return a.display_name.length() > b.display_name.length())
	return result


## Every "N/N Name" in `text` whose Name is a unit token: [[attack, defense, token]].
func _stated(text: String, tokens: Array[CardData]) -> Array[Array]:
	var found: Array[Array] = []
	var pattern: RegEx = RegEx.new()
	pattern.compile("(\\d+)/(\\d+) ([A-Z][^.,;:()\"]{1,40})")
	for hit: RegExMatch in pattern.search_all(text):
		var rest: String = hit.get_string(3)
		for token: CardData in tokens:
			var name: String = token.display_name
			if rest == name or rest.begins_with(name + " ") or rest.begins_with(name + "s ") or rest == name + "s":
				found.append([int(hit.get_string(1)), int(hit.get_string(2)), token])
				break
	return found


func test_every_text_that_states_a_tokens_numbers_matches_the_token() -> void:
	var tokens: Array[CardData] = _tokens()
	assert_gt(tokens.size(), 10)
	var texts: Dictionary = {}
	for value: Variant in Session.content.cards.values():
		texts["card %s" % (value as CardData).id] = (value as CardData).rules_text
	for value: Variant in Session.content.tokens.values():
		texts["token %s" % (value as CardData).id] = (value as CardData).rules_text
	for path: String in TEXT_FILES:
		var body: String = FileAccess.get_file_as_string(path)
		assert_false(body.is_empty(), "%s is read" % path)
		var number: int = 0
		for line: String in body.split("\n"):
			number += 1
			texts["%s:%d" % [path.get_file(), number]] = line
	var checked: int = 0
	for where: Variant in texts.keys():
		for statement: Array in _stated(str(texts[where]), tokens):
			var token: CardData = statement[2] as CardData
			checked += 1
			assert_eq("%d/%d" % [statement[0], statement[1]], "%d/%d" % [token.attack, token.defense], "%s says a %d/%d %s" % [where, statement[0], statement[1], token.display_name])
	assert_gt(checked, 30, "the scan found the statements (44 on Nov 12)")


func test_the_snack_is_a_one_one() -> void:
	var snack: CardData = TokenRegistry.data("T-09")
	assert_eq(snack.display_name, "Snack")
	assert_eq(snack.attack, 1)
	assert_eq(snack.defense, 1)


func test_gravois_snack_enters_as_a_one_one_even_when_his_zone_is_met_early() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	assert_eq(Session.completed_zone_count(), 0, "no zone freed: the Buffet is two places early, so his units hit 1 softer")
	var context: BattleContext = Session.make_npc_challenge_battle("gourmand")
	var game: GameState = context.game
	var eased: bool = false
	for modifier: Modifier in game.players[1].modifiers.modifiers:
		if modifier.kind == Modifier.Kind.STAT_CHANGE and modifier.label == ZoneOrderEase.LABEL and modifier.value < 0:
			eased = true
	assert_true(eased, "the ease is on his side")
	var snack: CardInstance = game.create_stated_token(1, TokenRegistry.data("T-09"))
	assert_eq(game.get_attack(snack), 1, "the Snack the event's text calls a 1/1 has 1 attack")
	assert_eq(game.get_defense(snack), 1)
	var plain: CardInstance = game.create_token(1, TokenRegistry.data("T-09"))
	assert_eq(game.get_attack(plain), 0, "the ease itself is unchanged for his other units")


func test_the_event_and_the_timed_rules_use_the_stated_token() -> void:
	var scripts: String = FileAccess.get_file_as_string("res://core/dungeon/encounter_scripts.gd")
	assert_true(scripts.contains("state.create_stated_token(owner, token)"), "a boss event's summon")
	var state: String = FileAccess.get_file_as_string("res://core/game/game_state.gd")
	assert_eq(state.count("create_stated_token(player_index, modifier.tokens["), 2, "the timed and staged rule summons")
	var events: String = FileAccess.get_file_as_string("res://data/encounters/encounter_scripts.json")
	assert_true(events.contains("a 1/1 Snack joins his side"), "the text still says 1/1")
