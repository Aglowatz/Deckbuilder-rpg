extends GutTest
## Zone title cards (Part E of the art integration round): the names, when a card shows, how it is drawn.


func before_each() -> void:
	KeyArt.reset()


func test_every_area_spells_its_name() -> void:
	assert_eq(Areas.banner_name(Areas.GAINLANDS), "The Gainlands")
	assert_eq(Areas.banner_name(Areas.DNA), "The Department of Necrotic Affairs")
	assert_eq(Areas.banner_name(Areas.BUFFET), "The Endless Buffet")
	assert_eq(Areas.banner_name(Areas.DUMP), "The Verdant Dump")
	assert_eq(Areas.banner_name(Areas.CAPITAL), "The Capital")
	assert_eq(Areas.banner_name(Areas.TOWN), "Crosspath")
	assert_eq(Areas.banner_name(Areas.START), "The Forest Clearing")
	assert_eq(Areas.banner_id(Areas.DNA), "ZONE-TITLE-DNA")
	assert_eq(Areas.banner_id(Areas.DUMP), "ZONE-TITLE-DUMP")
	for key: String in [Areas.START, Areas.TOWN, Areas.GAINLANDS, Areas.DNA, Areas.BUFFET, Areas.DUMP, Areas.CAPITAL]:
		assert_true(KeyArt.has(Areas.banner_id(key)), "%s banner art" % key)


func test_a_card_shows_on_entry_from_another_area_but_not_when_reloading_the_same_one() -> void:
	assert_true(ZoneTitleCard.should_show(Areas.GAINLANDS, Areas.TOWN))
	assert_true(ZoneTitleCard.should_show(Areas.TOWN, Areas.GAINLANDS))
	assert_true(ZoneTitleCard.should_show(Areas.TOWN, ""), "from the title (a loaded save, a new game)")
	assert_true(ZoneTitleCard.should_show(Areas.DNA, Areas.DUNGEON), "back from a dungeon is an entry too")
	assert_false(ZoneTitleCard.should_show(Areas.GAINLANDS, Areas.GAINLANDS), "loading a save made in the same area")
	assert_false(ZoneTitleCard.should_show(Areas.DUNGEON, Areas.TOWN), "dungeons have no banner")


func test_the_card_draws_the_name_over_the_banner() -> void:
	var card: ZoneTitleCard = ZoneTitleCard.make(Areas.DNA)
	assert_not_null(card)
	add_child_autofree(card)
	await wait_frames(2)
	assert_eq((card.find_child("Banner", true, false) as TextureRect).texture, KeyArt.texture("ZONE-TITLE-DNA"))
	var label: Label = card.find_child("ZoneName", true, false) as Label
	assert_eq(label.text, "The Department of Necrotic Affairs")
	assert_gt(label.size.x, 0.0)
	assert_null(ZoneTitleCard.make(Areas.DUNGEON), "no banner for a dungeon")


func test_a_long_name_shrinks_to_fit_the_banner_middle() -> void:
	var font: Font = UIStyle.font_title()
	var box: Vector2 = Vector2(460.0, 120.0)
	var short_size: int = ZoneTitleCard.fitted_font_size(font, "The Capital", box)
	var long_size: int = ZoneTitleCard.fitted_font_size(font, "The Department of Necrotic Affairs", box)
	assert_gt(short_size, long_size)
	var measured: Vector2 = font.get_multiline_string_size("The Department of Necrotic Affairs", HORIZONTAL_ALIGNMENT_CENTER, box.x, long_size)
	assert_lte(measured.y, box.y)


func test_dark_ribbons_get_light_names_and_parchment_gets_dark_ones() -> void:
	assert_true(ZoneTitleCard.is_bright_middle(KeyArt.texture("ZONE-TITLE-DNA")), "gray parchment")
	assert_false(ZoneTitleCard.is_bright_middle(KeyArt.texture("ZONE-TITLE-GAINLANDS")), "red ribbon")


func test_the_scene_manager_remembers_where_you_came_from() -> void:
	var saved_current: String = SceneManager.current_area
	var saved_previous: String = SceneManager.previous_area
	assert_true(SceneManager.has_signal("revealed"))
	SceneManager.current_area = saved_current
	SceneManager.previous_area = saved_previous


func test_a_dungeon_card_uses_its_zones_banner_and_a_flourish() -> void:
	var card: ZoneTitleCard = ZoneTitleCard.make_dungeon("The House of Gains", GainlandsZone.ID)
	assert_not_null(card)
	assert_eq(card.banner_override, "ZONE-TITLE-GAINLANDS")
	assert_eq(card.subtitle, "The Gainlands")
	assert_eq(card.path, int(Affinity.Type.BEEFCAKE))
	add_child_autofree(card)
	await wait_frames(2)
	assert_eq((card.find_child("ZoneName", true, false) as Label).text, "The House of Gains")
	assert_not_null(card.find_child("Flourish", true, false))
	assert_null(ZoneTitleCard.make_dungeon("", GainlandsZone.ID))
	var town: ZoneTitleCard = ZoneTitleCard.make_dungeon("The Door Under the Well", "")
	assert_eq(town.banner_override, "ZONE-TITLE-TOWN")
	town.free()


func test_later_arrivals_get_the_brief_card() -> void:
	ZoneTitleCard._seen.erase(Areas.DUMP)
	var first: ZoneTitleCard = ZoneTitleCard.make(Areas.DUMP)
	assert_false(first.brief)
	assert_eq(first.subtitle, "Home of the Refusemancer Path")
	ZoneTitleCard.mark_seen(Areas.DUMP)
	var again: ZoneTitleCard = ZoneTitleCard.make(Areas.DUMP)
	assert_true(again.brief)
	first.free()
	again.free()
