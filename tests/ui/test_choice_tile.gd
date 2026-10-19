extends GutTest
## Daytime Oct 19, Part 5: one tile style for the choice tiles (the Path choice, the equipment-slot choice, the Collection Book's
## entries) - `UiSkin.choice_tile`.


func test_a_choice_tile_gets_every_state_and_the_shared_focus_ring() -> void:
	var tile: Button = Button.new()
	add_child_autofree(tile)
	UiSkin.choice_tile(tile, UIStyle.GOLD)
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		assert_true(tile.has_theme_stylebox_override(state), "%s is styled" % state)
	assert_null(tile.get_node_or_null(^"SelectedRing"))


func test_selecting_adds_the_ring_and_deselecting_removes_it() -> void:
	var tile: Button = Button.new()
	add_child_autofree(tile)
	UiSkin.choice_tile(tile, UIStyle.GOLD, true)
	assert_not_null(tile.get_node_or_null(^"SelectedRing"), "the chosen tile wears a ring")
	UiSkin.choice_tile(tile, UIStyle.GOLD, true)
	assert_eq(tile.find_children("SelectedRing", "", false, false).size(), 1, "never two rings")
	UiSkin.choice_tile(tile, UIStyle.GOLD, false)
	await wait_process_frames(1)
	assert_null(tile.get_node_or_null(^"SelectedRing"))


func test_the_choice_screens_use_it() -> void:
	for path: String in ["res://ui/dungeon/element_choice_screen.gd", "res://ui/screens/equipment_slot_choice_screen.gd", "res://ui/town/codex_screen.gd"]:
		assert_true(FileAccess.get_file_as_string(path).contains("UiSkin.choice_tile("), "%s uses the shared tile" % path.get_file())
