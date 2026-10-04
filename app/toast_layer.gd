class_name ToastLayer
extends CanvasLayer
## A global notification layer (above every scene): short toasts stacked at the top centre. Used for the
## essence-conversion notices (Part F) and any `EventBus.toast_requested`. It never takes input.

const MAX_VISIBLE: int = 4
const LIFETIME: float = 4.6

## The messages shown so far (newest last) - kept for tests and the e2e flows.
var history: Array[String] = []
var _column: VBoxContainer


func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	_column = VBoxContainer.new()
	_column.name = "ToastColumn"
	_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_column.add_theme_constant_override("separation", 8)
	_column.position = Vector2(460, 84)
	_column.custom_minimum_size = Vector2(1000, 0)
	_column.alignment = BoxContainer.ALIGNMENT_BEGIN
	add_child(_column)
	EventBus.essence_converted.connect(_on_essence_converted)
	EventBus.toast_requested.connect(func(text: String) -> void: show_toast(text, UIStyle.PARCHMENT, null))


func _on_essence_converted(message: String, essence: Dictionary, gold: int) -> void:
	var tint: Color = UIStyle.GOLD
	var icon: Texture2D = CardIcons.ui("coins")
	if gold <= 0 and not essence.is_empty():
		tint = UIStyle.affinity_color(int(essence.keys()[0]) as Affinity.Type)
		icon = CardIcons.ui("gems")
	show_toast(message, tint, icon)


## Shows one toast (a panel with an optional tinted icon and the text); it fades after `LIFETIME` seconds.
func show_toast(text: String, tint: Color, icon: Texture2D) -> void:
	history.append(text)
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "Toast"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UIStyle.box(Color(0.07, 0.04, 0.12, 0.94), tint, 3, 14, 12))
	var row: HBoxContainer = UIKit.hbox(12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(row)
	if icon != null:
		row.add_child(CardIcons.glyph(icon, tint, Vector2(38, 38)))
	var label: Label = UIKit.label(text, &"", 24, UIStyle.PARCHMENT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(760, 0)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	panel.modulate.a = 0.0
	_column.add_child(panel)
	while _column.get_child_count() > MAX_VISIBLE:
		_column.get_child(0).queue_free()
		_column.remove_child(_column.get_child(0))
	Audio.sfx(&"coins", -10.0)
	var tween: Tween = panel.create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)
	tween.tween_interval(LIFETIME)
	tween.tween_property(panel, "modulate:a", 0.0, 0.6)
	tween.tween_callback(panel.queue_free)
