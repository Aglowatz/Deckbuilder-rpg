extends GutTest
## The wardrobe of painted-sprite cosmetics (docs/art/world_rollout.md, Part C): six hats and four cloaks, ownership and equipping, cloak dyes, vendor stock by progress,
## saving, and old saves (3D wardrobe) becoming the default look with bought items refunded. The 3D hero (the fallback and the tailor's look) is checked at the end.


func after_each() -> void:
	Session.save_enabled = false


func test_catalog_is_six_hats_and_four_cloaks() -> void:
	var hat_names: Array[String] = []
	for item: CosmeticData in CosmeticCatalog.hats():
		hat_names.append(item.art_name)
	hat_names.sort()
	assert_eq(hat_names, ["BOWLER", "CHEF", "LEAFCROWN", "TRICORN", "WIDEBRIM", "WIZARD"] as Array[String])
	var cloak_names: Array[String] = []
	for item: CosmeticData in CosmeticCatalog.cloaks():
		cloak_names.append(item.art_name)
	cloak_names.sort()
	assert_eq(cloak_names, ["PATCHWORK", "REDCAPE", "ROYAL", "TATTERED"] as Array[String])
	var ids: Dictionary = {}
	for item: CosmeticData in CosmeticCatalog.all():
		assert_false(ids.has(item.id), "%s is unique" % item.id)
		ids[item.id] = true
		assert_ne(item.display_name, "")
		assert_ne(item.description, "")
		assert_true(item.is_for_sale(), "%s has a shop price" % item.id)
	for slot: CosmeticData.Slot in [CosmeticData.Slot.HAT, CosmeticData.Slot.CLOAK]:
		assert_eq(CosmeticCatalog.starters(slot).size(), 0, "no starter items: the hero starts in the default look")


func test_state_owns_equips_and_dyes() -> void:
	var state: CosmeticState = CosmeticState.new()
	assert_eq(state.cloak_dye, Dye.NATURAL, "the cloak is natural at the start")
	assert_false(state.equip(CosmeticData.Slot.HAT, "hat_wizard"), "cannot wear what you do not own")
	assert_true(state.grant("hat_wizard"))
	assert_false(state.grant("hat_wizard"), "no duplicates")
	assert_false(state.grant("nope"))
	assert_true(state.equip(CosmeticData.Slot.HAT, "hat_wizard"))
	assert_false(state.equip(CosmeticData.Slot.CLOAK, "hat_wizard"), "a hat is not a cloak")
	state.set_dye(CosmeticData.Slot.CLOAK, 99)
	assert_eq(state.cloak_dye, Dye.count() - 1, "dyes clamp")
	state.set_dye(CosmeticData.Slot.CLOAK, -5)
	assert_eq(state.cloak_dye, Dye.NATURAL, "natural is the lowest")
	assert_true(state.equip(CosmeticData.Slot.HAT, ""))
	assert_eq(state.hat_id, "")


func test_state_round_trips() -> void:
	var state: CosmeticState = CosmeticState.new()
	state.grant("hat_chef")
	state.grant("cloak_royal")
	state.equip(CosmeticData.Slot.HAT, "hat_chef")
	state.equip(CosmeticData.Slot.CLOAK, "cloak_royal")
	state.set_dye(CosmeticData.Slot.CLOAK, 7)
	var copy: CosmeticState = CosmeticState.new()
	copy.from_dict(state.to_dict())
	assert_eq(copy.owned, state.owned)
	assert_eq(copy.hat_id, "hat_chef")
	assert_eq(copy.cloak_id, "cloak_royal")
	assert_eq(copy.cloak_dye, 7)
	assert_eq(copy.legacy_refund, 0)
	var broken: CosmeticState = CosmeticState.new()
	broken.from_dict({"version": CosmeticMigration.VERSION, "owned": ["bogus"], "hat": "hat_chef", "cloak": "cloak_royal"})
	assert_eq(broken.hat_id, "", "an unowned equipped id is dropped on load")


func test_vendor_stock_follows_progress() -> void:
	var fresh: UnlockState = UnlockState.new()
	var fresh_ids: Array[String] = []
	for item: CosmeticData in CosmeticCatalog.vendor_stock(fresh):
		fresh_ids.append(item.id)
	assert_true(fresh_ids.has("hat_chef"), "basic items from the start")
	assert_false(fresh_ids.has("hat_wizard"), "the wizard hat needs a freed zone")
	assert_false(fresh_ids.has("cloak_royal"), "the royal mantle needs the postgame")
	var veteran: UnlockState = UnlockState.new()
	veteran.zones_completed = 3
	veteran.player_level = 10
	veteran.postgame = true
	var veteran_ids: Array[String] = []
	for item: CosmeticData in CosmeticCatalog.vendor_stock(veteran):
		veteran_ids.append(item.id)
	assert_eq(veteran_ids.size(), 10, "everything is stocked at the end")
	assert_gt(CosmeticCatalog.vendor_teasers(fresh).size(), 0)
	assert_ne(CosmeticCatalog.unlock_hint(CosmeticCatalog.find("hat_wizard")), "")


func test_nothing_without_art_can_be_bought() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	Session.gold = 5000
	var item: CosmeticData = CosmeticCatalog.find("hat_chef")
	if SpriteCosmetics.art_ready(item):
		pending("the chef hat art is imported: the buy path is covered by the shop")
		return
	assert_false(Session.buy_cosmetic("hat_chef"), "arriving soon: not for sale yet")
	assert_eq(Session.gold, 5000, "nothing was charged")


