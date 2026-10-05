class_name CosmeticState
extends RefCounted
## What the hero owns and wears: owned item ids, the equipped hat and cloak, and a dye index for each. Saved with the campaign (`Session.to_dict`).
## Purely visual: nothing here changes any stat.

var owned: Array[String] = []
var hat_id: String = ""
var cloak_id: String = ""
var hat_dye: int = 0
var cloak_dye: int = 0
## True once the new-game "choose your look" has been answered (old saves count as chosen).
var look_chosen: bool = false


func owns(item_id: String) -> bool:
	return owned.has(item_id)


## Adds an item (no duplicates). Returns false for unknown ids or items already owned.
func grant(item_id: String) -> bool:
	if CosmeticCatalog.find(item_id) == null or owns(item_id):
		return false
	owned.append(item_id)
	return true


func equipped_id(slot: CosmeticData.Slot) -> String:
	return hat_id if slot == CosmeticData.Slot.HAT else cloak_id


func dye_index(slot: CosmeticData.Slot) -> int:
	return hat_dye if slot == CosmeticData.Slot.HAT else cloak_dye


## Wears an owned item (or "" to take the slot off). False when not owned. Switching items resets the dye to that item's default unless `keep_dye`.
func equip(slot: CosmeticData.Slot, item_id: String, keep_dye: bool = false) -> bool:
	if item_id != "":
		var item: CosmeticData = CosmeticCatalog.find(item_id)
		if item == null or item.slot != slot or not owns(item_id):
			return false
		if not keep_dye:
			set_dye(slot, item.default_dye)
	if slot == CosmeticData.Slot.HAT:
		hat_id = item_id
	else:
		cloak_id = item_id
	return true


func set_dye(slot: CosmeticData.Slot, index: int) -> void:
	if slot == CosmeticData.Slot.HAT:
		hat_dye = Dye.clamp_index(index)
	else:
		cloak_dye = Dye.clamp_index(index)


## A copy (the wardrobe previews changes on a copy and applies them on confirm).
func duplicate_state() -> CosmeticState:
	var copy: CosmeticState = CosmeticState.new()
	copy.from_dict(to_dict())
	return copy


func to_dict() -> Dictionary:
	return {"owned": owned.duplicate(), "hat": hat_id, "cloak": cloak_id, "hat_dye": hat_dye, "cloak_dye": cloak_dye, "look_chosen": look_chosen}


func from_dict(data: Dictionary) -> void:
	owned.clear()
	for id: Variant in data.get("owned", []) as Array:
		if CosmeticCatalog.find(str(id)) != null and not owned.has(str(id)):
			owned.append(str(id))
	hat_id = str(data.get("hat", ""))
	cloak_id = str(data.get("cloak", ""))
	if hat_id != "" and not owns(hat_id):
		hat_id = ""
	if cloak_id != "" and not owns(cloak_id):
		cloak_id = ""
	hat_dye = Dye.clamp_index(int(data.get("hat_dye", 0)))
	cloak_dye = Dye.clamp_index(int(data.get("cloak_dye", 0)))
	look_chosen = bool(data.get("look_chosen", false))
