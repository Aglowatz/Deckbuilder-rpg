extends GutTest
## G-03 for the D.N.A., Endless Buffet, Verdant Dump (id "heap") and Capital hubs: every sign board carries one pictogram that was chosen on purpose,
## using a sign reads its old words, prop fronts carry icons instead of lettering, and the Dump is never called "Heap" where players see it.

const HUBS: Dictionary = {
	"res://scenes/dna_zone.tscn": "dna",
	"res://scenes/buffet_zone.tscn": "buffet",
	"res://scenes/heap_zone.tscn": "heap",
	"res://scenes/capital_zone.tscn": "capital",
}


func _signs(hub: String) -> Array:
	match hub:
		"dna":
			var dna: DnaLayout = DnaLayout.new()
			dna.build()
			return dna.signs
		"buffet":
			var buffet: BuffetLayout = BuffetLayout.new()
			buffet.build()
			return buffet.signs
		"heap":
			var heap: HeapLayout = HeapLayout.new()
			heap.build()
			return heap.signs
	var capital: CapitalLayout = CapitalLayout.new()
	capital.build()
	return capital.signs


func _icons(hub: String) -> Dictionary:
	match hub:
		"dna":
			return DnaBuilder.SIGN_ICONS
		"buffet":
			return BuffetBuilder.SIGN_ICONS
		"heap":
			return HeapBuilder.SIGN_ICONS
	return CapitalBuilder.SIGN_ICONS


func test_every_hub_sign_is_mapped_to_an_existing_icon() -> void:
	for hub: String in ["dna", "buffet", "heap", "capital"]:
		var signs: Array = _signs(hub)
		assert_gt(signs.size(), 5 if hub == "gainlands" else 20, "%s has its signs (the Gainlands keeps 8 after the corrective pass)" % hub)
		var icons: Dictionary = _icons(hub)
		var story: ZoneStoryText = ZoneStoryText.shared() if hub == "dna" else null
		for sign: Object in signs:
			var key: String = str(sign.get("key"))
			assert_true(icons.has(key), "%s: %s is mapped on purpose (not the fallback)" % [hub, key])
			assert_true(IconArt.has(str(icons.get(key, ""))), "%s: %s names an icon that exists" % [hub, key])
			if story != null:
				assert_false(story.get_lines(key).is_empty(), "dna: %s still has words to read" % key)


func test_capital_banners_carry_the_ruler_emblem() -> void:
	var banners: int = 0
	for sign: CapitalLayout.Sign in _signs("capital"):
		if sign.style == "banner" and not sign.key.begins_with("sign.crease"):
			banners += 1
			assert_eq(CapitalBuilder.sign_icon(sign.key), RulerPresence.EMBLEM_ICON, "%s is one of Primm's banners" % sign.key)
	assert_gte(banners, 8)
	var statue: Node3D = CapitalProps.statue(1.0, false)
	add_child_autofree(statue)
	assert_eq(statue.find_children(IconSign.NODE_NAME, "MeshInstance3D", true, false).size(), 1, "the statue plinth carries the emblem")


func test_each_hub_builds_with_pictograms_only_and_every_sign_is_readable() -> void:
	for path: String in HUBS.keys():
		Session.new_game()
		var scene: ZoneScene = (load(path) as PackedScene).instantiate() as ZoneScene
		scene.call("screenshot_prepare", {"nohud": "true"})
		add_child(scene)
		await get_tree().process_frame
		var hub: String = str(HUBS[path])
		var expected: int = _signs(hub).size()
		var root: Node = scene.builder.get("root") as Node
		assert_not_null(root, "%s: builder root" % hub)
		if root != null:
			assert_eq(root.find_children("*", "Label3D", true, false).size(), 0, "%s: no lettering anywhere in the built hub" % hub)
			assert_gte(root.find_children(IconSign.NODE_NAME, "MeshInstance3D", true, false).size(), expected, "%s: one pictogram per sign (plus prop fronts)" % hub)
		var readable: int = 0
		for spot: ZoneSpot in scene.spots:
			if spot.kind == "sign":
				readable += 1
				assert_false(scene.story.get_lines(str(spot.data["key"])).is_empty(), "%s: %s reads something" % [hub, str(spot.data["key"])])
		assert_eq(readable, expected, "%s: every sign can be read by using it" % hub)
		scene.queue_free()
		await get_tree().process_frame


func test_the_rift_stations_show_an_icon_not_a_title() -> void:
	assert_true(FastTravelStation.new().icon_sign, "zones and the starting area use the icon board too")


func test_players_see_the_verdant_dump_not_heap() -> void:
	assert_eq(HeapZone.DISPLAY_NAME, "The Verdant Dump")
	var story: ZoneStoryText = ZoneStoryText.for_zone(HeapZone.ID)
	for key: Variant in story.lines.keys():
		for line: Variant in story.lines[key] as Array:
			var text: String = str(line)
			assert_false(text.contains("Verdant Heap"), "%s says Verdant Heap" % str(key))
			assert_false(text.contains("the Heap") or text.contains("The Heap"), "%s calls the zone the Heap" % str(key))


func test_a_sign_never_steals_the_e_from_the_spot_beside_it() -> void:
	# The Buffet's soup-fountain sign stands next to the fountain itself: E must ladle soup, not read the sign.
	Session.new_game()
	var scene: ZoneScene = (load("res://scenes/buffet_zone.tscn") as PackedScene).instantiate() as ZoneScene
	scene.call("screenshot_prepare", {"nohud": "true"})
	add_child_autofree(scene)
	await get_tree().process_frame
	var fountain: ZoneSpot = null
	for spot: ZoneSpot in scene.spots:
		if spot.id == "soup_fountain":
			fountain = spot
	assert_not_null(fountain, "the soup fountain spot exists")
	if fountain == null:
		return
	assert_eq(scene._nearest_spot(fountain.position + Vector3(0.0, 0.0, 0.6)), fountain, "the fountain wins over its sign")
	var at_sign: ZoneSpot = scene._nearest_spot(Vector3(47.6, 0.0, 67.0))  # right at the fountain sign (BuffetLayout "sign.fountain")
	assert_not_null(at_sign, "something is in reach at the sign")
	var far_sign: ZoneSpot = null
	for spot: ZoneSpot in scene.spots:
		if spot.kind == "sign" and str(spot.data["key"]) == "sign.cheese_note":
			far_sign = spot
	assert_not_null(far_sign)
	if far_sign != null:
		assert_eq(scene._nearest_spot(far_sign.position), far_sign, "a sign on its own is still readable")
