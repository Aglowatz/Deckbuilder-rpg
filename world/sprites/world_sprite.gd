class_name WorldSprite
extends Node3D
## A painted 2.5D character standing in the 3D world (docs/art/world_look_test.md): an upright camera-facing card that picks one of eight drawn directions from where
## its body points relative to the camera, walks with a four-frame cycle paced by its speed, breathes when still, and is lit, rim-lit and shadowed by the scene.
## Art: five drawn directions (FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK; the art looks LEFT, the other side is mirrored). NPCs may have only FRONT / SIDE / BACK.
## Use: `setup("PLAYER", camera, sun)`, then every frame `follow(world_pos, delta)` (movers) and `look_toward(direction)` (standing characters);
## `talking = true` shows the TALK pose when the character has one.

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


func setup(character_id: String, cam: Camera3D, sun_direction: Vector3 = Vector3.ZERO) -> bool:
	character = character_id
	camera = cam
	_info = SpriteLibrary.info(character_id)
	if _info.is_empty():
		return false
	for entry: Variant in _info["dirs"] as Array:
		_dirs.append(str(entry))
	for entry: Variant in _info["walk_dirs"] as Array:
		_walk_dirs.append(str(entry))
	_seed = randf() * 10.0
	var canvas: Array = _info["canvas"] as Array
	var fig_h: float = float(_info["fig_h"])
	world_height = float(_info["rel_height"]) * PLAYER_HEIGHT
	var px_to_world: float = world_height / fig_h
	_canvas_world = Vector2(float(canvas[0]), float(canvas[1])) * px_to_world
	var feet_lift: float = float(_info["bottom_pad"]) * px_to_world
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	_material = ShaderMaterial.new()
	_material.shader = load(SHADER) as Shader
	_shadow_material = ShaderMaterial.new()
	_shadow_material.shader = load(SHADOW_SHADER) as Shader
	_material.next_pass = _shadow_material
	for target: ShaderMaterial in [_material, _shadow_material]:
		target.set_shader_parameter("card_size", _canvas_world)
		target.set_shader_parameter("feet_lift", feet_lift)
	set_sun(sun_direction)
	_mesh = MeshInstance3D.new()
	_mesh.mesh = quad
	_mesh.material_override = _material
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh.set_meta(StyleToon.META_NO_TOON, true)
	_mesh.extra_cull_margin = 4.0
	add_child(_mesh)
	_blob = ContactShadow.attach(self, 0.3 * world_height)
	_apply("FRONT_IDLE", false)
	return true


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


var _sun_world: Vector3 = Vector3(-0.42, 0.62, 0.67)


## Where the card's feet are (the node position without the walking bob).
func feet_position() -> Vector3:
	return position - Vector3(0.0, _bob, 0.0)


var _bob: float = 0.0


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


func _update(world_pos: Vector3, delta: float) -> void:
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
	var stretch: Vector2 = Vector2.ONE
	_bob = 0.0
	if moving:
		_bob = 0.018 * world_height * (0.5 + 0.5 * cos(4.0 * PI * (_phase - 0.375)))
	else:
		var breath: float = sin(_time * 1.9 + _seed)
		stretch = Vector2(1.0 - 0.005 * breath, 1.0 + 0.011 * breath)
	for target: ShaderMaterial in [_material, _shadow_material]:
		target.set_shader_parameter("stretch", stretch)
	position = world_pos + Vector3(0.0, _bob, 0.0)
	_blob.position = Vector3(0.0, 0.035 - _bob, 0.0)
	_update_rim()


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
	var texture: Texture2D = SpriteLibrary.frame(character, key)
	for target: ShaderMaterial in [_material, _shadow_material]:
		target.set_shader_parameter("tex", texture)
		target.set_shader_parameter("flip_h", flip)


## The rim light sits on the side of the figure that faces the sun, as seen from the camera.
func _update_rim() -> void:
	var basis: Basis = camera.global_basis
	var x: float = _sun_world.dot(basis.x)
	var y: float = _sun_world.dot(basis.y)
	var dir: Vector2 = Vector2(x, y)
	if dir.length() < 0.15:
		dir = Vector2(-0.6, 0.8)
	_material.set_shader_parameter("rim_dir", dir.normalized())


## Pass-through for scene mood: overall transparency (an occlusion fade).
func set_fade(value: float) -> void:
	for target: ShaderMaterial in [_material, _shadow_material]:
		target.set_shader_parameter("fade", value)


## Light response tweaks: `warm` multiplies the sun, `shade` is how strongly shadow cools the card.
func set_light_response(warm: float, shade: float, rim: float) -> void:
	_material.set_shader_parameter("warm_gain", warm)
	_material.set_shader_parameter("shade_amount", shade)
	_material.set_shader_parameter("rim_strength", rim)
