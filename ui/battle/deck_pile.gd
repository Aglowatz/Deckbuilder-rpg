class_name DeckPile
extends Control
## One player's deck on the battleboard: a stack of card backs on the UI art kit's deck base (UI-HUD-DECK) with the count on the base front. The human's deck shows the
## back of their primary Path, the opponent's the default back (`CardView.back_id`). Purely visual: cards fly in from and out to `center()`.

const PILE_SIZE: Vector2 = Vector2(150, 150)
const BASE_SIZE: Vector2 = Vector2(150, 76)
const BACK_SIZE: Vector2 = Vector2(54, 81)

var player_index: int = 0
var count_label: Label
var _stack: Control


## True when the base art exists (the HUD then uses this instead of its plain counter chip).
static func available() -> bool:
	return UiArt.has("UI-HUD-DECK")


func setup(index: int) -> void:
	player_index = index
	custom_minimum_size = PILE_SIZE
	size = PILE_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	name = "DeckPile%d" % index
	var base: TextureRect = TextureRect.new()
	base.texture = UiArt.texture("UI-HUD-DECK")
	base.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	base.stretch_mode = TextureRect.STRETCH_SCALE
	base.position = Vector2(0, PILE_SIZE.y - BASE_SIZE.y)
	base.size = BASE_SIZE
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)
	_stack = Control.new()
	_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stack)
	var back: Texture2D = UiArt.texture("UI-CARDBACK-C" if index != 0 else CardView.player_back_id())
	for layer: int in range(3):
		var picture: TextureRect = TextureRect.new()
		picture.texture = back
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_SCALE
		picture.size = BACK_SIZE
		picture.position = Vector2((PILE_SIZE.x - BACK_SIZE.x) * 0.5 + float(layer - 1) * 2.5, 30.0 - float(layer) * 2.5)
		picture.modulate = Color(0.78, 0.74, 0.82) if layer < 2 else Color.WHITE
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stack.add_child(picture)
	count_label = UIKit.label("Deck 0", &"", 22, Color("fff3d6"), HORIZONTAL_ALIGNMENT_CENTER)
	count_label.add_theme_font_override("font", UIStyle.font_bold())
	count_label.add_theme_color_override("font_outline_color", Color("1b1020"))
	count_label.add_theme_constant_override("outline_size", 6)
	count_label.position = Vector2(0, PILE_SIZE.y - BASE_SIZE.y * 0.43)
	count_label.size = Vector2(PILE_SIZE.x, 28)
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(count_label)


## Where cards leave the deck / return to it, in the pile's parent coordinates.
func center() -> Vector2:
	return position + Vector2(PILE_SIZE.x * 0.5, 70.0)
