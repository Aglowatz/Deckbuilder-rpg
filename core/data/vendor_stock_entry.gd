class_name VendorStockEntry
extends Resource
## One card a vendor may stock, and the `Condition` that unlocks it. A null `unlock` means it is
## always for sale.

@export var card_id: String = ""
@export var unlock: Condition = null
