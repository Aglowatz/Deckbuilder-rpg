extends CardTestBase
## Overnight Nov 3-4, Parts A7 + B1 + B2 + B4: consumable items are single-use charges, four positional item slots (2 from the start, level 6,
## level 12), the save migration, and the Energy Draught (the old Healing Draught: +1 energy of a Path in your deck, this turn only).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.profile.owned_items.clear()
	Session.profile.item_uses_remaining.clear()
	Session.profile.equipped_item_ids.clear()


func _item(id: String) -> ItemData:
	return Session.content.item(id)


# ---- B1: one purchase = one charge, one use spends it for good -------------------------------------------------------------------


func test_buying_adds_one_charge_each_time() -> void:
	Session.gold = 1000
	var charm: ItemData = _item("firebrand_charm")
	assert_true(Session.buy_item(charm, Economy.item_price(charm.id)))
	assert_eq(Session.profile.item_uses_left(charm), 1)
	assert_true(Session.buy_item(charm, Economy.item_price(charm.id)))
	assert_eq(Session.profile.item_uses_left(charm), 2, "a second purchase is a second charge")
	assert_eq(Session.gold, 1000 - 2 * 100)


func test_every_item_is_single_use() -> void:
	for id: Variant in Session.content.items.keys():
		assert_eq(_item(str(id)).uses, 1, "%s is single-use" % str(id))


func test_a_battle_use_spends_a_charge_and_an_empty_slot_clears() -> void:
	var charm: ItemData = _item("firebrand_charm")
	Session.add_item(charm, 2)
	assert_true(Session.profile.equip_item_id(charm))
	Session.profile.spend_item_charge(charm)
	assert_eq(Session.profile.item_uses_left(charm), 1)
	assert_true(Session.profile.is_item_equipped(charm), "charges left: still equipped")
	Session.profile.spend_item_charge(charm)
	assert_false(Session.profile.owns_item(charm), "the last charge is gone")
	assert_false(Session.profile.is_item_equipped(charm), "the slot empties at 0 charges")
	assert_eq(Session.profile.equipped_count(), 0)


func test_owning_more_charges_than_slots_is_fine() -> void:
	for id: String in ["vitality_charm", "healing_salve", "power_wraps", "scroll_of_insight", "firebrand_charm"]:
		Session.add_item(_item(id), 3)
	assert_eq(Session.profile.owned_items.size(), 5)
	var equipped: int = 0
	for item: ItemData in Session.profile.owned_items:
		if Session.profile.equip_item_id(item):
			equipped += 1
	assert_eq(equipped, Session.profile.item_slots, "only the unlocked slots fill")
	assert_eq(Session.profile.owned_items.size(), 5, "the rest stay in the inventory")


# ---- B2: four positional slots -------------------------------------------------------------------------------------------------


func test_slots_unlock_two_then_level_6_then_level_12() -> void:
	assert_eq(ProgressionTable.row(1).item_slots, 2)
	assert_eq(ProgressionTable.row(5).item_slots, 2)
	assert_eq(ProgressionTable.row(6).item_slots, 3)
	assert_eq(ProgressionTable.row(11).item_slots, 3)
	assert_eq(ProgressionTable.row(12).item_slots, 4)
	assert_eq(ProgressionTable.row(ProgressionTable.MAX_LEVEL).item_slots, 4, "four slots in all")


func test_an_item_goes_into_the_slot_you_choose() -> void:
	Session.profile.apply_level(ProgressionTable.row(12))
	var charm: ItemData = _item("firebrand_charm")
	var salve: ItemData = _item("healing_salve")
	Session.add_item(charm)
	Session.add_item(salve)
	assert_true(Session.profile.equip_item_id(charm, 2), "slot 3 while 1 and 2 are empty")
	assert_eq(Session.profile.item_in_slot(2), "firebrand_charm")
	assert_eq(Session.profile.item_in_slot(0), "")
	assert_eq(Session.profile.first_empty_item_slot(), 0)
	assert_true(Session.profile.equip_item_id(salve))
	assert_eq(Session.profile.slot_of_item(salve), 0, "no slot named: the first empty one")
	Session.profile.unequip_item_id(charm)
	assert_eq(Session.profile.equipped_item_ids, ["healing_salve"] as Array[String], "trailing empties trimmed")


func test_a_locked_slot_takes_nothing() -> void:
	Session.profile.apply_level(ProgressionTable.row(1))
	var charm: ItemData = _item("firebrand_charm")
	Session.add_item(charm)
	assert_false(Session.profile.equip_item_id(charm, 2), "slot 3 opens at level 6")
	assert_false(Session.profile.equip_item_id(charm, 3), "slot 4 opens at level 12")
	assert_true(Session.profile.equip_item_id(charm, 1))


func test_battle_item_bar_shows_an_item_in_slot_two_with_slot_one_empty() -> void:
	var charm: ItemData = _item("firebrand_charm")
	Session.add_item(charm)
	Session.profile.equip_item_id(charm, 1)
	var bar: ItemBar = ItemBar.new()
	add_child_autofree(bar)
	bar.setup(null, Session.profile)
	assert_null(bar._items[0])
	assert_eq(bar._items[1], charm)


