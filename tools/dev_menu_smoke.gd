extends Node
## Oct 20, Part 1: the Dev Menu in the live game (windowed, injected F10). Opens it in Crosspath and shoots every tab, travels to a zone and
## the Capital inside the gate, starts a fight from the menu and wins it with "Win now", jumps to a dungeon's boss node, and saves and loads
## a snapshot.   bash tools/run_dev_menu_smoke.sh   (run alone)

var driver: UiDriver
var _failures: PackedStringArray = []
const OUT: String = "res://_screenshots/oct20d/"


func _ready() -> void:
	_run.call_deferred()


func _shot(name: String) -> void:
	await driver.frames(4)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("dev_menu_smoke: screenshot -> %s.png" % name)


func _wait_for(check: Callable, limit: float = 12.0) -> bool:
	var waited: float = 0.0
	while not bool(check.call()) and waited < limit:
		await driver.seconds(0.25)
		waited += 0.25
	return bool(check.call())


func _run() -> void:
	Session.save_enabled = false
	driver = UiDriver.new(get_tree())
	SceneManager.show_loading_screens = false
	get_tree().current_scene = null
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	Session.set_flag(&"trial_cleared")
	SceneManager.go_to_town()
	_check(await _wait_for(func() -> bool: return get_tree().current_scene is TownScene and not SceneManager.busy), "Crosspath loads")
	await driver.seconds(2.0)
	var menu: DevMenu = SceneManager.dev_menu
	_check(menu != null, "the Dev Menu is installed (debug build)")
	await driver.tap_key(KEY_F10)
	await driver.frames(20)
	_check(menu.is_open() and get_tree().paused, "F10 opens it in Crosspath and pauses the world")
	for index: int in range(DevMenu.TABS.size()):
		menu.show_page(index)
		await _shot("p1_dev_%d_%s" % [index + 1, DevMenu.TABS[index].to_lower()])
	# Player tab through the real systems
	menu._act(DevActions.set_level.bind(5, false))
	_check(Session.profile.level == 5, "Player: level 5 through real level-ups")
	menu._act(DevActions.add_gold.bind(1000))
	await driver.tap_key(KEY_F10)
	await driver.frames(10)
	_check(not menu.is_open() and not get_tree().paused, "F10 closes it")
	# travel to a zone
	menu.open_menu()
	menu._act(DevActions.travel_zone.bind("necrocrat"), true)
	_check(await _wait_for(func() -> bool: return get_tree().current_scene is ZoneScene and not SceneManager.busy, 25.0), "Travel: the D.N.A. loads")
	_check(not get_tree().paused, "travel unpauses the world")
	await driver.seconds(1.5)
	# a fight from the menu, won with Win now
	menu._act(DevActions.start_encounter.bind(DevActions.find_encounters("tutorial", 1)[0].id, Affinity.Type.BEEFCAKE), true)
	_check(await _wait_for(func() -> bool: return get_tree().current_scene is BattleScreen and not SceneManager.busy, 20.0), "Battle: a fight starts from the menu")
	await driver.seconds(3.0)
	await driver.tap_key(KEY_F10)
	await driver.frames(10)
	menu.show_page(3)
	await _shot("p1_dev_battle_live")
	menu._act(DevActions.draw_cards.bind(menu._battle(), 2))
	menu._act(DevActions.add_resource.bind(menu._battle(), ResourceKind.Kind.IRON, 1))
	menu._act(DevActions.reveal_enemy_hand.bind(menu._battle()))
	menu._act(func() -> String: return DevActions.end_battle(menu._battle(), true), true)
	_check(await _wait_for(func() -> bool: return driver.find_button("Continue") != null or get_tree().current_scene is TownScene, 20.0), "Win now shows the result")
	if driver.find_button("Continue") != null:
		await driver.click_button("Continue")
	_check(await _wait_for(func() -> bool: return get_tree().current_scene is TownScene and not SceneManager.busy, 25.0), "a menu fight returns to Crosspath")
	# view tools
	await driver.seconds(2.0)
	menu._set_walk_overlay(true)
	menu.show_fps = true
	menu._fps_label.visible = true
	await driver.seconds(1.0)
	_check(menu._walk_overlay != null and menu._walk_overlay.multimesh.instance_count > 0, "View: the walkable overlay draws round the hero")
	await _shot("p1_dev_walk_overlay")
	menu._set_walk_overlay(false)
	menu._set_free_camera(true)
	_check(get_tree().paused and get_viewport().get_camera_3d() is DevFreeCamera, "View: the free camera takes over and the world pauses")
	menu._set_free_camera(false)
	_check(not get_tree().paused and not (get_viewport().get_camera_3d() is DevFreeCamera), "View: the game camera comes back")
	# Capital inside
	menu._act(DevActions.travel_capital_inside, true)
	_check(await _wait_for(func() -> bool: return get_tree().current_scene is CapitalScene and not SceneManager.busy, 30.0), "Travel: the Capital inside the gate")
	await driver.seconds(2.0)
	await _shot("p1_dev_capital_inside")
	# a dungeon's boss node
	menu._act(DevActions.travel_dungeon.bind("D-HOG", -2), true)
	_check(await _wait_for(func() -> bool: return get_tree().current_scene is DungeonMapScreen and not SceneManager.busy, 25.0), "Travel: the House of Gains map")
	_check(Session.dungeon_map != null and Session.dungeon_map.is_available(Session.dungeon_map.boss().id), "the party stands next to the boss")
	await driver.seconds(2.0)
	await _shot("p1_dev_dungeon_boss")
	# snapshot round trip
	DevActions.save_snapshot("dev smoke")
	var gold: int = Session.gold
	Session.gold += 5
	DevActions.load_snapshot("dev smoke")
	_check(Session.gold == gold, "a snapshot loads back (gold %d)" % Session.gold)
	DevActions.delete_snapshot("dev smoke")
	await driver.seconds(3.0)
	_finish()


func _check(ok: bool, what: String) -> void:
	if ok:
		print("dev_menu_smoke: ok    %s" % what)
	else:
		_failures.append(what)
		print("dev_menu_smoke: FAIL  %s" % what)


func _finish() -> void:
	print("dev_menu_smoke: %s" % ("OK - the Dev Menu in the live game" if _failures.is_empty() else "FAILED: " + "; ".join(_failures)))
	get_tree().paused = false
	get_tree().quit(0 if _failures.is_empty() else 1)
