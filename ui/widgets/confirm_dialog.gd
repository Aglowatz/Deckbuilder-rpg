class_name ConfirmDialog
extends Control
## A modal yes/no question. Emits `confirmed` or `cancelled`, then frees itself.

signal confirmed
signal cancelled
## UI + economy fixes Oct 22: the middle button of a three-way question (`ask_three`, e.g. Save / Discard / Cancel).
signal alternative

## Set when the dialog was asked with a `check_text` (e.g. "Don't ask again"): read it in the confirmed/cancelled handlers.
var check: CheckBox


static func ask(parent: Node, title: String, message: String, confirm_text: String = "Yes", cancel_text: String = "Cancel", danger: bool = false, check_text: String = "") -> ConfirmDialog:
	var dialog: ConfirmDialog = ConfirmDialog.new()
	dialog.set_meta("title", title)
	dialog.set_meta("message", message)
	dialog.set_meta("confirm_text", confirm_text)
	dialog.set_meta("cancel_text", cancel_text)
	dialog.set_meta("danger", danger)
	dialog.set_meta("check_text", check_text)
	parent.add_child(dialog)
	return dialog


## A three-way question: `confirmed` (the first, primary button), `alternative` (the middle one) or `cancelled` (the last one, focused).
static func ask_three(parent: Node, title: String, message: String, confirm_text: String, alternative_text: String, cancel_text: String = "Cancel") -> ConfirmDialog:
	var dialog: ConfirmDialog = ConfirmDialog.new()
	dialog.set_meta("title", title)
	dialog.set_meta("message", message)
	dialog.set_meta("confirm_text", confirm_text)
	dialog.set_meta("alternative_text", alternative_text)
	dialog.set_meta("cancel_text", cancel_text)
	dialog.set_meta("danger", true)
	parent.add_child(dialog)
	return dialog


func _ready() -> void:
	UIKit.full_rect(self)
	UiScale.fit(self)
	z_index = 200
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.7)
	UIKit.full_rect(shade)
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(16)
	panel.add_child(column)
	column.add_child(UIKit.label(str(get_meta("title")), &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var text: Label = UIKit.label(str(get_meta("message")), &"", 23, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(500, 0)
	column.add_child(text)
	if str(get_meta("check_text", "")) != "":
		check = CheckBox.new()
		check.name = "DontAskCheck"
		check.text = str(get_meta("check_text"))
		check.add_theme_font_size_override("font_size", 20)
		check.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		column.add_child(check)
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	var three_way: bool = str(get_meta("alternative_text", "")) != ""
	var yes: FancyButton = FancyButton.make(str(get_meta("confirm_text")), &"DangerButton" if bool(get_meta("danger")) and not three_way else &"PrimaryButton", Vector2(220, 56))
	yes.pressed.connect(func() -> void:
		confirmed.emit()
		queue_free())
	row.add_child(yes)
	var middle: FancyButton = null
	if three_way:
		middle = FancyButton.make(str(get_meta("alternative_text")), &"DangerButton", Vector2(200, 56))
		middle.name = "AlternativeButton"
		middle.pressed.connect(func() -> void:
			alternative.emit()
			queue_free())
		row.add_child(middle)
		middle.focus_mode = Control.FOCUS_ALL
	var no: FancyButton = FancyButton.make(str(get_meta("cancel_text")), &"", Vector2(200, 56))
	no.pressed.connect(func() -> void:
		cancelled.emit()
		queue_free())
	row.add_child(no)
	UIKit.pop_in(panel)
	Audio.sfx(&"ui_open", -4.0)
	# Overnight Oct 17, Part 13: keyboard / pad: both buttons focusable, the safe choice focused for a dangerous action.
	yes.focus_mode = Control.FOCUS_ALL
	no.focus_mode = Control.FOCUS_ALL
	(no if bool(get_meta("danger")) else yes).call_deferred(&"grab_focus")
	_cancel_button = no
	_confirm_button = yes
	PadFocus.register(self)


var _cancel_button: FancyButton
var _confirm_button: FancyButton
## Fresh eyes round 2 (Oct 31): how long the dialog has been open. A confirm press is ignored for `GUARD_TIME` after it opens, so the E
## press that opened it ("Go in?" at the cave gate) can never also answer it.
var _age: float = 0.0
const GUARD_TIME: float = 0.35


func _process(delta: float) -> void:
	_age += delta


## Controller support (Oct 26): the pad's B answers with the cancel button (Esc is left to the screen below, as before).
## Fresh eyes round 2 (Oct 31): E (the overworld's interact key, which the HUD advertises on the very screen the dialog opens over), Enter,
## Space and the pad's A press the focused button - the one drawn gold - exactly as a click on it would. A focused FancyButton already takes
## Enter / Space / A itself; this catches E and any confirm press that reaches the dialog while no button has the focus (a mouse user who
## clicked beside the panel). The safe button of a dangerous question keeps the focus, so E there says "Cancel", like Enter does.
func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventJoypadButton and UiInput.is_back(event) and _cancel_button != null:
		get_viewport().set_input_as_handled()
		_cancel_button.pressed.emit()
		return
	if UiInput.is_confirm(event) and _age >= GUARD_TIME:
		get_viewport().set_input_as_handled()
		var target: BaseButton = focused_button()
		if target != null and not target.disabled:
			target.pressed.emit()


## The button a confirm key answers with: the focused one when it is one of this dialog's, else the primary button.
func focused_button() -> BaseButton:
	var owner_now: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	if owner_now is BaseButton and is_ancestor_of(owner_now):
		return owner_now as BaseButton
	return _confirm_button
