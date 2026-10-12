class_name CosmeticMigration
extends RefCounted
## Old saves (before the painted sprites) owned a 3D wardrobe of twelve hats and eleven cloaks. The wardrobe is now six hats and four cloaks of painted art, so an old save is
## reset to the default look: every item that was bought is refunded as gold at the price it cost, found items that still exist stay owned (unequipped), and a found item
## that does not exist any more is replaced by its successor. See docs/design/open_questions.md (World rollout).

const VERSION: int = 2

## Legacy item id -> [price, was a free starter choice]. Prices are what the old shop charged; found items had price 0.
const LEGACY: Dictionary = {
	"hat_wizard": [140, true], "hat_wide_brim": [90, true], "hat_beanie": [60, true], "hat_tricorn": [220, false], "hat_leaf_crown": [0, false],
	"hat_chef": [80, false], "hat_bowler": [120, false], "hat_top_hat": [320, false], "hat_cat_ears": [150, false], "hat_straw": [90, false],
	"hat_party": [60, false], "hat_mushroom": [260, false],
	"cloak_short": [70, true], "cloak_traveler": [110, true], "cloak_poncho": [90, true], "cloak_hooded": [160, false], "cloak_patchwork": [210, false],
	"cloak_tattered": [0, false], "cloak_royal": [0, false], "cloak_leaf": [250, false], "cloak_star": [450, false], "cloak_scarf": [130, false],
	"cloak_four_seals": [0, false],
}
## A found item that is gone: what takes its place.
const SUCCESSORS: Dictionary = {"cloak_four_seals": "cloak_red_cape", "hat_top_hat": "hat_bowler"}


## What an old `cosmetics` save dictionary becomes: {"owned": Array[String] (kept and replaced items), "refund": gold}.
static func migrate(data: Dictionary) -> Dictionary:
	var kept: Array[String] = []
	var refund: int = 0
	for entry: Variant in data.get("owned", []) as Array:
		var item_id: String = str(entry)
		var legacy: Array = LEGACY.get(item_id, [0, false]) as Array
		var price: int = int(legacy[0])
		var starter: bool = bool(legacy[1])
		if price > 0 and not starter:
			refund += price  # bought: the gold comes back
			continue
		if starter:
			continue  # a free choice at the start of the game: nothing to give back
		# a found item (price 0)
		var target: String = str(SUCCESSORS.get(item_id, item_id))
		if CosmeticCatalog.find(target) != null and not kept.has(target):
			kept.append(target)
	return {"owned": kept, "refund": refund}
