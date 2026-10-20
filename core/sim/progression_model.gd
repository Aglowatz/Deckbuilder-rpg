class_name ProgressionModel
extends RefCounted
## Rebalance Part B/E: the expected player at every point of the game, as data - level, reference deck (the Path's starting deck plus
## the upgrades a player has picked up by then), equipment (within the level track's rarity caps) and consumables. The balance
## simulation plays this player against every encounter; `docs/design/progression_model.md` is the prose version.

## The canonical zone order of a main-line run (any order is allowed; this is the one the model assumes).
const ZONE_ORDER: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer", "final"]

## Expected level per progression point (key: "tutorial", "town:...", "zone:<id>", a dungeon ID, "arena:<tier>").
const LEVELS: Dictionary = {
	"tutorial": 1,
	"town:roamer": 1, "town:storeroom": StoreroomGhosts.EXPECTED_LEVEL, "town:npc": 3, "town:graveyard": 7, "town:ninja": 12, "town:vault": 24,
	"zone:beefcake": 5, "D-HOG": 7, "S-IRON": 6, "S-TOWN": 6, "S-BEEF": 22,
	"zone:necrocrat": 9, "D-HFA": 11, "S-NECRO": 11,
	"zone:gourmand": 12, "D-TTK": 14, "S-GOUR": 14,
	"zone:refusemancer": 15, "D-ROT": 17, "S-REF": 17,
	"zone:final": 18, "S-CAP": 19, "D-PC": 20,
	"D-LAB": 26,
	"arena:1": 6, "arena:2": 12, "arena:3": 18,
}

## The deck stays at this size while upgrades come in (extra cards replace the weakest starter cards).
const REFERENCE_DECK_SIZE: int = 46

## Per Path: level -> {Card ID: copies} the player has added to the starting deck by that level (commons and uncommons first, the
## first Epic at 10, the Signature Legendary at 18). The second package lands at 5 because the level track hands out the first Path
## Pack at level 4 and Crosspath sells commons. Copies over the level's copy cap are skipped.
const UPGRADES: Dictionary = {
	Affinity.Type.BEEFCAKE: {
		3: {"B-06": 1, "B-16": 1, "B-15": 1},
		5: {"B-25": 1, "B-19": 2, "B-11": 1, "B-24": 1},
		10: {"B-27": 1, "B-23": 1, "B-10": 1},
		14: {"B-28": 1, "B-29": 1, "B-26": 1},
		18: {"B-33": 1, "B-27": 1},
		22: {"B-32": 1, "B-28": 1},
	},
	Affinity.Type.NECROCRAT: {
		3: {"N-16": 1, "N-13": 1, "N-17": 1},
		5: {"N-15": 1, "N-25": 1, "N-24": 1, "N-06": 1},
		10: {"N-30": 1, "N-24": 1, "N-25": 1, "N-22": 1},
		14: {"N-28": 1, "N-29": 1, "N-27": 1},
		18: {"N-33": 1, "N-31": 1},
		22: {"N-32": 1, "N-28": 1},
	},
	Affinity.Type.GOURMAND: {
		3: {"G-17": 1, "G-13": 1, "G-16": 1},
		5: {"G-05": 1, "G-20": 1, "G-22": 1, "G-24": 1},
		10: {"G-28": 1, "G-26": 1, "G-22": 1},
		14: {"G-29": 1, "G-30": 1, "G-26": 1},
		18: {"G-33": 1, "G-32": 1},
		22: {"G-27": 1, "G-28": 1},
	},
	Affinity.Type.REFUSEMANCER: {
		3: {"R-15": 1, "R-18": 1, "R-12": 1},
		5: {"R-25": 1, "R-09": 1, "R-23": 1, "R-12": 1},
		10: {"R-28": 1, "R-23": 1, "R-29": 1},
		14: {"R-30": 1, "R-31": 1, "R-24": 1},
		18: {"R-33": 1, "R-27": 1},
		22: {"R-32": 1, "R-29": 1},
	},
}

