class_name ScriptParser
extends RefCounted
## Parses a card script (see docs/card_pipeline.md) into `CardAbility` objects. One ability per line:
##
##   HEAD[(event or aura spec)] [name=spec ...] [once] [| COSTS] [? COND] => EFFECTS
##
## plus header lines `kw swat,flying` (keywords) and `produce N|B` / `produce any` (infrastructure energy).
## COSTS are comma-separated (`exhaust, pay(1), use(garbage,2), eat`), EFFECTS are `;`-separated calls (`create(garbage); draw(1)`),
## blocks are `{ a; b }`. `#` starts a comment line.

const HEADS: Dictionary = {
	"enter": CardAbility.Kind.ENTER,
	"die": CardAbility.Kind.DIE,
	"play": CardAbility.Kind.PLAY,
	"act": CardAbility.Kind.ACT,
	"attach": CardAbility.Kind.ATTACH,
	"static": CardAbility.Kind.STATIC,
	"aura": CardAbility.Kind.AURA,
	"host": CardAbility.Kind.HOST,
	"sot": CardAbility.Kind.START_OF_TURN,
	"eot": CardAbility.Kind.END_OF_TURN,
	"boc": CardAbility.Kind.BEGINNING_OF_COMBAT,
	"attack": CardAbility.Kind.ATTACK,
	"block": CardAbility.Kind.BLOCK,
	"when": CardAbility.Kind.WHEN,
	"trap": CardAbility.Kind.TRAP,
	"playcost": CardAbility.Kind.PLAY_COST,
	"costmod": CardAbility.Kind.COST_MOD,
	"drawn": CardAbility.Kind.DRAWN,
}

## Event aliases: a script event name -> [real event name, extra filters].
const EVENT_ALIASES: Dictionary = {
	"token_dies": ["unit_dies", ["tok"]],
	"rat_dies": ["unit_dies", ["tok:T-02"]],
	"schmuck_dies": ["unit_dies", ["tok:T-23"]],
	"golem_created": ["token_created", ["golem"]],
	"attacked": ["attacks", ["opp"]],
}


## The result of parsing a whole card script.
class Parsed:
	extends RefCounted
	var abilities: Array[CardAbility] = []
	var keywords: Array[CardEnums.Keyword] = []
	var produces: Array[Affinity.Type] = []
	var produces_any: bool = false
	var errors: Array[String] = []
	## Event names this card listens to (`when` and `trap` abilities), for a quick reject when events fire.
	var events: Dictionary = {}


static func parse(script_text: String) -> Parsed:
	var parsed: Parsed = Parsed.new()
	var line_number: int = 0
	for raw_line: String in script_text.split("\n"):
		line_number += 1
		var line: String = raw_line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		if line.begins_with("kw "):
			_parse_keywords(line.substr(3), parsed, line_number)
			continue
		if line.begins_with("produce "):
			_parse_produce(line.substr(8), parsed, line_number)
			continue
		var ability: CardAbility = _parse_ability(line, parsed, line_number)
		if ability != null:
			ability.index = parsed.abilities.size()
			parsed.abilities.append(ability)
			if not ability.event.is_empty():
				parsed.events[ability.event] = true
	return parsed


static func _parse_keywords(text: String, parsed: Parsed, line_number: int) -> void:
	for word: String in text.split(","):
		var keyword: int = keyword_from_word(word.strip_edges())
		if keyword < 0:
			parsed.errors.append("line %d: unknown keyword '%s'" % [line_number, word])
		else:
			parsed.keywords.append(keyword as CardEnums.Keyword)


static func keyword_from_word(word: String) -> int:
	var key: String = word.to_upper().replace("-", "_").replace(" ", "_")
	if CardEnums.Keyword.keys().has(key):
		return int(CardEnums.Keyword[key])
	return -1


static func _parse_produce(text: String, parsed: Parsed, line_number: int) -> void:
	var word: String = text.strip_edges()
	if word == "any":
		parsed.produces_any = true
		return
	for letter: String in word.split("|"):
		var path: Affinity.Type = Affinity.from_symbol(letter.strip_edges())
		if path == Affinity.Type.NEUTRAL:
			parsed.errors.append("line %d: unknown energy symbol '%s'" % [line_number, letter])
		else:
			parsed.produces.append(path)


# ---- One ability line ---------------------------------------------------------------------


