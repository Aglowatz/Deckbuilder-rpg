extends GutTest
## Brief 6, Part C: fog of war reveal and persistence, per-zone fog, and the rule that secrets
## (hidden chests and friends) never appear on a map.

const AREA: Rect2 = Rect2(0.0, 0.0, 40.0, 30.0)


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_everything_starts_hidden() -> void:
	var fog: FogOfWar = FogOfWar.for_bounds(AREA)
	assert_eq(fog.revealed_count(), 0)
	assert_false(fog.is_revealed(Vector2(10, 10)))


func test_reveal_marks_a_disc_around_the_player() -> void:
	var fog: FogOfWar = FogOfWar.for_bounds(AREA)
	var fresh: Array[Vector2i] = fog.reveal(Vector2(20, 15), 5.0)
	assert_gt(fresh.size(), 60, "a radius-5 disc is ~78 cells")
	assert_true(fog.is_revealed(Vector2(20, 15)))
	assert_true(fog.is_revealed(Vector2(23, 15)))
	assert_false(fog.is_revealed(Vector2(30, 15)), "far cells stay fogged")
	assert_eq(fog.reveal(Vector2(20, 15), 5.0).size(), 0, "revealing again finds nothing new")


func test_reveal_near_the_edge_does_not_crash_or_leak() -> void:
	var fog: FogOfWar = FogOfWar.for_bounds(AREA)
	fog.reveal(Vector2(0.5, 0.5), 7.0)
	fog.reveal(Vector2(39.5, 29.5), 7.0)
	assert_true(fog.is_revealed(Vector2(0.5, 0.5)))
	assert_false(fog.is_revealed(Vector2(-3, -3)), "outside the map is never revealed")


func test_fog_round_trips_through_a_dictionary() -> void:
	var fog: FogOfWar = FogOfWar.for_bounds(AREA)
	fog.reveal(Vector2(12, 12), 6.0)
	var restored: FogOfWar = FogOfWar.from_dict(fog.to_dict(), AREA)
	assert_eq(restored.revealed_count(), fog.revealed_count())
	assert_true(restored.is_revealed(Vector2(12, 12)))
	assert_false(restored.is_revealed(Vector2(30, 25)))


func test_fog_survives_a_map_resize() -> void:
	var fog: FogOfWar = FogOfWar.for_bounds(AREA)
	fog.reveal(Vector2(12, 12), 4.0)
	var bigger: FogOfWar = FogOfWar.from_dict(fog.to_dict(), Rect2(-10.0, -10.0, 80.0, 60.0))
	assert_true(bigger.is_revealed(Vector2(12, 12)), "revealed cells keep their world position")
	assert_eq(bigger.revealed_count(), fog.revealed_count())


func test_revealed_areas_persist_in_the_save_per_zone() -> void:
	var dna: FogOfWar = Session.fog_for(DnaZone.ID, AREA)
	dna.reveal(Vector2(10, 10), 6.0)
	var gain: FogOfWar = Session.fog_for(GainlandsZone.ID, AREA)
	gain.reveal(Vector2(30, 20), 4.0)
	var dna_count: int = dna.revealed_count()
	var gain_count: int = gain.revealed_count()
	assert_ne(dna_count, gain_count)
	var data: Dictionary = Session.to_dict()
	Session.new_game()
	assert_true(Session.map_fog.is_empty(), "a new game starts with no fog saved")
	assert_true(Session.from_dict(data))
	var dna_again: FogOfWar = Session.fog_for(DnaZone.ID, AREA)
	var gain_again: FogOfWar = Session.fog_for(GainlandsZone.ID, AREA)
	assert_eq(dna_again.revealed_count(), dna_count, "the D.N.A. kept its own reveal")
	assert_eq(gain_again.revealed_count(), gain_count, "the Gainlands kept its own reveal")
	assert_true(dna_again.is_revealed(Vector2(10, 10)))
	assert_false(dna_again.is_revealed(Vector2(30, 20)), "zones do not share fog")
	assert_true(gain_again.is_revealed(Vector2(30, 20)))


func test_pois_only_show_on_revealed_ground() -> void:
	var fog: FogOfWar = FogOfWar.for_bounds(AREA)
	var near: MapPoi = MapPoi.make(MapPoi.Kind.VENDOR, Vector3(20, 0, 15), "near")
	var far: MapPoi = MapPoi.make(MapPoi.Kind.HEAL, Vector3(35, 0, 25), "far")
	var pois: Array[MapPoi] = [near, far]
	assert_eq(MapView.visible_pois(pois, fog).size(), 0, "nothing before exploring")
	fog.reveal(Vector2(20, 15), 5.0)
	var shown: Array[MapPoi] = MapView.visible_pois(pois, fog)
	assert_eq(shown, [near] as Array[MapPoi])
	assert_eq(MapView.legend_kinds(shown), [MapPoi.Kind.VENDOR] as Array[MapPoi.Kind])


func test_there_is_no_poi_kind_for_secrets() -> void:
	for kind_name: String in MapPoi.Kind.keys():
		var lower: String = kind_name.to_lower()
		assert_false(lower.contains("chest") or lower.contains("secret") or lower.contains("stash"), kind_name)


func test_zone_defs_never_list_a_secret_as_a_poi() -> void:
	for zone_id: String in ZoneDefs.ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		for spot_id: String in def.poi_kinds.keys():
			assert_false(spot_id.begins_with("chest") or spot_id.contains("secret"), "%s: %s" % [zone_id, spot_id])
			assert_false(def.spot_def(spot_id).is_empty(), "%s: POI %s must be a real spot" % [zone_id, spot_id])
		for spot: Dictionary in def.spots:
			assert_false(str(spot["id"]).begins_with("chest"), "chests are not spots")


func test_d_n_a_chest_positions_are_never_poi_positions() -> void:
	var layout: DnaLayout = DnaLayout.new()
	layout.build()
	var def: ZoneDef = ZoneDefs.get_def(DnaZone.ID)
	for spot_id: String in def.poi_kinds.keys():
		var spot: Dictionary = def.spot_def(spot_id)
		var pos: Vector3 = (layout.anchors.get(str(spot["anchor"]), Vector3.ZERO) as Vector3) + (spot["offset"] as Vector3)
		for chest_id: String in layout.chests.keys():
			var chest: Vector3 = layout.chests[chest_id] as Vector3
			assert_gt(Vector2(pos.x - chest.x, pos.z - chest.z).length(), 0.4, "%s is not drawn on top of %s" % [spot_id, chest_id])


func test_town_poi_whitelist_has_no_secrets() -> void:
	for secret_id: String in ["chest", "lever", "vault", "hidden_vendor", "dev_shrine", "tunnel"]:
		assert_false(TownScene.POI_KINDS.has(secret_id), secret_id)
