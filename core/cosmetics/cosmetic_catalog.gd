class_name CosmeticCatalog
extends RefCounted
## The wardrobe's items (docs/art/world_rollout.md, Part C): six hats and four cloaks, each a painted-sprite overlay or sprite set (`CosmeticData.art_name` is the asset name:
## COS-HAT-<NAME>-<DIRECTION> and SPR-PLAYER-CLOAK-<NAME>-<DIRECTION>_<IDLE|WALK>). The hero starts in the default look (the dark teal hooded cloak, no hat), so there are no
## starter items. The clothing vendor (Pip Threadwell) sells all ten, opened up by progress; three are also found (a hidden chest in the Verdant Dump, one in the Gainlands,
## and the Royal Mantle after Primm). Items whose art is not imported yet are shown as "arriving soon" by the shop and cannot be bought.

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


static func vendor_stock(state: UnlockState) -> Array[CosmeticData]:
	var result: Array[CosmeticData] = []
	for item: CosmeticData in all():
		if item.is_for_sale() and Condition.met(item.unlock, state):
			result.append(item)
	return result


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
	# Prices and unlock timing follow progress (docs/design/open_questions.md): three hats from the first visit, the rest as zones fall and levels rise; the found items
	# (leaf crown, tattered cloak, royal mantle) also come from their chest or boss, the shop sells them later for a price.
	_all = [
		CosmeticData.make("hat_wide_brim", "Wide-Brim Hat", hat, "Shade for the head, drama for the walk.", 90, "WIDEBRIM"),
		CosmeticData.make("hat_chef", "Chef's Toque", hat, "Tall, white and full of opinions about seasoning.", 110, "CHEF"),
		CosmeticData.make("hat_bowler", "Bowler Hat", hat, "Respectable. Suspiciously respectable.", 140, "BOWLER"),
		CosmeticData.make("hat_tricorn", "Tricorn", hat, "Three corners, zero regrets. Arr, mostly.", 220, "TRICORN").unlocked_by(Condition.player_level(5)),
		CosmeticData.make("hat_wizard", "Wizard Hat", hat, "Pointy, wide and slightly too big. Comes with a feeling of competence.", 280, "WIZARD").unlocked_by(Condition.zones_completed(1)),
		CosmeticData.make("hat_leaf_crown", "Crown of Leaves", hat, "Grown, not forged. Smells like a very good morning.", 360, "LEAFCROWN").unlocked_by(Condition.zones_completed(2)).found_at("A hidden chest in the Verdant Dump"),
		CosmeticData.make("cloak_patchwork", "Patchwork Cloak", cloak, "Every patch has a story. Most of them involve a goat.", 210, "PATCHWORK").unlocked_by(Condition.player_level(4)),
		CosmeticData.make("cloak_red_cape", "Red Cape", cloak, "Flaps heroically. Does nothing else, heroically.", 260, "REDCAPE").unlocked_by(Condition.zones_completed(1)),
		CosmeticData.make("cloak_tattered", "Tattered Cloak", cloak, "Survived things. Would survive more.", 180, "TATTERED").unlocked_by(Condition.zones_completed(2)).found_at("A hidden chest in the Gainlands"),
		CosmeticData.make("cloak_royal", "Royal Mantle", cloak, "Fur trim, gold clasp and a quiet sense of entitlement.", 900, "ROYAL").unlocked_by(Condition.postgame()).found_at("A reward for beating Primm"),
	]
