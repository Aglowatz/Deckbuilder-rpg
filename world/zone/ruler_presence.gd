class_name RulerPresence
extends RefCounted
## Part D: the ruler's presence in a zone's hub. While the zone is oppressed: a looming statue of the
## ruler with a plaque, and tall banners in the ruler's colors. Once it is freed the ruler is gone: the
## statue lies toppled (with a new plaque), and cheerful bunting hangs where the banners were.
## G-03: no lettering in the world. The banners and the plinth carry the ruler's emblem (an icon); the plaque's words (`ruler.statue`, `ruler.statue.freed` in the zone's story file)
## are read by using the statue (`ZoneScene` adds a "plaque" spot at `statue_position`).

const EMBLEM_ICON: String = "ICON-NODE-BOSS"

const STATUE_NAME: String = "RulerStatue"
const BANNERS_NAME: String = "RulerBanners"


## Builds the statue and banners (oppressed) or the toppled statue and bunting (freed) around `hub`.
static func build(parent: Node3D, builder: ZoneMap, zone_def: ZoneDef, story: ZoneStoryText, hub: Vector3, freed: bool) -> void:
	var statue: Node3D = _statue(zone_def.ruler_tint, freed)
	statue.name = STATUE_NAME
	var statue_pos: Vector3 = hub + zone_def.statue_offset
	statue_pos.y = builder.height_at(statue_pos)
	parent.add_child(statue)
	statue.position = statue_pos
	if not freed:
		builder.add_blocker(statue_pos, 0.9)
	var banners: Node3D = Node3D.new()
	banners.name = BANNERS_NAME
	parent.add_child(banners)
	for offset: Vector3 in zone_def.banner_offsets:
		var pos: Vector3 = hub + offset
		pos.y = builder.height_at(pos)
		var banner: Node3D = _bunting(zone_def.ruler_tint) if freed else _banner(zone_def.ruler_tint)
		banners.add_child(banner)
		banner.position = pos
		var emblem: MeshInstance3D = banner.find_child("Emblem", false, false) as MeshInstance3D
		if emblem != null and emblem.material_override is ShaderMaterial:
			# the emblem hangs with its cloth (the toon shaders' hang mode, Gainlands v2 Part E): the cloth's top and length in the emblem's own frame
			emblem.set_instance_shader_parameter("hang", Vector4(0, 0, 1, BANNER_CLOTH.y))
			emblem.set_instance_shader_parameter("hang_top_phase", Vector2(BANNER_TOP - emblem.position.y, StyleToon.hang_phase(banner.global_position if banner.is_inside_tree() else banner.position)))


## Where the statue stands for a zone whose hub is `hub` (the plaque spot goes here).
static func statue_position(zone_def: ZoneDef, hub: Vector3) -> Vector3:
	return hub + zone_def.statue_offset


## True when `parent` currently has the oppressive ruler props (a test hook).
static func has_ruler_props(parent: Node) -> bool:
	var statue: Node = parent.get_node_or_null(STATUE_NAME)
	return statue != null and not bool(statue.get_meta("toppled", false))


