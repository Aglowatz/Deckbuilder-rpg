class_name ZoneEnemy
extends Node3D
## A roaming enemy in the D.N.A. Simple AI: PATROL (wander near its home), CHASE (the player came
## within aggro range and is in sight), RETURN (the player got too far from home, or the enemy got
## stuck / lost sight - it gives up and walks home). Slow types stay below the player's speed; the
## fast courier is faster. What touching the player does is decided by the scene via `touched`.

signal touched(enemy: ZoneEnemy)

enum State { PATROL, CHASE, RETURN }

## Enemy speeds were tuned against a hero that walked at 3.4; the storybook hero walks faster, so every enemy speed grows by the same ratio.
const SPEED_RATIO: float = TownPlayer.SPEED / ZoneEnemies.PLAYER_SPEED

var info: ZoneEnemyInfo
var instance_id: String = ""
var home: Vector3 = Vector3.ZERO
var patrol_radius: float = 3.0
var area: ZoneMap
var player: Node3D
var state: State = State.PATROL
## The scene sets this false while dialogue/menus are open so enemies freeze with the world.
var active: bool = true
## While > 0 the enemy cannot trigger `touched` (after hitting the player, or the spawn grace).
var cooldown: float = 0.0
## A road guard (Gainlands v2, Part G): it stands its ground (no patrol, no chase) and challenges anyone who steps within this many metres of it (centre to
## centre); 0 = an ordinary roaming enemy. Its training partners (`escorts`) are extra models of its kind standing beside it, gone with it.
var guard_radius: float = 0.0
var escorts: Array[Node3D] = []

var _model: Node3D
var _animation: AnimationPlayer
var _current_animation: StringName = &""
var _target: Vector3 = Vector3.ZERO
var _wait: float = 0.0
var _stuck_time: float = 0.0
var _lost_sight: float = 0.0
var _time: float = 0.0
var _alert: Label3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Overnight Oct 28-29: seconds left of the threat pose (the painted FRONT_TALK frame, facing the hero) an enemy strikes when it spots the hero, before it gives chase.
var _threat: float = 0.0
const THREAT_SECONDS: float = 0.45
## The painted roamers' rim: a warm red-orange edge, a little stronger than the NPCs' (0.42), so they read against busy ground.
const ROAMER_RIM: Color = Color(1.0, 0.55, 0.4)
const ROAMER_RIM_STRENGTH: float = 0.62


func setup(enemy_info: ZoneEnemyInfo, id: String, home_pos: Vector3, patrol: float, walk_area: ZoneMap, target_player: Node3D, grade: Callable = Callable()) -> void:
	info = enemy_info
	instance_id = id
	home = home_pos
	patrol_radius = patrol
	area = walk_area
	player = target_player
	position = home_pos
	_rng.seed = hash(id)
	_model = _make_model()
	add_child(_model)
	_model.scale = Vector3.ONE * info.model_scale * StorybookScale.CHAR_FACTOR
	if not is_sprite():
		if info.tint != Color.WHITE:
			ModelKit.tint(_model, info.tint)
		if grade.is_valid():
			grade.call(_model)
		_add_accessories()
		if info.ghostly:
			_make_ghostly()
	_animation = null if is_sprite() else ModelKit.animation_player(_model)
	if _animation != null:
		for anim_name: StringName in _animation.get_animation_list():
			var lower: String = String(anim_name).to_lower()
			if lower == "idle" or lower == "walk" or lower == "sprint":
				_animation.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	_play(info.anim_idle)
	_alert = Label3D.new()
	_alert.text = "!"
	_alert.font = UIStyle.font_title()
	_alert.font_size = 64
	_alert.pixel_size = 0.008
	_alert.modulate = Color(1.0, 0.35, 0.3)
	_alert.outline_size = 12
	_alert.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_alert.no_depth_test = true
	_alert.position = Vector3(0, StorybookScale.HERO_HEIGHT, 0)
	_alert.visible = false
	add_child(_alert)
	_pick_patrol_target()


