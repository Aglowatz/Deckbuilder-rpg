class_name EnemyDecks
extends RefCounted
## The decks the game's enemies play, built from the designed card set. Each archetype is a themed list of non-Infrastructure
## cards (Card ID -> copies, at most 4 each); `recipe()` adds basic Infrastructure of the Path(s) to make a full deck recipe,
## the format `ZoneDecks.from_recipe` and the dungeon definitions use ("BAS-B" is Powerhouse, "BAS-N" Ghost Town, "BAS-G"
## Feastforge, "BAS-R" Wasteworks).

const BASIC_BY_PATH: Dictionary = {
	Affinity.Type.BEEFCAKE: "BAS-B",
	Affinity.Type.NECROCRAT: "BAS-N",
	Affinity.Type.GOURMAND: "BAS-G",
	Affinity.Type.REFUSEMANCER: "BAS-R",
}

## key -> {"paths": [Affinity.Type...], "cards": {Card ID: copies}}
const ARCHETYPES: Dictionary = {
	# ---- Beefcake: Hustle, tools, raw stats, Iron -------------------------------------------------------
	"beefcake_rush": {
		"paths": [Affinity.Type.BEEFCAKE],
		"cards": {"B-01": 3, "B-07": 2, "B-06": 2, "B-12": 2, "B-03": 2, "B-21": 2, "B-19": 2, "B-24": 2, "B-26": 1, "B-20": 2},
	},
	"beefcake_tools": {
		"paths": [Affinity.Type.BEEFCAKE],
		"cards": {"B-05": 3, "B-08": 3, "B-09": 3, "B-02": 3, "B-14": 2, "B-16": 2, "B-17": 2, "B-15": 2, "B-18": 2, "B-10": 2, "B-25": 2, "B-04": 2},
	},
	"beefcake_bruisers": {
		"paths": [Affinity.Type.BEEFCAKE],
		"cards": {"B-04": 4, "B-11": 4, "B-13": 3, "B-28": 2, "B-29": 2, "B-27": 2, "B-30": 1, "B-31": 1, "B-33": 1, "B-12": 3, "B-32": 1},
	},
	# ---- Gourmand: Ingredients, golems, recipes, bounce and Plate ----------------------------------------
	"gourmand_golems": {
		"paths": [Affinity.Type.GOURMAND],
		"cards": {"G-01": 4, "G-02": 3, "G-03": 3, "G-08": 3, "G-12": 2, "G-14": 2, "G-09": 3, "G-15": 3, "G-28": 2, "G-10": 2, "G-13": 1, "G-27": 1},
	},
	"gourmand_control": {
		"paths": [Affinity.Type.GOURMAND],
		"cards": {"G-04": 4, "G-05": 3, "G-06": 4, "G-07": 3, "G-01": 3, "G-08": 2, "G-16": 2, "G-17": 1, "G-20": 2, "G-21": 2, "G-24": 1, "G-23": 2, "G-19": 2},
	},
	# ---- Refusemancer: Garbage, rats, ramp, traps ------------------------------------------------------------
	"refuse_rats": {
		"paths": [Affinity.Type.REFUSEMANCER],
		"cards": {"R-06": 4, "R-05": 3, "R-30": 2, "R-14": 1, "R-15": 1, "R-10": 2, "R-02": 3, "R-19": 2, "R-08": 3, "R-09": 1, "R-01": 3, "R-23": 2, "R-22": 2, "R-07": 2},
	},
	"refuse_garbage": {
		"paths": [Affinity.Type.REFUSEMANCER],
		"cards": {"R-01": 3, "R-03": 3, "R-22": 3, "R-23": 2, "R-28": 2, "R-27": 1, "R-06": 3, "R-08": 2, "R-11": 2, "R-17": 2, "R-18": 2, "R-25": 2, "R-12": 2, "R-04": 2},
	},
	# ---- Necrocrat: Red Tape, Contracts, tokens, reanimation -------------------------------------------------
	"necro_zombies": {
		"paths": [Affinity.Type.NECROCRAT],
		"cards": {"N-01": 4, "N-02": 4, "N-04": 3, "N-23": 2, "N-05": 3, "N-14": 2, "N-21": 2, "N-20": 2, "N-06": 3, "N-07": 3, "N-30": 1, "N-33": 1},
	},
	"necro_control": {
		"paths": [Affinity.Type.NECROCRAT],
		"cards": {"N-01": 3, "N-02": 3, "N-03": 3, "N-15": 3, "N-16": 2, "N-13": 1, "N-11": 2, "N-26": 3, "N-09": 3, "N-08": 3, "N-31": 1},
	},
	# ---- Two-Path decks (dungeon and zone bosses, Path-pair opponents) ---------------------------------------------
	"gourmand_beefcake": {
		"paths": [Affinity.Type.GOURMAND, Affinity.Type.BEEFCAKE],
		"cards": {"GB-01": 3, "GB-02": 3, "GB-03": 2, "GB-05": 2, "GB-10": 2, "GB-12": 2, "GB-14": 1, "B-01": 3, "B-06": 3, "G-01": 3, "G-08": 2, "B-11": 2, "G-12": 2},
	},
	"gourmand_necrocrat": {
		"paths": [Affinity.Type.GOURMAND, Affinity.Type.NECROCRAT],
		"cards": {"GN-02": 3, "GN-03": 2, "GN-06": 3, "GN-07": 2, "GN-09": 2, "GN-12": 2, "GN-15": 1, "N-01": 3, "N-02": 3, "G-01": 3, "G-09": 3, "N-06": 2, "G-07": 2},
	},
	"gourmand_refusemancer": {
		"paths": [Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER],
		"cards": {"GR-01": 3, "GR-02": 3, "GR-03": 2, "GR-04": 2, "GR-09": 2, "GR-12": 2, "GR-15": 2, "G-01": 3, "R-06": 3, "G-08": 2, "R-28": 1, "G-15": 3, "R-10": 2},
	},
	"necrocrat_refusemancer": {
		"paths": [Affinity.Type.NECROCRAT, Affinity.Type.REFUSEMANCER],
		"cards": {"NR-01": 3, "NR-03": 3, "NR-06": 2, "NR-08": 2, "NR-09": 2, "NR-10": 2, "NR-12": 2, "NR-15": 2, "N-01": 3, "R-06": 3, "N-02": 3, "R-14": 2},
	},
	"necrocrat_beefcake": {
		"paths": [Affinity.Type.NECROCRAT, Affinity.Type.BEEFCAKE],
		"cards": {"NB-02": 3, "NB-03": 2, "NB-07": 3, "NB-09": 2, "NB-10": 3, "NB-11": 2, "NB-14": 2, "NB-15": 2, "N-01": 3, "B-01": 3, "B-06": 3, "N-02": 3},
	},
	"beefcake_refusemancer": {
		"paths": [Affinity.Type.BEEFCAKE, Affinity.Type.REFUSEMANCER],
		"cards": {"BR-01": 3, "BR-02": 3, "BR-03": 2, "BR-04": 2, "BR-07": 2, "BR-09": 2, "BR-12": 2, "BR-13": 2, "B-01": 3, "R-06": 3, "B-06": 3, "R-05": 3},
	},
	# ---- All four Paths (the Four Fists champion) -------------------------------------------------------------------
	"four_paths": {
		"paths": [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT],
		"cards": {"B-01": 2, "B-11": 2, "G-01": 2, "G-05": 2, "R-06": 2, "R-19": 2, "N-02": 2, "N-15": 2, "C-02": 2, "C-09": 1, "P4-01": 1, "B-03": 2, "G-20": 2, "N-06": 2, "R-14": 1},
	},
	# ---- Colorless (the tutorial dungeon's wanderers, Primm's soldiers) ---------------------------------------------------
	"colorless_militia": {
		"paths": [],
		"cards": {"C-01": 3, "C-02": 2, "C-03": 2, "C-04": 2, "C-06": 2, "C-07": 2, "C-08": 2, "C-13": 2, "C-16": 2, "C-17": 2, "C-22": 1},
	},
	"colorless_regime": {
		"paths": [],
		"cards": {"C-02": 4, "C-05": 3, "C-08": 3, "C-09": 3, "C-21": 2, "C-19": 2, "C-27": 2, "C-30": 1, "C-23": 3, "C-16": 2, "C-17": 2},
	},
}


