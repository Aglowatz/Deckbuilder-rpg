extends Node
## Main scene for the loading-time measurement (Nov 2 pass, Part 3): puts LoadingTiming on the root so it survives every scene change it
## measures, then lets it drive the game from the first town load.
func _ready() -> void:
	var tool_node: LoadingTiming = LoadingTiming.new()
	tool_node.name = "LoadingTiming"
	get_tree().root.add_child.call_deferred(tool_node)
	tool_node.run.call_deferred()
