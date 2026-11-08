class_name LeverKit
extends RefCounted
## Brief 16, Group G: the hidden vault levers in the four Path zones, and (Import Nov 8) Crosspath's old lever by the Secluded Grove.
## Import Nov 8 (Batch 13): a painted lever - LEVER-LOCKED (handle up, padlocked) and LEVER-OPEN (handle thrown down, a warm glow) - stands as
## two camera-facing cards about 0.95 m tall; pulling it swaps the cards inside a short squash-and-settle tween. The plain enamel badge on the
## plinth is tinted in the Path's colour (a per-colour copy of the art). Without the art the old code box stands in: a base, an upright slot and
## a heavy `Handle` with a coloured knob that swings down. No marker, plate or glow: the zone scene only shows the [E] prompt within a metre or so.

const HANDLE_UP_DEGREES: float = -55.0
const HANDLE_DOWN_DEGREES: float = 55.0
const PROMPT_RADIUS: float = 1.5

const ART_LOCKED: String = "LEVER-LOCKED"
const ART_OPEN: String = "LEVER-OPEN"
## The painted lever's height (storybook scale: about half the hero's 1.7 m). Both states are drawn on one 1024 px canvas with the plinth in the same
## place, but the importer trims each to its own pixels (handle up: 644 x 1015; handle down: 778 x 711), so each card gets its own height and a
## small sideways shift to keep the plinth exactly where it was (the plinth's centre is x 513 of the canvas).
const ART_HEIGHT: float = 0.95
## Per state: card height (metres), sideways shift (metres), the enamel badge's centre (fraction of the trimmed image) and radius (of its height).
const STATE_ART: Dictionary = {
	"LEVER-LOCKED": {"height": 0.95, "shift": 0.006, "badge": Vector2(0.346, 0.740), "radius": 0.079},
	"LEVER-OPEN": {"height": 0.6655, "shift": 0.039, "badge": Vector2(0.328, 0.626), "radius": 0.1125},
}
## Crosspath's old lever has no Path: a warm brass badge.
const NEUTRAL_BADGE: Color = Color("d9b26a")

static var _tinted: Dictionary = {}


## True when both painted states are imported.
static func has_art() -> bool:
	return EnvKit.has(ART_LOCKED) and EnvKit.has_art(ART_LOCKED) and EnvKit.has(ART_OPEN) and EnvKit.has_art(ART_OPEN)


## A lever in the colour of its Path (the painted badge, or the box's knob and gem). `painted` false forces the code box (tests).
static func build(path_color: Color, painted: bool = true) -> Node3D:
	if painted and has_art():
		return _build_painted(path_color)
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


static func _build_painted(path_color: Color) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "VaultLever"
	root.set_meta(&"painted", true)
	root.set_meta(&"no_wind", true)
	for state: Array in [[ART_LOCKED, "Locked"], [ART_OPEN, "Open"]]:
		var spec: Dictionary = STATE_ART.get(str(state[0]), {}) as Dictionary
		var card: Node3D = ZoneClusters.card_prop(str(state[0]), float(spec.get("height", ART_HEIGHT)), true)
		if card == null:
			continue
		card.name = str(state[1])
		card.position.x = float(spec.get("shift", 0.0))
		var body: MeshInstance3D = card.get_node_or_null("Body") as MeshInstance3D
		var tinted: Texture2D = badge_texture(str(state[0]), path_color)
		if body != null and tinted != null and body.material_override is ShaderMaterial:
			var material: ShaderMaterial = (body.material_override as ShaderMaterial).duplicate() as ShaderMaterial
			material.set_shader_parameter("card_tex", tinted)
			body.material_override = material
		root.add_child(card)
	var open: Node3D = root.get_node_or_null("Open") as Node3D
	if open != null:
		open.visible = false
	return root


