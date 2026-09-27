class_name TownScene
extends Node3D
## Placeholder until milestone 4: shows the backdrop with a way back to the title.


func _ready() -> void:
	SceneManager.pause_allowed = true
	add_child(TownBackdrop.new())
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	var button: FancyButton = FancyButton.make("Back to Title", &"PrimaryButton", Vector2(280, 60))
	button.position = Vector2(60, 60)
	button.pressed.connect(SceneManager.go_to_title)
	layer.add_child(button)
