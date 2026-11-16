extends Node
## Main scene for the Dump corner camera walk (Fable Nov 16c, Part 3): starts HeapCornerCamera on the root.


func _ready() -> void:
	var smoke: HeapCornerCamera = HeapCornerCamera.new()
	smoke.name = "HeapCornerCamera"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
