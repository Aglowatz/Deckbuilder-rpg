extends GutTest
## Fresh eyes Oct 30: an OverlayScreen that overrides `_exit_tree` must call the base (WorldCover release, music pop, the log); the Deck
## Station skipped it and the forest stayed black after the station closed. A source scan, so every future screen is checked too.

const ROOTS: Array[String] = ["res://ui", "res://world"]


func test_every_overlay_screen_exit_tree_calls_super() -> void:
	var offenders: Array[String] = []
	var screens: int = 0
	for root: String in ROOTS:
		for path: String in _scripts_under(root):
			var text: String = FileAccess.get_file_as_string(path)
			if not text.contains("extends OverlayScreen"):
				continue
			screens += 1
			if text.contains("func _exit_tree") and not (text.contains("super._exit_tree()") or text.contains("super()")):
				offenders.append(path)
	assert_gt(screens, 5, "the scan found the overlay screens")
	assert_eq(offenders, [] as Array[String], "every OverlayScreen _exit_tree override calls super: %s" % str(offenders))


func test_world_cover_released_when_the_deck_station_leaves_the_tree() -> void:
	# The release path itself: a screen that covered the world is forgotten once it leaves the tree.
	var screen: Control = Control.new()
	add_child_autofree(screen)
	WorldCover._covering.append(screen)
	WorldCover.release(screen)
	assert_false(WorldCover.is_covering(), "release forgets the screen")


func _scripts_under(root: String) -> Array[String]:
	var result: Array[String] = []
	var dir: DirAccess = DirAccess.open(root)
	if dir == null:
		return result
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while not entry.is_empty():
		var path: String = root.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				result.append_array(_scripts_under(path))
		elif entry.ends_with(".gd"):
			result.append(path)
		entry = dir.get_next()
	dir.list_dir_end()
	return result
