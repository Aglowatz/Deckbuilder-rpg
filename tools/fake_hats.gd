extends SceneTree
## Draws plain stand-in hats (a wizard cone and a wide-brim disc, five directions each) into _art_inbox/fake_hats/<NAME>/<DIR>.png so the hat placement can be checked
## before the painted art exists: SPRITE_HAT_FOLDER=res://_art_inbox/fake_hats/ is then used by tools/sprite_sheet_shot.gd. Not part of the game.

const OUT: String = "res://_art_inbox/fake_hats/"


func _initialize() -> void:
	for dir_name: String in SpriteLibrary.HAT_DIRS:
		_save("WIZARD", dir_name, _cone(dir_name))
		_save("WIDEBRIM", dir_name, _disc(dir_name))
	quit()


func _save(hat: String, dir_name: String, image: Image) -> void:
	var folder: String = ProjectSettings.globalize_path(OUT + hat)
	DirAccess.make_dir_recursive_absolute(folder)
	image.save_png("%s/%s.png" % [folder, dir_name])


## A tall pointed cone with a brim; narrower seen from the side.
func _cone(dir_name: String) -> Image:
	var width: int = 240 if dir_name == "SIDE" else 300
	var image: Image = Image.create_empty(width, 320, false, Image.FORMAT_RGBA8)
	var colour: Color = Color(0.45, 0.2, 0.7, 1.0)
	for y: int in range(320):
		var t: float = float(y) / 300.0
		var half: float = float(width) * 0.5 * clampf(t, 0.0, 1.0) * 0.8
		if y > 290:
			half = float(width) * 0.5
		for x: int in range(width):
			if absf(float(x) - float(width) * 0.5) <= half:
				image.set_pixel(x, y, colour if y < 290 else colour.darkened(0.3))
	return image


func _disc(dir_name: String) -> Image:
	var width: int = 360
	var image: Image = Image.create_empty(width, 120, false, Image.FORMAT_RGBA8)
	for y: int in range(120):
		for x: int in range(width):
			var u: float = (float(x) - 180.0) / 180.0
			var v: float = (float(y) - 80.0) / 36.0
			var crown: bool = y < 70 and absf(float(x) - 180.0) < 90.0
			if u * u + v * v <= 1.0 or crown:
				image.set_pixel(x, y, Color(0.85, 0.7, 0.3, 1.0))
	return image
