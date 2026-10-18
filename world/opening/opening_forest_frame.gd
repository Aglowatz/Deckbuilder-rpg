class_name OpeningForestFrame
extends Node3D
## Dark foreground foliage at the screen's bottom corners (Art Bible G-06, the paint-over's silhouette leaves), riding with the camera so it frames every
## spot, angle, zoom and swivel the same way and never covers the hero, the NPCs or the dialogue box in the middle. Fern fronds and leaf sprays as
## flat silhouettes a metre or two in front of the lens (the tilt-shift blurs them), placed from the camera's field of view each frame, swaying a little.

const DISTANCE: float = 1.4
const COLOR: Color = Color(0.02, 0.06, 0.07)
## The sprays are built for a 16:9 screen (unit frame: y in -1..1, x in -ASPECT..ASPECT) and scaled uniformly, so the fronds keep their shape.
const ASPECT: float = 16.0 / 9.0

var camera: Camera3D
var _mesh: KitMesh = KitMesh.new()
var _body: MeshInstance3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _time: float = 0.0
var _last_fov: float = -1.0
var _last_aspect: float = -1.0


static func attach(cam: Camera3D) -> OpeningForestFrame:
	var frame: OpeningForestFrame = OpeningForestFrame.new()
	frame.name = "OpeningForestFrame"
	frame.camera = cam
	frame._rng.seed = 77
	cam.add_child(frame)
	frame._build()
	return frame


func _build() -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = COLOR
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.disable_fog = true
	material.set_meta(StyleToon.META_NO_TOON, true)
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	_mesh.set_material("leaf", material)
	# unit frame: the screen's corners at (+-1, +-1); sprays rooted just off the bottom corners, leaning in
	_spray(Vector2(-1.08, -1.12), 0.62, -0.25, 11)
	_spray(Vector2(-0.82, -1.18), 0.38, 0.15, 7)
	_spray(Vector2(1.1, -1.14), 0.5, 0.3, 9)
	_spray(Vector2(0.9, -1.2), 0.3, -0.1, 6)
	_spray(Vector2(-1.12, 0.95), 0.34, -2.4, 7)
	_body = _mesh.instance("FrameLeaves")
	_body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_body.set_meta(&"no_occlusion_fade", true)
	_body.set_meta(&"no_wind", true)
	_body.extra_cull_margin = 4.0
	add_child(_body)


## A spray of fronds from `root` (unit frame), `size` in unit-frame heights, leaning by `lean` radians off straight up, `count` fronds.
func _spray(unit_root: Vector2, size: float, lean: float, count: int) -> void:
	var root: Vector2 = Vector2(unit_root.x * ASPECT, unit_root.y)
	for index: int in range(count):
		var angle: float = lean + PI * 0.5 + lerpf(-0.75, 0.75, float(index) / float(maxi(count - 1, 1))) + _rng.randf_range(-0.12, 0.12)
		var length: float = size * _rng.randf_range(0.65, 1.1)
		var bend: float = _rng.randf_range(-0.35, 0.35)
		var shade: float = _rng.randf_range(0.7, 1.15)
		var prev_l: Vector2 = root
		var prev_r: Vector2 = root
		var steps: int = 6
		for s: int in range(1, steps + 1):
			var t: float = float(s) / float(steps)
			var a: float = angle + bend * t
			var spine: Vector2 = root + Vector2(cos(angle), sin(angle)) * length * t * 0.6 + Vector2(cos(a), sin(a)) * length * t * 0.4
			var across: Vector2 = Vector2(-sin(a), cos(a)) * size * 0.085 * sin(t * PI) * (1.0 + 0.4 * sin(t * 18.0))
			var l: Vector2 = spine - across
			var r: Vector2 = spine + across
			var c: Color = Color(shade, shade, shade)
			_mesh.quad("leaf", [Vector3(prev_l.x, prev_l.y, 0.0), Vector3(prev_r.x, prev_r.y, 0.0), Vector3(r.x, r.y, 0.0), Vector3(l.x, l.y, 0.0)], Vector3(0, 0, 1), [c, c, c, c])
			prev_l = l
			prev_r = r


func _process(delta: float) -> void:
	if camera == null:
		return
	_time += delta
	var size: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = size.x / maxf(size.y, 1.0)
	if not is_equal_approx(camera.fov, _last_fov) or not is_equal_approx(aspect, _last_aspect):
		_last_fov = camera.fov
		_last_aspect = aspect
		var half_h: float = DISTANCE * tan(deg_to_rad(camera.fov) * 0.5)
		_body.scale = Vector3(half_h, half_h, 1.0)
	_body.position = Vector3(sin(_time * 0.6) * 0.004, sin(_time * 0.43 + 1.0) * 0.003, -DISTANCE)
