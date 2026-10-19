class_name FeedbackReport
extends RefCounted
## Playtest feedback: one folder per report under user://feedback/ holding report.json (rating, notes, version, game state),
## screenshot.png and game.log (a copy of the engine log). Testers zip the whole feedback folder and send it back.

## Where reports go (a static var so tests and smoke runs can redirect it).
static var base: String = "user://feedback"
const LOG_PATH: String = "user://logs/godot.log"
const MAX_NOTES: int = 4000


## The version string shown in menus and reports.
static func version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))


## Makes sure the feedback folder exists and returns its real path on disk.
static func folder_path() -> String:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base))
	return ProjectSettings.globalize_path(base)


## Opens the feedback folder in the system file browser.
static func open_folder() -> void:
	OS.shell_open(folder_path())


## What the game knows about itself right now (also safe on the title screen, with no hero yet).
static func game_state() -> Dictionary:
	var state: Dictionary = {
		"version": version(),
		"save_format": Session.SAVE_FORMAT,
		"os": OS.get_name(),
		"godot": Engine.get_version_info().get("string", ""),
		"debug_build": OS.is_debug_build(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"window": str(DisplayServer.window_get_size()),
		"area": SceneManager.current_area,
		"has_hero": Session.has_profile(),
	}
	if Session.has_profile():
		state["session"] = Session.slot_meta()
		state["location_name"] = Session.location_name()
		state["quest"] = current_quest()
		# Daytime Oct 19: what a balance report needs at a glance (the save copy has the rest).
		state["path"] = Affinity.display_name(Session.profile.primary_affinity)
		state["deck_size"] = Session.deck.size() if Session.deck != null else 0
		state["duels_won"] = Session.counter("duels_won")
		state["zones_freed"] = ZoneCompletion.count(Session.flags)
	return state


## The quest the HUD tracker shows and its current step ({} with none).
static func current_quest() -> Dictionary:
	var quest: QuestData = QuestCatalog.find(Session.quest_log.tracked_id())
	if quest == null or quest.objectives.is_empty():
		return {}
	var step: Dictionary = QuestTracker.current_objective(quest, Session.quest_log, Session.unlock_state())
	return {"id": quest.id, "title": quest.title, "step": str(step.get("text", "")), "progress": "%d/%d" % [int(step.get("have", 0)), int(step.get("need", 0))]}


## Overnight Oct 18, Part 3: copies the autosave (and its backup) into the report, so the problem can be loaded and seen; cycle 16 adds
## settings.cfg (camera, quality and text options change what the tester sees).
static func _copy_saves(dir: String) -> void:
	for source: String in [SaveSlots.path_for(SaveSlots.AUTOSAVE), SaveSystem.backup_path(SaveSlots.path_for(SaveSlots.AUTOSAVE)), Settings.PATH]:
		if FileAccess.file_exists(source):
			DirAccess.copy_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path("%s/%s" % [dir, source.get_file()]))


## Writes a report and returns the folder it went into ("" when it could not be written).
## `screenshot` may be null (headless runs); `when` is injectable for tests.
static func write(rating: int, notes: String, screenshot: Image, root: String = "", when: Dictionary = {}) -> String:
	if root.is_empty():
		root = base
	var stamp: Dictionary = when if not when.is_empty() else Time.get_datetime_dict_from_system()
	var name: String = "v%s_%04d-%02d-%02d_%02d-%02d-%02d" % [version(), stamp.year, stamp.month, stamp.day, stamp.hour, stamp.minute, stamp.second]
	var dir: String = "%s/%s" % [root, name]
	var suffix: int = 2
	while DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
		dir = "%s/%s_%d" % [root, name, suffix]
		suffix += 1
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir)) != OK:
		return ""
	var report: Dictionary = {
		"rating": clampi(rating, 0, 5),
		"notes": notes.substr(0, MAX_NOTES),
		"created": "%04d-%02d-%02d %02d:%02d:%02d" % [stamp.year, stamp.month, stamp.day, stamp.hour, stamp.minute, stamp.second],
		"state": game_state(),
		"has_screenshot": screenshot != null and not screenshot.is_empty(),
	}
	var file: FileAccess = FileAccess.open("%s/report.json" % dir, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	if screenshot != null and not screenshot.is_empty():
		screenshot.save_png("%s/screenshot.png" % dir)
	_copy_log("%s/game.log" % dir)
	if Session.has_profile():
		Session.save_game()
	_copy_saves(dir)
	return ProjectSettings.globalize_path(dir)


static func _copy_log(target: String) -> void:
	if not FileAccess.file_exists(LOG_PATH):
		return
	var source: FileAccess = FileAccess.open(LOG_PATH, FileAccess.READ)
	if source == null:
		return
	var text: String = source.get_as_text()
	source.close()
	var out: FileAccess = FileAccess.open(target, FileAccess.WRITE)
	if out != null:
		out.store_string(text)
		out.close()
