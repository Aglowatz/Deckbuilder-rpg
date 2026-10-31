extends GutTest
## CombatPreview plays a combat out on a clone: the real game never changes, and the numbers match what really happens.


func _combat_game(attacker_data: CardData, blocker_data: CardData) -> Dictionary:
	var game: GameState = GameFactory.blank_game()
	var attacker: CardInstance = GameFactory.add_to_field(game, 0, attacker_data)
	var blocker: CardInstance = GameFactory.add_to_field(game, 1, blocker_data)
	game.advance_phase()
	return {"game": game, "attacker": attacker, "blocker": blocker}


func test_unblocked_attack_predicts_player_damage_without_changing_the_game() -> void:
	var ctx: Dictionary = _combat_game(GameFactory.vanilla(3, 3), GameFactory.vanilla(1, 1))
	var game: GameState = ctx["game"]
	var attacker: CardInstance = ctx["attacker"]
	var preview: Dictionary = CombatPreview.predict(game, 0, [attacker.uid] as Array[int], {})
	assert_true(bool(preview["valid"]))
	assert_eq(int((preview["players"] as Array)[1]), 3, "3 damage reaches the defender if unblocked")
	assert_eq(game.players[1].hp, 10, "the real game is untouched")
	assert_false(attacker.exhausted)
	assert_eq(game.combat_step, GameState.CombatStep.DECLARE_ATTACKERS)


func test_block_preview_marks_deaths_and_matches_the_real_combat() -> void:
	var ctx: Dictionary = _combat_game(GameFactory.vanilla(3, 2), GameFactory.vanilla(2, 4))
	var game: GameState = ctx["game"]
	var attacker: CardInstance = ctx["attacker"]
	var blocker: CardInstance = ctx["blocker"]
	assert_true(game.declare_attackers([attacker.uid] as Array[int]))
	var blocks: Dictionary = {attacker.uid: blocker.uid}
	var preview: Dictionary = CombatPreview.predict(game, 1, [] as Array[int], blocks)
	var units: Dictionary = preview["units"] as Dictionary
	assert_true(bool((units[attacker.uid] as Dictionary)["dies"]), "the 3/2 dies to the 2/4")
	assert_false(bool((units[blocker.uid] as Dictionary)["dies"]))
	assert_eq(int((units[blocker.uid] as Dictionary)["damage"]), 3)
	assert_eq(int((units[blocker.uid] as Dictionary)["hp_left"]), 1, "Overnight Oct 30-31: the 2/4 keeps 1 HP")
	assert_eq(int((preview["players"] as Array)[1]), 0, "blocked: nothing reaches the player")
	assert_true(game.declare_blockers(blocks))
	assert_null(game.find_permanent(attacker.uid), "the real combat agrees")
	assert_eq(blocker.damage, 3)


func test_preview_outside_combat_is_invalid() -> void:
	var game: GameState = GameFactory.blank_game()
	var preview: Dictionary = CombatPreview.predict(game, 0, [] as Array[int], {})
	assert_false(bool(preview["valid"]))
