class_name EndingScreen
extends Control
## The ending sequence (Brief 10, Part E), played after Primm falls: seven short beats (the castle crumbles, the facade falls, the rifts
## close, the Wrinkles come up into the light, the four Paths meet, the theme in plain words, a dove), each with a little icon staging and
## typewriter text; then placeholder credits; then the postgame announcement (`AnnouncementScreen`: the Paths Unbound), and the player
## is returned to the Capital, which has changed. All text: the Capital story's `ending.*` keys (`EndingDefs`).
## Advance with click / Space / Enter / E.

signal finished

const STAGE_TINT: Color = Color(0.1, 0.08, 0.16)

var _story: ZoneStoryText
var _index: int = 0
var _stage: Control
var _castle: TextureRect
var _rifts: Array[TextureRect] = []
var _paths: Array[TextureRect] = []
var _extra: Control
var _heading: Label
var _text: Label
var _hint: Label
var _flash: ColorRect
var _tween: Tween
var _done: bool = false
var _credits_running: bool = false
var _screenshot_args: Dictionary = {}


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = false
	Audio.play_music(&"ending")
	Session.ensure_game()
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_story = ZoneStoryText.for_zone(CapitalZone.ID)
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = STAGE_TINT
	UIKit.full_rect(backdrop)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	var glow: ColorRect = UIKit.gradient_background()
	glow.modulate.a = 0.5
	add_child(glow)
	_stage = Control.new()
	UIKit.full_rect(_stage)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	_extra = Control.new()
	UIKit.full_rect(_extra)
	_extra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_extra)
	_castle = _icon("delapouite/castle", Color("f2d070"), 460.0, Vector2(960, 380))
	_stage.add_child(_castle)
	for index: int in range(3):
		var rift: TextureRect = _icon("lorc/magic-swirl", Color("b46cff"), 150.0, Vector2(380.0 + float(index) * 580.0, 250.0 + 150.0 * float(index % 2)))
		_stage.add_child(rift)
		_rifts.append(rift)
	for index: int in range(EndingDefs.PATH_ICONS.size()):
		var spec: Dictionary = EndingDefs.PATH_ICONS[index]
		var corner: Vector2 = [Vector2(260, 200), Vector2(1660, 200), Vector2(260, 560), Vector2(1660, 560)][index]
		var path_icon: TextureRect = _icon(str(spec["icon"]), Color(str(spec["color"])), 210.0, corner)
		path_icon.modulate.a = 0.0
		_stage.add_child(path_icon)
		_paths.append(path_icon)
	var panel: PanelContainer = UIKit.panel()
	panel.position = Vector2(300, 770)
	panel.custom_minimum_size = Vector2(1320, 250)
	panel.size = Vector2(1320, 250)
	add_child(panel)
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	_heading = UIKit.label("", &"HeadingLabel", 32)
	column.add_child(_heading)
	_text = UIKit.label("", &"", 26, UIStyle.PARCHMENT)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(1270, 130)
	column.add_child(_text)
	_hint = UIKit.label("Click / Space to continue", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	column.add_child(_hint)
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	UIKit.full_rect(_flash)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.z_index = 50
	add_child(_flash)
	_index = clampi(int(_screenshot_args.get("beat", 0)), 0, EndingDefs.BEATS.size() - 1)
	for earlier: int in range(_index):
		_apply_end_state(str(EndingDefs.BEATS[earlier]["fx"]))
	_show_beat()
	if _screenshot_args.has("credits"):
		_start_credits.call_deferred()
	if _screenshot_args.has("postgame"):
		_show_postgame.call_deferred()


func _icon(key: String, color: Color, side: float, center: Vector2) -> TextureRect:
	var rect: TextureRect = CardIcons.glyph(CardIcons.named(key), color, Vector2(side, side))
	rect.size = Vector2(side, side)
	rect.pivot_offset = rect.size * 0.5
	rect.position = center - rect.size * 0.5
	return rect


func _show_beat() -> void:
	var beat: Dictionary = EndingDefs.BEATS[_index]
	var n: int = int(beat["n"])
	_heading.text = _story.text(EndingDefs.beat_title_key(n))
	_text.text = "\n".join(_story.get_lines(EndingDefs.beat_key(n)))
	_text.visible_ratio = 0.0
	_hint.text = "Click / Space to continue" if _index < EndingDefs.BEATS.size() - 1 else "Click / Space to see the credits"
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_text, "visible_ratio", 1.0, maxf(0.6, float(_text.text.length()) * 0.014))
	Audio.sfx(&"dialogue", -10.0)
	_fx(str(beat["fx"]))


## The screen stops the mouse, which also keeps clicks away from `_unhandled_input`: handle the click here.
func _gui_input(event: InputEvent) -> void:
	if _done or _credits_running:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		advance()


func _unhandled_input(event: InputEvent) -> void:
	if _done or _credits_running:
		return
	var pressed: bool = false
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: Key = (event as InputEventKey).keycode
		pressed = code == KEY_SPACE or code == KEY_ENTER or code == KEY_E
	elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	advance()


