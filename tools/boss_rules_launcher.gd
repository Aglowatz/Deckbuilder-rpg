extends Node
## Main scene for the boss-rules smoke (Daytime Oct 19): starts BossRulesSmoke on the root and opens Crosspath.


func _ready() -> void:
	var smoke: BossRulesSmoke = BossRulesSmoke.new()
	smoke.name = "BossRulesSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
