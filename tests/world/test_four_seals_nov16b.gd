extends GutTest
## Fable Nov 16b (Part 4): the Four Seals in Crosspath - a small cellar door in a grassy bank, built from the town's painted materials
## (no purple box, no colour lights); four round iron seals that show a padlock until their zone's lever is pulled and then turn to the
## Path's icon the next time the hero sees the vault; the doors ajar with all four, wide open once the Warden is beaten; the gold-framed
## "A seal turns in Crosspath" toast; the map icon.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _vault() -> Node3D:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	return FourSealVault.build(holder, Vector3.ZERO)


func _seal(vault: Node3D, zone_id: String) -> Node3D:
	return vault.find_child(FourSealVault.SEAL_PREFIX + zone_id, true, false) as Node3D


func test_it_is_a_small_cellar_door_of_the_town_s_materials() -> void:
	var vault: Node3D = _vault()
	var box: AABB = AABB()
	var first: bool = true
	var names: Dictionary = {}
	for node: Node in vault.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh.get_parent().name == "AppleTree" or mesh.get_parent().get_parent().name == "AppleTree":
			continue
		for surface: int in range(mesh.mesh.get_surface_count()):
			var material: Material = mesh.get_active_material(surface)
			assert_not_null(material, "%s surface %d has a material" % [mesh.name, surface])
			if material is StandardMaterial3D:
				assert_not_null((material as StandardMaterial3D).albedo_texture, "%s surface %d is a painted material, not a flat colour" % [mesh.name, surface])
				names[(material as StandardMaterial3D).resource_name] = true
				var tint: Color = (material as StandardMaterial3D).albedo_color
				assert_false(tint.b > tint.r * 1.25 and tint.b > tint.g * 1.25, "%s is not purple or blue (%s)" % [mesh.name, tint])
		if mesh.name == "Planks" or mesh.name == "Cellar":
			var part: AABB = mesh.transform * mesh.get_aabb() if mesh.name == "Cellar" else AABB(mesh.get_parent().position, Vector3(0.1, FourSealVault.DOOR_HEIGHT, 0.1))
			box = part if first else box.merge(part)
			first = false
	for id: String in ["ENV-WALL-FOUNDATION", "ENV-WALL-PLANK", "ENV-BEAM", "ENV-HEDGE", "ENV-GROUND-GRASS-CALM"]:
		assert_true(names.has(id), "built with %s" % id)
	assert_lt(FourSealVault.DOOR_HEIGHT, 2.0, "a low cellar door (the old door was 3.2 m in a 4.7 m frame)")
	assert_lt(box.end.y, 3.0, "nothing of it stands taller than three metres above the ground (the old frame: 4.75 m)")
	assert_eq(vault.find_children("Light_*", "OmniLight3D", true, false).size(), 0, "no colour light per seal")
	var glow: OmniLight3D = vault.get_node(FourSealVault.GLOW_NODE) as OmniLight3D
	assert_gt(glow.light_color.r, glow.light_color.b + 0.3, "the one light is warm lamplight")
	assert_eq(glow.light_energy, 0.0, "and it is off while the doors are shut")
	assert_not_null(vault.get_node_or_null("AppleTree"), "an apple tree stands half in front")


func test_four_iron_seals_show_a_padlock_while_locked() -> void:
	var vault: Node3D = _vault()
	for zone_id: String in VaultGuardian.ZONE_IDS:
		var seal: Node3D = _seal(vault, zone_id)
		assert_not_null(seal, zone_id)
		assert_eq(str(seal.get_meta(&"icon")), "ICON-PADLOCK")
		assert_false(bool(seal.get_meta(&"open")))
		var face: Sprite3D = seal.get_node("Face") as Sprite3D
		assert_eq(face.texture, IconArt.texture("ICON-PADLOCK", 128.0), "the face is the padlock picture")
		assert_true(seal.get_parent().name.begins_with("Leaf"), "the seal sits on a door leaf")
	var first_face: Sprite3D = _seal(vault, VaultGuardian.ZONE_IDS[0]).get_node("Face") as Sprite3D
	for zone_id: String in VaultGuardian.ZONE_IDS:
		var face: Sprite3D = _seal(vault, zone_id).get_node("Face") as Sprite3D
		assert_eq(face.modulate, first_face.modulate, "no colour light: every padlock is the same dimmed iron")


