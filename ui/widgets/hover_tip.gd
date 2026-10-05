class_name HoverTip
extends RefCounted
## A reliable hover tooltip for HUD widgets (zone effects, broken services): a styled panel that appears beside the hovered control while the mouse is over it and
## is freed when it leaves. Independent of the engine tooltip delay and of the mouse filters of the containers around it. Works in the town/zone HUD, the dungeon map
## and the battle HUD alike.

const WIDTH: float = 460.0


## `title` is bold, `body` explains exactly what the effect does. The control must be able to receive the mouse (STOP/PASS).
static func attach(target: Control, title: String, body: String, accent: Color = UIStyle.GOLD) -> void:
	if target.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		target.mouse_filter = Control.MOUSE_FILTER_PASS
	var holder: Array = [null]
	target.mouse_entered.connect(func() -> void:
		_hide(holder)
		holder[0] = _show(target, title, body, accent))
	target.mouse_exited.connect(func() -> void: _hide(holder))
	target.tree_exiting.connect(func() -> void: _hide(holder))


static func _hide(holder: Array) -> void:
	var tip: Variant = holder[0]
	if tip != null and is_instance_valid(tip):
		(tip as Node).queue_free()
	holder[0] = null


static func _show(target: Control, title: String, body: String, accent: Color) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "HoverTip"
	panel.theme_type_variation = &"DarkPanel"
	panel.top_level = true
	panel.z_index = 400
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = Vector2(WIDTH, 0)
	var column: VBoxContainer = UIKit.vbox(6)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(column)
	var heading: Label = UIKit.label(title, &"HeadingLabel", 24, accent)
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(heading)
	var text: Label = UIKit.label(body, &"", 20, UIStyle.PARCHMENT)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(WIDTH - 40.0, 0)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(text)
	target.add_child(panel)
	var rect: Rect2 = target.get_global_rect()
	var view: Vector2 = target.get_viewport_rect().size
	var x: float = rect.end.x + 14.0
	if x + WIDTH + 30.0 > view.x:
		x = maxf(8.0, rect.position.x - WIDTH - 44.0)
	panel.global_position = Vector2(x, clampf(rect.position.y, 8.0, view.y - 260.0))
	return panel
