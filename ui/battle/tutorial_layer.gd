class_name TutorialLayer
extends CanvasLayer
## Guided prompts for a new player's first battles. A short coach bubble points at the thing it talks about with a pulsing
## highlight, never on top of it, and moves on by itself when the player does it. Battle feel, Part D: one thing at a time,
## each prompt once ever (a `tut_<id>` flag), and the later topics (traps, Tools, the Refuse Pile) wait until they first come
## up, in whichever battle that is. "Skip tips" turns all of them off. It only watches the battle screen; it never touches the rules.

const STEPS: Array[Dictionary] = [
	{"id": "intro", "title": "Your first duel", "info": true,
		"text": "Bring the enemy's HP to 0 before they do it to you. Keep this hand, or take one free mulligan. No pressure. (Some pressure.)"},
	{"id": "infrastructure", "title": "Play an Infrastructure",
		"text": "[b]Click the glowing Infrastructure.[/b] It gives you energy. One per turn. The most important card of the day."},
	{"id": "energy", "title": "Energy", "info": true,
		"text": "Each Infrastructure is an [b]energy orb[/b] on your plate. Cards cost energy, and the orbs refill every turn."},
	{"id": "unit", "title": "Play a unit",
		"text": "Cards [color=#ffd76a]glow gold[/color] when you can pay for them. [b]Click a unit[/b] to put it on the field."},
	{"id": "resource_made", "title": "You made a Resource!", "info": true,
		"text": "That Infrastructure also made [b]1 {resource}[/b], your Path's Resource. Resources pile up on your tray and stay until you spend them. Hoarding is encouraged."},
	{"id": "resource_use", "title": "Spend your {resource}",
		"text": "[b]Click your glowing {resource}[/b], then a unit: {effect}. It costs 1 energy. Do it now; the duel waits for you."},
	{"id": "resource_spend", "title": "Spend your {resource}",
		"text": "This card [b]spends {resource}[/b]. {resource} does nothing alone; your Path's cards turn it into something. [b]Use it now.[/b]"},
	{"id": "resource_why", "title": "Make it, spend it", "info": true,
		"text": "That is the loop: [b]make[/b] Resources (basic Infrastructure, some cards), then [b]spend[/b] them for an edge. Iron pumps, Red Tape shrinks, Ingredients cook, Garbage gets eaten. Your deck is built around yours."},
	{"id": "end_turn", "title": "Nothing left to play", "info": true,
		"text": "[b]To Combat[/b] goes to attacking; [b]End Turn[/b] passes. You draw a card next turn. Patience is a strategy too."},
	{"id": "attack", "title": "Attack!",
		"text": "[b]Click your units[/b], then [b]Attack[/b]. The numbers show what each hit will do. New units wait a turn. They are still tying their shoes."},
	{"id": "block", "title": "Block!",
		"text": "[b]Click your unit, then the attacker[/b] it blocks. Unblocked attackers hit you. Then [b]Confirm Blocks[/b]."},
	{"id": "trap", "title": "Traps",
		"text": "A [b]Trap[/b] is set face-down and springs by itself on the enemy's turn. Click it to set it."},
	{"id": "enemy_trap", "title": "A trap!", "info": true,
		"text": "The enemy had a trap set. Their face-down traps sit fanned beside their row: count the card backs to see how many are left."},
	{"id": "tool", "title": "Tools",
		"text": "A [b]Tool[/b] stays on the table. Use its ability to attach it to one of your units."},
	{"id": "refuse", "title": "The Refuse Pile", "info": true,
		"text": "Spent spells and destroyed units go to the [b]Refuse Pile[/b]. Click it to look inside. It is less gross than it sounds."},
	{"id": "keywords", "title": "Keywords", "info": true,
		"text": "Words like [b]Flying[/b] change how a unit fights. Hover one on a card to see what it does. Flying units: rude, but effective."},
	# Overnight Oct 23, Part 5: four more first-time topics, each shown the first time it comes up.
	{"id": "enemy_traps_set", "title": "Face-down cards", "info": true,
		"text": "Those [b]card backs[/b] beside the enemy's row are [b]traps[/b]. You can't see them, but you can count them. Each springs once, by itself, on your turn."},
	{"id": "token", "title": "Tokens", "info": true,
		"text": "That unit is a [b]token[/b]: made by an effect, not drawn. It fights like any card, and when it leaves the field it is gone for good."},
	{"id": "rules", "title": "Rules of this fight", "info": true,
		"text": "The [b]icons under the enemy's portrait[/b] are this fight's rules. Hover one for what it does; click it for the full list. Red helps them, green helps you."},
	{"id": "scripted", "title": "Scripted events", "info": true,
		"text": "Bosses and elites have [b]scripted events[/b]: the [color=#ff9f43]amber icons[/color]. Each happens once, at half health or on a set turn. A timed one is announced the turn before."},
]

