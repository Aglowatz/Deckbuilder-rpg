class_name Modifier
extends Resource
## One entry in the unified modifier pipeline. Equipment, items, zones, dungeon effects and
## boons all produce Modifiers; the engine only ever reads a ModifierSet.

enum Kind {
	## value = flat change to max life.
	MAX_LIFE,
	## value = flat change to life at the start of a duel (may exceed max life).
	STARTING_LIFE,
	## value = flat change to max hand size.
	MAX_HAND_SIZE,
	## value = flat change to opening hand size.
	OPENING_HAND_SIZE,
	## value = change to generic cost of matching non-land cards (min cost 0).
	COST_CHANGE,
	## value = power delta, value2 = toughness delta for matching creatures.
	STAT_CHANGE,
	## value = extra land/color types allowed in the deck.
	MAX_DECK_COLORS,
	## value = extra cards drawn in each draw step.
	EXTRA_DRAWS,
	## value = flat change to how many face-down traps may be set at once.
	MAX_TRAPS,
	## `effect` resolves for the owner when their combat phase begins.
	START_OF_COMBAT_EFFECT,
	## value = flat change to the minimum legal deck size (may be negative). Used to waive the
	## normal minimum while a starter deck is still being filled out (e.g. the tutorial dungeon).
	MIN_DECK_SIZE,
}

## `color` value meaning "matches every card".
const ANY_COLOR: int = -1

@export var kind: Kind = Kind.MAX_LIFE
@export var value: int = 0
@export var value2: int = 0
## An Affinity.Type value, or ANY_COLOR.
@export var color: int = ANY_COLOR
@export var effect: EffectData
@export var label: String = ""


func matches_color(card_color: Affinity.Type) -> bool:
	return color == ANY_COLOR or color == int(card_color)
