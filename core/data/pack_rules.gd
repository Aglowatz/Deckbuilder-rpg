class_name PackRules
extends RefCounted
## Pack-system rules that are not about one pack: which cards never appear in packs, and which Path belongs to which zone.

## Cards that never appear in any pack (`CardData.not_in_packs`). Applied to the content by `ContentDefinitions.build`, so the
## generated .tres files carry the flag. Found another way:
##  - the mini-dungeon and main-dungeon unique rewards, the four Path-quest rewards and the card for toppling Primm;
##  - the zones' chest cards (also sold at the Capital's black market);
##  - enemy-only cards (Primm's enforcers and decks): they are not collectibles at all.
const NOT_IN_PACKS_IDS: Array[String] = [
	# Mini dungeon uniques
	"deceased_ceo", "iron_titan", "buffet_colossus", "heap_mother",
	# Main dungeon uniques
	"aurelio_the_true", "heartlift_the_unbroken", "the_final_approval", "heart_of_the_dump",
	# Path-quest rewards and Primm's reward
	"freed_wheel_crew", "odiles_real_recipe", "grandfather_marrow", "rescued_compost_heap", "the_paths_united",
	# Chest cards (a handful of others; "max_rep" stays in packs: it is the only pack-eligible Beefcake Epic)
	"tasting_menu", "recycle_bin", "moss_titan",
	# Enemy-only cards
	"compliance_officer", "perfection_inspector", "tidy_bot", "gate_guard", "approved_gate_captain", "rift_wretch",
	"shard_swarm", "citation", "decree_of_order", "primm_perfect_citizen", "primm_standard_issue", "primm_correction",
]

const PRISMATIC_ID: String = "prismatic"
const GENERAL_1_ID: String = "general_1"
const GENERAL_2_ID: String = "general_2"


## Sets `not_in_packs` on every card listed in `NOT_IN_PACKS_IDS` (any card dictionary of the content).
static func apply_flags(cards: Dictionary) -> void:
	for id: String in NOT_IN_PACKS_IDS:
		var card: CardData = cards.get(id) as CardData
		if card != null:
			card.not_in_packs = true


## Zone ids by Path. Literals on purpose (checked against the zone classes by a test): the pack generator runs as a bare script,
## where the zone classes (which reference the Session autoload) cannot compile.
const ZONE_BY_PATH: Dictionary = {
	Affinity.Type.A: "beefcake",
	Affinity.Type.B: "gourmand",
	Affinity.Type.C: "refusemancer",
	Affinity.Type.D: "necrocrat",
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
