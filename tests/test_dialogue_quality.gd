extends GutTest
## Overnight Oct 19 (Part 5, the dialogue pass): the checks the pass promised. Every line of the story files AND of the dungeon content text fits the
## dialogue box; no retired name (docs/design/canon.md "Banned old names") appears in any player-facing text; every quest step tells the player what to do.

const CANON_PATH: String = "res://docs/design/canon.md"
const CONTENT_PATH: String = "res://data/dungeons/dungeon_content.json"
const TIPS_PATH: String = "res://data/loading/loading_tips.txt"
const NPCS_PATH: String = "res://data/npcs/npcs.json"
const MAX_LINES_DEFAULT: int = 4
const MAX_LINES_LARGE: int = 6
## The banned list as of Oct 19, used when the canon file cannot be read (docs/ may be ignored by the importer; the file is read as plain text).
const FALLBACK_BANNED: Array[String] = ["Pathavia", "Concord Crossing", "Concordia Prime", "Neatropolis", "Mabbit Quill", "Tilda Marrow", "Grandfather Marrow",
	"Haulsworth", "Odile Bisque", "Gus Peelings", "Zinnia Vex", "Z.V.", "Crucible & Co.", "Aurelio", "Saucier", "Thaddeus", "Commander Gristle",
	"Registrar of Final Approvals", "Fernwick Loam", "Torvin", "Corwyn", "Over-Seasoned", "Thistlebark", "Vesna", "Tuskmore", "Trial of the Hollow",
	"Central Throne", "Gate Captain", "Tiny Tony", "Dolcetta", "Heartlift", "Bev Pettigrew", "Head Spotter", "Grand Clashatorium", "Brenda"]

var _box: DialogueBox


func before_all() -> void:
	_box = DialogueBox.new()
	add_child(_box)


func after_all() -> void:
	_box.queue_free()


## The banned names, read from the canon file's "Banned old names" bullet list (one source of truth).
static func banned_names() -> Array[String]:
	var names: Array[String] = []
	var text: String = FileAccess.get_file_as_string(CANON_PATH)
	var inside: bool = false
	for raw: String in text.split("\n"):
		var line: String = raw.strip_edges()
		if line.begins_with("## "):
			inside = line.to_lower().begins_with("## banned old names")
			continue
		if inside and line.begins_with("**"):
			break
		if inside and line.begins_with("- "):
			names.append(line.substr(2).strip_edges())
	return names if not names.is_empty() else FALLBACK_BANNED.duplicate()


static func _content_text() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONTENT_PATH))
	if parsed is Dictionary and (parsed as Dictionary).get("text") is Dictionary:
		return (parsed as Dictionary)["text"] as Dictionary
	return {}


## Every player-facing string: story files (values, never keys), dungeon content text, loading tips, NPC names and barks, quest titles, summaries and steps.
static func player_text() -> Dictionary:
	var result: Dictionary = {}
	var story: StoryText = StoryText.shared()
	for key: Variant in story.texts.keys():
		result["intro:%s" % key] = story.texts[key]
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer", "final"]:
		var zone: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
		if zone != null:
			for key: Variant in zone.lines.keys():
				result["%s:%s" % [zone_id, key]] = zone.lines[key]
	var content: Dictionary = _content_text()
	for key: Variant in content.keys():
		result["content:%s" % key] = content[key]
	result["tips"] = Array(FileAccess.get_file_as_string(TIPS_PATH).split("\n"))
	var npcs: Variant = JSON.parse_string(FileAccess.get_file_as_string(NPCS_PATH))
	if npcs is Dictionary:
		for id: Variant in (npcs as Dictionary).keys():
			result["npc:%s" % id] = _strings_of((npcs as Dictionary)[id], ["name", "display_name", "title", "barks"])
	elif npcs is Array:
		for entry: Variant in npcs as Array:
			if entry is Dictionary:
				result["npc:%s" % str((entry as Dictionary).get("id", "?"))] = _strings_of(entry, ["name", "display_name", "title", "barks"])
	for quest: QuestData in QuestCatalog.all():
		var lines: Array = [quest.title, quest.summary]
		for objective: QuestObjective in quest.objectives:
			lines.append(objective.text)
			lines.append(objective.hint)
		result["quest:%s" % quest.id] = lines
	return result


static func _strings_of(value: Variant, fields: Array[String]) -> Array:
	var out: Array = []
	if not (value is Dictionary):
		return out
	for field: String in fields:
		var item: Variant = (value as Dictionary).get(field)
		if item is String:
			out.append(item)
		elif item is Array:
			for entry: Variant in item as Array:
				out.append(str(entry))
	return out


static func _lines(value: Variant) -> Array:
	if value is Array:
		return value as Array
	return [str(value)]


func test_canon_lists_the_banned_names() -> void:
	assert_gte(banned_names().size(), 20, "the canon file's banned list is read")


func test_no_banned_old_name_in_player_text() -> void:
	var banned: Array[String] = banned_names()
	var hits: PackedStringArray = []
	var all_text: Dictionary = player_text()
	for key: Variant in all_text.keys():
		for line: Variant in _lines(all_text[key]):
			for name: String in banned:
				if str(line).contains(name):
					hits.append("%s: \"%s\" in %s" % [key, name, str(line).substr(0, 70)])
	assert_eq(hits.size(), 0, "retired names in player text:\n%s" % "\n".join(hits.slice(0, 25)))


func test_every_quest_step_says_what_to_do() -> void:
	var missing: PackedStringArray = []
	var quests: int = 0
	for quest: QuestData in QuestCatalog.all():
		quests += 1
		if quest.title.strip_edges().is_empty():
			missing.append("%s has no title" % quest.id)
		if quest.objectives.is_empty():
			missing.append("%s has no steps" % quest.id)
		for index: int in range(quest.objectives.size()):
			var text: String = quest.objectives[index].text.strip_edges()
			if text.length() < 6:
				missing.append("%s step %d: \"%s\"" % [quest.id, index, text])
	assert_gt(quests, 20, "the whole quest catalog is checked")
	assert_eq(missing.size(), 0, "quest steps without instruction text:\n%s" % "\n".join(missing))


func test_every_dungeon_content_line_fits_the_box() -> void:
	var too_long: PackedStringArray = []
	var content: Dictionary = _content_text()
	for key: Variant in content.keys():
		for line: Variant in _lines(content[key]):
			var text: String = Villain.fill(str(line))
			if _box.wrapped_lines(text, 1.0) > MAX_LINES_DEFAULT or _box.wrapped_lines(text, 1.4) > MAX_LINES_LARGE:
				too_long.append("%s: %s" % [key, text.substr(0, 60)])
	assert_gt(content.size(), 20, "the dungeon content text is checked")
	assert_eq(too_long.size(), 0, "dungeon content lines too long for the box:\n%s" % "\n".join(too_long))


## Overnight Oct 19 (Phase 2): lines the scenes read straight from the story resource's arrays are shown with their tokens filled
## (the Restless Cairn used to show a raw "{villain}"); the awakening lines are read raw and must not carry a token.
func test_raw_story_arrays_show_no_raw_tokens() -> void:
	var story: StoryText = StoryText.shared()
	for lines: Array[String] in [story.graveyard_intro_lines, story.graveyard_victory_lines, story.graveyard_defeat_lines,
			story.equipment_vendor_intro_lines, story.equipment_vendor_return_lines]:
		for line: String in StoryText._filled(lines):
			assert_false(line.contains("{"), "a token is left in: %s" % line)
	for line: String in story.awakening_lines:
		assert_false(line.contains("{"), "the awakening lines are shown raw: %s" % line)
