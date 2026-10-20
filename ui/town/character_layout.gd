class_name CharacterLayout
extends RefCounted
## Oct 19 night (Part 3): where the Character screen's five equipment slots sit on its UI-BG-CHARACTER background, in screen units (1920 x 1080).
## Exactly five slots, one per EquipmentData.Slot, placed by the body part they dress on a figure that faces the viewer:
##   helm at the head, armor at the chest, boots at the feet, weapon at the figure's RIGHT hand = the SCREEN LEFT, relic at the figure's LEFT
##   hand = the SCREEN RIGHT.
## Two backgrounds are handled:
##   - the first UI-BG-CHARACTER (Oct 2026) paints eight empty frames beside the figure with leader lines. The five slots sit exactly on the five
##     painted frames whose lines point at the matching body part, and the three spare painted frames are covered with a parchment patch so
##     nothing reads as a sixth slot (`PAINTED_*`).
##   - the redone background has no painted frames: the game draws its own slot frames (UiSkin.equip_slot_style) on the figure's body parts
##     (`FIGURE_SLOT_CENTERS`, tunable without code through `slot_centers` in data/ui_config.cfg).
## Which one is in is `background_painted_slots` in data/ui_config.cfg; `bash tools/import_ui_art.sh` sets it to false by itself when it imports a
## UI-BG-CHARACTER that is not the painted-frames picture (by its source MD5), so the new background is drop-in.

const UI_CONFIG_PATH: String = "res://data/ui_config.cfg"
const SECTION: String = "character"
const PAINTED_KEY: String = "background_painted_slots"
const CENTERS_KEY: String = "slot_centers"
## MD5 of the source PNG of the first UI-BG-CHARACTER (data/source/ui_import_manifest.csv), the one with eight painted frames.
const PAINTED_BACKGROUND_MD5: String = "e9174b6497f6357112746bf1b478e015"
const SLOT_SIZE: float = 124.0
const DESIGN_SIZE: Vector2 = Vector2(1920, 1080)

## The five painted frames used as slots on the first background (background cover-fitted: x * 1.25, y * 1.25 - 100): helm on the top-left frame
## (its line points at the head), armor on the right frame beside the chest, weapon on the left frame at hand height (the figure's right hand),
## relic on the right frame at hand height (its left hand), boots on the bottom-right frame (its line points at the boots).
const PAINTED_SLOT_CENTERS: Dictionary = {
	EquipmentData.Slot.HELM: Vector2(419, 150),
	EquipmentData.Slot.ARMOR: Vector2(975, 344),
	EquipmentData.Slot.WEAPON: Vector2(394, 575),
	EquipmentData.Slot.RELIC: Vector2(981, 581),
	EquipmentData.Slot.BOOTS: Vector2(963, 801),
}
## The three painted frames of the first background that are no slot (top right, second left, bottom left): covered, never used.
const PAINTED_SPARE_CENTERS: Array[Vector2] = [Vector2(969, 157), Vector2(407, 327), Vector2(406, 775)]

## The figure's body parts on a background without painted frames (the silhouette of the first background: head, chest, hands, feet).
const FIGURE_SLOT_CENTERS: Dictionary = {
	EquipmentData.Slot.HELM: Vector2(691, 146),
	EquipmentData.Slot.ARMOR: Vector2(691, 336),
	EquipmentData.Slot.WEAPON: Vector2(487, 532),
	EquipmentData.Slot.RELIC: Vector2(893, 532),
	EquipmentData.Slot.BOOTS: Vector2(694, 902),
}
const SLOT_KEYS: Dictionary = {
	EquipmentData.Slot.HELM: "helm", EquipmentData.Slot.WEAPON: "weapon", EquipmentData.Slot.ARMOR: "armor",
	EquipmentData.Slot.BOOTS: "boots", EquipmentData.Slot.RELIC: "relic",
}

## -1 = read the config, 0 / 1 = forced (tests, screenshots).
static var _forced_painted: int = -1


## True while the background is the one with painted frames. A `--character_bg=clean` or `--character_bg=painted` command-line argument
## (tools/shot.sh passes extra arguments through) wins over the config so both layouts can be screenshot.
static func painted_background() -> bool:
	if _forced_painted >= 0:
		return _forced_painted == 1
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--character_bg=clean":
			return false
		if arg == "--character_bg=painted":
			return true
	var config: ConfigFile = ConfigFile.new()
	if config.load(UI_CONFIG_PATH) != OK:
		return true
	return bool(config.get_value(SECTION, PAINTED_KEY, true))


