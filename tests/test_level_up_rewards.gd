extends GutTest
## New brief, Part D: level-up rewards rework, driven through the real Session (like
## tests/test_dev_shrine_grant.gd) rather than just ProgressionTable in isolation, so this proves
## the whole chain (add_xp -> apply_level -> _apply_level_rewards) actually behaves, not just the
## table's own data.

func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)


## Random card-choice level rewards are gone entirely: leveling all the way up (crossing every
## former card-choice filler level: 7, 13, 29) never adds a single card to the collection.
func test_leveling_up_never_grants_a_free_card() -> void:
	var owned_before: int = Session.profile.owned_cards.size()
	Session.add_xp(ProgressionTable.xp_to_reach(ProgressionTable.MAX_LEVEL))
	assert_eq(Session.profile.level, ProgressionTable.MAX_LEVEL)
	assert_eq(Session.profile.owned_cards.size(), owned_before, "no level-up card reward should ever land in the collection")


## Level 10 (EQUIPMENT_VENDOR_UNLOCK_LEVEL) unlocks the equipment vendor's advanced stock -
## verified live through the real Condition/UnlockState path EquipmentVendorScreen uses, not just
## the LevelData flag.
func test_reaching_level_10_unlocks_advanced_equipment_at_the_vendor() -> void:
	var vendor: EquipmentVendorData = EquipmentVendorScreen.default_stock()
	var before_state: UnlockState = Session.unlock_state()
	assert_eq(vendor.available_equipment_ids(before_state).size(), 5, "only the 5 basic pieces before leveling")
	Session.add_xp(ProgressionTable.xp_to_reach(ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL))
	assert_gte(Session.profile.level, ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL)
	var after_state: UnlockState = Session.unlock_state()
	assert_eq(vendor.available_equipment_ids(after_state).size(), 10, "all 10 pieces after reaching level 10")


## Level 6 (ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL) unlocks the item vendor's advanced half.
func test_reaching_level_6_unlocks_advanced_items_at_the_vendor() -> void:
	var vendor: ItemVendorData = ItemVendorScreen.default_stock()
	var before_count: int = vendor.available_item_ids(Session.unlock_state()).size()
	Session.add_xp(ProgressionTable.xp_to_reach(ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL))
	assert_gte(Session.profile.level, ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL)
	var after_count: int = vendor.available_item_ids(Session.unlock_state()).size()
	assert_gt(after_count, before_count, "reaching level 6 should unlock more item stock, not less or the same")


## The vendor-discount filler reward actually reduces what Session charges, not just what a
## screen displays.
func test_vendor_discount_reward_actually_reduces_the_charged_price() -> void:
	assert_eq(Session.effective_price(100), 100, "no discount yet")
	Session.add_xp(ProgressionTable.xp_to_reach(ProgressionTable.MAX_LEVEL))
	assert_gt(Session.profile.vendor_discount_percent, 0, "leveling to the max should have granted at least one discount reward")
	assert_lt(Session.effective_price(100), 100, "the discount should actually lower the charged price")