## Fable Nov 16c (the owner's answer to inbox 19): the fixed Path order, clockwise from the top - arm, chef's hat, leaf, skull.
func test_the_seals_sit_in_the_path_order_clockwise_from_the_top() -> void:
	assert_eq(VaultGuardian.ZONE_IDS, ["beefcake", "gourmand", "refusemancer", "necrocrat"] as Array[String])
	var vault: Node3D = _vault()
	var at: Dictionary = {}
	for zone_id: String in VaultGuardian.ZONE_IDS:
		at[zone_id] = _seal(vault, zone_id).global_position - vault.global_position
	var top: Vector3 = at["beefcake"]
	var right: Vector3 = at["gourmand"]
	var bottom: Vector3 = at["refusemancer"]
	var left: Vector3 = at["necrocrat"]
	assert_gt(top.y, right.y + 0.3, "the arm is at the top")
	assert_gt(top.y, left.y + 0.3)
	assert_lt(bottom.y, right.y - 0.3, "the leaf is at the bottom")
	assert_gt(right.x, top.x + 0.3, "the chef's hat is on the right (the doors face the player)")
	assert_lt(left.x, top.x - 0.3, "the skull is on the left")
	assert_almost_eq(top.x, bottom.x, 0.02)
	assert_almost_eq(left.y, right.y, 0.02)
	for a: String in at.keys():
		for b: String in at.keys():
			if a < b:
				assert_gt((at[a] as Vector3).distance_to(at[b] as Vector3), FourSealVault.SEAL_RADIUS * 2.0 + 0.05, "%s and %s do not touch" % [a, b])
		assert_between((at[a] as Vector3).y, 0.3, FourSealVault.DOOR_HEIGHT - 0.1, "%s is on the door" % a)
		assert_lt(absf((at[a] as Vector3).x), FourSealVault.DOOR_WIDTH * 0.5 - FourSealVault.SEAL_RADIUS + 0.02)


func test_a_locked_seal_shows_a_faint_outline_of_its_path_icon_behind_the_padlock() -> void:
	var vault: Node3D = _vault()
	for zone_id: String in VaultGuardian.ZONE_IDS:
		var seal: Node3D = _seal(vault, zone_id)
		var ghost: MeshInstance3D = seal.get_node_or_null("Ghost") as MeshInstance3D
		assert_not_null(ghost, zone_id)
		assert_true(ghost.visible, "%s: the outline shows while locked" % zone_id)
		assert_eq(str(ghost.get_meta(&"icon")), IconArt.energy_id(ZoneEffects.path_of(zone_id)), "%s: its own Path's icon" % zone_id)
		var face: Sprite3D = seal.get_node("Face") as Sprite3D
		assert_lt(ghost.position.z, face.position.z, "the outline lies behind the padlock")
		assert_gt((ghost.mesh as QuadMesh).size.x, float(face.texture.get_width()) * face.pixel_size + 0.1, "and reaches out round it")
		assert_true(ghost.material_override is ShaderMaterial)
	# Four different outlines.
	var icons: Dictionary = {}
	for zone_id: String in VaultGuardian.ZONE_IDS:
		icons[str(_seal(vault, zone_id).get_node("Ghost").get_meta(&"icon"))] = true
	assert_eq(icons.size(), 4)
	# Once it turns, the full icon shows and the outline is gone.
	Session.pull_vault_lever("gourmand")
	FourSealVault.reveal(vault, true)
	var turned: Node3D = _seal(vault, "gourmand")
	assert_false((turned.get_node("Ghost") as Node3D).visible)
	var full: Sprite3D = turned.get_node("Face") as Sprite3D
	assert_eq(full.texture, IconArt.texture(IconArt.energy_id(Affinity.Type.GOURMAND), 128.0))
	assert_eq(full.modulate, Color.WHITE, "in full colour")
	assert_true((_seal(vault, "beefcake").get_node("Ghost") as Node3D).visible, "the others keep theirs")


