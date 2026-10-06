class_name StyleBeacon
extends RefCounted
## A faint additive light pillar so a destination reads from across the map (soft, no hard edge). Shared by the town Rift Express, the starting-area cave gate and other landmarks.


static func build(parent: Node3D, pos: Vector3, color: Color, height: float = 7.0, alpha: float = 0.22) -> MeshInstance3D:
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.2
	cylinder.bottom_radius = 0.6
	cylinder.height = height
	cylinder.radial_segments = 16
	cylinder.rings = 1
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Additive blending only applies with a transparent material; without it the pillar renders opaque white.
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_BACK
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	var pillar: MeshInstance3D = MeshInstance3D.new()
	pillar.mesh = cylinder
	pillar.material_override = material
	pillar.position = pos + Vector3(0.0, height * 0.5, 0.0)
	pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pillar.set_meta(StyleToon.META_NO_TOON, true)
	parent.add_child(pillar)
	return pillar
