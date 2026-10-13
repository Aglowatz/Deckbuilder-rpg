class_name WorldSprite
extends Node3D
## A painted 2.5D character standing in the 3D world (docs/art/world_look_test.md, docs/art/world_rollout.md): an upright camera-facing card that picks one of eight drawn
## directions from where its body points relative to the camera, walks with a four-frame cycle paced by its speed, breathes when still, and is lit, rim-lit and shadowed by
## the scene. Art: five drawn directions (FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK; the art looks LEFT, the other side is mirrored). NPCs may have only FRONT / SIDE / BACK.
##
## Use: `setup("PLAYER", camera, sun)`, then every frame `follow(world_pos, delta)` (movers) and `look_toward(direction)` (standing characters); `talking = true` shows the
## TALK pose when the character has one. A sprite that is a child of the thing that moves (`SpriteActor`) sets `local_mode` and calls `follow_parent(delta)`.
##
## Cosmetics: `set_character("PLAYER_CLOAK_<NAME>")` swaps the whole sprite set (a cloak), `set_hat("<NAME>")` lays a hat card on the head (placed from the head anchor of
## the current frame, so it follows the head through every walk and idle frame, mirrored with the body), `set_dye(color)` recolours the cloak by hue.

const SHADER: String = "res://world/sprites/world_sprite.gdshader"
const SHADOW_SHADER: String = "res://world/sprites/world_sprite_shadow.gdshader"
## World height of a character whose relative height is 1.0 (the player), in metres.
const PLAYER_HEIGHT: float = 1.25
## One full walk cycle (two steps) covers this many character heights.
const STRIDE_HEIGHTS: float = 1.5
const MAX_CYCLES_PER_SECOND: float = 3.2
const MOVING_SPEED: float = 0.35
## The direction names and the angle (degrees from facing the camera) each is drawn at.
const DIR_ANGLES: Dictionary = {"FRONT": 0.0, "FRONTSIDE": 45.0, "SIDE": 90.0, "BACKSIDE": 135.0, "BACK": 180.0}
## How far in front of the body card (towards the camera, metres) a hat card is drawn.
const HAT_NUDGE: float = 0.03

var character: String = ""
var camera: Camera3D
## World direction the body points (unit, on the ground).
var heading: Vector3 = Vector3(0.0, 0.0, 1.0)
var talking: bool = false
var world_height: float = 1.0
## What the last update chose, for tests and the HUD.
var current_dir: String = "FRONT"
var current_key: String = "FRONT_IDLE"
var current_flip: bool = false
var walking: bool = false
var speed: float = 0.0
## How fast the body swings round towards its target heading.
var turn_rate_degrees: float = 540.0
## True for a sprite that is a child of the thing that moves (a `SpriteActor`): its position stays local and the speed is measured on the parent.
var local_mode: bool = false
## Tumble about the body's middle (radians), set by effects that spin the character.
var roll_radians: float = 0.0
## Where the hat card sits relative to the feet, as the last update placed it (for tests): Rect2(left, bottom, width, height) in metres.
var hat_rect: Rect2 = Rect2()
var hat_visible: bool = false

var _info: Dictionary = {}
var _dirs: Array[String] = []
var _walk_dirs: Array[String] = []
var _mesh: MeshInstance3D
var _material: ShaderMaterial
var _shadow_material: ShaderMaterial
var _blob: MeshInstance3D
var _target_heading: Vector3 = Vector3(0.0, 0.0, 1.0)
var _phase: float = 0.0
var _time: float = 0.0
var _seed: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO
var _have_last: bool = false
var _canvas_world: Vector2 = Vector2.ONE
var _canvas_px: Vector2 = Vector2.ONE
var _px_to_world: float = 0.003
var _bottom_pad: float = 16.0
var _feet_lift: float = 0.0
var _hat_mesh: MeshInstance3D
var _hat_material: ShaderMaterial
var _hat_art: String = ""
var _dye_color: Color = Color.WHITE
var _dye_amount: float = 0.0
var _body_scale: Vector2 = Vector2.ONE
var _sun_world: Vector3 = Vector3(-0.42, 0.62, 0.67)
var _sun_known: bool = false
var _bob: float = 0.0
var _tint: Color = Color.WHITE
var _hover: float = 0.0
var _hover_amplitude: float = 0.0


