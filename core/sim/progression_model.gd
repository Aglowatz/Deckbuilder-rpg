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
	"town:npc": 3, "town:graveyard": 7, "town:ninja": 12, "town:vault": 24,
	"zone:beefcake": 5, "D-HOG": 7, "S-IRON": 6, "S-TOWN": 6, "S-BEEF": 22,
	"zone:necrocrat": 9, "D-HFA": 11, "S-NECRO": 11,
	"zone:gourmand": 12, "D-TTK": 14, "S-GOUR": 14,
	"zone:refusemancer": 15, "D-ROT": 17, "S-REF": 17,
	"zone:final": 18, "S-CAP": 19, "D-PC": 20,
	"D-LAB": 26,
	"arena:1": 6, "arena:2": 12, "arena:3": 18,
}

## Colorless filler the reference deck sheds as its Path upgrades arrive, in order.
const FILLER_ORDER: Array[String] = ["C-01", "C-02", "C-02", "C-02", "C-03", "C-03", "C-06", "C-06", "C-07", "C-08", "C-11", "C-13", "C-17", "C-14", "C-01", "C-01", "C-10", "C-12", "C-05", "C-04"]
## The deck stays at this size while upgrades come in (extra cards replace filler).
const REFERENCE_DECK_SIZE: int = 46

## Per Path: level -> {Card ID: copies} the player has added to the starter by that level (commons and uncommons first, the first
## Epic at 10, the Legendary at 18; within the copy caps of the level track).
const UPGRADES: Dictionary = {
	Affinity.Type.BEEFCAKE: {
		3: {"B-06": 1, "B-24": 1, "B-14": 1},
		6: {"B-21": 2, "B-25": 1, "B-26": 1, "B-11": 1},
		10: {"B-27": 1, "B-19": 2, "B-23": 1},
		14: {"B-28": 1, "B-29": 1, "B-12": 2},
		18: {"B-33": 1, "B-26": 1},
		22: {"B-32": 1, "B-28": 1},
	},
	Affinity.Type.GOURMAND: {
		3: {"G-05": 1, "G-07": 1, "G-17": 1},
		6: {"G-08": 2, "G-12": 1, "G-21": 2, "G-25": 1},
		10: {"G-28": 1, "G-23": 2, "G-24": 1},
		14: {"G-29": 1, "G-30": 1, "G-26": 2},
		18: {"G-33": 1, "G-32": 1},
		22: {"G-27": 1, "G-22": 1},
	},
	Affinity.Type.REFUSEMANCER: {
		3: {"R-07": 1, "R-22": 1, "R-26": 1},
		6: {"R-22": 1, "R-14": 2, "R-09": 2, "R-25": 1},
		10: {"R-28": 1, "R-23": 2, "R-12": 2},
		14: {"R-29": 1, "R-30": 1, "R-24": 2},
		18: {"R-33": 1, "R-27": 1},
		22: {"R-32": 1, "R-29": 1},
	},
	Affinity.Type.NECROCRAT: {
		3: {"N-06": 1, "N-26": 1, "N-23": 1},
		6: {"N-15": 1, "N-07": 2, "N-18": 2, "N-14": 1},
		10: {"N-30": 1, "N-24": 2, "N-25": 2},
		14: {"N-28": 1, "N-29": 1, "N-27": 1},
		18: {"N-33": 1, "N-31": 1},
		22: {"N-32": 1, "N-28": 1},
	},
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
	if level >= 14:
		result.erase("travelers_boots")
		result.append("hover_boots")
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
	if level < 6:
		return {"healing_draught": 2}
	if level < 10:
		return {"healing_salve": 2}
	if level < 20:
		return {"healing_salve": 3, "firebrand_charm": 2}
	return {"healing_salve": 3, "firebrand_charm": 2, "sharpening_stone": 2}


## The reference deck of a Path at `level`: its starting deck plus every upgrade package up to that level, shedding colorless filler
## so the deck stays around `REFERENCE_DECK_SIZE` cards.
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
			for copy: int in range(int(package[id])):
				deck.cards.append(card)
	_shed_filler(deck)
	return deck


static func _shed_filler(deck: Deck) -> void:
	var cursor: int = 0
	while deck.cards.size() > REFERENCE_DECK_SIZE and cursor < FILLER_ORDER.size():
		var id: String = FILLER_ORDER[cursor]
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
