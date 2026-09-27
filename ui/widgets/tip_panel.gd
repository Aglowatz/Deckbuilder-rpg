class_name TipPanel
extends PanelContainer
## A short "first visit" hint that shows once per screen (remembered in the save flags).


## Shows the tip under `parent` unless `flag` was already set. Returns the panel or null.
static func show_once(parent: Control, flag: StringName, title: String, text: String, position: Vector2 = Vector2(560, 880)) -> TipPanel:
	if Session.flag(flag):
		return null
	Session.set_flag(flag)
	var tip: TipPanel = TipPanel.new()
	tip.position = position
	tip.custom_minimum_size = Vector2(800, 0)
	tip.z_index = 180
	parent.add_child(tip)
	var column: VBoxContainer = UIKit.vbox(6)
	tip.add_child(column)
	var header: HBoxContainer = UIKit.hbox(10)
	header.add_child(UIKit.label("Tip: " + title, &"HeadingLabel", 26))
	header.add_child(UIKit.filler())
	var close: FancyButton = FancyButton.make("Got it", &"PrimaryButton", Vector2(120, 42))
	close.add_theme_font_size_override("font_size", 20)
	close.pressed.connect(tip.dismiss)
	header.add_child(close)
	column.add_child(header)
	var body: RichTextLabel = UIKit.rich(text, 22)
	body.custom_minimum_size = Vector2(760, 0)
	column.add_child(body)
	UIKit.pop_in(tip)
	Audio.sfx(&"ui_open", -8.0)
	return tip


func dismiss() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
