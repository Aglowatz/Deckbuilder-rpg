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
	"zone:final": 18, "S-CAP": 19, "S-PASTE": 19, "D-PC": 20,
	"D-LAB": 26,
	"arena:1": 6, "arena:2": 12, "arena:3": 18,
}

## The deck stays at this size while upgrades come in (extra cards replace the weakest starter cards).
const REFERENCE_DECK_SIZE: int = 46

## Per Path: level -> {Card ID: copies} the player has added to the starting deck by that level. Overnight Oct 22 (Part 1): only cards a
## player can really own at that level under the Oct 22 shops (docs/design/vendors.md; `tools/reference_deck_audit.gd` checks it):
## - before its own zone: Sable's rotating sample (one Common of each Path per shelf, Colorless Commons and Uncommons) and the level
##   track's own-Path Packs (3 cards at 4, 9, 12, 16: about one Uncommon each);
## - from its own zone's first visit: every Common and the zone's two opening Uncommons;
## - only AFTER the zone's boss (so the boss itself is met without them): the other Uncommons, the shelf Epics, the dungeon prizes
##   (the main dungeon's Legendary, the side dungeon's Epic);
## - the Black Market's Epic from 19 (the Capital is reached at 18), the Capital quests' unique Epics and the shelf Legendary at 22.
## Zones (arrival / freed): Beefcake 5 / 7, Necrocrat 9 / 11, Gourmand 12 / 14, Refusemancer 15 / 17. Copies over the copy cap are skipped.
const UPGRADES: Dictionary = {
	Affinity.Type.BEEFCAKE: {
		3: {"B-06": 1, "B-16": 1, "B-15": 1},  # Sable's sample, one Beefcake Common per shelf
		5: {"B-25": 1, "B-19": 2, "B-11": 1, "B-22": 1, "B-34": 1, "B-36": 1},  # the Gainlands' shelf: Commons + the opening Uncommons (Yeet, Alarm-ish Clock); Cards Oct 27: Hammer Thrower, Desk Flip
		8: {"B-24": 1, "B-23": 1, "B-32": 1},  # the House of Gains beaten: the rest of the Uncommons, The Big Unit
		10: {"B-29": 1, "B-10": 1},  # the shelf's Epic (Swole Patrol Sergeant)
		14: {"B-26": 1, "B-29": 1, "B-23": 1},
		19: {"B-27": 1},  # the Black Market's Protein Farts
		22: {"B-33": 1, "B-30": 1},  # the postgame Legendary, the Capital quest's Barbell of the Ancients
	},
	Affinity.Type.NECROCRAT: {
		3: {"N-13": 1, "C-02": 2, "C-03": 2},  # Oct 21: Village Militia + Watchtower Archer (Sable's Colorless Commons): the L5 deck had six 1-2 cost units
		5: {"N-15": 1, "N-25": 1, "N-06": 1, "N-05": 1},  # Oct 22: one Uncommon (the L4 Path Pack) - Sable no longer sells the own Path
		9: {"N-26": 1, "N-23": 1, "N-01": 1, "N-37": 1, "N-36": 1, "N-38": 2, "N-03": 1, "N-07": 1},  # the D.N.A. shelf: the opening Uncommons (Audit Wraith, Middle Management Zombie); Cards Oct 27: Compliance Review, Service Charge; Overnight Oct 28: two Hazmat Interns, the Ghoul and the Grave Shift Worker (3/4 bodies now)
		12: {"N-29": 1, "N-24": 1, "N-22": 1, "N-31": 1, "N-34": 2},  # the Hall of Final Approvals beaten: Uncommons, the Waiting Room's Department, Mass Layoffs (Cards Oct 27: Betty Bones and Mortimer are their own cards now); Final Notice
		16: {"N-25": 1, "N-31": 1},
		19: {"N-27": 1},  # the Black Market's Mandatory Optional Team Meeting
		22: {"N-32": 1, "N-28": 1},
	},
	Affinity.Type.GOURMAND: {
		3: {"G-17": 1, "G-13": 1, "G-16": 1},  # Sable's sample
		5: {"G-05": 1, "G-20": 1, "G-22": 1, "G-07": 1},  # Oct 22: one Uncommon (the L4 Path Pack)
		10: {"G-10": 1, "G-18": 1, "G-22": 1},  # the L9 Path Pack + Sable's rotation
		12: {"G-23": 1, "G-05": 1, "G-35": 1},  # the Buffet shelf: the opening Uncommons (The Cullinator, En Garde-Manger); Cards Oct 27: Pest Control
		15: {"G-28": 1, "G-26": 1, "G-27": 1, "G-33": 1},  # the Test Kitchen beaten: Chef de Golem (the Doppelganger's pick, Cards Oct 27), Toro Toro, the Grand Chef
		18: {"G-28": 1, "G-26": 1},
		19: {"G-29": 1, "G-30": 1},  # the Black Market's Head Health Inspector; Cards Oct 27: The Infinite Pantry is the Paste Works' prize (L19)
		22: {"G-32": 1, "G-31": 1},
	},
	Affinity.Type.REFUSEMANCER: {
		3: {"R-15": 1, "R-18": 1, "R-12": 1},  # Sable's sample
		5: {"R-25": 1, "R-09": 1, "R-12": 1, "R-05": 1},  # Oct 22: one Uncommon (the L4 Path Pack)
		10: {"R-14": 1, "R-19": 1, "R-24": 1},  # the L9 Path Pack + Sable's rotation
		14: {"R-10": 1, "R-08": 1, "R-25": 1},  # the L12 Path Pack + Sable's rotation
		15: {"R-22": 1, "R-06": 1, "R-35": 1},  # the Dump's shelf: the opening Uncommons (Acid Vomitor, Manure Miracle); Cards Oct 27: Sewer Choir
		18: {"R-28": 1, "R-23": 1, "R-33": 1, "R-27": 1, "R-36": 1},  # the Rotheart beaten: Uncommons, Poo-uid, the Archdruid, the Raccoon; Cards Oct 27: Landfill Leviathan
		19: {"R-31": 1},  # the Black Market's Bulk Trash Day
		22: {"R-32": 1, "R-30": 1},
	},
}

