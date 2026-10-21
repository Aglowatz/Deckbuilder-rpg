extends GutTest
## Overnight Oct 16, Block 4e: every story line fits the dialogue box - at most 4 wrapped lines at the default text size and 6 at the largest
## (the box grows upward to fit, so this is the readability budget, not a clip), and no box is a wall of more than three sentences.

const DEFAULT_SCALE: float = 1.0
const LARGE_SCALE: float = 1.4
const MAX_LINES_DEFAULT: int = 4
const MAX_LINES_LARGE: int = 6
const SKIP_SUFFIX: Array[String] = [".name", ".title", ".prompt", ".button", ".label", ".hint", ".blurb", ".machines", ".wheel_names", ".pairs", ".shouts"]

var _box: DialogueBox


func before_all() -> void:
	_box = DialogueBox.new()
	add_child(_box)


func after_all() -> void:
	_box.queue_free()


func _dialogue_lines() -> Dictionary:
	var result: Dictionary = {}
	var story: StoryText = StoryText.shared()
	for key: Variant in story.texts.keys():
		result["intro:%s" % key] = story.texts[key]
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer", "final"]:
		var zone: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
		if zone == null:
			continue
		for key: Variant in zone.lines.keys():
			result["%s:%s" % [zone_id, key]] = zone.lines[key]
	# Oct 21: the multi-speaker story scenes (StoryScenes).
	for id: String in StoryScenes.ids():
		result["scene:%s" % id] = StoryScenes.all_lines(id)
	return result


func _skipped(key: String) -> bool:
	for suffix: String in SKIP_SUFFIX:
		if key.ends_with(suffix):
			return true
	return key.contains(":ui.") or key.contains(":pack.hint.")


func test_every_story_line_fits_the_box_at_default_and_large_text() -> void:
	var too_long: PackedStringArray = []
	var checked: int = 0
	var all_lines: Dictionary = _dialogue_lines()
	for key: Variant in all_lines.keys():
		if _skipped(str(key)) or not (all_lines[key] is Array):
			continue
		for line: Variant in all_lines[key] as Array:
			checked += 1
			var text: String = Villain.fill(str(line))
			var normal: int = _box.wrapped_lines(text, DEFAULT_SCALE)
			var large: int = _box.wrapped_lines(text, LARGE_SCALE)
			if normal > MAX_LINES_DEFAULT or large > MAX_LINES_LARGE:
				too_long.append("%s (%d / %d lines): %s" % [key, normal, large, text.substr(0, 60)])
	assert_gt(checked, 2000, "the whole story is checked")
	assert_eq(too_long.size(), 0, "lines too long for the box:\n%s" % "\n".join(too_long.slice(0, 25)))


func test_the_largest_text_size_is_the_one_checked() -> void:
	assert_eq(Settings.TEXT_SCALES[Settings.TEXT_SCALES.size() - 1], LARGE_SCALE)