## Finishes the typewriter, or moves to the next beat (and, after the last, to the credits).
func advance() -> void:
	if _text.visible_ratio < 1.0:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		_text.visible_ratio = 1.0
		return
	_index += 1
	if _index >= EndingDefs.BEATS.size():
		_start_credits()
		return
	_show_beat()


# ---- Effects -------------------------------------------------------------------------------------------------------


func _flash_screen(color: Color, peak: float = 0.8) -> void:
	_flash.color = Color(color.r, color.g, color.b, 0.0)
	var flash: Tween = create_tween()
	flash.tween_property(_flash, "color:a", peak, 0.08)
	flash.tween_property(_flash, "color:a", 0.0, 0.6)


func _shake(strength: float, duration: float) -> void:
	var shake: Tween = create_tween()
	for step: int in range(int(duration / 0.04)):
		shake.tween_property(_stage, "position", Vector2(randf_range(-strength, strength), randf_range(-strength, strength)), 0.04)
	shake.tween_property(_stage, "position", Vector2.ZERO, 0.05)


func _burst(at: Vector2, color: Color, amount: int = 90) -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.position = at
	particles.emitting = false
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = 1.6
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2(0, 240)
	particles.initial_velocity_min = 200.0
	particles.initial_velocity_max = 560.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 11.0
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = ramp
	particles.z_index = 40
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(2.0, false).timeout.connect(particles.queue_free)


