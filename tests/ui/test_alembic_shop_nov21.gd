extends GutTest
## Fable Nov 21 castle, Part 8: Auntie Alembic's shop - four glass jars that fill to 18 and light up when chosen, the "pick two Paths,
## then brew" strip, the pool as a titled grid, and the brewing moment (bubbles, a flash in the two Paths' colours).

const A: Affinity.Type = Affinity.Type.BEEFCAKE
const D: Affinity.Type = Affinity.Type.NECROCRAT


func _screen(essence_a: int, essence_d: int, gold: int = 1000) -> AlchemistScreen:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(A)
	Session.gold = gold
	Session.profile.set_essence(A, essence_a)
	Session.profile.set_essence(D, essence_d)
	var screen: AlchemistScreen = AlchemistScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	return screen


func _jar(screen: AlchemistScreen, path: Affinity.Type) -> EssenceJar:
	return (screen.find_child("EssenceRow%d" % int(path), true, false) as Button).find_child("Jar", true, false) as EssenceJar


func test_four_glass_jars_stand_on_a_shelf_and_show_their_fill() -> void:
	var screen: AlchemistScreen = await _screen(18, 9)
	var shelf: HBoxContainer = screen.find_child("JarShelf", true, false) as HBoxContainer
	assert_not_null(shelf, "Fable big pass Nov 23: the four jars stand in one row along the bottom (mock-up B)")
	assert_eq(shelf.get_child_count(), 4, "one jar per Path")
	var full: EssenceJar = _jar(screen, A)
	var half: EssenceJar = _jar(screen, D)
	assert_eq([full.amount, full.capacity], [18, Alchemy.ESSENCE_CAP_PER_PATH])
	assert_almost_eq(full.level(), 1.0, 0.001, "18 of 18 is a full jar")
	assert_almost_eq(half.level(), 0.5, 0.001, "9 of 18 is half a jar")
	assert_eq(_jar(screen, Affinity.Type.GOURMAND).amount, 0)
	assert_null(screen.find_child("*ProgressBar*", true, false), "the cramped list's bars are gone")


func test_a_chosen_jar_lights_up() -> void:
	var screen: AlchemistScreen = await _screen(18, 9)
	assert_false(_jar(screen, A).chosen)
	(screen.find_child("EssenceRow%d" % int(A), true, false) as Button).pressed.emit()
	assert_true(_jar(screen, A).chosen, "lit")
	assert_false(_jar(screen, D).chosen)
	assert_true(((screen.find_child("EssenceRow%d" % int(A), true, false) as Button).find_child("Selected", true, false) as Label).visible)
	(screen.find_child("EssenceRow%d" % int(A), true, false) as Button).pressed.emit()
	assert_false(_jar(screen, A).chosen, "and dark again when it is put back")


func test_the_strip_says_pick_two_paths_then_brew() -> void:
	var screen: AlchemistScreen = await _screen(18, 9)
	var steps: Control = screen.find_child("BrewSteps", true, false) as Control
	assert_not_null(steps)
	var slot_a: Label = (steps.get_node("Slot0") as Control).find_child("Text", true, false) as Label
	var slot_b: Label = (steps.get_node("Slot1") as Control).find_child("Text", true, false) as Label
	assert_eq([slot_a.text, slot_b.text], ["empty", "empty"])
	var craft: FancyButton = screen.find_child("CraftButton", true, false) as FancyButton
	assert_true(craft.disabled, "nothing to brew yet")
	assert_string_contains(craft.text, "Brew")
	(screen.find_child("EssenceRow%d" % int(A), true, false) as Button).pressed.emit()
	assert_eq([slot_a.text, slot_b.text], ["Beefcake", "empty"])
	(screen.find_child("EssenceRow%d" % int(D), true, false) as Button).pressed.emit()
	assert_eq([slot_a.text, slot_b.text], ["Beefcake", "Necrocrat"])
	assert_false(craft.disabled, "two Paths with enough essence: brew")
	assert_false((screen.find_child("PoolTitle", true, false) as Label).text.is_empty(), "the pool has its heading")
	assert_gt((screen.find_child("PossibleRow", true, false) as GridContainer).get_child_count(), 4, "and its tidy grid")


