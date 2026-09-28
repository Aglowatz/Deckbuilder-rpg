class_name ItemVendorData
extends Resource
## New brief, Part F: a vendor's item stock and each item's price/unlock Condition - the item
## equivalent of VendorData (cards). Stock starts small and grows with progress, same as the
## card vendor: an entry whose condition is not yet met is still "known" (a "???" teaser) but not
## for sale.

@export var vendor_name: String = ""
@export var entries: Array[ItemVendorEntry] = []
## Only appears at all once this is met - null = the vendor is always around.
@export var appears_when: Condition = null


func add(item_id: String, price: int, unlock: Condition = null) -> ItemVendorEntry:
	var entry: ItemVendorEntry = ItemVendorEntry.new()
	entry.item_id = item_id
	entry.price = price
	entry.unlock = unlock
	entries.append(entry)
	return entry


func is_open(state: UnlockState) -> bool:
	return Condition.met(appears_when, state)


## Item ids currently for sale.
func available_item_ids(state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for entry: ItemVendorEntry in entries:
		if Condition.met(entry.unlock, state):
			result.append(entry.item_id)
	return result


## Item ids known to exist but not yet unlocked (a "???" teaser row).
func locked_item_ids(state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for entry: ItemVendorEntry in entries:
		if not Condition.met(entry.unlock, state):
			result.append(entry.item_id)
	return result


func price_for(item_id: String) -> int:
	for entry: ItemVendorEntry in entries:
		if entry.item_id == item_id:
			return entry.price
	return 0


func teaser_for(item_id: String) -> String:
	for entry: ItemVendorEntry in entries:
		if entry.item_id == item_id:
			return Condition.teaser(entry.unlock)
	return ""
