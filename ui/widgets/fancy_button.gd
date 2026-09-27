class_name FancyButton
extends Button
## Button with hover/press feedback (scale tween + sounds). Theme variations
## ("PrimaryButton", "DangerButton", "GhostButton") come from UIStyle.

var _tween: Tween


func _ready() -> void:
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)
	button_down.connect(_on_down)
	pressed.connect(_on_pressed)
	resized.connect(_update_pivot)
	_update_pivot()
	focus_mode = Control.FOCUS_NONE


func _update_pivot() -> void:
	pivot_offset = size * 0.5


func _on_hover() -> void:
	if disabled:
		return
	Audio.sfx(&"ui_hover", -8.0)
	_scale_to(1.04, 0.12)


func _on_exit() -> void:
	_scale_to(1.0, 0.12)


func _on_down() -> void:
	if not disabled:
		_scale_to(0.96, 0.06)


func _on_pressed() -> void:
	Audio.sfx(&"ui_click")
	_scale_to(1.04, 0.1)


func _scale_to(target: float, duration: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE * target, duration)


static func make(label: String, variation: StringName = &"", min_size: Vector2 = Vector2.ZERO) -> FancyButton:
	var button: FancyButton = FancyButton.new()
	button.text = label
	if variation != &"":
		button.theme_type_variation = variation
	button.custom_minimum_size = min_size
	return button
