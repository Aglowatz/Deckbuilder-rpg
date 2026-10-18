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

## Most explanations a card tooltip lists, so a text-heavy card does not bury the card itself.
const MAX_ENTRIES: int = 5

const GLOSSARY: Dictionary = {
	"Trap": "Played face-down on your turn. It springs automatically on your opponent's turn when its condition is met, then goes to your Refuse Pile.",
	"Summoning sickness": "A unit that just entered the field can't attack until your next turn (unless it has Hustle).",
	"Exhaust": "An exhausted card is spent until it refreshes at the start of its controller's turn.",
	"Activate": "Using an ability. Activated abilities can only be used on your own turn.",
	"Shred": "Removed from the game for good.",
	"Reinstate": "A unit from a Refuse Pile enters the field.",
	"Send back": "Returns a card to its owner's hand. Tokens vanish.",
	"Brawl": "Two units deal damage equal to their attack to each other.",
	"Plate": "The unit becomes a 1/1 Snack token with no abilities.",
	"Peek": "Look at the top cards of your deck and put any of them on the bottom.",
	"Bury": "The top cards of a deck go to its owner's Refuse Pile.",
	"Processing": "A delayed effect: it resolves at the start of your turn after the listed number of your turns.",
	"Buff": "+1/+1 permanently.",
	"Overexert": "Exhaust, and this unit does not refresh next turn.",
	"Eat Garbage": "A cost: pay 1 energy and use a Garbage. (The Raccoon makes the energy free.) Some cards also say \"lose N HP\" - that is a separate, written cost.",
}


static func keyword_name(keyword: CardEnums.Keyword) -> String:
	return str((KEYWORD_TEXT[keyword] as Array)[0])


static func keyword_description(keyword: CardEnums.Keyword) -> String:
	return str((KEYWORD_TEXT[keyword] as Array)[1])


## All (name, description, icon id) triples worth explaining for a card: keywords first, then Trap, the mechanics and the resources or tokens its rules text names.
## The icon id is "" when there is none.
static func entries_for(card: CardData) -> Array[Array]:
	var result: Array[Array] = []
	for keyword: CardEnums.Keyword in card.keywords:
		result.append([keyword_name(keyword), keyword_description(keyword), IconArt.keyword_id(keyword)])
	if card.type == CardEnums.CardType.TRAP:
		result.append(["Trap", str(GLOSSARY["Trap"]), IconArt.type_id(CardEnums.CardType.TRAP)])
	var text: String = card.rules_text
	for word: String in IconArt.WORD_IDS.keys():
		if result.size() >= MAX_ENTRIES:
			break
		if GLOSSARY.has(word) and (_prefix_word(text, word, "#") != text or _prefix_word(text, word.to_lower(), "#") != text):
			result.append([word, str(GLOSSARY[word]), str(IconArt.WORD_IDS[word])])
	for kind: int in [ResourceKind.Kind.IRON, ResourceKind.Kind.RED_TAPE, ResourceKind.Kind.CONTRACT, ResourceKind.Kind.INGREDIENT, ResourceKind.Kind.GARBAGE]:
		var kind_name: String = ResourceKind.display_name(kind)
		if result.size() < MAX_ENTRIES and _prefix_word(text, kind_name, "#") != text:
			result.append([kind_name, str(ResourceKind.DESCRIPTIONS[kind]), IconArt.resource_id(kind)])
	return result


## A tooltip heading: the icon (when there is one) and the name in gold.
static func title_row(name: String, icon_id: String, font_size: int) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var icon: TextureRect = IconArt.rect(icon_id, float(font_size) + 6.0) if icon_id != "" else null
	if icon != null:
		row.add_child(icon)
	var title: Label = UIKit.label(name, &"", font_size, UIStyle.GOLD)
	title.add_theme_font_override("font", UIStyle.font_bold())
	row.add_child(title)
	return row


## Turns card rules text into BBCode with keywords in bold gold. With `icon_px` > 0 resource, token and energy words get their small icon in front (IconArt).
static func rules_bbcode(card: CardData, on_dark: bool = false, icon_px: int = 0) -> String:
	var text: String = card.rules_text
	if card.is_infrastructure() and text.is_empty():
		text = "Exhaust: add one %s energy." % UIStyle.affinity_name(card.color)
	var gold: String = (UIStyle.GOLD if on_dark else UIStyle.GOLD.darkened(0.45)).to_html(false)
	var words: Array[String] = ["Trap"]
	for keyword: CardEnums.Keyword in KEYWORD_TEXT.keys():
		words.append(keyword_name(keyword))
	for word: String in words:
		text = _bold_word(text, word, gold)
	if icon_px > 0:
		text = _with_icons(text, card, icon_px)
	return text


## `text` with a small icon before each resource or token word (and before "energy" on Infrastructure); a word whose icon is missing stays plain.
static func _with_icons(text: String, card: CardData, icon_px: int) -> String:
	for code: String in ENERGY_CODES.keys():
		var energy_tag: String = IconArt.bbcode(IconArt.energy_id(ENERGY_CODES[code] as Affinity.Type), icon_px)
		if energy_tag != "":
			text = text.replace(code, energy_tag)
	for word: String in RULES_ICON_WORDS_FIRST:
		var tag: String = IconArt.bbcode(str(IconArt.RULES_WORD_IDS[word]), icon_px)
		if tag != "":
			text = _prefix_word(text, word, tag)
	if card.is_infrastructure():
		var energy: String = IconArt.bbcode("ICON-ENERGY-GENERIC" if card.produces_any else IconArt.energy_id(card.color), icon_px)
		if energy != "":
			text = _prefix_word(text, "energy", energy)
	return text


## Energy written in rules text: "(B)" is a Beefcake energy symbol and so on.
const ENERGY_CODES: Dictionary = {"(B)": Affinity.Type.BEEFCAKE, "(N)": Affinity.Type.NECROCRAT, "(G)": Affinity.Type.GOURMAND, "(R)": Affinity.Type.REFUSEMANCER}


## Longest words first so "Red Tape" is not split by a shorter match and plurals are not matched twice.
const RULES_ICON_WORDS_FIRST: Array[String] = ["Red Tape", "Ingredients", "Ingredient", "Contracts", "Contract", "Clauses", "Clause", "Irons", "Iron", "Garbage"]


## The rules text with room for the icons (an "M" per icon) so the font-fit measures the real width.
static func measure_text(card: CardData) -> String:
	var text: String = card.rules_text if card.rules_text != "" else (rules_bbcode(card) if card.is_infrastructure() else "")
	for word: String in RULES_ICON_WORDS_FIRST:
		if IconArt.has(str(IconArt.RULES_WORD_IDS[word])):
			text = _prefix_word(text, word, "M")
	for code: String in ENERGY_CODES.keys():
		if IconArt.has(IconArt.energy_id(ENERGY_CODES[code] as Affinity.Type)):
			text = text.replace(code, "M")
	return text


static func _prefix_word(text: String, word: String, prefix: String) -> String:
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
		result += (prefix + word) if before_ok and after_ok else word
		index = end
	return result


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
