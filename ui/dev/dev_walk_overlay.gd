class_name DevWalkOverlay
extends MultiMeshInstance3D
## Oct 20 Dev Menu: tints the ground round the hero - green where the hero may stand, red where the area's `WalkableArea` refuses -
## in a square of `RADIUS` metres, rebuilt every `REFRESH` seconds as the hero moves. Debug only; it never blocks anything.

const RADIUS: float = 14.0
const STEP: float = 0.5
const REFRESH: float = 0.5
const OPEN: Color = Color(0.25, 1.0, 0.35, 0.35)
const BLOCKED: Color = Color(1.0, 0.2, 0.2, 0.4)

var hero: TownPlayer
var _timer: float = 0.0


func _ready() -> void:
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(STEP * 0.9, STEP * 0.9)
	quad.orientation = PlaneMesh.FACE_Y
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.no_depth_test = true  # seen through props and slopes: it is a debug view
	quad.material = material
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.mesh = quad
	var side: int = int(RADIUS * 2.0 / STEP)
	multimesh.instance_count = side * side
	_rebuild()


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = REFRESH
		_rebuild()


func _rebuild() -> void:
	if hero == null or not is_instance_valid(hero) or hero.town == null:
		return
	var side: int = int(RADIUS * 2.0 / STEP)
	var origin: Vector3 = hero.global_position
	var corner: Vector3 = Vector3(snappedf(origin.x, STEP) - RADIUS, origin.y + 0.06, snappedf(origin.z, STEP) - RADIUS)
	var index: int = 0
	for row: int in range(side):
		for column: int in range(side):
			var at: Vector3 = corner + Vector3(column * STEP, 0.0, row * STEP)
			multimesh.set_instance_transform(index, Transform3D(Basis.IDENTITY, at))
			multimesh.set_instance_color(index, OPEN if hero.town.is_walkable(at) else BLOCKED)
			index += 1