## The enemy's model: "proc:<name>" is a procedural Gainlands model, "kaykit:<name>" an animated KayKit
## character, anything else a Kenney Graveyard Kit character.
## Makes this enemy a road guard with `count` training partners standing either side of it, a step behind.
func make_guard(radius: float, count: int) -> void:
	guard_radius = radius
	patrol_radius = 0.0
	for index: int in range(count):
		var partner: Node3D = _make_model()
		partner.name = "Escort%d" % index
		add_child(partner)
		partner.scale = Vector3.ONE * info.model_scale * StorybookScale.CHAR_FACTOR * 0.92
		partner.position = Vector3((1.0 if index % 2 == 0 else -1.0) * 1.35, 0.0, -0.7 - 0.3 * float(index / 2))
		if info.tint != Color.WHITE and not (partner is SpriteActor):
			ModelKit.tint(partner, info.tint.darkened(0.08))
		var player_node: AnimationPlayer = ModelKit.animation_player(partner)
		if player_node != null and player_node.has_animation(info.anim_idle):
			player_node.get_animation(info.anim_idle).loop_mode = Animation.LOOP_LINEAR
			player_node.play(info.anim_idle)
		escorts.append(partner)


func _make_model() -> Node3D:
	# Overnight Oct 28: a painted 2.5D sprite set, once imported, replaces whatever model the spec names (docs/design/enemy_roster_oct28.md).
	# The importer names a set's folder (the manifest key) with underscores: FOE-PANTRY-HOUND -> FOE_PANTRY_HOUND.
	var key: String = info.sprite_key().replace("-", "_")
	# WAYWARD_ROAMER_MODELS=1 keeps the 3D models (performance A/B, overnight Oct 28-29).
	if SpriteLibrary.has_character(key) and OS.get_environment("WAYWARD_ROAMER_MODELS") != "1":
		# The painted set carries its own colours: the spec's tint was for the 3D model (overnight Oct 28-29).
		var actor: SpriteActor = NpcSprites.make_actor(key)
		actor.natural_scale = info.model_scale * StorybookScale.CHAR_FACTOR
		return actor
	if info.model.begins_with("capital:"):
		return CapitalMobs.build(info.model)
	if info.model.begins_with("heap:"):
		return HeapMobs.build(info.model)
	if info.model.begins_with("buffet:"):
		return BuffetMobs.build(info.model)
	if info.model.begins_with("proc:"):
		return GainlandsMobs.build(info.model)
	if info.model.begins_with("kaykit:"):
		return ModelKit.character(info.model.trim_prefix("kaykit:"))
	return ModelKit.zone_character(info.model)


func _make_ghostly() -> void:
	for child: Node in _model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		for surface: int in range(mesh_instance.mesh.get_surface_count()):
			var material: Material = mesh_instance.get_active_material(surface)
			if material is StandardMaterial3D:
				var copy: StandardMaterial3D = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
				copy.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				copy.albedo_color.a = 0.72
				copy.emission_enabled = true
				copy.emission = info.ghost_glow
				copy.emission_energy_multiplier = 0.5
				mesh_instance.set_surface_override_material(surface, copy)


## Little themed props (`ZoneEnemyInfo.accessories`) so each design reads at a glance: a tie and clipboard, a lanyard and
## coffee cup, a letter. Plain primitives (the same trick the town's corrupted NPCs use).
func _add_accessories() -> void:
	for entry: Dictionary in info.accessories:
		_accessory(entry["offset"] as Vector3, entry["size"] as Vector3, entry["color"] as Color)


func _accessory(offset: Vector3, size: Vector3, color: Color) -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size / maxf(info.model_scale * StorybookScale.CHAR_FACTOR, 0.1)
	mesh_instance.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material
	mesh_instance.position = offset / maxf(info.model_scale * StorybookScale.CHAR_FACTOR, 0.1)
	_model.add_child(mesh_instance)


func _play(animation_name: StringName) -> void:
	if _animation == null or _current_animation == animation_name or not _animation.has_animation(animation_name):
		return
	_current_animation = animation_name
	_animation.play(animation_name, 0.2)


