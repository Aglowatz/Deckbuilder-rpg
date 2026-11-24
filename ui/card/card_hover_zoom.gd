class_name CardHoverZoom
extends RefCounted
## Nov 18 day (Part 3): a card shown small (a pack's summary row, a reward pick) grows smoothly to about the size of the battle's hover
## preview (`TARGET_HEIGHT` canvas px tall, the preview card is 300 x 450) while the mouse is on it or the controller's focus is on it, stays
## inside the screen, and shrinks back when the mouse or focus leaves. Works from the card's on-screen size, so it holds at any resolution,
## text size and UI scale. Under Reduce motion it snaps instead of tweening.
##
## `target` is the Control that grows (a holder or the card itself); `source` is the Control whose mouse / focus signals drive it (defaults
## to `target`); `enabled` (optional) is asked before each zoom - false while the screen is still animating the card.

const TARGET_HEIGHT: float = 450.0
const MAX_FACTOR: float = 2.4
const MARGIN: float = 10.0
const DURATION: float = 0.14
const ZOOM_Z: int = 120


static func attach(target: Control, source: Control = null, enabled: Callable = Callable()) -> void:
	if target == null or target.has_meta(&"hover_zoom"):
		return
	var driver: Control = source if source != null else target
	target.set_meta(&"hover_zoom", true)
	var grow: Callable = func() -> void: zoom_in(target, enabled)
	var shrink: Callable = func() -> void: zoom_out(target)
	driver.mouse_entered.connect(grow)
	driver.mouse_exited.connect(shrink)
	driver.focus_entered.connect(grow)
	driver.focus_exited.connect(shrink)


## True while `target` is grown.
static func is_zoomed(target: Control) -> bool:
	return target != null and target.has_meta(&"zoom_base_scale")


## How much `target` grows from its current on-screen height (1.0 = already big enough).
static func factor_for(target: Control) -> float:
	var height: float = target.get_global_rect().size.y
	if height <= 1.0:
		return 1.0
	# Fable big pass Nov 23: a screen that shows its cards large already (the draft pick) asks for a bigger zoom (`set_height`)
	return clampf(float(target.get_meta(&"zoom_height", TARGET_HEIGHT)) / height, 1.0, MAX_FACTOR)


## The on-screen height (canvas px) `target` grows to instead of `TARGET_HEIGHT`.
static func set_height(target: Control, height: float) -> void:
	if target != null:
		target.set_meta(&"zoom_height", height)


static func zoom_in(target: Control, enabled: Callable = Callable()) -> void:
	if target == null or not is_instance_valid(target) or not target.is_inside_tree() or is_zoomed(target):
		return
	if enabled.is_valid() and not bool(enabled.call()):
		return
	var factor: float = factor_for(target)
	if factor <= 1.01:
		return
	var base_scale: Vector2 = target.scale
	var base_position: Vector2 = target.position
	target.set_meta(&"zoom_base_scale", base_scale)
	target.set_meta(&"zoom_base_position", base_position)
	target.set_meta(&"zoom_base_z", target.z_index)
	var new_scale: Vector2 = base_scale * factor
	target.z_index = ZOOM_Z
	if target.get_parent() is Container:
		# In a container the position belongs to the container (a hover can re-lay the row out mid-tween): grow about a pivot instead,
		# picked so the grown card keeps inside the screen. At scale 1 the pivot moves nothing, so it can stay set after the zoom.
		var middle: Vector2 = target.size * 0.5
		target.set_meta(&"zoom_base_pivot", target.pivot_offset)
		if base_scale.is_equal_approx(Vector2.ONE):
			var centred: Vector2 = target.position + middle - middle * new_scale
			var shift: Vector2 = _keep_on_screen_at(target, centred, new_scale)
			# Fable Nov 24: a card that is itself on the screen never needs to move further than it grows on one side. A larger
			# shift means the screen was still sliding in or not laid out yet when the pointer met the card (the pick of three
			# after a Halls fight threw its first card 2,000 px off the page that way): grow it where it stands instead.
			var most: Vector2 = target.size * (new_scale - Vector2.ONE) * 0.5 + Vector2(MARGIN, MARGIN)
			shift = Vector2(clampf(shift.x, -most.x, most.x), clampf(shift.y, -most.y, most.y))
			target.pivot_offset = middle + Vector2(shift.x / (1.0 - new_scale.x), shift.y / (1.0 - new_scale.y))
		_tween(target, new_scale, Vector2.INF)
		return
	# Keep the card's centre, then nudge it back inside the screen.
	var centre: Vector2 = _visual_centre(target, base_position, base_scale)
	var new_position: Vector2 = centre - target.pivot_offset - (target.size * 0.5 - target.pivot_offset) * new_scale
	new_position += _keep_on_screen(target, new_position, new_scale)
	_tween(target, new_scale, new_position)


static func zoom_out(target: Control) -> void:
	if target == null or not is_instance_valid(target) or not is_zoomed(target):
		return
	var base_scale: Vector2 = target.get_meta(&"zoom_base_scale") as Vector2
	var base_position: Vector2 = target.get_meta(&"zoom_base_position") as Vector2
	target.z_index = int(target.get_meta(&"zoom_base_z", 0))
	target.remove_meta(&"zoom_base_scale")
	target.remove_meta(&"zoom_base_position")
	target.remove_meta(&"zoom_base_z")
	if target.has_meta(&"zoom_base_pivot"):
		target.remove_meta(&"zoom_base_pivot")
		_tween(target, base_scale, Vector2.INF)
		return
	_tween(target, base_scale, base_position)


