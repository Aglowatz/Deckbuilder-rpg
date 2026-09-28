extends Node
## Main scene for the zone-entrances smoke test: starts ZoneEntrancesSmoke on the root (so it
## survives the town <-> zone scene changes it's testing) and switches to town.

func _ready() -> void:
	var smoke: ZoneEntrancesSmoke = ZoneEntrancesSmoke.new()
	smoke.name = "ZoneEntrancesSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