func setup(character_id: String, cam: Camera3D, sun_direction: Vector3 = Vector3.ZERO) -> bool:
	camera = cam
	_seed = randf() * 10.0
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	_material = ShaderMaterial.new()
	_material.shader = load(SHADER) as Shader
	_shadow_material = ShaderMaterial.new()
	_shadow_material.shader = load(SHADOW_SHADER) as Shader
	_material.next_pass = _shadow_material
	if not _load_character(character_id):
		return false
	set_sun(sun_direction)
	_sun_known = sun_direction.length() > 0.01
	_mesh = MeshInstance3D.new()
	_mesh.mesh = quad
	_mesh.material_override = _material
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh.set_meta(StyleToon.META_NO_TOON, true)
	_mesh.set_meta(&"no_occlusion_fade", true)
	_mesh.extra_cull_margin = 4.0
	add_child(_mesh)
	_blob = ContactShadow.attach(self, 0.3 * world_height)
	_apply("FRONT_IDLE", false)
	return true


## Reads the character's manifest entry into the sprite (canvas, direction lists, size). False when the character is unknown.
func _load_character(character_id: String) -> bool:
	var entry: Dictionary = SpriteLibrary.info(character_id)
	if entry.is_empty():
		return false
	character = character_id
	_info = entry
	_dirs.clear()
	_walk_dirs.clear()
	for dir_name: Variant in _info["dirs"] as Array:
		_dirs.append(str(dir_name))
	for dir_name: Variant in _info["walk_dirs"] as Array:
		_walk_dirs.append(str(dir_name))
	var canvas: Array = _info["canvas"] as Array
	var fig_h: float = float(_info["fig_h"])
	world_height = float(_info["rel_height"]) * PLAYER_HEIGHT
	_px_to_world = world_height / fig_h
	_canvas_px = Vector2(float(canvas[0]), float(canvas[1]))
	_canvas_world = _canvas_px * _px_to_world
	_bottom_pad = float(_info["bottom_pad"])
	_feet_lift = _bottom_pad * _px_to_world
	for target: ShaderMaterial in [_material, _shadow_material]:
		target.set_shader_parameter("card_size", _canvas_world)
		target.set_shader_parameter("feet_lift", _feet_lift)
	_material.set_shader_parameter("pivot_y", world_height * 0.5)
	var hue: Array = SpriteLibrary.cloak_hue(character_id)
	if hue.size() == 2:
		_material.set_shader_parameter("dye_hue", float(hue[0]))
		_material.set_shader_parameter("dye_width", float(hue[1]))
	return true


## Swaps the whole sprite set (a cloak is a full alternate set). Unknown characters are ignored; frames the set lacks fall back to the default hero's.
func set_character(character_id: String) -> bool:
	if character_id == character or _material == null:
		return false
	var previous: String = character
	if not _load_character(character_id):
		character = previous
		return false
	_apply(current_key, current_flip)
	return true


# ---- Cosmetics -------------------------------------------------------------------------------------------------------------------


## Puts the hat `art_name` (COS-HAT-<NAME>) on the head; "" takes it off. A hat whose art is not imported is silently left off.
func set_hat(art_name: String) -> void:
	_hat_art = art_name if art_name != "" and SpriteLibrary.has_hat(art_name) else ""
	if _hat_art != "" and _hat_mesh == null and _material != null:
		_build_hat_card()
	hat_visible = false
	if _hat_mesh != null:
		_hat_mesh.visible = false
	_update_hat()


func hat_name() -> String:
	return _hat_art


