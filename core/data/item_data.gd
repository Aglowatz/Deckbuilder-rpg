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