func test_the_seal_tooltips_name_the_path_and_the_state() -> void:
	assert_eq(FourSealVault.tooltip("gourmand"), "Gourmand seal: locked")
	assert_eq(FourSealVault.tooltip("beefcake"), "Beefcake seal: locked")
	Session.pull_vault_lever("gourmand")
	assert_eq(FourSealVault.tooltip("gourmand"), "Gourmand seal: locked", "pulled far away, not yet seen to turn")
	var vault: Node3D = _vault()
	FourSealVault.reveal(vault, true)
	assert_eq(FourSealVault.tooltip("gourmand"), "Gourmand seal: turned")
	var lines: PackedStringArray = SealTooltips.all_lines().split("\n")
	assert_eq(lines.size(), 4)
	assert_true(lines[0].begins_with("Beefcake"), "the fixed Path order")
	assert_true(lines[1].begins_with("Gourmand"))
	assert_true(lines[2].begins_with("Refusemancer"))
	assert_true(lines[3].begins_with("Necrocrat"))
	# The hero at the door sees all four lines; far away, nothing.
	var hero: Node3D = Node3D.new()
	add_child_autofree(hero)
	var camera: Camera3D = Camera3D.new()
	add_child_autofree(camera)
	camera.global_position = vault.global_position + Vector3(0.0, 4.0, 9.0)
	camera.look_at(vault.global_position + Vector3(0.0, 1.0, 0.0))
	camera.current = true
	var tips: SealTooltips = SealTooltips.install(self, vault, hero)
	autofree(tips.get_parent())
	await wait_process_frames(2)
	hero.global_position = vault.global_position + Vector3(0.5, 0.0, 2.0)
	tips._process(0.0)
	if tips.seal_at(camera, get_viewport().get_mouse_position()).is_empty():
		assert_eq(tips.showing, "all")
		assert_string_contains((tips.find_child("Text", true, false) as Label).text, "Necrocrat seal: locked")
	hero.global_position = vault.global_position + Vector3(0.0, 0.0, 30.0)
	tips._process(0.0)
	if tips.seal_at(camera, get_viewport().get_mouse_position()).is_empty():
		assert_eq(tips.showing, "")
	# The mouse over a seal picks that seal.
	var seal: Node3D = _seal(vault, "refusemancer")
	assert_eq(tips.seal_at(camera, camera.unproject_position(seal.global_position)), "refusemancer")
	assert_eq(tips.seal_at(camera, camera.unproject_position(seal.global_position) + Vector2(400, 0)), "")


func test_a_pulled_lever_turns_its_seal_the_next_time_the_hero_sees_the_vault() -> void:
	var vault: Node3D = _vault()
	Session.pull_vault_lever("gourmand")
	FourSealVault.refresh(vault)
	assert_false(bool(_seal(vault, "gourmand").get_meta(&"open")), "pulled far away: the seal has not turned yet")
	assert_eq(FourSealVault.pending(), ["gourmand"] as Array[String])
	assert_eq(FourSealVault.open_count(), 0)
	assert_false(FourSealVault.should_reveal(vault, vault.global_position + Vector3(30.0, 0.0, 0.0)), "not while the hero is far off")
	assert_true(FourSealVault.should_reveal(vault, vault.global_position + Vector3(0.0, 0.0, 5.0)), "it turns when the hero comes near")
	FourSealVault.reveal(vault, true)
	var seal: Node3D = _seal(vault, "gourmand")
	assert_true(bool(seal.get_meta(&"open")))
	assert_eq(str(seal.get_meta(&"icon")), IconArt.energy_id(Affinity.Type.GOURMAND), "it shows the Gourmand Path's icon")
	assert_eq((seal.get_node("Face") as Sprite3D).texture, IconArt.texture(IconArt.energy_id(Affinity.Type.GOURMAND), 128.0))
	assert_true(Session.flag(FourSealVault.seen_flag("gourmand")), "and that is remembered")
	assert_true(FourSealVault.pending().is_empty())
	assert_false(FourSealVault.should_reveal(vault, vault.global_position), "it does not turn twice")
	for zone_id: String in ["beefcake", "refusemancer", "necrocrat"]:
		assert_eq(str(_seal(vault, zone_id).get_meta(&"icon")), "ICON-PADLOCK", "%s is still locked" % zone_id)
	# A vault built later from the same save shows it turned at once.
	var again: Node3D = _vault()
	assert_true(bool(_seal(again, "gourmand").get_meta(&"open")))


func test_each_seal_shows_its_own_path() -> void:
	var vault: Node3D = _vault()
	var icons: Dictionary = {}
	for zone_id: String in VaultGuardian.ZONE_IDS:
		Session.pull_vault_lever(zone_id)
	FourSealVault.reveal(vault, true)
	for zone_id: String in VaultGuardian.ZONE_IDS:
		var icon: String = str(_seal(vault, zone_id).get_meta(&"icon"))
		assert_eq(icon, IconArt.energy_id(ZoneEffects.path_of(zone_id)))
		assert_true(IconArt.has(icon), "%s is a real icon" % icon)
		icons[icon] = true
	assert_eq(icons.size(), 4, "four different Path icons")


