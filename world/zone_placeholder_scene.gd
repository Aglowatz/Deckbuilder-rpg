class_name ZonePlaceholderScene
extends Node3D
## Part G: what a placeholder zone portal actually leads to - a small, tinted clearing with a
## "[Zone] - coming soon" sign and a portal straight back to town. Reads `Session.pending_zone_id`
## to know which of the 5 zones it is currently standing in for (name + tint only; the layout is
## identical). Reusable: this whole scene is the template a real zone replaces later, not
## something a real zone extends.

const CAMERA_OFFSET: Vector3 = Vector3(0.0, 7.0, 6.0)
const INTERACT_RADIUS: float = 1.7
const CLICK_PICK_RADIUS: float = 90.0

var area: ZonePlaceholderBuilder = ZonePlaceholderBuilder.new()
var player: TownPlayer
var info: ZonePortals.Info
var _camera: Camera3D
var _overlay_layer: Control
var _prompt_panel: PanelContainer
var _prompt_label: Label
var _portal_marker: Node3D
var _near_portal: bool = false
var _locked: bool = false
var _screenshot_args: Dictionary = {}


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = true
	Audio.play_music(&"map")
	info = ZonePortals.find(Session.pending_zone_id)
	if info == null:
		info = ZonePortals.all()[0]
	area.tint = info.tint
	add_child(WorldLook.environment(&"dusk"))
	add_child(WorldLook.sun(&"dusk"))
	area.build(self)
	_build_actors()
	_build_sign()
	_build_ui()


func _build_actors() -> void:
	var spawn: Vector3 = area.anchors.get("spawn", Vector3.ZERO) as Vector3
	player = TownPlayer.new()
	add_child(player)
	player.setup(area, "Knight", spawn)
	_portal_marker = Node3D.new()
	_portal_marker.position = (area.anchors.get("portal", Vector3.ZERO) as Vector3) + Vector3(0, 1.6, 0)
	add_child(_portal_marker)
	_camera = Camera3D.new()
	_camera.fov = 42.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + CAMERA_OFFSET
	_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)


func _build_sign() -> void:
	var portal_pos: Vector3 = area.anchors.get("portal", Vector3.ZERO) as Vector3
	var sign: Label3D = Label3D.new()
	sign.text = "%s\n- coming soon -" % info.display_name
	sign.font = UIStyle.font_title()
	sign.font_size = 40
	sign.pixel_size = 0.006
	sign.outline_size = 14
	sign.outline_modulate = Color(0.08, 0.05, 0.12, 0.95)
	sign.modulate = info.tint.lightened(0.4)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.no_depth_test = true
	sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sign.position = portal_pos + Vector3(0, 2.6, 0)
	add_child(sign)


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var host: Control = UIKit.layer_host(layer)
	host.add_child(UIKit.vignette(0.6))
	_prompt_panel = UIKit.panel()
	_prompt_panel.position = Vector2(700, 900)
	_prompt_panel.visible = false
	host.add_child(_prompt_panel)
	_prompt_label = UIKit.label("", &"", 30, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_prompt_panel.add_child(_prompt_label)
	var hints: Label = UIKit.label("WASD / arrows: move      E / Space / Click: return to town      Esc: menu", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	hints.position = Vector2(1150, 1030)
	hints.size = Vector2(750, 30)
	host.add_child(hints)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)


func _process(delta: float) -> void:
	var target: Vector3 = player.position + CAMERA_OFFSET
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	_camera.rotation_degrees = Vector3(-atan2(CAMERA_OFFSET.y, CAMERA_OFFSET.z) * 180.0 / PI, 0.0, 0.0)
	_update_near_portal()
	player.input_enabled = not _locked


func _update_near_portal() -> void:
	if _locked:
		_prompt_panel.visible = false
		_near_portal = false
		return
	var portal: Vector3 = area.anchors.get("portal", Vector3.ZERO) as Vector3
	var distance: float = Vector2(player.position.x - portal.x, player.position.z - portal.z).length()
	var was_near: bool = _near_portal
	_near_portal = distance <= INTERACT_RADIUS
	if _near_portal and not was_near:
		Audio.sfx(&"ui_tick", -10.0)
	if _near_portal:
		_prompt_label.text = "[E]  Return to town"
		_prompt_panel.visible = true
		_prompt_panel.reset_size()
		_prompt_panel.position.x = (1920.0 - _prompt_panel.size.x) * 0.5
	else:
		_prompt_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _locked or not _near_portal:
		return
	if event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		_return_to_town()
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		if (event as InputEventKey).keycode == KEY_SPACE:
			get_viewport().set_input_as_handled()
			_return_to_town()
			return
	if event is InputEventMouseButton:
		var click: InputEventMouseButton = event as InputEventMouseButton
		if click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			if _camera.unproject_position(_portal_marker.position).distance_to(click.position) <= CLICK_PICK_RADIUS:
				get_viewport().set_input_as_handled()
				_return_to_town()


func _return_to_town() -> void:
	Audio.sfx(&"door")
	SceneManager.go_to_town()


func screenshot_ready() -> bool:
	return true
