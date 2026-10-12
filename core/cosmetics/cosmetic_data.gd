class_name CosmeticData
extends RefCounted
## One wearable: a hat (a card laid on the head) or a cloak (a whole alternate sprite set). Purely visual.

enum Slot { HAT, CLOAK }

var id: String = ""
var display_name: String = ""
var slot: Slot = Slot.HAT
var description: String = ""
var price: int = 0
var starter: bool = false
var unlock: Condition
## Where the item can also be found (shown in the wardrobe / shop as a hint), "" for none. A found item still has a shop price.
var secret_hint: String = ""
## The asset name: COS-HAT-<art_name>-<DIR> for a hat, SPR-PLAYER-CLOAK-<art_name>-<DIR>_<IDLE|WALK> for a cloak.
var art_name: String = ""


static func make(item_id: String, title: String, item_slot: Slot, blurb: String, item_price: int, art: String = "") -> CosmeticData:
	var data: CosmeticData = CosmeticData.new()
	data.id = item_id
	data.display_name = title
	data.slot = item_slot
	data.description = blurb
	data.price = item_price
	data.art_name = art
	return data


func as_starter() -> CosmeticData:
	starter = true
	return self


func unlocked_by(condition: Condition) -> CosmeticData:
	unlock = condition
	return self


func found_at(hint: String) -> CosmeticData:
	secret_hint = hint
	return self


func is_for_sale() -> bool:
	return price > 0


func slot_name() -> String:
	return "Hat" if slot == Slot.HAT else "Cloak"
