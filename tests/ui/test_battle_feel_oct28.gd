extends GutTest
## Overnight Oct 28-29, Part 4 (docs/design/battle_feel.md): the timing rules of the battle juice - the hit-stop stays 40-80 ms, the
## effects layer follows the battle speed, a flying resource mote lands and calls back, numbers carry the Path colour, and 4x exists.


func test_hit_stop_is_40_to_80_ms() -> void:
	assert_almost_eq(BattleBoard.hit_stop_seconds(1), 0.04, 0.0001)
	assert_almost_eq(BattleBoard.hit_stop_seconds(3), 0.06, 0.0001)
	assert_almost_eq(BattleBoard.hit_stop_seconds(5), 0.08, 0.0001)
	assert_almost_eq(BattleBoard.hit_stop_seconds(12), 0.08, 0.0001, "never longer than 80 ms")
	assert_almost_eq(BattleBoard.hit_stop_seconds(0), 0.04, 0.0001)


func test_damage_numbers_stay_red_with_a_share_of_the_path_colour() -> void:
	var path: Color = UIStyle.affinity_color(Affinity.Type.NECROCRAT)
	var number: Color = BattleBoard.damage_number_color(path)
	assert_gt(number.r, number.b, "it still reads as a blow")
	assert_ne(number, BattleBoard.damage_number_color(UIStyle.affinity_color(Affinity.Type.GOURMAND)), "two Paths hit in two shades")


func test_the_effects_layer_follows_the_battle_speed() -> void:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.fx = fx
	board.speed = 4.0
	assert_eq(fx.speed, 4.0)
	board.speed = 1.0
	assert_eq(fx.speed, 1.0)


func test_a_resource_mote_lands_and_calls_back() -> void:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	fx.speed = 4.0
	var landed: Array[bool] = [false]
	fx.fly_mote(Vector2(100, 100), Vector2(600, 400), Color.GOLD, func() -> void: landed[0] = true)
	await wait_seconds(0.3)
	assert_true(landed[0], "a 0.32 s flight at 4x lands within 0.3 s")
	assert_eq(fx.get_children().filter(func(child: Node) -> bool: return child is Panel and not child.is_queued_for_deletion()).size(), 0, "the mote is gone")


func test_four_battle_speeds() -> void:
	assert_eq(Settings.BATTLE_SPEED_NAMES, ["1x", "1.5x", "2x", "4x"] as Array[String])
	assert_eq(Settings.BATTLE_SPEEDS.size(), Settings.BATTLE_SPEED_NAMES.size())


func test_a_legendary_makes_its_entrance_without_errors() -> void:
	var data: CardData = load("res://data/cards/B-32.tres") as CardData
	assert_eq(data.rarity, CardEnums.Rarity.LEGENDARY)
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.fx = fx
	board.speed = 4.0
	var view: CardView = CardView.create(data)
	board.add_child(view)
	board.views[77] = view
	await board._legendary_flourish(77, view)
	assert_true(fx.get_child_count() > 0, "rings, sparks and the word were drawn")
