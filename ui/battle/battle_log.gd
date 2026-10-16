class_name BattleLog
extends PanelContainer
## Battle feel, Part B: a collapsible log of what just happened ("Gym Bro attacked for 3", "Pink Slip destroyed Village
## Militia"). It only reads the game's events and names; it never touches the rules. Collapsed it is a small button.

const MAX_LINES: int = 40
const PANEL_SIZE: Vector2 = Vector2(330, 300)

var game: GameState
var enemy_name: String = "Enemy"
## uid -> CardData of every card the board has seen (dead cards keep their names).
var names: Dictionary = {}
var lines: Array[String] = []
var expanded: bool = false
var _list: RichTextLabel
var _toggle: FancyButton
var _body: Control
## Who last hurt each unit (uid -> source uid) and the spell being resolved, so a death can say what caused it.
var _hurt_by: Dictionary = {}
var _resolving: int = 0


func setup(game_state: GameState, enemy: String, card_names: Dictionary) -> void:
	game = game_state
	enemy_name = enemy
	names = card_names
	name = "BattleLog"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var column: VBoxContainer = UIKit.vbox(4)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(column)
	_body = UIKit.panel(&"DarkPanel")
	_body.custom_minimum_size = PANEL_SIZE
	_body.visible = false
	column.add_child(_body)
	_list = UIKit.rich("", 17, false)
	_list.name = "LogText"
	_list.fit_content = false
	_list.scroll_active = true
	_list.scroll_following = true
	_list.custom_minimum_size = PANEL_SIZE - Vector2(28, 28)
	_body.add_child(_list)
	_toggle = FancyButton.make("Battle log", &"GhostButton", Vector2(150, 38))
	_toggle.name = "LogToggle"
	_toggle.add_theme_font_size_override("font_size", 18)
	_toggle.pressed.connect(toggle)
	column.add_child(_toggle)


func toggle() -> void:
	expanded = not expanded
	_body.visible = expanded
	_toggle.text = "Hide log" if expanded else "Battle log"
	# The log grows upward from its button.
	position.y += -(PANEL_SIZE.y + 4.0) if expanded else PANEL_SIZE.y + 4.0
	Audio.sfx(&"ui_tick")


func add_event(event: GameEvent) -> void:
	var text: String = describe(event)
	if text.is_empty():
		return
	lines.append(text)
	while lines.size() > MAX_LINES:
		lines.pop_front()
	_list.text = "\n".join(lines)


## One readable line for an event, or "" for the bookkeeping ones (draws, phases, energy).
func describe(event: GameEvent) -> String:
	match event.type:
		GameEvent.Type.TURN_STARTED:
			_hurt_by.clear()
			_resolving = 0
			return "[color=#c9b98f]-- %s --[/color]" % ("Your turn" if event.player == 0 else "%s's turn" % enemy_name)
		GameEvent.Type.CARD_PLAYED:
			_resolving = event.card if _data(event.card) != null and not _data(event.card).is_unit() else 0
			if _data(event.card) != null and _data(event.card).type == CardEnums.CardType.TRAP and event.player != 0:
				return "%s set a trap" % _who(event.player)
			if event.other != 0:
				return "%s played %s on %s" % [_who(event.player), _card(event.card), _target(event.other)]
			return "%s played %s" % [_who(event.player), _card(event.card)]
		GameEvent.Type.INFRASTRUCTURE_PLAYED:
			return "%s played %s" % [_who(event.player), _card(event.card)]
		GameEvent.Type.TRAP_TRIGGERED:
			return "[color=#ffcf70]Trap! %s sprang[/color]" % _card(event.card)
		GameEvent.Type.ATTACKERS_DECLARED:
			return "%s attacked" % _card(event.card)
		GameEvent.Type.BLOCKER_ASSIGNED:
			return "%s blocked %s" % [_card(event.card), _card(event.other)]
		GameEvent.Type.DAMAGE_DEALT:
			if not Targets.is_player(event.other):
				_hurt_by[event.other] = event.card
			if event.amount <= 0:
				return ""
			return "%s hit %s for %d" % [_card(event.card), _target(event.other), event.amount]
		GameEvent.Type.UNIT_DIED:
			var cause: int = int(_hurt_by.get(event.card, _resolving))
			if cause > 0 and cause != event.card:
				return "[color=#ff8a7a]%s destroyed %s[/color]" % [_card(cause), _card(event.card)]
			return "[color=#ff8a7a]%s was destroyed[/color]" % _card(event.card)
		GameEvent.Type.HP_CHANGED:
			if event.amount > 0:
				return "[color=#8fe39a]%s healed %d (HP %d)[/color]" % [_who(event.player), event.amount, event.value]
			return ""
		GameEvent.Type.CARD_SENT_BACK:
			return "%s was sent back to hand" % _card(event.card)
		GameEvent.Type.TOKEN_CREATED:
			return "%s got a %s" % [_who(event.player), _card(event.card)]
		GameEvent.Type.ABILITY_ACTIVATED:
			return "%s used an ability" % _card(event.card)
		GameEvent.Type.STATS_CHANGED:
			return "%s got %+d/%+d" % [_card(event.card), event.amount, event.value]
		GameEvent.Type.CARD_SHREDDED:
			return "%s was shredded" % _card(event.card)
		GameEvent.Type.UNIT_REINSTATED:
			return "%s came back from the Refuse Pile" % _card(event.card)
		GameEvent.Type.GAME_OVER:
			return "[color=#ffd76a]The battle is over[/color]"
	return ""


func _who(player_index: int) -> String:
	return "You" if player_index == 0 else enemy_name


func _data(uid: int) -> CardData:
	if names.has(uid):
		return names[uid] as CardData
	var card: CardInstance = game.find_card(uid) if game != null else null
	return card.data if card != null else null


func _card(uid: int) -> String:
	var data: CardData = _data(uid)
	return "[b]%s[/b]" % data.display_name if data != null else "a card"


func _target(ref: int) -> String:
	if Targets.is_player(ref):
		return "you" if Targets.player_index(ref) == 0 else enemy_name
	return _card(ref)
