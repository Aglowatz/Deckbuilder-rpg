class_name RulerPresence
extends RefCounted
## Part D: the ruler's presence in a zone's hub. While the zone is oppressed: a looming statue of the
## ruler with a plaque, and tall banners in the ruler's colors. Once it is freed the ruler is gone: the
## statue lies toppled (with a new plaque), and cheerful bunting hangs where the banners were.
## All plaque text lives in the zone's story file (`ruler.statue`, `ruler.statue.freed`).

const STATUE_NAME: String = "RulerStatue"
const BANNERS_NAME: String = "RulerBanners"


## Builds the statue and banners (oppressed) or the toppled statue and bunting (freed) around `hub`.
static func build(parent: Node3D, builder: ZoneMap, zone_def: ZoneDef, story: ZoneStoryText, hub: Vector3, freed: bool) -> void:
	var statue: Node3D = _statue(zone_def.ruler_tint, story.text("ruler.statue"), freed)
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
		var banner: Node3D = _bunting(zone_def.ruler_tint) if freed else _banner(zone_def.ruler_tint, zone_def.ruler_name)
		banners.add_child(banner)
		banner.position = pos


## True when `parent` currently has the oppressive ruler props (a test hook).
static func has_ruler_props(parent: Node) -> bool:
	var statue: Node = parent.get_node_or_null(STATUE_NAME)
	return statue != null and not bool(statue.get_meta("toppled", false))


static func _statue(tint: Color, plaque_text: String, toppled: bool) -> Node3D:
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
	root.add_child(_plaque(plaque_text, Vector3(0, 0.55, 0.95)))
	return root


static func _banner(tint: Color, text: String) -> Node3D:
	var root: Node3D = Node3D.new()
	var pole: MeshInstance3D = _mesh(CylinderMesh.new(), _material(Color(0.2, 0.2, 0.22), 0.6))
	(pole.mesh as CylinderMesh).top_radius = 0.07
	(pole.mesh as CylinderMesh).bottom_radius = 0.09
	(pole.mesh as CylinderMesh).height = 5.0
	pole.position.y = 2.5
	root.add_child(pole)
	var cloth: MeshInstance3D = _box(Vector3(1.3, 2.6, 0.06), _material(tint, 0.85))
	cloth.position = Vector3(0.7, 3.6, 0)
	root.add_child(cloth)
	var stripe: MeshInstance3D = _box(Vector3(1.3, 0.3, 0.07), _material(Color(0.05, 0.05, 0.06), 0.8))
	stripe.position = Vector3(0.7, 3.6, 0)
	root.add_child(stripe)
	var label: Label3D = Label3D.new()
	label.text = text.to_upper()
	label.font = UIStyle.font_title()
	label.font_size = 26
	label.pixel_size = 0.0075
	label.modulate = Color(0.96, 0.92, 0.8)
	label.outline_size = 0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.width = 150.0
	label.position = Vector3(0.7, 2.7, 0.05)
	root.add_child(label)
	return root


static func _bunting(tint: Color) -> Node3D:
	var root: Node3D = Node3D.new()
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


static func _plaque(text: String, pos: Vector3) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font = UIStyle.font_title()
	label.font_size = 28
	label.pixel_size = 0.0058
	label.modulate = Color(0.96, 0.92, 0.8)
	label.outline_size = 8
	label.outline_modulate = Color(0.05, 0.05, 0.06, 0.95)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.width = 380.0
	label.position = pos
	return label


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
