class_name CloakSway
extends Node
## Secondary motion for a cloak: a chain of pivots (`Seg0`, `Seg1`, ... under the cloak root) bends back as the hero moves forward, swings sideways when the hero turns or
## strafes, and flutters a little when idle. Each segment is a spring that follows a lagged copy of the target, so the cloth whips instead of stiffly leaning.

var cloak: Node3D
var anchor: Node3D
var strength: float = 1.0

var _pivots: Array[Node3D] = []
var _angles: Array[Vector2] = []
var _last_position: Vector3 = Vector3.ZERO
var _last_yaw: float = 0.0
var _velocity_local: Vector3 = Vector3.ZERO
var _spin: float = 0.0
var _time: float = 0.0
var _have_last: bool = false


static func attach(cloak_root: Node3D, anchor_node: Node3D, sway_strength: float = 1.0) -> CloakSway:
	var sway: CloakSway = CloakSway.new()
	sway.name = "CloakSway"
	sway.cloak = cloak_root
	sway.anchor = anchor_node
	sway.strength = sway_strength
	cloak_root.add_child(sway)
	sway._collect()
	return sway


func _collect() -> void:
	_pivots.clear()
	_angles.clear()
	for node: Node in cloak.find_children("*Seg*", "Node3D", true, false):
		_pivots.append(node as Node3D)
		_angles.append(Vector2.ZERO)


func pivot_count() -> int:
	return _pivots.size()


func _process(delta: float) -> void:
	if delta <= 0.0 or anchor == null or not anchor.is_inside_tree():
		return
	_time += delta
	var pos: Vector3 = anchor.global_position
	var yaw: float = anchor.global_rotation.y
	if _have_last:
		var world_velocity: Vector3 = (pos - _last_position) / delta
		var target_local: Vector3 = anchor.global_basis.inverse() * world_velocity
		_velocity_local = _velocity_local.lerp(target_local, 1.0 - exp(-14.0 * delta))
		_spin = lerpf(_spin, wrapf(yaw - _last_yaw, -PI, PI) / delta, 1.0 - exp(-10.0 * delta))
	_last_position = pos
	_last_yaw = yaw
	_have_last = true
	var speed: float = Vector2(_velocity_local.x, _velocity_local.z).length()
	# x: swing back when moving forward (the model faces +Z); z: swing sideways when strafing or turning.
	var lean_x: float = clampf(_velocity_local.z * 0.2, -0.55, 0.85) * strength
	var lean_z: float = clampf(-_velocity_local.x * 0.2 + _spin * 0.05, -0.6, 0.6) * strength
	var flutter: float = (0.045 + minf(speed, 4.0) * 0.03) * strength
	for i: int in range(_pivots.size()):
		var lag: float = 1.0 + 0.45 * float(i)
		var target_x: float = lean_x * (0.55 + 0.2 * float(i)) + sin(_time * (2.1 + 0.6 * float(i)) - float(i) * 0.9) * flutter
		var target_z: float = lean_z * (0.55 + 0.2 * float(i)) + sin(_time * (1.7 + 0.5 * float(i)) + float(i)) * flutter * 0.7
		var rate: float = 9.0 / lag
		var current: Vector2 = _angles[i]
		current.x = lerpf(current.x, target_x, 1.0 - exp(-rate * delta))
		current.y = lerpf(current.y, target_z, 1.0 - exp(-rate * delta))
		_angles[i] = current
		_pivots[i].rotation = Vector3(current.x, 0.0, current.y)
