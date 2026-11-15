class_name RuleAudit
extends RefCounted
## Fable Nov 15 (Part 4): every fight shows every rule in effect. A fight's seats carry modifiers from many places (the zone, the dungeon's
## rules, boons, the Capital's broken services, the encounter's own rules, a rift's empowering, the early-zone ease...). `ModifierSet.origins`
## remembers each source as it is added; the fight's badges (`RuleBadges.Badge.covers`) say which modifiers they stand for. `unshown` is the
## difference: a modifier on a seat that no shown badge covers. The player's own gear and items are theirs, never a "rule", and are left out.
## Pure data: no scene, no nodes.

## What a scripted-event badge covers: the carrier modifier that rides on the foe's seat (EncounterScripts.carrier).
const SCRIPT_CARRIER: String = "script-carrier"
## Kinds whose `tokens` are filled in per fight (the Capital's junk card): the tokens are not part of the signature.
const TOKENS_FILLED_LATE: Array[Modifier.Kind] = [Modifier.Kind.SHUFFLE_JUNK_INTO_DECK]


## One string per distinct modifier: kind, values, colour, effect and tokens (a copy of a modifier has the same signature).
static func signature(modifier: Modifier) -> String:
	if modifier == null:
		return ""
	if modifier.kind == Modifier.Kind.ENCOUNTER_SCRIPT:
		return SCRIPT_CARRIER
	var tokens: PackedStringArray = []
	if not TOKENS_FILLED_LATE.has(modifier.kind):
		for token: CardData in modifier.tokens:
			tokens.append(token.id if token != null else "?")
	return "%s|%d|%d|%d|%s|%s" % [Modifier.Kind.keys()[modifier.kind], modifier.value, modifier.value2, modifier.color, _resource_text(modifier.effect, 0), ",".join(tokens)]


## A resource's stored values as text (nested resources too), so two copies of one effect read the same.
static func _resource_text(resource: Resource, depth: int) -> String:
	if resource == null:
		return ""
	if depth > 3:
		return "..."
	var parts: PackedStringArray = []
	for property: Dictionary in resource.get_property_list():
		if (int(property["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0 or (int(property["usage"]) & PROPERTY_USAGE_STORAGE) == 0:
			continue
		parts.append("%s=%s" % [str(property["name"]), _value_text(resource.get(str(property["name"])), depth)])
	return "{%s}" % ";".join(parts)


static func _value_text(value: Variant, depth: int) -> String:
	if value is CardData:
		return "card:%s" % (value as CardData).id
	if value is Resource:
		return _resource_text(value as Resource, depth + 1)
	if value is Array:
		var parts: PackedStringArray = []
		for item: Variant in value as Array:
			parts.append(_value_text(item, depth))
		return "[%s]" % ",".join(parts)
	return str(value)


## Every modifier a seat carries that is a rule of the fight (not the player's own gear or items): [{"source", "signature", "modifier"}].
static func applied(modifiers: ModifierSet) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if modifiers == null:
		return result
	for origin: Dictionary in modifiers.origins:
		var kind: int = int(origin["kind"])
		if kind == ModifierSource.SourceKind.EQUIPMENT or kind == ModifierSource.SourceKind.ITEM:
			continue
		for modifier: Variant in origin["modifiers"] as Array:
			if modifier is Modifier:
				result.append({"source": str(origin["name"]), "signature": signature(modifier as Modifier), "modifier": modifier})
	return result


## The rules a fight applies that none of its badges shows, one line each ("enemy: Rift-empowered applies STAT_CHANGE 1/1"); empty when
## everything is shown. Each badge cover is used once per seat, so two rules that happen to do the same thing both need a badge.
static func unshown(context: BattleContext) -> Array[String]:
	var missing: Array[String] = []
	if context == null or context.game == null:
		return missing
	var pool: Dictionary = {}
	for badge: RuleBadges.Badge in context.rule_badges:
		for cover: String in badge.covers:
			pool[cover] = int(pool.get(cover, 0)) + 1
	for seat: int in range(context.game.players.size()):
		var used: Dictionary = {}
		for entry: Dictionary in applied(context.game.players[seat].modifiers):
			var key: String = str(entry["signature"])
			used[key] = int(used.get(key, 0)) + 1
			if key == SCRIPT_CARRIER:
				if pool.has(key):
					continue  # one carrier, however many scripted badges
			elif int(used[key]) <= int(pool.get(key, 0)):
				continue
			missing.append("%s: \"%s\" applies %s" % ["you" if seat == 0 else "enemy", str(entry["source"]), describe(entry["modifier"] as Modifier)])
	return missing


## A modifier in a few words, for the audit's report.
static func describe(modifier: Modifier) -> String:
	var text: String = "%s %d" % [Modifier.Kind.keys()[modifier.kind], modifier.value]
	if modifier.value2 != 0:
		text += "/%d" % modifier.value2
	if modifier.color != Modifier.ANY_COLOR:
		text += " (%s)" % Affinity.display_name(modifier.color as Affinity.Type)
	if not modifier.tokens.is_empty():
		var names: PackedStringArray = []
		for token: CardData in modifier.tokens:
			names.append(token.id if token != null else "?")
		text += " [%s]" % ", ".join(names)
	if not modifier.label.is_empty():
		text += " '%s'" % modifier.label
	return text
