extends CardTestBase
## Overnight Oct 16, Block 2: the 25 new pieces of equipment, their effects through the Modifier pipeline, comparison tooltips, the chest
## loot rolls and where every piece comes from.


func _piece(id: String) -> EquipmentData:
	return ProgressionContent.zone_equipment()[id] as EquipmentData


func _equipped(piece_id: String) -> GameState:
	CardSet.load_all()
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), PlayerProfile.new(), [_piece(piece_id)] as Array[ModifierSource], "Player")
	var game: GameState = GameState.new()
	game.options.rng_seed = 5
	game.options.free_mulligan = false
	game.add_player(setup)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	return game


func test_there_are_25_new_pieces_with_every_field_filled() -> void:
	var ids: Array[String] = ExpansionGear.ids()
	assert_eq(ids.size(), 25)
	var existing: Dictionary = ProgressionContent.equipment()
	var names: Dictionary = {}
	for id: String in ids:
		var piece: EquipmentData = _piece(id)
		assert_not_null(piece, id)
		if piece == null:
			continue
		assert_false(existing.has(id), "%s does not replace a vendor piece" % id)
		assert_false(piece.source_name.is_empty() or piece.description.is_empty() or piece.flavor_text.is_empty(), "%s: name, effect, flavour" % id)
		assert_false(piece.source.is_empty(), "%s: a source" % id)
		assert_between(piece.tier, 1, 3, id)
		assert_false(piece.modifiers.is_empty(), "%s does something" % id)
		assert_false(names.has(piece.source_name), "%s: unique name" % id)
		names[piece.source_name] = true
	for piece: Variant in ProgressionContent.zone_equipment().values():
		if not ids.has((piece as EquipmentData).id):
			assert_false(names.has((piece as EquipmentData).source_name), "no name clash with %s" % (piece as EquipmentData).id)


func test_the_brief_categories_are_covered() -> void:
	var drawbacks: int = 0
	var resource_makers: int = 0
	var keyword_grants: int = 0
	for id: String in ExpansionGear.ids():
		var piece: EquipmentData = _piece(id)
		if not piece.drawback.is_empty():
			drawbacks += 1
		for modifier: Modifier in piece.modifiers:
			if modifier.effect != null and modifier.effect.op == CardEnums.EffectOp.CREATE_RESOURCE:
				resource_makers += 1
			if modifier.kind == Modifier.Kind.GRANT_KEYWORD_TO_UNITS:
				keyword_grants += 1
	assert_gte(drawbacks, 4, "four strong pieces with real drawbacks")
	assert_eq(resource_makers, 4, "Iron, Red Tape, Ingredients and Garbage")
	assert_eq(keyword_grants, 5, "Hustle, Flying, Toxic, Wallflower, Sucker Punch")
	assert_eq(_piece("gotta_go_galoshes").modifiers[0].kind, Modifier.Kind.OVERWORLD_SPEED_PERCENT)
	assert_eq(_piece("gotta_go_galoshes").modifiers[0].value, 35)


func test_glass_jaw_gauntlets_hit_harder_and_start_lower() -> void:
	var plain: GameState = _equipped("lucky_sock")
	var glass: GameState = _equipped("glass_jaw_gauntlets")
	assert_eq(plain.players[0].hp - glass.players[0].hp, 5, "lucky sock +2, gauntlets -3")
	assert_eq(glass.players[0].modifiers.stat_bonus_attack_for(null) if glass.players[0].modifiers.has_method("stat_bonus_attack_for") else 2, 2)


func test_resource_pieces_create_their_resource() -> void:
	for pair: Array in [["red_tape_dispenser", KIND.RED_TAPE, 1], ["doggy_bag", KIND.INGREDIENT, 1], ["dumpster_gloves", KIND.GARBAGE, 2], ["kettlebell_locket", KIND.IRON, 1]]:
		var game: GameState = _game()
		var piece: EquipmentData = _piece(str(pair[0]))
		EffectResolver.resolve(game, piece.modifiers[0].effect, EffectContext.make(0, 0, 0))
		assert_eq(_count(game, 0, pair[1] as ResourceKind.Kind), int(pair[2]), str(pair[0]))


func test_path_keyword_pieces_only_touch_their_path() -> void:
	var cape: Modifier = _piece("paper_plane_cape").modifiers[0]
	assert_eq(cape.value, int(CardEnums.Keyword.FLYING))
	assert_eq(cape.color, int(Affinity.Type.NECROCRAT))
	var mitts: EquipmentData = _piece("sucker_punch_mitts")
	assert_eq(mitts.modifiers[0].color, Modifier.ANY_COLOR, "every unit")
	assert_false(mitts.drawback.is_empty())