## The painted lever `id` with its enamel badge tinted `tint` (cached per id and colour). The enamel is the pale, unsaturated paint inside the
## badge circle; the copper rim, rivets and stone keep their colours, and the enamel keeps its painted shading.
static func badge_texture(id: String, tint: Color) -> Texture2D:
	var key: String = "%s|%s" % [id, tint.to_html(false)]
	if _tinted.has(key):
		return _tinted[key] as Texture2D
	var source: Texture2D = EnvKit.texture(id)
	if source == null:
		return null
	var image: Image = source.get_image()
	if image == null or image.is_empty():
		return source
	if image.is_compressed():
		image.decompress()
	image.clear_mipmaps()
	image.convert(Image.FORMAT_RGBA8)
	var size: Vector2 = Vector2(image.get_width(), image.get_height())
	var spec: Dictionary = STATE_ART.get(id, {}) as Dictionary
	var centre: Vector2 = (spec.get("badge", Vector2(0.34, 0.7)) as Vector2) * size
	var radius: float = float(spec.get("radius", 0.08)) * size.y
	var x0: int = maxi(0, int(centre.x - radius))
	var x1: int = mini(image.get_width() - 1, int(centre.x + radius))
	var y0: int = maxi(0, int(centre.y - radius))
	var y1: int = mini(image.get_height() - 1, int(centre.y + radius))
	for y: int in range(y0, y1 + 1):
		for x: int in range(x0, x1 + 1):
			if Vector2(x, y).distance_to(centre) > radius:
				continue
			var c: Color = image.get_pixel(x, y)
			if c.a < 0.5 or c.s > 0.3 or c.v < 0.5:
				continue
			var shade: float = clampf(c.v * 1.05, 0.0, 1.0)
			image.set_pixel(x, y, Color(tint.r * shade, tint.g * shade, tint.b * shade, c.a).lerp(c, 0.18))
	image.generate_mipmaps()
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_tinted[key] = texture
	return texture


static func handle_of(lever: Node3D) -> Node3D:
	return lever.get_node_or_null("Handle") as Node3D if lever != null else null


static func is_painted(lever: Node3D) -> bool:
	return lever != null and bool(lever.get_meta(&"painted", false))


static func is_pulled(lever: Node3D) -> bool:
	return lever != null and bool(lever.get_meta(&"pulled", false))


## Snaps the lever up (not pulled) or down (pulled).
static func set_pulled(lever: Node3D, pulled: bool) -> void:
	if lever == null:
		return
	lever.set_meta(&"pulled", pulled)
	if is_painted(lever):
		_show_state(lever, pulled)
		return
	var handle: Node3D = handle_of(lever)
	if handle != null:
		handle.rotation_degrees.z = HANDLE_DOWN_DEGREES if pulled else HANDLE_UP_DEGREES


static func _show_state(lever: Node3D, pulled: bool) -> void:
	if not is_instance_valid(lever):
		return
	var locked: Node3D = lever.get_node_or_null("Locked") as Node3D
	var open: Node3D = lever.get_node_or_null("Open") as Node3D
	if locked != null:
		locked.visible = not pulled
	if open != null:
		open.visible = pulled


## Pulls the lever (state recorded at once); returns the tween. Painted: a quick squash as the handle is thrown, the open card swaps in at the
## bottom of it, then a springy settle. Box: the handle swings down with a little overshoot.
static func pull_animated(lever: Node3D) -> Tween:
	if lever == null:
		return null
	lever.set_meta(&"pulled", true)
	if is_painted(lever):
		var tween: Tween = lever.create_tween()
		tween.tween_property(lever, "scale", Vector3(1.07, 0.88, 1.07), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(_show_state.bind(lever, true))
		tween.tween_property(lever, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		return tween
	var handle: Node3D = handle_of(lever)
	if handle == null:
		return null
	var swing: Tween = handle.create_tween()
	swing.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	swing.tween_property(handle, "rotation_degrees:z", HANDLE_DOWN_DEGREES, 0.45)
	return swing