## Info prompts go away by themselves after this long, so a player who ignores them is never stuck with one.
const INFO_SECONDS: float = 12.0
const BUBBLE_WIDTH: float = 440.0

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
var _shown_at: float = 0.0
var _skipped: bool = false
## Every prompt shown this battle, in order (smokes read it instead of sampling the bubble frame by frame).
var shown_log: Array[String] = []


## Whether a battle should show tips at all: until they are skipped, while any prompt has not been seen.
## Overnight Oct 30-31 (mid-game critic #1): the first-duel basics, never shown again to a hero past them (level 5+ or a zone freed): a save
## that skipped them (an old save, a snapshot) no longer gets "Your first duel" at level 13. The later topics (traps, Tools, the Refuse Pile,
## keywords, tokens, rules) still show once, when they first come up.
const BASIC_STEPS: Array[String] = ["intro", "infrastructure", "energy", "unit", "resource_made", "resource_use", "resource_spend", "resource_why", "end_turn", "attack", "block"]


static func past_basics() -> bool:
	return Session.profile != null and (Session.profile.level >= 5 or Session.completed_zone_count() > 0)


static func step_seen(id: String) -> bool:
	return Session.flag(StringName("tut_%s" % id)) or (BASIC_STEPS.has(id) and past_basics())


static func wanted() -> bool:
	if Session.flag(&"tutorial_done") or not Settings.tutorial_tips:  # Fresh eyes round 2 (Oct 31): Settings > Text > "Tutorial tips"
		return false
	for step: Dictionary in STEPS:
		if not step_seen(str(step["id"])):
			return true
	return false


func setup(battle: BattleScreen) -> void:
	screen = battle
	layer = 30
	for step: Dictionary in STEPS:
		if step_seen(str(step["id"])):
			_done[str(step["id"])] = true
	_host = UIKit.layer_host(self)
	_overlay = Overlay.new()
	_overlay.size = Vector2(1920, 1080)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_host.add_child(_overlay)
	_bubble = UIKit.panel()
	_bubble.name = "TutorialBubble"
	_bubble.custom_minimum_size = Vector2(BUBBLE_WIDTH, 0)
	_bubble.size = Vector2(BUBBLE_WIDTH, 10)
	_bubble.visible = false
	_bubble.z_index = 5
	# Clicks pass through the bubble (only its buttons take them), so it never blocks a card under it.
	_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_host.add_child(_bubble)
	var column: VBoxContainer = UIKit.vbox(6)
	_bubble.add_child(column)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title = UIKit.label("", &"HeadingLabel", 26)
	column.add_child(_title)
	_text = UIKit.rich("", 21)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.custom_minimum_size = Vector2(BUBBLE_WIDTH - 40.0, 0)
	column.add_child(_text)
	var row: HBoxContainer = UIKit.hbox(10)
	column.add_child(row)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_got_it = FancyButton.make("Got it", &"PrimaryButton", Vector2(130, 42))
	_got_it.pressed.connect(_on_got_it)
	row.add_child(_got_it)
	row.add_child(UIKit.filler())
	var skip: FancyButton = FancyButton.make("Skip tips", &"GhostButton", Vector2(150, 42))
	skip.add_theme_font_size_override("font_size", 19)
	skip.pressed.connect(skip_tutorial)
	row.add_child(skip)


