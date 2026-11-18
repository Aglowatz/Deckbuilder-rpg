class_name BuffetForestLife
extends Node3D
## Fable Nov 16b (Part 5): what makes the Buffet's east forest feel alive - steam drifting up between the trees, a few butterflies over
## its near edge and birds circling above it, and warm patches of light on the forest floor. (The leaves sway by themselves: the tree
## cards' shader.) Built on Medium and High only (`BuffetShore.alive`); nothing here blocks, casts a shadow or can be touched.

const BUTTERFLIES: int = 9
const BIRDS: int = 4
const WING_COLORS: Array[Color] = [Color("ffd27a"), Color("ff9db0"), Color("fff1c4"), Color("ffb36b"), Color("c9f2a0")]

var steam_count: int = 0
var patch_count: int = 0
var _wings: MultiMesh
## Batch 17 (Nov 18): the painted fliers (BUFF-SHEET-FLIERS: four butterfly frames over four bird frames), one camera-facing sprite per
## flier stepping through its frames; the dot wings are the fallback. Off on Low-end (nothing flies there).
const FLIER_SHEET: String = "res://assets/art/zone_kits/buffet/BUFF-SHEET-FLIERS.webp"
var _sprites: Array[Sprite3D] = []
var _time: float = 0.0
## Per flier: [home (Vector3), radius, speed, phase, height swing, is a bird].
var _fliers: Array[Array] = []
var _patches: Array[MeshInstance3D] = []


static func build(parent: Node3D, shore: BuffetShore) -> BuffetForestLife:
	var life: BuffetForestLife = BuffetForestLife.new()
	life.name = "ForestLife"
	parent.add_child(life)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 2611
	life._build_steam(shore, rng)
	life._build_patches(shore, rng)
	life._build_fliers(shore, rng)
	return life


## A spot on the forest's land between `near` and `far` metres from the table, on the stretch beside the playable area.
func _spot(shore: BuffetShore, rng: RandomNumberGenerator, near: float, far: float) -> Vector3:
	for _try: int in range(60):
		var x: float = rng.randf_range(97.0, 97.0 + far)
		var z: float = rng.randf_range(4.0, 92.0)
		var away: float = BuffetShore.from_table(x, z)
		if away >= near and away <= far and BuffetShore.on_land(x, z) and absf(z - BuffetLayout.river_z(x)) > BuffetShore.CHANNEL_HALF + 1.0:
			return Vector3(x, shore.land_y(), z)
	return Vector3(104.0, shore.land_y(), 24.0)


func _build_steam(shore: BuffetShore, rng: RandomNumberGenerator) -> void:
	for _index: int in range(BuffetShore.STEAM_SPOTS):
		var at: Vector3 = _spot(shore, rng, 5.0, 38.0)
		var puff: CPUParticles3D = BuffetProps.steam(self, at + Vector3(0.0, rng.randf_range(2.6, 4.4), 0.0), 7, 1.5, 0.9)
		puff.lifetime = 4.5
		puff.preprocess = 4.5
		puff.scale_amount_min = 1.4
		puff.scale_amount_max = 2.8
		# a slow drift sideways with the dinner-hour breeze
		puff.gravity = Vector3(0.25, 0.0, -0.08)
		puff.set_meta(&"no_range_cull", true)
		steam_count += 1


## Warm light on the forest floor: soft additive discs lying on the ground, breathing slowly.
func _build_patches(shore: BuffetShore, rng: RandomNumberGenerator) -> void:
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 0.86, 0.52, 0.5))
	gradient.set_color(1, Color(1.0, 0.86, 0.52, 0.0))
	var disc: GradientTexture2D = GradientTexture2D.new()
	disc.gradient = gradient
	disc.fill = GradientTexture2D.FILL_RADIAL
	disc.fill_from = Vector2(0.5, 0.5)
	disc.fill_to = Vector2(1.0, 0.5)
	disc.width = 64
	disc.height = 64
	for _index: int in range(BuffetShore.LIGHT_PATCHES):
		var at: Vector3 = _spot(shore, rng, 0.8, 16.0)
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		material.albedo_texture = disc
		material.albedo_color = Color(1.0, 1.0, 1.0, 0.5)
		material.no_depth_test = false
		var quad: PlaneMesh = PlaneMesh.new()
		quad.size = Vector2.ONE * rng.randf_range(3.0, 6.5)
		var patch: MeshInstance3D = MeshInstance3D.new()
		patch.name = "LightPatch"
		patch.mesh = quad
		patch.material_override = material
		patch.position = at + Vector3(0.0, 0.07, 0.0)
		patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		patch.set_meta(StyleToon.META_NO_TOON, true)
		patch.set_meta(PaintedClasses.META_NO_PAINT, true)
		patch.set_meta(&"no_occlusion_fade", true)
		patch.set_meta(&"phase", rng.randf() * TAU)
		add_child(patch)
		_patches.append(patch)
		patch_count += 1


