extends GutTest
## Part E: the level table, PlayerProfile's progression state, and the equipment/item framework.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


# ---- ProgressionTable ----------------------------------------------------------------------


func test_table_has_exactly_thirty_levels_in_order() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	assert_eq(rows.size(), ProgressionTable.MAX_LEVEL)
	for i: int in range(rows.size()):
		assert_eq(rows[i].level, i + 1)


func test_hp_reaches_25_at_level_30_via_even_levels_only() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	assert_eq(rows[0].max_hp, PlayerProfile.START_MAX_HP)
	assert_eq(rows[29].max_hp, PlayerProfile.ENDGAME_MAX_HP)
	for row: LevelData in rows:
		if row.level == 1:
			continue
		var previous: LevelData = rows[row.level - 2]
		if row.level % 2 == 0:
			assert_eq(row.max_hp, previous.max_hp + 1, "level %d should gain HP" % row.level)
		else:
			assert_eq(row.max_hp, previous.max_hp, "odd level %d should not gain HP" % row.level)


func test_opening_hand_and_item_slots_reach_their_caps_gradually() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	assert_eq(rows[0].opening_hand_size, PlayerProfile.MIN_OPENING_HAND)
	assert_eq(rows[29].opening_hand_size, PlayerProfile.MAX_OPENING_HAND)
	assert_eq(rows[0].item_slots, 1)
	assert_eq(rows[29].item_slots, 4)
	# Gradually: never a jump greater than 1 at a time.
	for i: int in range(1, rows.size()):
		assert_lte(rows[i].opening_hand_size - rows[i - 1].opening_hand_size, 1)
		assert_lte(rows[i].item_slots - rows[i - 1].item_slots, 1)


func test_copy_limit_is_three_at_most_and_levels_have_other_rewards() -> void:
	assert_eq(DeckValidator.MAX_COPIES, 3)
	for level: int in [11, 14, 17, 21, 28]:
		var row: LevelData = ProgressionTable.row(level)
		assert_true(row.reward_vendor_discount_percent > 0 or not row.reward_vendor_unlock.is_empty() or row.reward_equipment_vendor_unlock or row.reward_deck_expansion or row.max_hand_size > ProgressionTable.row(level - 1).max_hand_size, "level %d replaced its copy-limit reward with something else" % level)
	assert_eq(ProgressionTable.row(30).max_hand_size, 12)


func test_no_equipment_slot_choices_any_more() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	var choice_levels: Array[int] = []
	for row: LevelData in rows:
		if row.equipment_choice:
			choice_levels.append(row.level)
	assert_eq(choice_levels, [] as Array[int], "no slot choices: the level-5 armory quest opens every slot (Overnight Oct 17)")


## New brief, Part D: the two specific level-up rewards - advanced equipment at the equipment
## vendor, and the second half of the item vendor's stock - each unlock exactly once, at their
## own level, and the popup can announce them (LevelUpScreen._bonuses_for reads these same
## fields).
func test_vendor_unlock_rewards_infrastructure_at_their_own_levels_only() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	var equipment_unlock_levels: Array[int] = []
	var item_unlock_levels: Array[int] = []
	for row: LevelData in rows:
		if row.reward_equipment_vendor_unlock:
			equipment_unlock_levels.append(row.level)
		if row.reward_item_vendor_advanced_unlock:
			item_unlock_levels.append(row.level)
	assert_eq(equipment_unlock_levels, [ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL])
	assert_eq(item_unlock_levels, [ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL])


func test_every_level_up_grants_something() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	for row: LevelData in rows:
		assert_false(row.summary.is_empty(), "level %d has no summary" % row.level)
		if row.level == 1:
			continue
		var previous: LevelData = ProgressionTable.row(row.level - 1)
		var has_real_gain: bool = (
			row.max_hp > previous.max_hp or row.opening_hand_size > previous.opening_hand_size
			or row.item_slots > previous.item_slots or row.equipment_choice
			or row.max_hand_size > previous.max_hand_size
		)
		var has_filler: bool = row.reward_vendor_discount_percent > 0 or not row.reward_vendor_unlock.is_empty() or row.reward_deck_expansion or row.reward_equipment_vendor_unlock or row.reward_item_vendor_advanced_unlock
		var has_track_grant: bool = not row.grants.is_empty() or row.armory or not row.copy_cap_raises.is_empty()
		assert_true(has_real_gain or has_filler or has_track_grant, "level %d grants nothing" % row.level)


