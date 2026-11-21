extends GutTest
## Fable Nov 21 review (Part 4.2): a card's printed text says what its script does. Checked on every card and token: the energy an ability
## asks for ("Pay 1(G)" is one of any Path plus one Gourmand) and the keywords the card is printed with.
## Found by this check: Recipe for Wonder (G-31) printed "Pay 1(G)" and charged only (G).

const KEYWORD_NAMES: Dictionary = {
	"flying": "Flying", "swat": "Swat", "hustle": "Hustle", "wallflower": "Wallflower", "bulldoze": "Bulldoze", "sucker_punch": "Sucker Punch",
	"one_two_punch": "One-Two Punch", "toxic": "Toxic", "nourish": "Nourish", "overtime": "Overtime", "elusive": "Elusive",
	"untouchable": "Untouchable", "unbreakable": "Unbreakable",
}


func _all_cards() -> Array[CardData]:
	var cards: Array[CardData] = []
	for folder: String in ["res://data/cards", "res://data/tokens"]:
		for file: String in DirAccess.get_files_at(folder):
			if file.ends_with(".tres"):
				var card: CardData = load("%s/%s" % [folder, file]) as CardData
				if card != null:
					cards.append(card)
	return cards


## "1(G)", "2", "(B)(B)" -> "1G", "2", "BB": the amounts the text asks to pay, in reading order.
func _text_payments(rules: String) -> Array[String]:
	var found: Array[String] = []
	var pattern: RegEx = RegEx.new()
	pattern.compile("(?i)\\bpay (\\d*)((?:\\([BGNR]\\))*)")
	for hit: RegExMatch in pattern.search_all(rules):
		var amount: String = hit.get_string(1)
		var pips: String = hit.get_string(2).replace("(", "").replace(")", "")
		if amount.is_empty() and pips.is_empty():
			continue
		found.append(("" if amount == "0" else amount) + pips)
	found.sort()
	return found


func _script_payments(card: CardData) -> Array[String]:
	var found: Array[String] = []
	for ability: CardAbility in card.abilities():
		for cost: CardAbility.Cost in ability.costs:
			if cost.kind != "pay":
				continue
			var text: String = str(cost.generic) if cost.generic > 0 else ""
			for pip: Affinity.Type in cost.pips:
				text += Affinity.symbol(pip)
			found.append(text)
	found.sort()
	return found


func test_every_card_loads_and_parses() -> void:
	var cards: Array[CardData] = _all_cards()
	assert_gt(cards.size(), 340, "the whole card set is read")
	for card: CardData in cards:
		assert_eq(card.parsed_script().errors.size(), 0, "%s (%s): the script parses" % [card.id, card.display_name])


func test_the_energy_an_ability_costs_is_the_energy_its_text_says() -> void:
	var checked: int = 0
	for card: CardData in _all_cards():
		var from_text: Array[String] = _text_payments(card.rules_text)
		var from_script: Array[String] = _script_payments(card)
		if from_text.is_empty() and from_script.is_empty():
			continue
		# a resource card's own text ("Pay 1, use this Red Tape") is the resource rule, not a card script
		if card.script_text.is_empty():
			continue
		checked += 1
		assert_eq(from_script, from_text, "%s (%s): the text asks for %s, the script charges %s" % [card.id, card.display_name, str(from_text), str(from_script)])
	assert_gte(checked, 10, "the pay costs were found (%d cards)" % checked)


func test_recipe_for_wonder_costs_one_and_a_gourmand_energy() -> void:
	var card: CardData = load("res://data/cards/G-31.tres") as CardData
	var energy: Dictionary = {}
	for ability: CardAbility in card.abilities():
		if not ability.costs.is_empty():
			energy = AbilityRunner.energy_cost(ability.costs)
	assert_eq(int(energy.get("generic", -1)), 1, "one energy of any Path")
	assert_eq((energy.get("pips", []) as Array).size(), 1, "and one Gourmand energy")
	assert_eq(int((energy.get("pips", []) as Array)[0]), Affinity.Type.GOURMAND)


## A sentence of the text that is only keyword names ("Hustle. Bulldoze.") lists the keywords the script gives the card, and the other
## way round.
func test_the_keywords_printed_are_the_keywords_the_script_gives() -> void:
	var sentence_end: RegEx = RegEx.new()
	sentence_end.compile("[.\\n]")
	for card: CardData in _all_cards():
		if card.script_text.is_empty():
			continue
		var printed: Array[String] = []
		for paragraph: String in card.rules_text.split("\n"):
			var names: Array[String] = []
			var only_keywords: bool = true
			for piece: String in paragraph.split("."):
				var word: String = piece.strip_edges()
				if word.is_empty():
					continue
				if KEYWORD_NAMES.values().has(word):
					names.append(word)
				else:
					only_keywords = false
			if only_keywords:
				printed.append_array(names)
		var scripted: Array[String] = []
		for line: String in card.script_text.split("\n"):
			for clause: String in line.split(";"):
				var text: String = clause.strip_edges()
				if text.begins_with("kw "):
					for key: String in text.substr(3).split(","):
						scripted.append(str(KEYWORD_NAMES.get(key.strip_edges(), key.strip_edges())))
		printed.sort()
		scripted.sort()
		assert_eq(printed, scripted, "%s (%s): printed keywords %s, scripted %s" % [card.id, card.display_name, str(printed), str(scripted)])
