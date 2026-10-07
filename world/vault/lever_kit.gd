class_name LeverKit
extends RefCounted
## Brief 16, Group G: the hidden vault levers in the four Path zones. A small stone-and-iron lever box (a base, an upright slot, a heavy handle with a coloured knob) whose
## `Handle` swings down when pulled. No marker, plate or glow: the zone scene only shows the [E] prompt within a metre or so.

const HANDLE_UP_DEGREES: float = -55.0
const HANDLE_DOWN_DEGREES: float = 55.0
const PROMPT_RADIUS: float = 1.5


## A lever in the colour of its Path (the knob and a small gem on the base).
static func build(path_color: Color) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "VaultLever"
	var mesh: ProcMesh = ProcMesh.new()
	var stone: Color = Color("6b6878")
	var dark: Color = Color("3b3947")
	mesh.box(Vector3(0.0, 0.16, 0.0), Vector3(0.9, 0.32, 0.55), stone)
	mesh.box(Vector3(0.0, 0.36, 0.0), Vector3(0.7, 0.08, 0.4), dark)
	mesh.box(Vector3(0.0, 0.42, 0.0), Vector3(0.12, 0.1, 0.5), Color("1d1c25"))
	mesh.box(Vector3(-0.3, 0.2, 0.29), Vector3(0.12, 0.12, 0.04), path_color)
	root.add_child(mesh.build("Base"))
	var handle: Node3D = Node3D.new()
	handle.name = "Handle"
	handle.position = Vector3(0.0, 0.42, 0.0)
	handle.rotation_degrees.z = HANDLE_UP_DEGREES
	var rod: ProcMesh = ProcMesh.new()
	rod.frustum(0.0, 0.85, 0.045, 0.04, 8, Color("a7a9b8"))
	rod.sphere(Vector3(0.0, 0.88, 0.0), 0.1, 5, 8, path_color)
	handle.add_child(rod.build("Rod"))
	root.add_child(handle)
	return root


static func handle_of(lever: Node3D) -> Node3D:
	return lever.get_node_or_null("Handle") as Node3D if lever != null else null


## Snaps the handle up (not pulled) or down (pulled).
static func set_pulled(lever: Node3D, pulled: bool) -> void:
	var handle: Node3D = handle_of(lever)
	if handle != null:
		handle.rotation_degrees.z = HANDLE_DOWN_DEGREES if pulled else HANDLE_UP_DEGREES
		lever.set_meta(&"pulled", pulled)


## Swings the handle down with a little overshoot (state recorded at once); returns the tween.
static func pull_animated(lever: Node3D) -> Tween:
	var handle: Node3D = handle_of(lever)
	if handle == null:
		return null
	lever.set_meta(&"pulled", true)
	var tween: Tween = handle.create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(handle, "rotation_degrees:z", HANDLE_DOWN_DEGREES, 0.45)
	return tween
