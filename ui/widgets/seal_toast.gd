class_name SealToast
extends Control
## Fable Nov 16b (Part 4): the notice shown when a hidden lever is pulled in a Path zone - "A seal turns in Crosspath". It replaces the
## cutaway card with four coloured discs: a gold-framed toast at the top of the screen with the Path's icon on an iron seal, the title,
## one line of text and the count ("2 of 4") with four small pips. It stays about six seconds, or until it is clicked.

const SECONDS: float = 6.0
const TITLE: String = "A seal turns in Crosspath"
const WIDTH: float = 760.0

var zone_id: String = ""
var count: int = 0
var _left: float = SECONDS
var _closing: bool = false
var _panel: PanelContainer


## Shows the toast on `layer` (a full-screen Control) for the lever of `zone` with `pulled` levers pulled so far. Returns it.
static func show_on(layer: Control, zone: String, pulled: int) -> SealToast:
	if layer == null:
		return null
	for old: Node in layer.find_children("SealToast*", "", false, false):
		old.queue_free()
	var toast: SealToast = SealToast.new()
	toast.name = "SealToast"
	toast.zone_id = zone
	toast.count = pulled
	layer.add_child(toast)
	return toast


## The one line under the title.
static func line_for(pulled: int) -> String:
	if pulled >= VaultGuardian.ZONE_IDS.size():
		return "The last one. Under the town, an old cellar door comes unstuck."
	return "Far off, under the town, iron grinds on stone."


static func count_text(pulled: int) -> String:
	return "%d of %d" % [mini(pulled, VaultGuardian.ZONE_IDS.size()), VaultGuardian.ZONE_IDS.size()]


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 60
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_panel.tooltip_text = "Click to dismiss"
	_panel.add_theme_stylebox_override("panel", _frame())
	_panel.custom_minimum_size = Vector2(WIDTH, 0)
	_panel.gui_input.connect(_on_panel_input)
	add_child(_panel)
	var row: HBoxContainer = UIKit.hbox(22)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(row)
	row.add_child(_seal_plate())
	var column: VBoxContainer = UIKit.vbox(4)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(column)
	var title: Label = UIKit.label(TITLE, &"HeadingLabel", 32, UIStyle.GOLD)
	title.name = "Title"
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title)
	var line: Label = UIKit.label(line_for(count), &"", 22, UIStyle.PARCHMENT)
	line.name = "Line"
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size = Vector2(380, 0)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(line)
	var tally: HBoxContainer = UIKit.hbox(10)
	tally.name = "Tally"
	tally.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(tally)
	var number: Label = UIKit.label(count_text(count), &"", 26, UIStyle.GOLD)
	number.name = "Count"
	number.add_theme_font_override("font", UIStyle.font_bold())
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tally.add_child(number)
	for index: int in range(VaultGuardian.ZONE_IDS.size()):
		var pip: TextureRect = TextureRect.new()
		pip.name = "Pip%d" % (index + 1)
		pip.texture = UIStyle.circle_texture(22, UIStyle.GOLD if index < count else Color(0.2, 0.19, 0.24), UIStyle.GOLD_DIM, 2)
		pip.custom_minimum_size = Vector2(22, 22)
		pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tally.add_child(pip)
	_place.call_deferred()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.3)
	Audio.sfx(&"notify", -4.0)


## The game's gold-framed dark panel (the HUD's chip art when it is imported).
func _frame() -> StyleBox:
	var box: StyleBox = UiSkin.hud_chip() if UiArt.has("UI-PANEL-HUD") else UIStyle.box(Color(0.07, 0.05, 0.1, 0.95), UIStyle.GOLD, 3, 14, 10)
	box = box.duplicate() as StyleBox
	box.content_margin_left = 30.0
	box.content_margin_right = 34.0
	box.content_margin_top = 22.0
	box.content_margin_bottom = 22.0
	return box


## The Path's icon on a round iron seal (the vault's own seal, as it will look once it has turned).
func _seal_plate() -> Control:
	var plate: Control = Control.new()
	plate.name = "Seal"
	plate.custom_minimum_size = Vector2(124, 124)
	plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var iron: TextureRect = TextureRect.new()
	iron.texture = UIStyle.circle_texture(124, Color("2c2d35"), Color("6f7078"), 7)
	iron.size = Vector2(124, 124)
	iron.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(iron)
	var icon: TextureRect = IconArt.rect(IconArt.energy_id(ZoneEffects.path_of(zone_id)), 84.0)
	if icon != null:
		icon.name = "PathIcon"
		icon.position = Vector2(20, 20)
		icon.size = Vector2(84, 84)
		icon.pivot_offset = Vector2(42, 42)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plate.add_child(icon)
		# The seal turns: the icon swings in from edge-on.
		icon.scale = Vector2(0.05, 1.0)
		var turn: Tween = icon.create_tween()
		turn.tween_interval(0.25)
		turn.tween_property(icon, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return plate


func _place() -> void:
	if not is_inside_tree():
		return
	_panel.reset_size()
	_panel.position = Vector2((size.x - _panel.size.x) * 0.5, 150.0)


func _on_panel_input(event: InputEvent) -> void:
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		dismiss()


func _process(delta: float) -> void:
	if _closing:
		return
	_left -= delta
	if _left <= 0.0:
		dismiss()


## Fades the toast out and frees it (the click, or its six seconds).
func dismiss() -> void:
	if _closing:
		return
	_closing = true
	var fade: Tween = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.3)
	fade.tween_callback(queue_free)


func seconds_left() -> float:
	return _left
