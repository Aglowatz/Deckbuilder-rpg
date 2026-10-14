class_name FeedbackForm
extends CanvasLayer
## The playtest feedback form (F8, or "Send Feedback" in the pause menu): a 1-5 rating and free notes. The screenshot is taken
## before the form appears, so it shows the game as the tester saw it. Sending writes a FeedbackReport folder.

signal closed

var _screenshot: Image
var _rating: int = 0
var _notes: TextEdit
var _status: Label
var _stars: Array[Button] = []
var _send: FancyButton
var _sent: bool = false
var _was_paused: bool = false


## Opens the form over whatever is on screen. Returns null when one is already open.
static func open(host: Node) -> FeedbackForm:
	if host.get_tree().root.find_child("FeedbackForm", true, false) != null:
		return null
	var form: FeedbackForm = FeedbackForm.new()
	form.name = "FeedbackForm"
	form._screenshot = Session.capture_thumbnail()
	form._was_paused = host.get_tree().paused
	host.get_tree().paused = true
	host.get_tree().root.add_child(form)
	return form


func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root: Control = UIKit.layer_host(self)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	UiScale.fit(root)
	root.add_child(UiSkin.menu_backdrop(Color(0.02, 0.01, 0.05, 0.8)))
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	root.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(900, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(12)
	panel.add_child(column)
	column.add_child(UIKit.label("Send Feedback", &"HeadingLabel", 38, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(UIKit.label("How is the game going? (A screenshot, your game state and the log are saved with this.)", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var stars: HBoxContainer = UIKit.hbox(8)
	stars.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(stars)
	for i: int in range(1, 6):
		var star: Button = Button.new()
		star.name = "Star%d" % i
		star.text = "%d" % i
		star.toggle_mode = true
		star.custom_minimum_size = Vector2(64, 56)
		star.pressed.connect(_set_rating.bind(i))
		stars.add_child(star)
		_stars.append(star)
	_notes = TextEdit.new()
	_notes.name = "Notes"
	_notes.placeholder_text = "What happened? What was confusing, broken or fun?"
	_notes.custom_minimum_size = Vector2(0, 240)
	_notes.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	column.add_child(_notes)
	_status = UIKit.label("", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_status)
	var row: HBoxContainer = UIKit.hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	_send = FancyButton.make("Send", &"PrimaryButton", Vector2(200, 54))
	_send.name = "SendButton"
	_send.pressed.connect(submit)
	row.add_child(_send)
	var folder: FancyButton = FancyButton.make("Open feedback folder", &"", Vector2(300, 54))
	folder.name = "OpenFolderButton"
	folder.pressed.connect(FeedbackReport.open_folder)
	row.add_child(folder)
	var cancel: FancyButton = FancyButton.make("Close", &"", Vector2(160, 54))
	cancel.name = "CloseButton"
	cancel.pressed.connect(close)
	row.add_child(cancel)
	_notes.grab_focus()


func _set_rating(value: int) -> void:
	_rating = value
	for i: int in _stars.size():
		_stars[i].button_pressed = i < value


## Writes the report. Public so tests and tools can drive the form.
func submit() -> String:
	if _sent:
		return ""
	var path: String = FeedbackReport.write(_rating, _notes.text, _screenshot)
	if path.is_empty():
		_status.text = "Could not save the report. Is the disk full?"
		return ""
	_sent = true
	_send.disabled = true
	_status.text = "Saved! Zip the feedback folder and send it to us.\n%s" % path
	return path


func close() -> void:
	get_tree().paused = _was_paused
	closed.emit()
	queue_free()


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.keycode == KEY_F8):
		get_viewport().set_input_as_handled()
		close()
