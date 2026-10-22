extends SceneTree
## Apparel Part 2: plain stand-in hat SHEETS in the delivery format (COS-HAT-<NAME>-SHEET.png, 2560x512, five views left to right FRONT, FRONTSIDE, SIDE, BACKSIDE,
## BACK, transparent) for all six hats, so the sheet splitter and the auto-fit can be proven before the painted art arrives. Each view is a flat shape with a darker
## band where it meets the head; the side views are narrower, and every sheet carries a stray speck the splitter must drop. Not part of the game.
##   Godot --headless --path . -s res://tools/fake_hat_sheets.gd   -> _art_inbox/fake_hat_sheets/
## Then: Godot --headless --path . -s res://tools/world_test_import.gd -- --cosmetics --cos_inbox=res://_art_inbox/fake_hat_sheets/ --hat_out=res://_art_inbox/fake_hats_split/

const OUT: String = "res://_art_inbox/fake_hat_sheets/"
const CELL: int = 512
const COLOURS: Dictionary = {
	"WIDEBRIM": Color(0.5, 0.33, 0.18), "CHEF": Color(0.95, 0.95, 0.93), "BOWLER": Color(0.16, 0.15, 0.16),
	"TRICORN": Color(0.2, 0.18, 0.28), "WIZARD": Color(0.25, 0.2, 0.62), "LEAFCROWN": Color(0.3, 0.6, 0.25),
}
## How wide each view is drawn compared with the front (side views narrower, like a painted sheet).
const VIEW_WIDTH: Array[float] = [1.0, 0.92, 0.8, 0.92, 1.0]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for hat: String in COLOURS.keys():
		var sheet: Image = Image.create_empty(CELL * 5, CELL, false, Image.FORMAT_RGBA8)
		for view: int in range(5):
			_draw(sheet, hat, view, COLOURS[hat] as Color)
		# A stray speck near the border of the second and third views.
		sheet.fill_rect(Rect2i(CELL * 2 + 6, 60, 5, 9), Color(0, 0, 0, 1))
		sheet.save_png(ProjectSettings.globalize_path("%sCOS-HAT-%s-SHEET.png" % [OUT, hat]))
	print("fake_hat_sheets: %d sheets in %s" % [COLOURS.size(), OUT])
	quit()


func _draw(sheet: Image, hat: String, view: int, colour: Color) -> void:
	var cx: float = float(CELL * view + CELL / 2)
	var base_y: float = 380.0
	var scale: float = VIEW_WIDTH[view]
	var band: Color = colour.darkened(0.4)
	match hat:
		"WIDEBRIM":
			_ellipse(sheet, cx, base_y, 200.0 * scale, 34.0, colour)
			_rect(sheet, cx, base_y - 110.0, 95.0 * scale, 110.0, colour.lightened(0.1))
			_rect(sheet, cx, base_y - 22.0, 95.0 * scale, 20.0, band)
		"CHEF":
			_rect(sheet, cx, base_y - 170.0, 90.0 * scale, 170.0, colour)
			_ellipse(sheet, cx, base_y - 190.0, 120.0 * scale, 60.0, colour)
			_rect(sheet, cx, base_y - 30.0, 90.0 * scale, 30.0, colour.darkened(0.15))
		"BOWLER":
			_ellipse(sheet, cx, base_y, 120.0 * scale, 18.0, colour)
			_ellipse(sheet, cx, base_y - 60.0, 92.0 * scale, 70.0, colour.lightened(0.1))
			_rect(sheet, cx, base_y - 14.0, 92.0 * scale, 16.0, band)
		"TRICORN":
			for row: int in range(150):
				var half: float = (40.0 + float(row) * 1.1) * scale
				_rect(sheet, cx, base_y - 150.0 + float(row), half, 1.0, colour)
			_rect(sheet, cx, base_y - 18.0, 140.0 * scale, 16.0, Color(0.85, 0.7, 0.3))
		"WIZARD":
			_ellipse(sheet, cx, base_y, 170.0 * scale, 28.0, colour)
			for row: int in range(300):
				var half: float = float(row) / 300.0 * 95.0 * scale
				_rect(sheet, cx + (300.0 - float(row)) * 0.12, base_y - 300.0 + float(row), half, 1.0, colour)
			_rect(sheet, cx, base_y - 26.0, 95.0 * scale, 18.0, band)
		_:
			for leaf: int in range(9):
				var angle: float = PI * (0.1 + 0.8 * float(leaf) / 8.0)
				_ellipse(sheet, cx - cos(angle) * 100.0 * scale, base_y - 20.0 - sin(angle) * 30.0, 26.0, 40.0, colour.lightened(0.1 * float(leaf % 3)))
			_rect(sheet, cx, base_y - 8.0, 100.0 * scale, 10.0, Color(0.45, 0.3, 0.15))


func _rect(sheet: Image, cx: float, top: float, half_width: float, height: float, colour: Color) -> void:
	sheet.fill_rect(Rect2i(int(cx - half_width), int(top), int(half_width * 2.0), maxi(1, int(height))), colour)


func _ellipse(sheet: Image, cx: float, cy: float, rx: float, ry: float, colour: Color) -> void:
	for y: int in range(int(cy - ry), int(cy + ry) + 1):
		for x: int in range(int(cx - rx), int(cx + rx) + 1):
			var dx: float = (float(x) - cx) / rx
			var dy: float = (float(y) - cy) / ry
			if dx * dx + dy * dy <= 1.0 and x >= 0 and y >= 0 and x < sheet.get_width() and y < sheet.get_height():
				sheet.set_pixel(x, y, colour)
