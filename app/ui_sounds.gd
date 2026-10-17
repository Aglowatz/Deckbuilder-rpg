class_name UiSounds
extends Node
## The interface family everywhere at once (docs/audio/sound_direction.md, Part D): every button breathes on hover and taps when pressed, tabs turn
## a page, sliders tick per notch, and quests are accepted and completed with their own sounds, without any screen wiring it. A press only taps when
## the screen's own handler played nothing that frame (a confirm, an error, an open), so nothing doubles. A control with the meta `no_ui_sound` is
## left alone. Owned by `Audio`.

var _armed: bool = false
## `Audio.play_serial` as this frame began: a press taps only when no sound at all was asked for in its frame (whichever runs first, the screen's
## own handler or this hook).
var _frame_serial: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = -1000
	get_tree().node_added.connect(_on_node_added)
	EventBus.quest_notice.connect(_on_quest_notice)
	EventBus.arena_fight_finished.connect(func(_encounter: String, won: bool) -> void:
		if won:
			Audio.sfx(&"arena_cheer"))
	_armed = true


func _on_node_added(node: Node) -> void:
	if not _armed or node.has_meta(&"no_ui_sound"):
		return
	if node is BaseButton:
		var button: BaseButton = node as BaseButton
		button.mouse_entered.connect(_on_hover.bind(button))
		button.pressed.connect(_on_pressed.bind(button))
	elif node is TabBar:
		(node as TabBar).tab_clicked.connect(func(_tab: int) -> void: Audio.sfx(&"ui_tab"))
	elif node is TabContainer:
		(node as TabContainer).tab_clicked.connect(func(_tab: int) -> void: Audio.sfx(&"ui_tab"))
	elif node is Slider:
		var slider: Slider = node as Slider
		slider.value_changed.connect(func(_value: float) -> void: _on_slider(slider))


func _on_hover(button: BaseButton) -> void:
	if button.disabled or not button.is_visible_in_tree() or button.has_meta(&"no_ui_sound"):
		return
	Audio.sfx(&"ui_hover")


func _process(_delta: float) -> void:
	_frame_serial = Audio.play_serial


func _on_pressed(button: BaseButton) -> void:
	if button.has_meta(&"no_ui_sound"):
		return
	_tap_unless_handled.call_deferred(_frame_serial)


## Called at the end of the frame of a press: the tap plays only when nothing in that frame (the press's own handler included) played a sound.
func _tap_unless_handled(frame_serial: int) -> void:
	if Audio.play_serial == frame_serial:
		Audio.sfx(&"ui_click")


func _on_slider(slider: Slider) -> void:
	# Only the player's own drags and key presses tick, not a screen setting the value as it opens.
	if slider.has_focus() or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Audio.sfx(&"ui_slider")


func _on_quest_notice(_text: String, is_new: bool) -> void:
	Audio.sfx(&"quest_accept" if is_new else &"quest_complete")
