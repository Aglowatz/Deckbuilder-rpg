extends GutTest
## A card name never touches the cost pips: every designed card, token and Infrastructure card, in both the full and the compact frame and in both card looks
## (the full-art face, and the UI art kit frame overlays in case they are switched back on), fits the space left of the pips (shrunk, wrapped or shortened to
## the part before the comma).


func after_each() -> void:
	UiArt.set_card_frame_overlays(null)


func _misfits(overlays: bool) -> Array[String]:
	UiArt.set_card_frame_overlays(overlays)
	var misfits: Array[String] = []
	for entry: CardImporter.Entry in CardImporter.build_all():
		for card_mode: CardView.Mode in [CardView.Mode.FULL, CardView.Mode.COMPACT]:
			var view: CardView = CardView.create(entry.data, card_mode)
			add_child_autofree(view)
			if not view.name_fits():
				misfits.append("%s (%s%s)" % [entry.data.display_name, CardView.Mode.keys()[card_mode], ", framed" if overlays else ""])
	return misfits


func test_every_card_name_fits_beside_its_cost_pips() -> void:
	var misfits: Array[String] = _misfits(false)
	assert_eq(misfits.size(), 0, "names that overflow: %s" % ", ".join(misfits))


func test_every_name_also_fits_in_the_framed_look() -> void:
	var misfits: Array[String] = _misfits(true)
	assert_eq(misfits.size(), 0, "names that overflow in the framed look: %s" % ", ".join(misfits))


func test_the_check_covers_tokens_and_infrastructure() -> void:
	var kinds: Dictionary = {}
	for entry: CardImporter.Entry in CardImporter.build_all():
		if entry.is_token:
			kinds["token"] = true
		elif entry.data.is_infrastructure():
			kinds["infrastructure"] = true
		else:
			kinds["card"] = true
	assert_eq(kinds.size(), 3, "cards, tokens and infrastructure are all in the list the fit test walks")
