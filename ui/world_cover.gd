class_name WorldCover
extends RefCounted
## Performance pass Oct 25, Part 3 (docs/perf/perf_state.md): a full-screen menu (OverlayScreen) covers the 3D world with a painting or a
## 94% shade, yet the town kept rendering underneath - 700-1340 draw calls and 12-18 ms of GPU per frame for a picture nobody could see.
## While a screen is open the last world frame is kept as a still picture under the screen's own backdrop and the window's 3D rendering is
## switched off (`Viewport.disable_3d`); the 2D HUD under it and the screen itself draw as before. What shows through the shade is the
## same frame, standing still - the world's motion behind a 94% shade is not visible. Closing the last screen switches 3D back on.
##
## `WORLD_COVER=off` (environment) leaves the 3D world rendering (A/B runs).

## The still picture: taken from the frame before the first screen drew, reused by a screen that replaces another within a few frames.
static var _snapshot: ImageTexture
static var _covering: Array[Control] = []
static var _released_frame: int = -100
static var enabled: bool = OS.get_environment("WORLD_COVER") != "off"


## Called from a screen's `_ready` (before it has drawn): remembers the world picture. The 3D switch-off waits for `cover_now`, once the
## screen's opening fade has finished (while it fades in, the live world shows through it).
static func prepare(screen: Control) -> void:
	if not enabled or not _has_3d(screen):
		return
	var viewport: Viewport = screen.get_viewport()
	if _snapshot == null or (_covering.is_empty() and Engine.get_frames_drawn() - _released_frame > 2):
		# No screen covered the world in the last frames: the last frame shows the world (and the HUD), not a menu.
		var image: Image = viewport.get_texture().get_image()
		if image == null or image.is_empty():
			return
		_snapshot = ImageTexture.create_from_image(image)
	var picture: TextureRect = TextureRect.new()
	picture.name = "WorldCoverStill"
	picture.texture = _snapshot
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_SCALE
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.set_anchors_preset(Control.PRESET_FULL_RECT)
	picture.visible = false
	screen.add_child(picture)
	screen.move_child(picture, 0)
	screen.set_meta(&"world_cover_still", picture)


## The screen is fully opaque now: show the still and stop drawing the 3D world.
static func cover_now(screen: Control) -> void:
	if not is_instance_valid(screen) or not screen.is_inside_tree() or not screen.has_meta(&"world_cover_still"):
		return
	var picture: TextureRect = screen.get_meta(&"world_cover_still") as TextureRect
	if not is_instance_valid(picture):
		return
	picture.visible = true
	if not _covering.has(screen):
		_covering.append(screen)
	screen.get_viewport().disable_3d = true


## The screen is closing (`_exit_tree`): 3D comes back when no other screen still covers the world.
static func release(screen: Control) -> void:
	if not _covering.has(screen):
		return
	_covering.erase(screen)
	var alive: Array[Control] = []
	for other: Control in _covering:
		if is_instance_valid(other) and other.is_inside_tree():
			alive.append(other)
	_covering = alive
	if _covering.is_empty():
		var viewport: Viewport = screen.get_viewport()
		if viewport != null:
			viewport.disable_3d = false
		_released_frame = Engine.get_frames_drawn()


static func is_covering() -> bool:
	return not _covering.is_empty()


## Only a window that draws a 3D world (a town, a zone, the forest) has anything to save; the battle and the map are 2D.
static func _has_3d(screen: Control) -> bool:
	var viewport: Viewport = screen.get_viewport()
	return viewport != null and viewport == screen.get_tree().root and viewport.get_camera_3d() != null
