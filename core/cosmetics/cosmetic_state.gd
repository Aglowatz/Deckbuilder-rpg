class_name CosmeticState
extends RefCounted
## What the hero owns and wears: hats and cloaks (docs/art/world_rollout.md, Part C) and the cloak dye. The default look (nothing equipped, natural dye) is the dark teal
## hooded cloak with no hat. `hat_dye` is only used by the 3D hero-shaped NPCs (the tailor and her mannequin).

var owned: Array[String] = []
var hat_id: String = ""
var cloak_id: String = ""
var hat_dye: int = 0
var cloak_dye: int = Dye.NATURAL
## Fix pass Nov 4 (Part 3.3): the cloak dyes bought at Pip's (indexes into `Dye.PALETTE`; the natural colour is always owned).
var owned_dyes: Array[int] = []
## Set when an old save was loaded: the gold its bought items are worth (the session pays it out once and clears it).
var legacy_refund: int = 0


func owns(item_id: String) -> bool:
	return owned.has(item_id)


func grant(item_id: String) -> bool:
	if CosmeticCatalog.find(item_id) == null or owns(item_id):
		return false
	owned.append(item_id)
	return true


func owns_dye(index: int) -> bool:
	return index == Dye.NATURAL or owned_dyes.has(index)


func grant_dye(index: int) -> bool:
	if index < 0 or index >= Dye.count() or owned_dyes.has(index):
		return false
	owned_dyes.append(index)
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
	return {"version": CosmeticMigration.VERSION, "owned": owned.duplicate(), "hat": hat_id, "cloak": cloak_id, "cloak_dye": cloak_dye, "dyes": owned_dyes.duplicate()}


func from_dict(data: Dictionary) -> void:
	owned.clear()
	legacy_refund = 0
	hat_id = ""
	cloak_id = ""
	hat_dye = 0
	cloak_dye = Dye.NATURAL
	owned_dyes.clear()
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
	if data.has("dyes"):
		for index: Variant in data["dyes"] as Array:
			grant_dye(int(index))
	else:
		# A save from before the dyes were sold (Fix pass Nov 4): the dye being worn is kept as owned.
		grant_dye(cloak_dye)
	if not owns_dye(cloak_dye):
		cloak_dye = Dye.NATURAL
