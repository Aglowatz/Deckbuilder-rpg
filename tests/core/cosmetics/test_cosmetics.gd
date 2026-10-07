extends GutTest
## Hats, cloaks and dyes: the catalog, ownership and equipping, saving, vendor stock rules and the hero model.


func after_each() -> void:
	Session.save_enabled = false


func test_catalog_has_enough_variety() -> void:
	assert_gte(CosmeticCatalog.hats().size(), 10, "at least 10 hats")
	assert_gte(CosmeticCatalog.cloaks().size(), 8, "at least 8 cloaks")
	var ids: Dictionary = {}
	for item: CosmeticData in CosmeticCatalog.all():
		assert_false(ids.has(item.id), "%s is unique" % item.id)
		ids[item.id] = true
		assert_ne(item.display_name, "")
		assert_ne(item.description, "")
	for slot: CosmeticData.Slot in [CosmeticData.Slot.HAT, CosmeticData.Slot.CLOAK]:
		assert_eq(CosmeticCatalog.starters(slot).size(), 3, "three starting choices per slot")


func test_every_item_has_a_mesh_builder() -> void:
	for item: CosmeticData in CosmeticCatalog.hats():
		var hat: Node3D = CosmeticMeshes.build_hat(item.id, item.default_dye)
		assert_not_null(hat, "%s builds" % item.id)
		if hat != null:
			assert_gt(hat.find_children("*", "MeshInstance3D", true, false).size(), 0, "%s has geometry" % item.id)
			hat.free()
	for item: CosmeticData in CosmeticCatalog.cloaks():
		var cloak: Node3D = CosmeticMeshes.build_cloak(item.id, item.default_dye)
		assert_not_null(cloak, "%s builds" % item.id)
		if cloak != null:
			assert_gt(int(cloak.get_meta("pivot_count", 0)), 1, "%s is a chain of pivots (it can sway)" % item.id)
			cloak.free()


func test_secrets_are_not_sold_and_have_a_hint() -> void:
	var secrets: int = 0
	for item: CosmeticData in CosmeticCatalog.all():
		if not item.is_for_sale():
			secrets += 1
			assert_ne(item.secret_hint, "", "%s says where it hides" % item.id)
	assert_eq(secrets, 4, "four special cosmetics hidden around the world (the fourth is the Four-Seal Vault's cloak)")


func test_state_owns_equips_and_dyes() -> void:
	var state: CosmeticState = CosmeticState.new()
	assert_false(state.equip(CosmeticData.Slot.HAT, "hat_wizard"), "cannot wear what you do not own")
	assert_true(state.grant("hat_wizard"))
	assert_false(state.grant("hat_wizard"), "no duplicates")
	assert_false(state.grant("nope"))
	assert_true(state.equip(CosmeticData.Slot.HAT, "hat_wizard"))
	assert_eq(state.hat_dye, CosmeticCatalog.find("hat_wizard").default_dye, "the default dye comes with it")
	assert_false(state.equip(CosmeticData.Slot.CLOAK, "hat_wizard"), "a hat is not a cloak")
	state.set_dye(CosmeticData.Slot.HAT, 99)
	assert_eq(state.hat_dye, Dye.count() - 1, "dyes clamp")
	assert_true(state.equip(CosmeticData.Slot.HAT, ""))
	assert_eq(state.hat_id, "")


func test_state_round_trips() -> void:
	var state: CosmeticState = CosmeticState.new()
	state.grant("hat_chef")
	state.grant("cloak_royal")
	state.equip(CosmeticData.Slot.HAT, "hat_chef")
	state.equip(CosmeticData.Slot.CLOAK, "cloak_royal")
	state.set_dye(CosmeticData.Slot.CLOAK, 7)
	state.look_chosen = true
	var copy: CosmeticState = CosmeticState.new()
	copy.from_dict(state.to_dict())
	assert_eq(copy.owned, state.owned)
	assert_eq(copy.hat_id, "hat_chef")
	assert_eq(copy.cloak_id, "cloak_royal")
	assert_eq(copy.cloak_dye, 7)
	assert_true(copy.look_chosen)
	var broken: CosmeticState = CosmeticState.new()
	broken.from_dict({"owned": ["bogus"], "hat": "hat_chef", "cloak": "cloak_royal"})
	assert_eq(broken.hat_id, "", "an unowned equipped id is dropped on load")


func test_vendor_stock_follows_progress() -> void:
	var fresh: UnlockState = UnlockState.new()
	var fresh_ids: Array[String] = []
	for item: CosmeticData in CosmeticCatalog.vendor_stock(fresh):
		fresh_ids.append(item.id)
	assert_true(fresh_ids.has("hat_chef"), "basic items from the start")
	assert_false(fresh_ids.has("hat_top_hat"), "the top hat needs a freed zone")
	assert_false(fresh_ids.has("hat_leaf_crown"), "secrets are never stocked")
	var veteran: UnlockState = UnlockState.new()
	veteran.zones_completed = 3
	veteran.player_level = 10
	var veteran_ids: Array[String] = []
	for item: CosmeticData in CosmeticCatalog.vendor_stock(veteran):
		veteran_ids.append(item.id)
	for expected: String in ["hat_top_hat", "hat_tricorn", "hat_mushroom", "cloak_leaf", "cloak_star", "hat_cat_ears"]:
		assert_true(veteran_ids.has(expected), "%s unlocked by progress" % expected)
	assert_gt(CosmeticCatalog.vendor_teasers(fresh).size(), 0)
	assert_ne(CosmeticCatalog.unlock_hint(CosmeticCatalog.find("hat_top_hat")), "")


