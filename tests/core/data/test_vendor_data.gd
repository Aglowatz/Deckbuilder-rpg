extends GutTest

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func test_add_and_availability() -> void:
	var vendor: VendorData = VendorData.new()
	vendor.add("sellsword")
	vendor.add("beefcake_imp", Condition.flag("bought_beefcake"))
	var state: UnlockState = UnlockState.new()
	assert_eq(vendor.available_card_ids(state), ["sellsword"] as Array[String])
	assert_eq(vendor.locked_card_ids(state), ["beefcake_imp"] as Array[String])
	state.flags["bought_beefcake"] = true
	assert_eq(vendor.available_card_ids(state).size(), 2)
	assert_true(vendor.locked_card_ids(state).is_empty())


func test_teaser_for_locked_and_unknown_cards() -> void:
	var vendor: VendorData = VendorData.new()
	vendor.add("beefcake_imp", Condition.gold_spent(100))
	assert_eq(vendor.teaser_for("beefcake_imp"), "Spend 100 gold in total to unlock.")
	assert_eq(vendor.teaser_for("not_in_stock"), "")


func test_vendor_appears_when_gated() -> void:
	var vendor: VendorData = VendorData.new()
	vendor.appears_when = Condition.secret_found("hidden_path")
	var state: UnlockState = UnlockState.new()
	assert_false(vendor.is_open(state))
	state.found_secrets.append("hidden_path")
	assert_true(vendor.is_open(state))


func test_graduated_stock_starts_small_and_grows_with_progress() -> void:
	var gate: Condition = Condition.dungeon_cleared("Trial of the Hollow")
	var vendor: VendorData = VendorData.graduated(content, [Affinity.Type.A] as Array[Affinity.Type], gate)
	assert_eq(vendor.entries.size(), content.cards.size(), "every card is a known entry")
	var closed: UnlockState = UnlockState.new()
	assert_true(vendor.available_card_ids(closed).is_empty(), "nothing is for sale before the gate")
	var opened: UnlockState = UnlockState.new()
	opened.cleared_dungeons.append("Trial of the Hollow")
	var early_stock: Array[String] = vendor.available_card_ids(opened)
	assert_false(early_stock.is_empty())
	for id: String in early_stock:
		var card: CardData = content.card(id)
		assert_true(card.color == Affinity.Type.NEUTRAL or card.color == Affinity.Type.A, "%s should be neutral or the primary color" % id)
	opened.gold_spent = 1000
	var late_stock: Array[String] = vendor.available_card_ids(opened)
	assert_gt(late_stock.size(), early_stock.size(), "spending more gold unlocks more stock")
	assert_eq(late_stock.size(), content.cards.size(), "everything is unlocked eventually")


## Part E: reaching enough player level opens a rarity tier just as well as gold spent - either
## path unlocks it, so a "vendor unlock" level reward is a real mechanic.
func test_graduated_stock_also_unlocks_by_player_level() -> void:
	var gate: Condition = Condition.dungeon_cleared("Trial of the Hollow")
	var vendor: VendorData = VendorData.graduated(content, [Affinity.Type.A] as Array[Affinity.Type], gate)
	var state: UnlockState = UnlockState.new()
	state.cleared_dungeons.append("Trial of the Hollow")
	var no_level: Array[String] = vendor.available_card_ids(state)
	state.player_level = 21
	var high_level: Array[String] = vendor.available_card_ids(state)
	assert_gt(high_level.size(), no_level.size(), "leveling up unlocks more stock with no gold spent")
	assert_eq(high_level.size(), content.cards.size(), "level 21 alone unlocks everything")
