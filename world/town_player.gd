class_name TownPlayer
extends Node3D
## The walkable hero: WASD / arrow movement on the town's hex tiles with simple circle
## collisions (TownBuilder.is_walkable), turning, idle/walk animations and footstep sounds.

const SPEED: float = StorybookScale.WALK_SPEED
const MODEL_SCALE: float = StorybookScale.MODEL_SCALE

var town: WalkableArea
var input_enabled: bool = true
var model: Node3D
var _animation: AnimationPlayer
var _current_animation: StringName = &""
var _step_timer: float = 0.0
var _velocity: Vector3 = Vector3.ZERO
## Camera yaw the movement keys are relative to (the town camera never rotates).
var move_yaw: float = 0.0
## While true (thrown, falling, fading) the scene drives the position, including its height.
var airborne: bool = false
## When set, the hero plays this animation and ignores input (running in the hamster wheel).
var forced_animation: StringName = &""
## Brief 8: 1.0 on foot; a mount makes it faster. `moving` is true while a movement key is held this frame.
var speed_multiplier: float = 1.0
## Overnight Oct 16: gear outside battle (Gotta-Go Galoshes: OVERWORLD_SPEED_PERCENT), re-read from the equipped pieces twice a second.
var gear_speed: float = 1.0
var _gear_timer: float = 0.0
var moving: bool = false
## Overnight Oct 30-31, Part 3: sprinting this frame (Shift held, a controller's left-stick click until the hero stops, or Settings > Always
## sprint, where holding Shift walks). Not on a mount (it is faster already) and not in scripted moves.
var sprinting: bool = false
var _pad_sprint: bool = false


func setup(town_builder: WalkableArea, model_name: String, start: Vector3) -> void:
	town = town_builder
	Audio.set_ground(town_builder)
	position = start
	if model_name == "Hero":
		model = _hero_model()
		# World sounds are heard from the hero (AudioManager places the listener here).
		add_to_group(&"audio_hero")
	else:
		model = ModelKit.character(model_name)
	if model_name == "Hero" and model.has_meta("hero_model") and not EventBus.cosmetics_changed.is_connected(_on_cosmetics_changed):
		EventBus.cosmetics_changed.connect(_on_cosmetics_changed)
	add_child(model)
	model.scale = Vector3.ONE * MODEL_SCALE
	_animation = ModelKit.animation_player(model)
	_play(&"Idle")


## The hero is the painted 2.5D sprite (`SpriteActor`, docs/art/world_rollout.md); the 3D rogue is only the fallback when the sprite art is missing.
func _hero_model() -> Node3D:
	if SpriteLibrary.has_character("PLAYER"):
		var actor: SpriteActor = SpriteActor.new()
		actor.name = "HeroSprite"
		actor.character = "PLAYER"
		actor.natural_scale = MODEL_SCALE
		return actor
	return HeroModel.build(Session.cosmetics)


func _process(delta: float) -> void:
	_gear_timer -= delta
	if _gear_timer <= 0.0:
		_gear_timer = 0.5
		gear_speed = 1.0 + float(ExpansionGear.equipped_total(Session.profile, Modifier.Kind.OVERWORLD_SPEED_PERCENT)) / 100.0
	if forced_animation != &"":
		_play(forced_animation)
		return
	var direction: Vector2 = _read_input() if input_enabled else Vector2.ZERO
	if direction != Vector2.ZERO:
		var world_dir: Vector3 = Vector3(direction.x, 0.0, direction.y).rotated(Vector3.UP, move_yaw).normalized()
		var was_sprinting: bool = sprinting
		sprinting = wants_sprint()
		if sprinting and not was_sprinting and input_enabled:
			Audio.sfx(&"sprint_start")  # Part 8: a short whoosh as the hero breaks into a run
		_velocity = world_dir * SPEED * speed_multiplier * gear_speed * minf(direction.length(), 1.0) * (SPRINT if sprinting else 1.0)
		moving = true
		_move(_velocity * delta)
		var target_yaw: float = atan2(world_dir.x, world_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_yaw, 1.0 - exp(-14.0 * delta))
		_play(&"Walking_A")
		# The painted hero steps on its walk cycle's foot contacts (WorldSprite); only the 3D fallback model keeps the old timer.
		if not model is SpriteActor:
			_step_timer -= delta
			if _step_timer <= 0.0:
				_step_timer = 0.34
				Audio.footstep(position, true)
	else:
		_velocity = Vector3.ZERO
		moving = false
		sprinting = false
		_pad_sprint = false
		_play(&"Idle")
		_step_timer = 0.0
	if not airborne:
		var ground: float = town.height_at(position)
		if absf(position.y - ground) > 0.001:
			position.y = lerpf(position.y, ground, 1.0 - exp(-16.0 * delta))


