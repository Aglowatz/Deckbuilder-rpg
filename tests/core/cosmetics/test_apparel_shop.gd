extends GutTest
## Apparel Part 3: every cosmetic whose worn art exists can be bought (the four cloaks since Part 1), the found pieces arrive owned, every hat/cloak combination can
## be worn and is saved, and the cloak dye only shows on the plain hooded cloak.

const CLOAK_IDS: Array[String] = ["cloak_patchwork", "cloak_red_cape", "cloak_tattered", "cloak_royal"]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()


func after_each() -> void:
	Session.save_enabled = false
	SpriteLibrary.reset()


## Level 5, every zone freed and Primm beaten: every shop item is open.
func _open_everything() -> void:
	Session.profile.level = 5
	for zone_id: String in ZoneDefs.ids():
		Session.flags[str(ZoneCompletion.flag_name(zone_id))] = true
	Session.profile.postgame_unlocked = true


func test_every_cloak_can_be_bought_once_it_opens() -> void:
	_open_everything()
	Session.gold = 5000
	var spent: int = 0
	for item_id: String in CLOAK_IDS:
		var item: CosmeticData = CosmeticCatalog.find(item_id)
		assert_true(SpriteCosmetics.art_ready(item), "%s has its art" % item_id)
		assert_true(CosmeticCatalog.vendor_stock(Session.unlock_state()).has(item), "%s is on the shelf" % item_id)
		assert_true(Session.buy_cosmetic(item_id), "%s can be bought" % item_id)
		spent += item.price
		assert_false(Session.buy_cosmetic(item_id), "%s only once" % item_id)
	assert_eq(Session.gold, 5000 - spent)


func test_a_locked_cloak_waits_for_its_unlock() -> void:
	Session.gold = 5000
	assert_false(Session.buy_cosmetic("cloak_royal"), "the Royal Mantle opens after Primm")
	assert_eq(Session.gold, 5000)


func test_every_item_with_art_is_for_sale_and_every_item_without_is_not() -> void:
	_open_everything()
	for item: CosmeticData in CosmeticCatalog.all():
		Session.gold = 5000
		assert_eq(Session.buy_cosmetic(item.id), SpriteCosmetics.art_ready(item), "%s: buyable exactly when its art exists" % item.id)


func test_the_found_pieces_arrive_owned() -> void:
	Session.grant_chest_reward(GainlandsZone.CHEST_REWARDS["chest_ground_0"] as Dictionary)
	assert_true(Session.cosmetics.owns("cloak_tattered"), "the Gainlands chest gives the Tattered Cloak")
	Session.grant_chest_reward(HeapZone.CHEST_REWARDS["chest_fridge"] as Dictionary)
	assert_true(Session.cosmetics.owns("hat_leaf_crown"), "the Verdant Dump chest gives the Crown of Leaves")
	assert_true(Session.grant_cosmetic("cloak_royal", true), "the Royal Mantle after Primm")
	assert_true(Session.cosmetics.owns("cloak_royal"))
	assert_eq(Session.cosmetics.cloak_id, "", "found pieces are owned, not put on")


func test_every_combination_is_worn_and_saved() -> void:
	for item: CosmeticData in CosmeticCatalog.all():
		Session.grant_cosmetic(item.id)
	var hats: Array[String] = [""]
	for item: CosmeticData in CosmeticCatalog.hats():
		hats.append(item.id)
	var cloaks: Array[String] = [""]
	for item: CosmeticData in CosmeticCatalog.cloaks():
		cloaks.append(item.id)
	var scene: Node3D = Node3D.new()
	add_child_autofree(scene)
	var camera: Camera3D = Camera3D.new()
	scene.add_child(camera)
	camera.position = Vector3(0.0, 1.5, 6.0)
	var sprite: WorldSprite = WorldSprite.new()
	scene.add_child(sprite)
	assert_true(sprite.setup("PLAYER", camera, Vector3(0.42, -0.62, -0.67)))
	for hat_id: String in hats:
		for cloak_id: String in cloaks:
			var look: CosmeticState = Session.cosmetics.duplicate_state()
			assert_true(look.equip(CosmeticData.Slot.HAT, hat_id))
			assert_true(look.equip(CosmeticData.Slot.CLOAK, cloak_id))
			Session.apply_look(look)
			SpriteCosmetics.apply(sprite, Session.cosmetics)
			var cloak_art: String = SpriteCosmetics.art_name(cloak_id)
			assert_eq(sprite.character, "PLAYER" if cloak_id == "" else "PLAYER_CLOAK_" + cloak_art, "%s + %s: the cloak set" % [hat_id, cloak_id])
			var saved: Dictionary = Session.to_dict()
			Session.cosmetics.hat_id = ""
			Session.cosmetics.cloak_id = ""
			assert_true(Session.from_dict(saved))
			assert_eq(Session.cosmetics.hat_id, hat_id, "the hat is saved")
			assert_eq(Session.cosmetics.cloak_id, cloak_id, "the cloak is saved")


func test_the_dye_only_colours_the_plain_cloak() -> void:
	var look: CosmeticState = CosmeticState.new()
	look.set_dye(CosmeticData.Slot.CLOAK, 3)
	assert_true(SpriteCosmetics.dye_applies(look), "the hooded cloak takes a dye")
	look.grant("cloak_red_cape")
	look.equip(CosmeticData.Slot.CLOAK, "cloak_red_cape")
	assert_false(SpriteCosmetics.dye_applies(look), "the red cape keeps its red")
	var scene: Node3D = Node3D.new()
	add_child_autofree(scene)
	var camera: Camera3D = Camera3D.new()
	scene.add_child(camera)
	var sprite: WorldSprite = WorldSprite.new()
	scene.add_child(sprite)
	sprite.setup("PLAYER", camera, Vector3(0.42, -0.62, -0.67))
	SpriteCosmetics.apply(sprite, look)
	var material: ShaderMaterial = sprite.get_child(0).material_override as ShaderMaterial
	assert_not_null(material)
	assert_almost_eq(float(material.get_shader_parameter("dye_amount")), 0.0, 0.001, "no recolour on a named cloak")
	assert_eq(look.cloak_dye, 3, "the dye choice is kept for when the plain cloak goes back on")