func _process(delta: float) -> void:
	# Performance pass Oct 25: a patrolling enemy out of the camera's view walks on in steps of OFFSCREEN_EVERY frames (the missed time added
	# up, so its route and pace stay the same); one in view, chasing, returning or guarding a road updates every frame.
	if state == State.PATROL and guard_radius <= 0.0 and _off_screen():
		_skipped_delta += delta
		_skipped += 1
		if _skipped < OFFSCREEN_EVERY:
			return
	if _skipped > 0:
		delta = _skipped_delta if _skipped >= OFFSCREEN_EVERY else delta + _skipped_delta
		_skipped = 0
		_skipped_delta = 0.0
	_time += delta
	cooldown = maxf(0.0, cooldown - delta)
	if info.hover:
		_model.position.y = 0.22 + sin(_time * 3.2) * 0.06
	position.y = area.height_at(position)
	if is_sprite():
		_drive_sprite(_model as SpriteActor, delta)
		for escort: Node3D in escorts:
			if escort is SpriteActor:
				_drive_sprite(escort as SpriteActor, delta)
	if not active or player == null:
		_play(info.anim_idle)
		return
	if guard_radius > 0.0:
		# a road guard: stands in the road, alerts as the hero nears, challenges (starts the battle) once the hero is inside its circle
		_play(info.anim_idle)
		var reach: float = Vector2(player.position.x - position.x, player.position.z - position.z).length()
		_alert.visible = reach < guard_radius + 2.5
		if reach < guard_radius and cooldown <= 0.0:
			touched.emit(self)
		return
	var to_player: Vector3 = player.position - position
	to_player.y = 0.0
	var distance: float = to_player.length()
	var home_distance: float = Vector2(position.x - home.x, position.z - home.z).length()
	var moved: bool = false
	match state:
		State.PATROL:
			if distance < info.aggro_range and area.has_line_of_sight(position, player.position) and home_distance < info.leash_range:
				_set_state(State.CHASE)
			elif _wait > 0.0:
				_wait -= delta
			else:
				moved = _walk_toward(_target, info.patrol_speed, delta)
				if Vector2(position.x - _target.x, position.z - _target.z).length() < 0.25 or _stuck_time > 0.8:
					_wait = _rng.randf_range(0.8, 2.2)
					_stuck_time = 0.0
					_pick_patrol_target()
		State.CHASE:
			if _threat > 0.0:
				_threat -= delta
				_face(to_player, delta)
			elif home_distance > info.leash_range or _lost_sight > 2.0 or _stuck_time > 1.2:
				_set_state(State.RETURN)
			else:
				if area.has_line_of_sight(position, player.position):
					_lost_sight = 0.0
				else:
					_lost_sight += delta
				moved = _walk_toward(player.position, info.chase_speed, delta)
				if distance < info.touch_range * StorybookScale.INTERACT_FACTOR and cooldown <= 0.0:
					touched.emit(self)
		State.RETURN:
			moved = _walk_toward(home, info.patrol_speed * 1.6, delta)
			if home_distance < 0.5 or _stuck_time > 1.5:
				_set_state(State.PATROL)
				_stuck_time = 0.0
				_wait = 1.0
	_alert.visible = state == State.CHASE
	if is_sprite():
		var actor: SpriteActor = _model as SpriteActor
		actor.talking = _threat > 0.0
		if actor.sprite != null:
			_alert.position.y = actor.head_height() + 0.35
		_hop(moved)
	if moved:
		_play(info.anim_run if state == State.CHASE and _animation != null and _animation.has_animation(info.anim_run) else info.anim_walk)
	else:
		_play(info.anim_idle)
	if _animation == null:
		_waddle(moved)


## True when this enemy is drawn as a painted sprite (its walk comes from the sprite itself; no tint, accessories, ghost pass or waddle).
func is_sprite() -> bool:
	return _model is SpriteActor


## A painted set with no walk strips (the idle sets: the meatball, the courier, the gulls...) hops and sways while it moves, so it never slides;
## floaters (hover specs) only sway. Walk-strip sets walk with their own frames.
func _hop(moving: bool) -> void:
	var actor: SpriteActor = _model as SpriteActor
	if actor.sprite == null or not actor.sprite.walk_dirs().is_empty():
		return
	var rate: float = 11.0 if state == State.CHASE else 8.0
	var roll: float = sin(_time * rate) * 0.07 if moving else 0.0
	actor.rotation.z = lerpf(actor.rotation.z, roll, 0.25)
	if not info.hover:
		actor.position.y = absf(sin(_time * rate)) * 0.09 if moving else lerpf(actor.position.y, 0.0, 0.3)


