class_name TutorialLayer
extends CanvasLayer
## Guided prompts for the first battle. A coach bubble points at the thing to click with a
## pulsing highlight, and moves on by itself when the player does it. Skippable at any time.
## It only watches the battle screen (mode, game state, events); it never touches the rules.

const STEPS: Array[Dictionary] = [
	{
		"id": "intro", "title": "Your first duel",
		"text": "Reduce your opponent's HP to 0 before they do the same to you. Each side starts with 5 cards. You may keep this hand, or take one free mulligan for a fresh 5.",
		"info": true,
	},
	{
		"id": "infrastructure", "title": "Play an infrastructure",
		"text": "Infrastructure make the energy you spend on spells. [b]Click an infrastructure[/b] (or drag it onto the table). You can play [b]one infrastructure per turn[/b].",
	},
	{
		"id": "cast", "title": "Play a card",
		"text": "Cards [color=#ffd76a]glow gold[/color] when you can pay for them. Click one to play it. Units stay on the field; spells act once and are spent. Some spells ask you to choose a target.",
	},
	{
		"id": "keywords", "title": "Keywords",
		"text": "Words like [b]Flying[/b] or [b]Hustle[/b] change how a unit fights. [b]Hover any card[/b] to see it zoomed, with every keyword explained underneath.",
		"info": true,
	},
	{
		"id": "trap", "title": "Traps",
		"text": "A [b]Trap[/b] is play face-down. It springs by itself when the opponent does what it watches for, such as attacking. The opponent cannot see what it is.",
	},
	{
		"id": "end_turn", "title": "Ending your turn",
		"text": "Nothing left to do? [b]To Combat[/b] moves on to attacking, and [b]End Turn[/b] passes the turn. Your infrastructure ready and you draw a card next turn.",
		"info": true,
	},
	{
		"id": "attack", "title": "Attack!",
		"text": "[b]Click your units[/b] to send them at the opponent, then press [b]Attack[/b]. Attackers activate (they cannot block next turn) and units that just arrived cannot attack yet.",
	},
	{
		"id": "block", "title": "Block!",
		"text": "The opponent is attacking. [b]Click one of your units, then the attacker[/b] it should block. Unblocked attackers hit you. Then press [b]Confirm Blocks[/b].",
	},
]

var screen: BattleScreen
var _host: Control
var _overlay: Overlay
var _bubble: PanelContainer
var _title: Label
var _text: RichTextLabel
var _got_it: FancyButton
var _done: Dictionary = {}
var _current: String = ""
var _flags: Dictionary = {}
var _time: float = 0.0
var _skipped: bool = false


func setup(battle: BattleScreen) -> void:
	screen = battle
	layer = 30
	_host = UIKit.layer_host(self)
	_overlay = Overlay.new()
	_overlay.size = Vector2(1920, 1080)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_host.add_child(_overlay)
	_bubble = UIKit.panel()
	_bubble.custom_minimum_size = Vector2(520, 0)
	_bubble.size = Vector2(520, 10)
	_bubble.visible = false
	_bubble.z_index = 5
	_host.add_child(_bubble)
	var column: VBoxContainer = UIKit.vbox(8)
	_bubble.add_child(column)
	_title = UIKit.label("", &"HeadingLabel", 28)
	column.add_child(_title)
	_text = UIKit.rich("", 22)
	_text.custom_minimum_size = Vector2(480, 0)
	column.add_child(_text)
	var row: HBoxContainer = UIKit.hbox(10)
	column.add_child(row)
	_got_it = FancyButton.make("Got it", &"PrimaryButton", Vector2(150, 46))
	_got_it.pressed.connect(_on_got_it)
	row.add_child(_got_it)
	row.add_child(UIKit.filler())
	var skip: FancyButton = FancyButton.make("Skip tutorial", &"GhostButton", Vector2(190, 46))
	skip.add_theme_font_size_override("font_size", 20)
	skip.pressed.connect(skip_tutorial)
	row.add_child(skip)


func skip_tutorial() -> void:
	_skipped = true
	Session.set_flag(&"tutorial_done")
	_hide()
	set_process(false)


func _hide() -> void:
	_bubble.visible = false
	_overlay.target = Rect2()
	_overlay.queue_redraw()
	_current = ""


