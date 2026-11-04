extends GutTest
## Nov 2 pass, Part 4 (docs/design/items_nov2.md): the usable items' reworks and the high shelf's move to level 17. The game loads the items
## from data/items/*.tres (ContentLibrary), written from ProgressionContent by tools/generate_content.gd: both are checked so they never drift.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func _code_item(id: String) -> ItemData:
	return ProgressionContent.items(content.tokens).get(id) as ItemData


func test_scroll_of_insight_draws_one_card() -> void:
	for item: ItemData in [content.item("scroll_of_insight"), _code_item("scroll_of_insight")]:
		assert_eq(item.effect.op, CardEnums.EffectOp.DRAW)
		assert_eq(item.effect.amount, 1, "Draw 1 (Draw 2 was the strongest item on the shelf at 45 gold)")
		assert_eq(item.uses, 1, "Nov 3-4: every item is single-use")
		assert_true(item.description.contains("draw 1 card"), item.description)


func test_power_wraps_is_a_lasting_toughness_buff() -> void:
	for item: ItemData in [content.item("power_wraps"), _code_item("power_wraps")]:
		assert_eq(item.effect.op, CardEnums.EffectOp.BUFF, "mending damage did nothing: unit damage clears each turn")
		assert_eq(item.effect.amount, 0)
		assert_eq(item.effect.amount2, 2)
		assert_eq(item.effect.duration, CardEnums.Duration.PERMANENT)
		assert_eq(item.effect.target, CardEnums.TargetKind.CHOSEN_UNIT_ALLY)
		assert_true(item.description.contains("+0/+2"), item.description)
		assert_true(item.description.contains("rest of the battle"), item.description)


func test_reckless_tonic_says_what_it_does() -> void:
	for item: ItemData in [content.item("reckless_tonic"), _code_item("reckless_tonic")]:
		assert_eq(item.effect.op, CardEnums.EffectOp.GAIN_HP)
		assert_eq(item.effect.amount, 5)
		assert_eq(item.uses, 1)
		assert_true(item.description.contains("heal 5 HP"), item.description)


## Nov 3-4, Part B1: every item is single-use, so no description counts uses any more (the UI says "Single-use" and the charges owned).
func test_every_item_description_states_numbers_and_no_use_count() -> void:
	for id: Variant in content.items.keys():
		var item: ItemData = content.item(str(id))
		var text: String = item.description
		var has_number: bool = false
		for digit: String in ["1", "2", "3", "4", "5", "6", "one ", "One ", "two ", "Two ", "three ", "Three "]:
			if text.contains(digit):
				has_number = true
		assert_true(has_number, "%s names a number: %s" % [str(id), text])
		assert_false(text.contains("uses") or text.contains("One use") or text.contains("one per battle"), "%s: no use count: %s" % [str(id), text])
		assert_eq(item.uses, 1, "%s is single-use" % str(id))
		assert_eq(_code_item(str(id)).description, text, "%s: the .tres matches the code (run tools/generate_content.gd)" % str(id))


func test_the_high_shelf_opens_at_level_17_with_retuned_items() -> void:
	assert_eq(ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL, 17)
	var stock: ItemVendorData = ItemVendorScreen.default_stock()
	var state_16: UnlockState = UnlockState.new()
	state_16.player_level = 16
	var state_17: UnlockState = UnlockState.new()
	state_17.player_level = 17
	var prices: Dictionary = {}
	var locked_at_16: Array[String] = []
	for entry: ItemVendorEntry in stock.entries:
		prices[entry.item_id] = entry.price
		if entry.unlock != null and not Condition.met(entry.unlock, state_16):
			locked_at_16.append(entry.item_id)
			assert_true(Condition.met(entry.unlock, state_17), "%s opens at 17" % entry.item_id)
	locked_at_16.sort()
	assert_eq(locked_at_16, ["binding_chains", "grave_dust", "silence_powder", "summoning_charm", "ward_sigil"])
	# Nov 3-4, Part B3: the regular shelf 50-100 by power, the high shelf 150 each (one charge per purchase).
	for id: String in locked_at_16:
		assert_eq(int(prices[id]), 150, "%s: every high-shelf item is 150" % id)
	var cheapest: int = 1000
	for id: Variant in prices.keys():
		if not locked_at_16.has(str(id)):
			assert_between(int(prices[id]), 50, 100, str(id))
			cheapest = mini(cheapest, int(prices[id]))
	assert_eq(cheapest, 50, "the cheapest item is 50")
	assert_eq(int(prices["energy_draught"]), 100)
	assert_eq(int(prices["firebrand_charm"]), 100)
	assert_eq(content.item("binding_chains").uses, 1)
	assert_eq(content.item("silence_powder").effect.amount, 2)
	assert_eq(content.item("grave_dust").effect.amount, 6)
	assert_eq(content.item("summoning_charm").effect.amount, 3)


func test_a_bandaged_unit_keeps_its_toughness_next_turn() -> void:
	# the whole point of the rework: the buff outlives the turn (the old mend was gone before the opponent could hit the unit)
	var item: ItemData = content.item("power_wraps")
	assert_eq(item.effect.duration, CardEnums.Duration.PERMANENT)
	assert_eq(Economy.item_price("hearty_pie"), 0, "a reward-only item has no price")
