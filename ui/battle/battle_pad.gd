class_name BattlePad
extends Node
## Controller support (Oct 26, docs/design/controller.md): the battle screen with a pad. A cursor moves between everything the mouse can click on the
## board - the cards in hand, the units, infrastructure, traps, resources and tokens on both sides, the two portraits, the Refuse Piles and the HUD
## buttons (Combat / End Turn, Select All Attackers, the items, the speed, the battle log, the tutorial's buttons) - by screen position: the D-pad or
## the left stick picks the nearest thing in that direction.
## - A does what a click does on the thing under the cursor (plays a card from hand, picks an attacker or a blocker, picks a target, presses a button).
## - B cancels a target choice (or closes the Refuse Pile viewer).
## - X is the primary button (Next phase / Combat / End turn, the rebindable `battle_advance`); View ends the turn at once (`battle_end_turn`).
## - Y (`battle_inspect`) shows or hides the card details; the details follow the cursor like a mouse hover (the hand card lifts too).
## A modal panel (the mulligan, the result, a Choose-X box, an ability menu, a confirm box, the pause menu) takes ordinary menu focus instead
## (`PadFocus`), and the cursor waits. The cursor ring only shows while the pad is in use; the mouse and keyboard work exactly as before.

## A panel's meta holding its cancel button (B presses it).
const META_CANCEL: StringName = &"pad_cancel_button"
const RING_COLOR: Color = Color("ffd76a")
const TARGET_RING_COLOR: Color = Color("ff5a4a")
## Seconds a held direction waits before it repeats, then the repeat interval.
const REPEAT_DELAY: float = 0.38
const REPEAT_EVERY: float = 0.13

var screen: BattleScreen
## What the cursor is on: {"kind": "card" | "portrait" | "button" | "pile", "uid": int, "player": int, "control": Control} (empty = nothing yet).
var cursor: Dictionary = {}
## Y toggles the card details; on by default.
var details: bool = true
var _layer: CanvasLayer
var _ring: Control
var _hover_view: CardView
var _held_dir: Vector2 = Vector2.ZERO
var _held_time: float = 0.0
var _last_mode: int = -1


static func install(battle: BattleScreen) -> BattlePad:
	var pad: BattlePad = BattlePad.new()
	pad.name = "BattlePad"
	pad.screen = battle
	battle.add_child(pad)
	return pad


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.name = "BattlePadLayer"
	_layer.layer = 60
	add_child(_layer)
	_ring = Control.new()
	_ring.name = "BattlePadRing"
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ring.draw.connect(_draw_ring)
	_layer.add_child(_ring)
	EventBus.input_device_changed.connect(_on_device_changed)


## True while the cursor drives the board (the pad is in use and no modal panel holds the focus).
func active() -> bool:
	if not InputDevice.using_pad() or screen == null or not screen.is_inside_tree():
		return false
	if screen.refuse_viewer != null and screen.refuse_viewer.is_open():
		return true
	return PadFocus.top_root(get_tree()) == null and not _intro_playing()


func _intro_playing() -> bool:
	return screen.boss_intro != null and is_instance_valid(screen.boss_intro) and screen.boss_intro.is_inside_tree() and not screen.boss_intro.is_done()


# ---- Stops -----------------------------------------------------------------------------------


