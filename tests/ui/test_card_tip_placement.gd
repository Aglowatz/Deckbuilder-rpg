extends GutTest
## Overnight Oct 19 (Part 2): the card's ability box stands beside the hovered card on its own top layer, flips to the left near the right edge, stays on
## screen, and never covers the card - in the hand, on the field, for traps and token stacks alike (one placement rule for every card view).

const SCREEN: Vector2 = Vector2(1920, 1080)
const BOX: Vector2 = Vector2(330, 260)


func _assert_beside(card: Rect2, label: String) -> void:
	var at: Vector2 = BattleHud.tip_position(card, BOX, SCREEN)
	var tip: Rect2 = Rect2(at, BOX)
	assert_false(tip.intersects(card), "%s: the box never covers the card" % label)
	assert_true(Rect2(Vector2.ZERO, SCREEN).encloses(tip), "%s: the box stays on screen (%s)" % [label, str(tip)])


func test_box_stands_beside_the_card_everywhere() -> void:
	_assert_beside(Rect2(Vector2(700, 860), Vector2(170, 240)), "hand card at the bottom")
	_assert_beside(Rect2(Vector2(1700, 820), Vector2(170, 240)), "hand card at the right edge")
	_assert_beside(Rect2(Vector2(20, 400), Vector2(150, 210)), "field card at the left edge")
	_assert_beside(Rect2(Vector2(960, 20), Vector2(90, 120)), "enemy trap at the top")
	_assert_beside(Rect2(Vector2(1300, 600), Vector2(60, 84)), "token stack")


func test_prefers_the_right_side_and_flips_near_the_edge() -> void:
	var middle: Rect2 = Rect2(Vector2(700, 500), Vector2(170, 240))
	assert_gt(BattleHud.tip_position(middle, BOX, SCREEN).x, middle.end.x, "right of the card")
	var edge: Rect2 = Rect2(Vector2(1700, 500), Vector2(170, 240))
	assert_lt(BattleHud.tip_position(edge, BOX, SCREEN).x + BOX.x, edge.position.x, "left of a card at the right edge")


func test_the_box_lives_on_a_layer_above_the_table() -> void:
	assert_gt(BattleHud.TIP_LAYER, 0, "above the board (layer 0)")
	assert_lt(BattleHud.TIP_LAYER, 30, "under the tutorial bubbles")


func test_keyword_only_rules_are_not_repeated() -> void:
	var entries: Array[Array] = [["Hustle", "Can attack the turn it enters."], ["Bulldoze", "..."]]
	assert_true(BattleHud._only_keywords("Hustle.", entries))
	assert_true(BattleHud._only_keywords("Hustle. Bulldoze.", entries))
	assert_false(BattleHud._only_keywords("Hustle. When this unit enters, create an Ingredient.", entries))
	assert_false(BattleHud._only_keywords("", entries))
