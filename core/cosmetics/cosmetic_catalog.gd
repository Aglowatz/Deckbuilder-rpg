class_name CosmeticCatalog
extends RefCounted
## Every hat and cloak in the game. The visuals are in `CosmeticMeshes` (world/character); this is the data: names, prices, who sells what when.

static var _all: Array[CosmeticData] = []


static func all() -> Array[CosmeticData]:
	if _all.is_empty():
		_build()
	return _all


static func find(item_id: String) -> CosmeticData:
	for item: CosmeticData in all():
		if item.id == item_id:
			return item
	return null


static func in_slot(slot: CosmeticData.Slot) -> Array[CosmeticData]:
	var result: Array[CosmeticData] = []
	for item: CosmeticData in all():
		if item.slot == slot:
			result.append(item)
	return result


static func hats() -> Array[CosmeticData]:
	return in_slot(CosmeticData.Slot.HAT)


static func cloaks() -> Array[CosmeticData]:
	return in_slot(CosmeticData.Slot.CLOAK)


static func starters(slot: CosmeticData.Slot) -> Array[CosmeticData]:
	var result: Array[CosmeticData] = []
	for item: CosmeticData in in_slot(slot):
		if item.starter:
			result.append(item)
	return result


## What the tailor lists right now: for sale and unlocked by progress (owned items are filtered out by the shop, not here).
static func vendor_stock(state: UnlockState) -> Array[CosmeticData]:
	var result: Array[CosmeticData] = []
	for item: CosmeticData in all():
		if item.is_for_sale() and Condition.met(item.unlock, state):
			result.append(item)
	return result


## For sale but not unlocked yet (teasers with the requirement hint).
static func vendor_teasers(state: UnlockState) -> Array[CosmeticData]:
	var result: Array[CosmeticData] = []
	for item: CosmeticData in all():
		if item.is_for_sale() and not Condition.met(item.unlock, state):
			result.append(item)
	return result


static func unlock_hint(item: CosmeticData) -> String:
	var condition: Condition = item.unlock
	if condition == null:
		return ""
	match condition.kind:
		Condition.Kind.PLAYER_LEVEL:
			return "Reach level %d" % condition.amount
		Condition.Kind.ZONES_COMPLETED:
			return "Free %d zone%s" % [condition.amount, "" if condition.amount == 1 else "s"]
		Condition.Kind.POSTGAME:
			return "Beat Primm"
	return "Keep adventuring"


static func _build() -> void:
	var hat: CosmeticData.Slot = CosmeticData.Slot.HAT
	var cloak: CosmeticData.Slot = CosmeticData.Slot.CLOAK
	_all = [
		# Hats (12)
		CosmeticData.make("hat_wizard", "Wizard Hat", hat, "Pointy, wide and slightly too big. Comes with a feeling of competence.", 140, 6).as_starter(),
		CosmeticData.make("hat_wide_brim", "Wide-Brim Hat", hat, "Shade for the head, drama for the walk.", 90, 1).as_starter(),
		CosmeticData.make("hat_beanie", "Bobble Beanie", hat, "Warm, round and topped with a pompom.", 60, 0).as_starter(),
		CosmeticData.make("hat_tricorn", "Tricorn", hat, "Three corners, zero regrets. Arr, mostly.", 220, 11).unlocked_by(Condition.player_level(5)),
		CosmeticData.make("hat_leaf_crown", "Crown of Leaves", hat, "Grown, not forged. Smells like a very good morning.", 0, 3).found_at("A hidden chest in the Verdant Dump"),
		CosmeticData.make("hat_chef", "Chef's Toque", hat, "Tall, white and full of opinions about seasoning.", 80, 9),
		CosmeticData.make("hat_bowler", "Bowler Hat", hat, "Respectable. Suspiciously respectable.", 120, 10),
		CosmeticData.make("hat_top_hat", "Top Hat", hat, "For the hero who wishes to be a gentleman.", 320, 11).unlocked_by(Condition.zones_completed(1)),
		CosmeticData.make("hat_cat_ears", "Cat-Ear Band", hat, "Two ears, no tail. Purrfectly acceptable.", 150, 8).unlocked_by(Condition.player_level(8)),
		CosmeticData.make("hat_straw", "Sun Straw Hat", hat, "Wide, floppy and ready for a picnic.", 90, 2),
		CosmeticData.make("hat_party", "Party Cone", hat, "Every fight is a celebration if you wear it right.", 60, 7),
		CosmeticData.make("hat_mushroom", "Mushroom Cap", hat, "Spotted, squishy and very much alive.", 260, 0).unlocked_by(Condition.zones_completed(2)),
		# Cloaks (10)
		CosmeticData.make("cloak_short", "Short Cape", cloak, "A jaunty little cape, just for flapping.", 70, 0).as_starter(),
		CosmeticData.make("cloak_traveler", "Traveler's Cloak", cloak, "Long, plain and made for roads.", 110, 3).as_starter(),
		CosmeticData.make("cloak_poncho", "Poncho", cloak, "Stripes, a hole for your head, and zero stress.", 90, 1).as_starter(),
		CosmeticData.make("cloak_hooded", "Hooded Cloak", cloak, "The hood stays down. For now.", 160, 4),
		CosmeticData.make("cloak_patchwork", "Patchwork Cloak", cloak, "Every patch has a story. Most of them involve a goat.", 210, 2).unlocked_by(Condition.player_level(4)),
		CosmeticData.make("cloak_tattered", "Tattered Cloak", cloak, "Survived things. Would survive more.", 0, 10).found_at("A hidden chest in the Gainlands"),
		CosmeticData.make("cloak_royal", "Royal Mantle", cloak, "Fur trim, gold clasp and a quiet sense of entitlement.", 0, 0).found_at("A reward for beating Primm"),
		CosmeticData.make("cloak_leaf", "Leaf Cloak", cloak, "Overlapping leaves that rustle when you walk.", 250, 3).unlocked_by(Condition.zones_completed(1)),
		CosmeticData.make("cloak_star", "Starfall Cloak", cloak, "Night-blue with a scatter of tiny stars.", 450, 6).unlocked_by(Condition.zones_completed(3)),
		CosmeticData.make("cloak_scarf", "Long Scarf-Cape", cloak, "A scarf that got ideas above its station.", 130, 8),
		CosmeticData.make("cloak_four_seals", "Cloak of the Four Seals", cloak, "Four sigils, one for every Path, stitched on a cloak that does not wrinkle.", 0, 6).found_at("A reward for opening the Four-Seal Vault"),
	]