## Everything the cursor can stand on right now, each {"kind", "uid", "player", "control", "rect"} (rect in screen pixels).
func stops() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if screen.refuse_viewer != null and screen.refuse_viewer.is_open():
		return _viewer_stops()
	var board: BattleBoard = screen.board
	for uid: Variant in board.views.keys():
		var view: CardView = board.views[uid] as CardView
		if view == null or not is_instance_valid(view) or not view.is_visible_in_tree() or view.is_queued_for_deletion():
			continue
		var zone: int = int(board.zones.get(int(uid), -1))
		var owner_index: int = int(view.get_meta("owner", 0))
		if zone == BattleBoard.Zone.HAND and owner_index != 0:
			continue  # the enemy's hand is face down: nothing to read
		if zone == BattleBoard.Zone.CENTER or zone < 0:
			continue
		result.append({"kind": "card", "uid": int(uid), "player": owner_index, "control": view, "rect": PadFocus.focus_rect(view)})
	for index: int in range(2):
		var rect: Rect2 = screen.hud.portrait_rect(index)
		var xform: Transform2D = screen.hud.get_global_transform_with_canvas()
		result.append({"kind": "portrait", "uid": Targets.player(index), "player": index, "control": null, "rect": Rect2(xform * rect.position, rect.size * xform.get_scale())})
	for widget: RefusePileWidget in screen.refuse_widgets:
		if is_instance_valid(widget) and widget.is_visible_in_tree():
			result.append({"kind": "pile", "uid": 0, "player": widget.player_index, "control": widget, "rect": PadFocus.focus_rect(widget)})
	for button: BaseButton in _buttons(screen):
		result.append({"kind": "button", "uid": 0, "player": 0, "control": button, "rect": PadFocus.focus_rect(button)})
	if screen.tutorial != null and is_instance_valid(screen.tutorial):
		for button: BaseButton in _buttons(screen.tutorial):
			result.append({"kind": "button", "uid": 0, "player": 0, "control": button, "rect": PadFocus.focus_rect(button)})
	return result


func _buttons(root: Node) -> Array[BaseButton]:
	var result: Array[BaseButton] = []
	for node: Node in root.find_children("*", "BaseButton", true, false):
		var button: BaseButton = node as BaseButton
		if button.disabled or not button.is_visible_in_tree() or button.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			continue
		if screen.refuse_viewer != null and screen.refuse_viewer.is_ancestor_of(button):
			continue
		result.append(button)
	return result


func _viewer_stops() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var viewer: RefusePileViewer = screen.refuse_viewer
	for uid: int in viewer.shown_uids():
		var view: CardView = viewer._views.get(uid) as CardView
		if view != null and view.is_visible_in_tree():
			result.append({"kind": "viewer_card", "uid": uid, "player": 0, "control": view, "rect": PadFocus.focus_rect(view)})
	for node: Node in viewer.find_children("*", "BaseButton", true, false):
		var button: BaseButton = node as BaseButton
		if not button.disabled and button.is_visible_in_tree():
			result.append({"kind": "button", "uid": 0, "player": 0, "control": button, "rect": PadFocus.focus_rect(button)})
	return result


func _same(a: Dictionary, b: Dictionary) -> bool:
	if a.is_empty() or b.is_empty() or str(a["kind"]) != str(b["kind"]):
		return false
	match str(a["kind"]):
		"card", "viewer_card":
			return int(a["uid"]) == int(b["uid"])
		"portrait", "pile":
			return int(a["player"]) == int(b["player"])
	return a["control"] == b["control"]


## The live version of the cursor's stop (its rect moves with the cards), or {} when it is gone.
func current() -> Dictionary:
	if cursor.is_empty():
		return {}
	for stop: Dictionary in stops():
		if _same(stop, cursor):
			return stop
	return {}


# ---- Moving ------------------------------------------------------------------------------------


## Moves the cursor to the nearest stop in `direction` (screen space: (1, 0) right, (0, 1) down). Returns true when it moved.
func move(direction: Vector2) -> bool:
	var all: Array[Dictionary] = stops()
	var here: Dictionary = current()
	if here.is_empty():
		_place_default(all)
		return not cursor.is_empty()
	var from: Vector2 = (here["rect"] as Rect2).get_center()
	var best: Dictionary = {}
	var best_score: float = INF
	for stop: Dictionary in all:
		if _same(stop, here):
			continue
		var offset: Vector2 = (stop["rect"] as Rect2).get_center() - from
		var along: float = offset.dot(direction)
		if along <= 8.0:
			continue
		var across: float = absf(offset.dot(Vector2(-direction.y, direction.x)))
		# Prefer things straight ahead: sideways distance counts more than distance ahead (a card row reads as one line).
		var score: float = along + across * 2.2
		if score < best_score:
			best_score = score
			best = stop
	if best.is_empty():
		return false
	_set_cursor(best)
	Audio.sfx(&"ui_tick", -10.0)
	return true


