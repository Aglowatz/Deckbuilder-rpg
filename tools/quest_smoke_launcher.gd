extends Node
## Main scene for the quest smoke (Oct 16, Block 1g): starts QuestSmoke on the root so it survives every scene change it walks through.


func _ready() -> void:
	var smoke: QuestSmoke = QuestSmoke.new()
	smoke.name = "QuestSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
