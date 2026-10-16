extends Node
## Main scene for the Capital walk smoke (the layout pass): starts CapitalWalkSmoke on the root so it survives every scene change it walks through.


func _ready() -> void:
	var smoke: CapitalWalkSmoke = CapitalWalkSmoke.new()
	smoke.name = "CapitalWalkSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
