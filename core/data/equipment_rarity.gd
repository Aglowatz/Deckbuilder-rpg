class_name EquipmentRarity
extends RefCounted
## Overnight Oct 17, Part 5: equipment rarity as data. Every piece's rarity lives in `data/equipment/rarities.json` (same four tiers
## and colours as cards: Common, Uncommon, Epic, Legendary) and is applied when content loads, so the generated .tres files never
## need regenerating for a rarity change. Also adds the Starter Blade, the first piece of equipment (the level-5 armory quest).

const PATH: String = "res://data/equipment/rarities.json"
const STARTER_BLADE: String = "starter_blade"
const NAMES: Array[String] = ["Common", "Uncommon", "Epic", "Legendary"]

static var _table: Dictionary = {}


static func table() -> Dictionary:
	if _table.is_empty() and FileAccess.file_exists(PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary:
			_table = parsed as Dictionary
	return _table


## The rarity the data gives `id` (-1 when it is not listed).
static func rarity_of(id: String) -> int:
	var key: String = str(table().get(id, ""))
	return CardEnums.Rarity.keys().find(key.to_upper()) if not key.is_empty() else -1


static func display_name(rarity: int) -> String:
	return NAMES[clampi(rarity, 0, NAMES.size() - 1)]


## Sets every listed piece's rarity and adds the Starter Blade to `content`.
static func apply(content: ContentSet) -> void:
	if not content.zone_equipment.has(STARTER_BLADE) and not content.equipment.has(STARTER_BLADE):
		content.zone_equipment[STARTER_BLADE] = starter_blade()
	for pool: Dictionary in [content.equipment, content.zone_equipment]:
		for id: Variant in pool.keys():
			var rarity: int = rarity_of(str(id))
			if rarity >= 0:
				(pool[id] as EquipmentData).rarity = rarity as EquipmentData.Rarity


## The Starter Blade: +1 attack to the first unit you play each battle (`Modifier.Kind.FIRST_UNIT_STAT_CHANGE`).
static func starter_blade() -> EquipmentData:
	var piece: EquipmentData = EquipmentData.new()
	piece.id = STARTER_BLADE
	piece.source_name = "Starter Blade"
	piece.slot = EquipmentData.Slot.WEAPON
	piece.description = "The first unit you play each battle gets +1 attack."
	piece.flavor_text = "Requisition form 7-B, approved in triplicate. Pointy end goes toward the enemy."
	piece.tier = 1
	piece.source = "Quest: Some Assembly Required (Bertram Beetsworth, level 5)"
	var mod: Modifier = Modifier.new()
	mod.kind = Modifier.Kind.FIRST_UNIT_STAT_CHANGE
	mod.value = 1
	mod.value2 = 0
	piece.modifiers = [mod] as Array[Modifier]
	return piece
