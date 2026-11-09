extends Node
## Main scene for the Dex Circuit smoke (Overnight Nov 9, Part 3): starts DexCircuitSmoke on the root so it survives scene changes.


func _ready() -> void:
	var smoke: DexCircuitSmoke = DexCircuitSmoke.new()
	smoke.name = "DexCircuitSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
