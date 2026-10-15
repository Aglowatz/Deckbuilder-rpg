extends Node
## Main scene for the D.N.A. walk smoke (the slice, Part E): starts DnaWalkSmoke on the root so it survives every scene change it walks through.


func _ready() -> void:
	var smoke: DnaWalkSmoke = DnaWalkSmoke.new()
	smoke.name = "DnaWalkSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