## The painted roamer is driven from here (one per-frame script per enemy, not two; it also skips the frames this enemy skips off-screen):
## its frame step, and its rim once its card exists.
func _drive_sprite(actor: SpriteActor, delta: float) -> void:
	if actor.is_processing():
		actor.set_process(false)
	actor.step(delta)
	if actor.sprite != null and actor.sprite.rim_override.a <= 0.0:
		actor.sprite.set_rim(ROAMER_RIM, ROAMER_RIM_STRENGTH)


## Turns the body toward the given direction (the threat pose faces the hero).
func _face(direction: Vector3, delta: float) -> void:
	if direction.length() > 0.01:
		_model.rotation.y = lerp_angle(_model.rotation.y, atan2(direction.x, direction.z), 1.0 - exp(-12.0 * delta))


## Procedural models have no animation player: wobble while moving.
func _waddle(moving: bool) -> void:
	if is_sprite():
		return
	if _model.has_meta("roller"):
		# Rolling things (the Runaway Meatball) spin their body instead of waddling.
		if moving:
			(_model.get_meta("roller") as Node3D).rotation.x += (14.0 if state == State.CHASE else 6.0) * get_process_delta_time()
		return
	var target_roll: float = sin(_time * 9.0) * 0.12 if moving else 0.0
	_model.rotation.z = lerpf(_model.rotation.z, target_roll, 0.25)
	if not info.hover:
		_model.position.y = absf(sin(_time * 9.0)) * 0.07 if moving else 0.0


func _set_state(next: State) -> void:
	state = next
	_stuck_time = 0.0
	_lost_sight = 0.0
	if next == State.CHASE:
		Audio.sfx(&"ui_tick", -8.0, 0.3)
		if is_sprite():
			_threat = THREAT_SECONDS


func _pick_patrol_target() -> void:
	for attempt: int in range(8):
		var angle: float = _rng.randf() * TAU
		var radius: float = _rng.randf_range(0.5, patrol_radius)
		var candidate: Vector3 = home + Vector3(cos(angle), 0.0, sin(angle)) * radius
		if area.is_enemy_walkable(candidate, 0.25) and area.has_line_of_sight(position, candidate):
			_target = candidate
			return
	_target = home


## Steps toward `goal` at `speed`, sliding along obstacles. Returns true if it moved.
func _walk_toward(goal: Vector3, speed: float, delta: float) -> bool:
	var direction: Vector3 = goal - position
	direction.y = 0.0
	if direction.length() < 0.05:
		return false
	direction = direction.normalized()
	speed *= SPEED_RATIO
	var step: Vector3 = direction * speed * delta
	var before: Vector3 = position
	if area.is_enemy_walkable(position + step, 0.25):
		position += step
	elif area.is_enemy_walkable(position + Vector3(step.x, 0.0, 0.0), 0.25):
		position.x += step.x
	elif area.is_enemy_walkable(position + Vector3(0.0, 0.0, step.z), 0.25):
		position.z += step.z
	var moved: bool = position.distance_to(before) > speed * delta * 0.3
	if moved:
		_stuck_time = maxf(0.0, _stuck_time - delta)
		_model.rotation.y = lerp_angle(_model.rotation.y, atan2(direction.x, direction.z), 1.0 - exp(-10.0 * delta))
	else:
		_stuck_time += delta
	return moved


const OFFSCREEN_EVERY: int = 4
var _skipped: int = 0
var _skipped_delta: float = 0.0
var _camera: Camera3D


func _off_screen() -> bool:
	if _camera == null or not is_instance_valid(_camera) or not _camera.current:
		_camera = get_viewport().get_camera_3d() if is_inside_tree() else null
		if _camera == null:
			return false
	var middle: Vector3 = global_position + Vector3(0.0, 0.8, 0.0)
	return _camera.global_position.distance_squared_to(middle) > 9.0 and not _camera.is_position_in_frustum(middle)


## Pushes the enemy back/away (after it hit the player) so it does not hit again immediately.
func retreat_from(point: Vector3, seconds: float) -> void:
	cooldown = seconds
	_set_state(State.RETURN)
	var away: Vector3 = position - point
	away.y = 0.0
	if away.length() > 0.01:
		var candidate: Vector3 = position + away.normalized() * 1.2
		if area.is_enemy_walkable(candidate, 0.25):
			position = candidate
