extends Node
## Main scene for the reach walk smoke (Fix pass Nov 7, item 2): starts ReachWalkSmoke on the root so it survives the scene changes.


func _ready() -> void:
	var smoke: ReachWalkSmoke = ReachWalkSmoke.new()
	smoke.name = "ReachWalkSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