static func _statue(tint: Color, toppled: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.set_meta("toppled", toppled)
	var stone: StandardMaterial3D = _material(Color(0.42, 0.42, 0.45), 0.9)
	var cloth: StandardMaterial3D = _material(tint, 0.8)
	var pedestal: MeshInstance3D = _box(Vector3(1.8, 0.7, 1.8), stone)
	pedestal.position.y = 0.35
	root.add_child(pedestal)
	var figure: Node3D = Node3D.new()
	figure.position.y = 0.7
	root.add_child(figure)
	var body: MeshInstance3D = _mesh(CapsuleMesh.new(), cloth)
	(body.mesh as CapsuleMesh).radius = 0.5
	(body.mesh as CapsuleMesh).height = 2.2
	body.position.y = 1.2
	figure.add_child(body)
	var head: MeshInstance3D = _mesh(SphereMesh.new(), stone)
	(head.mesh as SphereMesh).radius = 0.38
	(head.mesh as SphereMesh).height = 0.76
	head.position.y = 2.55
	figure.add_child(head)
	var cape: MeshInstance3D = _box(Vector3(1.4, 1.8, 0.12), cloth)
	cape.position = Vector3(0, 1.4, -0.52)
	figure.add_child(cape)
	var fist: MeshInstance3D = _mesh(SphereMesh.new(), stone)
	(fist.mesh as SphereMesh).radius = 0.22
	(fist.mesh as SphereMesh).height = 0.44
	fist.position = Vector3(0.75, 2.2, 0.25)
	figure.add_child(fist)
	if toppled:
		figure.rotation_degrees = Vector3(0, 20, 84)
		figure.position = Vector3(1.2, 0.35, 1.0)
	root.add_child(_emblem(Vector2(0.5, 0.5), Vector3(0, 0.38, 0.91)))
	return root


## The banner's cloth (width, length) and the height of its top edge (it hangs from the crossbar): the hang mode keeps that edge still.
## Fixes Oct 26: a proper banner - a swallowtail cloth (two tails, SWALLOW_NOTCH deep in the middle) of the painted canvas in the ruler's colour with a
## darker trim down both sides and along the tails and a hem at the top, on a crossbar with a cap, a gilt finial on the pole, the emblem centred in
## the cloth's upper third. Cloth, trim and emblem share one hang frame (top BANNER_TOP, length BANNER_CLOTH.y), so they swing as one.
const BANNER_CLOTH: Vector2 = Vector2(1.3, 2.6)
const BANNER_TOP: float = 4.9
const BANNER_X: float = 0.72
const SWALLOW_NOTCH: float = 0.6
const TRIM_WIDTH: float = 0.1
const EMBLEM_SIZE: float = 0.84
const CLOTH_TEXTURE: String = "ENV-PROP-CANVAS"
const GILT: Color = Color("c9a227")
## The cloth's two faces stand this far either side of its plane: one plane drawn both ways shadowed itself (the sun's map cannot tell the faces apart).
const CLOTH_HALF_THICKNESS: float = 0.015


static func _banner(tint: Color) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "RulerBanner"
	var iron: StandardMaterial3D = _material(Color(0.2, 0.2, 0.22), 0.6)
	var gilt: StandardMaterial3D = _material(GILT, 0.35)
	gilt.metallic = 0.6
	var pole: MeshInstance3D = _mesh(CylinderMesh.new(), iron)
	pole.name = "Pole"  # rigid: the pole never bends (only the cloth sways, Gainlands v2 Part E)
	(pole.mesh as CylinderMesh).top_radius = 0.07
	(pole.mesh as CylinderMesh).bottom_radius = 0.09
	(pole.mesh as CylinderMesh).height = 5.0
	pole.position.y = 2.5
	root.add_child(pole)
	# the finial: a gilt ball and spike on the pole's top ("Pole" in the names keeps them rigid)
	var ball: MeshInstance3D = _mesh(SphereMesh.new(), gilt)
	ball.name = "FinialPole"
	(ball.mesh as SphereMesh).radius = 0.13
	(ball.mesh as SphereMesh).height = 0.26
	ball.position.y = 5.1
	root.add_child(ball)
	var spike: MeshInstance3D = _mesh(CylinderMesh.new(), gilt)
	spike.name = "FinialSpikePole"
	(spike.mesh as CylinderMesh).top_radius = 0.0
	(spike.mesh as CylinderMesh).bottom_radius = 0.06
	(spike.mesh as CylinderMesh).height = 0.32
	spike.position.y = 5.36
	root.add_child(spike)
	# the crossbar the cloth hangs from, with a gilt cap at its end
	var bar_length: float = BANNER_X + BANNER_CLOTH.x * 0.5 + 0.12
	var bar: MeshInstance3D = _mesh(CylinderMesh.new(), iron)
	bar.name = "CrossbarPole"
	(bar.mesh as CylinderMesh).top_radius = 0.035
	(bar.mesh as CylinderMesh).bottom_radius = 0.035
	(bar.mesh as CylinderMesh).height = bar_length
	bar.rotation_degrees.z = 90.0
	bar.position = Vector3(bar_length * 0.5, BANNER_TOP + 0.04, 0.0)
	root.add_child(bar)
	var cap: MeshInstance3D = _mesh(SphereMesh.new(), gilt)
	cap.name = "CrossbarCapPole"
	(cap.mesh as SphereMesh).radius = 0.06
	(cap.mesh as SphereMesh).height = 0.12
	cap.position = Vector3(bar_length, BANNER_TOP + 0.04, 0.0)
	root.add_child(cap)
	var canvas: Texture2D = EnvKit.texture(CLOTH_TEXTURE) if EnvKit.has(CLOTH_TEXTURE) else null
	root.add_child(_hanging("BannerCloth", _cloth_mesh(), _cloth_material(_dyed(tint), canvas)))
	root.add_child(_hanging("BannerTrim", _trim_mesh(), _cloth_material(tint.darkened(0.5), canvas)))
	root.add_child(_emblem(Vector2(EMBLEM_SIZE, EMBLEM_SIZE), Vector3(BANNER_X, BANNER_TOP - BANNER_CLOTH.y / 6.0 - 0.06, CLOTH_HALF_THICKNESS + 0.03), true))
	return root


## A hanging part of the banner, its top edge at BANNER_TOP: the hang mode reads its top and length from the meta (the cloth's own frame).
static func _hanging(node_name: String, mesh: ArrayMesh, material: StandardMaterial3D) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = Vector3(BANNER_X, BANNER_TOP, 0.0)
	instance.set_meta(&"hang", Vector2(0.0, BANNER_CLOTH.y))
	instance.set_meta(&"hang_normal", Vector3(0, 0, 1))
	return instance


## The cloth's colour on the canvas: the painted weave darkens what it multiplies (its average is well under white in linear light), so the ruler's
## colour is lifted in value - same hue - until the dyed cloth reads as bright as the old flat one.
static func _dyed(tint: Color) -> Color:
	return Color.from_hsv(tint.h, tint.s * 0.92, minf(tint.v * 1.6 + 0.12, 1.0))


static func _cloth_material(color: Color, texture: Texture2D) -> StandardMaterial3D:
	var material: StandardMaterial3D = _material(color, 0.85)
	material.albedo_texture = texture
	return material


## The cloth's bottom edge at `x` (-w/2..w/2): the two tails reach the full length at the sides, the notch rises SWALLOW_NOTCH in the middle.
static func _hem_y(x: float) -> float:
	var half: float = BANNER_CLOTH.x * 0.5
	return -BANNER_CLOTH.y + SWALLOW_NOTCH * (1.0 - absf(x) / half)


## The swallowtail cloth: a grid of quads from the top edge (y 0) down to the hem, both faces, UVs on the canvas (one tile across).
static func _cloth_mesh() -> ArrayMesh:
	var cols: int = 6
	var rows: int = 12
	var half: float = BANNER_CLOTH.x * 0.5
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side: float in [1.0, -1.0]:
		for i: int in range(cols):
			for j: int in range(rows):
				var quad: Array[Vector3] = []
				var uvs: Array[Vector2] = []
				for corner: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]:
					var x: float = -half + BANNER_CLOTH.x * float(i + corner.x) / float(cols)
					var y: float = _hem_y(x) * float(j + corner.y) / float(rows)
					quad.append(Vector3(x, y, CLOTH_HALF_THICKNESS * side))
					uvs.append(Vector2((x + half) / BANNER_CLOTH.x, -y / BANNER_CLOTH.x))
				_quad(tool, quad, uvs, Vector3(0, 0, side))
	return tool.commit()