func skip_tutorial() -> void:
	_skipped = true
	Session.set_flag(&"tutorial_done")
	_hide()
	set_process(false)


## The id of the prompt on screen ("" when none).
func current_step() -> String:
	return _current


func bubble_rect() -> Rect2:
	return Rect2(_bubble.position, _bubble.size) if _bubble.visible else Rect2()


func _hide() -> void:
	_bubble.visible = false
	_overlay.target = Rect2()
	_overlay.queue_redraw()
	_current = ""


## A prompt counts as seen once it has been shown and closed (done, dismissed or no longer relevant).
func _mark_done(id: String) -> void:
	_done[id] = true
	Session.set_flag(StringName("tut_%s" % id))


func on_battle_event(event: GameEvent) -> void:
	match event.type:
		GameEvent.Type.INFRASTRUCTURE_PLAYED:
			if event.player == 0:
				_flags["infrastructure_played"] = true
		GameEvent.Type.RESOURCE_CREATED:
			if event.player == 0:
				_flags["resource_made"] = true
		GameEvent.Type.RESOURCE_USED:
			if event.player == 0:
				_flags["resource_used"] = true
		GameEvent.Type.CARD_PLAYED:
			if event.player == 0:
				_flags["cast"] = true
				var card: CardInstance = screen.game.find_card(event.card)
				if card != null and card.data.is_tool():
					_flags["tool_played"] = true
		GameEvent.Type.PERMANENT_ENTERED:
			if event.player == 0:
				_flags["unit_played"] = true
		GameEvent.Type.TRAP_SET:
			if event.player == 0:
				_flags["trap_set"] = true
		GameEvent.Type.TRAP_TRIGGERED:
			if event.player != 0:
				_flags["enemy_trap"] = event.card
		GameEvent.Type.ATTACKERS_DECLARED:
			if event.player == 0:
				_flags["attacked"] = true
		GameEvent.Type.BLOCKER_ASSIGNED:
			_flags["blocked"] = true
		GameEvent.Type.UNIT_DIED, GameEvent.Type.CARD_TOSSED:
			_flags["refuse"] = true
		GameEvent.Type.TOKEN_CREATED:
			var made: CardInstance = screen.game.find_card(event.card)
			if made != null and made.data.is_unit():
				_flags["token"] = event.card
		GameEvent.Type.SCRIPT_TRIGGERED:
			_flags["scripted"] = true


func on_mode_changed(_mode: int) -> void:
	pass


func on_attackers_changed(_count: int) -> void:
	pass


## Fresh eyes round 2 (Oct 31): E and Enter (the keys the game calls "interact" and "confirm") press "Got it" while an info tip is up, as the
## click does; the pad's cursor already reaches the button (`BattlePad`). Space stays the battle's own phase key and is left alone, so a
## Space meant for To Combat never also closes a tip. A short guard after the tip opens keeps the key that caused it from closing it unread.
const GOT_IT_GUARD: float = 0.6


func _unhandled_input(event: InputEvent) -> void:
	if _skipped or _current == "" or not _bubble.visible or not _got_it.visible or _time - _shown_at < GOT_IT_GUARD:
		return
	var key: InputEventKey = event as InputEventKey
	var enter: bool = key != null and key.pressed and not key.echo and (key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER)
	if enter or (InputMap.has_action(&"interact") and event.is_action_pressed(&"interact") and not event.is_echo()):
		get_viewport().set_input_as_handled()
		_on_got_it()


func _on_got_it() -> void:
	if _current != "":
		_mark_done(_current)
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
		var info: bool = _is_info(_current)
		if _finished(_current) or not _still_relevant(_current) or (info and _time - _shown_at > INFO_SECONDS):
			_mark_done(_current)
			_hide()
			return
		_place()
	_overlay.pulse = 0.5 + 0.5 * sin(_time * 5.0)
	_overlay.queue_redraw()


func _is_info(id: String) -> bool:
	for step: Dictionary in STEPS:
		if str(step["id"]) == id:
			return bool(step.get("info", false))
	return false