## The centre of `target` in its parent's coordinates for a position and scale (no rotation).
static func _visual_centre(target: Control, position: Vector2, scale: Vector2) -> Vector2:
	return position + target.pivot_offset + (target.size * 0.5 - target.pivot_offset) * scale


## The shift (parent coordinates) that keeps the grown rect inside the visible screen with a small margin.
static func _keep_on_screen(target: Control, position: Vector2, scale: Vector2) -> Vector2:
	return _keep_on_screen_at(target, position + target.pivot_offset - target.pivot_offset * scale, scale)


## The same for a grown rect whose top-left corner (parent coordinates) is `top_left`.
static func _keep_on_screen_at(target: Control, top_left: Vector2, scale: Vector2) -> Vector2:
	var parent: CanvasItem = target.get_parent() as CanvasItem
	var to_canvas: Transform2D = parent.get_global_transform() if parent != null else Transform2D.IDENTITY
	var rect: Rect2 = Rect2(to_canvas * top_left, (to_canvas.basis_xform(target.size * scale)))
	var screen: Rect2 = target.get_viewport_rect().grow(-MARGIN)
	var shift: Vector2 = Vector2.ZERO
	if rect.size.x <= screen.size.x:
		if rect.position.x < screen.position.x:
			shift.x = screen.position.x - rect.position.x
		elif rect.end.x > screen.end.x:
			shift.x = screen.end.x - rect.end.x
	if rect.size.y <= screen.size.y:
		if rect.position.y < screen.position.y:
			shift.y = screen.position.y - rect.position.y
		elif rect.end.y > screen.end.y:
			shift.y = screen.end.y - rect.end.y
	var parent_scale: Vector2 = to_canvas.get_scale()
	return Vector2(shift.x / maxf(parent_scale.x, 0.001), shift.y / maxf(parent_scale.y, 0.001))


static func _tween(target: Control, scale: Vector2, position: Vector2) -> void:
	var previous: Variant = target.get_meta(&"zoom_tween") if target.has_meta(&"zoom_tween") else null
	if previous is Tween and (previous as Tween).is_valid():
		(previous as Tween).kill()
	var move: bool = position != Vector2.INF  # Vector2.INF: a container owns the position; only the scale changes
	if Settings.reduce_motion:
		target.scale = scale
		if move:
			target.position = position
		return
	var tween: Tween = target.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "scale", scale, DURATION)
	if move:
		tween.tween_property(target, "position", position, DURATION)
	target.set_meta(&"zoom_tween", tween)


## Fable Nov 21 (Part 5.6): the same zoom for a card that IGNORES the mouse (a static card inside a button, a reward box or a minigame,
## where clicks must reach whatever it sits on). A small watcher under the card looks at the pointer each frame: over the card's own
## rect (its size before it grew) the card grows; on the controller it grows while the focus is on the card or on the button that holds
## it. One card at a time; nothing while the left mouse button is held (a drag) or while another screen lies on top.
static func watch(target: Control, enabled: Callable = Callable()) -> void:
	if target == null or target.has_meta(&"hover_zoom"):
		return
	target.set_meta(&"hover_zoom", true)
	var watcher: Watcher = Watcher.new()
	watcher.name = "HoverZoomWatcher"
	watcher.target = target
	watcher.enabled = enabled
	target.add_child(watcher)


## True when `target` has either kind of hover zoom.
static func has_zoom(target: Control) -> bool:
	return target != null and target.has_meta(&"hover_zoom")


class Watcher:
	extends Node
	## The card that is grown by a watcher now (one at a time).
	static var active: Control = null
	## Tests: a canvas point used instead of the mouse (null = the real pointer).
	static var test_mouse: Variant = null

	var target: Control
	var enabled: Callable
	var _base: Rect2

	func _process(_delta: float) -> void:
		if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
			_leave()
			return
		var zoomed: bool = CardHoverZoom.is_zoomed(target)
		if not zoomed:
			_base = target.get_global_rect()
		var want: bool = false
		if InputDevice.using_pad() and test_mouse == null:
			var focus: Control = target.get_viewport().gui_get_focus_owner()
			want = focus != null and (focus == target or (focus is BaseButton and focus.is_ancestor_of(target)))
		else:
			var pointer: Vector2 = test_mouse as Vector2 if test_mouse != null else target.get_global_mouse_position()
			want = _base.has_point(pointer) and (test_mouse != null or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))
		if want:
			var top: Control = PadFocus.top_root(get_tree())
			if top != null and top != target and not top.is_ancestor_of(target):
				want = false
		if want and (active == null or active == target or not is_instance_valid(active) or not CardHoverZoom.is_zoomed(active)):
			active = target
			CardHoverZoom.zoom_in(target, enabled)
		elif not want:
			_leave()

	func _leave() -> void:
		if active == target:
			active = null
		if target != null and is_instance_valid(target) and CardHoverZoom.is_zoomed(target):
			CardHoverZoom.zoom_out(target)

	func _exit_tree() -> void:
		if active == target:
			active = null
