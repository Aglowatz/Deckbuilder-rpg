extends Node
## Main scene for the hub walk smoke (Oct 16, Block 3h): starts HubWalkSmoke on the root so it survives every scene change it walks through.


func _ready() -> void:
	var smoke: HubWalkSmoke = HubWalkSmoke.new()
	smoke.name = "HubWalkSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
