class_name ArtPatches
extends RefCounted
## Fable Nov 9 (Batch 14, Part 1.3): small in-code fixes to shipped pictures, applied when the picture is loaded. The only use so far is
## the protected Red Cross emblem (a red cross on white is reserved by the Geneva Conventions): Nurse Hesper's cap and armband in her
## portrait (NPC-HESPER) and in the epilogue still (STORY-EPI-WRINKLES) are recoloured to a muted leaf green inside small boxes around
## the two crosses. The art itself is untouched (a painted redo is on the art list); remove an entry once its redo is imported.
## Boxes are in normalised picture coordinates (0-1), so they hold whatever size the import rules give the texture.

## picture id -> the boxes (Rect2, normalised) in which red-dominant pixels are recoloured.
const PATCHES: Dictionary = {
	"NPC-HESPER": [Rect2(0.415, 0.085, 0.090, 0.060), Rect2(0.785, 0.585, 0.105, 0.080)],  # the cap's cross, the armband's cross
	"STORY-EPI-WRINKLES": [Rect2(0.549, 0.243, 0.032, 0.037), Rect2(0.470, 0.368, 0.034, 0.050)],  # Hesper in the fountain square: cap, armband
}
## A pixel is "red" (part of the cross) when red leads both other channels by this much (0-1) and is at least RED_MIN.
const RED_LEAD: float = 0.22
const RED_MIN: float = 0.35
## The green the cross becomes: the red channel carries the painted shading, scaled per channel (a muted leaf green).
const GREEN_SCALE: Color = Color(0.42, 0.66, 0.38)


static func has_patch(id: String) -> bool:
	return PATCHES.has(id)


## `texture` with its patches applied (a new ImageTexture), or the same texture when the id has none or the image cannot be read.
static func apply(id: String, texture: Texture2D) -> Texture2D:
	if texture == null or not PATCHES.has(id):
		return texture
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return texture
	image = image.duplicate() as Image
	if image.is_compressed():
		if image.decompress() != OK:
			return texture
	image.convert(Image.FORMAT_RGBA8)
	var changed: int = 0
	for box: Rect2 in PATCHES[id] as Array:
		changed += recolour_box(image, box)
	return ImageTexture.create_from_image(image) if changed > 0 else texture


## Recolours the red-dominant pixels of `image` inside the normalised `box`; returns how many pixels changed.
static func recolour_box(image: Image, box: Rect2) -> int:
	var x0: int = clampi(int(floor(box.position.x * image.get_width())), 0, image.get_width())
	var y0: int = clampi(int(floor(box.position.y * image.get_height())), 0, image.get_height())
	var x1: int = clampi(int(ceil(box.end.x * image.get_width())), 0, image.get_width())
	var y1: int = clampi(int(ceil(box.end.y * image.get_height())), 0, image.get_height())
	var changed: int = 0
	for y: int in range(y0, y1):
		for x: int in range(x0, x1):
			var pixel: Color = image.get_pixel(x, y)
			if is_red(pixel):
				image.set_pixel(x, y, greened(pixel))
				changed += 1
	return changed


static func is_red(pixel: Color) -> bool:
	return pixel.a > 0.05 and pixel.r >= RED_MIN and pixel.r - pixel.g >= RED_LEAD and pixel.r - pixel.b >= RED_LEAD


static func greened(pixel: Color) -> Color:
	return Color(pixel.r * GREEN_SCALE.r, pixel.r * GREEN_SCALE.g, pixel.r * GREEN_SCALE.b, pixel.a)
