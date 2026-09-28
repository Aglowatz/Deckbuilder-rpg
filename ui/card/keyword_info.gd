class_name KeywordInfo
extends RefCounted
## Player-facing names and explanations of keywords and card types (tooltips, bold text).

const KEYWORD_TEXT: Dictionary = {
	CardEnums.Keyword.FLYING: ["Flying", "Can only be blocked by creatures with Flying or Reach."],
	CardEnums.Keyword.REACH: ["Reach", "Can block creatures with Flying."],
	CardEnums.Keyword.HASTE: ["Haste", "Can attack the turn it enters play."],
	CardEnums.Keyword.DEFENDER: ["Defender", "Cannot attack."],
	CardEnums.Keyword.TRAMPLE: ["Trample", "Excess combat damage carries over to the player when blocked."],
	CardEnums.Keyword.FIRST_STRIKE: ["First Strike", "Deals combat damage before creatures without it."],
	CardEnums.Keyword.LIFESTEAL: ["Lifesteal", "Damage dealt by this creature also heals its controller."],
	CardEnums.Keyword.GUARD: ["Guard", "While you control an untapped Guard creature, enemy attackers must attack a Guard creature. A tapped Guard does not force attacks."],
	CardEnums.Keyword.VIGILANCE: ["Vigilance", "Attacking does not tap this creature."],
}

const GLOSSARY: Dictionary = {
	"Trap": "Set face-down on your turn. It springs automatically when its condition is met, then is spent.",
	"Summoning sickness": "A creature that just entered play cannot attack until your next turn (unless it has Haste).",
	"Tapped": "A tapped creature or land is spent until its controller's next turn.",
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
static func rules_bbcode(card: CardData) -> String:
	var text: String = card.rules_text
	if card.is_land():
		text = "Tap: add one %s mana." % UIStyle.affinity_name(card.color)
	var gold: String = UIStyle.GOLD.darkened(0.45).to_html(false)
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
