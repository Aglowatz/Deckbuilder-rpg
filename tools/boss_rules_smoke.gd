class_name BossRulesSmoke
extends Node
## Daytime Oct 19 (loop cycle 5): the windowed check of today's boss-rule flows outside the dungeon maps. Grand Bellows from the Arena
## screen and Shiro from his chest: each shows the "Before the fight" brief with its rule icons, Continue (a real click) starts the duel,
## the battle HUD carries the same rules as an icon row, and the enemy seat holds the rules. Run alone:  bash tools/run_boss_rules_smoke.sh

var driver: UiDriver
var _failures: PackedStringArray = []


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	driver = UiDriver.new(get_tree())
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish("town never loaded")
		return
	await driver.seconds(1.0)
	# 1. The Arena: pick Grand Bellows -> the brief -> Continue -> his duel with both rules.
	town.call(&"_open_arena")
	await driver.seconds(0.6)
	var arena: ArenaScreen = town._overlay as ArenaScreen
	_check(arena != null, "the Arena screen opens")
	if arena != null:
		arena.fight_chosen.emit("arena_marshal")
		await driver.seconds(0.6)
		await _brief_then_battle("Grand Bellows", ["Crowd Favourite", "Heckling Crowd"])
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish("town never came back after the arena duel")
		return
	await driver.seconds(1.0)
	if town._overlay != null:
		town._close_overlay()
		await driver.seconds(0.3)
	# 2. Shiro: his lines at the chest -> the brief -> Continue -> his duel with his rules.
	town.call(&"_start_ninja_fight")
	for _guard: int in range(40):
		if not town.dialogue.active:
			break
		await driver.tap_key(KEY_E)
		await driver.seconds(0.25)
	await driver.seconds(0.4)
	await _brief_then_battle(NinjaBoss.DISPLAY_NAME, ["The Oldest Trick", "Smoke and Mirrors"])
	_finish("")


func _brief_then_battle(foe: String, rules: Array[String]) -> void:
	var brief: RulesBrief = get_tree().root.find_child("RulesBrief", true, false) as RulesBrief
	_check(brief != null, "%s: the 'Before the fight' brief shows" % foe)
	if brief == null:
		return
	var names: Array[String] = []
	for badge: RuleBadges.Badge in brief.badges:
		names.append(badge.name)
	for rule: String in rules:
		_check(names.has(rule), "%s: the brief lists %s" % [foe, rule])
	_check(brief.find_child("RuleIconRow", true, false) != null, "%s: the brief has the rule icons" % foe)
	await driver.seconds(0.4)
	get_viewport().get_texture().get_image().save_png("res://_screenshots/boss_rules_%s.png" % foe.split(" ")[0].to_lower())
	_check(await driver.click_button("Continue"), "%s: Continue is clickable" % foe)
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "%s: Continue starts the duel" % foe)
	if battle == null:
		return
	await driver.seconds(1.0)
	var row: RuleIconRow = battle.find_child("RuleIconRow", true, false) as RuleIconRow
	_check(row != null and row.badges.size() >= rules.size(), "%s: the battle HUD shows the rules (%d icons)" % [foe, row.badges.size() if row != null else 0])
	_check(battle.context.game.players[1].modifiers.has(Modifier.Kind.STAT_CHANGE), "%s: the enemy seat carries the stat rule" % foe)
	battle.context.game._end_game(0, false)
	battle.context.won = true
	Session.complete_battle(battle.context)
	await driver.seconds(1.0)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 30.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _check(condition: bool, message: String) -> void:
	if condition:
		print("boss_rules_smoke: ok    ", message)
	else:
		_failures.append(message)
		print("boss_rules_smoke: FAIL  ", message)
		push_error("boss_rules_smoke: " + message)


func _finish(reason: String) -> void:
	var ok: bool = _failures.is_empty() and reason.is_empty()
	print("boss_rules_smoke: %s%s" % ["OK" if ok else "FAILED", (" - " + reason) if not reason.is_empty() else ""])
	get_tree().quit(0 if ok else 1)