## The trim: bands TRIM_WIDTH wide down both sides, along both tails' edges and across the top (the hem), a hair in front of and behind the cloth.
static func _trim_mesh() -> ArrayMesh:
	var half: float = BANNER_CLOTH.x * 0.5
	var bands: Array[Array] = [
		[Vector2(-half, 0.0), Vector2(-half, _hem_y(-half))], [Vector2(half, 0.0), Vector2(half, _hem_y(half))],
		[Vector2(-half, _hem_y(-half)), Vector2(0.0, _hem_y(0.0))], [Vector2(0.0, _hem_y(0.0)), Vector2(half, _hem_y(half))],
		[Vector2(-half, 0.0), Vector2(half, 0.0)],
	]
	var middle: Vector2 = Vector2(0.0, -BANNER_CLOTH.y * 0.5)
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side: float in [1.0, -1.0]:
		for band: Array in bands:
			var a: Vector2 = band[0] as Vector2
			var b: Vector2 = band[1] as Vector2
			var along: Vector2 = (b - a).normalized()
			# the band lies on the cloth: it grows from the edge toward the cloth's middle
			var inward: Vector2 = Vector2(-along.y, along.x)
			if inward.dot(middle - (a + b) * 0.5) < 0.0:
				inward = -inward
			var steps: int = maxi(1, int(a.distance_to(b) / 0.2))
			for k: int in range(steps):
				var p0: Vector2 = a.lerp(b, float(k) / float(steps))
				var p1: Vector2 = a.lerp(b, float(k + 1) / float(steps))
				var z: float = (CLOTH_HALF_THICKNESS + 0.008) * side
				var quad: Array[Vector3] = [Vector3(p0.x, p0.y, z), Vector3(p1.x, p1.y, z), Vector3(p1.x + inward.x * TRIM_WIDTH, p1.y + inward.y * TRIM_WIDTH, z), Vector3(p0.x + inward.x * TRIM_WIDTH, p0.y + inward.y * TRIM_WIDTH, z)]
				var uvs: Array[Vector2] = []
				for q: Vector3 in quad:
					uvs.append(Vector2((q.x + half) / BANNER_CLOTH.x, -q.y / BANNER_CLOTH.x))
				_quad(tool, quad, uvs, Vector3(0, 0, side))
	return tool.commit()


