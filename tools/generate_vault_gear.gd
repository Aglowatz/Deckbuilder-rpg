extends SceneTree
## Writes the Four-Seal Vault's exclusive equipment (Brief 16) to data/equipment/zone/four_seal_signet.tres without regenerating all content:
##   Godot --headless --path . -s res://tools/generate_vault_gear.gd


func _init() -> void:
	var piece: EquipmentData = ProgressionContent.zone_equipment()[VaultGuardian.REWARD_EQUIPMENT_ID] as EquipmentData
	var path: String = "res://data/equipment/zone/%s.tres" % piece.id
	piece.take_over_path(path)
	print("saved %s: %s" % [path, error_string(ResourceSaver.save(piece, path))])
	quit(0)
