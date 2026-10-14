extends Node
## Main scene for the Gainlands thrower smoke: starts ThrowerSmoke on the root (it survives the scene change into the zone) and lets it enter the Gainlands.


func _ready() -> void:
	var smoke: ThrowerSmoke = ThrowerSmoke.new()
	smoke.name = "ThrowerSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
