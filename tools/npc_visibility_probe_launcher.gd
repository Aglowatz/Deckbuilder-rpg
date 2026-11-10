extends Node
## Main scene for the NPC visibility probe (Fable pass Nov 10, Part 1.3): starts NpcVisibilityProbe on the root so it survives the scene changes.


func _ready() -> void:
	var probe: NpcVisibilityProbe = NpcVisibilityProbe.new()
	probe.name = "NpcVisibilityProbe"
	get_tree().root.add_child.call_deferred(probe)
	probe.run.call_deferred()
