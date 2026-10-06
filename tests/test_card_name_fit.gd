extends GutTest
## A card name never touches the cost pips: every designed card, in both the full and the compact frame, fits the space left
## of the pips (shrunk, wrapped or shortened to the part before the comma).


func test_every_card_name_fits_beside_its_cost_pips() -> void:
	var misfits: Array[String] = []
	for entry: CardImporter.Entry in CardImporter.build_all():
		if entry.is_token or entry.data.is_infrastructure():
			continue
		for card_mode: CardView.Mode in [CardView.Mode.FULL, CardView.Mode.COMPACT]:
			var view: CardView = CardView.create(entry.data, card_mode)
			add_child_autofree(view)
			if not view.name_fits():
				misfits.append("%s (%s)" % [entry.data.display_name, CardView.Mode.keys()[card_mode]])
	assert_eq(misfits.size(), 0, "names that overflow: %s" % ", ".join(misfits))
