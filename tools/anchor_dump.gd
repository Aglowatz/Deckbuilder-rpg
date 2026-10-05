extends SceneTree
func _initialize() -> void:
	var t: TownBuilder = TownBuilder.new()
	var root: Node3D = Node3D.new()
	t.build(root)
	for k: String in t.anchors:
		var a: Vector3 = t.anchors[k]
		print("anchor ", k, " ", a, " cell ", HexGrid.world_to_cell(a))
	print("obstacles ", t.obstacles.size(), " walkable ", t.walkable.size())
	quit()
