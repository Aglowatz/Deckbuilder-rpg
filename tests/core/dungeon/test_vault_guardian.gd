extends GutTest
## Brief 16, Group G: the four hidden levers, the Four-Seal Vault and its Warden - lever rules in any order, the hidden quest, the boss deck, the rewards and saving.

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.profile = CampaignStart.new_profile(_content, Affinity.Type.NECROCRAT)
	Session.deck = CampaignStart.starter_deck(_content, Affinity.Type.NECROCRAT)


func test_the_four_levers_are_in_the_four_path_zones() -> void:
	assert_eq(VaultGuardian.ZONE_IDS.size(), 4)
	for zone_id: String in ["beefcake", "gourmand", "refusemancer", "necrocrat"]:
		assert_true(VaultGuardian.is_lever_zone(zone_id), zone_id)
		assert_true(ZoneDefs.has_def(zone_id))
	assert_false(VaultGuardian.is_lever_zone("capital"))
	assert_false(VaultGuardian.is_lever_zone("town"))


func test_the_quest_is_hidden_until_the_first_lever_and_counts_them() -> void:
	assert_false(Session.quest_log.is_active(VaultGuardian.QUEST_ID))
	var first: Dictionary = Session.pull_vault_lever("gourmand")
	assert_true(bool(first["first"]))
	assert_eq(int(first["count"]), 1)
	assert_true(Session.quest_log.is_active(VaultGuardian.QUEST_ID), "a hidden quest appears in the log after the first lever")
	var quest: QuestData = QuestCatalog.find(VaultGuardian.QUEST_ID)
	assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()), Vector2i(1, 4))
	assert_false(Session.vault_unlocked())


func test_a_lever_works_once_and_any_order_unlocks_the_vault() -> void:
	var order: Array[String] = ["necrocrat", "beefcake", "refusemancer", "gourmand"]
	for index: int in range(order.size()):
		assert_false(Session.vault_unlocked())
		var result: Dictionary = Session.pull_vault_lever(order[index])
		assert_eq(int(result["count"]), index + 1)
		assert_eq(bool(result["all"]), index == 3)
		assert_true(Session.pull_vault_lever(order[index]).is_empty(), "pulling it again does nothing")
	assert_true(Session.vault_unlocked())
	assert_eq(Session.vault_levers_pulled(), 4)
	assert_true(Session.pull_vault_lever("capital").is_empty(), "no lever in the Capital")


func test_the_cutaway_messages_count_to_four() -> void:
	assert_eq(VaultGuardian.pulled_message(1), "Far away, a great lock grinds open... (1/4)")
	assert_eq(VaultGuardian.pulled_message(3), "Far away, a great lock grinds open... (3/4)")
	assert_true(VaultGuardian.pulled_message(4).contains("(4/4)"))


func test_lever_state_survives_a_save_round_trip() -> void:
	Session.pull_vault_lever("beefcake")
	Session.pull_vault_lever("necrocrat")
	var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	Session.new_game()
	assert_true(Session.from_dict(data))
	assert_true(Session.vault_lever_pulled("beefcake"))
	assert_true(Session.vault_lever_pulled("necrocrat"))
	assert_false(Session.vault_lever_pulled("gourmand"))
	assert_eq(Session.vault_levers_pulled(), 2)
	assert_true(Session.quest_log.is_active(VaultGuardian.QUEST_ID))


func test_the_warden_is_a_four_path_boss_with_a_big_deck_and_an_escalating_summon() -> void:
	var deck: Deck = VaultGuardian.deck(_content)
	assert_gte(deck.size(), 44)
	assert_eq(deck.colors().size(), 4, "it uses all four Paths")
	for id: Variant in VaultGuardian.DECK_RECIPE.keys():
		assert_not_null(_content.card(str(id)) if not str(id).begins_with("BAS-") else _content.card(str(id)), "card %s exists" % str(id))
	var context: BattleContext = Session.make_vault_battle()
	assert_true(context.is_vault_boss)
	assert_eq(context.board_key, "town")
	assert_eq(context.game.players[1].hp, VaultGuardian.STARTING_HP)
	assert_gt(VaultGuardian.STARTING_HP, 30, "far more life than any other duel")
	var modifier: Modifier = VaultGuardian._escalation_modifier()
	assert_eq(modifier.tokens.size(), VaultGuardian.SUMMON_STAGES.size())
	for token: CardData in modifier.tokens:
		assert_not_null(token)


func test_winning_pays_packs_essence_gear_a_cloak_and_xp() -> void:
	for zone_id: String in VaultGuardian.ZONE_IDS:
		Session.pull_vault_lever(zone_id)
	var xp_before: int = Session.profile.xp
	var result: Dictionary = Session.apply_vault_win()
	assert_true(bool(result["first_win"]))
	assert_eq((result["packs"] as Array).size(), 4, "one Gilded Pack per Path")
	for path: Affinity.Type in Affinity.colored_types():
		assert_gte(Session.pack_count(PackRules.gilded_pack_id(path)), 1)
		assert_eq(Session.profile.essence_of(path), VaultGuardian.REWARD_ESSENCE_PER_PATH)
	assert_true(Session.profile.owned_equipment.has(_content.equipment_piece(VaultGuardian.REWARD_EQUIPMENT_ID)), "the exclusive Four-Seal Signet")
	assert_true(Session.cosmetics.owns(VaultGuardian.REWARD_COSMETIC_ID), "the exclusive cloak")
	assert_eq(Session.profile.xp, xp_before + VaultGuardian.REWARD_XP, "a big XP bonus")
	assert_true(Session.vault_defeated())
	assert_true(Session.quest_log.is_completed(VaultGuardian.QUEST_ID))
	assert_not_null(result["summary"] as RewardSummary)
	assert_false((result["summary"] as RewardSummary).is_empty())


func test_the_signet_is_a_relic_that_grants_resources_and_life() -> void:
	var piece: EquipmentData = _content.equipment_piece(VaultGuardian.REWARD_EQUIPMENT_ID)
	assert_not_null(piece)
	assert_eq(piece.slot, EquipmentData.Slot.RELIC)
	assert_eq(piece.modifiers.size(), 5)
	assert_true(CardIcons.BY_EQUIPMENT_ID.has(piece.id))
	assert_false(piece.flavor_text.is_empty())


func test_the_lever_and_the_vault_are_built_from_the_save() -> void:
	var lever: Node3D = LeverKit.build(Color.RED)
	add_child_autofree(lever)
	assert_not_null(LeverKit.handle_of(lever))
	LeverKit.set_pulled(lever, true)
	assert_almost_eq(LeverKit.handle_of(lever).rotation_degrees.z, LeverKit.HANDLE_DOWN_DEGREES, 0.01)
	LeverKit.set_pulled(lever, false)
	assert_almost_eq(LeverKit.handle_of(lever).rotation_degrees.z, LeverKit.HANDLE_UP_DEGREES, 0.01)
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var vault: Node3D = FourSealVault.build(holder, Vector3.ZERO)
	for zone_id: String in VaultGuardian.ZONE_IDS:
		var light: OmniLight3D = vault.get_node("Light_%s" % zone_id) as OmniLight3D
		assert_eq(light.light_energy, 0.0, "all four seals start dark")
	Session.pull_vault_lever("beefcake")
	FourSealVault.refresh(vault)
	assert_gt((vault.get_node("Light_beefcake") as OmniLight3D).light_energy, 0.0, "a pulled lever lights its seal")
	assert_eq((vault.get_node("Light_gourmand") as OmniLight3D).light_energy, 0.0)
