class_name StartingAreaScene
extends Node3D
## Where a new campaign begins: the hero wakes up alone in a small forest clearing, talks to
## themselves, and the only way forward is the cave mouth into the Trial of the Hollow. Entering
## it for the first time asks which element (`ElementChoiceScreen`, Part C) before the dungeon
## actually starts. No town access from here - see docs/design/starting_deck_and_affinity.md.

const STORY_PATH: String = "res://data/story/intro_story.tres"
const CAMERA_OFFSET: Vector3 = Vector3(0.0, 8.4, 7.0)
const INTERACT_RADIUS: float = 1.7
## How close (in screen pixels) a click has to land to the gate's marker to count as clicking it.
const CLICK_PICK_RADIUS: float = 90.0

var area: StartingAreaBuilder = StartingAreaBuilder.new()
var player: TownPlayer
var dialogue: DialogueBox
var _camera: Camera3D
var _overlay_layer: Control
var _prompt_panel: PanelContainer
var _prompt_label: Label
var _gate_marker: Node3D
var _near_gate: bool = false
var _locked: bool = false
var _screenshot_args: Dictionary = {}


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = true
	Audio.play_music(&"map")
	if not _screenshot_args.is_empty() and str(_screenshot_args.get("fresh", "false")) == "true":
		Session.new_game()
	elif Session.profile == null and not Session.flag(&"awakened"):
		Session.new_game()
	add_child(WorldLook.environment(&"dusk"))
	add_child(WorldLook.sun(&"dusk"))
	area.build(self)
	_build_actors()
	_build_ui()
	if not Session.flag(&"awakened"):
		Session.set_flag(&"awakened")
		Session.save_game()
		_play_awakening.call_deferred()
	Session.save_game()


func _build_actors() -> void:
	var spawn: Vector3 = area.anchors.get("spawn", Vector3.ZERO) as Vector3
	player = TownPlayer.new()
	add_child(player)
	player.setup(area, "Knight", spawn)
	_gate_marker = Node3D.new()
	_gate_marker.position = (area.anchors.get("gate", Vector3.ZERO) as Vector3) + Vector3(0, 1.6, 0)
	add_child(_gate_marker)
	_camera = Camera3D.new()
	_camera.fov = 40.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + CAMERA_OFFSET
	_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var host: Control = UIKit.layer_host(layer)
	host.add_child(UIKit.vignette(0.6))
	dialogue = DialogueBox.new()
	host.add_child(dialogue)
	_prompt_panel = UIKit.panel()
	_prompt_panel.position = Vector2(700, 900)
	_prompt_panel.visible = false
	host.add_child(_prompt_panel)
	_prompt_label = UIKit.label("", &"", 30, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_prompt_panel.add_child(_prompt_label)
	var hints: Label = UIKit.label("WASD / arrows: move      E / Space / Click: interact      Esc: menu", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	hints.position = Vector2(1200, 1030)
	hints.size = Vector2(700, 30)
	host.add_child(hints)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)


func _play_awakening() -> void:
	var story: StoryText = load(STORY_PATH) as StoryText
	if story == null or story.awakening_lines.is_empty():
		return
	dialogue.start("", story.awakening_lines)


func _process(delta: float) -> void:
	var target: Vector3 = player.position + CAMERA_OFFSET
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	_camera.rotation_degrees = Vector3(-atan2(CAMERA_OFFSET.y, CAMERA_OFFSET.z) * 180.0 / PI, 0.0, 0.0)
	_update_near_gate()
	player.input_enabled = not _locked and not dialogue.active


func _update_near_gate() -> void:
	if _locked or dialogue.active:
		_prompt_panel.visible = false
		_near_gate = false
		return
	var gate: Vector3 = area.anchors.get("gate", Vector3.ZERO) as Vector3
	var distance: float = Vector2(player.position.x - gate.x, player.position.z - gate.z).length()
	var was_near: bool = _near_gate
	_near_gate = distance <= INTERACT_RADIUS
	if _near_gate and not was_near:
		Audio.sfx(&"ui_tick", -10.0)
	if _near_gate:
		_prompt_label.text = "[E]  Enter the cave"
		_prompt_panel.visible = true
		_prompt_panel.reset_size()
		_prompt_panel.position.x = (1920.0 - _prompt_panel.size.x) * 0.5
	else:
		_prompt_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _locked or dialogue.active or not _near_gate:
		return
	if event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		_enter_gate()
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		if (event as InputEventKey).keycode == KEY_SPACE:
			get_viewport().set_input_as_handled()
			_enter_gate()
			return
	if event is InputEventMouseButton:
		var click: InputEventMouseButton = event as InputEventMouseButton
		if click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			if _camera.unproject_position(_gate_marker.position).distance_to(click.position) <= CLICK_PICK_RADIUS:
				get_viewport().set_input_as_handled()
				_enter_gate()


func _enter_gate() -> void:
	Audio.sfx(&"ui_select")
	var dialog: ConfirmDialog = ConfirmDialog.ask(
		_overlay_layer, "Trial of the Hollow",
		"A cold draft rises from the dark. This looks like the only way out. Go in?",
		"Enter", "Not yet",
	)
	_locked = true
	dialog.confirmed.connect(_confirm_enter)
	dialog.cancelled.connect(func() -> void: _locked = false)


## Part C: the element is chosen once, before the very first attempt. A retry after an abandoned
## run (the profile already exists) skips straight back into the dungeon with that same element.
func _confirm_enter() -> void:
	Audio.sfx(&"door")
	if Session.has_profile():
		Session.begin_intro_trial(Session.profile.primary_affinity)
		return
	var choice: ElementChoiceScreen = ElementChoiceScreen.new()
	_overlay_layer.add_child(choice)
	choice.chosen.connect(func(color: Affinity.Type) -> void:
		Audio.sfx(&"ui_confirm")
		choice.queue_free()
		Session.begin_intro_trial(color))


# ---- Screenshot helpers -----------------------------------------------------------------


func screenshot_ready() -> bool:
	return true
