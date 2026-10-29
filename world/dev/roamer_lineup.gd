class_name RoamerLineup
extends Node3D
## Screenshot aid (overnight Oct 28-29, art batch Part 1): every kind of roaming enemy of the scene stands in a row beside the hero, one copy per facing
## (FRONT, FRONTSIDE, SIDE left, BACKSIDE, BACK, SIDE right - the right-facing ones are the mirrored left art), so scale, baseline, facing and contrast can be
## judged against the zone itself. `mode`: "idle", "walk" (the walk cycle on the spot) or "threat" (the pose an enemy strikes when it spots the hero).
## Use from a scene's screenshot args: `--lineup=idle|walk|threat` (ZoneScene, TownScene). The real roamers are hidden and frozen.

## Facings relative to the camera, degrees: 0 faces the camera, +90 points to the screen's right.
const FACINGS: Array[float] = [0.0, -45.0, -90.0, -135.0, 180.0, 90.0]
const COLUMNS: Array[float] = [-3.9, -2.6, -1.3, 1.3, 2.6, 3.9]
const ROW_DEPTH: float = 2.0

var mode: String = "idle"
var _copies: Array[ZoneEnemy] = []
var _facing: Array[float] = []
var _player: Node3D
var _time: float = 0.0
var _reported: bool = false


## Hides `enemies` and puts the lineup in their place (deferred until the camera exists).
static func install(root: Node, player: Node3D, enemies: Array, lineup_mode: String) -> RoamerLineup:
	var lineup: RoamerLineup = RoamerLineup.new()
	lineup.name = "RoamerLineup"
	lineup.mode = lineup_mode
	lineup._player = player
	root.add_child(lineup)
	var kinds: Dictionary = {}
	for value: Variant in enemies:
		var enemy: ZoneEnemy = value as ZoneEnemy
		if enemy == null or not is_instance_valid(enemy):
			continue
		enemy.visible = false
		enemy.active = false
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		if not kinds.has(enemy.info.display_name):
			kinds[enemy.info.display_name] = enemy
	var row: int = 0
	for display_name: Variant in kinds:
		var source: ZoneEnemy = kinds[display_name] as ZoneEnemy
		for column: int in range(FACINGS.size()):
			var copy: ZoneEnemy = ZoneEnemy.new()
			root.add_child(copy)
			copy.setup(source.info, "lineup_%d_%d" % [row, column], player.position, 0.0, source.area, null)
			copy.set_meta("lineup_offset", Vector2(COLUMNS[column], float(row) * ROW_DEPTH))
			lineup._copies.append(copy)
			lineup._facing.append(FACINGS[column])
		row += 1
	print("roamer lineup: %d kinds (%s), mode %s" % [kinds.size(), ", ".join(PackedStringArray(kinds.keys())), lineup_mode])
	return lineup


func _process(delta: float) -> void:
	_time += delta
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null or _player == null:
		return
	var basis: Basis = camera.global_basis
	var right: Vector3 = Vector3(basis.x.x, 0.0, basis.x.z).normalized()
	var away: Vector3 = -Vector3(basis.z.x, 0.0, basis.z.z).normalized()
	for index: int in range(_copies.size()):
		var copy: ZoneEnemy = _copies[index]
		var offset: Vector2 = copy.get_meta("lineup_offset") as Vector2
		var at: Vector3 = _player.global_position + right * offset.x + away * offset.y
		at.y = copy.area.height_at(at) if copy.area != null else at.y
		copy.global_position = at
		var angle: float = deg_to_rad(_facing[index])
		var toward_camera: Vector3 = -away
		var heading: Vector3 = toward_camera * cos(angle) + right * sin(angle)
		var model: Node3D = copy.get_child(0) as Node3D
		if model == null:
			continue
		model.rotation.y = atan2(heading.x, heading.z)
		if model is SpriteActor:
			var actor: SpriteActor = model as SpriteActor
			actor.talking = mode == "threat"
			if actor.sprite != null:
				actor.sprite.demo_walk_speed = 1.6 if mode == "walk" else 0.0
				if _time > 3.0 and not _reported:
					print("lineup %s facing %d: %s%s" % [copy.info.display_name, int(_facing[index]), actor.sprite.current_key, " (mirrored)" if actor.sprite.current_flip else ""])
	if _time > 3.0:
		_reported = true
