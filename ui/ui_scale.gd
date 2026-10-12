class_name UiScale
extends Node
## The UI scale setting (90 to 150 percent), applied per screen instead of to the whole window, because many HUDs are laid out at fixed positions on the 1920x1080 canvas
## and a window-wide scale would push their corners off the screen.
##
## - `UiScale.fit(screen)`: for a full-screen Control whose children are containers (menus, vendors, popups, dialogs). The Control is made as big as the screen
##   divided by the scale and scaled up by it, so it always covers the screen exactly and its containers re-flow for the new size.
## - `UiScale.corner(panels)`: for HUD panels at fixed positions. Each panel grows (or shrinks) around the corner or edge of itself that is nearest to the screen edge,
##   so a panel in the top right stays in the top right.
## Both follow `Settings.ui_scale` live.

var _target: Control
## "fit" or "corner".
var _mode: String = "fit"
var _panels: Array[Control] = []
## How much of the scale a HUD panel takes (1.0 = all of it). Crowded HUDs (the battle) take part of it so panels do not run into the board.
var _strength: float = 1.0


## Makes `screen` (a full-screen Control that is not inside a container) follow the UI scale.
static func fit(screen: Control) -> UiScale:
	if screen.get_parent() is Container:
		return null
	var scaler: UiScale = UiScale.new()
	scaler.name = "UiScaleFit"
	scaler._target = screen
	scaler._mode = "fit"
	screen.add_child(scaler)
	return scaler


## Makes each of `panels` (HUD panels at fixed positions) follow the UI scale around their screen-edge side.
static func corner(host: Node, panels: Array[Control], strength: float = 1.0) -> UiScale:
	var scaler: UiScale = UiScale.new()
	scaler._strength = strength
	scaler.name = "UiScaleCorner"
	scaler._mode = "corner"
	scaler._panels = panels
	host.add_child(scaler)
	return scaler


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.ui_scale_changed.connect(refit)
	if _mode == "fit":
		_target.get_viewport().size_changed.connect(refit)
	else:
		for panel: Control in _panels:
			if panel != null:
				panel.resized.connect(_pivot_panel.bind(panel))
	refit()


func refit() -> void:
	if _mode == "fit":
		_fit_screen()
	else:
		for panel: Control in _panels:
			if panel != null and is_instance_valid(panel):
				_pivot_panel(panel)


func _fit_screen() -> void:
	if _target == null or not is_instance_valid(_target) or not _target.is_inside_tree():
		return
	var factor: float = Settings.ui_scale
	var view: Vector2 = _target.get_viewport().get_visible_rect().size
	_target.custom_minimum_size = Vector2.ZERO
	_target.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_target.pivot_offset = Vector2.ZERO
	_target.position = Vector2.ZERO
	_target.scale = Vector2(factor, factor)
	_target.size = view / factor


func _pivot_panel(panel: Control) -> void:
	if not panel.is_inside_tree():
		return
	var factor: float = 1.0 + (Settings.ui_scale - 1.0) * _strength
	var view: Vector2 = panel.get_viewport().get_visible_rect().size
	var middle: Vector2 = panel.position + panel.size * 0.5
	panel.pivot_offset = pivot_for(middle, panel.size, view)
	panel.scale = Vector2(factor, factor)


## The pivot (in panel coordinates) a panel scales around: the right or bottom edge when its centre is in the right or bottom part of the screen, the left or top edge when it
## is in the left or top part, and its own middle when it is near the centre line.
static func pivot_for(centre: Vector2, panel_size: Vector2, view: Vector2) -> Vector2:
	var x: float = 0.0
	if absf(centre.x - view.x * 0.5) < view.x * 0.15:
		x = panel_size.x * 0.5
	elif centre.x > view.x * 0.5:
		x = panel_size.x
	var y: float = 0.0
	if absf(centre.y - view.y * 0.5) < view.y * 0.15:
		y = panel_size.y * 0.5
	elif centre.y > view.y * 0.5:
		y = panel_size.y
	return Vector2(x, y)