func _show(step: Dictionary) -> void:
	_current = str(step["id"])
	shown_log.append(_current)
	_shown_at = _time
	_title.text = _fill(str(step["title"]))
	_text.text = _fill(str(step["text"]))
	_got_it.visible = bool(step.get("info", false))
	_bubble.visible = true
	_bubble.reset_size()
	_bubble.size = Vector2(BUBBLE_WIDTH, _bubble.size.y)
	# The first placement is exact (no glide from wherever the last bubble was).
	_bubble.position = _best_spot(_target_rect(_current), _avoid_rects(_current), _bubble.size)
	Audio.sfx(&"ui_open", -8.0)
	UIKit.pop_in(_bubble)


# ---- Resources (Overnight Oct 17, Part 9) ------------------------------------------------------------------------

## What each Resource's own use does, for the "spend it" prompt.
const RESOURCE_EFFECTS: Dictionary = {
	ResourceKind.Kind.IRON: "your unit gets [b]+1/+1 until end of turn[/b] (use it before you attack)",
	ResourceKind.Kind.RED_TAPE: "an enemy unit gets [b]-2 attack until the start of your next turn[/b] (shrink a blocker, then attack; it stays shrunk through their turn)",
}
## Words in a card's rules text that mean it spends a Resource.
const SPEND_WORDS: Array[String] = ["use an Ingredient", "use two Ingredients", "use an Iron", "use a Red Tape", "use a Garbage", "Eat garbage", "eat garbage"]


## The player's Path Resource (the kind their coins are, else their Path's).
func _resource_kind() -> ResourceKind.Kind:
	for uid: int in _resource_coins():
		var view: CardView = screen.board.view_for(uid)
		if view != null and view.data != null:
			return view.data.resource_kind as ResourceKind.Kind
	return maxi(0, ResourceKind.created_by_basic(Session.profile.primary_affinity)) as ResourceKind.Kind if Session.profile != null else ResourceKind.Kind.IRON


func _fill(text: String) -> String:
	if not text.contains("{"):
		return text
	var kind: ResourceKind.Kind = _resource_kind()
	return text.replace("{resource}", ResourceKind.display_name(kind)).replace("{effect}", str(RESOURCE_EFFECTS.get(kind, "it gets stronger")))


## The player's Resource coins on the table.
func _resource_coins() -> Array[int]:
	var result: Array[int] = []
	for uid: Variant in screen.board.zones.keys():
		if int(screen.board.zones[uid]) != BattleBoard.Zone.RESOURCES:
			continue
		var view: CardView = screen.board.view_for(int(uid))
		if view != null and int(view.get_meta("owner", 0)) == 0:
			result.append(int(uid))
	return result


## Coins the player could use right now (Iron and Red Tape have their own use; it costs 1 energy and needs a target).
func _usable_resource_coins() -> Array[int]:
	var result: Array[int] = []
	var game: GameState = screen.game
	if game.active != 0 or not game.in_main_phase() or not game.can_pay_energy(0, 1, [] as Array[Affinity.Type]):
		return result
	for uid: int in _resource_coins():
		var view: CardView = screen.board.view_for(uid)
		var kind: ResourceKind.Kind = view.data.resource_kind as ResourceKind.Kind
		if ResourceKind.has_use_ability(kind) and _has_own_target(game, kind):
			result.append(uid)
	return result


## Fresh eyes Oct 30: the "spend your Iron" prompt (and its hold on the turn) wants a unit of the player's OWN to buff. `use_targets` lists
## every unit, the enemy's included, so the prompt fired - and held End Turn - while the only unit on the table was the enemy's.
static func _has_own_target(game: GameState, kind: ResourceKind.Kind) -> bool:
	var targets: Array[int] = ResourceRules.use_targets(game, 0, kind)
	for unit: CardInstance in game.players[0].units():
		if targets.has(unit.uid):
			return true
	return false


