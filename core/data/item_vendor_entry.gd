class_name ItemVendorEntry
extends Resource
## One consumable item a vendor may stock, its price, and the `Condition` that unlocks it (see
## VendorStockEntry, the card equivalent). A null `unlock` means it is always for sale.

@export var item_id: String = ""
@export var price: int = 0
@export var unlock: Condition = null
