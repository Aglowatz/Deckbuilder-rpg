extends SceneTree
## Measures every character frame in assets/art/world_test/sprites/ (and the cosmetic cloak sets in cosmetics_manifest.json) and writes the head anchor of every frame
## ("head": {frame: [x, y_top, width]}) and the cloak hue ("cloak_hue": [hue, half_width]) into the manifest it belongs to. Run after tools/world_test_import.gd and
## tools/import_cosmetics.gd:  Godot --headless --path . -s res://tools/sprite_anchors.gd
## (Reads the PNG files directly; it does not need Godot's import step.)

const SPRITES: String = "res://assets/art/world_test/sprites/"
const MANIFESTS: Array[String] = ["manifest.json", "cosmetics_manifest.json"]


func _initialize() -> void:
	for manifest_name: String in MANIFESTS:
		_process_manifest(manifest_name)
	quit()


func _process_manifest(manifest_name: String) -> void:
	var path: String = SPRITES + manifest_name
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var manifest: Dictionary = JSON.parse_string(file.get_as_text()) as Dictionary
	file.close()
	for character: Variant in manifest.keys():
		var entry: Dictionary = manifest[character] as Dictionary
		var head: Dictionary = {}
		var sample: Array = []
		for frame: Variant in entry.get("frames", []) as Array:
			var image_path: String = ProjectSettings.globalize_path("%s%s/%s.png" % [SPRITES, str(character), str(frame)])
			if not FileAccess.file_exists(image_path):
				continue
			var image: Image = Image.load_from_file(image_path)
			if image == null:
				continue
			image.convert(Image.FORMAT_RGBA8)
			var anchor: Array = SpriteAnchors.head_anchor(image)
			if anchor.size() >= 3:
				head[str(frame)] = [snappedf(float(anchor[0]), 0.1), snappedf(float(anchor[1]), 0.1), snappedf(float(anchor[2]), 0.1)]
			if str(frame).begins_with("BACK") and str(frame).ends_with("_IDLE"):  # from behind the cloak covers most of the figure
				sample.append(image)
		entry["head"] = head
		# Apparel Part 2: the hero's hat follows the head TRACKED from each direction's idle frame (one head width per direction, the bob and sway exactly),
		# not the per-frame measurement, whose width wobbles with the hair and would make the hat pulse during the walk.
		if str(character).begins_with("PLAYER"):
			entry["hat_anchor"] = _track_heads(str(character), head)
		if not sample.is_empty():
			var hue: Array = SpriteAnchors.cloak_hue(sample)
			entry["cloak_hue"] = [snappedf(float(hue[0]), 0.001), float(hue[1])]
		print("sprite_anchors: %s: %d head anchors, cloak hue %s" % [str(character), head.size(), str(entry.get("cloak_hue", []))])
	var out: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	out.store_string(JSON.stringify(manifest, "\t"))
	out.close()


## frame -> [x, y_top, head_width] for the hat: the idle frame's anchor of that direction moved by SpriteAnchors.head_offset.
func _track_heads(character: String, head: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var idles: Dictionary = {}
	for frame: Variant in head.keys():
		var key: String = str(frame)
		var dir_name: String = key.get_slice("_", 0)
		var idle_key: String = dir_name + "_IDLE"
		var idle_anchor: Array = head.get(idle_key, []) as Array
		if idle_anchor.size() < 3:
			result[key] = head[frame]
			continue
		if not idles.has(idle_key):
			idles[idle_key] = _image(character, idle_key)
		var offset: Vector2i = Vector2i.ZERO
		if key != idle_key:
			offset = SpriteAnchors.head_offset(idles[idle_key] as Image, idle_anchor, _image(character, key))
		result[key] = [snappedf(float(idle_anchor[0]) + float(offset.x), 0.1), snappedf(float(idle_anchor[1]) + float(offset.y), 0.1), float(idle_anchor[2])]
	return result


func _image(character: String, frame: String) -> Image:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path("%s%s/%s.png" % [SPRITES, character, frame]))
	image.convert(Image.FORMAT_RGBA8)
	return image
