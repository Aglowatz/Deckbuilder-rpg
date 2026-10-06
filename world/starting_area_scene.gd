class_name StartingAreaScene
extends Node3D
## Where a new campaign begins: the hero wakes up alone in a small forest clearing, talks to
## themselves, and the only way forward is the cave mouth into the Trial of the Hollow. Entering
## it for the first time asks which element (`ElementChoiceScreen`, Part C) before the dungeon
## actually starts. No town access from here - see docs/design/starting_deck_and_affinity.md.

const STORY_PATH: String = "res://data/story/intro_story.tres"
const CAMERA_OFFSET: Vector3 = Vector3(0.0, 8.4, 7.0)

## Screenshot only: `--cam=x,y,z` replaces the camera offset and the camera then looks at the hero (any yaw).
var _camera_offset: Vector3 = CAMERA_OFFSET
var _custom_camera: bool = false
const INTERACT_RADIUS: float = 1.7
## How close (in screen pixels) a click has to land to the gate's marker to count as clicking it.
const CLICK_PICK_RADIUS: float = 90.0
## New brief (third), Part D: the hidden tunnel's interact radius - tight, like the town's hidden
## chests, since the only tell it exists at all is this prompt appearing once genuinely close.
const TUNNEL_RADIUS: float = 1.5

var area: StartingAreaBuilder = StartingAreaBuilder.new()
var player: TownPlayer
var dialogue: DialogueBox
var _camera: Camera3D
var _overlay_layer: Control
var _prompt_panel: PanelContainer
var _prompt_label: Label
var _gate_marker: Node3D
var _near_gate: bool = false
var _near_tunnel: bool = false
var _locked: bool = false
var _screenshot_args: Dictionary = {}
var minimap: MinimapHud


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = true
	Audio.play_music(&"map")
	if not _screenshot_args.is_empty() and str(_screenshot_args.get("fresh", "false")) == "true":
		Session.new_game()
	elif Session.profile == null and not Session.flag(&"awakened"):
		Session.new_game()
	area.build(self)
	if _screenshot_args.has("cam"):
		var cam: PackedStringArray = str(_screenshot_args["cam"]).split(",")
		_camera_offset = Vector3(float(cam[0]), float(cam[1]), float(cam[2]))
		_custom_camera = true
	_build_actors()
	_build_ui()
	if _screenshot_args.has("pos"):
		var pos: PackedStringArray = str(_screenshot_args["pos"]).split(",")
		player.position = Vector3(float(pos[0]), 0.0, float(pos[1]))
		_camera.position = player.position + _camera_offset * Settings.camera_zoom
	if str(_screenshot_args.get("nohud", "false")) == "true":
		for child: Node in get_children():
			if child is CanvasLayer:
				(child as CanvasLayer).visible = false
	if not Session.flag(&"awakened") and not _screenshot_args.has("quiet"):
		Session.set_flag(&"awakened")
		Session.save_game()
		_play_awakening.call_deferred()
	Session.save_game()


