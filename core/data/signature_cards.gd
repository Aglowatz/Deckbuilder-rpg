class_name SignatureCards
extends RefCounted
## Overnight Nov 19 (Part 4): each mini dungeon's signature card. The first clear awards it (shown as a card on the clear screen); it is
## never in a pack; once that dungeon has been beaten it is sold in the zone's shop (the Capital's two at the Black Market, the Vault's
## at Sable's stall in Crosspath), up to 3 copies with the usual notice for copies above the deck limit.
##
## | Mini dungeon | Signature card |
## | The Waiting Room of Eternity (D.N.A.) | Betty Bones, Surly Secretary (N-30) |
## | The Raw Deal (Buffet; called Omakase before Nov 21) | Toro Toro (G-27) |
## | The Trash Panda Throne (Dump) | Raccoon (R-27) |
## | The Ascent of Mount Swolympus (Gainlands) | Barbell of the Ancients (B-30) |
## | The Iron Cave (Gainlands) | Baron Quadzilla, Lord of Leg Day (B-37) |
## | The Old Service Tunnels (Capital) | The Wanderer (C-29) |
## | The Paste Works (Capital) | The Infinite Pantry (G-30) |
## | The Forgotten Vault (Crosspath) | Old Kingdom Banner (C-21) |

## dungeon id -> [card id, shop: a zone id, "final" for the Capital's Black Market, "town" for Sable in Crosspath]
const TABLE: Dictionary = {
	"S-NECRO": ["N-30", "necrocrat"],
	"S-GOUR": ["G-27", "gourmand"],
	"S-REF": ["R-27", "refusemancer"],
	"S-BEEF": ["B-30", "beefcake"],
	"S-IRON": ["B-37", "beefcake"],
	"S-CAP": ["C-29", "final"],
	"S-PASTE": ["G-30", "final"],
	"S-TOWN": ["C-21", "town"],
}


static func card_for(dungeon_id: String) -> String:
	return str((TABLE.get(dungeon_id, ["", ""]) as Array)[0])


static func is_signature(card_id: String) -> bool:
	for row: Variant in TABLE.values():
		if str((row as Array)[0]) == card_id:
			return true
	return false


static func dungeon_of(card_id: String) -> String:
	for dungeon_id: Variant in TABLE.keys():
		if str((TABLE[dungeon_id] as Array)[0]) == card_id:
			return str(dungeon_id)
	return ""


## The signature cards a shop sells: [card id, dungeon id] for every dungeon whose shop is `shop` ("beefcake", "final", "town"...).
static func for_shop(shop: String) -> Array[Array]:
	var result: Array[Array] = []
	for dungeon_id: Variant in TABLE.keys():
		var row: Array = TABLE[dungeon_id] as Array
		if str(row[1]) == shop:
			result.append([str(row[0]), str(dungeon_id)])
	return result


## The flag a side dungeon's first clear sets (the same as `GameSession.side_cleared_flag`), as a Condition for a shop entry.
static func cleared_condition(dungeon_id: String) -> Condition:
	return Condition.flag(str(cleared_flag(dungeon_id)))


static func cleared_flag(dungeon_id: String) -> StringName:
	if dungeon_id == PathologyLab.DUNGEON_ID:
		return PathologyLab.FLAG_CLEARED
	if dungeon_id == PasteWorks.DUNGEON_ID:
		return PasteWorks.FLAG_CLEARED
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(dungeon_id)
	if plan == null:
		return StringName("side_cleared_" + dungeon_id)
	# A zone's second side dungeon (Mount Swolympus beside the Iron Cave) keeps a flag of its own: sharing the zone's flag meant clearing
	# one counted as the other's first clear.
	var primary: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone(plan.zone_id)
	if primary != null and primary.id != plan.id:
		return StringName("side_cleared_" + dungeon_id)
	if ZoneDefs.has_def(plan.zone_id) and not ZoneDefs.get_def(plan.zone_id).flag_mini_cleared.is_empty():
		return ZoneDefs.get_def(plan.zone_id).flag_mini_cleared
	return &"town_vault_cleared"


## Adds the signature cards of `shop` to `data` once their dungeon has been cleared (before that the shop does not show them at all,
## not even as a "???" teaser).
static func add_to_shop(data: VendorData, shop: String, state: UnlockState) -> void:
	for pair: Array in for_shop(shop):
		if not Condition.met(cleared_condition(str(pair[1])), state):
			continue
		var present: bool = false
		for entry: VendorStockEntry in data.entries:
			present = present or entry.card_id == str(pair[0])
		if not present:
			data.add(str(pair[0]))


## Overnight Nov 19 (Part 6.8): Announcer Grand Bellows at Sable's stall once the Arena's Diamond tier is cleared.
const BELLOWS_ID: String = "C-36"
const DIAMOND_FLAG: String = "arena_tier_4_cleared"