func on_battle_event(event: GameEvent) -> void:
	match event.type:
		GameEvent.Type.INFRASTRUCTURE_PLAYED:
			if event.player == 0:
				_flags["infrastructure_played"] = true
		GameEvent.Type.CARD_PLAYED:
			if event.player == 0:
				_flags["cast"] = true
		GameEvent.Type.TRAP_SET:
			if event.player == 0:
				_flags["trap_set"] = true
		GameEvent.Type.ATTACKERS_DECLARED:
			if event.player == 0:
				_flags["attacked"] = true
		GameEvent.Type.BLOCKER_ASSIGNED:
			_flags["blocked"] = true
		GameEvent.Type.GAME_OVER:
			Session.set_flag(&"tutorial_done")


func on_mode_changed(_mode: int) -> void:
	pass


func on_attackers_changed(_count: int) -> void:
	pass


func _on_got_it() -> void:
	if _current != "":
		_done[_current] = true
		_hide()


# ---- Step logic -------------------------------------------------------------------------


func _process(delta: float) -> void:
	if _skipped or screen == null:
		return
	_time += delta
	if _current == "":
		for step: Dictionary in STEPS:
			var id: String = str(step["id"])
			if not _done.has(id) and _triggered(id):
				_show(step)
				break
	else:
		if _finished(_current) or not _still_relevant(_current):
			_done[_current] = true
			_hide()
			return
		_place()
	_overlay.pulse = 0.5 + 0.5 * sin(_time * 5.0)
	_overlay.queue_redraw()


func _show(step: Dictionary) -> void:
	_current = str(step["id"])
	_title.text = str(step["title"])
	_text.text = str(step["text"])
	_got_it.visible = bool(step.get("info", false))
	_bubble.visible = true
	_bubble.reset_size()
	_bubble.size = Vector2(520, _bubble.size.y)
	Audio.sfx(&"ui_open", -8.0)
	UIKit.pop_in(_bubble)


func _mode() -> BattleScreen.Mode:
	return screen.mode


func _hand_cards() -> Array[CardInstance]:
	return screen.game.players[0].hand


func _castable() -> Array[int]:
	var result: Array[int] = []
	for card: CardInstance in _hand_cards():
		if not card.data.is_infrastructure() and screen.game.can_play_card(0, card.uid):
			result.append(card.uid)
	return result


func _playable_infrastructure() -> Array[int]:
	var result: Array[int] = []
	for card: CardInstance in _hand_cards():
		if card.data.is_infrastructure() and screen.game.can_play_infrastructure(0, card.uid):
			result.append(card.uid)
	return result


func _keyword_cards() -> Array[int]:
	var result: Array[int] = []
	for card: CardInstance in _hand_cards():
		if not card.data.keywords.is_empty():
			result.append(card.uid)
	return result


func _trap_cards() -> Array[int]:
	var result: Array[int] = []
	for card: CardInstance in _hand_cards():
		if card.data.type == CardEnums.CardType.TRAP and screen.game.can_play_card(0, card.uid):
			result.append(card.uid)
	return result


func _triggered(id: String) -> bool:
	if screen.busy:
		return false
	var mode: BattleScreen.Mode = _mode()
	match id:
		"intro":
			return mode == BattleScreen.Mode.MULLIGAN
		"infrastructure":
			return mode == BattleScreen.Mode.MAIN and not _playable_infrastructure().is_empty()
		"cast":
			return mode == BattleScreen.Mode.MAIN and bool(_flags.get("infrastructure_played", false)) and not _castable().is_empty()
		"keywords":
			return mode == BattleScreen.Mode.MAIN and _done.has("cast") and not _keyword_cards().is_empty()
		"trap":
			return mode == BattleScreen.Mode.MAIN and _done.has("cast") and not _trap_cards().is_empty()
		"end_turn":
			return mode == BattleScreen.Mode.MAIN and bool(_flags.get("infrastructure_played", false)) and _castable().is_empty() and _playable_infrastructure().is_empty()
		"attack":
			return mode == BattleScreen.Mode.ATTACK and not screen.game.possible_attackers(0).is_empty()
		"block":
			return mode == BattleScreen.Mode.BLOCK
	return false


func _finished(id: String) -> bool:
	match id:
		"infrastructure":
			return bool(_flags.get("infrastructure_played", false))
		"cast":
			return bool(_flags.get("cast", false))
		"trap":
			return bool(_flags.get("trap_set", false))
		"attack":
			return bool(_flags.get("attacked", false))
		"block":
			return bool(_flags.get("blocked", false))
	return false


## A step goes away when the moment it explains has passed.
func _still_relevant(id: String) -> bool:
	var mode: BattleScreen.Mode = _mode()
	match id:
		"intro":
			return mode == BattleScreen.Mode.MULLIGAN
		"infrastructure", "cast", "keywords", "trap", "end_turn":
			return mode == BattleScreen.Mode.MAIN or mode == BattleScreen.Mode.TARGETING
		"attack":
			return mode == BattleScreen.Mode.ATTACK
		"block":
			return mode == BattleScreen.Mode.BLOCK
	return true


