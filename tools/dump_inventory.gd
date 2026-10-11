extends SceneTree
## Prints the consumable items, all equipment and all cosmetics as markdown table rows for the ART INVENTORY section of docs/backlog.md:
##   Godot --headless --path . -s res://tools/dump_inventory.gd
## Output: "## items", "## equipment" and "## cosmetics" blocks, one row per entry (name | where/slot | effect).


func _init() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	print("## items")
	var item_ids: Array[String] = []
	for key: Variant in content.items.keys():
		item_ids.append(str(key))
	item_ids.sort()
	for id: String in item_ids:
		var item: ItemData = content.items[id] as ItemData
		print("| %s | %s | %s |" % [item.display_name, item.id, _clean(item.description)])
	print("## equipment")
	var pieces: Dictionary = {}
	for key: Variant in content.equipment.keys():
		pieces[str(key)] = content.equipment[key]
	for key: Variant in content.zone_equipment.keys():
		pieces[str(key)] = content.zone_equipment[key]
	var piece_ids: Array[String] = []
	for key: Variant in pieces.keys():
		piece_ids.append(str(key))
	piece_ids.sort()
	var slot_names: Array[String] = ["Helm", "Weapon", "Armor", "Boots", "Relic"]
	for id: String in piece_ids:
		var piece: EquipmentData = pieces[id] as EquipmentData
		print("| %s | %s | %s | %s |" % [piece.source_name, id, slot_names[int(piece.slot)], _clean(piece.description)])
	print("## cosmetics")
	for item: CosmeticData in CosmeticCatalog.all():
		print("| %s | %s | %s | %s |" % [item.display_name, item.id, "Hat" if item.slot == CosmeticData.Slot.HAT else "Cloak", _clean(item.description)])
	print("## dyes")
	for index: int in range(Dye.count()):
		print("| %s |" % Dye.dye_name(index))
	quit(0)


func _clean(text: String) -> String:
	return text.replace("\n", " ").replace("|", "/").strip_edges()
