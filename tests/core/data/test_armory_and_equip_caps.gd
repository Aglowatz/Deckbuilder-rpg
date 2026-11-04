extends GutTest
## Overnight Oct 17, Part 5 / Oct 20, Part 4: the armory quest (Beetsworth closed until Elder Maren sends the hero after the store room -
## never by level; it ends with the Starter Blade and every equipment slot), equipment rarities from data. Fix pass Nov 4: no rarity caps - any piece is worn in its slot at any level.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _to_level(level: int) -> void:
	Session.add_xp(ProgressionTable.xp_to_reach(level) - Session.profile.xp)


## Maren's errands up to the store room are done, so she offers the armory quest; the hero takes it.
func _sent_by_maren() -> void:
	Session.quest_log.completed.append(QuestDefinitions.GHOSTS)
	assert_true(Session.quests_offered_by(QuestDefinitions.MAREN).has(QuestCatalog.find(QuestDefinitions.ARMORY)), "Maren offers the armory quest")
	assert_true(Session.start_quest(QuestDefinitions.ARMORY))


func test_every_piece_has_a_rarity_from_data() -> void:
	var all: Dictionary = Session.content.equipment.duplicate()
	all.merge(Session.content.zone_equipment)
	for id: Variant in all.keys():
		assert_true(EquipmentRarity.rarity_of(str(id)) >= 0, "%s has a rarity in data/equipment/rarities.json" % id)
	assert_eq(int(Session.content.equipment_piece("hubris_crown").rarity), int(CardEnums.Rarity.LEGENDARY))
	assert_eq(EquipmentData.RARITY_NAMES[2], "Epic", "the same names as cards")


func test_the_starter_blade_exists_and_buffs_the_first_unit_only() -> void:
	var blade: EquipmentData = Session.content.equipment_piece(EquipmentRarity.STARTER_BLADE)
	assert_not_null(blade)
	assert_eq(blade.slot, EquipmentData.Slot.WEAPON)
	assert_eq(int(blade.rarity), int(CardEnums.Rarity.COMMON))
	assert_true(blade.modifiers[0].kind == Modifier.Kind.FIRST_UNIT_STAT_CHANGE)


func test_beetsworth_is_closed_until_maren_sends_you_whatever_the_level() -> void:
	_to_level(7)
	assert_false(Session.quest_log.is_active(QuestDefinitions.ARMORY), "no level starts it any more")
	assert_eq(Session.armory_stage(), 0)
	assert_false(Session.gear_unlocked())
	assert_eq(Session.armory_talk(), 0, "no shop, no quest")
	assert_false(Session.quest_log.is_active(QuestDefinitions.ARMORY))


func test_maren_sends_you_and_the_quest_ends_with_gear_and_all_slots() -> void:
	_to_level(5)
	_sent_by_maren()
	assert_true(Session.quest_log.is_active(QuestDefinitions.ARMORY))
	assert_eq(Session.armory_stage(), 1)
	assert_eq(Session.armory_talk(), 1, "the first talk is the report")
	assert_eq(Session.armory_stage(), 2, "now a duel is needed")
	assert_eq(Session.armory_talk(), 2, "talking again before the duel changes nothing")
	Session.note_duel_won()
	Session.refresh_quests()
	assert_eq(Session.armory_stage(), 3)
	Session.armory_talk()
	assert_true(Session.gear_unlocked())
	for slot: Variant in EquipmentData.Slot.values():
		assert_true(Session.profile.has_equipment_slot(slot as EquipmentData.Slot), "slot %d open" % int(slot))
	# Nov 3-4, Part B6: the blade is handed over, not worn - the quest's last step is equipping it on the Character page
	var blade: EquipmentData = Session.content.equipment_piece(EquipmentRarity.STARTER_BLADE)
	assert_true(Session.profile.owned_equipment.has(blade))
	assert_null(Session.profile.equipped_in(EquipmentData.Slot.WEAPON))
	assert_false(Session.quest_log.is_completed(QuestDefinitions.ARMORY), "one step left: equip it")
	assert_true(Session.equip_item(blade))
	Session.refresh_quests()
	assert_true(Session.quest_log.is_completed(QuestDefinitions.ARMORY))
	assert_eq(Session.profile.equipped_in(EquipmentData.Slot.WEAPON).id, EquipmentRarity.STARTER_BLADE)


func test_no_more_slot_choices_on_level_up() -> void:
	_to_level(15)
	assert_eq(Session.pending_equipment_choices, 0)
	for level: int in range(1, 31):
		assert_false(ProgressionTable.row(level).equipment_choice)


func test_any_rarity_is_worn_at_any_level() -> void:
	_to_level(2)
	_sent_by_maren()
	Session.armory_talk()
	Session.note_duel_won()
	Session.refresh_quests()
	Session.armory_talk()
	var first: EquipmentData = Session.content.equipment_piece("flamethrower")  # Epic weapon
	var second: EquipmentData = Session.content.equipment_piece("big_brain_beret")  # Epic helm
	Session.grant_equipment(first)
	Session.grant_equipment(second)
	assert_eq(Session.why_not_equip(first), "")
	assert_true(Session.equip_item(first), "an Epic at level 2")
	assert_eq(Session.why_not_equip(second), "")
	assert_true(Session.equip_item(second), "and a second Epic beside it")


func test_swapping_a_piece_in_the_same_slot_is_never_blocked_by_its_own_rarity() -> void:
	_to_level(5)
	Session._open_the_armory()
	var a: EquipmentData = Session.content.equipment_piece("flamethrower")
	var b: EquipmentData = Session.content.equipment_piece("spotters_barbell")  # also an Epic weapon
	Session.grant_equipment(a)
	Session.grant_equipment(b)
	assert_true(Session.equip_item(a))
	assert_eq(Session.why_not_equip(b), "", "replacing the Epic in the same slot is fine")


func test_old_saves_with_slots_keep_them_and_their_pieces() -> void:
	_to_level(6)
	Session.profile.unlock_equipment_slot(EquipmentData.Slot.WEAPON)
	Session.profile.unlock_equipment_slot(EquipmentData.Slot.HELM)
	var epic_a: EquipmentData = Session.content.equipment_piece("flamethrower")
	var epic_b: EquipmentData = Session.content.equipment_piece("big_brain_beret")
	Session.profile.owned_equipment.append_array([epic_a, epic_b])
	Session.profile.equipment.append_array([epic_a, epic_b] as Array[ModifierSource])
	Session.flags.erase("armory_unlocked")
	var data: Dictionary = Session.to_dict()
	assert_true(Session.from_dict(data))
	assert_true(Session.gear_unlocked(), "an old save with slots counts as done")
	assert_true(Session.profile.has_equipment_slot(EquipmentData.Slot.BOOTS), "and gets every slot")
	assert_eq(Session.profile.equipment.size(), 2, "both Epics stay on")
