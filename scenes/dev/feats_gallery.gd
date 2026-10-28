extends Control
## Overnight Oct 28 (screenshots): the Feats page on its own, with a few feats earned (the cave, two zones), as the pause menu shows it.
##   bash tools/shot.sh res://scenes/dev/feats_gallery.tscn feats_page


func _ready() -> void:
	Session.save_enabled = false
	Session.ensure_game(Affinity.Type.NECROCRAT)
	Session.complete_zone("beefcake")
	Session.complete_zone("gourmand")
	UIKit.full_rect(self)
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = Color(0.06, 0.05, 0.09)
	UIKit.full_rect(backdrop)
	add_child(backdrop)
	var panel: FeatsPanel = FeatsPanel.make()
	panel.position = Vector2(470, 160)
	add_child(panel)
