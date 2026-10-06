class_name NpcHp
extends Node
## Small idle HP for NPCs: now and then a flourish animation (a wave, a stretch, tinkering), and a gentle turn toward the hero when close.
## Register each NPC's model; `target` is the hero (a Node3D).

const FLOURISHES: Array[StringName] = [&"Interact", &"Use_Item", &"Cheer", &"PickUp", &"Spellcast_Raise"]
const NOTICE_RANGE: float = 3.4

var target: Node3D
var _entries: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func register(model: Node3D, base_yaw_degrees: float) -> void:
	var player: AnimationPlayer = ModelKit.animation_player(model)
	_entries.append({
		"model": model, "player": player, "base_yaw": deg_to_rad(base_yaw_degrees),
		"timer": _rng.randf_range(2.0, 9.0), "busy": 0.0,
	})


func entry_count() -> int:
	return _entries.size()


func _process(delta: float) -> void:
	for entry: Dictionary in _entries:
		var model: Node3D = entry["model"] as Node3D
		if not is_instance_valid(model):
			continue
		var player: AnimationPlayer = entry["player"] as AnimationPlayer
		var busy: float = float(entry["busy"]) - delta
		entry["busy"] = busy
		var yaw_goal: float = float(entry["base_yaw"])
		if target != null and is_instance_valid(target):
			var offset: Vector3 = target.global_position - model.global_position
			offset.y = 0.0
			if offset.length() < NOTICE_RANGE:
				yaw_goal = atan2(offset.x, offset.z)
		model.rotation.y = lerp_angle(model.rotation.y, yaw_goal, 1.0 - exp(-3.0 * delta))
		if player == null:
			continue
		if busy <= 0.0 and player.current_animation != "Idle" and player.has_animation("Idle"):
			player.play("Idle", 0.25)
		var timer: float = float(entry["timer"]) - delta
		entry["timer"] = timer
		if timer <= 0.0 and busy <= 0.0:
			var choices: Array[StringName] = []
			for name: StringName in FLOURISHES:
				if player.has_animation(name):
					choices.append(name)
			if not choices.is_empty():
				var chosen: StringName = choices[_rng.randi() % choices.size()]
				var animation: Animation = player.get_animation(chosen)
				animation.loop_mode = Animation.LOOP_NONE
				player.play(chosen, 0.2)
				entry["busy"] = animation.length
			entry["timer"] = _rng.randf_range(5.0, 12.0)
