extends GutTest
## Fix pass Nov 4 (B), Part 5.2: the Deck Station's ten slot frames line up as 5 above and 5 below (same columns, same size), locks as before.


func test_the_ten_slots_line_up_five_above_five_below() -> void:
	assert_eq(DeckSlots.SLOT_COUNT, 10)
	for view: Vector2 in [Vector2(1600, 900), Vector2(1920, 1080)]:
		for column: int in range(5):
			var top: Rect2 = DeckRack.cell_rect(column, view)
			var bottom: Rect2 = DeckRack.cell_rect(column + 5, view)
			assert_almost_eq(top.position.x, bottom.position.x, 0.01, "column %d lines up" % column)
			assert_almost_eq(top.size, bottom.size, Vector2(0.01, 0.01), "same size")
			assert_lt(top.end.y, bottom.position.y, "top row above the bottom row")
