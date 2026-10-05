class_name ZoneEnemy
extends Node3D
## A roaming enemy in the D.N.A. Simple AI: PATROL (wander near its home), CHASE (the player came
## within aggro range and is in sight), RETURN (the player got too far from home, or the enemy got
## stuck / lost sight - it gives up and walks home). Slow types stay below the player's speed; the
## fast courier is faster. What touching the player does is decided by the scene via `touched`.

signal touched(enemy: ZoneEnemy)

enum State { PATROL, CHASE, RETURN }

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
	_model.scale = Vector3.ONE * info.model_scale
	if info.tint != Color.WHITE:
		ModelKit.tint(_model, info.tint)
	if grade.is_valid():
		grade.call(_model)
	_add_accessories()
	if info.ghostly:
		_make_ghostly()
	_animation = ModelKit.animation_player(_model)
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
	_alert.position = Vector3(0, 1.25, 0)
	_alert.visible = false
	add_child(_alert)
	_pick_patrol_target()


## The enemy's model: "proc:<name>" is a procedural Gainlands model, "kaykit:<name>" an animated KayKit
## character, anything else a Kenney Graveyard Kit character.
func _make_model() -> Node3D:
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
	mesh.size = size / maxf(info.model_scale, 0.1)
	mesh_instance.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material
	mesh_instance.position = offset / maxf(info.model_scale, 0.1)
	_model.add_child(mesh_instance)


func _play(animation_name: StringName) -> void:
	if _animation == null or _current_animation == animation_name or not _animation.has_animation(animation_name):
		return
	_current_animation = animation_name
	_animation.play(animation_name, 0.2)


func _process(delta: float) -> void:
	_time += delta
	cooldown = maxf(0.0, cooldown - delta)
	if info.hover:
		_model.position.y = 0.22 + sin(_time * 3.2) * 0.06
	position.y = area.height_at(position)
	if not active or player == null:
		_play(info.anim_idle)
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
			if home_distance > info.leash_range or _lost_sight > 2.0 or _stuck_time > 1.2:
				_set_state(State.RETURN)
			else:
				if area.has_line_of_sight(position, player.position):
					_lost_sight = 0.0
				else:
					_lost_sight += delta
				moved = _walk_toward(player.position, info.chase_speed, delta)
				if distance < info.touch_range and cooldown <= 0.0:
					touched.emit(self)
		State.RETURN:
			moved = _walk_toward(home, info.patrol_speed * 1.6, delta)
			if home_distance < 0.5 or _stuck_time > 1.5:
				_set_state(State.PATROL)
				_stuck_time = 0.0
				_wait = 1.0
	_alert.visible = state == State.CHASE
	if moved:
		_play(info.anim_run if state == State.CHASE and _animation != null and _animation.has_animation(info.anim_run) else info.anim_walk)
	else:
		_play(info.anim_idle)
	if _animation == null:
		_waddle(moved)


## Procedural models have no animation player: wobble while moving.
func _waddle(moving: bool) -> void:
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