func test_session_equip_and_save_round_trip() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	assert_eq(Session.cosmetics.owned.size(), 0, "a new game starts in the default look")
	assert_eq(Session.cosmetics.hat_id, "")
	assert_eq(Session.cosmetics.cloak_dye, Dye.NATURAL)
	Session.grant_cosmetic("hat_chef")
	Session.grant_cosmetic("cloak_tattered")
	var look: CosmeticState = Session.cosmetics.duplicate_state()
	look.equip(CosmeticData.Slot.HAT, "hat_chef")
	look.equip(CosmeticData.Slot.CLOAK, "cloak_tattered")
	look.set_dye(CosmeticData.Slot.CLOAK, 4)
	Session.apply_look(look)
	var saved: Dictionary = Session.to_dict()
	Session.new_game()
	assert_eq(Session.cosmetics.owned.size(), 0, "a new game starts bare")
	assert_true(Session.from_dict(saved))
	assert_eq(Session.cosmetics.hat_id, "hat_chef")
	assert_eq(Session.cosmetics.cloak_id, "cloak_tattered")
	assert_eq(Session.cosmetics.cloak_dye, 4)


func test_old_save_without_cosmetics_loads() -> void:
	Session.new_game()
	Session.ensure_game()
	var saved: Dictionary = Session.to_dict()
	saved.erase("cosmetics")
	assert_true(Session.from_dict(saved))
	assert_eq(Session.cosmetics.owned.size(), 0)


func test_old_3d_wardrobe_save_is_reset_and_refunded() -> void:
	# A save from before the sprites: two free starters (wide-brim hat, short cape), one bought tricorn (220), one bought star cloak (450), the found tattered cloak and the
	# found four-seals cloak, wearing the tricorn.
	var old: Dictionary = {
		"owned": ["hat_wide_brim", "cloak_short", "hat_tricorn", "cloak_star", "cloak_tattered", "cloak_four_seals", "hat_leaf_crown"],
		"hat": "hat_tricorn", "cloak": "cloak_star", "hat_dye": 3, "cloak_dye": 5, "look_chosen": true,
	}
	var state: CosmeticState = CosmeticState.new()
	state.from_dict(old)
	assert_eq(state.legacy_refund, 220 + 450, "what was bought is refunded at its old price; starters were free")
	assert_eq(state.hat_id, "", "back to the default look")
	assert_eq(state.cloak_id, "")
	assert_eq(state.cloak_dye, Dye.NATURAL)
	assert_true(state.owns("cloak_tattered"), "a found item that still exists stays owned")
	assert_true(state.owns("hat_leaf_crown"))
	assert_true(state.owns("cloak_red_cape"), "the lost four-seals cloak is replaced by the red cape")
	assert_false(state.owns("hat_tricorn"), "bought items were refunded, not kept")
	assert_false(state.owns("cloak_star"))


func test_session_pays_the_refund_once() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	var saved: Dictionary = Session.to_dict()
	saved["gold"] = 100
	saved["cosmetics"] = {"owned": ["hat_tricorn", "cloak_scarf"], "hat": "hat_tricorn", "cloak": "", "look_chosen": true}
	assert_true(Session.from_dict(saved))
	assert_eq(Session.gold, 100 + 220 + 130, "the bought hat and scarf come back as gold")
	assert_eq(Session.cosmetics.legacy_refund, 0, "paid out once")
	var again: Dictionary = Session.to_dict()
	assert_true(Session.from_dict(again))
	assert_eq(Session.gold, 100 + 220 + 130, "saving and loading again does not pay again")


func test_rewards_use_only_the_new_items() -> void:
	assert_not_null(CosmeticCatalog.find(VaultGuardian.REWARD_COSMETIC_ID), "the vault's reward exists in the new wardrobe")
	for zone_chests: Dictionary in [BuffetZone.CHEST_REWARDS, CapitalZone.CHEST_REWARDS, GainlandsZone.CHEST_REWARDS, HeapZone.CHEST_REWARDS]:
		for chest_id: Variant in zone_chests.keys():
			var reward: Dictionary = zone_chests[chest_id] as Dictionary
			var cosmetic: String = str(reward.get("cosmetic", ""))
			if cosmetic != "":
				assert_not_null(CosmeticCatalog.find(cosmetic), "%s: chest cosmetic %s is one of the ten" % [chest_id, cosmetic])


func test_hero_model_is_unarmed_and_wears_the_look() -> void:
	# The 3D hero is the fallback when the sprite art is missing, and the tailor and her mannequin are still 3D pieces in 3D outfits.
	var state: CosmeticState = CosmeticState.new()
	state.hat_id = "hat_tricorn"
	state.cloak_id = "cloak_hooded"
	var model: Node3D = HeroModel.build(state)
	add_child_autofree(model)
	for node_name: String in HeroModel.GEAR_NODES:
		for node: Node in model.find_children(node_name, "Node3D", true, false):
			assert_false((node as Node3D).visible, "%s is hidden: the hero is unarmed" % node_name)
	var skeleton: Skeleton3D = HeroModel.skeleton_of(model)
	assert_not_null(skeleton.get_node_or_null(HeroModel.HAT_NODE), "the hat sits on the head bone")
	assert_not_null(skeleton.get_node_or_null(HeroModel.CLOAK_NODE), "the cloak hangs from the chest bone")
	assert_true(HeroModel.has_core_animations(model), "idle, walk, run and interact exist")
	state.hat_id = ""
	HeroModel.refresh(model, state)
	await get_tree().process_frame
	assert_null(skeleton.get_node_or_null(HeroModel.HAT_NODE), "taking the hat off removes it")
	var tailor: CosmeticState = HeroModel.npc_look("tailor")
	assert_eq(tailor.hat_id, "hat_top_hat", "the tailor keeps her top hat though it is not in the wardrobe")


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
