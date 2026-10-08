class_name StartingAreaScene
extends Node3D
## Where a new campaign begins: the hero wakes up alone in a small forest clearing, talks to
## themselves, and the only way forward is the cave mouth into the Forgotten Cave. Entering
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
## Polish round: the treeline nooks' hidden chests use the same tight radius.
const CHEST_RADIUS: float = 1.5
## Story v2: how close to the treeline the hero may get before talking themselves back to the cave.
const EDGE_PROBE: float = 0.7

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
var _chest_near: String = ""
var _locked: bool = false
var _screenshot_args: Dictionary = {}
var minimap: MinimapHud
## Polish round: the endless forest around the clearing (visual only).
var forest: StartingForest
var _rescuer: Node3D
var _maren: Node3D
var _self_talk_cooldown: float = 0.0
var _self_talk_index: int = 0


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
	ChestKit.apply_saved(area.chest_nodes, StartingAreaScene._chest_secret)
	if _screenshot_args.has("pos"):
		var pos: PackedStringArray = str(_screenshot_args["pos"]).split(",")
		player.position = Vector3(float(pos[0]), 0.0, float(pos[1]))
		_camera.position = player.position + _camera_offset * Settings.camera_zoom
	if str(_screenshot_args.get("nohud", "false")) == "true":
		for child: Node in get_children():
			if child is CanvasLayer:
				(child as CanvasLayer).visible = false
	# Screenshot helpers: show the Rescuer or Elder Maren without playing their scenes.
	if str(_screenshot_args.get("show", "")) == "rescuer":
		_spawn_rescuer()
	elif str(_screenshot_args.get("show", "")) == "maren":
		var mouth: Vector3 = area.anchors.get("gate", Vector3.ZERO) as Vector3
		_maren = ModelKit.character("Mage")
		TortoiseKit.add_shell(_maren)
		ModelKit.place(self, _maren, mouth + Vector3(0.0, 0.0, 2.3), 180.0, TownPlayer.MODEL_SCALE)
		player.position = mouth + Vector3(0.0, 0.0, 0.5)
	if Session.cave_exit_pending and Session.profile != null and not _screenshot_args.has("quiet"):
		Session.cave_exit_pending = false
		_begin_cave_exit.call_deferred()
	elif not Session.flag(&"rescuer_met") and Session.profile == null and not _screenshot_args.has("quiet"):
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
	var cells: Array[Vector2i] = []
	for row: int in range(StartingAreaBuilder.MAP.size()):
		for col: int in range(StartingAreaBuilder.MAP[row].length()):
			cells.append(Vector2i(col, row))
	forest = StartingForest.build(self, cells, spawn, Settings.graphics_quality)


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
	if story == null or story.awakening_lines.is_empty() or Session.flag(&"awakened"):
		_start_rescuer_scene()
		return
	Session.set_flag(&"awakened")
	Session.save_game()
	dialogue.start("", story.awakening_lines, NpcRegistry.PLAYER_ID)
	dialogue.finished.connect(_start_rescuer_scene, CONNECT_ONE_SHOT)


# ---- Story v2 prologue: the Rescuer ------------------------------------------------------------------------------------------------------


## A hooded Rescuer kneels beside the Wanderer, asks if they can still fight, has them choose the one Path they can carry (the starting deck), points to
## the Forgotten Cave and slips back into the trees.
func _start_rescuer_scene() -> void:
	_locked = true
	var rescuer_pos: Vector3 = _spawn_rescuer()
	player.face(rescuer_pos)
	_say_rescuer("prologue.rescuer.1", func() -> void:
		_say_wanderer("prologue.wanderer.1", func() -> void:
			_say_rescuer("prologue.rescuer.2", func() -> void:
				_say_wanderer("prologue.wanderer.2", func() -> void:
					_say_rescuer("prologue.rescuer.3", _choose_path_in_conversation)))))


## The hooded Rescuer, kneeling a step from the spot where the Wanderer woke. Returns where.
func _spawn_rescuer() -> Vector3:
	var spawn: Vector3 = area.anchors.get("spawn", Vector3.ZERO) as Vector3
	_rescuer = ModelKit.character("Rogue_Hooded")
	ModelKit.tint(_rescuer, Color(0.62, 0.58, 0.7))
	var rescuer_pos: Vector3 = spawn + Vector3(1.0, 0.0, -0.3)
	ModelKit.place(self, _rescuer, rescuer_pos, rad_to_deg(atan2(spawn.x - rescuer_pos.x, spawn.z - rescuer_pos.z)), TownPlayer.MODEL_SCALE)
	var animation: AnimationPlayer = ModelKit.animation_player(_rescuer)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
	return rescuer_pos