## Two triangles facing `normal` (Godot's front faces wind clockwise seen from the front).
static func _quad(tool: SurfaceTool, points: Array[Vector3], uvs: Array[Vector2], normal: Vector3) -> void:
	var order: Array[int] = [0, 1, 2, 0, 2, 3]
	if (points[1] - points[0]).cross(points[2] - points[0]).dot(normal) > 0.0:
		order = [0, 2, 1, 0, 3, 2]
	for index: int in order:
		tool.set_normal(normal)
		tool.set_uv(uvs[index])
		tool.add_vertex(points[index])


static func _bunting(tint: Color) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Bunting"
	root.set_meta(&"no_wind", true)  # small pennants on a line: they used to bend from their pole's foot
	var pole: MeshInstance3D = _mesh(CylinderMesh.new(), _material(Color(0.55, 0.4, 0.25), 0.7))
	(pole.mesh as CylinderMesh).top_radius = 0.06
	(pole.mesh as CylinderMesh).bottom_radius = 0.08
	(pole.mesh as CylinderMesh).height = 4.0
	pole.position.y = 2.0
	root.add_child(pole)
	var colors: Array[Color] = [Color("e8625a"), Color("f2c14e"), Color("6fbf73"), Color("5aa0e0"), tint.lightened(0.3)]
	for index: int in range(5):
		var flag: MeshInstance3D = _mesh(PrismMesh.new(), _material(colors[index], 0.8))
		(flag.mesh as PrismMesh).size = Vector3(0.5, 0.6, 0.05)
		flag.rotation_degrees.z = 180.0
		flag.position = Vector3(0.35 + 0.5 * float(index), 3.8 - 0.12 * float(index % 2), 0)
		root.add_child(flag)
	return root


const CLOTH_ICON_SHADER: String = "res://world/style/style_cloth_icon.gdshader"


## The ruler's emblem: an unshaded icon quad (no toon conversion), facing +z like the old lettering.
## `hanging`: the emblem is painted on a banner's cloth and moves with it (style_cloth_icon.gdshader, the toon shaders' hang mode).
static func _emblem(size: Vector2, pos: Vector3, hanging: bool = false) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = size
	var material: Material = null
	if hanging:
		var cloth_icon: ShaderMaterial = ShaderMaterial.new()
		cloth_icon.shader = load(CLOTH_ICON_SHADER) as Shader
		cloth_icon.set_shader_parameter("icon", IconArt.texture(EMBLEM_ICON, 128.0))
		cloth_icon.set_meta(StyleToon.META_NO_TOON, true)
		material = cloth_icon
	else:
		var standard: StandardMaterial3D = StandardMaterial3D.new()
		standard.albedo_texture = IconArt.texture(EMBLEM_ICON, 128.0)
		standard.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		standard.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		standard.set_meta(StyleToon.META_NO_TOON, true)
		material = standard
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "Emblem"
	instance.mesh = quad
	instance.material_override = material
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.position = pos
	return instance


static func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


static func _mesh(mesh: Mesh, material: StandardMaterial3D) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	return instance


static func _box(size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	return _mesh(mesh, material)
