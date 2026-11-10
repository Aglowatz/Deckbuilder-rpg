extends Node
## Main scene for the dungeon route audit (Fable pass Nov 10, Part 1.2): starts DungeonRouteAudit on the root so it survives the scene changes.


func _ready() -> void:
	var audit: DungeonRouteAudit = DungeonRouteAudit.new()
	audit.name = "DungeonRouteAudit"
	get_tree().root.add_child.call_deferred(audit)
	audit.run.call_deferred()
