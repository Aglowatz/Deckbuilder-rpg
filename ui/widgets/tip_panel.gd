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
	column.name = "Full"
	tip.add_child(column)
	tip._title = title
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
	# Import Nov 8 (C1b F11): the body's height is only known a frame or two later - the box re-fits whenever it grows, so its last line
	# never spills below the frame or off the screen.
	tip.resized.connect(tip._keep_on_screen)
	return tip


## UI + economy fixes Oct 22: the tips are placed for a 1920x1080 screen; on a smaller one (a big UI scale) they are moved back inside it.
func _keep_on_screen() -> void:
	var parent_control: Control = get_parent() as Control
	if parent_control == null or parent_control.size.x < 100.0:
		return
	var room: Vector2 = parent_control.size
	position.x = clampf(position.x, 12.0, maxf(12.0, room.x - size.x - 12.0))
	position.y = clampf(position.y, 12.0, maxf(12.0, room.y - size.y - 12.0))


## Import Nov 8 (C7 F12, C3 F6): a tip never sits over the screen while the player uses it. A click anywhere outside it folds it into a small
## "Tip: <title>" pill in its corner (click the pill to read it again; "Got it" still closes it for good).
var _title: String = ""
var _pill: FancyButton = null


func is_collapsed() -> bool:
	return _pill != null and _pill.visible


func collapse() -> void:
	if _dismissed or is_collapsed():
		return
	var full: Control = get_node_or_null("Full") as Control
	if full == null:
		return
	full.visible = false
	if _pill == null:
		_pill = FancyButton.make("Tip: %s" % _title, &"GhostButton", Vector2(0, 40))
		_pill.add_theme_font_size_override("font_size", 18)
		_pill.pressed.connect(expand)
		add_child(_pill)
	_pill.visible = true
	custom_minimum_size = Vector2(0, 0)
	size = Vector2.ZERO
	modulate.a = 0.85


func expand() -> void:
	var full: Control = get_node_or_null("Full") as Control
	if full == null or _dismissed:
		return
	if _pill != null:
		_pill.visible = false
	full.visible = true
	custom_minimum_size = Vector2(800, 0)
	modulate.a = 1.0
	_age = 0.0
	_keep_on_screen.call_deferred()


func _input(event: InputEvent) -> void:
	if _dismissed or _age < GUARD_TIME or not is_visible_in_tree() or is_collapsed():
		return
	var press: InputEventMouseButton = event as InputEventMouseButton
	if press != null and press.pressed and not get_global_rect().has_point(press.global_position):
		collapse()


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
