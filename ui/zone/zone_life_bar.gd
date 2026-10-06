class_name ZoneHpBar
extends PanelContainer
## HUD: the zone HP that persists for the whole visit. Redraws on `EventBus.zone_HP_changed`
## and flashes red (with a shake) when HP drops.

var _label: Label
var _bar: ProgressBar
var _last_hp: int = -1
var _shake: Tween


func _ready() -> void:
	theme_type_variation = &"DarkPanel"
	custom_minimum_size = Vector2(340, 0)
	var column: VBoxContainer = UIKit.vbox(5)
	add_child(column)
	var top: HBoxContainer = UIKit.hbox(8)
	column.add_child(top)
	var heart: BattleHud.HeartIcon = BattleHud.HeartIcon.new()
	heart.custom_minimum_size = Vector2(32, 32)
	top.add_child(heart)
	_label = UIKit.label("", &"", 28, UIStyle.PARCHMENT)
	_label.add_theme_font_override("font", UIStyle.font_title())
	top.add_child(_label)
	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(0, 14)
	_bar.show_percentage = false
	column.add_child(_bar)
	column.add_child(UIKit.label("Zone HP: no healing after battles.", &"MutedLabel", 16))
	EventBus.zone_hp_changed.connect(set_hp)
	if Session.zone_run != null:
		set_hp(Session.zone_run.hp, Session.zone_run.max_hp())


func set_hp(hp: int, max_hp: int) -> void:
	if _label == null:
		return
	_label.text = "HP  %d / %d" % [hp, max_hp]
	_bar.max_value = max_hp
	_bar.value = hp
	var ratio: float = float(hp) / float(maxi(max_hp, 1))
	var fill: Color = UIStyle.GOOD if ratio > 0.6 else (Color("e0b03a") if ratio > 0.3 else UIStyle.HP_RED)
	_bar.add_theme_stylebox_override("fill", UIStyle.box(fill, Color(0, 0, 0, 0), 0, 8))
	if _last_hp >= 0 and hp < _last_hp:
		_flash()
	_last_hp = hp


func _flash() -> void:
	if _shake != null and _shake.is_valid():
		_shake.kill()
	_label.add_theme_color_override("font_color", UIStyle.HP_RED)
	var home: float = position.x
	_shake = create_tween()
	for i: int in range(6):
		_shake.tween_property(self, "position:x", home + (8.0 if i % 2 == 0 else -8.0), 0.04)
	_shake.tween_property(self, "position:x", home, 0.04)
	_shake.tween_callback(func() -> void: _label.add_theme_color_override("font_color", UIStyle.PARCHMENT))
