extends Node
## New brief, Part F: human-input regression test for using an equipped item in battle -
## equips Scroll of Insight (draw a card, no target needed) and Firebrand Charm (deal 2 damage,
## needs a target) before a real practice battle, then clicks the item bar with real input.
## Run windowed (not headless - injected input needs a real viewport):
##   Godot --path . res://tools/battle_item_smoke.tscn
## Exit code 0 = every check passed; 1 = a check failed.

var driver: UiDriver
var screen: BattleScreen
var _failures: PackedStringArray = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	Session.ensure_game()
	Session.profile.item_slots = 2
	var scroll: ItemData = Session.content.item("scroll_of_insight")
	var firebrand: ItemData = Session.content.item("firebrand_charm")
	Session.add_item(scroll)
	Session.add_item(firebrand)
	_check(Session.profile.equip_item_id(scroll), "can equip Scroll of Insight")
	_check(Session.profile.equip_item_id(firebrand), "can equip Firebrand Charm")

	var packed: PackedScene = load("res://scenes/battle.tscn") as PackedScene
	screen = packed.instantiate() as BattleScreen
	screen.screenshot_prepare({"enemy": "Cave Scavenger", "no_tutorial": "true"})
	get_tree().root.add_child(screen)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	screen.board.speed = 10.0
	await _wait_for_main()
	_check(screen.mode == BattleScreen.Mode.MAIN, "the battle actually reaches the player's main phase")

	_check(screen.item_bar != null, "the item bar exists when items are equipped")
	if screen.item_bar == null:
		_finish(false, "no item bar")
		return

	# Non-targeted: Scroll of Insight (draw a card).
	var hand_before: int = screen.game.players[0].hand.size()
	var uses_before: int = Session.profile.item_uses_left(scroll)
	await driver.click(_slot_center(0))
	await driver.frames(6)
	_check(screen.game.players[0].hand.size() == hand_before + 1, "clicking Scroll of Insight draws a card")
	_check(Session.profile.item_uses_left(scroll) == uses_before - 1, "using it spends a charge")

	# Targeted: Firebrand Charm (deal 2 damage) - needs an enemy creature on the board. The AI
	# starting hand may not have one out yet, so pass turns (via BattlePilot) until it does.
	var pilot: BattlePilot = BattlePilot.new(driver, screen)
	var found_target: bool = await _get_an_enemy_creature_out(pilot)
	_check(found_target, "an enemy creature eventually takes the field")
	if found_target and screen.mode == BattleScreen.Mode.MAIN:
		var enemy_creature: CardInstance = screen.game.players[1].creatures()[0]
		var damage_before: int = enemy_creature.damage
		await driver.click(_slot_center(1))
		await driver.frames(3)
		_check(screen.mode == BattleScreen.Mode.TARGETING, "a targeted item enters targeting mode")
		var view: CardView = screen.board.view_for(enemy_creature.uid)
		await driver.click(driver.center_of_control(view))
		await driver.frames(6)
		# 2 damage may well be lethal against a weak tutorial creature - a dead creature's damage
		# resets on the way to the graveyard, so "it died" is just as much proof the 2 damage
		# landed as "its damage counter went up by 2".
		var died: bool = not screen.game.players[1].creatures().has(enemy_creature)
		_check(died or enemy_creature.damage == damage_before + 2, "clicking a target actually deals the item's damage")

	_finish(_failures.is_empty(), "checked using an equipped item in battle (untargeted + targeted)")


# ---- Helpers --------------------------------------------------------------------------------


func _slot_center(index: int) -> Vector2:
	var local: Vector2 = Vector2(index * (ItemBar.SLOT_SIZE.x + ItemBar.SPACING) + ItemBar.SLOT_SIZE.x * 0.5, ItemBar.SLOT_SIZE.y * 0.5)
	return screen.item_bar.position + local


func _wait_for_main() -> void:
	var elapsed: float = 0.0
	while screen.mode != BattleScreen.Mode.MAIN and elapsed < 20.0:
		if screen.mode == BattleScreen.Mode.MULLIGAN and not screen.busy:
			await driver.click_button("Keep Hand")
		await driver.frames(3)
		elapsed += 3.0 / 60.0


## Passes/plays turns (via BattlePilot) until an enemy creature is on the board and it is the
## player's main phase again, or we give up.
func _get_an_enemy_creature_out(pilot: BattlePilot) -> bool:
	var elapsed: float = 0.0
	while elapsed < 60.0:
		if screen.mode == BattleScreen.Mode.MAIN and not screen.game.players[1].creatures().is_empty():
			return true
		if screen.mode == BattleScreen.Mode.OVER:
			return false
		if screen.busy or screen.mode == BattleScreen.Mode.WAITING:
			await driver.frames(4)
		else:
			await pilot.act()
			await driver.frames(3)
		elapsed += 3.0 / 60.0
	return false


func _check(condition: bool, message: String) -> void:
	if condition:
		print("battle_item_smoke: ok    ", message)
	else:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("battle_item_smoke: FAIL  ", message)
	push_error("battle_item_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("battle_item_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