## Puts the cursor where the current decision starts: a target to pick, an attacker, a blocker, a card to toss, a playable card, else the main button.
func _place_default(all: Array[Dictionary]) -> void:
	var wanted: Callable = func(_stop: Dictionary) -> bool: return false
	match screen.mode:
		BattleScreen.Mode.TARGETING:
			wanted = func(stop: Dictionary) -> bool: return (str(stop["kind"]) in ["card", "portrait", "viewer_card"]) and screen._target_options.has(int(stop["uid"]))
		BattleScreen.Mode.ATTACK:
			wanted = func(stop: Dictionary) -> bool: return str(stop["kind"]) == "card" and PlayerState.find_in(screen.game.possible_attackers(0), int(stop["uid"])) != null
		BattleScreen.Mode.BLOCK:
			wanted = func(stop: Dictionary) -> bool: return str(stop["kind"]) == "card" and int(stop["player"]) == 0 and int(screen.board.zones.get(int(stop["uid"]), -1)) == BattleBoard.Zone.FIELD
		BattleScreen.Mode.TOSS:
			wanted = func(stop: Dictionary) -> bool: return str(stop["kind"]) == "card" and int(stop["player"]) == 0 and int(screen.board.zones.get(int(stop["uid"]), -1)) == BattleBoard.Zone.HAND
		BattleScreen.Mode.MAIN:
			wanted = func(stop: Dictionary) -> bool:
				if str(stop["kind"]) != "card" or int(stop["player"]) != 0 or int(screen.board.zones.get(int(stop["uid"]), -1)) != BattleBoard.Zone.HAND:
					return false
				var card: CardInstance = screen.game.players[0].find_hand(int(stop["uid"]))
				return card != null and screen._is_playable(card)
	var picks: Array[Dictionary] = []
	for stop: Dictionary in all:
		if bool(wanted.call(stop)):
			picks.append(stop)
	if picks.is_empty() and screen.refuse_viewer != null and screen.refuse_viewer.is_open():
		picks = all
	if picks.is_empty():
		for stop: Dictionary in all:
			if str(stop["kind"]) == "button" and stop["control"] == screen.hud.primary_button:
				picks.append(stop)
	if picks.is_empty():
		for stop: Dictionary in all:
			if str(stop["kind"]) == "card" and int(stop["player"]) == 0:
				picks.append(stop)
	if picks.is_empty():
		_set_cursor({})
		return
	picks.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["rect"] as Rect2).position.x < (b["rect"] as Rect2).position.x)
	_set_cursor(picks[0])


## Places the cursor afresh for the current decision (called when the battle enters a new mode).
func reset() -> void:
	if not active():
		_hover(null)
		cursor = {}
		return
	_place_default(stops())


func _set_cursor(stop: Dictionary) -> void:
	cursor = stop.duplicate()
	cursor.erase("rect")
	var view: CardView = null
	if str(stop.get("kind", "")) in ["card", "viewer_card"]:
		view = stop["control"] as CardView
	_hover(view)


func _hover(view: CardView) -> void:
	if _hover_view == view:
		return
	if _hover_view != null and is_instance_valid(_hover_view):
		if screen.refuse_viewer != null and screen.refuse_viewer.is_open():
			screen.hud.hide_preview()
		else:
			screen.board._on_unhover(_hover_view)
	_hover_view = view
	if view == null:
		return
	if screen.refuse_viewer != null and screen.refuse_viewer.is_open():
		screen.refuse_viewer._on_card_hovered(view)
	else:
		screen.board._on_hover(view)
	if not details:
		screen.hud.hide_preview()


## The cursor's centre in screen pixels while it stands on a target choice (the targeting arrow aims there), else null.
func aim_point() -> Variant:
	if not active() or screen.mode != BattleScreen.Mode.TARGETING:
		return null
	var here: Dictionary = current()
	if here.is_empty():
		return null
	return (here["rect"] as Rect2).get_center()


# ---- Acting -------------------------------------------------------------------------------------


## A: what a click does on the cursor's stop.
func activate() -> void:
	var here: Dictionary = current()
	if here.is_empty():
		_place_default(stops())
		return
	match str(here["kind"]):
		"card":
			screen.pad_click_card(here["control"] as CardView)
		"viewer_card":
			screen.refuse_viewer.choose(int(here["uid"]))
		"portrait":
			if screen.mode == BattleScreen.Mode.TARGETING and screen._target_options.has(int(here["uid"])) and not screen.busy:
				screen._finish_targeting(int(here["uid"]))
		"pile":
			screen._on_pile_pressed(int(here["player"]))
		"button":
			var button: BaseButton = here["control"] as BaseButton
			if button != null and not button.disabled:
				if button.toggle_mode:
					button.button_pressed = not button.button_pressed
				button.pressed.emit()