## The walk direction: keys give a unit vector (diagonals normalised, as before); controller support (Oct 26): the left stick gives its tilt, so a
## half-tilted stick walks slower (never below MIN_STICK_SPEED, so the hero does not creep).
func _read_input() -> Vector2:
	var result: Vector2 = Vector2.ZERO
	if _key_held(&"move_up"):
		result.y -= 1.0
	if _key_held(&"move_down"):
		result.y += 1.0
	if _key_held(&"move_left"):
		result.x -= 1.0
	if _key_held(&"move_right"):
		result.x += 1.0
	if result != Vector2.ZERO:
		return result.normalized()
	var stick: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if stick == Vector2.ZERO:
		return stick
	return stick.normalized() * clampf(stick.length(), MIN_STICK_SPEED, 1.0)


const MIN_STICK_SPEED: float = 0.4
## Overnight Oct 30-31, Part 3: the sprint speed (x the walk; the walk animation plays faster to match).
const SPRINT: float = 1.65


## Whether the hero sprints now: Shift held (or not held with Always sprint), or a controller's left-stick click (latched until it stops).
## On foot only (`speed_multiplier` 1.0: a mount is faster already).
func wants_sprint() -> bool:
	if speed_multiplier != 1.0 or airborne:
		return false
	if InputMap.has_action(&"sprint") and Input.is_action_just_pressed(&"sprint") and InputDevice.using_pad():
		_pad_sprint = not _pad_sprint
	var held: bool = InputMap.has_action(&"sprint") and Input.is_action_pressed(&"sprint") and not InputDevice.using_pad()
	return _pad_sprint or (held != Settings.always_sprint)


## A movement action held at full strength (a key or a D-pad button); a stick reads weaker than 1 and goes through `Input.get_vector`.
func _key_held(action: StringName) -> bool:
	return Input.get_action_strength(action) >= 0.99


## Moves by `step`, sliding along obstacles when the full step is blocked.
func _move(step: Vector3) -> void:
	if town.is_walkable(position + step):
		position += step
	elif town.is_walkable(position + Vector3(step.x, 0.0, 0.0)):
		position.x += step.x
	elif town.is_walkable(position + Vector3(0.0, 0.0, step.z)):
		position.z += step.z


func face(target: Vector3) -> void:
	var offset: Vector3 = target - position
	model.rotation.y = atan2(offset.x, offset.z)


func _play(animation_name: StringName) -> void:
	if _animation == null or _current_animation == animation_name:
		return
	if not _animation.has_animation(animation_name):
		return
	_current_animation = animation_name
	_animation.play(animation_name, 0.2)


func _on_cosmetics_changed() -> void:
	if model != null and is_instance_valid(model) and model.has_meta("hero_model"):
		HeroModel.refresh(model, Session.cosmetics)


func _exit_tree() -> void:
	if EventBus.cosmetics_changed.is_connected(_on_cosmetics_changed):
		EventBus.cosmetics_changed.disconnect(_on_cosmetics_changed)