## The archetype's full recipe: its cards plus `infra_count` basic Infrastructure split evenly over its Paths
## (colorless decks use `fallback_path`'s basics).
static func recipe(key: String, infra_count: int = 16, fallback_path: Affinity.Type = Affinity.Type.BEEFCAKE) -> Dictionary:
	assert(ARCHETYPES.has(key), "unknown enemy deck archetype %s" % key)
	var archetype: Dictionary = ARCHETYPES[key] as Dictionary
	var result: Dictionary = {}
	var paths: Array = archetype["paths"] as Array
	if paths.is_empty():
		paths = [fallback_path]
	var left: int = infra_count
	for index: int in range(paths.size()):
		var share: int = left if index == paths.size() - 1 else infra_count / paths.size()
		result[str(BASIC_BY_PATH[int(paths[index])])] = share
		left -= share
	for id: Variant in (archetype["cards"] as Dictionary).keys():
		result[str(id)] = int((archetype["cards"] as Dictionary)[id])
	return result


## The same recipe trimmed to roughly `size` cards in total (smaller decks for weak enemies): copies are removed one at a time
## from the most-duplicated card until the deck is small enough, never touching the Infrastructure.
static func trimmed(key: String, size: int, infra_count: int = 16, fallback_path: Affinity.Type = Affinity.Type.BEEFCAKE) -> Dictionary:
	var full: Dictionary = recipe(key, infra_count, fallback_path)
	var total: int = 0
	for id: Variant in full.keys():
		total += int(full[id])
	var spells: Array = []
	for id: Variant in full.keys():
		if not str(id).begins_with("BAS-"):
			spells.append(id)
	var guard: int = 0
	while total > size and guard < 200:
		guard += 1
		var best: String = ""
		var best_copies: int = 1
		for id: Variant in spells:
			if int(full[id]) > best_copies:
				best_copies = int(full[id])
				best = str(id)
		if best.is_empty():
			break
		full[best] = int(full[best]) - 1
		total -= 1
	return full


