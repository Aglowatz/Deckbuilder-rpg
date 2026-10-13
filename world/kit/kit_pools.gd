class_name KitPools
extends RefCounted
## Batched ground pools for the kit (vertical slice, Part D / performance): every soft ambient-occlusion skirt under a building or prop, and every warm pool of lantern / window
## light, of a whole scene become ONE mesh each (vertex colours carry strength and fade), instead of one node and one material per pool. Built at the end of the town build.
##   AO   pool: {"pos": Vector3, "size": Vector2 (width, depth; ZERO = a circle), "radius": float, "yaw": float (degrees), "strength": float, "margin": float}
##   glow pool: {"pos": Vector3, "radius": float, "color": Color, "strength": float}

const AO_LIFT: float = 0.041
const GLOW_LIFT: float = 0.072
const AO_SHADE: Color = Color(0.16, 0.1, 0.22)


## One MeshInstance3D with every AO pool: a rectangle (or a disc) at full strength fading linearly to nothing over `margin` metres.
static func build_ao(parent: Node3D, pools: Array[Dictionary]) -> MeshInstance3D:
	if pools.is_empty() or OS.get_environment("KIT_OFF").contains("ao"):
		return null
	var mesh: KitMesh = KitMesh.new()
	var material_value: StandardMaterial3D = StandardMaterial3D.new()
	material_value.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_value.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_value.vertex_color_use_as_albedo = true
	material_value.disable_receive_shadows = true
	material_value.render_priority = -30
	material_value.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_value.set_meta(StyleToon.META_NO_TOON, true)
	mesh.set_material("ao", material_value)
	for pool: Dictionary in pools:
		var pos: Vector3 = pool["pos"] as Vector3
		var strength: float = float(pool.get("strength", 0.4))
		var margin: float = float(pool.get("margin", 0.9))
		var inner: Color = Color(AO_SHADE.r, AO_SHADE.g, AO_SHADE.b, strength)
		var outer: Color = Color(AO_SHADE.r, AO_SHADE.g, AO_SHADE.b, 0.0)
		var size: Vector2 = pool.get("size", Vector2.ZERO) as Vector2
		if size == Vector2.ZERO:
			var radius: float = float(pool.get("radius", 0.5))
			var segs: int = 10
			for step: int in range(segs):
				var a0: float = TAU * float(step) / float(segs)
				var a1: float = TAU * float(step + 1) / float(segs)
				var center: Vector3 = Vector3(pos.x, AO_LIFT, pos.z)
				var p0: Vector3 = center + Vector3(cos(a0), 0, sin(a0)) * (radius + margin)
				var p1: Vector3 = center + Vector3(cos(a1), 0, sin(a1)) * (radius + margin)
				mesh.tri("ao", [center, p0, p1], Vector3.UP, [inner, outer, outer])
			continue
		var yaw: float = deg_to_rad(float(pool.get("yaw", 0.0)))
		var basis: Basis = Basis(Vector3.UP, yaw)
		var hx: float = size.x * 0.5
		var hz: float = size.y * 0.5
		var in_pts: Array[Vector3] = []
		var out_pts: Array[Vector3] = []
		for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			in_pts.append(Vector3(pos.x, AO_LIFT, pos.z) + basis * Vector3(corner.x * hx, 0.0, corner.y * hz))
			out_pts.append(Vector3(pos.x, AO_LIFT, pos.z) + basis * Vector3(corner.x * (hx + margin), 0.0, corner.y * (hz + margin)))
		mesh.quad("ao", in_pts, Vector3.UP, [inner, inner, inner, inner])
		for side: int in range(4):
			var next: int = (side + 1) % 4
			mesh.quad("ao", [in_pts[side], in_pts[next], out_pts[next], out_pts[side]], Vector3.UP, [inner, inner, outer, outer])
	var instance: MeshInstance3D = mesh.instance("AOPools")
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta("no_occlusion_fade", true)
	parent.add_child(instance)
	return instance


## One MeshInstance3D with every warm light pool (additive, soft round texture).
static func build_glow(parent: Node3D, pools: Array[Dictionary]) -> MeshInstance3D:
	if pools.is_empty() or OS.get_environment("KIT_OFF").contains("glow"):
		return null
	var mesh: KitMesh = KitMesh.new()
	var material_value: StandardMaterial3D = StandardMaterial3D.new()
	material_value.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_value.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_value.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material_value.albedo_texture = StyleAmbience.soft_texture()
	material_value.vertex_color_use_as_albedo = true
	material_value.disable_receive_shadows = true
	material_value.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_value.set_meta(StyleToon.META_NO_TOON, true)
	mesh.set_material("glow", material_value)
	for pool: Dictionary in pools:
		var pos: Vector3 = pool["pos"] as Vector3
		var radius: float = float(pool.get("radius", 2.2))
		var color: Color = pool.get("color", Color("ffb45a")) as Color
		var strength: float = float(pool.get("strength", 0.15))
		var tint: Color = Color(color.r, color.g, color.b, strength)
		var y: float = GLOW_LIFT
		mesh.quad("glow", [Vector3(pos.x - radius, y, pos.z - radius), Vector3(pos.x + radius, y, pos.z - radius), Vector3(pos.x + radius, y, pos.z + radius), Vector3(pos.x - radius, y, pos.z + radius)], Vector3.UP,
			[tint, tint, tint, tint], [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	var instance: MeshInstance3D = mesh.instance("GlowPools")
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta("no_occlusion_fade", true)
	parent.add_child(instance)
	return instance