func _build_actors() -> void:
	var spawn: Vector3 = area.anchors.get("spawn", Vector3.ZERO) as Vector3
	player = TownPlayer.new()
	add_child(player)
	player.setup(area, "Hero", spawn)
	var moon: OmniLight3D = OmniLight3D.new()
	moon.light_color = Color("ffe6b0")
	moon.light_energy = 2.0
	moon.omni_range = 6.0
	moon.omni_attenuation = 1.2
	moon.position = spawn + Vector3(0.0, 3.2, 0.6)
	add_child(moon)
	var gate_pos: Vector3 = area.anchors.get("gate", Vector3.ZERO) as Vector3
	StyleBeacon.build(self, gate_pos + Vector3(0.0, 0.0, -0.9), Color(0.4, 1.0, 0.9), 6.0, 0.14)
	var gate_light: OmniLight3D = OmniLight3D.new()
	gate_light.light_color = Color("5ff0d8")
	gate_light.light_energy = 1.5
	gate_light.omni_range = 5.0
	gate_light.position = gate_pos + Vector3(0.0, 1.4, 0.2)
	add_child(gate_light)
	_gate_marker = Node3D.new()
	_gate_marker.position = (area.anchors.get("gate", Vector3.ZERO) as Vector3) + Vector3(0, 1.6, 0)
	add_child(_gate_marker)
	_camera = Camera3D.new()
	_camera.fov = 40.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + _camera_offset * Settings.camera_zoom
	_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)
	var rig: StyleRig = StyleRig.install(self, StylePresets.START, _camera, player)
	if rig != null and rig.ambience != null:
		rig.ambience.focus(0.45, 1.5)
	var fader: CloudFader = CloudFader.new()
	fader.camera = _camera
	fader.target = player
	add_child(fader)
	for cloud: Node3D in area.clouds:
		fader.adopt(cloud, 2.0)
	if rig != null:
		ZoneDressing.build(self, area, StylePresets.START, Settings.graphics_quality)
		_worn_path()


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
	# New brief, Part B: only shown once a deck actually exists (a returning profile - see
	# docs/design/open_questions.md D64); a brand-new arrival has nothing to edit yet.
	if Session.deck != null:
		var deck_button: FancyButton = FancyButton.make("Deck (B)", &"", Vector2(180, 52))
		deck_button.position = Vector2(1650, 28)
		deck_button.pressed.connect(_open_deck_builder)
		host.add_child(deck_button)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)
	minimap = MinimapHud.new()
	host.add_child(minimap)
	minimap.setup("start", area, player, _collect_pois)
	minimap.full_map_requested.connect(_open_full_map)


## Minimap points of interest: the cave gate only. The hidden tunnel is a secret and never shown.
func _collect_pois() -> Array[MapPoi]:
	return [MapPoi.make(MapPoi.Kind.DUNGEON, area.anchors.get("gate", Vector3.ZERO) as Vector3, "Cave gate")] as Array[MapPoi]


func _open_full_map() -> void:
	if _locked or dialogue.active:
		return
	_locked = true
	var screen: FullMapScreen = FullMapScreen.new()
	screen.setup("start", area, player, _collect_pois(), "The Awakening")
	_overlay_layer.add_child(screen)
	screen.closed.connect(func() -> void:
		screen.queue_free()
		_locked = false)


func _play_awakening() -> void:
	if not Session.cosmetics.look_chosen:
		_choose_look()
		return
	_play_awakening_lines()


## The new-game choice of a starting hat and cloak (a short, friendly screen before the first words of the story).
func _choose_look() -> void:
	_locked = true
	var screen: WardrobeScreen = WardrobeScreen.starter()
	_overlay_layer.add_child(screen)
	screen.closed.connect(func() -> void:
		screen.queue_free()
		_locked = false
		_play_awakening_lines())


func _play_awakening_lines() -> void:
	var story: StoryText = load(STORY_PATH) as StoryText
	if story == null or story.awakening_lines.is_empty():
		return
	dialogue.start("", story.awakening_lines)


func _process(delta: float) -> void:
	var target: Vector3 = player.position + _camera_offset * Settings.camera_zoom
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	if _custom_camera:
		_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)
	else:
		_camera.rotation_degrees = Vector3(-atan2(CAMERA_OFFSET.y, CAMERA_OFFSET.z) * 180.0 / PI, 0.0, 0.0)
	_update_prompt()
	player.input_enabled = not _locked and not dialogue.active


## Both the cave gate and (on a brand-new profile only) the hidden tunnel share the one prompt
## panel - the gate wins if both were ever in range at once, which never happens in practice given
## how far apart they are.
func _update_prompt() -> void:
	if _locked or dialogue.active:
		_prompt_panel.visible = false
		_near_gate = false
		_near_tunnel = false
		return
	var gate: Vector3 = area.anchors.get("gate", Vector3.ZERO) as Vector3
	var gate_distance: float = Vector2(player.position.x - gate.x, player.position.z - gate.z).length()
	var was_near_gate: bool = _near_gate
	_near_gate = gate_distance <= INTERACT_RADIUS
	var near_tunnel_now: bool = false
	if Session.profile == null and area.anchors.has("tunnel"):
		var tunnel: Vector3 = area.anchors["tunnel"] as Vector3
		var tunnel_distance: float = Vector2(player.position.x - tunnel.x, player.position.z - tunnel.z).length()
		near_tunnel_now = tunnel_distance <= TUNNEL_RADIUS
	var was_near_tunnel: bool = _near_tunnel
	_near_tunnel = near_tunnel_now
	if (_near_gate and not was_near_gate) or (_near_tunnel and not was_near_tunnel):
		Audio.sfx(&"ui_tick", -10.0)
	if _near_gate:
		_prompt_label.text = "[E]  Enter the cave"
	elif _near_tunnel:
		_prompt_label.text = "[E]  Slip through the tunnel"
	else:
		_prompt_panel.visible = false
		return
	_prompt_panel.visible = true
	_prompt_panel.reset_size()
	_prompt_panel.position.x = (1920.0 - _prompt_panel.size.x) * 0.5