func test_xp_to_reach_is_strictly_increasing() -> void:
	var previous: int = -1
	for level: int in range(1, ProgressionTable.MAX_LEVEL + 1):
		var xp: int = ProgressionTable.xp_to_reach(level)
		assert_gt(xp, previous, "level %d" % level)
		previous = xp


func test_level_for_xp_matches_the_thresholds() -> void:
	assert_eq(ProgressionTable.level_for_xp(0), 1)
	assert_eq(ProgressionTable.level_for_xp(-100), 1)
	for level: int in range(2, ProgressionTable.MAX_LEVEL + 1):
		var threshold: int = ProgressionTable.xp_to_reach(level)
		assert_eq(ProgressionTable.level_for_xp(threshold), level, "exactly at the threshold")
		assert_eq(ProgressionTable.level_for_xp(threshold - 1), level - 1, "just under the threshold")
	assert_eq(ProgressionTable.level_for_xp(ProgressionTable.xp_to_reach(ProgressionTable.MAX_LEVEL) + 999999), ProgressionTable.MAX_LEVEL, "never exceeds max level")


# ---- PlayerProfile leveling ------------------------------------------------------------------


func test_apply_level_updates_absolute_stats() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.apply_level(ProgressionTable.row(10))
	assert_eq(profile.level, 10)
	assert_eq(profile.max_hp, ProgressionTable.row(10).max_hp)
	assert_eq(profile.opening_hand_size, ProgressionTable.row(10).opening_hand_size)
	assert_eq(profile.item_slots, ProgressionTable.row(10).item_slots)
	assert_eq(profile.base_max_hp(), ProgressionTable.row(10).max_hp)


## New brief, Part D: PlayerProfile.discounted_price() - the pure-core half of the vendor-discount
## reward (Session.effective_price() is the thin app-layer wrapper around this).
func test_discounted_price_applies_the_percentage_and_never_drops_below_one() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	assert_eq(profile.discounted_price(100), 100, "no discount by default")
	profile.vendor_discount_percent = 10
	assert_eq(profile.discounted_price(100), 90)
	profile.vendor_discount_percent = 30
	assert_eq(profile.discounted_price(100), 70)
	profile.vendor_discount_percent = 99
	assert_eq(profile.discounted_price(1), 1, "never rounds down to 0 for a positive price")
	assert_eq(profile.discounted_price(0), 0)


func test_apply_level_sets_max_hand_size() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	assert_eq(profile.base_max_hand_size(), 10)
	profile.apply_level(ProgressionTable.row(14))
	assert_eq(profile.base_max_hand_size(), 11)
	profile.apply_level(ProgressionTable.row(30))
	assert_eq(profile.base_max_hand_size(), 12)


func test_deck_validator_caps_a_legendary_at_one_then_three_at_level_30() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var legendary: CardData = CardBuilder.unit("myth", "Myth", Affinity.Type.BEEFCAKE, 1, [] as Array[Affinity.Type], 1, 1)
	legendary.rarity = CardEnums.Rarity.LEGENDARY
	var deck: Deck = Deck.new()
	deck.cards.append(legendary)
	assert_false(DeckValidator.has_problem(DeckValidator.validate(deck, profile), DeckValidator.Problem.TOO_MANY_COPIES), "1 Legendary is fine at level 1")
	deck.cards.append(legendary)
	assert_true(DeckValidator.has_problem(DeckValidator.validate(deck, profile), DeckValidator.Problem.TOO_MANY_COPIES), "2 are too many at level 1")
	profile.level = 30
	deck.cards.append(legendary)
	assert_false(DeckValidator.has_problem(DeckValidator.validate(deck, profile), DeckValidator.Problem.TOO_MANY_COPIES), "3 are fine at level 30")
	deck.cards.append(legendary)
	assert_true(DeckValidator.has_problem(DeckValidator.validate(deck, profile), DeckValidator.Problem.TOO_MANY_COPIES), "4 are too many at any level")


