extends TownScene
## Painted ground-texture test (docs/art/texture_test.md). The real town (built in code, so this scene extends it) with a hand-painted ground laid over the grass: grass base,
## wildflower patches from soft noise masks, stone for the central plaza. T switches between it and the current flat ground. Buildings, props and characters are untouched,
## the real scenes are untouched and the real save is never written.
## Open tests/textures/town_square_textured.tscn in the editor and press F6, or: godot --path . res://tests/textures/town_square_textured.tscn
## Screenshot args (tools/shot.sh): --tex=1|0 (default 1), --zoom=1.0..2.3 (camera distance, default 1.5), plus the town's own --cam, --pos, --at, --nohud, --open.

const SHADER_PATH: String = "res://assets/shaders/style_painted_ground.gdshader"
const TEXTURES: String = "res://assets/art/textures/"
const AREA_RADIUS: float = 34.0
const CELL: float = 1.0
## Just above the hex tiles, under the road paving decals (GroundDecals.LIFT 0.025 + 0.001 and up).
const HEIGHT: float = GroundDecals.LIFT + 0.0006
const DISC_VERTEX_COUNT: int = 29

var textured: bool = true
var _ground: MeshInstance3D
## The flat ground's own overlays (moss patches and the plaza's paving discs): hidden while the painted ground is shown.
var _flat_overlays: Array[MeshInstance3D] = []


func _init() -> void:
	# This test scene must never overwrite the player's real save.
	Session.save_enabled = false


func screenshot_prepare(args: Dictionary) -> void:
	super.screenshot_prepare(args)
	if args.has("zoom"):
		Settings.camera_zoom = clampf(float(args["zoom"]), Settings.ZOOM_MIN, Settings.ZOOM_MAX)


func _ready() -> void:
	super._ready()
	textured = str(_screenshot_args.get("tex", "1")) != "0"
	_collect_flat_overlays()
	_ground = _build_ground()
	add_child(_ground)
	_apply_mode()


func _material() -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(SHADER_PATH) as Shader
	# Drawn before the road/crest decals (they are transparent and do not write depth), so they stay on top of it.
	material.render_priority = -100
	for layer: String in ["grass", "wildflower", "stone"]:
		var key: String = "flower" if layer == "wildflower" else layer
		material.set_shader_parameter("%s_albedo" % key, load("%stown_%s_albedo.webp" % [TEXTURES, layer]))
		material.set_shader_parameter("%s_normal" % key, load("%stown_%s_normal.webp" % [TEXTURES, layer]))
		material.set_shader_parameter("%s_rough" % key, load("%stown_%s_rough.webp" % [TEXTURES, layer]))
	material.set_shader_parameter("plaza_center", Vector2(TownLayout.PLAZA.x, TownLayout.PLAZA.z))
	material.set_shader_parameter("plaza_radius", TownLayout.PLAZA_RADIUS)
	material.set_shader_parameter("fade_start", AREA_RADIUS - 8.0)
	material.set_shader_parameter("fade_end", AREA_RADIUS)
	return material


## A grid of 1 m squares over the town's walkable ground (a square is kept only when all four corners and its centre are on the island, so it never hangs over water).
func _build_ground() -> MeshInstance3D:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var origin: Vector3 = TownLayout.PLAZA
	var steps: int = int(ceil(AREA_RADIUS / CELL))
	for iz: int in range(-steps, steps):
		for ix: int in range(-steps, steps):
			var x0: float = origin.x + float(ix) * CELL
			var z0: float = origin.z + float(iz) * CELL
			if Vector2(x0 + CELL * 0.5 - origin.x, z0 + CELL * 0.5 - origin.z).length() > AREA_RADIUS:
				continue
			var inside: bool = true
			for point: Vector2 in [Vector2(0.5, 0.5), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]:
				if not town.is_floor_at(Vector3(x0 + point.x * CELL, 0.0, z0 + point.y * CELL)):
					inside = false
					break
			if not inside:
				continue
			var base: int = vertices.size()
			vertices.append(Vector3(x0, 0.0, z0))
			vertices.append(Vector3(x0 + CELL, 0.0, z0))
			vertices.append(Vector3(x0 + CELL, 0.0, z0 + CELL))
			vertices.append(Vector3(x0, 0.0, z0 + CELL))
			for i: int in range(4):
				normals.append(Vector3.UP)
			indices.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "PaintedGround"
	instance.mesh = mesh
	instance.material_override = _material()
	instance.position = Vector3(0.0, HEIGHT, 0.0)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	return instance


## Flat-ground overlays hidden while the painted ground shows: the moss patches (TownSquare's and ZoneDressing's) and the plaza's three paving discs (TownStreets).
## All are 28-segment fans (29 vertices); road ribbons, the royal crest and other decals stay in both modes.
func _collect_flat_overlays() -> void:
	var roots: Array[Node] = [square.root, square.streets.root, get_node_or_null("ZoneDressing")]
	for parent: Node in roots:
		if parent == null:
			continue
		for child: Node in parent.get_children():
			var instance: MeshInstance3D = child as MeshInstance3D
			if instance == null or not instance.material_override is ShaderMaterial or not instance.mesh is ArrayMesh:
				continue
			var arrays: Array = (instance.mesh as ArrayMesh).surface_get_arrays(0)
			if (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() != DISC_VERTEX_COUNT:
				continue
			var is_moss: bool = int((instance.material_override as ShaderMaterial).get_shader_parameter("pattern")) == int(GroundDecals.Pattern.MOSS)
			var at_plaza: bool = Vector2(instance.position.x - TownLayout.PLAZA.x, instance.position.z - TownLayout.PLAZA.z).length() < 0.5
			if is_moss or (parent == square.streets.root and at_plaza):
				_flat_overlays.append(instance)
	print("texture test: %d flat overlays toggled" % _flat_overlays.size())


func _apply_mode() -> void:
	_ground.visible = textured
	for overlay: MeshInstance3D in _flat_overlays:
		overlay.visible = not textured


func toggle_ground() -> void:
	textured = not textured
	_apply_mode()
	if hud != null:
		hud.toast("Painted ground" if textured else "Flat ground (current)", UIStyle.GOLD)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_T and not _locked:
		get_viewport().set_input_as_handled()
		toggle_ground()
		return
	super._unhandled_input(event)
