class_name TipPanel
extends PanelContainer
## A short "first visit" hint that shows once per screen (remembered in the save flags).


## Shows the tip under `parent` unless `flag` was already set. Returns the panel or null.
static func show_once(parent: Control, flag: StringName, title: String, text: String, position: Vector2 = Vector2(560, 880)) -> TipPanel:
	if Session.flag(flag) or not Settings.tutorial_tips:  # Fresh eyes round 2 (Oct 31): Settings > Text > "Tutorial tips" turns them all off (unseen ones stay unseen)
		return null
	# Daytime Oct 19: a screen the UiArtWarmup builds unseen must not use up its one-time tip.
	var node: Node = parent
	while node != null:
		if node is OverlayScreen and (node as OverlayScreen).warming:
			return null
		node = node.get_parent()
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
	tip._keep_on_screen.call_deferred()
	return tip


## UI + economy fixes Oct 22: the tips are placed for a 1920x1080 screen; on a smaller one (a big UI scale) they are moved back inside it.
func _keep_on_screen() -> void:
	var parent_control: Control = get_parent() as Control
	if parent_control == null or parent_control.size.x < 100.0:
		return
	var room: Vector2 = parent_control.size
	position.x = clampf(position.x, 12.0, maxf(12.0, room.x - size.x - 12.0))
	position.y = clampf(position.y, 12.0, maxf(12.0, room.y - size.y - 12.0))


func dismiss() -> void:
	if _dismissed:
		return
	_dismissed = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)


## Fresh eyes round 2 (Oct 31): "Got it" also answers to E / Enter / Space / the pad's A (the keys the game calls "interact" and "confirm"), after
## a short guard so the press that opened the screen cannot also close its tip. A focused button on the screen below takes Enter / Space / A
## first (it never sees them here); E always reaches the tip.
const GUARD_TIME: float = 0.4
var _age: float = 0.0
var _dismissed: bool = false


func _process(delta: float) -> void:
	_age += delta


func _unhandled_input(event: InputEvent) -> void:
	if _dismissed or _age < GUARD_TIME or not is_visible_in_tree():
		return
	if UiInput.is_confirm(event):
		get_viewport().set_input_as_handled()
		dismiss()