## Overrides the config for this run (tests, screenshots); null returns to the config file.
static func force_painted(value: Variant) -> void:
	_forced_painted = -1 if value == null else (1 if bool(value) else 0)


## The centre of every equipment slot (EquipmentData.Slot -> Vector2, screen units) for the given background.
static func slot_centers(painted: bool) -> Dictionary:
	if painted:
		return PAINTED_SLOT_CENTERS.duplicate()
	var centers: Dictionary = FIGURE_SLOT_CENTERS.duplicate()
	var config: ConfigFile = ConfigFile.new()
	if config.load(UI_CONFIG_PATH) == OK:
		var custom: Variant = config.get_value(SECTION, CENTERS_KEY, {})
		if custom is Dictionary:
			for slot: Variant in SLOT_KEYS:
				var point: Variant = (custom as Dictionary).get(SLOT_KEYS[slot])
				if point is Array and (point as Array).size() >= 2:
					centers[slot] = Vector2(float((point as Array)[0]), float((point as Array)[1]))
	return centers


## The rect of a slot (SLOT_SIZE square around its centre).
static func slot_rect(center: Vector2) -> Rect2:
	return Rect2(center - Vector2(SLOT_SIZE, SLOT_SIZE) * 0.5, Vector2(SLOT_SIZE, SLOT_SIZE))


## The painted frames to cover (empty on a background without painted frames).
static func spare_frame_centers(painted: bool) -> Array[Vector2]:
	return PAINTED_SPARE_CENTERS.duplicate() if painted else ([] as Array[Vector2])


## Whether a UI-BG-CHARACTER source file (by its MD5) is the picture with painted frames.
static func is_painted_background_md5(md5: String) -> bool:
	return md5 == PAINTED_BACKGROUND_MD5


## Sets `background_painted_slots` in the config file, keeping its comments; adds the [character] section when missing. True when written.
static func write_painted_flag(painted: bool, path: String = UI_CONFIG_PATH) -> bool:
	var text: String = FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	var line: String = "%s=%s" % [PAINTED_KEY, "true" if painted else "false"]
	var lines: PackedStringArray = text.split("\n")
	var replaced: bool = false
	for index: int in lines.size():
		if lines[index].strip_edges().begins_with(PAINTED_KEY + "="):
			lines[index] = line
			replaced = true
	var out: String = "\n".join(lines)
	if not replaced:
		if not out.contains("[%s]" % SECTION):
			out = out.rstrip("\n") + "\n\n[%s]\n" % SECTION
		out = out.replace("[%s]\n" % SECTION, "[%s]\n%s\n" % [SECTION, line])
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(out)
	file.close()
	return true


## Where a screen point falls on the background texture (cover-fitted to DESIGN_SIZE like `UiSkin.screen_background`).
static func texture_point(screen_point: Vector2, texture_size: Vector2) -> Vector2:
	var scale: float = maxf(DESIGN_SIZE.x / texture_size.x, DESIGN_SIZE.y / texture_size.y)
	var offset: Vector2 = (texture_size * scale - DESIGN_SIZE) * 0.5
	return (screen_point + offset) / scale


## The parchment colour round a painted frame: the per-channel median of a ring of samples just outside it (leader lines and stains are outvoted).
static func paper_colour(image: Image, screen_center: Vector2) -> Color:
	var size: Vector2 = Vector2(image.get_width(), image.get_height())
	var reds: Array[float] = []
	var greens: Array[float] = []
	var blues: Array[float] = []
	var reach: float = SLOT_SIZE * 0.62
	for step: int in 16:
		var angle: float = TAU * float(step) / 16.0
		var point: Vector2 = texture_point(screen_center + Vector2(cos(angle), sin(angle)) * reach, size)
		var x: int = clampi(int(point.x), 0, image.get_width() - 1)
		var y: int = clampi(int(point.y), 0, image.get_height() - 1)
		var colour: Color = image.get_pixel(x, y)
		reds.append(colour.r)
		greens.append(colour.g)
		blues.append(colour.b)
	reds.sort()
	greens.sort()
	blues.sort()
	return Color(reds[8], greens[8], blues[8], 1.0)
