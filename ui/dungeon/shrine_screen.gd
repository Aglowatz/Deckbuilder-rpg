class_name ShrineScreen
extends Control
## The healing shrine: rest to restore HP (the amount comes from the map node).

signal finished

var _button: FancyButton
var _hp_label: Label
var _bar: ProgressBar
var _rested: bool = false
var _heal: int = 0


func _ready() -> void:
	UIKit.full_rect(self)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.82)
	UIKit.full_rect(shade)
	add_child(shade)
	var node: DungeonMap.MapNode = Session.dungeon_map.node(int(get_meta("node_id", 4)))
	_heal = node.heal_amount
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(760, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(14)
	panel.add_child(column)
	column.add_child(UIKit.label(node.title, &"TitleLabel", 54, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var glow: TextureRect = CardIcons.glyph(CardIcons.ui("fountain"), Color("8fe8ff"), Vector2(150, 150))
	glow.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(glow)
	var text: Label = UIKit.label("A quiet light gathers in the stone. Rest here and it will mend %d of your HP." % _heal, &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(680, 0)
	column.add_child(text)
	_hp_label = UIKit.label("", &"", 32, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_hp_label.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(_hp_label)
	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(0, 20)
	_bar.show_percentage = false
	column.add_child(_bar)
	_button = FancyButton.make("Rest", &"PrimaryButton", Vector2(260, 60))
	_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_button.pressed.connect(_on_button)
	column.add_child(_button)
	_show_hp(Session.run.hp)
	UIKit.pop_in(panel)
	Audio.sfx(&"ui_open")
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(glow, "modulate", Color(1.4, 1.4, 1.4), 1.0).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(glow, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_SINE)


func _show_hp(value: float) -> void:
	_hp_label.text = "HP  %d / %d" % [roundi(value), Session.run.max_hp()]
	_bar.max_value = Session.run.max_hp()
	_bar.value = value
	_bar.add_theme_stylebox_override("fill", UIStyle.box(UIStyle.GOOD, Color(0, 0, 0, 0), 0, 8))


func _on_button() -> void:
	if _rested:
		finished.emit()
		return
	_rested = true
	var before: int = Session.run.hp
	Session.run.heal(_heal)
	Audio.sfx(&"heal")
	var tween: Tween = create_tween()
	tween.tween_method(_show_hp, float(before), float(Session.run.hp), 0.9)
	_button.text = "Continue"
