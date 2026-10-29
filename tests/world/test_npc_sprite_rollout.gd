extends GutTest
## The NPC sprite rollout (docs/art/world_rollout.md): every list NPC with a world sprite set maps to its painted set, the ones without keep their 3D model, thrower and
## portal ripper entries reuse Big Hurl and Rip Tearson, the ghosts float translucent, the Capital's citizens stroll on walkable ground, and plates sit above each figure.


func _list_rows() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/npcs/npcs.json")) as Array


func test_every_npc_with_a_sprite_set_maps_to_an_imported_character() -> void:
	var checked: int = 0
	for row: Variant in _list_rows():
		var entry: Dictionary = row as Dictionary
		var set_name: String = str(entry.get("sprite_set", ""))
		var id: String = str(entry["id"])
		if set_name.begins_with("Stationary") or set_name.begins_with("Wanderer") or set_name.begins_with("Done"):
			if id == NpcRegistry.PLAYER_ID:
				continue
			var character: String = NpcSprites.character_for(id)
			assert_ne(character, "", "%s (%s) has an imported sprite set" % [id, set_name])
			if character != "":
				assert_true(SpriteLibrary.info(character).get("dirs", []).has("FRONT"), "%s has a front view" % character)
				checked += 1
		elif set_name.begins_with("None"):
			# the Doppelganger wears Escoffina's look in the Buffet (a disguise); Primm stands in the Crease after his fall (SPR-PRIMM, art import Oct 29)
			if id != "NPC-DOPPEL" and id != "NPC-PRIMM":
				assert_eq(NpcSprites.character_for(id), "", "%s is dungeon / battle only: no world sprite" % id)
	assert_gt(checked, 40, "the whole list was checked")


func test_special_mappings() -> void:
	assert_eq(NpcSprites.character_for("NPC-ROLLO"), "GUS", "Rollo Spokes was Gus")
	assert_eq(NpcSprites.character_for("NPC-DOPPEL"), "ESCOFFINA", "the Doppelganger is disguised as the Grand Chef")
	assert_eq(NpcSprites.character_for("NPC-ELOWEN"), "ELOWEN", "Elowen has her own sprite set since the art import of Oct 20")
	assert_eq(NpcSprites.character_for("NPC-PLAYER"), "")


func test_throwers_and_portal_rippers_reuse_hurl_and_rip() -> void:
	var def: ZoneDef = ZoneDefs.get_def(GainlandsZone.ID)
	var throwers: int = 0
	var rippers: int = 0
	for entry: Dictionary in def.npcs:
		var id: String = str(entry["id"])
		if id.begins_with("thrower"):
			assert_eq(NpcSprites.character_for_entry(entry), "HURL", id)
			throwers += 1
		elif id.begins_with("ripper"):
			assert_eq(NpcSprites.character_for_entry(entry), "RIP", id)
			rippers += 1
	assert_gt(throwers, 0)
	assert_gt(rippers, 0)


func test_the_ghosts_are_translucent_and_float() -> void:
	var camera: Camera3D = Camera3D.new()
	add_child_autofree(camera)
	camera.current = true
	camera.position = Vector3(0.0, 2.0, 6.0)
	for character: String in ["ECTOMUND", "KYLE", "GERALD", "AGNES"]:
		var actor: SpriteActor = NpcSprites.make_actor(character)
		add_child_autofree(actor)
		await get_tree().process_frame
		await get_tree().process_frame
		assert_lt(float(NpcSprites.ghost_style(character)["alpha"]), 0.9, character)
		assert_gt(actor.sprite.head_height(), actor.sprite.world_height, "%s floats above the ground" % character)
		assert_gt(actor.sprite.position.y, 0.05, "%s hovers" % character)
	var living: SpriteActor = NpcSprites.make_actor("ELDER")
	add_child_autofree(living)
	await get_tree().process_frame
	assert_almost_eq(living.sprite.head_height(), living.sprite.world_height, 0.001)


func test_plates_sit_above_the_figure_at_its_relative_height() -> void:
	var tall: SpriteActor = NpcSprites.make_actor("HURL")
	var small: SpriteActor = NpcSprites.make_actor("THREADWELL")
	add_child_autofree(tall)
	add_child_autofree(small)
	await get_tree().process_frame
	assert_almost_eq(tall.sprite.world_height, 1.6 * WorldSprite.PLAYER_HEIGHT, 0.001)
	assert_almost_eq(small.sprite.world_height, 0.45 * WorldSprite.PLAYER_HEIGHT, 0.001)
	assert_gt(NpcSprites.label_height(tall, 1.9), NpcSprites.label_height(small, 1.9) + 1.0)
	assert_eq(NpcSprites.label_height(Node3D.new(), 1.9), 1.9, "a 3D model keeps the default")


func test_a_stroller_wanders_and_stays_on_walkable_ground() -> void:
	var stroller: SpriteStroller = SpriteStroller.new()
	stroller.character = "CITIZEN"
	add_child_autofree(stroller)
	var inside: Callable = func(p: Vector3) -> bool: return Vector2(p.x, p.z).length() < 4.5
	stroller.setup(Vector3(1.0, 0.0, 0.0), inside, 7)
	var start: Vector3 = stroller.world_position()
	var farthest: float = 0.0
	for frame: int in range(1800):
		stroller.tick(1.0 / 60.0, Vector3(50.0, 0.0, 50.0))
		var p: Vector3 = stroller.world_position()
		assert_true(inside.call(p), "always on the ground")
		farthest = maxf(farthest, p.distance_to(start))
	assert_gt(farthest, 0.8, "they walked somewhere in half a minute")
	stroller.frozen = true
	var held: Vector3 = stroller.world_position()
	for frame: int in range(120):
		stroller.tick(1.0 / 60.0, Vector3(50.0, 0.0, 50.0))
	assert_eq(stroller.world_position(), held, "frozen while the hero talks to them")


func test_the_capital_citizens_wander_with_their_own_tints() -> void:
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	var citizens: int = 0
	for entry: Dictionary in def.npcs:
		if bool(entry.get("facade", false)):
			assert_true(bool(entry.get("wander", false)), str(entry["id"]))
			assert_eq(NpcSprites.character_for_entry(entry), "CITIZEN")
			citizens += 1
	assert_eq(citizens, 9)
	assert_eq(NpcSprites.CITIZEN_TINTS.size(), 9)
