class_name PackRules
extends RefCounted
## Pack-system rules that are not about one pack: which cards never appear in packs, and which Path belongs to which zone.

## Cards that never appear in any pack carry `CardData.not_in_packs` (set in `data/source/card_overrides.csv`, which survives a
## re-import; the final review marks the reward-only ones - unique dungeon rewards, quest rewards, chest cards - see
## docs/design/reward_cards.md for the suggested list).
const PRISMATIC_ID: String = "prismatic"
const GENERAL_1_ID: String = "general_1"
const GENERAL_2_ID: String = "general_2"



## Zone ids by Path. Literals on purpose (checked against the zone classes by a test): the pack generator runs as a bare script,
## where the zone classes (which reference the Session autoload) cannot compile.
const ZONE_BY_PATH: Dictionary = {
	Affinity.Type.BEEFCAKE: "beefcake",
	Affinity.Type.GOURMAND: "gourmand",
	Affinity.Type.REFUSEMANCER: "refusemancer",
	Affinity.Type.NECROCRAT: "necrocrat",
}


## The Path a zone belongs to (NEUTRAL for the Capital, which has none).
static func path_for_zone(zone_id: String) -> Affinity.Type:
	for path: Variant in ZONE_BY_PATH.keys():
		if str(ZONE_BY_PATH[path]) == zone_id:
			return int(path) as Affinity.Type
	return Affinity.Type.NEUTRAL


## The zone of a Path (empty for NEUTRAL).
static func zone_for_path(path: Affinity.Type) -> String:
	return str(ZONE_BY_PATH.get(path, ""))


## Pack ids: one Path Pack and one Gilded Pack per Path, the Prismatic Pack and the two General tiers.
static func path_pack_id(path: Affinity.Type) -> String:
	return "path_%s" % Affinity.display_name(path).to_lower()


static func gilded_pack_id(path: Affinity.Type) -> String:
	return "gilded_%s" % Affinity.display_name(path).to_lower()
