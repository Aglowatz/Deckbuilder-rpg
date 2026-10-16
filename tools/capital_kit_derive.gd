extends SceneTree
## Derived tiles of the Capital kit (zone "final"), written next to the imported art and registered in data/art/zone_kits/final.json (hand entries survive a
## re-import): CAP-WALL-PASTEL is painted as three horizontal bands "so each can be cropped as its own tile" (the sheet), so each band becomes its own
## tile (-PINK, -MINT, -BLUE: the band's middle, mirrored top-to-bottom so it tiles); CAP-ROOF-PASTEL is blue only, and the paint-overs roof the
## identical houses pink as well, so -PINK is the same tiles hue-turned to the sheet's pastel pink. Re-run after a re-import of either source.
##   Godot --headless --path . -s res://tools/capital_kit_derive.gd

const DIR: String = "res://assets/art/zone_kits/final/"
const REGISTRY: String = "res://data/art/zone_kits/final.json"


func _initialize() -> void:
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY)) as Dictionary
	var items: Dictionary = registry["items"] as Dictionary
	var pastel: Image = Image.load_from_file(ProjectSettings.globalize_path(DIR + "CAP-WALL-PASTEL.webp"))
	var band_h: int = pastel.get_height() / 3
	var names: Array[String] = ["PINK", "MINT", "BLUE"]
	for index: int in range(3):
		# the middle 60 % of the band (no blend with the next band), mirrored below itself so the tile repeats without a seam
		var inset: int = int(float(band_h) * 0.2)
		var crop: Image = pastel.get_region(Rect2i(0, index * band_h + inset, pastel.get_width(), band_h - inset * 2))
		var tile: Image = Image.create(crop.get_width(), crop.get_height() * 2, false, crop.get_format())
		tile.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), Vector2i.ZERO)
		var flipped: Image = crop.duplicate() as Image
		flipped.flip_y()
		tile.blit_rect(flipped, Rect2i(Vector2i.ZERO, flipped.get_size()), Vector2i(0, crop.get_height()))
		var id: String = "CAP-WALL-PASTEL-%s" % names[index]
		tile.save_webp(ProjectSettings.globalize_path(DIR + id + ".webp"), true, 0.9)
		items[id] = _entry(items["CAP-WALL-PASTEL"] as Dictionary, id, "Pastel facade wall (%s band)" % names[index].to_lower(), tile.get_size())
	var roof: Image = Image.load_from_file(ProjectSettings.globalize_path(DIR + "CAP-ROOF-PASTEL.webp"))
	roof.convert(Image.FORMAT_RGBA8)
	for y: int in range(roof.get_height()):
		for x: int in range(roof.get_width()):
			var c: Color = roof.get_pixel(x, y)
			# blue (h ~0.58) to the sheet's pastel pink (#F5C6D0, h ~0.96), keeping the painted value and a pastel saturation
			roof.set_pixel(x, y, Color.from_hsv(fposmod(c.h + 0.38, 1.0), c.s * 0.95, minf(c.v * 1.02, 1.0), c.a))
	roof.save_webp(ProjectSettings.globalize_path(DIR + "CAP-ROOF-PASTEL-PINK.webp"), true, 0.9)
	items["CAP-ROOF-PASTEL-PINK"] = _entry(items["CAP-ROOF-PASTEL"] as Dictionary, "CAP-ROOF-PASTEL-PINK", "Pastel roof tile (pink)", roof.get_size())
	var file: FileAccess = FileAccess.open(REGISTRY, FileAccess.WRITE)
	file.store_string(JSON.stringify(registry, "\t", true))
	file.close()
	print("capital_kit_derive: 4 derived tiles written")
	quit(0)


## A registry entry for a derived tile: the source's numbers, its own size and tile (same texel density), no normal / roughness maps of its own.
func _entry(source: Dictionary, id: String, asset: String, px: Vector2i) -> Dictionary:
	var entry: Dictionary = source.duplicate(true)
	entry["id"] = id
	entry["asset"] = asset
	entry["derived_from"] = str(source["id"])
	entry["px"] = [px.x, px.y]
	entry["maps"] = false
	entry["slot"] = "%s.%s" % [str(source.get("group", "wall")), id.to_lower()]
	entry["tile_v"] = float(source["tile_u"]) * float(px.y) / float(px.x)
	entry.erase("seam")
	return entry
