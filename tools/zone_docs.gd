extends Node
## Writes docs/zone_plans/<area>.md and docs/art/zone_kits/<area>.md (+ ALL.md) from data/subareas, data/zone_styles, data/source/art_bible.csv and `ZoneDocsVocab`.
## Run: Godot --headless --path . res://tools/zone_docs.tscn   (the hand-written gainlands plan is left alone)

const CSV_NAMES: Dictionary = {
	"main_town": "Main Town", "starting_forest": "Starting Forest", "gainlands": "The Gainlands", "dna": "The Department", "buffet": "The Endless", "heap": "The Verdant",
	"capital_outside": "The Capital: Outside", "capital_inside": "The Capital: Inside", "castle_grounds": "Primm", "pathology_lab": "The Path-ology",
}
const HEADER: String = "| ID | Asset | Category | Lock | Image Description (for ChatGPT) | Size / Format | In-Game Use | Priority |\n|---|---|---|---|---|---|---|---|\n"


func _ready() -> void:
	var rows: Dictionary = _csv_rows()
	var all_lines: PackedStringArray = PackedStringArray()
	var totals: PackedStringArray = PackedStringArray()
	var grand: int = 0
	for area_id: String in SubAreaDefs.AREAS:
		var row: PackedStringArray = rows.get(area_id, PackedStringArray()) as PackedStringArray
		if area_id != "gainlands":
			_write("res://docs/zone_plans/%s.md" % area_id, _plan(area_id, row))
		var kit: Array[String] = _kit_rows(area_id, row)
		var text: String = "# %s: new art needed (sheet-ready)\n\nBudget (Art Bible G-09): %s. Reuse the shared kit (ENV-*) wherever possible; this lists only what is new. Locks: SURFACE, CUTOUT, TREE, SHEET, CONCEPT, BACKDROP. Palette %s.\n\n%s%s\n" % [
			str(SubAreaDefs.area(area_id).get("name", area_id)), _budget(area_id, row), ", ".join(_palette(area_id)), HEADER, "\n".join(kit)]
		_write("res://docs/art/zone_kits/%s.md" % area_id, text)
		totals.append("| %s | %d | %s |" % [str(SubAreaDefs.area(area_id).get("name", area_id)), kit.size(), _budget(area_id, row)])
		grand += kit.size()
		all_lines.append_array(kit)
	var all_text: String = "# All zones: new art needed (sheet-ready)\n\nOne row per image, all areas. Per-area files: docs/art/zone_kits/<area>.md.\n\n| Area | New images listed | Art Bible budget |\n|---|---|---|\n%s\n| **Total** | **%d** | |\n\n%s%s\n" % ["\n".join(totals), grand, HEADER, "\n".join(all_lines)]
	_write("res://docs/art/zone_kits/ALL.md", all_text)
	print("zone docs written: %d rows" % grand)
	get_tree().quit()


