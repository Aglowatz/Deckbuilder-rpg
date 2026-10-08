extends SceneTree
## Writes the Path-ology Lab's first-clear equipment (Story v2 Part H) to data/equipment/zone/siphons_lens.tres without regenerating all content:
##   Godot --headless --path . -s res://tools/generate_lab_gear.gd


func _init() -> void:
	var piece: EquipmentData = ProgressionContent.zone_equipment()[PathologyLab.REWARD_EQUIPMENT_ID] as EquipmentData
	var path: String = "res://data/equipment/zone/%s.tres" % piece.id
	piece.take_over_path(path)
	print("saved %s: %s" % [path, error_string(ResourceSaver.save(piece, path))])
	quit(0)
