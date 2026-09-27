class_name UIKit
extends RefCounted
## Small builders so screens can be assembled in code without boilerplate.


static func label(
	text: String,
	variation: StringName = &"",
	size: int = -1,
	color: Color = Color(0, 0, 0, 0),
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT,
) -> Label:
	var node: Label = Label.new()
	node.text = text
	if variation != &"":
		node.theme_type_variation = variation
	if size > 0:
		node.add_theme_font_size_override("font_size", size)
	if color.a > 0.0:
		node.add_theme_color_override("font_color", color)
	node.horizontal_alignment = align
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


static func rich(text: String, size: int = 22, fit: bool = true) -> RichTextLabel:
	var node: RichTextLabel = RichTextLabel.new()
	node.bbcode_enabled = true
	node.fit_content = fit
	node.scroll_active = false
	node.text = text
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key: String in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		node.add_theme_font_size_override(key, size)
	return node


static func vbox(separation: int = 10) -> VBoxContainer:
	var node: VBoxContainer = VBoxContainer.new()
	node.add_theme_constant_override("separation", separation)
	return node


static func hbox(separation: int = 10) -> HBoxContainer:
	var node: HBoxContainer = HBoxContainer.new()
	node.add_theme_constant_override("separation", separation)
	return node


static func margin(child: Control, pixels: int) -> MarginContainer:
	var node: MarginContainer = MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		node.add_theme_constant_override("margin_" + side, pixels)
	node.add_child(child)
	return node


static func spacer(height: int = 0, width: int = 0) -> Control:
	var node: Control = Control.new()
	node.custom_minimum_size = Vector2(width, height)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


static func filler() -> Control:
	var node: Control = Control.new()
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


static func panel(variation: StringName = &"") -> PanelContainer:
	var node: PanelContainer = PanelContainer.new()
	if variation != &"":
		node.theme_type_variation = variation
	return node


static func full_rect(node: Control) -> void:
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


static func vignette(strength: float = 0.75) -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	full_rect(rect)
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://ui/shaders/vignette.gdshader") as Shader
	material.set_shader_parameter("strength", strength)
	rect.material = material
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


static func gradient_background() -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	full_rect(rect)
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://ui/shaders/gradient_bg.gdshader") as Shader
	rect.material = material
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


## Waits `seconds` of game time (stops while the tree is paused).
static func wait(node: Node, seconds: float) -> Signal:
	return node.get_tree().create_timer(seconds, false).timeout


## Fades and slides a control in (used when panels and screens appear).
static func pop_in(node: Control, delay: float = 0.0) -> void:
	node.modulate.a = 0.0
	var tween: Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "modulate:a", 1.0, 0.3).set_delay(delay)


## CanvasLayers are not Controls, so anchors under them do not resolve. This returns a Control
## the size of the design viewport (1920x1080) to hold a layer's UI.
static func layer_host(layer: CanvasLayer) -> Control:
	var host: Control = Control.new()
	host.position = Vector2.ZERO
	host.size = Vector2(1920, 1080)
	host.custom_minimum_size = Vector2(1920, 1080)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(host)
	return host
