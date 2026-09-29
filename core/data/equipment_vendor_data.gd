class_name EquipmentVendorData
extends Resource
## New brief, Part C: the equipment vendor's stock and each piece's price/unlock Condition - the
## equipment equivalent of ItemVendorData (Part F, itself modeled on the card vendor's
## VendorData, D37/D75). Stock starts as 5 basic (tier 1) pieces, always for sale; the 5 advanced
## (tier 2) pieces are known (a "???" teaser) but locked until their unlock Condition is met.

@export var vendor_name: String = ""
@export var entries: Array[EquipmentVendorEntry] = []
## Only appears at all once this is met - null = the vendor is always around.
@export var appears_when: Condition = null


func add(equipment_id: String, price: int, unlock: Condition = null) -> EquipmentVendorEntry:
	var entry: EquipmentVendorEntry = EquipmentVendorEntry.new()
	entry.equipment_id = equipment_id
	entry.price = price
	entry.unlock = unlock
	entries.append(entry)
	return entry


func is_open(state: UnlockState) -> bool:
	return Condition.met(appears_when, state)


## Equipment ids currently for sale.
func available_equipment_ids(state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for entry: EquipmentVendorEntry in entries:
		if Condition.met(entry.unlock, state):
			result.append(entry.equipment_id)
	return result


## Equipment ids known to exist but not yet unlocked (a "???" teaser row).
func locked_equipment_ids(state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for entry: EquipmentVendorEntry in entries:
		if not Condition.met(entry.unlock, state):
			result.append(entry.equipment_id)
	return result


func price_for(equipment_id: String) -> int:
	for entry: EquipmentVendorEntry in entries:
		if entry.equipment_id == equipment_id:
			return entry.price
	return 0


func teaser_for(equipment_id: String) -> String:
	for entry: EquipmentVendorEntry in entries:
		if entry.equipment_id == equipment_id:
			return Condition.teaser(entry.unlock)
	return ""