## Per Path: the starting-deck cards a player cuts first as upgrades come in (weakest first; one copy per entry). Oct 22: the starting
## decks are about 15 Colorless Commons now, and a player swaps that filler out for Path cards first.
const CUT_ORDER: Dictionary = {
	Affinity.Type.BEEFCAKE: ["C-16", "C-16", "C-13", "C-04", "C-13", "C-04", "C-11", "C-06", "C-11", "C-02", "C-08", "C-06", "C-02", "B-20", "B-07", "B-07", "B-14", "B-08", "B-04", "B-08", "B-01", "B-05", "B-03", "B-01", "B-12", "B-21", "B-04", "B-05"],
	# Oct 21: a Necrocrat player cuts the slow 4-cost units first and keeps the 1-2 drops (the L5 deck played no unit for four turns).
	# Cards Oct 27: once the Colorless filler is gone, the situational spells (Casket, Waiting Room, Endless Filing, Permission to Die) and
	# the Service Charge go before the bodies - the L12 deck had cut every Middle Management Zombie, Accountant and Notary Wraith and kept
	# Village Militia (round robin 20-25%).
	Affinity.Type.NECROCRAT: ["C-17", "C-17", "C-14", "C-07", "C-14", "C-07", "C-05", "C-04", "C-05", "C-04", "C-03", "C-02", "C-03", "C-02", "C-03", "N-22", "N-13", "N-24", "N-25", "N-36", "N-03", "N-07", "N-03", "N-07", "N-23", "N-05", "N-06", "N-23", "N-04", "N-03", "N-05", "N-04", "N-06", "N-01", "N-02"],
	Affinity.Type.GOURMAND: ["C-16", "C-16", "C-14", "C-04", "C-14", "C-04", "C-05", "C-02", "C-05", "C-03", "C-02", "C-03", "G-21", "G-04", "G-14", "G-06", "G-02", "G-09", "G-06", "G-02", "G-07", "G-01", "G-09", "G-15", "G-01", "G-05", "G-20"],
	Affinity.Type.REFUSEMANCER: ["C-17", "C-17", "C-11", "C-15", "C-11", "C-15", "C-06", "C-09", "C-06", "C-03", "C-02", "C-09", "C-03", "R-17", "R-04", "R-01", "R-11", "R-07", "R-10", "R-02", "R-05", "R-19", "R-08", "R-02", "R-06", "R-05", "R-14", "R-19"],
}


static func level_for(key: String, fallback: int = 1) -> int:
	return int(LEVELS.get(key, fallback))


## The equipment worn at `level`, slot by slot, within the caps (Common 5; Uncommon 2, 3 from L10, 5 from L16; Epic 1 from L5, 2 from
## L13, 3 from L19). Nothing before level 5 (the armory quest).
static func equipment_for(level: int) -> Array[String]:
	var result: Array[String] = []
	if level < 5:
		return result
	# Oct 29 (docs/design/equipment.md, slot progression): the two Commons at 5, the Wicked Dagger (Colorless units) at 6, the Glass Jaw
	# Gauntlets from the House of Gains at 10 (after Clench), the Traveler's Boots at 9, the Extra Pocket at 11, the Dog-Eared Bookmark at 16, the Elastic
	# Waistband from the Test Kitchen at 16 (two Epics: cap 2 from 13), the Crown of Mild Hubris at 22 (Legendary cap 1).
	result.append("saucepan_helmet")
	result.append("cardboard_cuirass")
	if level >= 6:
		result.append("wicked_dagger")
	if level >= 9:
		result.append("travelers_boots")
	if level >= 10:  # the Gauntlets are the House of Gains' first-clear prize: worn after Clench, not against him
		result.erase("wicked_dagger")
		result.append("glass_jaw_gauntlets")
	if level >= 11:
		result.append("extra_pocket")
	if level >= 16:
		result.erase("extra_pocket")
		result.append("dog_eared_bookmark")
		result.erase("cardboard_cuirass")
		result.append("elastic_waistband")
	if level >= 22:
		result.erase("saucepan_helmet")
		result.append("hubris_crown")
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
