class_name EquipmentVendorEntry
extends Resource
## New brief, Part C: one piece of equipment the equipment vendor may stock, its price, and the
## `Condition` that unlocks it - the equipment equivalent of ItemVendorEntry (Part F). A null
## `unlock` means it is always for sale.

@export var equipment_id: String = ""
@export var price: int = 0
@export var unlock: Condition = null