## B: backs out of a target choice or the Refuse Pile viewer.
func back() -> void:
	if screen.refuse_viewer != null and screen.refuse_viewer.is_open():
		screen.refuse_viewer.close()
		reset()
		return
	if screen.mode == BattleScreen.Mode.TARGETING:
		screen._cancel_targeting()


## Y: the card details on or off.
func toggle_details() -> void:
	details = not details
	Audio.sfx(&"ui_tick")
	if not details:
		screen.hud.hide_preview()
	elif _hover_view != null and is_instance_valid(_hover_view):
		screen._on_card_hovered(_hover_view)


func _input(event: InputEvent) -> void:
	if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return
	InputDevice.note(event)
	if not active():
		return
	if not UiInput.is_fresh_press(event):
		return
	var direction: Vector2 = _direction_of(event)
	if direction != Vector2.ZERO:
		get_viewport().set_input_as_handled()
		move(direction)
		_held_dir = direction
		_held_time = 0.0
		return
	if event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()
		activate()
	elif event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		back()
	elif event.is_action_pressed(&"battle_inspect"):
		get_viewport().set_input_as_handled()
		toggle_details()


static func _direction_of(event: InputEvent) -> Vector2:
	if event.is_action_pressed(&"ui_left"):
		return Vector2.LEFT
	if event.is_action_pressed(&"ui_right"):
		return Vector2.RIGHT
	if event.is_action_pressed(&"ui_up"):
		return Vector2.UP
	if event.is_action_pressed(&"ui_down"):
		return Vector2.DOWN
	return Vector2.ZERO


func _process(delta: float) -> void:
	if screen == null:
		return
	if int(screen.mode) != _last_mode:
		_last_mode = int(screen.mode)
		if InputDevice.using_pad():
			reset.call_deferred()
	var on: bool = active()
	if on and current().is_empty() and screen.mode != BattleScreen.Mode.WAITING:
		_place_default(stops())
	# A held direction repeats (walking along a long hand).
	if on and _held_dir != Vector2.ZERO:
		var still: bool = Input.is_action_pressed(&"ui_left") if _held_dir == Vector2.LEFT else (Input.is_action_pressed(&"ui_right") if _held_dir == Vector2.RIGHT else (Input.is_action_pressed(&"ui_up") if _held_dir == Vector2.UP else Input.is_action_pressed(&"ui_down")))
		if not still:
			_held_dir = Vector2.ZERO
		else:
			_held_time += delta
			if _held_time >= REPEAT_DELAY:
				_held_time -= REPEAT_EVERY
				move(_held_dir)
	_ring.queue_redraw()


func _draw_ring() -> void:
	if not active():
		return
	var here: Dictionary = current()
	if here.is_empty():
		return
	var rect: Rect2 = (here["rect"] as Rect2).grow(6.0)
	var pulse: float = 0.75 + 0.25 * sin(float(Time.get_ticks_msec()) / 170.0)
	var targeting: bool = screen.mode == BattleScreen.Mode.TARGETING and screen._target_options.has(int(here.get("uid", 0)))
	var color: Color = TARGET_RING_COLOR if targeting else RING_COLOR
	color.a = pulse
	_ring.draw_rect(rect.grow(2.0), Color(0, 0, 0, 0.5 * pulse), false, 7.0)
	_ring.draw_rect(rect, color, false, 4.0)
	# A small drawn A below the stop says what pressing does.
	var tag: Vector2 = Vector2(rect.get_center().x, rect.end.y + 16.0)
	_ring.draw_circle(tag, 13.0, Color(0, 0, 0, 0.6 * pulse))
	_ring.draw_arc(tag, 13.0, 0.0, TAU, 24, color, 2.0, true)


func _on_device_changed(using_pad: bool) -> void:
	if not is_inside_tree() or screen == null:
		return
	if using_pad:
		reset()
	else:
		_hover(null)
		cursor = {}
	if not screen.busy and screen.mode != BattleScreen.Mode.WAITING and screen.mode != BattleScreen.Mode.OVER:
		screen._refresh_ui()
