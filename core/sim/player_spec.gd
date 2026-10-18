class_name PlayerSpec
extends RefCounted
## The player's side of a balance simulation (Rebalance Part B): the deck, the level (HP, opening hand, item slots through
## `ProgressionTable`), the equipment worn, the consumables carried and the AI that plays it. Pure data; `BalanceSim` builds the
## `PlayerSetup` from it.

var label: String = "Player"
var deck: Deck
var level: int = 1
## Equipment ids (`ContentSet.equipment_piece`); unknown ids are skipped.
var equipment_ids: Array[String] = []
## Consumables carried into the fight: item id -> uses. `SimItemPolicy` spends them like a sensible player would.
var items: Dictionary = {}
var ai_name: String = "Balanced"
## False = the AI never uses Iron, Red Tape or Contracts (the "is temporary Iron worth 1 energy" check).
var use_resources: bool = true
var extra_sources: Array[ModifierSource] = []


static func make(deck_value: Deck, level_value: int = 1, label_value: String = "") -> PlayerSpec:
	var spec: PlayerSpec = PlayerSpec.new()
	spec.deck = deck_value
	spec.level = level_value
	spec.label = label_value if not label_value.is_empty() else (deck_value.deck_name if deck_value != null else "Player")
	return spec


## A profile with this level's stats and the equipment worn.
func profile(content: ContentSet) -> PlayerProfile:
	var made: PlayerProfile = PlayerProfile.new()
	made.apply_level(ProgressionTable.row(clampi(level, 1, ProgressionTable.MAX_LEVEL)))
	for id: String in equipment_ids:
		var piece: EquipmentData = content.equipment_piece(id)
		if piece != null:
			made.equipment.append(piece)
	return made


func duplicate_spec() -> PlayerSpec:
	var copy: PlayerSpec = PlayerSpec.new()
	copy.label = label
	copy.deck = deck
	copy.level = level
	copy.equipment_ids = equipment_ids.duplicate()
	copy.items = items.duplicate()
	copy.ai_name = ai_name
	copy.use_resources = use_resources
	copy.extra_sources = extra_sources.duplicate()
	return copy


func describe() -> String:
	var parts: PackedStringArray = ["%s (L%d, %d cards)" % [label, level, deck.size() if deck != null else 0]]
	if not equipment_ids.is_empty():
		parts.append("gear: " + ", ".join(equipment_ids))
	if not items.is_empty():
		var item_parts: PackedStringArray = []
		for id: Variant in items.keys():
			item_parts.append("%s x%d" % [str(id), int(items[id])])
		parts.append("items: " + ", ".join(item_parts))
	if not use_resources:
		parts.append("no resource use")
	return "; ".join(parts)
