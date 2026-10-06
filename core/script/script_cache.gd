class_name ScriptCache
extends RefCounted
## Parses each distinct card script once. `ScriptCache.parsed(card)` is what the engine calls at run time.

static var _cache: Dictionary = {}
static var _empty: ScriptParser.Parsed = ScriptParser.Parsed.new()


static func parsed_text(script_text: String) -> ScriptParser.Parsed:
	if script_text.is_empty():
		return _empty
	if _cache.has(script_text):
		return _cache[script_text] as ScriptParser.Parsed
	var result: ScriptParser.Parsed = ScriptParser.parse(script_text)
	_cache[script_text] = result
	return result


static func parsed(data: CardData) -> ScriptParser.Parsed:
	return parsed_text(data.script_text)


static func abilities(data: CardData) -> Array[CardAbility]:
	return parsed_text(data.script_text).abilities


## True when the card has any continuous ability (aura, host effect, static flag, cost change): the engine only
## scans those cards when it computes stats, keywords and flags.
static func has_static(data: CardData) -> bool:
	for ability: CardAbility in abilities(data):
		if ability.is_static_kind():
			return true
	return false
