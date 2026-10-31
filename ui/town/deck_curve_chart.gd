class_name DeckCurveChart
extends Control
## Overnight Oct 30-31, Part 7: the Deck Station's cost curve - one bar per cost (0 ... 6, 7+) for the deck's non-Infrastructure cards, the
## count over each bar, the cost under it. Reads `DeckInsights.cost_curve`; draws only.

const BAR_COLOR: Color = Color("e0b25a")
const EMPTY_COLOR: Color = Color(1, 1, 1, 0.08)

var curve: Array[int] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_text = ""


func set_curve(values: Array[int]) -> void:
	curve = values.duplicate()
	queue_redraw()


func _draw() -> void:
	if curve.is_empty():
		return
	var font: Font = UIStyle.font_bold()
	var buckets: int = curve.size()
	var gap: float = 6.0
	var label_h: float = 18.0
	var width: float = (size.x - gap * float(buckets - 1)) / float(buckets)
	var top: float = 18.0
	var height: float = size.y - top - label_h
	var peak: int = 1
	for value: int in curve:
		peak = maxi(peak, value)
	for index: int in range(buckets):
		var x: float = float(index) * (width + gap)
		draw_rect(Rect2(x, top, width, height), EMPTY_COLOR)
		var bar: float = height * float(curve[index]) / float(peak)
		if curve[index] > 0:
			draw_rect(Rect2(x, top + height - bar, width, bar), BAR_COLOR)
			var count: String = str(curve[index])
			draw_string(font, Vector2(x, top + height - bar - 3.0), count, HORIZONTAL_ALIGNMENT_CENTER, width, 15, UIStyle.PARCHMENT)
		var cost: String = "%d+" % index if index == buckets - 1 else str(index)
		draw_string(font, Vector2(x, size.y - 2.0), cost, HORIZONTAL_ALIGNMENT_CENTER, width, 15, UIStyle.MUTED)