func _unhandled_input(event: InputEvent) -> void:
	# New brief, Part B: the deck builder hotkey works here too, once a deck actually exists to
	# edit (a returning profile after an abandoned run - a brand-new arrival has no deck yet,
	# see docs/design/open_questions.md D64).
	if not _locked and not dialogue.active and event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_M:
		get_viewport().set_input_as_handled()
		_open_full_map()
		return
	if not _locked and not dialogue.active and Session.deck != null and event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_B:
		get_viewport().set_input_as_handled()
		_open_deck_builder()
		return
	if _locked or dialogue.active:
		return
	# New brief (third), Part D: the hidden tunnel - E/Space only, like the town's hidden chests
	# (no marker to click on).
	if _near_tunnel and not _near_gate:
		if event.is_action_pressed(&"interact") or (event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_SPACE):
			get_viewport().set_input_as_handled()
			_enter_tunnel()
		return
	if not _near_gate:
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
		_overlay_layer, StoryText.shared().text("start.gate_title"),
		StoryText.shared().text("start.gate_prompt"),
		"Enter", "Not yet",
	)
	_locked = true
	dialog.confirmed.connect(_confirm_enter)
	dialog.cancelled.connect(func() -> void: _locked = false)


## New brief (third), Part D: the hidden tunnel - a short flavor line so it feels intentional (not
## a shortcut nobody wrote for), then the same element choice as the real gate, then straight to
## town: a legal 45-card deck, the tutorial's own total XP/gold, and the tutorial-complete flags
## (`Session.skip_tutorial_via_secret_tunnel`), no dungeon in between.
func _enter_tunnel() -> void:
	Audio.sfx(&"ui_select")
	_locked = true
	dialogue.start("", StoryText.shared().get_lines("start.tunnel"))
	dialogue.finished.connect(func() -> void:
		var choice: ElementChoiceScreen = ElementChoiceScreen.new()
		_overlay_layer.add_child(choice)
		choice.chosen.connect(func(color: Affinity.Type) -> void:
			Audio.sfx(&"ui_confirm")
			choice.queue_free()
			Session.skip_tutorial_via_secret_tunnel(color)
			SceneManager.go_to_town()), CONNECT_ONE_SHOT)


## Part C: the element is chosen once, before the very first attempt. A retry after an abandoned
## run (the profile already exists) skips straight back into the dungeon with that same element.
func _open_deck_builder() -> void:
	Audio.sfx(&"ui_open")
	_locked = true
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	_overlay_layer.add_child(screen)
	screen.closed.connect(func() -> void:
		screen.queue_free()
		_locked = false
		Audio.sfx(&"ui_close", -4.0))


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


## A faint worn trail from the arrival spot to the cave gate, so the first thing the eye finds is where to go.
func _worn_path() -> void:
	var spawn: Vector3 = area.anchors.get("spawn", Vector3.ZERO) as Vector3
	var gate: Vector3 = (area.anchors.get("gate", Vector3.ZERO) as Vector3) + Vector3(0.0, 0.0, 0.6)
	var points: Array[Vector3] = []
	for i: int in range(7):
		var t: float = float(i) / 6.0
		var wobble: float = sin(t * 6.0) * 0.25
		var p: Vector3 = spawn.lerp(gate, t) + Vector3(wobble, 0.0, 0.0)
		p.y = area.height_at(p)
		points.append(p)
	GroundDecals.add_path(self, points, GroundDecals.Kind.WORN_PATH, 1.0, [Color("8a8470"), Color("6a6a60")], 3.0)