## Per Path: the starting-deck cards a player cuts first as upgrades come in (weakest first; one copy per entry).
const CUT_ORDER: Dictionary = {
	Affinity.Type.BEEFCAKE: ["B-20", "B-07", "B-07", "B-14", "B-08", "B-04", "B-08", "B-01", "B-05", "B-03", "B-01", "B-12", "B-21", "B-04", "B-05"],
	Affinity.Type.NECROCRAT: ["N-12", "N-21", "N-06", "N-14", "N-20", "N-05", "N-03", "N-07", "N-01", "N-02", "N-07", "N-01", "N-18", "N-04", "N-02"],
	Affinity.Type.GOURMAND: ["G-21", "G-04", "G-14", "G-06", "G-02", "G-09", "G-06", "G-02", "G-07", "G-01", "G-09", "G-15", "G-01", "G-05", "G-20"],
	Affinity.Type.REFUSEMANCER: ["R-17", "R-04", "R-01", "R-11", "R-07", "R-10", "R-02", "R-05", "R-19", "R-08", "R-02", "R-06", "R-05", "R-14", "R-19"],
}


static func level_for(key: String, fallback: int = 1) -> int:
	return int(LEVELS.get(key, fallback))


## The equipment worn at `level`, slot by slot, within the caps (Common 5; Uncommon 2, 3 from L10, 5 from L16; Epic 1 from L5, 2 from
## L13, 3 from L19). Nothing before level 5 (the armory quest).
static func equipment_for(level: int) -> Array[String]:
	var result: Array[String] = []
	if level < 5:
		return result
	result.append("saucepan_helmet")
	result.append("cardboard_cuirass")
	if level >= 7:
		result.append("wicked_dagger")
	if level >= 9:
		result.append("travelers_boots")
	if level >= 11:
		result.append("extra_pocket")
	if level >= 16:
		result.erase("extra_pocket")
		result.append("dog_eared_bookmark")
	if level >= 18:
		result.erase("wicked_dagger")
		result.append("flamethrower")
	if level >= 20:
		result.erase("cardboard_cuirass")
		result.append("swole_belt")
	return result


## The consumables carried at `level` (item id -> uses), within the item slots (1, 2 from L10, 3 from L20).
static func items_for(level: int) -> Dictionary:
	if level < 3:
		return {}
	# A fight-worth of charges, not a full shop: consumables are bought per use and a player does not burn three Salves on every roamer.
	if level < 6:
		return {"healing_draught": 1}
	if level < 10:
		return {"healing_salve": 1}
	if level < 20:
		return {"healing_salve": 2, "firebrand_charm": 1}
	return {"healing_salve": 2, "firebrand_charm": 1, "sharpening_stone": 1}


## The reference deck of a Path at `level`: its starting deck plus every upgrade package up to that level (within the level's copy
## caps), cutting the weakest starting cards so the deck stays at `REFERENCE_DECK_SIZE` cards.
static func reference_deck(content: ContentSet, path: Affinity.Type, level: int) -> Deck:
	var deck: Deck = CampaignStart.starter_deck(content, path)
	deck.deck_name = "%s L%d" % [Affinity.display_name(path), level]
	var packages: Dictionary = UPGRADES.get(path, {}) as Dictionary
	var levels: Array = packages.keys()
	levels.sort()
	for at: Variant in levels:
		if int(at) > level:
			continue
		var package: Dictionary = packages[at] as Dictionary
		var ids: Array = package.keys()
		ids.sort()
		for id: Variant in ids:
			var card: CardData = content.card(str(id))
			if card == null:
				continue
			var cap: int = CopyCaps.for_card(card, level)
			for copy: int in range(int(package[id])):
				if deck.count_of(card.id) < cap:
					deck.cards.append(card)
	_cut_to_size(deck, path)
	return deck


static func _cut_to_size(deck: Deck, path: Affinity.Type) -> void:
	var order: Array = CUT_ORDER.get(path, []) as Array
	var cursor: int = 0
	while deck.cards.size() > REFERENCE_DECK_SIZE and cursor < order.size():
		var id: String = str(order[cursor])
		cursor += 1
		for index: int in range(deck.cards.size()):
			if deck.cards[index].id == id:
				deck.cards.remove_at(index)
				break


## The expected player for an encounter: that Path's reference deck at the encounter's level, the gear and items of that level.
static func player_for(content: ContentSet, encounter: EncounterSpec, path: Affinity.Type) -> PlayerSpec:
	var level: int = encounter.expected_level
	var spec: PlayerSpec = PlayerSpec.make(reference_deck(content, path, level), level, "%s L%d" % [Affinity.display_name(path), level])
	spec.equipment_ids = equipment_for(level)
	spec.items = items_for(level)
	return spec