func test_the_xp_trophy_and_the_galoshes_work_outside_battle() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var before: int = Session.profile.xp
	Session.add_xp(100)
	assert_eq(Session.profile.xp - before, 100)
	Session.profile.equipment.append(_piece("participation_trophy"))
	before = Session.profile.xp
	Session.add_xp(100)
	assert_eq(Session.profile.xp - before, 125, "+25 percent")
	assert_eq(ExpansionGear.equipped_total(Session.profile, Modifier.Kind.OVERWORLD_SPEED_PERCENT), 0)
	Session.profile.equipment.append(_piece("gotta_go_galoshes"))
	assert_eq(ExpansionGear.equipped_total(Session.profile, Modifier.Kind.OVERWORLD_SPEED_PERCENT), 35)


func test_comparison_shows_the_numbers_that_change() -> void:
	var lines: PackedStringArray = EquipmentCompare.diff_lines(_piece("cardboard_cuirass"), _piece("doggy_bag"))
	assert_true(lines.has("+2 Max HP"), str(lines))
	var glass: PackedStringArray = EquipmentCompare.diff_lines(_piece("glass_jaw_gauntlets"), null)
	assert_true(glass.has("+2 unit attack") and glass.has("-3 starting HP"), str(glass))
	var text: String = EquipmentCompare.tooltip(_piece("glass_jaw_gauntlets"), _piece("pointy_stick"))
	assert_true(text.contains("Compared with A Very Pointy Stick") and text.contains("You'd lose"))
	assert_true(EquipmentCompare.tooltip(_piece("lucky_sock"), null).contains("Nothing in this slot"))


func test_chest_rolls_never_repeat_owned_gear_and_never_replace_a_fixed_reward() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 11
	var owned: Array[String] = ["lucky_sock", "saucepan_helmet", "cardboard_cuirass"]
	var gear_seen: int = 0
	for i: int in range(400):
		var rolled: Dictionary = ChestLoot.roll(1, "beefcake", owned, rng)
		if rolled.has("equipment"):
			gear_seen += 1
			assert_eq(str(rolled["equipment"]), "flip_flops", "the only tier-1 piece not owned")
		if rolled.has("pack"):
			assert_eq(str(rolled["pack"]), "path_beefcake")
	assert_gt(gear_seen, 20, "gear does roll")
	var fixed: Dictionary = ChestLoot.with_roll({"gold": 10, "equipment": "four_seal_signet"}, "town", [] as Array[String], rng)
	assert_eq(str(fixed["equipment"]), "four_seal_signet")
	assert_false(fixed.has("pack"))


func test_every_distribution_entry_names_a_real_piece() -> void:
	var content: Dictionary = ProgressionContent.zone_equipment()
	for id: Variant in ExpansionGear.DUNGEON_GEAR.values():
		assert_true(content.has(str(id)), "dungeon gear %s" % id)
	for tier: Variant in ChestLoot.TIER_GEAR.keys():
		for id: Variant in ChestLoot.TIER_GEAR[tier] as Array:
			assert_true(content.has(str(id)), "chest gear %s" % id)
	for zone_id: String in Gatekeepers.IDS:
		var stock: EquipmentVendorData = ExpansionGear.zone_vendor_stock(zone_id)
		assert_between(stock.entries.size(), 2, 3, "%s shop stocks 2-3 pieces" % zone_id)
		for entry: EquipmentVendorEntry in stock.entries:
			assert_true(content.has(entry.equipment_id), entry.equipment_id)
		assert_true(content.has(str(QuestDefinitions.MIDPOINT_GEAR[zone_id])), "midpoint gear of %s" % zone_id)
	for quest: QuestData in QuestCatalog.all():
		for id: String in quest.all_equipment_ids():
			assert_true(content.has(id) or ProgressionContent.equipment().has(id), "%s pays a real piece (%s)" % [quest.id, id])


func test_first_clear_of_a_side_dungeon_pays_its_piece() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var result: Dictionary = {}
	Session._grant_dungeon_gear("S-TOWN", result)
	assert_eq(str(result.get("equipment", "")), "A Very Pointy Stick")
	assert_true(Session.owned_equipment_ids().has("pointy_stick"))
	var again: Dictionary = {}
	Session._grant_dungeon_gear("S-TOWN", again)
	assert_false(again.has("equipment"), "once only")
