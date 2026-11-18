extends GutTest
## Nov 18 day, Part 3: a small card in a pack's result row or a reward pick grows under the mouse / focus to about the battle preview's
## size, stays on screen, and returns when the mouse or focus leaves.


func before_each() -> void:
	Settings.reduce_motion = true  # snaps: the test reads the end state at once


func after_each() -> void:
	Settings.reduce_motion = false


func _small_card(at: Vector2, card_scale: float) -> Control:
	CardSet.load_all()
	var holder: Control = Control.new()
	holder.size = CardView.SIZE * card_scale
	holder.position = at
	holder.pivot_offset = holder.size * 0.5
	add_child_autofree(holder)
	var view: CardView = CardView.create(CardSet.card("C-04"), CardView.Mode.FULL)
	holder.add_child(view)
	CardView.fit(view, card_scale)
	return holder


func test_a_hovered_card_grows_to_the_preview_size_and_shrinks_back() -> void:
	var holder: Control = _small_card(Vector2(800, 400), 0.58)
	CardHoverZoom.attach(holder)
	var before: Vector2 = holder.scale
	holder.mouse_entered.emit()
	assert_true(CardHoverZoom.is_zoomed(holder))
	assert_almost_eq(holder.get_global_rect().size.y, CardHoverZoom.TARGET_HEIGHT, 2.0, "about the battle preview's height")
	assert_gt(holder.z_index, 0, "drawn over its neighbours")
	holder.mouse_exited.emit()
	assert_false(CardHoverZoom.is_zoomed(holder))
	assert_eq(holder.scale, before)
	assert_eq(holder.position, Vector2(800, 400))


func test_the_focused_card_grows_too() -> void:
	var holder: Control = _small_card(Vector2(800, 400), 0.58)
	holder.focus_mode = Control.FOCUS_ALL
	CardHoverZoom.attach(holder)
	holder.focus_entered.emit()
	assert_true(CardHoverZoom.is_zoomed(holder))
	holder.focus_exited.emit()
	assert_false(CardHoverZoom.is_zoomed(holder))


func test_a_card_near_the_top_edge_stays_on_screen() -> void:
	var holder: Control = _small_card(Vector2(40, 10), 0.58)
	CardHoverZoom.attach(holder)
	holder.mouse_entered.emit()
	var rect: Rect2 = holder.get_global_rect()
	var screen: Rect2 = holder.get_viewport_rect()
	assert_gte(rect.position.y, screen.position.y, "not off the top")
	assert_gte(rect.position.x, screen.position.x, "not off the left")
	assert_lte(rect.end.y, screen.end.y)


func test_the_enabled_check_holds_the_zoom() -> void:
	var holder: Control = _small_card(Vector2(800, 400), 0.58)
	var allowed: Array[bool] = [false]
	CardHoverZoom.attach(holder, null, func() -> bool: return allowed[0])
	holder.mouse_entered.emit()
	assert_false(CardHoverZoom.is_zoomed(holder), "not while the screen is still animating it")
	allowed[0] = true
	holder.mouse_entered.emit()
	assert_true(CardHoverZoom.is_zoomed(holder))


func test_a_big_card_does_not_grow() -> void:
	var holder: Control = _small_card(Vector2(600, 300), 1.2)
	CardHoverZoom.attach(holder)
	holder.mouse_entered.emit()
	assert_false(CardHoverZoom.is_zoomed(holder), "already bigger than the preview")


func test_the_reward_pick_tiles_zoom() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/screens/reward_popup.gd")
	assert_eq(source.count("CardHoverZoom.attach(tile)"), 2, "first build and after a reroll")
	assert_true(FileAccess.get_file_as_string("res://ui/dungeon/rewards_screen.gd").contains("CardHoverZoom.attach(holder, view)"))
	assert_true(FileAccess.get_file_as_string("res://ui/packs/pack_opening_screen.gd").contains("CardHoverZoom.attach(holder"))


func test_a_card_in_a_row_container_grows_about_its_centre_without_moving() -> void:
	CardSet.load_all()
	var row: HBoxContainer = HBoxContainer.new()
	row.position = Vector2(600, 400)
	add_child_autofree(row)
	var holder: Control = Control.new()
	holder.custom_minimum_size = CardView.SIZE * 0.6
	row.add_child(holder)
	var view: CardView = CardView.create(CardSet.card("C-04"), CardView.Mode.FULL)
	holder.add_child(view)
	CardView.fit(view, 0.6)
	await get_tree().process_frame
	var before: Rect2 = holder.get_global_rect()
	var position_before: Vector2 = holder.position
	CardHoverZoom.attach(holder)
	holder.mouse_entered.emit()
	assert_eq(holder.position, position_before, "the container keeps the position")
	var after: Rect2 = holder.get_global_rect()
	assert_almost_eq(after.size.y, CardHoverZoom.TARGET_HEIGHT, 2.0)
	assert_almost_eq(after.get_center().x, before.get_center().x, 1.0, "grows about its centre")
	holder.mouse_exited.emit()
	assert_almost_eq(holder.get_global_rect().size.y, before.size.y, 0.5)
