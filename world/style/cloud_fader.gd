class_name CloudFader
extends Node
## Decorative clouds that never obscure play: each adopted cloud gets a soft translucent material and fades out whenever it sits between the camera and the hero
## (or is close to the camera), and fades back in afterwards. `adopt` clouds, then add the fader to the scene with a camera and a target.

const FADE_SPEED: float = 3.0

var camera: Camera3D
var target: Node3D
var _clouds: Array[Dictionary] = []


static func make_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.97, 0.94, 0.92)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


## Makes `cloud` (a model root) fade-capable; `radius` is its rough half-size in metres.
func adopt(cloud: Node3D, radius: float) -> void:
	var material: StandardMaterial3D = make_material()
	for node: Node in cloud.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		mesh_instance.material_override = material
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh_instance.set_meta(StyleToon.META_NO_TOON, true)
	_clouds.append({"node": cloud, "material": material, "radius": radius, "alpha": 0.92})


func cloud_count() -> int:
	return _clouds.size()


## Opacity a cloud at `cloud_pos` should have for a camera at `cam_pos` looking at `hero_pos` (pure function, tested).
static func target_alpha(cam_pos: Vector3, hero_pos: Vector3, cloud_pos: Vector3, radius: float) -> float:
	var to_hero: Vector3 = hero_pos - cam_pos
	var length_sq: float = to_hero.length_squared()
	if length_sq < 0.001:
		return 0.92
	var t: float = clampf((cloud_pos - cam_pos).dot(to_hero) / length_sq, 0.0, 1.0)
	var nearest: Vector3 = cam_pos + to_hero * t
	var miss: float = cloud_pos.distance_to(nearest)
	var near_camera: float = cloud_pos.distance_to(cam_pos)
	var blocking: float = 1.0 - smoothstep(radius * 0.6, radius * 1.6, miss)
	var close: float = 1.0 - smoothstep(radius * 1.2, radius * 3.0, near_camera)
	return lerpf(0.92, 0.0, maxf(blocking, close))


func _process(delta: float) -> void:
	if camera == null or not is_instance_valid(camera):
		camera = get_viewport().get_camera_3d()
	if camera == null or target == null or not is_instance_valid(camera) or not is_instance_valid(target):
		return
	var hero: Vector3 = target.global_position + Vector3(0.0, 0.6, 0.0)
	for entry: Dictionary in _clouds:
		var cloud: Node3D = entry["node"] as Node3D
		if not is_instance_valid(cloud):
			continue
		var goal: float = target_alpha(camera.global_position, hero, cloud.global_position, float(entry["radius"]))
		var alpha: float = move_toward(float(entry["alpha"]), goal, FADE_SPEED * delta)
		entry["alpha"] = alpha
		var material: StandardMaterial3D = entry["material"] as StandardMaterial3D
		material.albedo_color.a = alpha
		cloud.visible = alpha > 0.01
