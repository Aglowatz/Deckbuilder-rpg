extends SceneTree
## Writes the four lieutenants' relics (Oct 21 story-content brief, `Lieutenants.add_equipment`) to data/equipment/zone/<id>.tres without
## regenerating all content (tools/generate_content.gd writes them too):
##   Godot --headless --path . -s res://tools/generate_lieutenant_gear.gd


func _init() -> void:
	var pieces: Dictionary = {}
	Lieutenants.add_equipment(pieces)
	for id: Variant in pieces.keys():
		var piece: EquipmentData = pieces[id] as EquipmentData
		var path: String = "res://data/equipment/zone/%s.tres" % piece.id
		piece.take_over_path(path)
		print("saved %s: %s" % [path, error_string(ResourceSaver.save(piece, path))])
	quit(0)
