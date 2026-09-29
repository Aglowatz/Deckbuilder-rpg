class_name DevTools
extends RefCounted
## New brief (third), Part E: the one gate deciding whether debug-only content (currently just the
## town's Dev Shrine) exists at all. `force_debug` defaults to the real `OS.is_debug_build()` but
## can be overridden by a test, since GUT itself always runs in a debug binary and could otherwise
## never observe the "release build" branch.

## Project setting namespace for an explicit override (`project.godot` -> [deckbuilder] section),
## separate from `OS.is_debug_build()` so a debug *export* (not just running from the editor) can
## still show dev content on purpose if you ever want that.
const SETTING_PATH: String = "deckbuilder/dev_shrine_enabled"


static func shrine_enabled(force_debug: bool = OS.is_debug_build()) -> bool:
	return force_debug or bool(ProjectSettings.get_setting(SETTING_PATH, false))
