class_name ArtImporter
extends RefCounted
## The card art importer (docs/art/art_pipeline.md): turns the PNG/JPG files in an inbox, named by Card ID, into 768x1152 WebP files in
## assets/art/cards/, moves the originals to a source folder and writes the art status report. Driven by `tools/import_art`.

const WIDTH: int = 768
const HEIGHT: int = 1152
const QUALITY: float = 0.85
const INPUT_EXTENSIONS: Array[String] = ["png", "jpg", "jpeg", "webp"]


class Result:
	extends RefCounted
	## Card IDs whose art was added or replaced this run.
	var added: Array[String] = []
	## Files in the inbox that name no known Card ID.
	var unknown: Array[String] = []
	## Files that could not be read or written (with the reason).
	var errors: Array[String] = []
	## Known IDs that still have no art after the run.
	var missing: Array[String] = []
	var present: int = 0
	## Card IDs whose existing art was replaced because the source image changed.
	var replaced: Array[String] = []
	## Card IDs (with the source size) whose image was not 2:3 and was centre-cropped.
	var cropped: Array[String] = []
	## Files that name an ID another file already names.
	var duplicates: Array[String] = []
	## Card IDs already up to date (source image unchanged since the last import).
	var unchanged: int = 0
	## Known IDs that have art after the run.
	var have: Array[String] = []
	var total: int = 0

	func summary() -> String:
		return "Art import: %d added, %d unknown files, %d errors; %d of %d cards and tokens have art, %d missing." % [
			added.size(), unknown.size(), errors.size(), present, total, missing.size(),
		]


## Reads `art_map.csv` (`filename,Card ID`; the filename with or without extension) into {lowercase stem -> Card ID}.
static func read_map(path: String) -> Dictionary:
	var map: Dictionary = {}
	if not FileAccess.file_exists(path):
		return map
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var first: bool = true
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if first:
			first = false
			continue
		if row.size() >= 2 and not row[0].strip_edges().is_empty() and not row[1].strip_edges().is_empty():
			map[row[0].strip_edges().get_basename().to_lower()] = row[1].strip_edges()
	return map


## Crops `image` to 2:3 (centred) and resizes it to WIDTH x HEIGHT.
static func fit_image(image: Image) -> Image:
	var target_ratio: float = float(WIDTH) / float(HEIGHT)
	var ratio: float = float(image.get_width()) / float(image.get_height())
	var crop: Rect2i = Rect2i(0, 0, image.get_width(), image.get_height())
	if ratio > target_ratio:
		crop.size.x = int(round(float(image.get_height()) * target_ratio))
		crop.position.x = (image.get_width() - crop.size.x) / 2
	elif ratio < target_ratio:
		crop.size.y = int(round(float(image.get_width()) / target_ratio))
		crop.position.y = (image.get_height() - crop.size.y) / 2
	var result: Image = image.get_region(crop)
	result.convert(Image.FORMAT_RGBA8)
	result.resize(WIDTH, HEIGHT, Image.INTERPOLATE_LANCZOS)
	return result



## True when `image` is not 2:3 (beyond a 0.5% tolerance), so `fit_image` will centre-crop it.
static func needs_crop(image: Image) -> bool:
	var target_ratio: float = float(WIDTH) / float(HEIGHT)
	var ratio: float = float(image.get_width()) / float(image.get_height())
	return absf(ratio - target_ratio) / target_ratio > 0.005


## Reads the import manifest (`Card ID,file,bytes,md5`) into {Card ID -> md5}.
static func read_manifest(path: String) -> Dictionary:
	var manifest: Dictionary = {}
	if not FileAccess.file_exists(path):
		return manifest
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var first: bool = true
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if first:
			first = false
			continue
		if row.size() >= 4:
			manifest[row[0]] = row[3]
	return manifest


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_csv_line(PackedStringArray(["Card ID", "file", "bytes", "md5"]))
	var ids: Array = rows.keys()
	ids.sort()
	for id: Variant in ids:
		file.store_csv_line(rows[id] as PackedStringArray)
	file.close()