func _fx(name: String) -> void:
	match name:
		"crumble":
			_flash_screen(Color("ffffff"), 0.9)
			_shake(20.0, 0.9)
			_burst(_castle.position + _castle.size * 0.5, Color("cfc8d8"), 140)
			_castle.texture = CardIcons.named("delapouite/castle-ruins")
			(_castle.material as ShaderMaterial).set_shader_parameter("tint", Color("b8b0c8"))
			Audio.sfx(&"hit_heavy", 0.0)
		"throne":
			_flash_screen(Color("ffe9a8"), 0.85)
			(_castle.material as ShaderMaterial).set_shader_parameter("tint", Color(0.72, 0.69, 0.78, 0.2))
			var seat: TextureRect = _icon("delapouite/imperial-crown", Color("f2c14e"), 300.0, Vector2(960, 540))
			seat.modulate.a = 0.0
			_extra.add_child(seat)
			var glow: Tween = create_tween()
			glow.tween_property(seat, "modulate:a", 1.0, 1.2)
			for index: int in range(EndingDefs.PATH_ICONS.size()):
				_burst(Vector2(660.0 + 200.0 * float(index), 560.0), Color(str(EndingDefs.PATH_ICONS[index]["color"])), 60)
			Audio.sfx(&"victory", -4.0)
		"primm_sees":
			var mirror: TextureRect = _icon("delapouite/shinto-shrine-mirror", Color("cfc8d8"), 240.0, Vector2(960, 560))
			mirror.modulate.a = 0.0
			_extra.add_child(mirror)
			var clear: Tween = create_tween()
			clear.tween_property(mirror, "modulate:a", 1.0, 1.0)
			clear.tween_property(mirror, "modulate:a", 0.0, 1.4)
			Audio.sfx(&"heal", -4.0)
		"stamp":
			var mark: Label = UIKit.label("HEIR: ALIVE.\nFILE COMPLETE.", &"", 74, Color("d9402f"), HORIZONTAL_ALIGNMENT_CENTER)
			mark.size = Vector2(900, 220)
			mark.pivot_offset = mark.size * 0.5
			mark.position = Vector2(960.0, 380.0) - mark.size * 0.5
			mark.rotation_degrees = -9.0
			mark.scale = Vector2(2.4, 2.4)
			mark.modulate.a = 0.0
			mark.z_index = 30
			_extra.add_child(mark)
			var slam: Tween = create_tween().set_parallel(true)
			slam.tween_property(mark, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			slam.tween_property(mark, "modulate:a", 1.0, 0.18)
			get_tree().create_timer(0.2, false).timeout.connect(func() -> void:
				_shake(16.0, 0.4)
				_burst(Vector2(960, 400), Color("d9402f"), 50))
			Audio.sfx(&"hit_heavy", -2.0)
		"facade":
			_shake(10.0, 0.5)
			var wall: TextureRect = _icon("delapouite/broken-wall", Color("e8e0d0"), 260.0, Vector2(560, 560))
			var party: TextureRect = _icon("delapouite/party-flags", Color("f2c14e"), 230.0, Vector2(1360, 560))
			party.modulate.a = 0.0
			_extra.add_child(wall)
			_extra.add_child(party)
			var show: Tween = create_tween()
			show.tween_property(party, "modulate:a", 1.0, 1.2)
			_burst(wall.position + wall.size * 0.5, Color("e8e0d0"), 80)
		"rifts":
			_flash_screen(Color("b8e8ff"), 0.6)
			for rift: TextureRect in _rifts:
				var close: Tween = create_tween().set_parallel(true)
				close.tween_property(rift, "scale", Vector2(0.05, 0.05), 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				close.tween_property(rift, "rotation_degrees", 360.0, 1.0)
				close.tween_property(rift, "modulate:a", 0.0, 1.0)
			Audio.sfx(&"spell", -2.0)
		"wrinkles":
			var lamp: TextureRect = _icon("delapouite/scroll-quill", Color("ffd9a0"), 220.0, Vector2(960, 560))
			lamp.modulate.a = 0.0
			_extra.add_child(lamp)
			var rise: Tween = create_tween()
			rise.tween_property(lamp, "modulate:a", 1.0, 1.0)
			Audio.sfx(&"heal")
		"reunion":
			for index: int in range(_paths.size()):
				var show_path: Tween = create_tween()
				show_path.tween_property(_paths[index], "modulate:a", 1.0, 0.5 + 0.25 * float(index))
			Audio.sfx(&"turn_start")
		"unite":
			var centre: Vector2 = Vector2(960, 380)
			for path_icon: TextureRect in _paths:
				var move: Tween = create_tween().set_parallel(true)
				move.tween_property(path_icon, "position", centre - path_icon.size * 0.5 + Vector2(randf_range(-60, 60), randf_range(-40, 40)), 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
				move.tween_property(path_icon, "scale", Vector2(0.8, 0.8), 1.4)
			var hearts: TextureRect = _icon("delapouite/nested-hearts", Color("ffd36b"), 360.0, centre)
			hearts.modulate.a = 0.0
			hearts.scale = Vector2(0.4, 0.4)
			_extra.add_child(hearts)
			var swell: Tween = create_tween().set_parallel(true)
			swell.tween_property(hearts, "modulate:a", 1.0, 1.4).set_delay(0.9)
			swell.tween_property(hearts, "scale", Vector2.ONE, 1.4).set_delay(0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			get_tree().create_timer(1.6, false).timeout.connect(func() -> void:
				_flash_screen(Color("ffd36b"), 0.7)
				_burst(centre, Color("ffd36b"), 120))
			Audio.sfx(&"victory", -3.0)
		"dove":
			var dove: TextureRect = _icon("delapouite/peace-dove", Color("f4fff0"), 260.0, Vector2(960, 560))
			dove.modulate.a = 0.0
			_extra.add_child(dove)
			var fly: Tween = create_tween().set_parallel(true)
			fly.tween_property(dove, "modulate:a", 1.0, 0.8)
			fly.tween_property(dove, "position", dove.position + Vector2(0, -220), 2.4).set_trans(Tween.TRANS_SINE)
			_burst(Vector2(960, 560), Color("f4fff0"), 70)
			Audio.sfx(&"heal")


## Used to jump to a later beat (screenshots): puts the stage in the state the earlier beats leave it in.
func _apply_end_state(name: String) -> void:
	match name:
		"crumble":
			_castle.texture = CardIcons.named("delapouite/castle-ruins")
		"throne":
			(_castle.material as ShaderMaterial).set_shader_parameter("tint", Color(0.72, 0.69, 0.78, 0.2))
		"rifts":
			for rift: TextureRect in _rifts:
				rift.modulate.a = 0.0
		"reunion":
			for path_icon: TextureRect in _paths:
				path_icon.modulate.a = 1.0


# ---- Credits, the postgame announcement, back to the world ---------------------------------------------------------------


func _start_credits() -> void:
	if _credits_running:
		return
	_credits_running = true
	_done = true
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.0)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.z_index = 60
	add_child(shade)
	var fade: Tween = create_tween()
	fade.tween_property(shade, "color:a", 0.94, 1.0)
	var lines: Array[String] = []
	for index: int in range(1, EndingDefs.CREDITS_LINES + 1):
		lines.append_array(_story.get_lines("ending.credits.%d" % index))
	var credits: Label = UIKit.label("\n\n".join(lines), &"", 34, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	credits.name = "Credits"
	credits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credits.custom_minimum_size = Vector2(1100, 0)
	credits.size = Vector2(1100, 1400)
	credits.position = Vector2(410, 1080)
	credits.z_index = 70
	add_child(credits)
	var scroll: Tween = create_tween()
	var travel: float = 1080.0 + float(lines.size()) * 90.0
	scroll.tween_property(credits, "position:y", -travel, 2.0 + float(lines.size()) * 1.6)
	scroll.tween_callback(_show_postgame)
	var skip: FancyButton = FancyButton.make("Skip", &"", Vector2(160, 52))
	skip.position = Vector2(1720, 996)
	skip.z_index = 80
	skip.pressed.connect(func() -> void:
		scroll.kill()
		_show_postgame())
	add_child(skip)


func _show_postgame() -> void:
	if get_node_or_null("PostgameAnnouncement") != null:
		return
	var lines: Array[String] = []
	for index: int in range(1, EndingDefs.POSTGAME_LINES + 1):
		lines.append(_story.text("ending.postgame.line.%d" % index))
	var screen: AnnouncementScreen = AnnouncementScreen.make(_story.text("ending.postgame.title"), _story.text("ending.postgame.body"), lines, Color("9cf5a0"))
	screen.name = "PostgameAnnouncement"
	screen.z_index = 200
	add_child(screen)
	screen.finished.connect(_return_to_world, CONNECT_ONE_SHOT)


func _return_to_world() -> void:
	finished.emit()
	Session.return_from_ending()
