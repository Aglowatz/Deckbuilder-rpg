class_name PlayerProfile
extends Resource
## Player stats live here, never hardcoded in the rules. Equipment/items/zones layer
## Modifiers on top of these base values.

const START_MAX_LIFE: int = 10
const ENDGAME_MAX_LIFE: int = 25
const MIN_OPENING_HAND: int = 5
const MAX_OPENING_HAND: int = 8
const DEFAULT_MAX_HAND_SIZE: int = 10

@export var max_life: int = START_MAX_LIFE
@export var opening_hand_size: int = MIN_OPENING_HAND
@export var max_hand_size: int = DEFAULT_MAX_HAND_SIZE
@export var owned_cards: Array[CardData] = []
## Raises the deck color limit from 2 to 4.
@export var postgame_unlocked: bool = false
## The land color the player chose at the start (NEUTRAL = not chosen yet).
@export var primary_affinity: Affinity.Type = Affinity.Type.NEUTRAL
## Set once the intro dungeon is cleared and the attunement reward has been granted.
@export var intro_dungeon_cleared: bool = false
@export var equipment: Array[ModifierSource] = []
@export var items: Array[ModifierSource] = []


## Base stats clamped to their allowed ranges (before modifiers).
func base_max_life() -> int:
	return clampi(max_life, START_MAX_LIFE, ENDGAME_MAX_LIFE)


func base_opening_hand() -> int:
	return clampi(opening_hand_size, MIN_OPENING_HAND, MAX_OPENING_HAND)


func base_max_hand_size() -> int:
	return maxi(1, max_hand_size)


## Modifiers contributed by the player's own equipment and items.
func gear_modifiers() -> ModifierSet:
	var mods: ModifierSet = ModifierSet.new()
	mods.add_sources(equipment)
	mods.add_sources(items)
	return mods