## Imports art from an external, read-only folder (the Google Drive "Approved" folder): files are only ever read and copied (as
## converted WebP), never moved, renamed or deleted. Names must be `<Card ID or Token ID>.<png|jpg|jpeg|webp>`; anything else is
## reported (images) or ignored (non-images). A file is (re)imported when its Card ID has no art yet or its content hash differs
## from the one recorded in `manifest_path`. Files are processed strictly one at a time (one image in memory), which keeps memory flat on small PCs.
static func import_from_source(source_dir: String, out_dir: String, manifest_path: String, known: Dictionary) -> Result:
	var result: Result = Result.new()
	DirAccess.make_dir_recursive_absolute(_real(out_dir))
	var manifest: Dictionary = read_manifest(_real(manifest_path))
	var rows: Dictionary = {}
	# {Card ID -> [file name, modified time]}: when two files name one ID the newest wins.
	var chosen: Dictionary = {}
	var files: Array[String] = []
	for file_name: String in DirAccess.get_files_at(source_dir):
		files.append(file_name)
	files.sort()
	for file_name: String in files:
		if not INPUT_EXTENSIONS.has(file_name.get_extension().to_lower()):
			continue
		var card_id: String = file_name.get_basename()
		if not known.has(card_id):
			result.unknown.append(file_name)
			continue
		var modified: int = FileAccess.get_modified_time(source_dir.path_join(file_name))
		if chosen.has(card_id):
			result.duplicates.append("%s (also %s)" % [file_name, (chosen[card_id] as Array)[0]])
			if modified <= int((chosen[card_id] as Array)[1]):
				continue
		chosen[card_id] = [file_name, modified]
	var ids: Array = chosen.keys()
	ids.sort()
	for id: Variant in ids:
		var card_id: String = str(id)
		var file_name: String = str((chosen[card_id] as Array)[0])
		var full_path: String = source_dir.path_join(file_name)
		var hash: String = FileAccess.get_md5(full_path)
		var target: String = _real(out_dir.path_join("%s.webp" % card_id))
		var had_art: bool = FileAccess.file_exists(target)
		var bytes: int = 0
		var probe: FileAccess = FileAccess.open(full_path, FileAccess.READ)
		if probe != null:
			bytes = probe.get_length()
			probe.close()
		rows[card_id] = PackedStringArray([card_id, file_name, str(bytes), hash])
		if had_art and str(manifest.get(card_id, "")) == hash:
			result.unchanged += 1
			continue
		var outcome: String = _convert_file(full_path, target, file_name, result)
		if outcome.is_empty():
			rows.erase(card_id)
			continue
		if had_art:
			result.replaced.append(card_id)
		result.added.append(card_id)
		if outcome != "ok":
			result.cropped.append("%s (%s)" % [card_id, outcome])
	_write_manifest(_real(manifest_path), rows)
	_tally(result, out_dir, known)
	return result


## Reads one image, fits it to 2:3 and writes the WebP. Returns "" on failure (recorded in `result.errors`), else "ok" or the source size (e.g. "1024x1024") when it was centre-cropped.
## The image is local to this call, so it is freed before the next file loads.
static func _convert_file(full_path: String, target: String, file_name: String, result: Result) -> String:
	var image: Image = Image.load_from_file(full_path)
	if image == null or image.is_empty():
		result.errors.append("%s: not a readable image" % file_name)
		return ""
	var size_note: String = "%dx%d" % [image.get_width(), image.get_height()] if needs_crop(image) else "ok"
	var fitted: Image = fit_image(image)
	var error: Error = fitted.save_webp(target, true, QUALITY)
	if error != OK:
		result.errors.append("%s: could not write %s (error %d)" % [file_name, target, error])
		return ""
	return size_note


