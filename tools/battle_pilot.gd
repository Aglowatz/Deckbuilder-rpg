class_name BattlePilot
extends RefCounted
## A simple click-driven player used by the smoke and end-to-end tests. It plays a land, casts
## its most expensive card (dragging the first plain one), attacks with everything and blocks
## when it is safe or necessary, all through real mouse input.

var driver: UiDriver
var screen: BattleScreen
var dragged_once: bool = false


func _init(ui_driver: UiDriver, battle: BattleScreen) -> void:
	driver = ui_driver
	screen = battle


func _view_center(uid: int) -> Vector2:
	return driver.center_of_control(screen.board.view_for(uid))


## Performs one decision for the current human mode.
func act() -> void:
	var game: GameState = screen.game
	match screen.mode:
		BattleScreen.Mode.MULLIGAN:
			await driver.click_button("Keep Hand")
		BattleScreen.Mode.MAIN:
			await _act_main(game)
		BattleScreen.Mode.ATTACK:
			for card: CardInstance in game.possible_attackers(0):
				if game.get_power(card) > 0:
					await driver.click(_view_center(card.uid))
			var attack: Button = driver.find_button("Attack with")
			if attack == null:
				attack = driver.find_button("No Attack")
			await driver.click(driver.button_center(attack))
		BattleScreen.Mode.BLOCK:
			var used: Array[int] = []
			for attacker_uid: int in game.attackers:
				var attacker: CardInstance = game.find_permanent(attacker_uid)
				for blocker: CardInstance in game.possible_blockers(0):
					if used.has(blocker.uid) or attacker == null or not CombatResolver.can_block(attacker, blocker):
						continue
					if game.get_toughness(blocker) > game.get_power(attacker) or game.players[0].life <= game.get_power(attacker) * 2:
						used.append(blocker.uid)
						await driver.click(_view_center(blocker.uid))
						await driver.click(_view_center(attacker_uid))
						break
			var confirm: Button = driver.find_button("Confirm Blocks")
			if confirm == null:
				confirm = driver.find_button("No Blocks")
			await driver.click(driver.button_center(confirm))
		BattleScreen.Mode.DISCARD:
			for card: CardInstance in game.players[0].hand.slice(0, game.pending_discard):
				await driver.click(_view_center(card.uid))
			await driver.click_button("Discard")
		BattleScreen.Mode.TARGETING:
			var target: int = screen._target_options[0]
			if target > 0:
				await driver.click(_view_center(target))
			else:
				await driver.click(screen.hud.portrait_rect(Targets.player_index(target)).get_center())


func _act_main(game: GameState) -> void:
	var player: PlayerState = game.players[0]
	for card: CardInstance in player.hand:
		if card.data.is_land() and game.can_play_land(0, card.uid):
			await driver.click(_view_center(card.uid))
			return
	var best: CardInstance = null
	for card: CardInstance in player.hand:
		if not card.data.is_land() and game.can_cast(0, card.uid):
			if best == null or card.data.mana_value() > best.data.mana_value():
				best = card
	if best != null:
		if not dragged_once and best.data.effects.is_empty():
			dragged_once = true
			await driver.drag(_view_center(best.uid), Vector2(985, 480))
		else:
			await driver.click(_view_center(best.uid))
		return
	var next: Button = driver.find_button("To Combat")
	if next == null:
		next = driver.find_button("End Turn")
	await driver.click(driver.button_center(next))
