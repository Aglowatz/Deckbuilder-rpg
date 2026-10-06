extends GutTest
## Brief 10b: the Beefcake Rift Express (fast travel): which stations exist and unlock, the text, the stations' places in the town and
## every zone, the menu, and the rule that a trip never starts for a station that is not unlocked.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


# ---- Rules --------------------------------------------------------------------------------------------------------------------


func test_there_is_a_station_in_town_and_one_per_zone() -> void:
	var ids: Array[String] = FastTravel.station_ids()
	assert_eq(ids[0], FastTravel.TOWN)
	assert_eq(ids.size(), 1 + ZoneDefs.all_ids().size())
	for zone_id: String in ZoneDefs.all_ids():
		assert_true(ids.has(zone_id), "a station in %s" % zone_id)


func test_only_the_town_station_is_unlocked_at_the_start() -> void:
	assert_eq(FastTravel.unlocked_ids(Session.flags), [FastTravel.TOWN] as Array[String])
	assert_true(FastTravel.is_unlocked(Session.flags, FastTravel.TOWN))
	for zone_id: String in ZoneDefs.all_ids():
		assert_false(FastTravel.is_unlocked(Session.flags, zone_id))


func test_reaching_a_zone_town_unlocks_its_station_once() -> void:
	assert_true(Session.unlock_fast_travel(GainlandsZone.ID), "the first time")
	assert_true(Session.fast_travel_unlocked(GainlandsZone.ID))
	assert_false(Session.unlock_fast_travel(GainlandsZone.ID), "only the first time reports an unlock")
	assert_false(Session.fast_travel_unlocked(DnaZone.ID), "the other stations stay locked")
	assert_false(Session.unlock_fast_travel(FastTravel.TOWN), "the town station has nothing to unlock")
	assert_false(Session.unlock_fast_travel("nowhere"))


func test_destinations_are_every_other_unlocked_station() -> void:
	Session.unlock_fast_travel(DnaZone.ID)
	Session.unlock_fast_travel(HeapZone.ID)
	var from_town: Array[String] = FastTravel.destinations(Session.flags, FastTravel.TOWN)
	assert_eq(from_town.size(), 2)
	assert_false(from_town.has(FastTravel.TOWN))
	var from_dna: Array[String] = FastTravel.destinations(Session.flags, DnaZone.ID)
	assert_true(from_dna.has(FastTravel.TOWN) and from_dna.has(HeapZone.ID))
	assert_false(from_dna.has(DnaZone.ID), "not to where you already are")
	assert_true(FastTravel.can_travel(Session.flags, DnaZone.ID, HeapZone.ID), "zone to zone")
	assert_false(FastTravel.can_travel(Session.flags, DnaZone.ID, BuffetZone.ID), "a locked station")


func test_the_unlocks_are_saved() -> void:
	Session.unlock_fast_travel(BuffetZone.ID)
	var data: Dictionary = Session.to_dict()
	assert_true(bool((data["flags"] as Dictionary).get(str(FastTravel.unlock_flag(BuffetZone.ID)), false)))


func test_a_trip_to_a_locked_station_does_not_start() -> void:
	assert_false(Session.fast_travel_to(GainlandsZone.ID))
	assert_false(Session.arrive_at_station)
	assert_false(Session.fast_travel_to("nowhere"))


# ---- Text ----------------------------------------------------------------------------------------------------------------------


func test_every_station_has_its_text() -> void:
	var story: StoryText = StoryText.shared()
	var missing: Array[String] = []
	var keys: Array[String] = [
		"travel.title", "travel.subtitle", "travel.here", "travel.locked.name", "travel.locked.blurb", "travel.warning", "travel.button",
		"travel.close", "travel.prompt", "travel.intro.town", "travel.intro.zone", "travel.intro.final", "travel.return.town",
		"travel.return.zone", "travel.rip.sound", "travel.sign.town", "travel.sign.zone", "travel.unlock.toast", "travel.unlock.title",
	]
	for index: int in range(1, FastTravel.RIP_LINES + 1):
		keys.append("travel.rip.%d" % index)
	for station_id: String in FastTravel.station_ids():
		keys.append("travel.operator.%s" % station_id)
		keys.append("travel.station.%s.name" % station_id)
		keys.append("travel.station.%s.blurb" % station_id)
		keys.append("travel.arrive.%s" % station_id)
		if station_id != FastTravel.TOWN:
			keys.append("travel.unlock.%s" % station_id)
	for key: String in keys:
		if not story.has_text(key):
			missing.append(key)
	assert_eq(missing, [] as Array[String], "missing travel text")


