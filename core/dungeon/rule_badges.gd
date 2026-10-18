class_name RuleBadges
extends RefCounted
## Playtest v0.4.0, Part F: every rule that bends a fight, as one list of badges with an icon and a tooltip - the zone's buff and debuff
## (`ZoneEffects`), the dungeon's own buffs and debuffs (`DungeonRules`), the boons earned in a run, the Capital's broken services
## (`CapitalDebuffs`) and a fight's one-sided encounter rules (`EncounterModifiers`). The node map, the dungeon entrance brief, the pre-fight
## brief and the battle HUD all draw the same badges (`RuleIconRow`). The enemy's intent is never part of this: only rules.

const SIDE_BOTH: String = "both"
const SIDE_PLAYER: String = "player"
const SIDE_ENEMY: String = "enemy"

## Icons by dungeon rule name (game-icons keys, see `CardIcons`), with a scroll as the fallback.
const DUNGEON_ICONS: Dictionary = {
	"Pump Iron": "lorc/muscle-up", "Iron-less Prison": "lorc/manacles", "Experimental": "lorc/bubbling-flask", "Corrupted Food": "lorc/acid-blob",
	"Processing Time": "lorc/hourglass", "Red Tape Everywhere": "delapouite/crime-scene-tape", "Overgrowth": "lorc/sprout", "Rot": "lorc/skull-crack",
	"Perfect Order": "delapouite/checklist", "Mirrors": "delapouite/shinto-shrine-mirror", "Thin Air": "lorc/feathered-wing",
	"Never Skip Leg Day": "delapouite/weight-lifting-up", "Fresh Fish": "delapouite/fish-monster", "Please Wait": "delapouite/alarm-clock",
	"Midnight Snack": "delapouite/trash-can", "Forgotten Harmony": "lorc/rainbow-star", "Old Kingdom": "delapouite/castle-ruins",
}
const ZONE_BUFF_ICON: String = "lorc/rainbow-star"
const ZONE_DEBUFF_ICON: String = "lorc/cursed-star"
const BOON_ICON: String = "lorc/gem-pendant"
const CAPITAL_ICON: String = "delapouite/broken-wall"
const DEFAULT_ICON: String = "lorc/scroll-unfurled"


class Badge:
	extends RefCounted
	## "zone_buff", "zone_debuff", "dungeon", "boon", "capital" or "encounter".
	var kind: String = "dungeon"
	var name: String = ""
	var text: String = ""
	var icon: String = "lorc/scroll-unfurled"
	var side: String = "both"
	## True for a rule that helps the player (green), false for one that hurts or binds (red); shared rules are gold.
	var good: bool = false

	func is_good() -> bool:
		return good

	func color() -> Color:
		if kind == "zone_buff" or kind == "boon" or (kind == "encounter" and side == SIDE_PLAYER):
			return Color("6fbf73")
		if kind == "zone_debuff" or kind == "capital" or (kind == "encounter" and side == SIDE_ENEMY):
			return Color("e8625a")
		return Color("ffd166")

	func side_text() -> String:
		match side:
			SIDE_PLAYER:
				return "Applies to you only."
			SIDE_ENEMY:
				return "Applies to the enemy only."
		return "Applies to you and to the enemy."

	func tooltip() -> String:
		return "%s\n\n%s" % [text, side_text()]

	func line() -> String:
		return "%s: %s" % [name, text]


static func _badge(kind: String, name: String, text: String, icon: String, side: String, good: bool) -> Badge:
	var badge: Badge = Badge.new()
	badge.kind = kind
	badge.name = name
	badge.text = text
	badge.icon = icon
	badge.side = side
	badge.good = good
	return badge


## The zone's buff and debuff (both sides).
static func for_zone(zone_id: String) -> Array[Badge]:
	var result: Array[Badge] = []
	if zone_id.is_empty():
		return result
	var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id)
	if effect == null:
		return result
	result.append(_badge("zone_buff", effect.buff_name(), "%s\n%s" % [effect.buff_mechanic(), effect.buff_flavor()], ZONE_BUFF_ICON, SIDE_BOTH, true))
	result.append(_badge("zone_debuff", effect.debuff_name(), "%s\n%s" % [effect.debuff_mechanic(), effect.debuff_flavor()], ZONE_DEBUFF_ICON, SIDE_BOTH, false))
	return result


## The dungeon list's buffs and debuffs that apply at `node_number` (0 = all of them).
static func for_dungeon(key: String, node_number: int = 0) -> Array[Badge]:
	var result: Array[Badge] = []
	if key.is_empty():
		return result
	for rule: Dictionary in DungeonRules.rules(key):
		var nodes: Array = rule.get("nodes", []) as Array
		if node_number > 0 and not nodes.is_empty() and not nodes.has(node_number):
			continue
		var name: String = str(rule["name"])
		var side: String = SIDE_PLAYER if str(rule["scope"]) == "player" else SIDE_BOTH
		var good: bool = side == SIDE_PLAYER
		result.append(_badge("dungeon", name, str(rule["text"]), str(DUNGEON_ICONS.get(name, DEFAULT_ICON)), side, good))
	return result


## The boons earned in a run (their source names; a boon only ever helps the player).
static func for_boons(sources: Array[ModifierSource]) -> Array[Badge]:
	var result: Array[Badge] = []
	for source: ModifierSource in sources:
		if source.source_kind != ModifierSource.SourceKind.BOON:
			continue
		var text: String = ""
		for modifier: Modifier in source.modifiers:
			if not modifier.label.is_empty():
				text += ("" if text.is_empty() else " ") + modifier.label
		result.append(_badge("boon", source.source_name, text if not text.is_empty() else "A boon: it fights on your side.", BOON_ICON, SIDE_PLAYER, true))
	return result


## The Capital's broken services that are active (each hurts the player in a duel).
static func for_capital(flags: Dictionary) -> Array[Badge]:
	var result: Array[Badge] = []
	for debuff: CapitalDebuffs.Debuff in CapitalDebuffs.active(flags):
		result.append(_badge("capital", debuff.name_text(), debuff.mechanic_text(), CAPITAL_ICON, SIDE_PLAYER, false))
	return result


## A fight's one-sided encounter rules (red for the enemy's, green for the player's); rules split over several modifiers share a badge.
static func for_encounter(rules: Array[EncounterModifiers.Rule]) -> Array[Badge]:
	var result: Array[Badge] = []
	var seen: Dictionary = {}
	for rule: EncounterModifiers.Rule in rules:
		if seen.has(rule.name):
			continue
		seen[rule.name] = true
		var side: String = SIDE_ENEMY if rule.is_enemy_side() else SIDE_PLAYER
		result.append(_badge("encounter", rule.name, rule.text, rule.icon, side, side == SIDE_PLAYER))
	return result


## Everything that applies in a dungeon run at `node_number`: zone, dungeon rules, boons (encounter rules are per fight, added by the caller).
static func for_run(zone_id: String, dungeon_key: String, sources: Array[ModifierSource], node_number: int = 0) -> Array[Badge]:
	var result: Array[Badge] = []
	result.append_array(for_zone(zone_id))
	result.append_array(for_dungeon(dungeon_key, node_number))
	result.append_array(for_boons(sources))
	return result


## One line per badge, for the dungeon brief and the log.
static func lines(badges: Array[Badge]) -> Array[String]:
	var result: Array[String] = []
	for badge: Badge in badges:
		result.append(badge.line())
	return result


static func names(badges: Array[Badge]) -> String:
	var parts: PackedStringArray = []
	for badge: Badge in badges:
		parts.append(badge.name)
	return ", ".join(parts)
