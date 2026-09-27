class_name TownBackdrop
extends Node3D
## A slowly orbiting view of the town island, used behind the title screen and other menus.

var town: TownBuilder = TownBuilder.new()
var _camera: Camera3D
var _angle: float = 0.0
var _center: Vector3
var _time: float = 0.0
@export var orbit_speed: float = 0.035
@export var distance: float = 15.0
@export var height: float = 8.5
@export var start_angle: float = 0.55


func _ready() -> void:
	add_child(WorldLook.environment(&"day"))
	add_child(WorldLook.sun(&"day"))
	town.build(self)
	_center = HexGrid.cell_to_world(4, 3) + Vector3(0.6, 0.6, 0.0)
	_camera = Camera3D.new()
	_camera.fov = 42.0
	_camera.h_offset = -3.2
	add_child(_camera)
	_camera.current = true
	_angle = start_angle
	# A traveller standing by the well gives the scene a focal point.
	var knight: Node3D = ModelKit.character("Knight")
	ModelKit.place(self, knight, town.anchors["well"] as Vector3 + Vector3(-0.9, 0, 0.5), 25.0, 0.3)
	var animation: AnimationPlayer = ModelKit.animation_player(knight)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
	_update_camera()


func _process(delta: float) -> void:
	_time += delta
	_angle += orbit_speed * delta
	_update_camera()


func _update_camera() -> void:
	var offset: Vector3 = Vector3(sin(_angle), 0.0, cos(_angle)) * distance
	_camera.position = _center + offset + Vector3(0, height + sin(_time * 0.4) * 0.3, 0)
	_camera.look_at(_center, Vector3.UP)
