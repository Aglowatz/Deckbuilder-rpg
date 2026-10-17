extends Node
## Gainlands v2, Part A: lists every object the Gainlands builder and its dressing place (name, position, world-space size from the mesh bounds) so the audit in
## docs/art/gainlands_v2.md can compare current sizes with the storybook scale. Run: Godot --headless --path . res://tools/gainlands_inventory.tscn


func _ready() -> void:
	var host: Node3D = Node3D.new()
	add_child(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var dressing: GainlandsDressing = GainlandsDressing.build(host, builder, GraphicsQuality.Level.MEDIUM)
	for holder: Node3D in [builder.root, dressing.root]:
		print("== %s (%d children)" % [holder.name, holder.get_child_count()])
		var counts: Dictionary = {}
		for child: Node in holder.get_children():
			var key: String = String(child.name).rstrip("0123456789").trim_suffix("@")
			counts[key] = int(counts.get(key, 0)) + 1
			if child is Node3D:
				var size: Vector3 = _size(child as Node3D)
				var p: Vector3 = (child as Node3D).global_position
				print("  %-34s (%6.1f, %6.1f)  size %5.1f x %5.1f x %5.1f" % [child.name, p.x, p.z, size.x, size.y, size.z])
		print("  counts: %s" % str(counts))
	var trees: int = 0
	var rocks: int = 0
	for prop: GainlandsLayout.Prop in builder.layout.props:
		if prop.kind == "tree":
			trees += 1
		elif prop.kind == "boulder":
			rocks += 1
	print("== layout props %d (trees %d, boulders %d), signs %d, paths %d, pipes %d, enemies %d, chests %d" % [builder.layout.props.size(), trees, rocks, builder.layout.signs.size(), builder.layout.paths.size(), builder.layout.pipes.size(), builder.layout.enemy_spawns.size(), builder.layout.chests.size()])
	get_tree().quit()


## The world-space bounding box of every mesh under `node` (MultiMeshes counted by their AABB).
func _size(node: Node3D) -> Vector3:
	var box: AABB = AABB()
	var first: bool = true
	var meshes: Array[Node] = node.find_children("*", "VisualInstance3D", true, false)
	if node is VisualInstance3D:
		meshes.append(node)
	for item: Node in meshes:
		var visual: VisualInstance3D = item as VisualInstance3D
		var local: AABB = visual.get_aabb()
		if local.size == Vector3.ZERO:
			continue
		var world: AABB = visual.global_transform * local
		if first:
			box = world
			first = false
		else:
			box = box.merge(world)
	return box.size
