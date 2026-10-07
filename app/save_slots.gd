class_name SaveSlots
extends RefCounted
## Brief 16, Group E: manual save slots and the autosave. Slot 0 is the autosave (written by `Session.save_game()` all the time), slots 1..SLOT_COUNT are
## manual saves made from the pause menu. Each slot is `<dir>/slot_N.json` (the whole campaign plus a `meta` block: name, date, playtime, level, location,
## gold) with an optional `slot_N.png` screenshot thumbnail. The old single save (`user://save.json`) is moved into slot 1 the first time the game starts.

const SLOT_COUNT: int = 5
const AUTOSAVE: int = 0
const LEGACY_PATH: String = "user://save.json"
const THUMB_SIZE: Vector2i = Vector2i(320, 180)

## The folder the slots live in (tests point it somewhere else).
static var dir: String = "user://saves/"


static func path_for(slot: int) -> String:
	return dir.path_join("autosave.json" if slot == AUTOSAVE else "slot_%d.json" % slot)


static func thumb_path(slot: int) -> String:
	return dir.path_join("autosave.png" if slot == AUTOSAVE else "slot_%d.png" % slot)


static func is_valid_slot(slot: int) -> bool:
	return slot >= AUTOSAVE and slot <= SLOT_COUNT


static func exists(slot: int) -> bool:
	return SaveSystem.exists(path_for(slot))


static func slot_label(slot: int) -> String:
	return "Autosave" if slot == AUTOSAVE else "Slot %d" % slot


## What the slot list shows: {} for an empty slot, else {slot, name, saved_at (unix), playtime (seconds), level, location, gold, thumbnail (bool), compatible (bool)}.
static func info(slot: int) -> Dictionary:
	if not exists(slot):
		return {}
	var data: Dictionary = SaveSystem.read(path_for(slot))
	if data.is_empty():
		return {}
	var meta: Dictionary = data.get("meta", {}) as Dictionary
	return {
		"slot": slot,
		"name": str(meta.get("name", "")) if not str(meta.get("name", "")).is_empty() else slot_label(slot),
		"saved_at": int(meta.get("saved_at", FileAccess.get_modified_time(path_for(slot)))),
		"playtime": float(meta.get("playtime", data.get("playtime", 0.0))),
		"level": int(meta.get("level", data.get("level", 1))),
		"location": str(meta.get("location", "Unknown")),
		"scene": str(meta.get("scene", "town")),
		"gold": int(meta.get("gold", data.get("gold", 0))),
		"thumbnail": FileAccess.file_exists(thumb_path(slot)),
		"compatible": int(data.get("save_format", 1)) == Session.SAVE_FORMAT,
	}


static func load_data(slot: int) -> Dictionary:
	return SaveSystem.read(path_for(slot))


## Writes `data` (a `Session.to_dict()`) to the slot with its thumbnail (an Image or null).
static func write(slot: int, data: Dictionary, thumbnail: Image) -> bool:
	if not is_valid_slot(slot):
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	if not SaveSystem.write(data, path_for(slot)):
		return false
	if thumbnail != null:
		var small: Image = thumbnail.duplicate() as Image
		small.resize(THUMB_SIZE.x, THUMB_SIZE.y, Image.INTERPOLATE_BILINEAR)
		small.save_png(ProjectSettings.globalize_path(thumb_path(slot)))
	return true


static func delete(slot: int) -> void:
	SaveSystem.delete(path_for(slot))
	SaveSystem.delete(thumb_path(slot))


static func thumbnail(slot: int) -> Texture2D:
	var path: String = thumb_path(slot)
	if not FileAccess.file_exists(path):
		return null
	var image: Image = Image.load_from_file(path)
	return ImageTexture.create_from_image(image) if image != null else null


## The slot (autosave included) saved most recently, or -1 when there are no saves.
static func latest_slot() -> int:
	var best: int = -1
	var best_time: int = -1
	for slot: int in range(AUTOSAVE, SLOT_COUNT + 1):
		var found: Dictionary = info(slot)
		if found.is_empty() or not bool(found["compatible"]):
			continue
		if int(found["saved_at"]) > best_time:
			best_time = int(found["saved_at"])
			best = slot
	return best


static func any_save() -> bool:
	return latest_slot() >= 0


## Moves the old single save into slot 1 (and keeps it as the autosave so Continue still works). Nothing is lost: the old file is renamed `save.json.migrated`.
## Returns true when a save was migrated.
static func migrate_legacy() -> bool:
	if not FileAccess.file_exists(LEGACY_PATH):
		return false
	var data: Dictionary = SaveSystem.read(LEGACY_PATH)
	if data.is_empty():
		return false
	if not exists(1):
		var migrated: Dictionary = data.duplicate(true)
		var meta: Dictionary = (migrated.get("meta", {}) as Dictionary).duplicate()
		meta["name"] = "Earlier save"
		meta["saved_at"] = FileAccess.get_modified_time(LEGACY_PATH)
		meta["level"] = int(data.get("level", 1))
		meta["gold"] = int(data.get("gold", 0))
		if not meta.has("location"):
			meta["location"] = "Unknown"
		migrated["meta"] = meta
		write(1, migrated, null)
	if not exists(AUTOSAVE):
		write(AUTOSAVE, data, null)
	var backup: String = LEGACY_PATH + ".migrated"
	if FileAccess.file_exists(backup):
		DirAccess.remove_absolute(backup)
	DirAccess.rename_absolute(LEGACY_PATH, backup)
	return true


static func format_playtime(seconds: float) -> String:
	var total: int = int(seconds)
	var hours: int = total / 3600
	var minutes: int = (total % 3600) / 60
	return "%dh %02dm" % [hours, minutes] if hours > 0 else "%dm %02ds" % [minutes, total % 60]


static func format_date(unix: int) -> String:
	var parts: Dictionary = Time.get_datetime_dict_from_unix_time(unix)
	return "%04d-%02d-%02d %02d:%02d" % [int(parts["year"]), int(parts["month"]), int(parts["day"]), int(parts["hour"]), int(parts["minute"])]
