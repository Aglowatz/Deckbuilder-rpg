extends GutTest
## Fix pass Nov 4 (Part 3.4): nothing is drawn over a card face in any card shop (Mirepoix's cloches were the "white arches" on every card;
## Gristle's can front covered the rules text; Fig Sly's doors hid the cards). The stands sit under the card.


func test_the_card_shops_add_no_overlays() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/town/vendor_screen.gd")
	for call: String in ["add_cloche(", "add_compartment(", "add_pull_out("]:
		assert_false(source.contains(call), "vendor_screen.gd still calls VendorFx.%s" % call)


func test_a_stand_sits_under_the_card() -> void:
	var holder: Control = Control.new()
	add_child_autofree(holder)
	var card_area: Rect2 = Rect2(Vector2(0, 0), CardView.SIZE * 0.5)
	for kind: VendorFx.Stand in [VendorFx.Stand.CAN, VendorFx.Stand.TUB]:
		var stand: VendorFx.StandFront = VendorFx.add_stand(holder, card_area, kind, Color.GRAY)
		assert_gte(stand.position.y, card_area.end.y - 2.0, "the stand starts at the card's bottom edge")