# ---- Placement --------------------------------------------------------------------------


func _target_rect(id: String) -> Rect2:
	match id:
		"intro":
			return Rect2(700, 380, 540, 180)
		"infrastructure":
			return _union(_playable_infrastructure())
		"cast":
			return _union(_castable())
		"keywords":
			return _union(_keyword_cards())
		"trap":
			return _union(_trap_cards())
		"end_turn":
			return screen.hud.primary_button.get_global_rect()
		"attack":
			var uids: Array[int] = []
			for card: CardInstance in screen.game.possible_attackers(0):
				uids.append(card.uid)
			return _union(uids)
		"block":
			return _union(screen.game.attackers)
	return Rect2()


func _union(uids: Array[int]) -> Rect2:
	var result: Rect2 = Rect2()
	var first: bool = true
	for uid: int in uids:
		var view: CardView = screen.board.view_for(uid)
		if view == null:
			continue
		var transform: Transform2D = view.get_global_transform()
		var corners: Array[Vector2] = [
			transform * Vector2.ZERO, transform * Vector2(CardView.SIZE.x, 0.0),
			transform * CardView.SIZE, transform * Vector2(0.0, CardView.SIZE.y),
		]
		var rect: Rect2 = Rect2(corners[0], Vector2.ZERO)
		for corner: Vector2 in corners:
			rect = rect.expand(corner)
		result = rect if first else result.merge(rect)
		first = false
	return result


func _place() -> void:
	var target: Rect2 = _target_rect(_current)
	_overlay.target = target
	var size: Vector2 = _bubble.size
	var x: float = 0.0
	var y: float = 0.0
	if target.size == Vector2.ZERO:
		x = (1920.0 - size.x) * 0.5
		y = 300.0
		_overlay.arrow_from = Vector2.ZERO
	else:
		x = clampf(target.get_center().x - size.x * 0.5, 20.0, 1900.0 - size.x)
		var above: float = target.position.y - size.y - 40.0
		if above >= 130.0 and _current not in ["end_turn", "intro"]:
			y = above
			_overlay.arrow_from = Vector2(clampf(target.get_center().x, x + 30.0, x + size.x - 30.0), y + size.y)
		elif _current == "end_turn":
			x = target.position.x - size.x - 30.0
			y = target.get_center().y - size.y * 0.5
			_overlay.arrow_from = Vector2(x + size.x, target.get_center().y)
		else:
			y = minf(target.end.y + 40.0, 1060.0 - size.y)
			_overlay.arrow_from = Vector2(clampf(target.get_center().x, x + 30.0, x + size.x - 30.0), y)
	_bubble.position = _bubble.position.lerp(Vector2(x, y), 0.35)


class Overlay:
	extends Control
	var target: Rect2 = Rect2()
	var arrow_from: Vector2 = Vector2.ZERO
	var pulse: float = 0.0

	func _draw() -> void:
		if target.size == Vector2.ZERO:
			return
		var ring: Rect2 = target.grow(8.0 + pulse * 5.0)
		draw_rect(ring, Color(1.0, 0.85, 0.35, 0.16 + pulse * 0.12), true)
		draw_rect(ring, Color(1.0, 0.85, 0.35, 0.95), false, 4.0)
		if arrow_from != Vector2.ZERO:
			var tip: Vector2 = target.get_center()
			var direction: Vector2 = (tip - arrow_from).normalized()
			var end: Vector2 = target.get_center() - direction * minf(target.size.length() * 0.3, 90.0)
			end = _clip_to_ring(arrow_from, end, ring)
			draw_line(arrow_from, end, Color(1.0, 0.85, 0.35, 0.95), 5.0, true)
			var side: Vector2 = Vector2(-direction.y, direction.x)
			draw_colored_polygon(PackedVector2Array([end + direction * 6.0, end - direction * 16.0 + side * 12.0, end - direction * 16.0 - side * 12.0]), Color(1.0, 0.85, 0.35, 0.95))

	func _clip_to_ring(from: Vector2, to: Vector2, ring: Rect2) -> Vector2:
		var point: Vector2 = to
		var steps: int = 30
		for step: int in range(steps + 1):
			var candidate: Vector2 = to.lerp(from, float(step) / float(steps))
			point = candidate
			if not ring.has_point(candidate):
				break
		return point
