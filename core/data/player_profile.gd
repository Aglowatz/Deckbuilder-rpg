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
## Currently equipped gear only (at most one EquipmentData per slot) - this is what feeds
## `gear_modifiers()`/the pipeline. Use `equip`/`unequip`, not direct mutation.
@export var equipment: Array[ModifierSource] = []
@export var items: Array[ModifierSource] = []

# ---- Progression (Part E) ----------------------------------------------------------------

@export var level: int = 1
@export var xp: int = 0
@export var item_slots: int = 1
## Everything owned, whether equipped or not.
@export var owned_equipment: Array[EquipmentData] = []
## Slot types unlocked so far (levels 5/10/15/20/25, one per level, player's choice).
@export var equipment_slots: Array[EquipmentData.Slot] = []
## Owned consumables (Part E: ItemData has limited `uses`; `use_item` consumes one).
@export var owned_items: Array[ItemData] = []
## item id -> uses remaining. Missing entry = full uses (item.uses).
@export var item_uses_remaining: Dictionary = {}


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


# ---- Progression (Part E) ----------------------------------------------------------------


## Applies one level's absolute stats (max_life/opening_hand_size/item_slots/level). Called once
## per level gained, in the order gained, by whatever awards XP - never inferred automatically
## from `level` alone, so a profile built directly for a test (setting `max_life` etc by hand) is
## never silently overwritten by this.
func apply_level(row: LevelData) -> void:
	level = row.level
	max_life = row.max_life
	opening_hand_size = row.opening_hand_size
	item_slots = row.item_slots


## Max copies of a card of `rarity` this profile's level allows in a deck.
func max_copies_for(rarity: CardEnums.Rarity) -> int:
	var row: LevelData = ProgressionTable.row(level)
	return int(row.copy_limits.get(rarity, DeckValidator.MAX_COPIES)) if row != null else DeckValidator.MAX_COPIES


func has_equipment_slot(slot: EquipmentData.Slot) -> bool:
	return equipment_slots.has(slot)


## Unlocks a slot type (Part E: one choice per level 5/10/15/20/25). False if already unlocked.
func unlock_equipment_slot(slot: EquipmentData.Slot) -> bool:
	if has_equipment_slot(slot):
		return false
	equipment_slots.append(slot)
	return true


func equipped_in(slot: EquipmentData.Slot) -> EquipmentData:
	for piece: ModifierSource in equipment:
		if (piece as EquipmentData).slot == slot:
			return piece as EquipmentData
	return null


## Equips `item` into its own slot, replacing whatever was equipped there. False if the slot is
## not unlocked yet or the item is not owned.
func equip(item: EquipmentData) -> bool:
	if item == null or not has_equipment_slot(item.slot) or not owned_equipment.has(item):
		return false
	unequip(item.slot)
	equipment.append(item)
	return true


## Unequips whatever is in `slot` (back into the owned pool, not discarded). Returns it, or null.
func unequip(slot: EquipmentData.Slot) -> EquipmentData:
	var current: EquipmentData = equipped_in(slot)
	if current != null:
		equipment.erase(current)
	return current


func owns_item(item: ItemData) -> bool:
	return owned_items.has(item)


func item_uses_left(item: ItemData) -> int:
	if item == null:
		return 0
	return int(item_uses_remaining.get(item.id, item.uses))


## Uses one charge of `item` against `run` (Part E: items resolve outside a duel - see
## ItemUseResolver). False if not owned, out of uses, or the effect is not one items support.
func use_item(item: ItemData, run: DungeonRun) -> bool:
	if item == null or not owns_item(item) or item_uses_left(item) <= 0:
		return false
	if not ItemUseResolver.apply(item, run):
		return false
	var remaining: int = item_uses_left(item) - 1
	item_uses_remaining[item.id] = remaining
	if remaining <= 0:
		owned_items.erase(item)
		item_uses_remaining.erase(item.id)
	return true
