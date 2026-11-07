class_name PathDirection
extends RefCounted
## Fixes Oct 25, Part 8: once the armory quest is done and the story's main quests open, Elder Maren sends the Wanderer to the zone of
## their own Path first, and that zone's main line (its gatekeeper) is the tracked quest. Her lines explain, with the real numbers from
## `ZoneEffects`: (1) that zone's vendor sells more cards of the Path; (2) inside it the Path's cards get the zone's buff; (3) the Paths
## oppose each other (Beefcake vs Necrocrat, Gourmand vs Refusemancer) and the rival Path's cards get the zone's debuff there.
## Text: `quest.path_direction` in data/dungeons/dungeon_content.json, with the tokens below. Pure rules (no scene tree).

const FLAG: String = "maren_path_direction"
const TEXT_KEY: String = "quest.path_direction"
## Fix pass Nov 7 (item 1): Maren's last word at the cave mouth - start with your own Path, its gatekeeper and its road.
const CAVE_TEXT_KEY: String = "cave_mouth.maren_path"
## The zone card vendor of each Path zone (the NPC who sells its cards).
const VENDORS: Dictionary = {
	"beefcake": "Coach Brutus Benchley", "necrocrat": "Clerk Ledgerbone", "gourmand": "Madame Mirepoix", "refusemancer": "Granny Gristle",
}


## The Path zone of a Path ("beefcake" for Beefcake...), "" for none.
static func zone_of(path: Affinity.Type) -> String:
	for zone_id: String in Gatekeepers.IDS:
		if ZoneEffects.path_of(zone_id) == path:
			return zone_id
	return ""


## The main quest line of the player's own Path zone ("" without a Path).
static func own_main_quest(path: Affinity.Type) -> String:
	var zone_id: String = zone_of(path)
	return "" if zone_id.is_empty() else QuestDefinitions.zone_main_id(zone_id)


## True when Maren should give the talk now: she has greeted the hero in town, she has not said it yet, and the player has not already
## beaten their own Path's gatekeeper (an old save far past this point is never sent back to the start). Fix pass Nov 7 (D3): it no longer
## waits for the armory errand - Maren's errands run beside the Path line.
static func due(qlog: QuestLog, flags: Dictionary, path: Affinity.Type) -> bool:
	if bool(flags.get(FLAG, false)) or not bool(flags.get("elder_greeted", false)):
		return false
	if qlog == null:
		return false
	var zone_id: String = zone_of(path)
	if zone_id.is_empty():
		return false
	return not bool(flags.get(str(CorruptedNpcs.unlock_flag(zone_id)), false))


## Fix pass Nov 7 (item 1): the road out of Crosspath to each Path zone, as the HUD and Maren name it.
const ROADS: Dictionary = {
	"beefcake": "the Gainlands road", "necrocrat": "the D.N.A. road", "gourmand": "the Buffet road", "refusemancer": "the Dump road",
}


static func road_of(zone_id: String) -> String:
	return str(ROADS.get(zone_id, "the road out of town"))


## Fix pass Nov 7 (item 1): the standing "Your Path" line in the HUD tracker, from the Path choice until that zone's gatekeeper is beaten:
## "Face Brick Bronson on the Gainlands road". "" without a Path, once the gatekeeper is beaten, or in the postgame.
static func tracker_line(path: Affinity.Type, flags: Dictionary) -> String:
	var zone_id: String = zone_of(path)
	if zone_id.is_empty() or Gatekeepers.is_cleared(flags, zone_id) or bool(flags.get("primm_defeated", false)):
		return ""
	return "Face %s on %s" % [CorruptedNpcs.display_name(zone_id).get_slice(",", 0), road_of(zone_id)]


## The token values for the player's Path: zone, vendor, path, buff and debuff (names and plain mechanics), rival Path and its zone,
## the gatekeeper's name.
static func tokens(path: Affinity.Type) -> Dictionary:
	var zone_id: String = zone_of(path)
	var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id)
	var rival: Affinity.Type = ZoneEffects.rival_of(path)
	var rival_zone: String = zone_of(rival)
	return {
		"{zone}": ZoneDefs.get_def(zone_id).display_name,
		"{vendor}": str(VENDORS.get(zone_id, "the zone's card vendor")),
		"{path}": Affinity.display_name(path),
		"{rival}": Affinity.display_name(rival),
		"{rival_zone}": ZoneDefs.get_def(rival_zone).display_name if not rival_zone.is_empty() else "",
		"{buff}": effect.buff_name(),
		"{buff_text}": effect.buff_mechanic(),
		"{debuff}": effect.debuff_name(),
		"{debuff_text}": effect.debuff_mechanic(),
		"{gatekeeper}": CorruptedNpcs.display_name(zone_id).get_slice(",", 0),
		"{road}": road_of(zone_id),
		"{obstacle}": Gatekeepers.obstacle_name(zone_id),
	}


## Maren's lines for the player's Path, tokens filled.
static func lines(path: Affinity.Type, text_key: String = TEXT_KEY) -> Array[String]:
	var values: Dictionary = tokens(path)
	var result: Array[String] = []
	for raw: String in DungeonCatalog.text_lines(text_key):
		var line: String = raw
		for token: Variant in values.keys():
			line = line.replace(str(token), str(values[token]))
		result.append(Villain.fill(line))
	return result


## The Glossary's "Zones" rows: how rival Paths and zone effects work, then each zone's buff and debuff with the real numbers.
static func glossary_entries() -> Array[Array]:
	var result: Array[Array] = [
		["Your Path's zone", "Each Path has a zone of its own. Its card vendor sells more of that Path's cards than anyone in town, and inside it that Path's cards get the zone's buff."],
		["Rival Paths", "Beefcake and Necrocrat oppose each other, and so do Gourmand and Refusemancer. In a Path's zone its rival's cards get the zone's debuff."],
		["Both sides", "Zone effects apply to you and to the enemy alike, in the zone and in its dungeons (gold rule icons in battle)."],
	]
	for zone_id: String in Gatekeepers.IDS:
		var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id)
		if effect == null:
			continue
		result.append([ZoneDefs.get_def(zone_id).display_name, "[+] %s\n[-] %s" % [effect.buff_line(), effect.debuff_line()]])
	return result