## Butterflies and birds: every wing is one instance of one MultiMesh (one draw call), moved each frame.
func _build_fliers(shore: BuffetShore, rng: RandomNumberGenerator) -> void:
	if ResourceLoader.exists(FLIER_SHEET):
		_build_painted_fliers(shore, rng)
		return
	var wing: QuadMesh = QuadMesh.new()
	wing.size = Vector2.ONE
	wing.center_offset = Vector3(0.5, 0.0, 0.0)  # hinged at its inner edge
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = UIStyle.circle_texture(32, Color.WHITE)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.alpha_scissor_threshold = 0.5
	wing.surface_set_material(0, material)
	_wings = MultiMesh.new()
	_wings.transform_format = MultiMesh.TRANSFORM_3D
	_wings.use_colors = true
	_wings.mesh = wing
	_wings.instance_count = (BUTTERFLIES + BIRDS) * 2
	for index: int in range(BUTTERFLIES + BIRDS):
		var bird: bool = index >= BUTTERFLIES
		var home: Vector3 = _spot(shore, rng, 4.0 if bird else 0.8, 40.0 if bird else 7.0)
		home.y += rng.randf_range(9.0, 15.0) if bird else rng.randf_range(0.7, 2.2)
		_fliers.append([home, rng.randf_range(7.0, 15.0) if bird else rng.randf_range(0.8, 2.4), (rng.randf_range(0.25, 0.4) if bird else rng.randf_range(0.5, 1.1)) * (1.0 if rng.randf() < 0.5 else -1.0), rng.randf() * TAU, rng.randf_range(0.2, 0.7), bird])
		var color: Color = Color(0.2, 0.16, 0.14) if bird else WING_COLORS[index % WING_COLORS.size()]
		_wings.set_instance_color(index * 2, color)
		_wings.set_instance_color(index * 2 + 1, color)
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "Fliers"
	instance.multimesh = _wings
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.custom_aabb = AABB(Vector3(90.0, -2.0, -10.0), Vector3(80.0, 26.0, 120.0))
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	add_child(instance)
	_place_fliers()


func _build_painted_fliers(shore: BuffetShore, rng: RandomNumberGenerator) -> void:
	var sheet: Texture2D = load(FLIER_SHEET) as Texture2D
	var holder: Node3D = Node3D.new()
	holder.name = "Fliers"
	holder.visible = not GraphicsQuality.low_end
	add_child(holder)
	for index: int in range(BUTTERFLIES + BIRDS):
		var bird: bool = index >= BUTTERFLIES
		var home: Vector3 = _spot(shore, rng, 4.0 if bird else 0.8, 40.0 if bird else 7.0)
		home.y += rng.randf_range(9.0, 15.0) if bird else rng.randf_range(0.7, 2.2)
		_fliers.append([home, rng.randf_range(7.0, 15.0) if bird else rng.randf_range(0.8, 2.4), (rng.randf_range(0.25, 0.4) if bird else rng.randf_range(0.5, 1.1)) * (1.0 if rng.randf() < 0.5 else -1.0), rng.randf() * TAU, rng.randf_range(0.2, 0.7), bird])
		var sprite: Sprite3D = Sprite3D.new()
		sprite.name = "Bird" if bird else "Butterfly"
		sprite.texture = sheet
		sprite.hframes = 4
		sprite.vframes = 2
		sprite.frame = 4 if bird else 0
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.shaded = false
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		sprite.pixel_size = (1.3 if bird else 0.42) / (float(sheet.get_width()) / 4.0)
		sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		sprite.set_meta(StyleToon.META_NO_TOON, true)
		sprite.set_meta(PaintedClasses.META_NO_PAINT, true)
		sprite.set_meta(&"no_occlusion_fade", true)
		sprite.set_meta(&"no_range_cull", true)
		holder.add_child(sprite)
		_sprites.append(sprite)
	_place_fliers()


func _process(delta: float) -> void:
	_time += delta
	_place_fliers()
	for patch: MeshInstance3D in _patches:
		var material: StandardMaterial3D = patch.material_override as StandardMaterial3D
		material.albedo_color.a = 0.34 + 0.18 * sin(_time * 0.5 + float(patch.get_meta(&"phase")))


## Where flier `index` is right now: a butterfly wanders in a loose figure of eight round its home, a bird circles.
func flier_at(index: int) -> Vector3:
	var flier: Array = _fliers[index]
	var home: Vector3 = flier[0] as Vector3
	var radius: float = float(flier[1])
	var bird: bool = bool(flier[5])
	var angle: float = _time * float(flier[2]) + float(flier[3])
	return home + Vector3(cos(angle) * radius, sin(angle * (1.3 if bird else 2.7)) * float(flier[4]), sin(angle * (1.0 if bird else 2.0)) * radius * (1.0 if bird else 0.6))


func flier_count() -> int:
	return _fliers.size()


func _place_fliers() -> void:
	if not _sprites.is_empty():
		if not (_sprites[0].get_parent() as Node3D).visible:
			return
		for index: int in range(_sprites.size()):
			var bird_sprite: bool = bool(_fliers[index][5])
			_sprites[index].position = flier_at(index)
			var step: int = int(_time * (7.0 if bird_sprite else 12.0) + float(_fliers[index][3]) * 3.0) % 4
			_sprites[index].frame = (4 if bird_sprite else 0) + step
		return
	if _wings == null:
		return
	for index: int in range(_fliers.size()):
		var flier: Array = _fliers[index]
		var bird: bool = bool(flier[5])
		var angle: float = _time * float(flier[2]) + float(flier[3])
		var at: Vector3 = flier_at(index)
		var heading: float = atan2(-sin(angle) * signf(float(flier[2])), cos(angle) * signf(float(flier[2])))
		var flap: float = sin(_time * (5.5 if bird else 17.0) + float(flier[3]) * 3.0) * (0.7 if bird else 1.05)
		var span: float = 0.62 if bird else 0.17
		var chord: float = 0.2 if bird else 0.2
		var body: Basis = Basis(Vector3.UP, heading)
		for side: int in range(2):
			var sign_value: float = 1.0 if side == 0 else -1.0
			# the wing lies flat (x = out from the body, y = along it), lifted about the body's axis by the flap
			var wing_basis: Basis = body * Basis(Vector3.FORWARD, flap * sign_value) * Basis(Vector3(sign_value * span, 0.0, 0.0), Vector3(0.0, 0.0, -chord), Vector3(0.0, 1.0, 0.0))
			_wings.set_instance_transform(index * 2 + side, Transform3D(wing_basis, at))
