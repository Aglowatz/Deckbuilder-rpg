class_name ConfirmDialog
extends Control
## A modal yes/no question. Emits `confirmed` or `cancelled`, then frees itself.

signal confirmed
signal cancelled


static func ask(parent: Node, title: String, message: String, confirm_text: String = "Yes", cancel_text: String = "Cancel", danger: bool = false) -> ConfirmDialog:
	var dialog: ConfirmDialog = ConfirmDialog.new()
	dialog.set_meta("title", title)
	dialog.set_meta("message", message)
	dialog.set_meta("confirm_text", confirm_text)
	dialog.set_meta("cancel_text", cancel_text)
	dialog.set_meta("danger", danger)
	parent.add_child(dialog)
	return dialog


func _ready() -> void:
	UIKit.full_rect(self)
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
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	var yes: FancyButton = FancyButton.make(str(get_meta("confirm_text")), &"DangerButton" if bool(get_meta("danger")) else &"PrimaryButton", Vector2(220, 56))
	yes.pressed.connect(func() -> void:
		confirmed.emit()
		queue_free())
	row.add_child(yes)
	var no: FancyButton = FancyButton.make(str(get_meta("cancel_text")), &"", Vector2(200, 56))
	no.pressed.connect(func() -> void:
		cancelled.emit()
		queue_free())
	row.add_child(no)
	UIKit.pop_in(panel)
	Audio.sfx(&"ui_open", -4.0)