## Recolours the cloak to `color` (the shader finds the cloak by its hue); `amount` 0 = natural colours.
func set_dye(color: Color, amount: float = 1.0) -> void:
	_dye_color = color
	_dye_amount = amount
	if _material != null:
		_material.set_shader_parameter("dye_color", color)
		_material.set_shader_parameter("dye_amount", amount)


func _build_hat_card() -> void:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	_hat_material = ShaderMaterial.new()
	_hat_material.shader = load(SHADER) as Shader
	_hat_material.set_shader_parameter("feet_lift", 0.0)
	_hat_material.set_shader_parameter("depth_nudge", HAT_NUDGE)
	_hat_material.set_shader_parameter("pivot_y", world_height * 0.5)
	_hat_mesh = MeshInstance3D.new()
	_hat_mesh.name = "Hat"
	_hat_mesh.mesh = quad
	_hat_mesh.material_override = _hat_material
	_hat_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_hat_mesh.set_meta(StyleToon.META_NO_TOON, true)
	_hat_mesh.set_meta(&"no_occlusion_fade", true)
	_hat_mesh.extra_cull_margin = 4.0
	_hat_mesh.visible = false
	add_child(_hat_mesh)


## Places the hat card for the frame that is showing: the head anchor of this frame (the same frame key of the default hero when the cloak set has none) turned into
## metres from the feet, the hat sized from the head's width, mirrored with the body.
func _update_hat() -> void:
	if _hat_mesh == null or _hat_art == "":
		hat_visible = false
		if _hat_mesh != null:
			_hat_mesh.visible = false
		return
	var dir_name: String = current_key.get_slice("_", 0)
	var texture: Texture2D = SpriteLibrary.hat_texture(_hat_art, dir_name)
	var head: Array = SpriteLibrary.head_anchor(character, current_key)
	if head.is_empty():
		head = SpriteLibrary.head_anchor("PLAYER", current_key)
	if texture == null or head.size() < 3:
		hat_visible = false
		_hat_mesh.visible = false
		return
	var fit: Dictionary = SpriteLibrary.hat_fit(_hat_art, dir_name)
	var head_w: float = float(head[2]) * _px_to_world
	var width: float = head_w * float(fit["width"]) * float(fit["scale"])
	var height: float = width * float(texture.get_height()) / float(texture.get_width())
	var x: float = (float(head[0]) - _canvas_px.x * 0.5) * _px_to_world + float(fit["dx"]) * head_w
	var y: float = (_canvas_px.y - _bottom_pad - float(head[1])) * _px_to_world - float(fit["sink"]) * head_w + float(fit["dy"]) * head_w
	if current_flip:
		x = -x
	hat_rect = Rect2(x - width * 0.5, y, width, height)
	hat_visible = true
	_hat_mesh.visible = true
	_hat_material.set_shader_parameter("tex", texture)
	_hat_material.set_shader_parameter("flip_h", current_flip)
	_hat_material.set_shader_parameter("card_size", Vector2(width, height))
	_hat_material.set_shader_parameter("offset", Vector2(x, y))


# ---- Light and motion ----------------------------------------------------------------------------------------------------------


## `sun_direction` is the direction the light travels (the light node's forward). Sets the rim side and the ground shadow's length and direction.
func set_sun(sun_direction: Vector3) -> void:
	if _material == null:
		return
	var d: Vector3 = sun_direction.normalized() if sun_direction.length() > 0.01 else Vector3(0.42, -0.62, -0.67).normalized()
	var horizontal: Vector2 = Vector2(d.x, d.z)
	var elevation_tan: float = maxf(-d.y, 0.2) / maxf(horizontal.length(), 0.05)
	var ground: Vector2 = horizontal.normalized() * minf(1.0 / elevation_tan, 2.2)
	_shadow_material.set_shader_parameter("shadow_ground", ground)
	_sun_world = -d


## Where the card's feet are (the node position without the walking bob).
func feet_position() -> Vector3:
	return position - Vector3(0.0, _bob, 0.0)