func test_the_beefcakes_are_in_character() -> void:
	var story: StoryText = StoryText.shared()
	assert_true(story.text("travel.intro.town").contains("SPOTTER"))
	assert_true(story.text("travel.rip.4").contains("leg day"))
	assert_true(story.text("travel.station.town.blurb").contains("sky"))


# ---- The stations in the world ------------------------------------------------------------------------------------


func test_the_town_has_a_station_with_room_to_arrive_and_to_use_it() -> void:
	var town: TownBuilder = TownBuilder.new()
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	town.build(parent, false)
	var station: Vector3 = town.anchors["rift_station"] as Vector3
	assert_true(town.is_walkable(station + Vector3(0.0, 0.0, 1.6), 0.3), "the landing spot and the spot to use it from, in front")
	assert_true(town.anchors.has("npc_rift_station"))


func test_every_zone_map_has_a_station_with_room_to_arrive_and_to_use_it() -> void:
	var builders: Dictionary = {
		DnaZone.ID: DnaBuilder.new(), GainlandsZone.ID: GainlandsBuilder.new(), BuffetZone.ID: BuffetBuilder.new(),
		HeapZone.ID: HeapBuilder.new(), CapitalZone.ID: CapitalBuilder.new(),
	}
	for zone_id: String in builders.keys():
		var builder: ZoneMap = builders[zone_id] as ZoneMap
		var parent: Node3D = Node3D.new()
		add_child_autofree(parent)
		builder.build(parent)
		assert_true(builder.has_anchor(FastTravel.ANCHOR), "%s has a Rift Station" % zone_id)
		var station: Vector3 = builder.anchor(FastTravel.ANCHOR)
		assert_true(builder.is_walkable(station + Vector3(0.0, 0.0, 2.4)), "%s: the landing spot in front" % zone_id)
		assert_true(builder.is_walkable(station + Vector3(0.0, 0.0, 1.6)), "%s: the spot to use it from" % zone_id)


func test_the_station_builds_and_tears() -> void:
	var station: FastTravelStation = FastTravelStation.new()
	add_child_autofree(station)
	station.build(["BEEFCAKE RIFT EXPRESS", "Do not look at the seam."] as Array[String], false)
	assert_false(station.active)
	station.set_active(true)
	assert_true(station.active)
	var tween: Tween = station.rip_effect(0.1)
	assert_not_null(tween)


# ---- The menu --------------------------------------------------------------------------------------------------------------------


func test_the_menu_lists_every_station_and_only_unlocked_ones_can_be_chosen() -> void:
	Session.unlock_fast_travel(GainlandsZone.ID)
	var screen: FastTravelScreen = FastTravelScreen.new()
	screen.here = FastTravel.TOWN
	add_child_autofree(screen)
	await get_tree().process_frame
	for station_id: String in FastTravel.station_ids():
		assert_not_null(screen.find_child("Station_%s" % station_id, true, false), "a row for %s" % station_id)
	assert_null(screen.find_child("Rip_%s" % FastTravel.TOWN, true, false), "no button for where you stand")
	assert_not_null(screen.find_child("Rip_%s" % GainlandsZone.ID, true, false), "a button for an unlocked station")
	assert_null(screen.find_child("Rip_%s" % DnaZone.ID, true, false), "none for a locked one")
	var chosen: Array[String] = []
	screen.destination_chosen.connect(func(station_id: String) -> void: chosen.append(station_id))
	(screen.find_child("Rip_%s" % GainlandsZone.ID, true, false) as Button).pressed.emit()
	assert_eq(chosen, [GainlandsZone.ID] as Array[String])
