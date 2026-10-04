class_name TreasureScreen
extends Control
## A treasure node (Part E): a chest that opens with a small animation and lists what it held (gold, XP, an
## item, a card, a heal...). The loot is applied by `Session.apply_treasure` when the chest is opened.

signal finished

var map_node: DungeonMap.MapNode
var _column: VBoxContainer
var _panel: PanelContainer
var _chest: TextureRect
var _opened: bool = false
var _button: FancyButton


static func make(node: DungeonMap.MapNode) -> TreasureScreen:
	var screen: TreasureScreen = TreasureScreen.new()
	screen.name = "TreasureScreen"
	screen.map_node = node
	return screen


func _ready() -> void:
	UIKit.full_rect(self)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.84)
	UIKit.full_rect(shade)
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	_panel = UIKit.panel()
	_panel.custom_minimum_size = Vector2(900, 0)
	center.add_child(_panel)
	_column = UIKit.vbox(14)
	_panel.add_child(_column)
	_column.add_child(UIKit.label(map_node.title, &"TitleLabel", 52, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var blurb: Label = UIKit.label(map_node.blurb, &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(820, 0)
	_column.add_child(blurb)
	_chest = CardIcons.glyph(CardIcons.named("skoll/open-treasure-chest"), UIStyle.GOLD, Vector2(170, 170))
	_chest.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_chest.pivot_offset = Vector2(85, 85)
	_column.add_child(_chest)
	_button = FancyButton.make("Open the chest", &"PrimaryButton", Vector2(280, 62))
	_button.name = "TreasureButton"
	_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_button.pressed.connect(_on_button)
	_column.add_child(_button)
	UIKit.pop_in(_panel)
	Audio.sfx(&"ui_open")


func _on_button() -> void:
	if _opened:
		finished.emit()
		return
	_opened = true
	var granted: Dictionary = Session.apply_treasure(map_node)
	Audio.sfx(&"chest_open")
	var pop: Tween = create_tween()
	pop.tween_property(_chest, "scale", Vector2(1.35, 1.35), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(_chest, "scale", Vector2.ONE, 0.2)
	for line: String in _lines(granted):
		var row: Label = UIKit.label(line, &"HeadingLabel", 28, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
		row.name = "Loot"
		_column.add_child(row)
		_column.move_child(row, _column.get_child_count() - 2)
	if granted.has("gold"):
		Audio.sfx(&"coins")
	_button.text = "Continue"


func _lines(granted: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	if granted.has("gold"):
		lines.append("+%d gold" % int(granted["gold"]))
	if granted.has("xp"):
		lines.append("+%d XP" % int(granted["xp"]))
	if granted.has("heal"):
		lines.append("+%d life" % int(granted["heal"]))
	if granted.has("item"):
		lines.append("Item: %s" % str(granted["item"]))
	if granted.has("card"):
		lines.append("Card: %s" % str(granted["card"]))
	if granted.has("equipment"):
		lines.append("Equipment: %s" % str(granted["equipment"]))
	if lines.is_empty():
		lines.append("The chest is empty. Someone got here first.")
	return lines
