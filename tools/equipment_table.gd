extends Node
## Prints the 25 new pieces as markdown rows for docs/design/equipment.md (a scene, so the autoloads exist):
##   Godot --headless --path . res://tools/equipment_table.tscn


func _ready() -> void:
	await get_tree().process_frame
	var lines: PackedStringArray = ["| Piece | Slot | Rarity / tier | Effect | Drawback | Flavor | Source |", "|---|---|---|---|---|---|---|"]
	var pieces: Dictionary = ProgressionContent.zone_equipment()
	for id: String in ExpansionGear.ids():
		var piece: EquipmentData = pieces[id] as EquipmentData
		var data_rarity: int = EquipmentRarity.rarity_of(id)  # Oct 29: the rarity the game applies (data/equipment/rarities.json)
		if data_rarity >= 0:
			piece.rarity = data_rarity as EquipmentData.Rarity
		var effect: String = piece.description.trim_suffix(piece.drawback).strip_edges()
		lines.append("| %s (`%s`) | %s | %s / %d | %s | %s | %s | %s |" % [piece.source_name, id, EquipmentData.slot_name(piece.slot), EquipmentData.RARITY_NAMES[int(piece.rarity)], piece.tier, effect, piece.drawback if piece.drawback != "" else "-", piece.flavor_text, piece.source])
	print("\n".join(lines))
	get_tree().quit(0)