func _write(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _csv_rows() -> Dictionary:
	var result: Dictionary = {}
	var file: FileAccess = FileAccess.open("res://data/source/art_bible.csv", FileAccess.READ)
	var all: Array[PackedStringArray] = []
	while not file.eof_reached():
		all.append(file.get_csv_line())
	for area_id: String in CSV_NAMES.keys():
		for line: PackedStringArray in all:
			if line.size() > 9 and line[0].begins_with(str(CSV_NAMES[area_id])):
				result[area_id] = line
				break
	return result


func _budget(area_id: String, row: PackedStringArray) -> String:
	var text: String = row[9] if row.size() > 9 else ""
	if text == "" or text == "TBD":
		return "About %d" % int(ZoneDocsVocab.BUDGET.get(area_id, 25))
	return text


func _palette(area_id: String) -> Array[String]:
	var result: Array[String] = []
	for entry: Variant in ZoneStyles.style(area_id).get("palette", []) as Array:
		result.append(str(entry))
	return result


func _style_line(area_id: String, row: PackedStringArray) -> String:
	var palette: Array[String] = _palette(area_id)
	var mood: String = row[3] if row.size() > 3 else ""
	var building: String = row[4] if row.size() > 4 else ""
	return "Palette %s. Mood: %s. Building language: %s. Painted, not pixel: clean bold shapes, soft cel-shaded painting, rich harmonious colour, matching PAINTOVER-TOWN.png. No text or letters." % [", ".join(palette.slice(0, 5)), mood.to_lower(), building]


func _kit_rows(area_id: String, row: PackedStringArray) -> Array[String]:
	var prefix: String = str(ZoneDocsVocab.PREFIX[area_id])
	var style: String = _style_line(area_id, row)
	var lines: Array[String] = []
	# Paint-overs (one per hub and sub-area: the screenshots in docs/art/paintover_inputs).
	var zone_data: Dictionary = SubAreaDefs.area(area_id)
	var po_index: int = 0
	for sub_id: String in SubAreaDefs.sub_ids(area_id):
		po_index += 1
		var sub_name: String = str(SubAreaDefs.sub(area_id, sub_id).get("name", sub_id))
		lines.append("| %s-PO-%s | Paint-over: %s | Paint-over | CONCEPT | Full painted paint-over of %s from the Cinematic camera (see PO-%s-%s.png): %s | 1600x900 PNG | Visual target for the sub-area | %s |" % [prefix, sub_id.to_upper().replace("_", "-"), sub_name, sub_name, prefix, sub_id.to_upper().replace("_", "-"), "1" if po_index <= 2 else "3"])
	for entry: String in ZoneDocsVocab.SURFACES.get(area_id, []):
		var parts: PackedStringArray = entry.split("|")
		var priority: String = "1" if parts[0].begins_with("WALL") or parts[0].begins_with("GROUND") else "2"
		lines.append("| %s-%s | %s | Surface | SURFACE | %s Seamless, tileable, albedo only, flat even light. %s | 1024x1024 PNG, tileable | Kit material swap for this zone (%s) | %s |" % [prefix, parts[0], parts[1], parts[2], style, parts[0].split("-")[0].to_lower(), priority])
	for entry: String in ZoneDocsVocab.SHEETS.get(area_id, []):
		var parts: PackedStringArray = entry.split("|")
		lines.append("| %s-%s | %s | Cutout sheet | SHEET | %s Transparent background, clear gaps between items so each can be sliced apart. %s | 2048x1365 PNG, transparent, grid | Sliced into kit cutouts | 2 |" % [prefix, parts[0], parts[1], parts[2], style])
	for entry: String in ZoneDocsVocab.TREES.get(area_id, []):
		var parts: PackedStringArray = entry.split("|")
		lines.append("| %s-%s | %s | Tree / plant | TREE | %s Single object, transparent background, trunk base at bottom centre, round and storybook-sized. %s | 1024x1536 PNG, transparent | Tree card in the zone | 2 |" % [prefix, parts[0], parts[1], parts[2], style])
	for entry: String in ZoneDocsVocab.PROPS.get(area_id, []):
		var parts: PackedStringArray = entry.split("|")
		lines.append("| %s-%s | %s | Prop | CUTOUT | %s Single prop, transparent background, slightly oversized storybook scale. %s | 1024x1024 PNG, transparent | Prop in clusters | 3 |" % [prefix, parts[0], parts[1], parts[2], style])
	for entry: String in ZoneDocsVocab.DECALS.get(area_id, []):
		var parts: PackedStringArray = entry.split("|")
		lines.append("| %s-%s | %s | Decal | CUTOUT | %s Top-down, transparent soft edge. %s | 1024x1024 PNG, transparent | Ground decal | 3 |" % [prefix, parts[0], parts[1], parts[2], style])
	for entry: String in ZoneDocsVocab.SKIES.get(area_id, []):
		var parts: PackedStringArray = entry.split("|")
		lines.append("| %s-%s | %s | Sky / backdrop | BACKDROP | %s Wide, soft, no hard horizon objects in the middle. %s | 2048x1024 PNG | World look sky ring / distant backdrop | 2 |" % [prefix, parts[0], parts[1], parts[2], style])
	# Hero landmarks: the stand-ins named *-HERO-* in the sub-area data.
	for sub_id: String in SubAreaDefs.sub_ids(area_id):
		for item: Variant in SubAreaDefs.sub(area_id, sub_id).get("landmarks", []) as Array:
			var landmark: Dictionary = item as Dictionary
			var id: String = str(landmark.get("id", ""))
			if not id.contains("-HERO-"):
				continue
			var size_array: Array = landmark.get("size", [4, 4, 4]) as Array
			var title: String = id.get_slice("-HERO-", 1).replace("-", " ").capitalize()
			lines.append("| %s | Hero landmark: %s | Hero landmark | CONCEPT | Concept art of the %s for %s, 3/4 view, about %s x %s x %s m at storybook scale (a person is 1.7 m), clear silhouette. %s | 1536x1024 PNG | Replaces the %s stand-in in %s | 1 |" % [id, title, title.to_lower(), str(SubAreaDefs.sub(area_id, sub_id).get("name", sub_id)), str(size_array[0]), str(size_array[1]), str(size_array[2]), style, str(landmark.get("kind", "box")), sub_id])
	var _keep: Dictionary = zone_data
	return lines


func _plan(area_id: String, row: PackedStringArray) -> String:
	var zone: Dictionary = SubAreaDefs.area(area_id)
	var out: PackedStringArray = PackedStringArray()
	out.append("# %s: zone plan\n" % str(zone.get("name", area_id)))
	out.append("Art Bible row: %s; palette %s; mood %s; building language %s; material swaps %s. Style file `data/zone_styles/%s.json`. Data `data/subareas/%s/`.\n" % [
		row[1].to_lower() if row.size() > 1 else "", ", ".join(_palette(area_id)), row[3].to_lower() if row.size() > 3 else "", row[4].to_lower() if row.size() > 4 else "", row[5].to_lower() if row.size() > 5 else "", area_id, area_id])
	out.append("Hero landmarks (Art Bible): %s.\n" % (row[6] if row.size() > 6 else ""))
	out.append("## Structure (G-07)\n")
	out.append("| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |\n|---|---|---|---|---|---|---|")
	out.append("| **%s** (hub) | the existing scene `%s` | existing | existing landmarks | existing | all existing content | gates to %s |" % [str(zone.get("hub_name", "Hub")), SubAreaDefs.hub_scene(area_id).get_file(), ", ".join(_gate_names(area_id))])
	var secrets: PackedStringArray = PackedStringArray()
	var chests: int = 0
	var shrines: int = 0
	var lore: int = 0
	var vignettes: int = 0
	var vistas: int = 0
	var levers: int = 0
	for sub_id: String in SubAreaDefs.sub_ids(area_id):
		var d: Dictionary = SubAreaDefs.sub(area_id, sub_id)
		var hero: String = ""
		for item: Variant in d.get("landmarks", []) as Array:
			var landmark: Dictionary = item as Dictionary
			if str(landmark.get("id", "")).contains("-HERO-"):
				hero = str(landmark["id"])
				break
		var size_array: Array = d.get("size", [0, 0]) as Array
		var exits: PackedStringArray = PackedStringArray()
		for item: Variant in d.get("exits", []) as Array:
			exits.append(str((item as Dictionary).get("label", "")))
		var pois: PackedStringArray = PackedStringArray()
		for item: Variant in d.get("poi", []) as Array:
			var poi: Dictionary = item as Dictionary
			pois.append("%s (%s)" % [str(poi.get("title", "")), str(poi.get("type", ""))])
			match str(poi.get("type", "")):
				"chest":
					chests += 1
				"shrine":
					shrines += 1
				"lore":
					lore += 1
				"vignette":
					vignettes += 1
				"vista":
					vistas += 1
				"shortcut":
					levers += 1
					secrets.append("%s: %s opens a barrier (%s)" % [str(d.get("name", sub_id)), str(poi.get("title", "")), str(poi.get("opens", ""))])
		out.append("| **%s** | `%s` | %s | %s | %s x %s | %s | %s |" % [str(d.get("name", sub_id)), sub_id, str(d.get("mood", "")), hero, str(size_array[0]), str(size_array[1]), "; ".join(pois), ", ".join(exits)])
	out.append("\nA 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).\n")
	out.append("## Loops, shortcuts, secrets\n")
	out.append("* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/%s/`." % area_id)
	for secret: String in secrets:
		out.append("* Shortcut / secret: %s." % secret)
	if secrets.is_empty():
		out.append("* Secrets: the shrines and the far-corner chests.")
	out.append("\n## Where existing content goes\n")
	out.append("%s\n" % str(ZoneDocsVocab.EXISTING.get(area_id, "")))
	out.append("## New content\n")
	out.append("%d chests (rewards drawn from the zone's own chest tables: gold, items, cards), %d card shrines, %d lore pages, %d vignettes, %d vistas, %d lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.\n" % [chests, shrines, lore, vignettes, vistas, levers])
	out.append("## Status\n\nPlanned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/%s.md`, paint-over inputs `docs/art/paintover_inputs/%s/`, camera contact sheet `docs/art/zone_plans_shots/%s.png`. Details and numbers: `docs/overnight_report.md`." % [area_id, area_id, area_id])
	return "\n".join(out) + "\n"


func _gate_names(area_id: String) -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for gate: Dictionary in SubAreaDefs.gates(area_id):
		names.append(str(gate.get("label", "")))
	if names.is_empty():
		names.append("(entered from another sub-area)")
	return names
