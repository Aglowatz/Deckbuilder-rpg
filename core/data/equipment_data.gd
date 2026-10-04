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
## New brief, Part B: false = tier 1 ("basic", stocked at the equipment vendor from the start),
## true = tier 2 ("advanced", locked behind a level-up reward - see docs/design/progression.md).
@export var advanced: bool = false
## Brief 8, Part C: a line of flavor text shown under the description.
@export var flavor_text: String = ""


static func slot_name(value: Slot) -> String:
	return str(SLOT_NAMES.get(value, "Unknown"))


## New brief, Part B/C: the one shared hover tooltip text for an equipped piece - name and full
## effect - used identically by the character screen (and anywhere else that shows equipment).
func tooltip_text() -> String:
	if flavor_text.is_empty():
		return "%s\n%s" % [source_name, description]
	return "%s\n%s\n%s" % [source_name, description, flavor_text]