## Cards in hand or on the field that spend a Resource and could be played or used now (only while the player has one).
func _spenders() -> Array[int]:
	var result: Array[int] = []
	if _resource_coins().is_empty() or screen.game.active != 0:
		return result
	for card: CardInstance in _hand_cards():
		if _spends(card.data) and screen.game.can_play_card(0, card.uid):
			result.append(card.uid)
	for card: CardInstance in screen.game.players[0].field:
		if _spends(card.data) and not card.exhausted:
			result.append(card.uid)
	return result


static func _spends(data: CardData) -> bool:
	if data == null:
		return false
	for word: String in SPEND_WORDS:
		if data.rules_text.contains(word):
			return true
	return false


## While the "spend your Iron / Red Tape" prompt is up, the duel waits: To Combat / End Turn ask the player to use it first. Only while
## it can really be used, so nothing can lock up.
func blocks_turn_end() -> bool:
	if _skipped or _current != "resource_use":
		return false
	return _still_relevant(_current)


func _mode() -> BattleScreen.Mode:
	return screen.mode


func _hand_cards() -> Array[CardInstance]:
	return screen.game.players[0].hand


func _hand_where(test: Callable) -> Array[int]:
	var result: Array[int] = []
	for card: CardInstance in _hand_cards():
		if bool(test.call(card)):
			result.append(card.uid)
	return result


func _castable_units() -> Array[int]:
	return _hand_where(func(card: CardInstance) -> bool: return card.data.is_unit() and screen.game.can_play_card(0, card.uid))


func _castable() -> Array[int]:
	return _hand_where(func(card: CardInstance) -> bool: return not card.data.is_infrastructure() and screen.game.can_play_card(0, card.uid))


func _playable_infrastructure() -> Array[int]:
	return _hand_where(func(card: CardInstance) -> bool: return card.data.is_infrastructure() and screen.game.can_play_infrastructure(0, card.uid))


func _keyword_cards() -> Array[int]:
	var result: Array[int] = []
	for card: CardInstance in screen.game.players[0].field:
		if not card.data.keywords.is_empty():
			result.append(card.uid)
	return result


func _trap_cards() -> Array[int]:
	return _hand_where(func(card: CardInstance) -> bool: return card.data.type == CardEnums.CardType.TRAP and screen.game.can_play_card(0, card.uid))


func _tool_cards() -> Array[int]:
	return _hand_where(func(card: CardInstance) -> bool: return card.data.is_tool() and screen.game.can_play_card(0, card.uid))


func _triggered(id: String) -> bool:
	if screen.busy:
		return false
	var mode: BattleScreen.Mode = _mode()
	var main: bool = mode == BattleScreen.Mode.MAIN
	match id:
		"intro":
			return mode == BattleScreen.Mode.MULLIGAN
		"infrastructure":
			return main and not _playable_infrastructure().is_empty()
		"energy":
			return main and bool(_flags.get("infrastructure_played", false))
		"resource_made":
			return main and (_done.has("unit") or _castable_units().is_empty()) and bool(_flags.get("resource_made", false)) and not _resource_coins().is_empty()
		"unit":
			return main and _done.has("energy") and not _castable_units().is_empty()
		"resource_use":
			return main and _done.has("resource_made") and not _usable_resource_coins().is_empty()
		"resource_spend":
			return main and _done.has("resource_made") and _usable_resource_coins().is_empty() and not _spenders().is_empty()
		"resource_why":
			return main and bool(_flags.get("resource_used", false))
		"end_turn":
			return main and _done.has("unit") and screen.game.phase == GameState.Phase.MAIN1 and _castable().is_empty() and _playable_infrastructure().is_empty()
		"attack":
			return mode == BattleScreen.Mode.ATTACK and not screen.game.possible_attackers(0).is_empty()
		"block":
			return mode == BattleScreen.Mode.BLOCK
		"trap":
			return main and _done.has("unit") and not _trap_cards().is_empty()
		"enemy_trap":
			return int(_flags.get("enemy_trap", 0)) > 0 and screen.board.view_for(int(_flags["enemy_trap"])) != null
		"tool":
			return main and _done.has("unit") and not _tool_cards().is_empty()
		"refuse":
			var fought: bool = _done.has("attack") or _done.has("block")
			return main and fought and bool(_flags.get("refuse", false)) and not screen.game.players[0].refuse_pile.is_empty()
		"keywords":
			return main and _done.has("attack") and not _keyword_cards().is_empty()
		"enemy_traps_set":
			return main and _done.has("unit") and _rect_of(_enemy_trap_uids()).has_area()
		"token":
			return main and _done.has("unit") and screen.board.view_for(int(_flags.get("token", 0))) != null
		"rules":
			return main and (_done.has("unit") or screen.game.turn >= 4) and screen.hud.rule_row != null and is_instance_valid(screen.hud.rule_row)
		"scripted":
			return main and bool(_flags.get("scripted", false)) and screen.hud.rule_row != null and is_instance_valid(screen.hud.rule_row)
	return false