## For a character that moves: called every frame with its world position. The body turns towards the direction of travel; speed comes from the position change.
func follow(world_pos: Vector3, delta: float) -> void:
	var moved: Vector3 = (world_pos - _last_pos) if _have_last else Vector3.ZERO
	_last_pos = world_pos
	_have_last = true
	moved.y = 0.0
	speed = moved.length() / maxf(delta, 0.0001)
	if speed > MOVING_SPEED:
		_target_heading = moved.normalized()
	_update(world_pos, delta)


## `follow` for a sprite that is a child of the mover: its world position is its parent's.
func follow_parent(delta: float) -> void:
	var parent: Node3D = get_parent() as Node3D
	if parent == null:
		return
	follow(parent.global_position, delta)


## For a character standing in place: the direction its body should turn towards.
func look_toward(direction: Vector3) -> void:
	direction.y = 0.0
	if direction.length() > 0.01:
		_target_heading = direction.normalized()


## Jumps the body to face `direction` immediately (spawning, teleporting) and forgets the last position so no phantom speed is measured.
func snap_heading(direction: Vector3) -> void:
	direction.y = 0.0
	if direction.length() > 0.01:
		heading = direction.normalized()
		_target_heading = heading
	_have_last = false


## Squash / stretch from the thing the sprite stands in for (a bounce pad's squash, a shrink): 1 = natural.
func set_body_scale(factor: Vector2) -> void:
	_body_scale = factor


func _update(world_pos: Vector3, delta: float) -> void:
	# The scene's own sun (the style rig puts its key light in the group `style_sun`), found once the sprite is in the tree.
	if not _sun_known and is_inside_tree():
		var sun: Node = get_tree().get_first_node_in_group(&"style_sun")
		if sun is DirectionalLight3D:
			set_sun(-(sun as DirectionalLight3D).global_basis.z)
			_sun_known = true
	if camera == null:
		camera = get_viewport().get_camera_3d() if is_inside_tree() else null
		if camera == null:
			return
	_time += delta
	_turn(delta)
	var best: String = _choose_direction()
	var moving: bool = speed > MOVING_SPEED and _walk_dirs.has(best)
	walking = moving
	var key: String
	if talking and _info.get("has_talk", false):
		best = "FRONT"
		key = "FRONT_TALK"
		current_flip = false
	elif moving:
		var cycles: float = minf(speed / (STRIDE_HEIGHTS * world_height), MAX_CYCLES_PER_SECOND)
		_phase = fposmod(_phase + cycles * delta, 1.0)
		key = "%s_WALK%d" % [best, int(_phase * 4.0) % 4 + 1]
	else:
		_phase = 0.0
		key = "%s_IDLE" % best
	current_dir = best
	_apply(key, _flip_for(best))
	var stretch: Vector2 = _body_scale
	_bob = 0.0
	_bob = _hover + _hover_amplitude * (0.5 + 0.5 * sin(_time * 1.35 + _seed))
	if moving:
		_bob += 0.018 * world_height * (0.5 + 0.5 * cos(4.0 * PI * (_phase - 0.375)))
	else:
		var breath: float = sin(_time * 1.9 + _seed)
		stretch *= Vector2(1.0 - 0.005 * breath, 1.0 + 0.011 * breath)
	for target: ShaderMaterial in _materials():
		target.set_shader_parameter("stretch", stretch)
		target.set_shader_parameter("roll", roll_radians)
	position = Vector3(0.0, _bob, 0.0) if local_mode else world_pos + Vector3(0.0, _bob, 0.0)
	_blob.position = Vector3(0.0, 0.035 - _bob, 0.0)
	_update_rim()


func _materials() -> Array[ShaderMaterial]:
	var list: Array[ShaderMaterial] = [_material, _shadow_material]
	if _hat_material != null:
		list.append(_hat_material)
	return list


func _turn(delta: float) -> void:
	var angle: float = heading.signed_angle_to(_target_heading, Vector3.UP)
	var step: float = deg_to_rad(turn_rate_degrees) * delta
	if absf(angle) <= step:
		heading = _target_heading
	else:
		heading = heading.rotated(Vector3.UP, signf(angle) * step)


