extends Node
## Main scene for the Crosspath walk smoke (Oct 17, Part E): starts CrosspathWalkSmoke on the root so it survives the scene change into town.


func _ready() -> void:
	var smoke: CrosspathWalkSmoke = CrosspathWalkSmoke.new()
	smoke.name = "CrosspathWalkSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