static func has_archetype(key: String) -> bool:
	return ARCHETYPES.has(key)


## Every card id used by any archetype (for tests).
static func all_card_ids() -> Array[String]:
	var seen: Dictionary = {}
	for key: Variant in ARCHETYPES.keys():
		for id: Variant in ((ARCHETYPES[key] as Dictionary)["cards"] as Dictionary).keys():
			seen[str(id)] = true
	var result: Array[String] = []
	for id: Variant in seen.keys():
		result.append(str(id))
	result.sort()
	return result


## A recipe plus extra cards (a boss's signature cards).
static func with_cards(base: Dictionary, extra: Dictionary) -> Dictionary:
	var result: Dictionary = base.duplicate()
	for id: Variant in extra.keys():
		result[id] = int(result.get(id, 0)) + int(extra[id])
	return result


## The cards of archetype `card_key` (trimmed so the whole deck has about `size` cards), with `infra_count` basic Infrastructure split evenly
## over `paths` (Primm's regime plays Colorless cards over Infrastructure of whatever Paths it has conquered).
static func mixed(card_key: String, size: int, paths: Array[Affinity.Type], infra_count: int) -> Dictionary:
	var result: Dictionary = trimmed(card_key, size, 0)
	for key: Variant in result.keys():
		if str(key).begins_with("BAS-"):
			result.erase(key)
	var left: int = infra_count
	for index: int in range(paths.size()):
		var share: int = left if index == paths.size() - 1 else infra_count / paths.size()
		result[str(BASIC_BY_PATH[int(paths[index])])] = share
		left -= share
	return result
