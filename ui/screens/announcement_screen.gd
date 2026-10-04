class_name AnnouncementScreen
extends Control
## A celebratory full-screen announcement: a big title, a paragraph, optional extra lines (what just
## unlocked) and a Continue button, with an animated entrance, a particle burst and a sound. Used when
## a zone is freed (Part D) and when the Arena / the Alchemist open (Parts F, G).

signal finished

var title: String = ""
var body: String = ""
var extra_lines: Array[String] = []
var accent: Color = UIStyle.GOLD
var _panel: PanelContainer


## `lines` are shown as gold bullet rows under the paragraph (unlock notices).
static func make(title_text: String, body_text: String, lines: Array[String] = [], accent_color: Color = UIStyle.GOLD) -> AnnouncementScreen:
	var screen: AnnouncementScreen = AnnouncementScreen.new()
	screen.name = "AnnouncementScreen"
	screen.title = title_text
	screen.body = body_text
	screen.extra_lines = lines
	screen.accent = accent_color
	return screen


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.06, 0.82)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	_panel = UIKit.panel()
	_panel.custom_minimum_size = Vector2(900, 0)
	center.add_child(_panel)
	var column: VBoxContainer = UIKit.vbox(16)
	_panel.add_child(column)
	var heading: Label = UIKit.label(title, &"TitleLabel", 62, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	heading.name = "AnnouncementTitle"
	heading.add_theme_color_override("font_color", accent)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(heading)
	var text: Label = UIKit.label(body, &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.name = "AnnouncementBody"
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(820, 0)
	column.add_child(text)
	for line: String in extra_lines:
		var row: Label = UIKit.label(line, &"HeadingLabel", 24, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
		row.add_theme_color_override("font_color", accent)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(row)
	column.add_child(UIKit.spacer(6))
	var button: FancyButton = FancyButton.make("Continue", &"PrimaryButton", Vector2(260, 62))
	button.name = "ContinueButton"
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_continue)
	column.add_child(button)
	_animate_in()
	Audio.sfx(&"level_up")


func _continue() -> void:
	Audio.sfx(&"ui_confirm")
	finished.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept") and is_visible_in_tree():
		get_viewport().set_input_as_handled()
		_continue()


func _animate_in() -> void:
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(0.6, 0.6)
	_panel.modulate.a = 0.0
	var tween: Tween = _panel.create_tween().set_parallel(true)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.35)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for burst: int in range(3):
		get_tree().create_timer(0.25 * float(burst), false).timeout.connect(_burst.bind(float(burst)))


func _burst(index: float) -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	var size: Vector2 = get_viewport_rect().size
	particles.position = Vector2(size.x * (0.3 + 0.2 * index), size.y * 0.5)
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 60
	particles.lifetime = 1.4
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2(0, 280)
	particles.initial_velocity_min = 180.0
	particles.initial_velocity_max = 520.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 10.0
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, accent)
	ramp.set_color(1, Color(accent.r, accent.g, accent.b, 0.0))
	particles.color_ramp = ramp
	particles.z_index = 250
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(1.8, false).timeout.connect(particles.queue_free)