func _finished(id: String) -> bool:
	match id:
		"infrastructure":
			return bool(_flags.get("infrastructure_played", false))
		"unit":
			return bool(_flags.get("unit_played", false))
		"resource_use", "resource_spend":
			return bool(_flags.get("resource_used", false))
		"trap":
			return bool(_flags.get("trap_set", false))
		"tool":
			return bool(_flags.get("tool_played", false))
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
		"resource_use":
			return (mode == BattleScreen.Mode.MAIN and not _usable_resource_coins().is_empty()) or mode == BattleScreen.Mode.TARGETING
		"resource_spend":
			return (mode == BattleScreen.Mode.MAIN and not _spenders().is_empty()) or mode == BattleScreen.Mode.TARGETING
		"infrastructure", "energy", "unit", "trap", "tool", "end_turn", "keywords", "refuse", "resource_made", "resource_why", "rules", "scripted":
			return mode == BattleScreen.Mode.MAIN or mode == BattleScreen.Mode.TARGETING
		"enemy_traps_set":
			return (mode == BattleScreen.Mode.MAIN or mode == BattleScreen.Mode.TARGETING) and _rect_of(_enemy_trap_uids()).has_area()
		"token":
			return (mode == BattleScreen.Mode.MAIN or mode == BattleScreen.Mode.TARGETING) and screen.board.view_for(int(_flags.get("token", 0))) != null
		"attack":
			return mode == BattleScreen.Mode.ATTACK
		"block":
			return mode == BattleScreen.Mode.BLOCK
		"enemy_trap":
			return screen.board.view_for(int(_flags.get("enemy_trap", 0))) != null
	return true


# ---- Placement --------------------------------------------------------------------------


func _target_rect(id: String) -> Rect2:
	match id:
		"intro":
			return Rect2()
		"infrastructure":
			return _union(_playable_infrastructure())
		"energy":
			return screen.hud.portrait_rect(0)
		"unit":
			return _union(_castable_units())
		"keywords":
			return _union(_keyword_cards())
		"resource_made", "resource_why":
			return _union(_resource_coins())
		"resource_use":
			return _union(_usable_resource_coins())
		"resource_spend":
			return _union(_spenders())
		"trap":
			return _union(_trap_cards())
		"tool":
			return _union(_tool_cards())
		"enemy_trap":
			return _union([int(_flags.get("enemy_trap", 0))] as Array[int])
		"refuse":
			return screen.refuse_widgets[0].get_global_rect() if not screen.refuse_widgets.is_empty() else Rect2()
		"end_turn":
			return screen.hud.primary_button.get_global_rect()
		"attack":
			var uids: Array[int] = []
			for card: CardInstance in screen.game.possible_attackers(0):
				uids.append(card.uid)
			return _union(uids)
		"block":
			return _union(screen.game.attackers)
		"enemy_traps_set":
			return _rect_of(_enemy_trap_uids())
		"token":
			return _union([int(_flags.get("token", 0))] as Array[int])
		"rules", "scripted":
			return screen.hud.rule_row.get_global_rect() if screen.hud.rule_row != null and is_instance_valid(screen.hud.rule_row) else Rect2()
	return Rect2()