# ---- Equipment ----------------------------------------------------------------------------


func test_progression_content_has_ten_equipment_two_per_slot_and_thirteen_items() -> void:
	# New brief, Part B: 10 real pieces (a basic and an advanced one per slot), replacing the
	# original 5 placeholders.
	assert_eq(content.equipment.size(), 11, "the ten plus the Blade of Earned Reputation (Oct 29)")
	var basic_by_slot: Dictionary = {}
	var advanced_by_slot: Dictionary = {}
	for piece: Variant in content.equipment.values():
		var gear: EquipmentData = piece as EquipmentData
		if gear.advanced:
			advanced_by_slot[gear.slot] = true
		else:
			basic_by_slot[gear.slot] = true
	assert_eq(basic_by_slot.size(), 5, "one basic piece per slot")
	assert_eq(advanced_by_slot.size(), 5, "one advanced piece per slot")
	# New brief, Part F: 3 original placeholders + 10 new basic consumables.
	assert_eq(content.items.size(), 18)
	for consumable: Variant in content.items.values():
		assert_gt((consumable as ItemData).uses, 0)
		assert_not_null((consumable as ItemData).effect)


## New brief (third), Part C: the shared equipment tooltip (character screen) is just name +
## description - equipment has no target, unlike an item's effect.
func test_equipment_tooltip_text_includes_name_and_description() -> void:
	var helm: EquipmentData = content.equipment_piece("xray_goggles")
	var text: String = helm.tooltip_text()
	assert_true(text.contains(helm.source_name))
	assert_true(text.contains(helm.description))


func test_cannot_equip_into_a_locked_slot() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var helm: EquipmentData = content.equipment_piece("xray_goggles")
	profile.owned_equipment.append(helm)
	assert_false(profile.equip(helm), "the Helm slot is not unlocked yet")
	profile.unlock_equipment_slot(EquipmentData.Slot.HELM)
	assert_true(profile.equip(helm))
	assert_eq(profile.equipped_in(EquipmentData.Slot.HELM), helm)
	assert_true(profile.equipment.has(helm))


func test_equipping_a_second_piece_in_the_same_slot_replaces_the_first() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.unlock_equipment_slot(EquipmentData.Slot.WEAPON)
	var sword: EquipmentData = EquipmentData.new()
	sword.id = "test_sword"
	sword.slot = EquipmentData.Slot.WEAPON
	var axe: EquipmentData = EquipmentData.new()
	axe.id = "test_axe"
	axe.slot = EquipmentData.Slot.WEAPON
	profile.owned_equipment.append_array([sword, axe])
	assert_true(profile.equip(sword))
	assert_true(profile.equip(axe))
	assert_eq(profile.equipped_in(EquipmentData.Slot.WEAPON), axe)
	assert_eq(profile.equipment.size(), 1, "only one piece per slot")


func test_unequip_returns_it_to_owned_and_removes_its_modifiers() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.unlock_equipment_slot(EquipmentData.Slot.ARMOR)
	var vest: EquipmentData = content.equipment_piece("thorned_loincloth")
	profile.owned_equipment.append(vest)
	profile.equip(vest)
	assert_eq(profile.gear_modifiers().sum(Modifier.Kind.MAX_HP), -2)
	var removed: EquipmentData = profile.unequip(EquipmentData.Slot.ARMOR)
	assert_eq(removed, vest)
	assert_null(profile.equipped_in(EquipmentData.Slot.ARMOR))
	assert_eq(profile.gear_modifiers().sum(Modifier.Kind.MAX_HP), 0)
	assert_true(profile.owned_equipment.has(vest), "still owned after unequipping")


