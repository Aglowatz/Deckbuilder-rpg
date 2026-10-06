class_name TargetSpec
extends RefCounted
## What a script can point at: `unit.opp.atk<=3`, `tool|wonder|resource`, `refuse.unit.mine.cost<=2`, `unit|opp`...
## Grammar: `zone[|zone...](.filter)*` where a zone is one of
##   unit, tool, wonder, infra, resource, token (a unit token), any (unit or player), player, opp, me, refuse, deck, hand, trap
## and a filter is a side (`mine`/`opp`, relative to the controller; `any` is the default), a card type (`unit`, `tool`, ...
## for `refuse`/`deck`/`hand`), `other`, `tok`, `nontok`, `tok:ID`, `golem`, `exhausted`, `ready`, `fresh`, `buffed`,
## `multipath`, `attacking`, `path=B|N|G|R`, `kw=hustle`, `nokw=hustle`, `kind=garbage`, `atk<=3`, `def<2`, `cost>=4`,
## `buffs>=1` (the right-hand side may be a `$var`).

const ZONE_WORDS: Array[String] = ["unit", "tool", "wonder", "infra", "resource", "token", "any", "player", "opp", "me", "refuse", "deck", "hand", "trap", "card"]
const TYPE_WORDS: Array[String] = ["unit", "tool", "wonder", "infra", "spell", "trap", "card", "resource"]

var raw: String = ""
var zones: Array[String] = []
## "mine", "opp" or "" (either).
var side: String = ""
var types: Array[String] = []
## Each: {"key": String, "op": String, "value": Variant (int or "$var" String)} or {"flag": String}.
var filters: Array[Dictionary] = []


static func parse(text: String) -> TargetSpec:
	var spec: TargetSpec = TargetSpec.new()
	spec.raw = text
	var segments: PackedStringArray = text.split(".")
	if segments.is_empty():
		return spec
	for zone: String in segments[0].split("|"):
		spec.zones.append(zone.strip_edges())
	for i: int in range(1, segments.size()):
		var segment: String = segments[i].strip_edges()
		if segment == "mine" or segment == "opp":
			spec.side = segment
		elif segment == "any":
			spec.side = ""
		elif TYPE_WORDS.has(segment) and (spec.zones.has("refuse") or spec.zones.has("deck") or spec.zones.has("hand")):
			spec.types.append(segment)
		else:
			spec.filters.append(_parse_filter(segment))
	return spec


static func _parse_filter(segment: String) -> Dictionary:
	var regex: RegEx = RegEx.new()
	regex.compile("^(atk|def|cost|buffs)(<=|>=|==|=|<|>)(.+)$")
	var found: RegExMatch = regex.search(segment)
	if found != null:
		var value_text: String = found.get_string(3)
		var value: Variant = value_text if value_text.begins_with("$") else int(value_text)
		var op: String = found.get_string(2)
		return {"key": found.get_string(1), "op": "==" if op == "=" else op, "value": value}
	if segment.begins_with("tok:"):
		return {"key": "tokid", "op": "==", "value": segment.substr(4)}
	for prefix: String in ["path=", "kw=", "nokw=", "kind="]:
		if segment.begins_with(prefix):
			return {"key": prefix.trim_suffix("="), "op": "==", "value": segment.substr(prefix.length())}
	return {"flag": segment}


func has_zone(zone: String) -> bool:
	return zones.has(zone)


## True when the spec can name a player.
func includes_players() -> bool:
	return zones.has("any") or zones.has("player") or zones.has("opp") or zones.has("me")


func includes_units() -> bool:
	return zones.has("unit") or zones.has("any") or zones.has("token")


## Compares `left` with the filter's right-hand side using its operator.
static func compare(left: int, op: String, right: int) -> bool:
	match op:
		"<=":
			return left <= right
		">=":
			return left >= right
		"<":
			return left < right
		">":
			return left > right
		"==":
			return left == right
	return false