func _say_rescuer(key: String, then: Callable) -> void:
	dialogue.start(RoyalFamily.fill("{rescuer}"), StoryText.shared().get_lines(key), "NPC-RESCUER")
	dialogue.finished.connect(then, CONNECT_ONE_SHOT)


func _say_wanderer(key: String, then: Callable) -> void:
	dialogue.start("", StoryText.shared().get_lines(key), NpcRegistry.PLAYER_ID)
	dialogue.finished.connect(then, CONNECT_ONE_SHOT)


## The starting deck choice (moved here from the cave gate): the same four-tile screen, now asked in the Rescuer's conversation.
func _choose_path_in_conversation() -> void:
	var choice: ElementChoiceScreen = ElementChoiceScreen.new()
	_overlay_layer.add_child(choice)
	choice.chosen.connect(func(color: Affinity.Type) -> void:
		Audio.sfx(&"ui_confirm")
		choice.queue_free()
		Session.choose_starting_path(color)
		_say_rescuer("prologue.rescuer.4", _rescuer_leaves))


func _rescuer_leaves() -> void:
	var fade: Tween = create_tween().set_parallel(true)
	var away: Vector3 = _rescuer.position + Vector3(1.4, 0.0, -1.0)
	fade.tween_property(_rescuer, "position", away, 1.6)
	for node: Node in _rescuer.find_children("*", "GeometryInstance3D", true, false):
		fade.tween_property(node, "transparency", 1.0, 1.4)
	fade.finished.connect(func() -> void:
		_rescuer.queue_free()
		_rescuer = null
		_say_wanderer("prologue.wanderer.3", func() -> void:
			_locked = false))


## Walking into the treeline (outside the nooks and the tunnel, which are secrets on purpose) makes the Wanderer talk themselves back to the cave. No exploring yet.
func _check_forest_edge(delta: float) -> void:
	_self_talk_cooldown = maxf(0.0, _self_talk_cooldown - delta)
	if _self_talk_cooldown > 0.0 or _locked or dialogue.active or not Session.flag(&"rescuer_met") or Session.flag(&"trial_cleared"):
		return
	for key: String in area.anchors.keys():
		if key.begins_with("hidden_chest_") or key == "tunnel":
			var secret: Vector3 = area.anchors[key] as Vector3
			if Vector2(player.position.x - secret.x, player.position.z - secret.z).length() < 2.2:
				return
	var at_edge: bool = false
	for step: int in range(8):
		var angle: float = TAU * float(step) / 8.0
		var probe: Vector3 = player.position + Vector3(cos(angle), 0.0, sin(angle)) * EDGE_PROBE
		if not area.is_floor_at(probe):
			at_edge = true
			break
	if not at_edge:
		return
	_self_talk_cooldown = 9.0
	var lines: Array[String] = StoryText.shared().get_lines("prologue.self_talk")
	var line: String = lines[_self_talk_index % lines.size()]
	_self_talk_index += 1
	dialogue.start("", [line] as Array[String], NpcRegistry.PLAYER_ID)
	# Turned gently back toward the cave.
	var gate: Vector3 = area.anchors.get("gate", Vector3.ZERO) as Vector3
	var back: Vector3 = player.position.move_toward(Vector3(gate.x, player.position.y, gate.z + 1.2), 0.9)
	if area.is_walkable(back):
		player.position = back


# ---- Story v2: Elder Maren waits at the cave mouth ----------------------------------------------------------------------------------------


func _begin_cave_exit() -> void:
	_locked = true
	var gate: Vector3 = area.anchors.get("gate", Vector3.ZERO) as Vector3
	player.position = gate + Vector3(0.0, 0.0, 0.5)
	_camera.position = player.position + _camera_offset * Settings.camera_zoom
	var maren_pos: Vector3 = gate + Vector3(0.0, 0.0, 2.3)
	_maren = ModelKit.character("Mage")
	TortoiseKit.add_shell(_maren)
	ModelKit.place(self, _maren, maren_pos, 180.0, TownPlayer.MODEL_SCALE)
	player.face(maren_pos)
	_say_maren("cave_mouth.maren", func() -> void:
		_say_wanderer("cave_mouth.wanderer", func() -> void:
			_say_maren("cave_mouth.maren_end", func() -> void:
				Session.set_flag(&"maren_met")
				Session.save_game()
				SceneManager.go_to_town())))


