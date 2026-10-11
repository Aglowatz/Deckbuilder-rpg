extends Control
## Contact sheet of every icon at 128/64/32 px on dark and light backdrops (shot hook: bash tools/shot.sh res://scenes/dev/icon_gallery.tscn icon_gallery).


func _ready() -> void:
	var back: ColorRect = ColorRect.new()
	back.color = Color("2a2234")
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(back)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 12
	grid.position = Vector2(8, 8)
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 4)
	add_child(grid)
	var ids: Array = IconArt.known_ids().keys()
	ids.sort()
	for id: Variant in ids:
		var cell: VBoxContainer = VBoxContainer.new()
		var big: TextureRect = IconArt.rect(str(id), 96)
		if big != null:
			cell.add_child(big)
		var small: HBoxContainer = HBoxContainer.new()
		for px: int in [32, 24]:
			var s: TextureRect = IconArt.rect(str(id), px)
			if s != null:
				small.add_child(s)
		cell.add_child(small)
		var label: Label = Label.new()
		label.text = str(id).trim_prefix("ICON-")
		label.add_theme_font_size_override("font_size", 9)
		cell.add_child(label)
		grid.add_child(cell)
