class_name DungeonRules
extends RefCounted
## The dungeon list's "Dungeon Buffs/Debuffs" column (in addition to the zone effects) as game rules, through the normal modifier pipeline. Every rule is ACTIVE: each
## is a Modifier kind the engine reads (see `Modifier.Kind`, "Dungeon rule" entries). `shared_source` applies to both duelists, `player_source` to the player only.

## Dungeon ID -> [{name, text, active, scope ("both" | "player"), modifiers}] built in `rules`.


## The rules of a dungeon (by `MainDungeons` key): [{name, text, active, scope}].
static func rules(key: String) -> Array[Dictionary]:
	var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(key)
	var result: Array[Dictionary] = []
	if plan == null:
		return result
	for entry: Dictionary in _entries(plan.id):
		result.append({"name": entry["name"], "text": entry["text"], "active": entry["modifiers"] != null, "scope": entry["scope"]})
	return result


## The CSV text of the dungeon's buffs/debuffs.
static func csv_text(key: String) -> String:
	var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(key)
	return plan.buffs if plan != null else ""


## The modifiers that apply to both duelists in this dungeon (null when none).
static func shared_source(key: String, node_number: int = 0) -> ModifierSource:
	return _source(key, "both", node_number)


## The modifiers that apply to the player only (null when none).
static func player_source(key: String, node_number: int = 0) -> ModifierSource:
	return _source(key, "player", node_number)


## `zone` (the zone effects, may be null) plus the shared dungeon rules as one source.
static func with_shared(zone: ModifierSource, key: String, node_number: int = 0) -> ModifierSource:
	var shared: ModifierSource = shared_source(key, node_number)
	if shared == null:
		return zone
	if zone == null:
		return shared
	var merged: ModifierSource = ModifierSource.new()
	merged.source_name = "%s + %s" % [zone.source_name, shared.source_name]
	merged.source_kind = zone.source_kind
	merged.modifiers = zone.modifiers.duplicate()
	merged.modifiers.append_array(shared.modifiers)
	return merged


static func _source(key: String, scope: String, node_number: int = 0) -> ModifierSource:
	var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(key)
	if plan == null:
		return null
	var modifiers: Array[Modifier] = []
	for entry: Dictionary in _entries(plan.id):
		if str(entry["scope"]) == scope and entry["modifiers"] != null and _applies_at(entry, node_number):
			modifiers.append_array(entry["modifiers"] as Array[Modifier])
	if modifiers.is_empty():
		return null
	var source: ModifierSource = ModifierSource.new()
	source.source_name = "%s rules" % plan.dungeon_name
	source.source_kind = ModifierSource.SourceKind.DUNGEON
	source.modifiers = modifiers
	return source


## A rule limited to some nodes (`nodes`: their numbers) only applies on those; `node_number` 0 = not asked, so every rule counts.
static func _applies_at(entry: Dictionary, node_number: int) -> bool:
	var nodes: Array = entry.get("nodes", []) as Array
	return nodes.is_empty() or node_number == 0 or nodes.has(node_number)

## Every rule named in the CSV for a dungeon: modifiers == null means the engine cannot express it yet.
static func _entries(dungeon_id: String) -> Array[Dictionary]:
	match dungeon_id:
		"D-HOG":
			return [
				_rule("Pump Iron", "Your Beefcake units enter with +1 attack.", "player", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Affinity.Type.BEEFCAKE, 0)] as Array[Modifier]),
				_rule("Iron-less Prison", "In the prison (nodes 8-9) Iron can't be used.", "both", [CardBuilder.modifier(Modifier.Kind.BLOCK_RESOURCE_USE, ResourceKind.Kind.IRON)] as Array[Modifier], [8, 9]),
			]
		"D-TTK":
			return [
				_rule("Experimental", "At the start of each battle, a random unit on each side gains a random keyword.", "both", [CardBuilder.modifier(Modifier.Kind.EXPERIMENTAL_KEYWORD, 1)] as Array[Modifier]),
				_rule("Corrupted Food", "Healing effects heal 1 less.", "both", [CardBuilder.modifier(Modifier.Kind.HP_GAIN_BONUS, -1)] as Array[Modifier]),
			]
		"D-HFA":
			return [
				_rule("Processing Time", "Each player's first spell each turn costs 1 more.", "both", [CardBuilder.modifier(Modifier.Kind.FIRST_SPELL_COST_CHANGE, 1)] as Array[Modifier]),
				_rule("Red Tape Everywhere", "Start each battle with one Red Tape.", "both", [CardBuilder.modifier(Modifier.Kind.STARTING_RESOURCES, 1, Modifier.ANY_COLOR, ResourceKind.Kind.RED_TAPE)] as Array[Modifier]),
			]
		"D-ROT":
			return [
				_rule("Overgrowth", "At the start of each turn, each unit gets a buff.", "both", [CardBuilder.modifier(Modifier.Kind.OVERGROWTH, 1)] as Array[Modifier]),
				_rule("Rot", "At end of turn, units with 1 defense are destroyed.", "both", [CardBuilder.modifier(Modifier.Kind.ROT, 1)] as Array[Modifier]),
			]
		"D-PC":
			return [
				_rule("Perfect Order", "Units can't have more than 2 keywords.", "both", [CardBuilder.modifier(Modifier.Kind.KEYWORD_CAP, 2)] as Array[Modifier]),
				_rule("Mirrors", "The first card each player plays each game is copied for the opponent.", "both", [CardBuilder.modifier(Modifier.Kind.MIRRORS, 1)] as Array[Modifier]),
			]
		"S-BEEF":
			return [_rule("Thin Air", "Units with Hustle get +1/+0.", "both", [CardBuilder.modifier(Modifier.Kind.KEYWORD_STAT_CHANGE, 1, Modifier.ANY_COLOR, CardEnums.Keyword.HUSTLE)] as Array[Modifier])]
		"S-IRON":
			return [_rule("Never Skip Leg Day", "Beefcake units get +0/+1.", "both", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Affinity.Type.BEEFCAKE, 1)] as Array[Modifier])]
		"S-GOUR":
			return [_rule("Fresh Fish", "Tokens enter with +1/+1.", "both", [CardBuilder.modifier(Modifier.Kind.TOKEN_STAT_CHANGE, 1, Modifier.ANY_COLOR, 1)] as Array[Modifier])]
		"S-NECRO":
			return [_rule("Please Wait", "Units enter exhausted (both players).", "both", [CardBuilder.modifier(Modifier.Kind.ENTER_EXHAUSTED, 1)] as Array[Modifier])]
		"S-REF":
			return [_rule("Midnight Snack", "Whenever a player eats garbage, they gain 1 HP.", "both", [CardBuilder.modifier(Modifier.Kind.EAT_HP_GAIN, 1)] as Array[Modifier])]
		"S-CAP":
			return [_rule("Forgotten Harmony", "Multi-path cards cost 1 less.", "both", [CardBuilder.modifier(Modifier.Kind.MULTIPATH_COST_CHANGE, -1)] as Array[Modifier])]
		"S-TOWN":
			return [_rule("Old Kingdom", "Colorless units get +1/+1.", "both", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Affinity.Type.NEUTRAL, 1)] as Array[Modifier])]
	return []


static func _rule(rule_name: String, text: String, scope: String, modifiers: Variant, nodes: Array = []) -> Dictionary:
	return {"name": rule_name, "text": text, "scope": scope, "modifiers": modifiers, "nodes": nodes}
