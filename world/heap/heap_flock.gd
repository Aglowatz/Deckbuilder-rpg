class_name HeapFlock
extends Node3D
## The Junk Gull Flock's model: flaps every gull's wings and rocks the gulls a little so the flock reads as alive.

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	for gull: Node in get_children():
		var phase: float = float(gull.get_index()) * 0.9
		var flap: float = sin(_time * 14.0 + phase) * 0.7
		var left: Node3D = gull.get_node_or_null("WingL") as Node3D
		var right: Node3D = gull.get_node_or_null("WingR") as Node3D
		if left != null:
			left.rotation.z = -flap
		if right != null:
			right.rotation.z = flap
		(gull as Node3D).position.y += sin(_time * 3.0 + phase) * 0.002
