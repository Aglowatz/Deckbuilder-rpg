extends GutTest
## Overnight Oct 31 - Nov 1, Part 5 (the wish list): "Click again to go" on dungeon nodes, unlock hints printed on locked gear slots, a banner
## when a zone's HP pool differs, and the map's "Where to?" list with the dungeon entrance first.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_an_open_dungeon_node_says_how_to_go() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	assert_string_contains(DungeonMapScreen.node_go_hint(), "Click again or press E to go.")  # Fable pass Nov 1: the confirm key goes too
	InputDevice.set_kind(InputDevice.Kind.PAD)
	assert_string_contains(DungeonMapScreen.node_go_hint(), "to go.")
	assert_false(DungeonMapScreen.node_go_hint().contains("Click"), "a pad player is told the button")
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


## Nov 3-4, Part C: the locked figure carries one printed hint - the pill under it names the real quest (it was five "Opens: armory quest" captions).
func test_locked_gear_slots_print_their_unlock_hint() -> void:
	assert_eq(CharacterScreen.equipment_unlock_text(), "Equipment unlocks after Some Assembly Required")
	var screen: CharacterScreen = CharacterScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	var pill: Control = screen.find_child("UnlockPill", true, false) as Control
	assert_not_null(pill)
	assert_true(pill.visible)
	assert_eq((pill.find_child("PillText", true, false) as Label).text, CharacterScreen.equipment_unlock_text())


func test_a_zone_with_a_different_hp_pool_announces_it_once_per_visit() -> void:
	Session.begin_zone_visit(GainlandsZone.ID)
	if Session.zone_run.max_hp() == Session.profile.base_max_hp():
		assert_eq(Session.hp_pool_notice(), "", "the usual pool needs no banner")
	var famine: Modifier = CardBuilder.modifier(Modifier.Kind.MAX_HP, -5)
	famine.label = "Famine"
	var source: ModifierSource = CardBuilder.modifier_source("Famine", ModifierSource.SourceKind.ZONE, [famine] as Array[Modifier])
	Session.zone_run.run.dungeon_sources.append(source)
	var notice: String = Session.hp_pool_notice()
	assert_string_contains(notice, "Max HP here: %d" % Session.zone_run.max_hp())
	assert_string_contains(notice, "-5 Famine")
	assert_eq(Session.hp_pool_notice(), "", "once per visit")
	Session.begin_zone_visit(GainlandsZone.ID)
	Session.zone_run.run.dungeon_sources.append(source)
	assert_ne(Session.hp_pool_notice(), "", "a new visit announces again")


func test_where_to_lists_named_places_dungeon_first_one_per_name() -> void:
	var points: Array[MapPoi] = [
		MapPoi.make(MapPoi.Kind.VENDOR, Vector3.ZERO, "Sable's Cards"),
		MapPoi.make(MapPoi.Kind.DUNGEON, Vector3(5, 0, 5), "The Iron Cave"),
		MapPoi.make(MapPoi.Kind.VENDOR, Vector3(1, 0, 0), "Sable's Cards"),
		MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3(2, 0, 0), "A crate"),
		MapPoi.make(MapPoi.Kind.HEAL, Vector3(3, 0, 0), ""),
	] as Array[MapPoi]
	var places: Array[MapPoi] = FullMapScreen.where_to_places(points)
	assert_eq(places.size(), 3, "named places only, one per name (the unnamed healer is left out)")
	assert_eq(places[0].label, "The Iron Cave", "the dungeon entrance comes first")
	assert_eq(places[1].label, "Sable's Cards")
	assert_eq(places[2].label, "A crate", "named interactables come last (the Deck Station, the Hall of Records)")
