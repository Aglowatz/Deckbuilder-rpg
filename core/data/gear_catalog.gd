class_name GearCatalog
extends RefCounted
## Overnight Oct 19-20: the Collection Book's Gear page. Every equipment piece the game has (the content's vendor pieces plus every zone,
## dungeon, quest, arena, vault, Lab and Old Well piece - `ContentSet.equipment` and `ContentSet.zone_equipment`, both built by
## `ProgressionContent`), in slot order (Helm, Weapon, Armor, Boots, Relic), and the "where does it come from" hint shown on a piece not
## found yet. Pure: no Session, no nodes.

const SLOT_ORDER: Array[EquipmentData.Slot] = [
	EquipmentData.Slot.HELM, EquipmentData.Slot.WEAPON, EquipmentData.Slot.ARMOR, EquipmentData.Slot.BOOTS, EquipmentData.Slot.RELIC,
]
const SECRET_HINT: String = "A secret"
const UNKNOWN_HINT: String = "Somewhere out there"
## The town equipment vendor (the ten `ProgressionContent.equipment` pieces), worded like `ExpansionGear.SOURCES`.
const VENDOR_HINT: String = "Bertram's equipment stall, Crosspath"
const ARENA_HINT: String = "The Undercroft (arena prize)"


## Pieces whose source must not be spoiled: the Old Well's relic, the Four-Seal Vault's reward and the hidden Path-ology Lab's reward.
static func secret_piece_ids() -> Array[String]:
	return [OldWellQuest.REWARD_EQUIPMENT_ID, VaultGuardian.REWARD_EQUIPMENT_ID, PathologyLab.REWARD_EQUIPMENT_ID]


## Hidden quests (started by a secret, never offered): any piece they pay is "A secret".
static func secret_quest_ids() -> Array[String]:
	return [OldWellQuest.QUEST_ID, VaultGuardian.QUEST_ID]


## Every piece once, sorted by slot (SLOT_ORDER), then rarity (commonest first), then name.
static func all_pieces(content: ContentSet) -> Array[EquipmentData]:
	var by_id: Dictionary = {}
	if content == null:
		return []
	for pool: Dictionary in [content.equipment, content.zone_equipment]:
		for key: Variant in pool.keys():
			var piece: EquipmentData = pool[key] as EquipmentData
			if piece != null and not piece.id.is_empty() and not by_id.has(piece.id):
				by_id[piece.id] = piece
	var result: Array[EquipmentData] = []
	for value: Variant in by_id.values():
		result.append(value as EquipmentData)
	result.sort_custom(_before)
	return result


static func _before(a: EquipmentData, b: EquipmentData) -> bool:
	var slot_a: int = SLOT_ORDER.find(a.slot)
	var slot_b: int = SLOT_ORDER.find(b.slot)
	if slot_a != slot_b:
		return slot_a < slot_b
	if int(a.rarity) != int(b.rarity):
		return int(a.rarity) < int(b.rarity)
	return a.source_name < b.source_name


## The pieces of one slot, in `all_pieces` order.
static func of_slot(pieces: Array[EquipmentData], slot: EquipmentData.Slot) -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for piece: EquipmentData in pieces:
		if piece.slot == slot:
			result.append(piece)
	return result


## (owned, total) over `pieces`; `owned_ids` = the Session's `owned_equipment_ids()`.
static func progress(pieces: Array[EquipmentData], owned_ids: Array[String]) -> Vector2i:
	var found: int = 0
	for piece: EquipmentData in pieces:
		if owned_ids.has(piece.id):
			found += 1
	return Vector2i(found, pieces.size())


## Where a piece comes from, for its silhouette tile: the piece's own `source` text when it has one, else the quest that pays it, the
## arena, the zone puzzle or the town vendor; "A secret" for the secret pieces and hidden quests; "Somewhere out there" when unknown.
## `quests` = `QuestCatalog.all()` (passed in to keep this pure and testable).
static func source_hint(piece: EquipmentData, content: ContentSet, quests: Array[QuestData]) -> String:
	if piece == null:
		return UNKNOWN_HINT
	if secret_piece_ids().has(piece.id):
		return SECRET_HINT
	if not piece.source.is_empty():
		return SECRET_HINT if piece.source.to_lower().begins_with("secret") else piece.source
	for quest: QuestData in quests:
		if quest != null and quest.all_equipment_ids().has(piece.id):
			return SECRET_HINT if secret_quest_ids().has(quest.id) else "Quest: %s" % quest.title
	if ArenaContent.IDS.has(piece.id):
		return ARENA_HINT
	for zone_id: String in ZoneDefs.all_ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		if def != null and def.puzzle_equipment_id == piece.id:
			return "Puzzle: %s" % def.display_name
	if content != null and content.equipment.has(piece.id):
		return VENDOR_HINT
	return UNKNOWN_HINT