func test_an_old_save_keeps_the_items_that_fit_and_maps_the_old_draught() -> void:
	Session.add_item(_item("firebrand_charm"))
	Session.add_item(_item("healing_salve"))
	var saved: Dictionary = Session.to_dict()
	# An old save: the Healing Draught by its old id, three items equipped at level 25 (it had 3 slots there under the old track), and a
	# level-1 save with one item.
	(saved["owned_items"] as Array).append({"id": "healing_draught", "uses_left": 2})
	saved["equipped_items"] = ["healing_draught", "firebrand_charm", "healing_salve"]
	assert_true(Session.from_dict(saved))
	assert_true(Session.profile.owns_item(_item("energy_draught")), "the Healing Draught is the Energy Draught now")
	assert_eq(Session.profile.item_uses_left(_item("energy_draught")), 2, "its charges are kept")
	assert_eq(Session.profile.item_slots, ProgressionTable.row(Session.profile.level).item_slots)
	assert_eq(Session.profile.equipped_count(), mini(3, Session.profile.item_slots), "every equipped item that fits stays")
	assert_eq(Session.profile.item_in_slot(0), "energy_draught", "the renamed item keeps its slot")


func test_normalize_moves_an_item_out_of_a_locked_slot() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.item_slots = 2
	var charm: ItemData = _item("firebrand_charm")
	var salve: ItemData = _item("healing_salve")
	profile.owned_items.append(charm)
	profile.owned_items.append(salve)
	profile.equipped_item_ids = ["", "firebrand_charm", "", "healing_salve"] as Array[String]
	profile.normalize_item_slots()
	assert_eq(profile.equipped_item_ids, ["healing_salve", "firebrand_charm"] as Array[String])
	profile.equipped_item_ids = ["ghost_item", "firebrand_charm", "firebrand_charm"] as Array[String]
	profile.normalize_item_slots()
	assert_eq(profile.equipped_item_ids, ["", "firebrand_charm"] as Array[String], "unowned and doubled entries drop")


# ---- B4: the Energy Draught --------------------------------------------------------------------------------------------------------


func _duel(deck: Deck) -> GameState:
	CardSet.load_all()
	var game: GameState = GameState.new()
	game.options.rng_seed = 3
	game.options.free_mulligan = false
	game.add_player(PlayerSetup.create(deck, PlayerProfile.new(), [] as Array[ModifierSource], "Player"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	while not (game.active == 0 and game.in_main_phase()):
		game.advance_phase()
	return game


func test_energy_draught_text_and_no_healing() -> void:
	var draught: ItemData = _item("energy_draught")
	assert_eq(draught.display_name, "Energy Draught")
	assert_eq(draught.effect.op, CardEnums.EffectOp.ADD_ENERGY)
	assert_true(draught.description.contains("Path"), draught.description)
	assert_false(draught.description.to_lower().contains("heal"), draught.description)
	assert_eq(IconArt.item_icon_id("energy_draught"), IconArt.item_icon_id("healing_draught"), "same bottle art")


func test_energy_draught_offers_only_the_deck_paths_and_adds_one_this_turn() -> void:
	var deck: Deck = GameFactory.make_deck(null, 20, 45, Affinity.Type.BEEFCAKE)
	var game: GameState = _duel(deck)
	var choices: Array[Affinity.Type] = game.item_path_choices(0)
	assert_eq(choices, [Affinity.Type.BEEFCAKE] as Array[Affinity.Type], "a one-Path deck offers just that Path")
	var draught: ItemData = _item("energy_draught")
	assert_true(game.can_use_item(0, draught))
	assert_false(game.use_item(0, draught, int(Affinity.Type.NECROCRAT)), "a Path not in the deck is refused")
	var pool_before: int = game.players[0].pool.size()
	assert_true(game.use_item(0, draught, int(Affinity.Type.BEEFCAKE)))
	assert_eq(game.players[0].pool.size(), pool_before + 1)
	assert_eq(game.players[0].pool[game.players[0].pool.size() - 1], int(Affinity.Type.BEEFCAKE))
	assert_false(game.can_use_item(0, draught), "once per battle")
	# this turn only: floating energy empties when the turn ends
	var turn: int = game.turn
	while game.turn == turn and not game.is_over():
		game.advance_phase()
	assert_false(game.players[0].pool.has(int(Affinity.Type.BEEFCAKE)), "gone at the end of the turn")


func test_energy_draught_left_off_healing_lists() -> void:
	assert_false(Session.healing_blocked_for(_item("energy_draught")), "not food: the Famine does not block it")
	assert_false(ItemUseResolver.can_apply(_item("energy_draught")), "no use outside a battle (it heals nothing)")
	var stock: ItemVendorData = ItemVendorScreen.default_stock()
	var found: bool = false
	for entry: ItemVendorEntry in stock.entries:
		if entry.item_id == "energy_draught":
			found = true
			assert_eq(entry.price, 100)
	assert_true(found, "Tilly sells it")
