class_name TownHud
extends Control
## The town's overlay: objective, gold, "press E" prompt, toast messages and control hints.

signal character_pressed
signal deck_pressed
signal quests_pressed
signal wardrobe_pressed

var _objective: RichTextLabel
var _location: Label
var _left_column: VBoxContainer
var _effects_panel: ZoneEffectsPanel
var _progress: Label
var _gold: Label
var _prompt_panel: PanelContainer
var _prompt_label: Label
var _toast: Label
var _toast_tween: Tween


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var left_column: VBoxContainer = UIKit.vbox(10)
	left_column.position = Vector2(30, 28)
	left_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_column)
	var objective_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	objective_panel.custom_minimum_size = Vector2(430, 0)
	left_column.add_child(objective_panel)
	_left_column = left_column
	left_column.add_child(QuestTracker.new())
	var column: VBoxContainer = UIKit.vbox(4)
	objective_panel.add_child(column)
	_location = UIKit.label("", &"HeadingLabel", 30)
	_location.name = "LocationLabel"
	column.add_child(_location)
	_progress = UIKit.label("", &"MutedLabel", 20)
	_progress.name = "ZoneProgressLabel"
	column.add_child(_progress)
	column.add_child(UIKit.label("Objective", &"HeadingLabel", 22))
	_objective = UIKit.rich("", 22)
	_objective.custom_minimum_size = Vector2(400, 0)
	column.add_child(_objective)
	var gold_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	gold_panel.position = Vector2(1650, 28)
	add_child(gold_panel)
	var gold_row: HBoxContainer = UIKit.hbox(10)
	gold_panel.add_child(gold_row)
	gold_row.add_child(CardIcons.glyph(CardIcons.ui("coins"), UIStyle.GOLD, Vector2(34, 34)))
	_gold = UIKit.label("0", &"", 30, UIStyle.GOLD)
	_gold.add_theme_font_override("font", UIStyle.font_title())
	gold_row.add_child(_gold)
	var character_button: FancyButton = FancyButton.make("Character (C)", &"", Vector2(180, 52))
	character_button.position = Vector2(1650, 100)
	character_button.pressed.connect(func() -> void: character_pressed.emit())
	add_child(character_button)
	var deck_button: FancyButton = FancyButton.make("Deck (B)", &"", Vector2(180, 52))
	deck_button.position = Vector2(1650, 170)
	deck_button.pressed.connect(func() -> void: deck_pressed.emit())
	add_child(deck_button)
	var quests_button: FancyButton = FancyButton.make("Quests (J)", &"", Vector2(180, 52))
	quests_button.position = Vector2(1650, 240)
	quests_button.pressed.connect(func() -> void: quests_pressed.emit())
	add_child(quests_button)
	var wardrobe_button: FancyButton = FancyButton.make("Wardrobe (T)", &"", Vector2(180, 52))
	wardrobe_button.name = "WardrobeButton"
	wardrobe_button.position = Vector2(1650, 310)
	wardrobe_button.pressed.connect(func() -> void: wardrobe_pressed.emit())
	add_child(wardrobe_button)
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
	var hints: Label = UIKit.label("WASD / arrows: move      E / Space / Click: interact      C: character      B: deck      J: quests      T: wardrobe      M: map      Esc: menu", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	hints.position = Vector2(960, 1030)
	hints.size = Vector2(940, 30)
	add_child(hints)
	EventBus.gold_changed.connect(set_gold)
	set_gold(Session.gold)


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


## The town's name and how many zones are free ("Concord Crossing - 1 of 4 zones free").
func set_location(town_name: String, progress: String) -> void:
	_location.text = town_name
	_progress.text = progress


func set_objective(bbcode: String) -> void:
	_objective.text = bbcode


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
