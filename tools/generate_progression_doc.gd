extends SceneTree
## Writes docs/design/progression.md from ProgressionTable.build() (the one source of truth for
## Part E's level table). Run after changing anything in core/data/progression_table.gd:
##   Godot --headless --path . -s res://tools/generate_progression_doc.gd

const DOC_PATH: String = "res://docs/design/progression.md"


func _initialize() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	var lines: PackedStringArray = []
	lines.append("# Player Progression (Part E)")
	lines.append("")
	lines.append("Levels 1-30. Generated from `core/data/progression_table.gd` by `tools/")
	lines.append("generate_progression_doc.gd` - edit the table, not this file, then regenerate.")
	lines.append("")
	lines.append("- **XP**: every encounter grants XP scaled by difficulty (`EncounterRewards`):")
	lines.append("  Tutorial 15, Normal 30, Elite 60, Boss 120. The curve below is tuned so finishing")
	lines.append("  the main story lands around **level 20**; levels 21-30 are postgame.")
	lines.append("- **Starting life**: 10 at level 1, +1 on every even level, reaching **25 at level 30**")
	lines.append("  (before equipment/item modifiers).")
	lines.append("- **Opening hand size**: 5 at level 1, gradually up to **8** at level 24+.")
	lines.append("- **Item slots**: 1 at level 1, gradually up to **4** at level 30.")
	lines.append("- **Equipment slots** (Helm/Weapon/Armor/Boots/Relic): 0 at level 1; one is chosen")
	lines.append("  and unlocked at levels 5, 10, 15, 20 and 25 - all five are unlocked by level 25.")
	lines.append("- **Deck copy limits by rarity**: Common/Uncommon start at 3, Epic at 2, Legendary at")
	lines.append("  1; each increases gradually until every rarity allows **4 copies**.")
	lines.append("- Every level grants something: a real stat/slot/limit increase, an equipment choice,")
	lines.append("  or (when none of those land) gold, a card choice, or a vendor-stock unlock.")
	lines.append("")
	lines.append("| Level | XP to reach | Life | Hand | Items | Common | Uncommon | Epic | Legendary | Grants |")
	lines.append("|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|")
	for row: LevelData in rows:
		lines.append("| %d | %d | %d | %d | %d | %d | %d | %d | %d | %s |" % [
			row.level, row.xp_to_reach, row.max_life, row.opening_hand_size, row.item_slots,
			int(row.copy_limits[CardEnums.Rarity.COMMON]), int(row.copy_limits[CardEnums.Rarity.UNCOMMON]),
			int(row.copy_limits[CardEnums.Rarity.EPIC]), int(row.copy_limits[CardEnums.Rarity.LEGENDARY]),
			row.summary,
		])
	lines.append("")
	lines.append("## Equipment and items (placeholders)")
	lines.append("")
	lines.append("Built on the existing Modifier pipeline: `EquipmentData` (slot + Modifiers, IS a")
	lines.append("`ModifierSource`) and `ItemData` (limited `uses` + one `EffectData`, resolved outside a")
	lines.append("duel by `ItemUseResolver` - see docs/design/open_questions.md for why). Five equipment")
	lines.append("pieces and three items prove equip/unequip/use work end to end:")
	lines.append("")
	lines.append("| Slot | Piece | Effect |")
	lines.append("|---|---|---|")
	var content: ContentSet = ContentLibrary.load_all()
	var pieces: Array[EquipmentData] = []
	for id: Variant in content.equipment.keys():
		pieces.append(content.equipment_piece(str(id)))
	pieces.sort_custom(func(a: EquipmentData, b: EquipmentData) -> bool: return int(a.slot) < int(b.slot))
	for piece: EquipmentData in pieces:
		lines.append("| %s | %s | %s |" % [EquipmentData.slot_name(piece.slot), piece.source_name, piece.description])
	lines.append("")
	lines.append("| Item | Uses | Effect |")
	lines.append("|---|---:|---|")
	var item_ids: Array = content.items.keys()
	item_ids.sort()
	for id: Variant in item_ids:
		var consumable: ItemData = content.item(str(id))
		lines.append("| %s | %d | %s |" % [consumable.display_name, consumable.uses, consumable.description])
	var path: String = ProjectSettings.globalize_path(DOC_PATH)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("Wrote %s" % DOC_PATH)
	quit(0)
