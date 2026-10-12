class_name CosmeticState
extends RefCounted
## What the hero owns and wears: hats and cloaks (docs/art/world_rollout.md, Part C) and the cloak dye. The default look (nothing equipped, natural dye) is the dark teal
## hooded cloak with no hat. `hat_dye` is only used by the 3D hero-shaped NPCs (the tailor and her mannequin).

var owned: Array[String] = []
var hat_id: String = ""
var cloak_id: String = ""
var hat_dye: int = 0
var cloak_dye: int = Dye.NATURAL
## Set when an old save was loaded: the gold its bought items are worth (the session pays it out once and clears it).
var legacy_refund: int = 0


func owns(item_id: String) -> bool:
	return owned.has(item_id)


func grant(item_id: String) -> bool:
	if CosmeticCatalog.find(item_id) == null or owns(item_id):
		return false
	owned.append(item_id)
	return true


func equipped_id(slot: CosmeticData.Slot) -> String:
	return hat_id if slot == CosmeticData.Slot.HAT else cloak_id


func dye_index(slot: CosmeticData.Slot) -> int:
	return hat_dye if slot == CosmeticData.Slot.HAT else cloak_dye


## Equips an owned item ("" takes the slot off). The cloak dye stays as it is.
func equip(slot: CosmeticData.Slot, item_id: String, _keep_dye: bool = true) -> bool:
	if item_id != "":
		var item: CosmeticData = CosmeticCatalog.find(item_id)
		if item == null or item.slot != slot or not owns(item_id):
			return false
	if slot == CosmeticData.Slot.HAT:
		hat_id = item_id
	else:
		cloak_id = item_id
	return true


func set_dye(slot: CosmeticData.Slot, index: int) -> void:
	if slot == CosmeticData.Slot.HAT:
		hat_dye = clampi(index, 0, Dye.count() - 1)
	else:
		cloak_dye = Dye.clamp_index(index)


func duplicate_state() -> CosmeticState:
	var copy: CosmeticState = CosmeticState.new()
	copy.from_dict(to_dict())
	return copy


func to_dict() -> Dictionary:
	return {"version": CosmeticMigration.VERSION, "owned": owned.duplicate(), "hat": hat_id, "cloak": cloak_id, "cloak_dye": cloak_dye}


func from_dict(data: Dictionary) -> void:
	owned.clear()
	legacy_refund = 0
	hat_id = ""
	cloak_id = ""
	hat_dye = 0
	cloak_dye = Dye.NATURAL
	if int(data.get("version", 1)) < CosmeticMigration.VERSION:
		# An old save: back to the default look, bought items refunded, found items kept.
		var migrated: Dictionary = CosmeticMigration.migrate(data)
		for id: Variant in migrated["owned"] as Array:
			owned.append(str(id))
		legacy_refund = int(migrated["refund"])
		return
	for id: Variant in data.get("owned", []) as Array:
		if CosmeticCatalog.find(str(id)) != null and not owned.has(str(id)):
			owned.append(str(id))
	hat_id = str(data.get("hat", ""))
	cloak_id = str(data.get("cloak", ""))
	if hat_id != "" and not owns(hat_id):
		hat_id = ""
	if cloak_id != "" and not owns(cloak_id):
		cloak_id = ""
	cloak_dye = Dye.clamp_index(int(data.get("cloak_dye", Dye.NATURAL)))