static func _parse_ability(line: String, parsed: Parsed, line_number: int) -> CardAbility:
	var ability: CardAbility = CardAbility.new()
	ability.source_text = line
	var left: String = line
	var right: String = ""
	var arrow: int = line.find(" => ")
	if arrow >= 0:
		left = line.substr(0, arrow)
		right = line.substr(arrow + 4)
	elif line.ends_with(" =>"):
		left = line.substr(0, line.length() - 3)
	# Condition: ` ? cond` or ` ?! cond` at the end of the left part.
	var cond_text: String = ""
	var cond_at: int = _find_top_level(left, " ?! ")
	if cond_at >= 0:
		cond_text = left.substr(cond_at + 4)
		left = left.substr(0, cond_at)
		ability.condition_negated = true
	else:
		cond_at = _find_top_level(left, " ? ")
		if cond_at >= 0:
			cond_text = left.substr(cond_at + 3)
			left = left.substr(0, cond_at)
	var costs_text: String = ""
	var pipe_at: int = _find_top_level(left, " | ")
	if pipe_at >= 0:
		costs_text = left.substr(pipe_at + 3)
		left = left.substr(0, pipe_at)
	if not _parse_head(left.strip_edges(), ability, parsed, line_number):
		return null
	if not costs_text.is_empty():
		for cost_text: String in _split_top_level(costs_text, ","):
			_parse_cost(cost_text.strip_edges(), ability, parsed, line_number)
	if ability.kind == CardAbility.Kind.ATTACH:
		_complete_attach(ability)
	if not cond_text.is_empty():
		ability.condition = _parse_condition(cond_text.strip_edges(), parsed, line_number)
	if not right.strip_edges().is_empty():
		for effect_text: String in _split_top_level(right, ";"):
			var stripped: String = effect_text.strip_edges()
			if stripped.is_empty():
				continue
			var fx: CardAbility.Fx = parse_effect(stripped, parsed, line_number)
			if fx != null:
				ability.effects.append(fx)
	return ability


## "Exhaust: attach to target unit you control" - the part every Tool shares.
static func _complete_attach(ability: CardAbility) -> void:
	var decl: CardAbility.TargetDecl = CardAbility.TargetDecl.new()
	decl.name = "t"
	decl.spec = TargetSpec.parse("unit.mine")
	ability.targets.append(decl)
	if not ability.has_cost("exhaust"):
		var exhaust: CardAbility.Cost = CardAbility.Cost.new()
		exhaust.kind = "exhaust"
		ability.costs.insert(0, exhaust)
	var attach_fx: CardAbility.Fx = CardAbility.Fx.new()
	attach_fx.name = "attach"
	attach_fx.args = ["t"]
	attach_fx.text = "attach(t)"
	ability.effects.insert(0, attach_fx)

static func _parse_head(text: String, ability: CardAbility, parsed: Parsed, line_number: int) -> bool:
	var tokens: PackedStringArray = text.split(" ", false)
	if tokens.is_empty():
		parsed.errors.append("line %d: empty ability" % line_number)
		return false
	var head_token: String = tokens[0]
	var head_name: String = head_token
	var inner: String = ""
	var paren: int = head_token.find("(")
	if paren >= 0 and head_token.ends_with(")"):
		head_name = head_token.substr(0, paren)
		inner = head_token.substr(paren + 1, head_token.length() - paren - 2)
	if not HEADS.has(head_name):
		parsed.errors.append("line %d: unknown ability head '%s'" % [line_number, head_name])
		return false
	ability.kind = HEADS[head_name] as CardAbility.Kind
	if ability.kind == CardAbility.Kind.WHEN or ability.kind == CardAbility.Kind.TRAP:
		_parse_event(inner, ability)
	elif ability.kind == CardAbility.Kind.AURA:
		ability.aura_spec = TargetSpec.parse(inner)
	for i: int in range(1, tokens.size()):
		var token: String = tokens[i]
		if token == "once":
			ability.once = true
		elif token.contains("="):
			var eq: int = token.find("=")
			var decl: CardAbility.TargetDecl = CardAbility.TargetDecl.new()
			decl.name = token.substr(0, eq)
			var spec_text: String = token.substr(eq + 1)
			var star: int = spec_text.rfind("*")
			if star >= 0 and spec_text.substr(star + 1).is_valid_int():
				decl.max_count = int(spec_text.substr(star + 1))
				spec_text = spec_text.substr(0, star)
			decl.spec = TargetSpec.parse(spec_text)
			ability.targets.append(decl)
		else:
			parsed.errors.append("line %d: unexpected head token '%s'" % [line_number, token])
	return true