func test_the_doors_stand_ajar_with_all_four_and_open_once_the_warden_is_beaten() -> void:
	var vault: Node3D = _vault()
	var left: Node3D = vault.get_node(FourSealVault.LEAF_LEFT) as Node3D
	var right: Node3D = vault.get_node(FourSealVault.LEAF_RIGHT) as Node3D
	assert_almost_eq(left.rotation.y, 0.0, 0.001, "shut")
	for zone_id: String in ["beefcake", "gourmand", "refusemancer"]:
		Session.pull_vault_lever(zone_id)
	FourSealVault.reveal(vault, true)
	assert_almost_eq(left.rotation.y, 0.0, 0.001, "three of four: still shut")
	Session.pull_vault_lever("necrocrat")
	FourSealVault.reveal(vault, true)
	assert_almost_eq(absf(rad_to_deg(left.rotation.y)), FourSealVault.AJAR_DEGREES, 0.01, "all four: the doors come ajar")
	assert_almost_eq(left.rotation.y, -right.rotation.y, 0.001, "the two leaves swing apart")
	assert_gt((vault.get_node(FourSealVault.GLOW_NODE) as OmniLight3D).light_energy, 0.5, "light falls out of the gap")
	Session.set_flag(VaultGuardian.FLAG_DEFEATED)
	FourSealVault.refresh(vault)
	assert_almost_eq(absf(rad_to_deg(left.rotation.y)), FourSealVault.OPEN_DEGREES, 0.01, "the Warden beaten: wide open")
	assert_eq((vault.get_node(FourSealVault.GLOW_NODE) as OmniLight3D).light_energy, 0.0)


func test_the_toast_says_a_seal_turns_in_crosspath() -> void:
	var layer: Control = Control.new()
	layer.size = Vector2(1920, 1080)
	add_child_autofree(layer)
	Session.pull_vault_lever("beefcake")
	Session.pull_vault_lever("necrocrat")
	var toast: SealToast = SealToast.show_on(layer, "necrocrat", 2)
	await wait_process_frames(3)
	assert_eq((toast.find_child("Title", true, false) as Label).text, "A seal turns in Crosspath")
	assert_eq((toast.find_child("Count", true, false) as Label).text, "2 of 4")
	assert_false((toast.find_child("Line", true, false) as Label).text.is_empty())
	assert_lt((toast.find_child("Line", true, false) as Label).text.length(), 80, "one line")
	var icon: TextureRect = toast.find_child("PathIcon", true, false) as TextureRect
	assert_not_null(icon, "the Path's icon")
	assert_eq(icon.texture, IconArt.texture(IconArt.energy_id(Affinity.Type.NECROCRAT), 84.0))
	assert_eq(toast.find_children("Pip*", "TextureRect", true, false).size(), 4)
	assert_true(toast.find_child("Panel", true, false).has_theme_stylebox_override("panel"), "a framed panel")
	assert_almost_eq(toast.seconds_left(), SealToast.SECONDS, 0.5, "about six seconds")
	assert_between(SealToast.SECONDS, 5.0, 7.0)
	# A click dismisses it.
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	(toast.find_child("Panel", true, false) as Control).gui_input.emit(click)
	await wait_seconds(0.5)
	assert_false(is_instance_valid(toast), "gone after the click")
	assert_string_contains(SealToast.line_for(4), "last")
	assert_eq(SealToast.count_text(4), "4 of 4")
	# A second toast replaces the first.
	var first: SealToast = SealToast.show_on(layer, "beefcake", 1)
	var second: SealToast = SealToast.show_on(layer, "gourmand", 2)
	await wait_process_frames(2)
	assert_false(is_instance_valid(first))
	assert_true(is_instance_valid(second))


func test_it_times_out_after_six_seconds() -> void:
	var layer: Control = Control.new()
	add_child_autofree(layer)
	var toast: SealToast = SealToast.show_on(layer, "beefcake", 1)
	await wait_process_frames(2)
	toast._process(SealToast.SECONDS + 0.1)
	await wait_seconds(0.5)
	assert_false(is_instance_valid(toast))


func test_the_cellar_is_solid_and_the_way_in_is_open() -> void:
	var town: TownBuilder = TownBuilder.new()
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	town.build(parent, false)
	var mouth: Vector3 = town.anchors["vault4_mouth"] as Vector3
	var spot: Vector3 = town.anchors["vault4"] as Vector3
	assert_true(town.is_walkable(spot, 0.3), "the hero can stand in front of the doors")
	assert_true(town.is_walkable(spot + Vector3(1.0, 0.0, 2.0), 0.3), "and come up the stepping stones")
	assert_false(town.is_walkable(mouth + Vector3(0.0, 0.0, -0.2), 0.3), "not through the doors")
	assert_false(town.is_walkable(mouth + Vector3(0.0, 0.0, -3.0), 0.3), "not through the bank")
	assert_false(town.is_walkable(mouth + Vector3(-2.5, 0.0, 1.5), 0.3), "not through the hedge")
