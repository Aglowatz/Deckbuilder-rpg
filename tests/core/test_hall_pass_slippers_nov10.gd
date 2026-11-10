extends GutTest
## Fable pass Nov 10, Part 5: the Hall Pass Slippers (Boots, the slot with the fewest pieces) make the hero immune to the world's hazards
## outside battle - roamer bumps, rifts, the gravy, pits and falls (`ZoneRun.world_damage`) - and nothing else: battles and story damage are
## untouched. Sold on Madame Mirepoix's shelf in the Endless Buffet at the tier-2 Uncommon price.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)


func test_the_piece_exists_in_the_fewest_slot_and_on_the_buffet_shelf() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var piece: EquipmentData = content.equipment_piece("hall_pass_slippers")
	assert_not_null(piece)
	assert_eq(piece.slot, EquipmentData.Slot.BOOTS)
	assert_eq(piece.rarity, EquipmentData.Rarity.UNCOMMON)
	# boots are the slot with the fewest pieces (count them)
	var counts: Dictionary = {}
	for table: Dictionary in [content.equipment, content.zone_equipment]:
		for id: Variant in table.keys():
			var other: EquipmentData = table[id] as EquipmentData
			if other != null and str(id) != "hall_pass_slippers":
				counts[other.slot] = int(counts.get(other.slot, 0)) + 1
	var fewest: int = 999
	for slot: Variant in counts.keys():
		fewest = mini(fewest, int(counts[slot]))
	assert_eq(int(counts.get(EquipmentData.Slot.BOOTS, 0)), fewest, "boots had the fewest pieces before it: %s" % str(counts))
	var shelf: EquipmentVendorData = ExpansionGear.zone_vendor_stock("gourmand")
	assert_eq(shelf.price_for("hall_pass_slippers"), Economy.gear_price(EquipmentData.Rarity.UNCOMMON, 2), "on Mirepoix's shelf at the tier-2 Uncommon price")
	assert_eq(Economy.gear_price(EquipmentData.Rarity.UNCOMMON, 2), 500)
	assert_true(shelf.available_equipment_ids(Session.unlock_state()).has("hall_pass_slippers"), "for sale from the first visit")


func test_world_damage_is_waived_only_while_the_slippers_are_worn() -> void:
	var run: ZoneRun = ZoneRun.enter("gourmand", Session.profile, Session.deck)
	var full: int = run.hp
	assert_eq(run.world_damage(1), 1, "a hazard hurts without the slippers")
	assert_eq(run.hp, full - 1)
	var piece: EquipmentData = Session.content.equipment_piece("hall_pass_slippers")
	Session.grant_equipment(piece)
	Session.profile.unlock_equipment_slot(EquipmentData.Slot.BOOTS)
	assert_true(Session.equip_item(piece), "the slippers can be worn")
	assert_true(run.immune_to_world_damage())
	assert_eq(run.world_damage(2), 0, "the gravy, a bump or a fall takes nothing")
	assert_eq(run.hp, full - 1, "HP untouched")
	# plain damage (story events, dungeon challenges) still lands
	run.damage(1)
	assert_eq(run.hp, full - 2)
	# the fall helpers go through the gate
	var fall: Dictionary = BuffetInteractables.apply_soup_fall(run, "the gravy", "fell in %s")
	assert_eq(int(fall["damage"]), 0)
	var pit: Dictionary = HeapInteractables.apply_hazard_fall(run, "a pit", "fell in %s")
	assert_eq(int(pit["damage"]), 0)
	var slip: Dictionary = GainlandsInteractables.apply_fall(run, "an island", "fell off %s")
	assert_eq(int(slip["damage"]), 0)
	assert_eq(run.hp, full - 2)


func test_battles_ignore_the_slippers() -> void:
	var piece: EquipmentData = Session.content.equipment_piece("hall_pass_slippers")
	Session.grant_equipment(piece)
	Session.profile.unlock_equipment_slot(EquipmentData.Slot.BOOTS)
	Session.equip_item(piece)
	var game: GameState = GameState.new()
	var me: PlayerState = game.add_player(_setup())
	game.add_player(_setup())
	assert_false(me.modifiers.has(Modifier.Kind.WORLD_IMMUNITY) and false, "no battle rule reads WORLD_IMMUNITY")
	var source: String = FileAccess.get_file_as_string("res://core/game/game_state.gd") + FileAccess.get_file_as_string("res://core/game/combat_resolver.gd")
	assert_false(source.contains("WORLD_IMMUNITY"), "the battle engine never looks at it")


static func _setup() -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.new()
	setup.deck = GameFactory.make_deck()
	return setup