## Angle (degrees, signed) of the body's heading relative to facing the camera: 0 = facing the camera, +90 = pointing to the screen's right, 180 = facing away.
func facing_angle() -> float:
	var basis: Basis = camera.global_basis
	var right: Vector3 = Vector3(basis.x.x, 0.0, basis.x.z).normalized()
	var toward: Vector3 = Vector3(basis.z.x, 0.0, basis.z.z).normalized()
	return rad_to_deg(atan2(heading.dot(right), heading.dot(toward)))


func _choose_direction() -> String:
	var angle: float = absf(facing_angle())
	var best: String = _dirs[0]
	var best_score: float = 1e9
	for dir_name: String in _dirs:
		# The direction already shown gets a few degrees of grace so an angle on a boundary does not flicker.
		var score: float = absf(angle - float(DIR_ANGLES[dir_name])) - (9.0 if dir_name == current_dir else 0.0)
		if score < best_score:
			best_score = score
			best = dir_name
	return best


func _flip_for(dir_name: String) -> bool:
	if dir_name == "FRONT" or dir_name == "BACK":
		return false
	return facing_angle() > 0.0


func _apply(key: String, flip: bool) -> void:
	current_key = key
	current_flip = flip
	var texture: Texture2D = SpriteLibrary.frame_or_default(character, key)
	if texture != null:
		for target: ShaderMaterial in [_material, _shadow_material]:
			target.set_shader_parameter("tex", texture)
	for target: ShaderMaterial in [_material, _shadow_material]:
		target.set_shader_parameter("flip_h", flip)
	_update_hat()


## The rim light sits on the side of the figure that faces the sun, as seen from the camera.
func _update_rim() -> void:
	var basis: Basis = camera.global_basis
	var x: float = _sun_world.dot(basis.x)
	var y: float = _sun_world.dot(basis.y)
	var dir: Vector2 = Vector2(x, y)
	if dir.length() < 0.15:
		dir = Vector2(-0.6, 0.8)
	_material.set_shader_parameter("rim_dir", dir.normalized())
	if _hat_material != null:
		_hat_material.set_shader_parameter("rim_dir", dir.normalized())


## Pass-through for scene mood: overall transparency (an occlusion fade).
func set_fade(value: float) -> void:
	for target: ShaderMaterial in _materials():
		target.set_shader_parameter("fade", value)


## Light response tweaks: `warm` multiplies the sun, `shade` is how strongly shadow cools the card.
func set_light_response(warm: float, shade: float, rim: float) -> void:
	for target: ShaderMaterial in [_material, _hat_material]:
		if target != null:
			target.set_shader_parameter("warm_gain", warm)
			target.set_shader_parameter("shade_amount", shade)
			target.set_shader_parameter("rim_strength", rim)


## A translucent, floating character (a ghost): `alpha` is the body's opacity, `hover` the height it floats above the ground (metres) and `bob` how far it drifts up and
## down. The ground shadow fades with it and the contact blob stays on the ground.
func set_ghost(alpha: float, hover: float, bob: float) -> void:
	_hover = hover
	_hover_amplitude = bob
	for target: ShaderMaterial in _materials():
		if target == _shadow_material:
			target.set_shader_parameter("fade", clampf(alpha * 0.55, 0.0, 1.0))
			continue
		target.set_shader_parameter("base_alpha", alpha)
		target.set_shader_parameter("scissor", 0.3 if alpha < 0.99 else 0.58)


## Multiplies the card's colours (per-copy variety for a crowd of identical citizens). White = natural.
func set_tint(color: Color) -> void:
	_tint = color
	for target: ShaderMaterial in [_material, _hat_material]:
		if target != null:
			target.set_shader_parameter("tint", Vector3(color.r, color.g, color.b))


func tint_color() -> Color:
	return _tint


## The height of the top of the figure above the feet, in metres (plates and quest markers sit above this).
func head_height() -> float:
	return world_height + _hover + _hover_amplitude
