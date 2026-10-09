class_name KeywordInfo
extends RefCounted
## Player-facing names and explanations of keywords and card types (tooltips, bold text).

const KEYWORD_TEXT: Dictionary = {
	CardEnums.Keyword.FLYING: ["Flying", "Can only be blocked by units with Flying or Swat."],
	CardEnums.Keyword.SWAT: ["Swat", "Can block units with Flying."],
	CardEnums.Keyword.HUSTLE: ["Hustle", "Can attack and activate the turn it enters."],
	CardEnums.Keyword.WALLFLOWER: ["Wallflower", "Can't attack."],
	CardEnums.Keyword.BULLDOZE: ["Bulldoze", "Excess combat damage beyond the blocker's defense hits the opponent."],
	CardEnums.Keyword.SUCKER_PUNCH: ["Sucker Punch", "Deals combat damage before units without it."],
	CardEnums.Keyword.ONE_TWO_PUNCH: ["One-Two Punch", "Deals both Sucker Punch and regular combat damage."],
	CardEnums.Keyword.TOXIC: ["Toxic", "Any damage this deals to a unit destroys it."],
	CardEnums.Keyword.NOURISH: ["Nourish", "Damage this deals also heals you that much."],
	CardEnums.Keyword.OVERTIME: ["Overtime", "Attacking doesn't activate (exhaust) this unit."],
	CardEnums.Keyword.ELUSIVE: ["Elusive", "Can't be blocked."],
	CardEnums.Keyword.UNTOUCHABLE: ["Untouchable", "Can't be targeted by your opponent's cards."],
	CardEnums.Keyword.UNBREAKABLE: ["Unbreakable", "Can't be destroyed by damage or destroy effects. It can still be Shredded, sent back, or reduced to 0 defense."],
}

const GLOSSARY: Dictionary = {
	"Trap": "Played face-down on your turn. It springs automatically on your opponent's turn when its condition is met, then goes to your Refuse Pile.",
	"Summoning sickness": "A unit that just entered the field can't attack until your next turn (unless it has Hustle).",
	"Exhaust": "An exhausted card is spent until it refreshes at the start of its controller's turn.",
	"Activate": "Using an ability. Activated abilities can only be used on your own turn.",
	"Shred": "Removed from the game for good.",
}


static func keyword_name(keyword: CardEnums.Keyword) -> String:
	return str((KEYWORD_TEXT[keyword] as Array)[0])


static func keyword_description(keyword: CardEnums.Keyword) -> String:
	return str((KEYWORD_TEXT[keyword] as Array)[1])


## All (name, description) pairs worth explaining for a card, keywords first.
static func entries_for(card: CardData) -> Array[Array]:
	var result: Array[Array] = []
	for keyword: CardEnums.Keyword in card.keywords:
		result.append([keyword_name(keyword), keyword_description(keyword)])
	if card.type == CardEnums.CardType.TRAP:
		result.append(["Trap", str(GLOSSARY["Trap"])])
	return result


## Turns card rules text into BBCode with keywords in bold gold.
static func rules_bbcode(card: CardData, on_dark: bool = false) -> String:
	var text: String = card.rules_text
	if card.is_infrastructure() and text.is_empty():
		text = "Exhaust: add one %s energy." % UIStyle.affinity_name(card.color)
	var gold: String = (UIStyle.GOLD if on_dark else UIStyle.GOLD.darkened(0.45)).to_html(false)
	var words: Array[String] = ["Trap"]
	for keyword: CardEnums.Keyword in KEYWORD_TEXT.keys():
		words.append(keyword_name(keyword))
	for word: String in words:
		text = _bold_word(text, word, gold)
	return text


static func _bold_word(text: String, word: String, color_hex: String) -> String:
	# Whole-word replace without RegEx (plain string scan).
	var result: String = ""
	var index: int = 0
	while true:
		var found: int = text.find(word, index)
		if found < 0:
			result += text.substr(index)
			break
		var end: int = found + word.length()
		var before_ok: bool = found == 0 or not _is_word_char(text[found - 1])
		var after_ok: bool = end >= text.length() or not _is_word_char(text[end])
		result += text.substr(index, found - index)
		if before_ok and after_ok:
			result += "[b][color=#%s]%s[/color][/b]" % [color_hex, word]
		else:
			result += word
		index = end
	return result


static func _is_word_char(character: String) -> bool:
	return character.to_lower() != character.to_upper() or character.is_valid_int() or character == "_"
