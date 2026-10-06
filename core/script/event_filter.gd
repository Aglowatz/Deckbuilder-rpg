class_name EventFilter
extends RefCounted
## Matches the filters of a `when(...)` / `trap(...)` ability against an event, e.g. `unit_dies:mine,other`:
##   mine / opp / any       the event's player relative to the ability's controller
##   other                  the event's card is not the ability's own card
##   tok / nontok / tok:ID / golem
##   hustle / nohustle      the event card's keywords at the time of the event
##   atk<=3 / def<2 / cost>=4 / buffs>=1
##   unit / tool / wonder / infra / spell / trap / resource (card types; several joined with |)
##   multipath, iron / garbage / ... (the resource kind), le=5 (HP threshold)

const TYPE_WORDS: Array[String] = ["unit", "tool", "wonder", "infra", "spell", "trap", "resource", "token"]


## `data` keys: "card" (CardInstance or null), "player" (int), "kind" (resource kind), "hp" (int).
static func matches(state: GameState, filters: Array[String], source: CardInstance, controller: int, data: Dictionary) -> bool:
	var card: CardInstance = data.get("card") as CardInstance
	var event_player: int = int(data.get("player", -1))
	for filter: String in filters:
		if not _match_one(state, filter, source, controller, card, event_player, data):
			return false
	return true


static func _match_one(state: GameState, filter: String, source: CardInstance, controller: int, card: CardInstance, event_player: int, data: Dictionary) -> bool:
	match filter:
		"mine":
			return event_player == controller
		"opp":
			return event_player != controller and event_player >= 0
		"any", "":
			return true
		"other":
			return card == null or card != source
		"tok":
			return card != null and card.is_token()
		"nontok":
			return card != null and not card.is_token()
		"golem":
			return card != null and card.is_token() and card.data.display_name.contains("Golem")
		"hustle":
			return card != null and state.unit_has_keyword(card, CardEnums.Keyword.HUSTLE)
		"nohustle":
			return card != null and not state.unit_has_keyword(card, CardEnums.Keyword.HUSTLE)
		"multipath":
			return card != null and card.data.is_multipath()
	if filter.begins_with("tok:"):
		return card != null and card.is_token() and card.data.id == filter.substr(4)
	if filter.begins_with("le=") or filter.begins_with("le"):
		var limit_text: String = filter.trim_prefix("le=").trim_prefix("le")
		return int(data.get("hp", 9999)) <= int(limit_text)
	var regex: RegEx = RegEx.new()
	regex.compile("^(atk|def|cost|buffs)(<=|>=|==|=|<|>)(-?[0-9]+)$")
	var found: RegExMatch = regex.search(filter)
	if found != null:
		if card == null:
			return false
		var left: int = 0
		match found.get_string(1):
			"atk":
				left = state.get_attack(card)
			"def":
				left = state.get_defense(card)
			"cost":
				left = card.data.energy_value()
			"buffs":
				left = card.buffs
		var op: String = found.get_string(2)
		return TargetSpec.compare(left, "==" if op == "=" else op, int(found.get_string(3)))
	# Card types (possibly alternatives joined with |) or a resource kind.
	var words: PackedStringArray = filter.split("|")
	var all_types: bool = true
	for word: String in words:
		if not TYPE_WORDS.has(word):
			all_types = false
	if all_types:
		if card == null:
			return false
		for word: String in words:
			if _is_type(card, word):
				return true
		return false
	var kind: int = ResourceKind.from_word(filter)
	if kind != ResourceKind.NONE:
		return int(data.get("kind", ResourceKind.NONE)) == kind
	return false


static func _is_type(card: CardInstance, word: String) -> bool:
	match word:
		"unit":
			return card.data.is_unit()
		"tool":
			return card.data.is_tool()
		"wonder":
			return card.data.is_wonder()
		"infra":
			return card.data.is_infrastructure()
		"spell":
			return card.data.type == CardEnums.CardType.SPELL
		"trap":
			return card.data.type == CardEnums.CardType.TRAP
		"resource":
			return card.data.is_resource()
		"token":
			return card.is_token()
	return false