static func _parse_event(inner: String, ability: CardAbility) -> void:
	var cleaned: String = inner.replace(":", ",")
	var parts: PackedStringArray = cleaned.split(",", false)
	if parts.is_empty():
		return
	var event_name: String = parts[0].strip_edges()
	var filters: Array[String] = []
	for i: int in range(1, parts.size()):
		filters.append(parts[i].strip_edges())
	if EVENT_ALIASES.has(event_name):
		var alias: Array = EVENT_ALIASES[event_name] as Array
		event_name = str(alias[0])
		for extra: Variant in alias[1] as Array:
			filters.append(str(extra))
	ability.event = event_name
	ability.event_filters = filters


# ---- Costs ----------------------------------------------------------------------------------


static func _parse_cost(text: String, ability: CardAbility, parsed: Parsed, line_number: int) -> void:
	if text == "once":
		ability.once = true
		return
	var cost: CardAbility.Cost = CardAbility.Cost.new()
	var call: CardAbility.Fx = parse_effect(text, parsed, line_number)
	if call == null:
		return
	cost.kind = call.name
	match call.name:
		"exhaust", "overexert", "destroy_self":
			pass
		"eat":
			if not call.args.is_empty():
				_set_count(cost, call.args[0])
		"pay":
			if call.args.is_empty():
				parsed.errors.append("line %d: pay needs an amount" % line_number)
			else:
				_parse_pay(cost, str(call.args[0]), parsed, line_number)
		"use":
			if call.args.is_empty():
				parsed.errors.append("line %d: use needs a resource" % line_number)
			else:
				_parse_use(cost, call, parsed, line_number)
		"destroy":
			if call.args.is_empty():
				parsed.errors.append("line %d: destroy needs a target spec" % line_number)
			else:
				cost.spec = TargetSpec.parse(str(call.args[0]))
				if call.args.size() > 1:
					_set_count(cost, call.args[1])
		_:
			parsed.errors.append("line %d: unknown cost '%s'" % [line_number, call.name])
			return
	ability.costs.append(cost)


static func _set_count(cost: CardAbility.Cost, value: Variant) -> void:
	if str(value) == "X":
		cost.x_count = true
		cost.count = 1
	else:
		cost.count = int(value)


## `pay(1)`, `pay(G)`, `pay(2)`, `pay(1G)`, `pay(RR)`: generic digits then Path letters.
static func _parse_pay(cost: CardAbility.Cost, text: String, parsed: Parsed, line_number: int) -> void:
	var digits: String = ""
	for character: String in text:
		if character.is_valid_int():
			digits += character
		else:
			var path: Affinity.Type = Affinity.from_symbol(character)
			if path == Affinity.Type.NEUTRAL:
				parsed.errors.append("line %d: bad pay symbol '%s'" % [line_number, character])
			else:
				cost.pips.append(path)
	cost.generic = int(digits) if not digits.is_empty() else 0


static func _parse_use(cost: CardAbility.Cost, call: CardAbility.Fx, parsed: Parsed, line_number: int) -> void:
	var what: String = str(call.args[0])
	if what == "token":
		cost.kind = "use_token"
	else:
		for word: String in what.split("|"):
			var kind: int = ResourceKind.from_word(word)
			if kind == ResourceKind.NONE:
				parsed.errors.append("line %d: unknown resource '%s'" % [line_number, word])
			else:
				cost.resource_kinds.append(kind as ResourceKind.Kind)
	if call.args.size() > 1:
		_set_count(cost, call.args[1])


# ---- Effects and conditions ---------------------------------------------------------------


## Parses one effect call such as `damage(t,2)`. Returns null (and records an error) on bad syntax.
static func parse_effect(text: String, parsed: Parsed, line_number: int) -> CardAbility.Fx:
	var reader: Reader = Reader.new(text)
	var value: Variant = reader.read_value()
	if reader.failed or not (value is CardAbility.Fx):
		if value is String or value is int:
			var bare: CardAbility.Fx = CardAbility.Fx.new()
			bare.name = str(value)
			bare.text = text
			if not reader.failed:
				return bare
		parsed.errors.append("line %d: cannot parse '%s'" % [line_number, text])
		return null
	(value as CardAbility.Fx).text = text
	return value as CardAbility.Fx


