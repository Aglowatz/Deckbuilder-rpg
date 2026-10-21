class_name FeedbackForm
extends CanvasLayer
## The playtest feedback form (F8, or "Send Feedback" in the pause menu): a 1-5 rating and free notes. The screenshot is taken
## before the form appears, so it shows the game as the tester saw it. Sending writes a FeedbackReport folder.

signal closed

## Opens the report folder in the file browser after sending (smoke runs switch it off).
static var open_after_send: bool = true

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
	# Overnight Oct 20: a direct child of the root (find_child over the whole 3D town cost hundreds of ms).
	if host.get_tree().root.get_node_or_null(^"FeedbackForm") != null:
		return null
	GameLog.modal_opened("FeedbackForm")
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
	column.add_child(UIKit.label("Report a Problem", &"HeadingLabel", 38, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(UIKit.label("What happened? A screenshot, the log, your save, the area and your quest are saved with this. Nothing is sent anywhere.", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
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
	_notes.placeholder_text = "What happened? What did you expect? (Optional: rate the game 1-5 above.)"
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
	Audio.sfx(&"game_save")
	_status.text = "Saved! Zip this folder and send it to us:\n%s" % path
	if open_after_send and DisplayServer.get_name() != "headless":
		OS.shell_open(path)
	return path


func close() -> void:
	GameLog.modal_closed("FeedbackForm")
	get_tree().paused = _was_paused
	closed.emit()
	queue_free()


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.keycode == KEY_F8):
		get_viewport().set_input_as_handled()
		close()