func _say_maren(key: String, then: Callable) -> void:
	dialogue.start("Elder Maren", StoryText.shared().get_lines(key), "NPC-ELDER")
	dialogue.finished.connect(then, CONNECT_ONE_SHOT)


func _process(delta: float) -> void:
	var target: Vector3 = player.position + _camera_offset * Settings.camera_zoom
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	if _custom_camera:
		_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)
	else:
		_camera.rotation_degrees = Vector3(-atan2(CAMERA_OFFSET.y, CAMERA_OFFSET.z) * 180.0 / PI, 0.0, 0.0)
	_check_forest_edge(delta)
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
		_chest_near = ""
		return
	var gate: Vector3 = area.anchors.get("gate", Vector3.ZERO) as Vector3
	var gate_distance: float = Vector2(player.position.x - gate.x, player.position.z - gate.z).length()
	var was_near_gate: bool = _near_gate
	_near_gate = gate_distance <= INTERACT_RADIUS
	var near_tunnel_now: bool = false
	if not Session.flag(&"trial_cleared") and area.anchors.has("tunnel"):
		var tunnel: Vector3 = area.anchors["tunnel"] as Vector3
		var tunnel_distance: float = Vector2(player.position.x - tunnel.x, player.position.z - tunnel.z).length()
		near_tunnel_now = tunnel_distance <= TUNNEL_RADIUS
	var was_near_tunnel: bool = _near_tunnel
	_near_tunnel = near_tunnel_now
	if (_near_gate and not was_near_gate) or (_near_tunnel and not was_near_tunnel):
		Audio.sfx(&"ui_tick", -10.0)
	_chest_near = _find_chest_in_reach()
	if _near_gate:
		_prompt_label.text = "[E]  Enter the cave"
	elif _chest_near != "":
		_prompt_label.text = "[E]  Open the chest"
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
	if _chest_near != "" and not _near_gate and (event.is_action_pressed(&"interact") or (event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_SPACE)):
		get_viewport().set_input_as_handled()
		_open_chest(_chest_near)
		return
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


## The id of the unopened hidden chest within CHEST_RADIUS of the hero, or "".
func _find_chest_in_reach() -> String:
	for id: String in StartingAreaBuilder.HIDDEN_CHESTS.keys():
		if Session.found_secret(_chest_secret(id)):
			continue
		var pos: Vector3 = area.anchors.get("hidden_chest_%s" % id, Vector3.ZERO) as Vector3
		if Vector2(player.position.x - pos.x, player.position.z - pos.z).length() <= CHEST_RADIUS:
			return id
	return ""


static func _chest_secret(id: String) -> String:
	return "hidden_chest_%s" % id


## Opens a nook chest: the lid swings up, then the reward box (gold only here - there is no profile yet) until the player confirms.
func _open_chest(id: String) -> void:
	var pos: Vector3 = area.anchors.get("hidden_chest_%s" % id, Vector3.ZERO) as Vector3
	player.face(pos)
	if Session.found_secret(_chest_secret(id)):
		return
	Session.discover_secret(_chest_secret(id))
	var reward: Dictionary = {"gold": int((StartingAreaBuilder.HIDDEN_CHESTS[id] as Dictionary)["gold"])}
	var summary: RewardSummary = Session.grant_chest_reward(reward, "Hidden chest")
	Session.save_game()
	_locked = true
	player.input_enabled = false
	Audio.sfx(&"chest_open")
	Audio.sfx(&"coins", 0.0, 0.05)
	ChestKit.open_animated(area.chest_nodes.get(id) as Node3D)
	await get_tree().create_timer(0.7).timeout
	var popup: RewardPopup = RewardPopup.make(summary)
	_overlay_layer.add_child(popup)
	Audio.sfx(&"ui_open")
	popup.finished.connect(func() -> void:
		popup.queue_free()
		_locked = false
		Audio.sfx(&"ui_close", -4.0))


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
	dialogue.start("", StoryText.shared().get_lines("start.tunnel"), NpcRegistry.PLAYER_ID)
	dialogue.finished.connect(func() -> void:
		if Session.profile != null:
			# The Path was already chosen in the Rescuer's conversation; the shortcut keeps it.
			Session.skip_tutorial_via_secret_tunnel(Session.profile.primary_affinity)
			SceneManager.go_to_town()
			return
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
