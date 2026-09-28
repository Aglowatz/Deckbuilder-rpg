class_name EquipmentData
extends ModifierSource
## One piece of equipment (Part E): a slot plus the Modifiers it grants while equipped. It IS a
## ModifierSource (not just wrapping one), so an equipped piece can be dropped straight into
## `PlayerProfile.equipment` / `ModifierPipeline.build` with no extra plumbing.

enum Slot { HELM, WEAPON, ARMOR, BOOTS, RELIC }

const SLOT_NAMES: Dictionary = {
	Slot.HELM: "Helm", Slot.WEAPON: "Weapon", Slot.ARMOR: "Armor",
	Slot.BOOTS: "Boots", Slot.RELIC: "Relic",
}

@export var id: String = ""
@export var slot: Slot = Slot.RELIC
@export var description: String = ""


static func slot_name(value: Slot) -> String:
	return str(SLOT_NAMES.get(value, "Unknown"))
