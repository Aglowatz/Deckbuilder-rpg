extends Node
## Main scene for the Endless Buffet walk smoke (the slice, Part E): starts BuffetWalkSmoke on the root so it survives every scene change it walks through.


func _ready() -> void:
	var smoke: BuffetWalkSmoke = BuffetWalkSmoke.new()
	smoke.name = "BuffetWalkSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
