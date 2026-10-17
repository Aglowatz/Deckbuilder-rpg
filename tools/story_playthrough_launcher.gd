extends Node
## Main scene for the story playthrough bot (Oct 16, Block 5a): starts StoryPlaythrough on the root so it survives every scene change it walks through.


func _ready() -> void:
	var smoke: StoryPlaythrough = StoryPlaythrough.new()
	smoke.name = "StoryPlaythrough"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