func test_session_buy_equip_and_save_round_trip() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	assert_true(Session.cosmetics.look_chosen, "launch helpers pick a default look")
	Session.gold = 500
	assert_false(Session.buy_cosmetic("hat_top_hat"), "locked by progress")
	assert_true(Session.buy_cosmetic("hat_chef"))
	assert_eq(Session.gold, 500 - CosmeticCatalog.find("hat_chef").price)
	assert_false(Session.buy_cosmetic("hat_chef"), "already owned")
	assert_false(Session.buy_cosmetic("hat_leaf_crown"), "not for sale")
	var look: CosmeticState = Session.cosmetics.duplicate_state()
	look.equip(CosmeticData.Slot.HAT, "hat_chef")
	look.set_dye(CosmeticData.Slot.HAT, 4)
	Session.apply_look(look)
	var saved: Dictionary = Session.to_dict()
	Session.new_game()
	assert_eq(Session.cosmetics.owned.size(), 0, "a new game starts bare")
	assert_false(Session.cosmetics.look_chosen)
	assert_true(Session.from_dict(saved))
	assert_eq(Session.cosmetics.hat_id, "hat_chef")
	assert_eq(Session.cosmetics.hat_dye, 4)
	assert_true(Session.cosmetics.owns("hat_wide_brim"))


func test_old_saves_count_as_chosen() -> void:
	Session.new_game()
	Session.ensure_game()
	var saved: Dictionary = Session.to_dict()
	saved.erase("cosmetics")
	assert_true(Session.from_dict(saved))
	assert_true(Session.cosmetics.look_chosen)


func test_starting_look_grants_and_equips() -> void:
	Session.new_game()
	Session.choose_starting_look("hat_beanie", "cloak_poncho", 5, 2)
	assert_true(Session.cosmetics.owns("hat_beanie"))
	assert_eq(Session.cosmetics.hat_id, "hat_beanie")
	assert_eq(Session.cosmetics.cloak_id, "cloak_poncho")
	assert_eq(Session.cosmetics.hat_dye, 5)
	assert_eq(Session.cosmetics.cloak_dye, 2)
	assert_true(Session.cosmetics.look_chosen)


func test_hero_model_is_unarmed_and_wears_the_look() -> void:
	var state: CosmeticState = CosmeticState.new()
	state.grant("hat_tricorn")
	state.grant("cloak_hooded")
	state.equip(CosmeticData.Slot.HAT, "hat_tricorn")
	state.equip(CosmeticData.Slot.CLOAK, "cloak_hooded")
	var model: Node3D = HeroModel.build(state)
	add_child_autofree(model)
	for node_name: String in HeroModel.GEAR_NODES:
		for node: Node in model.find_children(node_name, "Node3D", true, false):
			assert_false((node as Node3D).visible, "%s is hidden: the hero is unarmed" % node_name)
	var skeleton: Skeleton3D = HeroModel.skeleton_of(model)
	assert_not_null(skeleton.get_node_or_null(HeroModel.HAT_NODE), "the hat sits on the head bone")
	assert_not_null(skeleton.get_node_or_null(HeroModel.CLOAK_NODE), "the cloak hangs from the chest bone")
	assert_true(HeroModel.has_core_animations(model), "idle, walk, run and interact exist")
	state.equip(CosmeticData.Slot.HAT, "")
	HeroModel.refresh(model, state)
	await get_tree().process_frame
	assert_null(skeleton.get_node_or_null(HeroModel.HAT_NODE), "taking the hat off removes it")


func test_cloak_sways_when_the_hero_moves() -> void:
	var anchor: Node3D = Node3D.new()
	add_child_autofree(anchor)
	var cloak: Node3D = CosmeticMeshes.build_cloak("cloak_traveler", 3)
	anchor.add_child(cloak)
	var sway: CloakSway = CloakSway.attach(cloak, anchor)
	assert_eq(sway.pivot_count(), 3)
	for frame: int in range(40):
		anchor.global_position += Vector3(0.0, 0.0, 0.08)  # walking forward (+Z is the way the model faces)
		sway._process(1.0 / 60.0)
	var top: Node3D = cloak.find_child("Seg0", true, false) as Node3D
	var bottom: Node3D = cloak.find_child("Seg2", true, false) as Node3D
	assert_gt(top.rotation.x, 0.02, "the cloak swings back")
	assert_gt(bottom.rotation.x, 0.0)
