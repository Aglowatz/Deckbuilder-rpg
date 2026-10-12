class_name TownHud
extends Control
## The town's overlay: objective, gold, "press E" prompt, toast messages and control hints.

signal character_pressed
signal deck_pressed
signal quests_pressed
signal wardrobe_pressed
signal packs_pressed

var _menu_button: FancyButton
var _menu_panel: PanelContainer
var _location: Label
var _left_column: VBoxContainer
var _effects_panel: ZoneEffectsPanel
var _progress: Label
var _gold: Label
var _prompt_panel: PanelContainer
var _prompt_label: Label
var _toast: Label
var _toast_tween: Tween
var _gold_panel: PanelContainer

## HUD panels take this much of the UI scale (the minimap above them takes the same), so the right column stays tidy at 150 percent.
const HUD_SCALE_STRENGTH: float = 0.55
## Where the right column sits at a scale of 100 percent: the minimap bottom (20 + 250), the gold panel, the Menu button and its list.
const RIGHT_COLUMN_Y: Array[float] = [282.0, 346.0, 408.0]


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var left_column: VBoxContainer = UIKit.vbox(10)
	left_column.position = Vector2(30, 28)
	left_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_column)
	var objective_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	objective_panel.name = "LocationPanel"
	objective_panel.custom_minimum_size = Vector2(300, 0)
	objective_panel.visible = false  # shown once a location is set: no empty box
	left_column.add_child(objective_panel)
	_left_column = left_column
	left_column.add_child(QuestTracker.new())
	var column: VBoxContainer = UIKit.vbox(4)
	objective_panel.add_child(column)
	_location = UIKit.label("", &"HeadingLabel", 26)
	_location.name = "LocationLabel"
	column.add_child(_location)
	_progress = UIKit.label("", &"MutedLabel", 18)
	_progress.name = "ZoneProgressLabel"
	column.add_child(_progress)
	var gold_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	gold_panel.position = Vector2(1650, 282)
	add_child(gold_panel)
	var gold_row: HBoxContainer = UIKit.hbox(10)
	gold_panel.add_child(gold_row)
	gold_row.add_child(IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 34.0))
	_gold = UIKit.label("0", &"", 30, UIStyle.GOLD)
	_gold.add_theme_font_override("font", UIStyle.font_title())
	gold_row.add_child(_gold)
	_menu_button = FancyButton.make("Menu", &"PrimaryButton", Vector2(180, 52))
	_menu_button.name = "MenuButton"
	_menu_button.position = Vector2(1650, 346)
	_menu_button.pressed.connect(toggle_menu)
	add_child(_menu_button)
	_menu_panel = UIKit.panel()
	_menu_panel.name = "MenuPanel"
	_menu_panel.position = Vector2(1650, 408)
	_menu_panel.visible = false
	add_child(_menu_panel)
	var menu_column: VBoxContainer = UIKit.vbox(6)
	_menu_panel.add_child(menu_column)
	for entry: Array in [["Character (%s)" % Keybinds.first_key(&"open_character"), character_pressed, "ICON-UI-CHARACTER"], ["Deck (%s)" % Keybinds.first_key(&"open_deck"), deck_pressed, "ICON-UI-DECK"], ["Quests (%s)" % Keybinds.first_key(&"open_quests"), quests_pressed, "ICON-UI-QUESTS"], ["Packs (%s)" % Keybinds.first_key(&"open_packs"), packs_pressed, "ICON-UI-PACKS"], ["Wardrobe (%s)" % Keybinds.first_key(&"open_wardrobe"), wardrobe_pressed, "ICON-UI-WARDROBE"]]:
		var item: FancyButton = FancyButton.make(str(entry[0]), &"", Vector2(200, 48))
		item.name = "Menu_%s" % str(entry[0]).split(" ")[0]
		IconArt.button_icon(item, str(entry[2]), 30.0)
		var signal_ref: Signal = entry[1] as Signal
		item.pressed.connect(func() -> void:
			close_menu()
			signal_ref.emit())
		menu_column.add_child(item)
	_prompt_panel = UIKit.panel()
	_prompt_panel.position = Vector2(700, 900)
	_prompt_panel.visible = false
	add_child(_prompt_panel)
	_prompt_label = UIKit.label("", &"", 30, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_prompt_panel.add_child(_prompt_label)
	_toast = UIKit.label("", &"", 32, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_toast.add_theme_font_override("font", UIStyle.font_bold())
	_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.position = Vector2(460, 780)
	_toast.size = Vector2(1000, 44)
	_toast.modulate.a = 0.0
	add_child(_toast)
	var hints: Label = UIKit.label("%s: move      %s / Click: interact      Menu button: character, deck, quests, packs, wardrobe      %s: map      %s: menu" % [_move_keys_text(), Keybinds.hint(&"interact"), Keybinds.first_key(&"open_map"), Keybinds.first_key(&"pause")], &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	hints.position = Vector2(960, 1030)
	hints.size = Vector2(940, 30)
	add_child(hints)
	EventBus.gold_changed.connect(set_gold)
	set_gold(Session.gold)
	UiScale.corner(self, [left_column, gold_panel, _menu_button, _menu_panel] as Array[Control], HUD_SCALE_STRENGTH)
	_gold_panel = gold_panel
	Settings.ui_scale_changed.connect(_stack_right_column)
	_stack_right_column()


func set_gold(amount: int) -> void:
	_gold.text = str(amount)


## Part C: the active zone's buff and debuff, shown under the objective while in a zone.
func show_zone_effects(effect: ZoneEffects.Effect, zone_title: String) -> void:
	if _effects_panel != null:
		_effects_panel.queue_free()
		_effects_panel = null
	if effect == null:
		return
	_effects_panel = ZoneEffectsPanel.make(effect, zone_title, true)
	_left_column.add_child(_effects_panel)
	_left_column.move_child(_effects_panel, 1)


## Any extra panel under the objective (the Capital's broken services).
func add_panel(panel: Control) -> void:
	_left_column.add_child(panel)
	_left_column.move_child(panel, 1)


## The town's name and how many zones are free ("Crosspath - 1 of 4 zones free").
func set_location(town_name: String, progress: String) -> void:
	_location.text = town_name
	_location.get_parent().get_parent().visible = town_name != "" or progress != ""
	_progress.text = progress


## The objective box was removed (the quest tracker replaces it); kept so scenes can still call it.
func set_objective(_bbcode: String) -> void:
	pass


func show_prompt(text: String) -> void:
	_prompt_label.text = text
	_prompt_panel.visible = true
	_prompt_panel.reset_size()
	_prompt_panel.position.x = (1920.0 - _prompt_panel.size.x) * 0.5


func hide_prompt() -> void:
	_prompt_panel.visible = false


var _queue: Array = []
var _queue_timer: float = 0.0


## Toasts that must each be readable (several quest notices at once) - shown one after another.
func queue_toast(message: String, color: Color = UIStyle.PARCHMENT) -> void:
	_queue.append([message, color])


func _process(delta: float) -> void:
	_queue_timer -= delta
	if _queue_timer <= 0.0 and not _queue.is_empty():
		var entry: Array = _queue.pop_front()
		toast(str(entry[0]), entry[1] as Color)
		_queue_timer = 2.4


func toast(message: String, color: Color = UIStyle.PARCHMENT) -> void:
	_toast.text = message
	_toast.add_theme_color_override("font_color", color)
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(2.0)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.5)


func toggle_menu() -> void:
	_menu_panel.visible = not _menu_panel.visible
	Audio.sfx(&"ui_tick")


func close_menu() -> void:
	_menu_panel.visible = false


## The movement keys for the hint line: the primary keys as "W A S D", plus "arrows" when the secondary ones are the arrow keys.
func _move_keys_text() -> String:
	var primary: PackedStringArray = []
	var secondary: PackedStringArray = []
	for action: StringName in [&"move_up", &"move_left", &"move_down", &"move_right"]:
		var keys: Array[int] = Keybinds.keys_of(action)
		primary.append(Keybinds.key_text(keys[0]))
		secondary.append(Keybinds.key_text(keys[1]))
	var text: String = " ".join(primary)
	if secondary != PackedStringArray(["Up", "Left", "Down", "Right"]):
		return text + (" / " + " ".join(secondary) if secondary != PackedStringArray(["-", "-", "-", "-"]) else "")
	return text + " / arrows"


## Moves the gold counter, the Menu button and its list down by what the (scaled) minimap and the panels above them gained, so nothing overlaps.
func _stack_right_column() -> void:
	if _gold_panel == null or _menu_button == null or _menu_panel == null:
		return
	var factor: float = 1.0 + (Settings.ui_scale - 1.0) * HUD_SCALE_STRENGTH
	var shift: float = 250.0 * (factor - 1.0)
	_gold_panel.position.y = RIGHT_COLUMN_Y[0] + shift
	_menu_button.position.y = RIGHT_COLUMN_Y[1] + shift + _gold_panel.size.y * (factor - 1.0)
	_menu_panel.position.y = RIGHT_COLUMN_Y[2] + shift + (_gold_panel.size.y + _menu_button.size.y) * (factor - 1.0)
