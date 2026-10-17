extends GutTest
## World sounds (docs/audio/sound_direction.md, "Places"): every ambience set has files, each place sounds different, the Capital's districts follow
## their state, the Verdant Dump grows eerier toward the Rotheart, footsteps follow the walk cycle's contacts and every surface has a footstep.

const SURFACES: Array[String] = ["grass", "dirt", "cobble", "stone", "wood", "carpet", "marble", "tile", "pastel", "ash", "mashed", "junk", "gravel", "metal"]


func test_every_ambience_and_landmark_set_has_files() -> void:
	var bank: SfxBank = SfxBank.load_from()
	for set_name: String in AmbienceProfiles.all_sets():
		assert_false(bank.files(set_name).is_empty(), "%s has files" % set_name)
	for zone_id: String in ["beefcake", "refusemancer", "gourmand", "final"]:
		for entry: Array in ZoneSoundscape.emitters(zone_id):
			assert_true(bank.is_loop(str(entry[0])), "%s is a loop" % entry[0])


func test_the_beds_are_loops() -> void:
	var bank: SfxBank = SfxBank.load_from()
	for profile_name: Variant in AmbienceProfiles.PROFILES.keys():
		for bed: Variant in (AmbienceProfiles.PROFILES[profile_name] as Dictionary).get("beds", []) as Array:
			assert_true(bank.is_loop(str((bed as Dictionary)["set"])), "%s bed %s loops" % [profile_name, (bed as Dictionary)["set"]])


func test_every_place_sounds_distinct() -> void:
	var seen: Dictionary = {}
	for place: String in ["forest", "town", "gainlands", "dna", "buffet", "heap", "capital_out", "capital_in"]:
		var profile: Dictionary = AmbienceProfiles.resolved(place)
		var first_bed: String = str(((profile["beds"] as Array)[0] as Dictionary)["set"])
		assert_false(seen.has(first_bed), "%s has its own bed (%s)" % [place, first_bed])
		seen[first_bed] = place


func test_every_surface_has_a_footstep() -> void:
	var bank: SfxBank = SfxBank.load_from()
	for surface: String in SURFACES:
		assert_true(bank.is_playable("step_" + surface), surface)
		assert_gte(bank.files(bank.layer_sets("step_" + surface)[0]).size(), 4, "%s has 4+ variants" % surface)


func test_zone_profiles() -> void:
	assert_eq(ZoneSoundscape.zone_profile("beefcake"), "gainlands")
	assert_eq(ZoneSoundscape.zone_profile("necrocrat"), "dna")
	assert_eq(ZoneSoundscape.zone_profile("gourmand"), "buffet")
	assert_eq(ZoneSoundscape.zone_profile("refusemancer"), "heap")


func test_capital_districts_follow_their_state() -> void:
	var flags: Dictionary = {}
	assert_eq(ZoneSoundscape.capital_profile("gate", false, flags), "capital_out")
	assert_eq(ZoneSoundscape.capital_profile("plaza", true, flags), "capital_in")
	assert_eq(ZoneSoundscape.capital_profile("grave", true, flags), "capital_grave_broken")
	flags[ZoneCompletion.flag_name("necrocrat")] = true
	assert_eq(ZoneSoundscape.capital_profile("grave", true, flags), "capital_grave_restored")
	assert_eq(ZoneSoundscape.capital_profile("reek", true, flags), "capital_reek_broken", "another district keeps its own state")
	for district: String in ["transit", "hungry", "grave", "reek"]:
		for state: String in ["broken", "restored"]:
			assert_true(AmbienceProfiles.has("capital_%s_%s" % [district, state]), "%s %s" % [district, state])


func test_the_dump_grows_eerier_toward_the_rotheart() -> void:
	var near: Vector3 = Vector3(HeapLayout.ROTHEART.x, 0.0, HeapLayout.ROTHEART.y + 20.0)
	var middle: Vector3 = Vector3(HeapLayout.ROTHEART.x, 0.0, HeapLayout.ROTHEART.y + 50.0)
	var far: Vector3 = Vector3(HeapLayout.ROTHEART.x, 0.0, HeapLayout.ROTHEART.y + 100.0)
	assert_almost_eq(ZoneSoundscape.heap_corruption(near), 1.0, 0.001)
	assert_between(ZoneSoundscape.heap_corruption(middle), 0.1, 0.9)
	assert_almost_eq(ZoneSoundscape.heap_corruption(far), 0.0, 0.001)


func test_footsteps_land_on_the_walk_cycles_contacts() -> void:
	assert_true(WorldSprite._crossed(0.1, 0.13, 0.125))
	assert_false(WorldSprite._crossed(0.13, 0.2, 0.125))
	assert_true(WorldSprite._crossed(0.95, 0.15, 0.125), "a wrap past 1.0 still counts")
	assert_true(WorldSprite._crossed(0.6, 0.63, 0.625))


func test_area_surfaces_name_real_footsteps() -> void:
	var bank: SfxBank = SfxBank.load_from()
	var dna: DnaBuilder = DnaBuilder.new()
	var capital: CapitalBuilder = CapitalBuilder.new()
	var heap: HeapBuilder = HeapBuilder.new()
	var buffet: BuffetBuilder = BuffetBuilder.new()
	var gainlands: GainlandsBuilder = GainlandsBuilder.new()
	for layout_owner: Variant in [dna.layout, capital.layout, heap.layout, buffet.layout, gainlands.layout]:
		layout_owner.call("build")
	var found: Dictionary = {}
	for area: WalkableArea in [dna, capital, heap, buffet, gainlands]:
		for x: int in range(0, 120, 6):
			for z: int in range(-30, 130, 6):
				var surface: String = str(area.surface_at(Vector3(float(x), 0.0, float(z))))
				assert_true(bank.has_event("step_" + surface), "%s is a footstep" % surface)
				found[surface] = true
	for surface: String in ["carpet", "marble", "tile", "mashed", "junk", "ash", "cobble", "pastel", "wood"]:
		assert_true(found.has(surface), "%s appears somewhere" % surface)
