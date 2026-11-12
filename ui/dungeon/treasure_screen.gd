class_name TreasureScreen
extends Control
## A treasure node (Part E): a chest that opens with a small animation and lists what it held (gold, XP, an
## item, a card, a heal...). The loot is applied by `Session.apply_treasure` when the chest is opened.
## Fable Nov 12c (Part B): built on `NodeCard` - the room's corner of the map under a gold wash, sparkles, the loot as icon rows.

signal finished

var map_node: DungeonMap.MapNode
var card: NodeCard
var _opened: bool = false
var _button: FancyButton


static func make(node: DungeonMap.MapNode) -> TreasureScreen:
	var screen: TreasureScreen = TreasureScreen.new()
	screen.name = "TreasureScreen"
	screen.map_node = node
	return screen


func _ready() -> void:
	PadFocus.register(self)  # controller support (Oct 26): the pad focuses this screen's buttons
	UIKit.full_rect(self)
	card = NodeCard.make(NodeCard.Kind.TREASURE, map_node.title, 820.0)
	add_child(card)
	card.set_banner_for_node(map_node)
	if not map_node.blurb.is_empty():
		card.flavour(map_node.blurb)
	card.effect([["ICON-GOLD", "Gold"], ["ICON-XP", "XP"], ["ICON-UI-INVENTORY", "and whatever else is inside"]])
	_button = card.button("Open the chest", true, "ICON-NODE-TREASURE", 300.0)
	_button.name = "TreasureButton"
	_button.pressed.connect(_on_button)
	ConfirmKey.attach(card, _button)
	_button.call_deferred(&"grab_focus")
	Audio.sfx(&"ui_open")


func _on_button() -> void:
	if _opened:
		Audio.sfx(&"ui_close")
		finished.emit()
		return
	_opened = true
	var granted: Dictionary = Session.apply_treasure(map_node)
	Audio.sfx(&"chest_iron")
	if card.icon != null and not NodeCard.still():
		card.icon.pivot_offset = card.icon.size * 0.5
		var pop: Tween = create_tween()
		pop.tween_property(card.icon, "scale", Vector2(1.3, 1.3), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		pop.tween_property(card.icon, "scale", Vector2.ONE, 0.2)
	# the list of what it held replaces the "what is inside" line
	for child: Node in card.content.get_children():
		if child.name == "Effect":
			child.queue_free()
	for entry: Array in loot_rows(granted):
		var row: HFlowContainer = card.effect([[str(entry[0]), str(entry[1])]])
		row.name = "Loot"
	if granted.has("gold"):
		Audio.sfx(&"coins")
	_button.text = "Continue"
	_button.icon = null


func _lines(granted: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	for entry: Array in loot_rows(granted):
		lines.append(str(entry[1]))
	return lines


## What the chest held, one row each: [icon id, text].
static func loot_rows(granted: Dictionary) -> Array[Array]:
	var rows: Array[Array] = []
	if granted.has("gold"):
		rows.append(["ICON-GOLD", "+%d gold" % int(granted["gold"])])
	if granted.has("xp"):
		rows.append(["ICON-XP", "+%d XP" % int(granted["xp"])])
	if granted.has("heal"):
		rows.append(["ICON-STAT-HP", "+%d HP" % int(granted["heal"])])
	if granted.has("item"):
		rows.append(["ICON-UI-INVENTORY", "Item: %s" % str(granted["item"])])
	if granted.has("card"):
		rows.append(["ICON-UI-COLLECTION", "Card: %s" % str(granted["card"])])
	if granted.has("equipment"):
		rows.append(["ICON-EQUIP-RELIC", "Equipment: %s" % str(granted["equipment"])])
	if granted.has("pack"):
		rows.append(["ICON-UI-PACKS", "Pack: %s" % str(granted["pack"])])
	if rows.is_empty():
		rows.append(["", "The chest is empty. Someone got here first."])
	return rows
