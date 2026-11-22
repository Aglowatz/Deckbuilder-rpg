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
	var shelf: GridContainer = screen.find_child("JarShelf", true, false) as GridContainer
	assert_not_null(shelf)
	assert_eq(shelf.columns, 2)
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
	var slot_a: Label = (steps.get_node("Slot0") as Control).get_node("Text") as Label
	var slot_b: Label = (steps.get_node("Slot1") as Control).get_node("Text") as Label
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
	assert_eq(pool.columns, 8)
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
