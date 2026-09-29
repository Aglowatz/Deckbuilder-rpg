extends GutTest
## New brief, Part C: EquipmentVendorData/EquipmentVendorEntry - the equipment equivalent of
## ItemVendorData (Part F), mirrored test-for-test against tests/core/data/test_vendor_data.gd's
## VendorData coverage.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func test_add_and_availability() -> void:
	var vendor: EquipmentVendorData = EquipmentVendorData.new()
	vendor.add("wicked_dagger", 100)
	vendor.add("flamethrower", 300, Condition.player_level(10))
	var state: UnlockState = UnlockState.new()
	assert_eq(vendor.available_equipment_ids(state), ["wicked_dagger"] as Array[String])
	assert_eq(vendor.locked_equipment_ids(state), ["flamethrower"] as Array[String])
	state.player_level = 10
	assert_eq(vendor.available_equipment_ids(state).size(), 2)
	assert_true(vendor.locked_equipment_ids(state).is_empty())


func test_teaser_for_locked_and_unknown_equipment() -> void:
	var vendor: EquipmentVendorData = EquipmentVendorData.new()
	vendor.add("flamethrower", 300, Condition.player_level(10))
	assert_eq(vendor.teaser_for("flamethrower"), "Reach level 10 to unlock.")
	assert_eq(vendor.teaser_for("not_in_stock"), "")


func test_price_for() -> void:
	var vendor: EquipmentVendorData = EquipmentVendorData.new()
	vendor.add("wicked_dagger", 100)
	assert_eq(vendor.price_for("wicked_dagger"), 100)
	assert_eq(vendor.price_for("not_in_stock"), 0)


func test_vendor_appears_when_gated() -> void:
	var vendor: EquipmentVendorData = EquipmentVendorData.new()
	vendor.appears_when = Condition.secret_found("hidden_path")
	var state: UnlockState = UnlockState.new()
	assert_false(vendor.is_open(state))
	state.found_secrets.append("hidden_path")
	assert_true(vendor.is_open(state))


## Part C: the real default stock - 5 basic pieces always for sale, 5 advanced locked behind the
## same level-up reward Part D announces.
func test_default_stock_has_five_basic_and_five_advanced() -> void:
	var vendor: EquipmentVendorData = EquipmentVendorScreen.default_stock()
	assert_eq(vendor.entries.size(), 10)
	var closed: UnlockState = UnlockState.new()
	var available: Array[String] = vendor.available_equipment_ids(closed)
	var locked: Array[String] = vendor.locked_equipment_ids(closed)
	assert_eq(available.size(), 5, "5 basic pieces from the start")
	assert_eq(locked.size(), 5, "5 advanced pieces still locked")
	for id: String in available:
		assert_false((content.equipment_piece(id) as EquipmentData).advanced, "%s should be basic" % id)
	for id: String in locked:
		assert_true((content.equipment_piece(id) as EquipmentData).advanced, "%s should be advanced" % id)
	var opened: UnlockState = UnlockState.new()
	opened.player_level = 10
	assert_eq(vendor.available_equipment_ids(opened).size(), 10, "levelling up unlocks the rest")
