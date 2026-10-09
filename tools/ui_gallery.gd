extends Control
## A review sheet of the UI art kit as the game draws it: panels at several sizes, the four button states, bars, slots, tooltip, chip, dialogue.
## `bash tools/shot.sh res://scenes/dev/ui_gallery.tscn ui_gallery`


func _ready() -> void:
	var back: ColorRect = ColorRect.new()
	back.color = Color(0.2, 0.17, 0.25)
	UIKit.full_rect(back)
	add_child(back)
	_panel(Vector2(20, 20), Vector2(420, 300), &"PanelContainer", "Main panel 420x300")
	_panel(Vector2(20, 340), Vector2(220, 120), &"PanelContainer", "Small 220x120")
	_panel(Vector2(460, 20), Vector2(460, 340), &"RewardPanel", "Popup panel")
	_panel(Vector2(260, 340), Vector2(180, 90), &"TooltipPanel", "Tooltip")
	_panel(Vector2(460, 380), Vector2(300, 60), &"HudChip", "Chip 300x60")
	_panel(Vector2(460, 460), Vector2(160, 46), &"HudChip", "Gold 120")
	_panel(Vector2(20, 480), Vector2(900, 190), &"DialoguePanel", "Dialogue panel with the name tab at its top-left")
	var x: float = 940.0
	for kind: String in ["", "PrimaryButton", "DangerButton"]:
		var y: float = 30.0
		for state: String in ["normal", "hover", "pressed", "disabled"]:
			var button: Button = Button.new()
			button.text = "%s %s" % [kind if kind != "" else "Secondary", state]
			if kind != "":
				button.theme_type_variation = kind
			button.position = Vector2(x, y)
			button.size = Vector2(300, 0)
			button.disabled = state == "disabled"
			add_child(button)
			if state == "hover" or state == "pressed":
				var style: StyleBox = button.get_theme_stylebox(state)
				button.add_theme_stylebox_override("normal", style)
			y += 76.0
		x += 320.0
	var tall: Button = Button.new()
	tall.text = "A longer button label here"
	tall.theme_type_variation = &"PrimaryButton"
	tall.position = Vector2(940, 360)
	tall.size = Vector2(520, 90)
	add_child(tall)


func _panel(at: Vector2, size_px: Vector2, variation: StringName, text: String) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = variation
	panel.position = at
	panel.custom_minimum_size = size_px
	panel.size = size_px
	var label: Label = Label.new()
	label.text = text
	panel.add_child(label)
	add_child(panel)