func test_the_pool_shows_unseen_cards_face_down_with_the_owned_count() -> void:
	var screen: AlchemistScreen = await _screen(18, 9)
	(screen.find_child("EssenceRow%d" % int(A), true, false) as Button).pressed.emit()
	(screen.find_child("EssenceRow%d" % int(D), true, false) as Button).pressed.emit()
	var pool: GridContainer = screen.find_child("PossibleRow", true, false) as GridContainer
	assert_eq(pool.columns, AlchemistScreen.POOL_COLUMNS)
	for holder: Node in pool.get_children():
		var owned: Label = holder.find_child("Owned", true, false) as Label
		assert_not_null(owned)
		assert_true(owned.text.contains("/"), "owned out of the cap: %s" % owned.text)


func test_the_brewing_moment_bubbles_and_flashes_in_the_two_paths_colours() -> void:
	var before: bool = Settings.reduce_motion
	Settings.reduce_motion = false
	var screen: AlchemistScreen = await _screen(18, 9)
	(screen.find_child("EssenceRow%d" % int(A), true, false) as Button).pressed.emit()
	(screen.find_child("EssenceRow%d" % int(D), true, false) as Button).pressed.emit()
	(screen.find_child("CraftButton", true, false) as FancyButton).pressed.emit()
	await wait_frames(2)
	assert_eq(screen.find_children("Bubble*", "Panel", true, false).size(), AlchemistScreen.BREW_BUBBLES, "the pot boils")
	assert_eq(screen._brew_colours, [UIStyle.affinity_color(A), UIStyle.affinity_color(D)] as Array[Color])
	await wait_seconds(1.7)
	assert_eq(screen.find_children("BrewFlash*", "ColorRect", true, false).size(), 2, "one flash for each Path")
	assert_not_null(screen.find_child("CraftedCard", true, false), "and the card is revealed, enlarged")
	assert_eq(_jar(screen, A).amount, 18 - Alchemy.MIN_ESSENCE_PER_PATH, "the jar went down by what the brew took")
	Settings.reduce_motion = before


# ---- Fable big pass Nov 23 (Part 8): the rebuild from mock-up B ---------------------------------------------------------------------


func test_four_path_sockets_stand_on_the_circle_round_alembic_and_light_up() -> void:
	var screen: AlchemistScreen = await _screen(18, 9)
	var ring: AlembicRing = screen.find_child("Ring", true, false) as AlembicRing
	var streams: AlembicRing = screen.find_child("Streams", true, false) as AlembicRing
	assert_not_null(ring)
	assert_not_null(streams)
	var cauldron: Control = screen.find_child("Cauldron", true, false) as Control
	assert_gt(streams.get_index(), cauldron.get_index(), "the streams pour over her picture")
	assert_lt(ring.get_index(), cauldron.get_index(), "the circle is behind it")
	for path: Affinity.Type in PathIcons.ORDER:
		var socket: Button = screen.find_child("Socket%d" % int(path), true, false) as Button
		assert_not_null(socket, "a socket for %s" % Affinity.display_name(path))
		assert_eq(socket.focus_mode, Control.FOCUS_ALL, "a controller reaches it")
		var spot: Vector2 = ring.sockets[path] as Vector2
		var on_circle: float = pow((spot.x - ring.centre.x) / ring.radii.x, 2.0) + pow((spot.y - ring.centre.y) / ring.radii.y, 2.0)
		assert_between(on_circle, 0.8, 1.25, "the socket sits on the circle")
		assert_false(bool(socket.get_meta("chosen")))
	(screen.find_child("Socket%d" % int(A), true, false) as Button).pressed.emit()
	assert_true(bool((screen.find_child("Socket%d" % int(A), true, false) as Button).get_meta("chosen")), "a clicked socket lights up")
	assert_true(_jar(screen, A).chosen, "and so does its jar: one choice, two ways to make it")
	assert_eq(streams.chosen, [A] as Array[Affinity.Type], "its essence pours into the pot")
	var stream: PackedVector2Array = streams.stream_points(A)
	assert_lt(stream[0].distance_to(ring.sockets[A] as Vector2), 1.0)
	assert_lt(stream[stream.size() - 1].distance_to(streams.pot_mouth), 1.0, "from the socket into the pot's mouth")


