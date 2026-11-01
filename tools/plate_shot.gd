extends Node
## Overnight Oct 31 - Nov 1: the battle HP plates for a few names side by side (the boss plate wrap check).
## Windowed: Godot --path . --resolution 1600x900 res://tools/plate_shot.tscn -- [--out=plates] [--names=A|B|C]
## Output: _screenshots/oct31n/<out>.png

func _ready() -> void:
	var names: PackedStringArray = ["Primm - Phase Standardization", "Primm - Standardization", "The Doppelganger", "Colonel Cornelius Crumb", "Cave Scavenger", "You"]
	var out: String = "plates"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--names="):
			names = arg.substr(8).split("|")
		elif arg.begins_with("--out="):
			out = arg.substr(6)
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	var back: ColorRect = ColorRect.new()
	back.color = Color(0.12, 0.1, 0.16)
	back.size = Vector2(1600, 900)
	layer.add_child(back)
	for i: int in names.size():
		var plate: BattleHud.Portrait = BattleHud.Portrait.new()
		plate.title = names[i]
		plate.hp = 30
		plate.max_hp = 30
		plate.position = Vector2(40 + (i % 3) * 500, 40 + (i / 3) * 300)
		layer.add_child(plate)
	for frame: int in 20:
		await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_screenshots/oct31n"))
	get_viewport().get_texture().get_image().save_png("res://_screenshots/oct31n/%s.png" % out)
	print("plate_shot: _screenshots/oct31n/%s.png" % out)
	get_tree().quit()