func test_equipped_gear_flows_through_the_pipeline_into_a_real_game() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.unlock_equipment_slot(EquipmentData.Slot.ARMOR)
	var vest: EquipmentData = content.equipment_piece("thorned_loincloth")
	profile.owned_equipment.append(vest)
	profile.equip(vest)
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), profile)
	var game: GameState = GameState.new()
	game.add_player(setup)
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	assert_eq(game.players[0].max_hp, 8, "10 base - 2 from Thorned Loincloth")


# ---- Items ----------------------------------------------------------------------------------


func test_use_item_consumes_a_charge_and_heals_the_run() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var draught: ItemData = content.item("healing_draught")
	profile.owned_items.append(draught)
	var run: DungeonRun = DungeonRun.enter(profile, GameFactory.make_deck())
	run.lose_hp(5)
	var before: int = run.hp
	assert_true(profile.use_item(draught, run))
	assert_eq(run.hp, before + 3)
	assert_eq(profile.item_uses_left(draught), draught.uses - 1)


func test_item_is_removed_once_out_of_uses() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var tonic: ItemData = content.item("reckless_tonic")
	assert_eq(tonic.uses, 1)
	profile.owned_items.append(tonic)
	var run: DungeonRun = DungeonRun.enter(profile, GameFactory.make_deck())
	assert_true(profile.use_item(tonic, run))
	assert_false(profile.owns_item(tonic), "used up its only charge")
	assert_false(profile.use_item(tonic, run), "cannot use it again")


func test_use_item_fails_for_an_unowned_item_or_an_unsupported_effect() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var draught: ItemData = content.item("healing_draught")
	var run: DungeonRun = DungeonRun.enter(profile, GameFactory.make_deck())
	assert_false(profile.use_item(draught, run), "not owned")
	var weird: ItemData = ItemData.new()
	weird.id = "weird"
	weird.uses = 1
	weird.effect = EffectData.new()
	weird.effect.op = CardEnums.EffectOp.DRAW
	profile.owned_items.append(weird)
	assert_false(profile.use_item(weird, run), "DRAW is not a supported outside-battle op")
	assert_true(profile.owns_item(weird), "an unsupported use does not consume the charge")


# ---- Equipping items (new brief, Part F) -----------------------------------------------------


func test_equip_is_limited_by_item_slots() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.item_slots = 1
	var draught: ItemData = content.item("healing_draught")
	var tonic: ItemData = content.item("reckless_tonic")
	profile.owned_items.append(draught)
	profile.owned_items.append(tonic)
	assert_true(profile.equip_item_id(draught))
	assert_false(profile.equip_item_id(tonic), "only 1 item slot at level 1")
	profile.item_slots = 2
	assert_true(profile.equip_item_id(tonic), "a second slot frees up room")
	assert_eq(profile.equipped_item_ids, ["healing_draught", "reckless_tonic"])


func test_cannot_equip_an_unowned_item_or_equip_twice() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.item_slots = 4
	var draught: ItemData = content.item("healing_draught")
	assert_false(profile.equip_item_id(draught), "not owned")
	profile.owned_items.append(draught)
	assert_true(profile.equip_item_id(draught))
	assert_false(profile.equip_item_id(draught), "already equipped")


func test_using_up_the_last_charge_also_unequips_it() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.item_slots = 1
	var tonic: ItemData = content.item("reckless_tonic")
	profile.owned_items.append(tonic)
	profile.item_uses_remaining[tonic.id] = tonic.uses
	profile.equip_item_id(tonic)
	profile.spend_item_charge(tonic)
	assert_false(profile.owns_item(tonic))
	assert_false(profile.is_item_equipped(tonic), "gone from inventory, so no longer equipped either")
	assert_eq(profile.equipped_item_ids.size(), 0)


## Overnight Oct 17, Part 6: the reward track pays gold at some levels again (the brief asks for gold among the fillers; it
## replaces Brief 16's no-gold rule, ON17-8). Levelling 1 to 30 pays exactly the track's gold.
func test_levelling_pays_exactly_the_track_gold() -> void:
	var expected: int = 0
	for row: LevelData in ProgressionTable.build():
		for grant: Dictionary in row.grants:
			if str(grant.get("kind", "")) == "gold":
				expected += int(grant.get("amount", 0))
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var before: int = Session.gold
	Session.add_xp(ProgressionTable.xp_to_reach(ProgressionTable.MAX_LEVEL))
	assert_eq(Session.gold, before + expected, "levelling from 1 to 30 pays the track's gold")