static func _tally(result: Result, out_dir: String, known: Dictionary) -> void:
	var ids: Array = known.keys()
	ids.sort()
	result.total = ids.size()
	for id: Variant in ids:
		if FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % str(id)))):
			result.present += 1
			result.have.append(str(id))
		else:
			result.missing.append(str(id))

static func _real(path: String) -> String:
	return ProjectSettings.globalize_path(path)


## Imports every file of `inbox_dir`. `known` maps every Card ID / Token ID to its name. Directories are res:// or absolute paths.
static func import_all(inbox_dir: String, out_dir: String, source_dir: String, map_path: String, known: Dictionary) -> Result:
	var result: Result = Result.new()
	var map: Dictionary = read_map(map_path)
	DirAccess.make_dir_recursive_absolute(_real(out_dir))
	var files: Array[String] = []
	for file_name: String in DirAccess.get_files_at(_real(inbox_dir)):
		files.append(file_name)
	files.sort()
	for file_name: String in files:
		if not INPUT_EXTENSIONS.has(file_name.get_extension().to_lower()):
			continue
		var stem: String = file_name.get_basename()
		var card_id: String = str(map.get(stem.to_lower(), stem))
		if not known.has(card_id):
			result.unknown.append(file_name)
			continue
		var image: Image = Image.load_from_file(_real(inbox_dir.path_join(file_name)))
		if image == null or image.is_empty():
			result.errors.append("%s: not a readable image" % file_name)
			continue
		var fitted: Image = fit_image(image)
		var target: String = _real(out_dir.path_join("%s.webp" % card_id))
		var error: Error = fitted.save_webp(target, true, QUALITY)
		if error != OK:
			result.errors.append("%s: could not write %s (error %d)" % [file_name, target, error])
			continue
		DirAccess.make_dir_recursive_absolute(_real(source_dir))
		var destination: String = _real(source_dir.path_join(file_name))
		if FileAccess.file_exists(destination):
			DirAccess.remove_absolute(destination)
		if DirAccess.rename_absolute(_real(inbox_dir.path_join(file_name)), destination) != OK:
			result.errors.append("%s: converted, but the original could not be moved to %s" % [file_name, source_dir])
		result.added.append(card_id)
	_tally(result, out_dir, known)
	return result


## The Markdown status report: every Card ID and Token ID with its name and whether its art exists.
static func status_markdown(out_dir: String, known: Dictionary, result: Result) -> String:
	var lines: Array[String] = []
	lines.append("# Card art status")
	lines.append("")
	lines.append("Generated by `tools/import_art`. Art loads from `assets/art/cards/<ID>.webp`; a card without art shows the placeholder.")
	lines.append("")
	lines.append("**%d of %d** cards and tokens have art; **%d** missing." % [result.present, result.total, result.missing.size()])
	if not result.added.is_empty():
		lines.append("")
		lines.append("Added this run: %s" % ", ".join(result.added))
	if not result.replaced.is_empty():
		lines.append("")
		lines.append("Replaced (source image changed): %s" % ", ".join(result.replaced))
	if not result.cropped.is_empty():
		lines.append("")
		lines.append("Centre-cropped to 2:3 (source size): %s" % ", ".join(result.cropped))
	if not result.unknown.is_empty():
		lines.append("")
		lines.append("Unknown files in the source folder or inbox (name them by Card ID or list them in `data/source/art_map.csv`): %s" % ", ".join(result.unknown))
	for problem: String in result.errors:
		lines.append("")
		lines.append("Error: %s" % problem)
	lines.append("")
	lines.append("| ID | Name | Art |")
	lines.append("|----|------|-----|")
	var ids: Array = known.keys()
	ids.sort()
	for id: Variant in ids:
		var exists: bool = FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % str(id))))
		lines.append("| %s | %s | %s |" % [str(id), str(known[id]).replace("|", "/"), "yes" if exists else "no"])
	lines.append("")
	return "\n".join(lines)
