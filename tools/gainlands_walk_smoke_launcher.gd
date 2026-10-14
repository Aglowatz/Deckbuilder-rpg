extends Node
## Main scene for the Gainlands walk smoke (Part G): starts GainlandsWalkSmoke on the root so it survives every scene change it walks through.


func _ready() -> void:
	var smoke: GainlandsWalkSmoke = GainlandsWalkSmoke.new()
	smoke.name = "GainlandsWalkSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
