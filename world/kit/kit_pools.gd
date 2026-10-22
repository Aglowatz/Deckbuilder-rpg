class_name KitPools
extends RefCounted
## Batched ground pools for the kit (vertical slice, Part D / performance): every soft ambient-occlusion skirt under a building or prop, and every warm pool of lantern / window
## light, of a whole scene become ONE mesh each (vertex colours carry strength and fade), instead of one node and one material per pool. Built at the end of the town build.
##   AO   pool: {"pos": Vector3, "size": Vector2 (width, depth; ZERO = a circle), "radius": float, "yaw": float (degrees), "strength": float, "margin": float}
##   glow pool: {"pos": Vector3, "radius": float, "color": Color, "strength": float}

const AO_LIFT: float = 0.041
## Graphics Tier 1: how far inside the footprint line a building's AO ring fades to nothing.
const INNER_FADE: float = 0.9
const GLOW_LIFT: float = 0.072
const AO_SHADE: Color = Color(0.16, 0.1, 0.22)
const AO_SHADER: String = "res://world/kit/kit_pools.gdshader"
const GLOW_SHADER: String = "res://world/kit/kit_pools_glow.gdshader"


## One MeshInstance3D with every AO pool: a rectangle (or a disc) at full strength fading linearly to nothing over `margin` metres.
static func build_ao(parent: Node3D, pools: Array[Dictionary]) -> MeshInstance3D:
	if pools.is_empty() or OS.get_environment("KIT_OFF").contains("ao"):
		return null
	var mesh: KitMesh = KitMesh.new()
	# Graphics Tier 1: a shader material (kit_pools.gdshader) so the skirts can fade out at the bottom of the screen, under cut-away buildings.
	var material_value: ShaderMaterial = ShaderMaterial.new()
	material_value.shader = load(AO_SHADER) as Shader
	material_value.render_priority = -30
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
		# Graphics Tier 1: the skirt is a hollow ring - full at the footprint line, fading outward over the margin and inward over INNER_FADE metres. Nothing
		# is drawn under the middle of the building, so a building the OcclusionFader cuts away reveals the painted ground, not a violet rectangle.
		var inset_pts: Array[Vector3] = []
		for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			inset_pts.append(Vector3(pos.x, AO_LIFT, pos.z) + basis * Vector3(corner.x * maxf(hx - INNER_FADE, 0.0), 0.0, corner.y * maxf(hz - INNER_FADE, 0.0)))
		for side: int in range(4):
			var next: int = (side + 1) % 4
			mesh.quad("ao", [in_pts[side], in_pts[next], out_pts[next], out_pts[side]], Vector3.UP, [inner, inner, outer, outer])
			mesh.quad("ao", [inset_pts[side], inset_pts[next], in_pts[next], in_pts[side]], Vector3.UP, [outer, outer, inner, inner])
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
	var material_value: ShaderMaterial = ShaderMaterial.new()
	material_value.shader = load(GLOW_SHADER) as Shader
	material_value.set_shader_parameter("soft_tex", StyleAmbience.soft_texture())
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
