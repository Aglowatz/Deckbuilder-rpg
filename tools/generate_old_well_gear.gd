extends SceneTree
## Writes the Old Well secret quest's relic (Overnight Oct 19-20, Part 6) to data/equipment/zone/first_water_phial.tres without regenerating all
## content (tools/generate_content.gd writes it too):
##   Godot --headless --path . -s res://tools/generate_old_well_gear.gd


func _init() -> void:
	var piece: EquipmentData = ProgressionContent.zone_equipment()[OldWellQuest.REWARD_EQUIPMENT_ID] as EquipmentData
	var path: String = "res://data/equipment/zone/%s.tres" % piece.id
	piece.take_over_path(path)
	print("saved %s: %s" % [path, error_string(ResourceSaver.save(piece, path))])
	quit(0)
