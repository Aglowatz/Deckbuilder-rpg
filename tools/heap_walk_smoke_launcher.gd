extends Node
## Main scene for the Verdant Dump walk smoke (the slice, Part A): starts HeapWalkSmoke on the root so it survives every scene change it walks through.


func _ready() -> void:
	var smoke: HeapWalkSmoke = HeapWalkSmoke.new()
	smoke.name = "HeapWalkSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
