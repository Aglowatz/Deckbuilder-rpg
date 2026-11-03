extends GutTest
## Overnight Nov 2-3, Part 2 (docs/design/items_nov3.md): the Field Bandage is now Power Wraps (same effect, price and icon; an old save's
## bandage loads as the wraps) and the Reckless Tonic can backfire - with its odds it deals 1 damage to you instead of healing 5. The rolls are
## seeded: in a duel the game's RNG, outside one the caller's roll.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func _code_item(id: String) -> ItemData:
	return ProgressionContent.items(content.tokens).get(id) as ItemData


func test_power_wraps_replaced_the_field_bandage() -> void:
	for item: ItemData in [content.item("power_wraps"), _code_item("power_wraps")]:
		assert_eq(item.display_name, "Power Wraps")
		assert_eq(item.effect.op, CardEnums.EffectOp.BUFF)
		assert_eq([item.effect.amount, item.effect.amount2], [0, 2], "+0/+2 for the rest of the battle")
		assert_eq(item.effect.duration, CardEnums.Duration.PERMANENT)
	assert_null(ProgressionContent.items(content.tokens).get("field_bandage"), "no item keeps the old id")
	assert_eq(CardIcons.BY_ITEM_ID.get("power_wraps", ""), "delapouite/hand-bandage", "the same icon")


func test_an_old_save_with_the_field_bandage_loads_power_wraps() -> void:
	assert_eq(ContentSet.current_item_id("field_bandage"), "power_wraps")
	assert_eq(content.item("field_bandage"), content.item("power_wraps"), "the old id finds the new item")
	assert_eq(ContentSet.current_item_id("vitality_charm"), "vitality_charm")


func test_the_tonic_states_both_outcomes_and_the_odds() -> void:
	for item: ItemData in [content.item("reckless_tonic"), _code_item("reckless_tonic")]:
		assert_gt(item.backfire_chance, 0.0)
		assert_eq(item.backfire_damage, 1)
		assert_eq(item.effect.amount, 5)
		assert_true(item.description.contains("5 HP"), item.description)
		assert_true(item.description.contains("1 damage"), item.description)
		assert_true(item.description.contains("1 in %d" % roundi(1.0 / item.backfire_chance)), "the odds in plain words: " + item.description)


## Seeds whose first roll heals and whose first roll backfires (deterministic: the same seeds every run).
func _seed_for(backfire: bool, item: ItemData) -> int:
	for seed_value: int in range(1, 200):
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = seed_value
		if item.backfires(rng.randf()) == backfire:
			return seed_value
	return -1


func test_in_a_duel_the_tonic_heals_five() -> void:
	var item: ItemData = content.item("reckless_tonic")
	var game: GameState = GameFactory.blank_game()
	game.rng.seed = _seed_for(false, item)
	game.players[0].hp = 3
	assert_true(game.use_item(0, item))
	assert_false(game.last_item_backfired)
	assert_eq(game.players[0].hp, 8)


func test_in_a_duel_the_tonic_can_backfire() -> void:
	var item: ItemData = content.item("reckless_tonic")
	var game: GameState = GameFactory.blank_game()
	game.rng.seed = _seed_for(true, item)
	game.players[0].hp = 3
	assert_true(game.use_item(0, item), "a backfire still spends the use")
	assert_true(game.last_item_backfired)
	assert_eq(game.players[0].hp, 2, "1 damage instead of the heal")
	assert_true(game.item_used(0, item))


func test_outside_a_duel_the_roll_decides() -> void:
	var item: ItemData = content.item("reckless_tonic")
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), Deck.new())
	run.hp = run.max_hp() - 6
	var before: int = run.hp
	assert_true(ItemUseResolver.apply(item, run, 0.99))
	assert_false(ItemUseResolver.last_backfired)
	assert_eq(run.hp, before + 5)
	assert_true(ItemUseResolver.apply(item, run, 0.0))
	assert_true(ItemUseResolver.last_backfired)
	assert_eq(run.hp, before + 4)


func test_other_items_never_backfire() -> void:
	for item: ItemData in content.items.values():
		if item.id != "reckless_tonic":
			assert_eq(item.backfire_chance, 0.0, item.id)
