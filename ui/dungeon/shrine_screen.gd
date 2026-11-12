class_name ShrineScreen
extends Control
## The healing shrine: rest to restore HP (the amount comes from the map node).
## Fable Nov 12c (Part B): built on `NodeCard` - the room's corner of the dungeon map as the banner, the heal as a ghost segment on the HP
## bar with "HP 9 → 15", Rest / Leave it, a shimmer over the bar as it fills.

signal finished

const FLAVOUR: String = "A quiet light gathers in the stone. Sit a while and it will mend you."

var card: NodeCard
var _button: FancyButton
var _leave: FancyButton
var _preview: NodeCard.HpPreview
var _rested: bool = false
var _heal: int = 0


func _ready() -> void:
	PadFocus.register(self)  # controller support (Oct 26): the pad focuses this screen's buttons
	UIKit.full_rect(self)
	var node: DungeonMap.MapNode = Session.dungeon_map.node(int(get_meta("node_id", 4)))
	_heal = node.heal_amount
	card = NodeCard.make(NodeCard.Kind.SHRINE, node.title, 820.0)
	add_child(card)
	card.set_banner_for_node(node)
	var hp: int = Session.run.hp
	var max_hp: int = Session.run.max_hp()
	card.flavour(FLAVOUR)
	card.effect([["ICON-STAT-HP", effect_text(_heal, max_hp)]])
	_preview = card.hp_preview(hp, mini(max_hp, hp + _heal), max_hp)
	var full: bool = hp >= max_hp
	_button = card.button("Continue" if full else "Rest", true, "" if full else "ICON-NODE-HEAL", 260.0)
	_button.name = "ShrineRest"
	_button.pressed.connect(_on_button)
	if full:
		_rested = true  # nothing to mend: the one button walks on
	else:
		_leave = card.button("Leave it", false, "", 220.0)
		_leave.name = "ShrineLeave"
		_leave.pressed.connect(func() -> void:
			Audio.sfx(&"ui_back")
			finished.emit())
		card.back_button = _leave
	# Overnight Nov 4-5, Part 8 (fresh critic #2): E / Enter / Space / the pad's A press Rest, then Continue (the critic was stuck here).
	ConfirmKey.attach(card, _button)
	_button.call_deferred(&"grab_focus")
	Audio.sfx(&"ui_open")


## Fresh eyes Oct 30: a full heal says so (the cave's "mend 999 of your HP" read as a placeholder).
static func effect_text(heal: int, max_hp: int) -> String:
	return "Heal to full HP" if heal >= max_hp else "Heal %d HP" % heal


func _on_button() -> void:
	if _rested:
		Audio.sfx(&"ui_close")
		finished.emit()
		return
	_rested = true
	Session.run.heal(_heal)
	Audio.sfx(&"heal")
	_preview.after = Session.run.hp
	_preview.apply()
	card.heal_shimmer()
	_button.text = "Continue"
	_button.icon = null
	if _leave != null:
		_leave.visible = false
		card.back_button = null
