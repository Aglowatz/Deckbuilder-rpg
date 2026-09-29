class_name ItemData
extends Resource
## A consumable item (Part E): a limited number of uses, each resolving `effect`. Distinct from
## equipment - items are not permanent stat sources, so they are not a ModifierSource; using one
## is a one-off effect, resolved by `ItemUseResolver`.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
## How many times the item can be used before it is used up.
@export var uses: int = 1
@export var effect: EffectData


## New brief, Part B: the one shared hover tooltip text - name, full effect and targeting
## requirement - used identically by the battle item bar, the character screen and the item
## vendor, so all three always read the same for the same item.
func tooltip_text() -> String:
	var text: String = "%s\n%s" % [display_name, description]
	if effect != null:
		text += "\n%s" % effect.target_requirement_text()
	return text
