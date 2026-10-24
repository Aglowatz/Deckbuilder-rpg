extends GutTest
## The sub-area scenes are gone (docs/design/subarea_removal.md): a save that recorded one ("sub:<area>/<sub>") loads into that area's main scene at the spot
## where the hub gate to it stood, or at the area's own spawn when the sub-area is unknown; nothing else is touched by the migration.


func test_every_removed_sub_area_resolves_to_its_main_area() -> void:
	assert_eq(LegacySubAreas.PLACES.size(), 40, "all 40 removed sub-areas are in the table")
	for key: Variant in LegacySubAreas.PLACES.keys():
		var place: Dictionary = LegacySubAreas.resolve("sub:%s" % str(key))
		var area: String = str(key).get_slice("/", 0)
		assert_eq(str(place["kind"]), str(LegacySubAreas.AREA_KINDS[area]), "%s loads into its area's main scene" % str(key))
		assert_true(place.has("position"), "%s has a landing spot" % str(key))
		var kind: String = str(place["kind"])
		if kind.begins_with("zone:"):
			assert_true(ZoneDefs.has_def(kind.trim_prefix("zone:")), "%s names a real zone" % str(key))


func test_the_landing_spots_are_the_old_gate_positions() -> void:
	assert_eq(LegacySubAreas.resolve("sub:gainlands/proving_grounds")["position"], Vector3(50.0, 0.0, 78.0), "the old Proving Grounds gate returns to the plaza (Gainlands v2 moved the hub)")
	assert_eq(LegacySubAreas.resolve("sub:gainlands/sky_garden")["position"], Vector3(50.0, 0.0, 78.0), "the Sky Garden hung off the Proving Grounds: the plaza too")
	assert_eq(LegacySubAreas.resolve("sub:dna/executive_approach")["position"], Vector3(70.5, 0.0, 27.5), "the Executive Approach hung off the Records Basement gate")
	assert_eq(LegacySubAreas.resolve("sub:castle_grounds/grand_stair")["kind"], "zone:final", "the castle grounds were reached from the Capital")
	assert_eq(LegacySubAreas.resolve("sub:castle_grounds/grand_stair")["position"], Vector3(59.3, 0.0, 20.3), "at the Palace Approach gate")
	assert_eq(LegacySubAreas.resolve("sub:pathology_lab/glass_tank_hall")["kind"], "start", "the Lab antechamber was reached from the forest clearing")
	assert_eq(LegacySubAreas.resolve("sub:pathology_lab/glass_tank_hall")["position"], Vector3(5.4, 0.0, 5.6), "at the hatch gate")
	assert_eq(LegacySubAreas.resolve("sub:main_town/chapel_hill")["position"], Vector3(-1.3, 0.0, 38.7))


func test_unknown_tokens_fall_back_sensibly() -> void:
	assert_eq(LegacySubAreas.resolve("zone:gourmand"), {}, "a current token is not a legacy one")
	assert_eq(LegacySubAreas.resolve("town"), {})
	assert_eq(LegacySubAreas.resolve("sub:heap/no_such_place"), {"kind": "zone:refusemancer"}, "an unknown sub-area of a known area loads the area at its own spawn")
	assert_eq(LegacySubAreas.resolve("sub:nowhere/at_all"), {"kind": "town"}, "an unknown area loads the town")


func test_loading_a_sub_area_save_resumes_in_the_main_area_at_the_gate() -> void:
	Session.new_game()
	Session.ensure_game()
	Session.set_flag(&"trial_cleared")
	Session.last_location = "The Proving Grounds"
	# Oct 23: a test folder - this test used to write the player's real manual Slot 1 on every GUT run.
	var real_dir: String = SaveSlots.dir
	SaveSlots.dir = "user://test_legacy_sub_area_saves/"
	Session.save_to_slot(1, "Sub-area save")
	var data: Dictionary = SaveSlots.load_data(1)
	(data["meta"] as Dictionary)["scene"] = "sub:gainlands/proving_grounds"
	SaveSystem.write(data, SaveSlots.path_for(1))
	var loaded: bool = Session.load_from_slot(1)
	SaveSlots.delete(1)
	SaveSlots.dir = real_dir
	assert_true(loaded)
	assert_eq(Session.pending_resume_scene, "sub:gainlands/proving_grounds", "the token is read as saved")
	# resume_loaded_game changes the scene; the part under test is where it sends the hero. The town fallback and the zone case are read from the source.
	var source: String = FileAccess.get_file_as_string("res://app/game_session.gd")
	var body: String = source.substr(source.find("func resume_loaded_game()"), 1200)
	assert_true(body.contains("LegacySubAreas.resolve(kind)"), "resume asks the legacy table")
	assert_true(body.contains("zone_run.return_position = legacy[\"position\"]"), "a zone save lands at the old gate")
	assert_true(body.contains("start_return_position = legacy[\"position\"]"), "a forest save lands at the old gate")
	assert_true(body.contains("town_return_position = legacy[\"position\"]"), "a town save lands at the old gate")
	# the landing spots stand on walkable ground of their hubs in the default state
	var layout: GainlandsLayout = GainlandsLayout.new()
	layout.build()
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	builder.build(host)
	for key: String in ["gainlands/proving_grounds", "gainlands/swolympus_trailhead"]:
		var spot: Vector3 = LegacySubAreas.resolve("sub:%s" % key)["position"] as Vector3
		assert_true(builder.is_walkable(spot, 0.3), "%s lands on walkable Gainlands ground (%s)" % [key, str(spot)])
	Session.new_game()