func test_the_old_gold_levels_grant_something_meaningful() -> void:
	for level: int in [3, 6, 13, 21, 27]:
		var row: LevelData = ProgressionTable.row(level)
		var previous: LevelData = ProgressionTable.row(level - 1)
		var real: bool = (
			row.reward_vendor_discount_percent > 0 or not row.reward_vendor_unlock.is_empty() or row.reward_deck_expansion
			or row.reward_equipment_vendor_unlock or row.reward_item_vendor_advanced_unlock or row.max_hp > previous.max_hp
			or not row.grants.is_empty()
		)
		assert_true(real, "level %d (formerly gold) grants: %s" % [level, row.summary])
	assert_true(ProgressionTable.row(7).reward_deck_expansion)
	assert_true(ProgressionTable.row(13).reward_equipment_vendor_unlock)
	assert_true(ProgressionTable.row(21).reward_vendor_discount_percent > 0)
	assert_false(ProgressionTable.row(10).reward_equipment_vendor_unlock, "moved off level 10, which keeps its stat rewards")
	assert_false(ProgressionTable.row(24).reward_vendor_discount_percent > 0, "moved off level 24")


func test_deck_slots_open_two_at_a_time_at_7_14_21() -> void:
	assert_eq(ProgressionTable.row(1).deck_slots, 4)
	assert_eq(ProgressionTable.row(6).deck_slots, 4)
	assert_eq(ProgressionTable.row(7).deck_slots, 6)
	assert_eq(ProgressionTable.row(14).deck_slots, 8)
	assert_eq(ProgressionTable.row(21).deck_slots, 10)
	assert_eq(ProgressionTable.row(30).deck_slots, 10)
	assert_true("Deck Station: 4 to 6 deck slots" in ProgressionTable.row(7).summary, ProgressionTable.row(7).summary)


func test_stat_rewards_keep_their_schedule() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	assert_eq(rows[29].max_hp, 25)
	assert_eq(rows[23].opening_hand_size, 8)
	assert_eq(rows[29].item_slots, 4)
	assert_eq(rows[27].max_hand_size, 12)
	var choice_levels: Array[int] = []
	for row: LevelData in rows:
		if row.equipment_choice:
			choice_levels.append(row.level)
	assert_eq(choice_levels, [] as Array[int], "no slot choices: the level-5 armory quest opens every slot (Overnight Oct 17)")


## XP Pass Oct 30: the curve is re-based (slower from L6). A save made on the old curve can hold more levels than its XP gives now;
## it keeps its level, XP and rewards, and the next level comes at the new curve's threshold.
func test_an_old_save_above_the_new_curve_keeps_its_level() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var row: LevelData = ProgressionTable.row(12)
	Session.profile.apply_level(row)
	Session.profile.xp = 2000  # level 12 on the old curve (1,980), level 9 on the new one
	assert_lt(ProgressionTable.level_for_xp(Session.profile.xp), 12, "the new curve gives less")
	var gold: int = Session.gold
	assert_true(Session.add_xp(100).is_empty(), "no level gained, none lost")
	assert_eq(Session.profile.level, 12)
	assert_eq(Session.profile.xp, 2100)
	assert_eq(Session.gold, gold, "no level rewards paid twice")
	var gained: Array[LevelData] = Session.add_xp(ProgressionTable.xp_to_reach(13) - Session.profile.xp)
	assert_eq(gained.size(), 1, "level 13 at its new threshold")
	assert_eq(Session.profile.level, 13)


func test_the_curve_costs_more_every_level() -> void:
	for level: int in range(3, ProgressionTable.MAX_LEVEL + 1):
		assert_gt(ProgressionTable.xp_step(level), ProgressionTable.xp_step(level - 1), "level %d costs more than level %d" % [level, level - 1])
	assert_eq(ProgressionTable.xp_to_reach(5), 300, "level 5 on the store room ghosts' hand-in")