## The enemy's set traps (their face-down card backs).
func _enemy_trap_uids() -> Array[int]:
	var result: Array[int] = []
	for card: CardInstance in screen.game.players[1].traps:
		result.append(card.uid)
	return result


func _rect_of(uids: Array[int]) -> Rect2:
	return _union(uids) if not uids.is_empty() else Rect2()


## Everything the bubble must not cover: the target, the hand while it talks about a hand card, and for a block also the
## units that could block.
func _avoid_rects(id: String) -> Array[Rect2]:
	var rects: Array[Rect2] = [_target_rect(id)]
	if id == "block":
		var blockers: Array[int] = []
		for card: CardInstance in screen.game.possible_blockers(0):
			blockers.append(card.uid)
		rects.append(_union(blockers))
	if id in ["infrastructure", "unit", "trap", "tool"]:
		rects.append(_union(_hand_where(func(_card: CardInstance) -> bool: return true)))
	# Fresh eyes round 2 (Oct 31): never over the enlarged card preview (left column) or either player's plate - the second critic's "Play a unit"
	# tip sat on the preview and its "Energy" tip on the player's plate.
	if screen.hud != null:
		rects.append(screen.hud.preview_rect())
		rects.append(screen.hud.plate_rect(0))
		rects.append(screen.hud.plate_rect(1))
	return rects


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


## The first of above, left, right and below the target that stays on screen and covers nothing in `avoid`.
func _best_spot(target: Rect2, avoid: Array[Rect2], size: Vector2) -> Vector2:
	if target.size == Vector2.ZERO:
		return Vector2((1920.0 - size.x) * 0.5, 300.0)
	var gap: float = 36.0
	var center: Vector2 = target.get_center()
	var candidates: Array[Vector2] = [
		Vector2(center.x - size.x * 0.5, target.position.y - size.y - gap),
		Vector2(target.position.x - size.x - gap, center.y - size.y * 0.5),
		Vector2(target.end.x + gap, center.y - size.y * 0.5),
		Vector2(center.x - size.x * 0.5, target.end.y + gap),
		# The open table edges: the left column beside the plates, then the strip left of the turn panel.
		Vector2(16.0, 330.0),
		Vector2(1620.0 - size.x, 330.0),
	]
	var fallback: Vector2 = Vector2.ZERO
	var first: bool = true
	for spot: Vector2 in candidates:
		var clamped: Vector2 = Vector2(clampf(spot.x, 16.0, 1904.0 - size.x), clampf(spot.y, 120.0, 1064.0 - size.y))
		var box: Rect2 = Rect2(clamped, size)
		if first:
			fallback = clamped
			first = false
		var clear: bool = true
		for rect: Rect2 in avoid:
			if rect.size != Vector2.ZERO and box.intersects(rect.grow(8.0)):
				clear = false
		if clear:
			return clamped
	return fallback


func _place() -> void:
	var target: Rect2 = _target_rect(_current)
	_overlay.target = target
	var spot: Vector2 = _best_spot(target, _avoid_rects(_current), _bubble.size)
	_bubble.position = _bubble.position.lerp(spot, 0.35)
	if target.size == Vector2.ZERO:
		_overlay.arrow_from = Vector2.ZERO
		return
	# The arrow leaves the bubble's edge nearest the target.
	var box: Rect2 = Rect2(spot, _bubble.size)
	var tip: Vector2 = target.get_center()
	_overlay.arrow_from = Vector2(clampf(tip.x, box.position.x + 30.0, box.end.x - 30.0), clampf(tip.y, box.position.y + 20.0, box.end.y - 20.0))


class Overlay:
	extends Control
	var target: Rect2 = Rect2()
	var arrow_from: Vector2 = Vector2.ZERO
	var pulse: float = 0.0

	func _draw() -> void:
		if target.size == Vector2.ZERO:
			return
		var ring: Rect2 = target.grow(8.0 + pulse * 5.0)
		draw_rect(ring, Color(1.0, 0.85, 0.35, 0.10 + pulse * 0.08), true)
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