func test_the_brew_button_is_under_her_and_the_jars_along_the_bottom() -> void:
	var screen: AlchemistScreen = await _screen(18, 9)
	await wait_frames(2)
	var cauldron: Rect2 = (screen.find_child("Cauldron", true, false) as Control).get_global_rect()
	var brew: Rect2 = (screen.find_child("CraftButton", true, false) as Control).get_global_rect()
	var shelf: Rect2 = (screen.find_child("JarShelf", true, false) as Control).get_global_rect()
	var panel: Rect2 = (screen.find_child("CardPanel", true, false) as Control).get_global_rect()
	assert_gte(brew.position.y, cauldron.end.y - 8.0, "Brew is under Alembic")
	assert_almost_eq(brew.get_center().x, cauldron.get_center().x, 12.0, "and centred on her")
	assert_gte(shelf.position.y, brew.end.y, "the jars are below it")
	assert_gt(panel.position.x, brew.end.x, "the card panel is on the right")
	assert_false(panel.intersects(shelf), "nothing overlaps")
	var paper: StyleBoxFlat = (screen.find_child("CardPanel", true, false) as PanelContainer).get_theme_stylebox("panel") as StyleBoxFlat
	assert_gt(paper.bg_color.get_luminance(), 0.7, "the card panel is light, like mock-up A's")


func test_the_third_and_fourth_slot_open_after_primm() -> void:
	var screen: AlchemistScreen = await _screen(18, 18)
	assert_eq(screen.slot_count(), 2)
	var locked: Array[bool] = []
	for index: int in range(4):
		locked.append(bool((screen.find_child("Slot%d" % index, true, false) as Control).get_meta("locked")))
	assert_eq(locked, [false, false, true, true] as Array[bool], "two Paths before Primm; the others show a padlock")
	Session.profile.postgame_unlocked = true
	for path: Affinity.Type in PathIcons.ORDER:
		Session.profile.set_essence(path, 18)
	var after: AlchemistScreen = AlchemistScreen.new()
	add_child_autofree(after)
	await wait_frames(3)
	assert_eq(after.slot_count(), 4)
	for index: int in range(4):
		assert_false(bool((after.find_child("Slot%d" % index, true, false) as Control).get_meta("locked")), "slot %d is open after Primm" % index)
	for path: Affinity.Type in PathIcons.ORDER.slice(0, 3):
		(after.find_child("Socket%d" % int(path), true, false) as Button).pressed.emit()
	var craft: FancyButton = after.find_child("CraftButton", true, false) as FancyButton
	assert_string_contains(craft.text, "%d gold" % Alchemy.TRI_GOLD_COST)
	assert_false(craft.disabled, "three Paths brew")
	(after.find_child("Socket%d" % int(PathIcons.ORDER[3]), true, false) as Button).pressed.emit()
	assert_eq(after._selected.size(), 4, "and all four may go in")
	assert_string_contains(craft.text, "%d gold" % Alchemy.QUAD_GOLD_COST)
	assert_eq(Alchemy.gold_cost(2), Alchemy.GOLD_COST)
	assert_eq(Alchemy.problem_for(Session.profile, 0, after._selected), "Need %d gold" % Alchemy.QUAD_GOLD_COST)


func test_the_brewed_card_rises_over_the_cauldron_and_the_pool_stays() -> void:
	var screen: AlchemistScreen = await _screen(18, 18)
	(screen.find_child("EssenceRow%d" % int(A), true, false) as Button).pressed.emit()
	(screen.find_child("EssenceRow%d" % int(D), true, false) as Button).pressed.emit()
	(screen.find_child("CraftButton", true, false) as FancyButton).pressed.emit()
	await wait_seconds(2.4)
	var card: Control = screen.find_child("CraftedCard", true, false) as Control
	assert_not_null(card)
	assert_false((screen.find_child("Cauldron", true, false) as Control).visible, "the card takes her place until the next click")
	assert_true((screen.find_child("PossibleCards", true, false) as Control).visible, "the pool stays in its panel")
	assert_true(card.has_meta(&"hover_zoom") or card.mouse_filter == Control.MOUSE_FILTER_PASS, "hovering it magnifies it")
	(screen.find_child("Socket%d" % int(A), true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_null(screen.find_child("CraftedCard", true, false), "a click on a Path puts the cauldron back")
	assert_true((screen.find_child("Cauldron", true, false) as Control).visible)
