extends GutTest
## Fable Nov 21 review (Part 6): the small polish fixes, one test each.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


## The Card Packs shelf: every Open button sits on one line, whatever the length of the pack's name and description (a Gilded pack's
## two-line name and three-line description pushed its button below its neighbours').
func test_the_open_buttons_of_the_pack_shelf_line_up() -> void:
	while PacksScreen.all_pack_count() > 0:
		PacksScreen.open_all()
	Session.add_pack("path_beefcake", 1)
	Session.add_pack("gilded_refusemancer", 1)
	Session.add_pack("general_1", 1)
	var screen: PacksScreen = PacksScreen.new()
	add_child_autofree(screen)
	await wait_frames(4)
	var tops: Array[float] = []
	for id: String in ["path_beefcake", "gilded_refusemancer", "general_1"]:
		var button: Control = screen.find_child("Open_%s" % id, true, false) as Control
		assert_not_null(button, "the shelf has %s" % id)
		if button != null:
			tops.append(button.global_position.y)
	assert_eq(tops.size(), 3)
	if tops.size() == 3:
		assert_almost_eq(tops[0], tops[1], 1.0, "the plain pack's and the gilded pack's Open buttons are level (%.0f, %.0f)" % [tops[0], tops[1]])
		assert_almost_eq(tops[0], tops[2], 1.0, "and the General Pack's (%.0f, %.0f)" % [tops[0], tops[2]])


## The Deck Station's search box: a field that shows on the wood and a hint that can be read (it was grey on a grey veil).
func test_the_search_box_and_its_hint_can_be_read() -> void:
	var bar: CardFilterBar = CardFilterBar.new()
	bar.show_search = true
	add_child_autofree(bar)
	await wait_frames(2)
	assert_not_null(bar.search_box)
	var field: StyleBoxFlat = bar.search_box.get_theme_stylebox("normal") as StyleBoxFlat
	assert_not_null(field, "the box has its own field")
	if field == null:
		return
	assert_gte(field.bg_color.a, 0.9, "the field is solid enough to show on the wood")
	var hint: Color = bar.search_box.get_theme_color("font_placeholder_color")
	assert_gte(GlassTheme.contrast(hint, Color(field.bg_color, 1.0)), 5.0, "the hint reads on its field (%.1f : 1)" % GlassTheme.contrast(hint, Color(field.bg_color, 1.0)))
	assert_gte(field.get_border_width(SIDE_TOP), 1, "a hairline marks the field's edge")


## Choosing a line of a drop-down list (Settings: window mode, graphics quality, text size ...) ticks; it was silent.
func test_choosing_a_drop_down_line_ticks() -> void:
	if Audio.ui_sounds == null:
		pass_test("no interface sounds in this run")
		return
	var options: OptionButton = OptionButton.new()
	options.add_item("Normal")
	options.add_item("Large")
	add_child_autofree(options)
	await wait_frames(2)
	var before: int = Audio.ui_sounds.option_ticks
	options.select(1)
	assert_eq(Audio.ui_sounds.option_ticks, before, "a list set by its screen makes no sound")
	options.item_selected.emit(1)
	assert_eq(Audio.ui_sounds.option_ticks, before + 1, "the player's own choice ticks")
	var quiet: OptionButton = OptionButton.new()
	quiet.set_meta(&"no_ui_sound", true)
	quiet.add_item("One")
	add_child_autofree(quiet)
	await wait_frames(1)
	quiet.item_selected.emit(0)
	assert_eq(Audio.ui_sounds.option_ticks, before + 1, "a control marked no_ui_sound stays silent")
