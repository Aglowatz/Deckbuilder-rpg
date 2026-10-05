class_name CosmeticData
extends RefCounted
## One purely visual hat or cloak. It never touches stats (equipment slots stay stat-only and are not drawn on the hero).
## Meshes are built by `CosmeticMeshes` from `id` (procedural, or lifted from a KayKit model); `unlock` decides when the tailor sells it.

enum Slot { HAT, CLOAK }

var id: String = ""
var display_name: String = ""
var slot: Slot = Slot.HAT
var description: String = ""
## Gold price at the tailor; 0 = never sold (a secret or a reward).
var price: int = 0
## Offered at the start of a new game (the hero keeps the chosen one, the rest go on sale).
var starter: bool = false
## Shown in the shop only once this is met (null = from the start).
var unlock: Condition
## Where players find it when it is not sold (docs/design/secrets.md).
var secret_hint: String = ""
var default_dye: int = 0


static func make(item_id: String, title: String, item_slot: Slot, blurb: String, item_price: int, default_dye_index: int = 0) -> CosmeticData:
	var data: CosmeticData = CosmeticData.new()
	data.id = item_id
	data.display_name = title
	data.slot = item_slot
	data.description = blurb
	data.price = item_price
	data.default_dye = default_dye_index
	return data


func as_starter() -> CosmeticData:
	starter = true
	return self


func unlocked_by(condition: Condition) -> CosmeticData:
	unlock = condition
	return self


func found_at(hint: String) -> CosmeticData:
	secret_hint = hint
	price = 0
	return self


func is_for_sale() -> bool:
	return price > 0


func slot_name() -> String:
	return "Hat" if slot == Slot.HAT else "Cloak"
