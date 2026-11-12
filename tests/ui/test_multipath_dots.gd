extends GutTest
## Fable Nov 12c (A7): a multi-Path card shows no coloured dots under its name, in any view. Its Path cost icons stay.


func _multipath_cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for value: Variant in Session.content.multipath_cards.values():
		result.append(value as CardData)
	return result


## The round gem panels the old face drew at (22 + 26 n, 70): small square panels with a full corner radius just under the name bar.
func _gems(view: CardView) -> int:
	var found: int = 0
	for child: Node in view.get_children():
		if child is Panel and (child as Panel).size.is_equal_approx(Vector2(22, 22)) and (child as Panel).position.y > 60.0 and (child as Panel).position.y < 100.0:
			found += 1
	return found


func test_no_view_of_a_multipath_card_draws_the_dots() -> void:
	var cards: Array[CardData] = _multipath_cards()
	assert_gt(cards.size(), 10, "the multi-Path cards are loaded")
	for card: CardData in cards.slice(0, 12):
		for mode: CardView.Mode in [CardView.Mode.FULL, CardView.Mode.COMPACT]:
			var holder: Control = CardView.wrapped(card, 0.5, mode)
			add_child_autofree(holder)
			var views: Array[Node] = holder.find_children("*", "CardView", true, false)
			var view: CardView = (views[0] as CardView) if not views.is_empty() else (holder as CardView)
			assert_not_null(view, "%s has a card view" % card.id)
			if view != null:
				assert_true(view.dual, "%s is drawn as a multi-Path card" % card.id)
				assert_eq(_gems(view), 0, "%s (mode %d) has no dots under its name" % [card.id, mode])


func test_the_cost_icons_stay() -> void:
	var card: CardData = _multipath_cards()[0]
	assert_gt(card.colored_pips.size(), 1, "a multi-Path card asks for more than one Path")
	var holder: Control = CardView.wrapped(card, 0.5)
	add_child_autofree(holder)
	var rows: Array[Node] = holder.find_children("*", "", true, false).filter(func(node: Node) -> bool: return node.get_script() != null and node.has_method("_draw") and "step" in node and "data" in node)
	assert_gt(rows.size(), 0, "the cost row on the top right is still drawn")


func test_the_source_no_longer_builds_the_gems() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/card/card_view.gd")
	assert_false(source.contains("gem_color"), "the gem panels are gone from the card face")
