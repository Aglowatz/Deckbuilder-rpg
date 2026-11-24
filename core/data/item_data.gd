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
## Overnight Nov 2-3, Part 2: an item that can backfire (the Reckless Tonic): with this chance (0..1) a use deals `backfire_damage` to its user
## INSTEAD of its effect. The roll is the duel's seeded RNG in a battle and the caller's roll outside one.
@export var backfire_chance: float = 0.0
@export var backfire_damage: int = 0


## True when a use with this roll (0..1) backfires.
func backfires(roll: float) -> bool:
	return backfire_chance > 0.0 and roll < backfire_chance


## New brief, Part B: the one shared hover tooltip text - name, full effect and targeting
## requirement - used identically by the battle item bar, the character screen and the item
## vendor, so all three always read the same for the same item.
## Fable big pass Nov 23: the same order as equipment (`GearText`): the name, the kind line, what it does (with its targeting).
func tooltip_text() -> String:
	return GearText.item_tooltip(self)