## `lhs OP rhs` (top-level comparison) or a single truthy value.
static func _parse_condition(text: String, parsed: Parsed, line_number: int) -> CardAbility.Fx:
	var operators: Array[String] = ["==", "!=", "<=", ">=", "<", ">"]
	var depth: int = 0
	var i: int = 0
	while i < text.length():
		var c: String = text[i]
		if c == "(" or c == "{":
			depth += 1
		elif c == ")" or c == "}":
			depth -= 1
		elif depth == 0:
			for op: String in operators:
				if text.substr(i, op.length()) == op:
					var cmp: CardAbility.Fx = CardAbility.Fx.new()
					cmp.name = "cmp"
					var lhs: Variant = _condition_side(text.substr(0, i).strip_edges(), parsed, line_number)
					var rhs: Variant = _condition_side(text.substr(i + op.length()).strip_edges(), parsed, line_number)
					if lhs == null or rhs == null:
						return null
					cmp.args = [lhs, op, rhs]
					cmp.text = text
					return cmp
		i += 1
	return parse_effect(text, parsed, line_number)


## One side of a comparison: a number stays a number, anything else is a value call.
static func _condition_side(text: String, parsed: Parsed, line_number: int) -> Variant:
	if text.is_valid_int():
		return int(text)
	return parse_effect(text, parsed, line_number)

# ---- Tokenizing helpers ------------------------------------------------------------------


## Finds `needle` outside parentheses and braces.
static func _find_top_level(text: String, needle: String) -> int:
	var depth: int = 0
	for i: int in range(text.length()):
		var c: String = text[i]
		if c == "(" or c == "{":
			depth += 1
		elif c == ")" or c == "}":
			depth -= 1
		elif depth == 0 and text.substr(i, needle.length()) == needle:
			return i
	return -1


static func _split_top_level(text: String, separator: String) -> Array[String]:
	var result: Array[String] = []
	var depth: int = 0
	var current: String = ""
	for i: int in range(text.length()):
		var c: String = text[i]
		if c == "(" or c == "{":
			depth += 1
		elif c == ")" or c == "}":
			depth -= 1
		if c == separator and depth == 0:
			result.append(current)
			current = ""
		else:
			current += c
	if not current.strip_edges().is_empty():
		result.append(current)
	return result


## A tiny recursive-descent reader for values: numbers, words, `name(args)` calls and `{ a; b }` blocks.
class Reader:
	extends RefCounted
	var text: String
	var pos: int = 0
	var failed: bool = false

	func _init(source: String) -> void:
		text = source

	func _skip() -> void:
		while pos < text.length() and text[pos] == " ":
			pos += 1

	func read_value() -> Variant:
		_skip()
		if pos >= text.length():
			failed = true
			return ""
		if text[pos] == "{":
			return _read_block()
		var start: int = pos
		while pos < text.length() and not ",(){};".contains(text[pos]) and text[pos] != " ":
			pos += 1
		var word: String = text.substr(start, pos - start)
		if word.is_empty():
			failed = true
			return ""
		if pos < text.length() and text[pos] == "(":
			pos += 1
			var call: CardAbility.Fx = CardAbility.Fx.new()
			call.name = word
			_skip()
			if pos < text.length() and text[pos] == ")":
				pos += 1
				return call
			while true:
				call.args.append(read_value())
				if failed:
					return call
				_skip()
				if pos >= text.length():
					failed = true
					return call
				if text[pos] == ",":
					pos += 1
					continue
				if text[pos] == ")":
					pos += 1
					break
				failed = true
				return call
			return call
		if word.is_valid_int():
			return int(word)
		return word

	func _read_block() -> CardAbility.FxBlock:
		var block: CardAbility.FxBlock = CardAbility.FxBlock.new()
		pos += 1
		while true:
			_skip()
			if pos >= text.length():
				failed = true
				return block
			if text[pos] == "}":
				pos += 1
				return block
			if text[pos] == ";":
				pos += 1
				continue
			var value: Variant = read_value()
			if failed:
				return block
			if value is CardAbility.Fx:
				block.effects.append(value as CardAbility.Fx)
			else:
				var bare: CardAbility.Fx = CardAbility.Fx.new()
				bare.name = str(value)
				block.effects.append(bare)
		return block
