class_name E2EDemo
extends Node
## Plays the whole demo through the real UI: title -> new game -> town (walk to the Wellspring,
## choose a color, buy a card, edit and save the deck) -> gate -> dungeon map -> tutorial battle
## -> challenge -> battle -> shrine -> boss -> rewards -> Trial complete -> town. Mouse clicks
## and key presses are injected with UiDriver; battles use BattlePilot clicks for the tutorial
## battle and the AI for the rest. Failed duels send the player home and the flow retries.

const SAVE_PATH: String = "user://e2e_save.json"
const TIME_LIMIT_SECONDS: float = 900.0
const MAX_TRIAL_ATTEMPTS: int = 6

var driver: UiDriver
var failures: PackedStringArray = []
var trace: PackedStringArray = []
var _started_ms: int = 0
var _did: Dictionary = {}
var _trial_attempts: int = 0
var _battles: int = 0
var _held_keys: Dictionary = {}
var _stall: int = 0
var _last_key: String = ""


func _check(condition: bool, message: String) -> void:
	if condition:
		trace.append("ok    " + message)
	else:
		failures.append(message)
		trace.append("FAIL  " + message)
		print("E2E FAIL: ", message)


func _note(message: String) -> void:
	trace.append("      " + message)
	print("e2e: ", message)


func run() -> void:
	_started_ms = Time.get_ticks_msec()
	Session.save_path = SAVE_PATH
	SaveSystem.delete(SAVE_PATH)
	Session.rng.seed = 12345
	driver = UiDriver.new(get_tree())
	await driver.frames(20)
	var last_scene: Node = null
	while not _did.has("finished"):
		if float(Time.get_ticks_msec() - _started_ms) / 1000.0 > TIME_LIMIT_SECONDS:
			_check(false, "finished within %d seconds" % int(TIME_LIMIT_SECONDS))
			break
		var scene: Node = get_tree().current_scene
		if scene == null or SceneManager.busy:
			await driver.frames(5)
			continue
		if scene != last_scene:
			last_scene = scene
			_note("scene: %s" % scene.get_script().get_global_name())
			_stall = 0
			await driver.seconds(0.6)
		if scene is TitleScreen:
			await _title(scene as TitleScreen)
		elif scene is TownScene:
			await _town(scene as TownScene)
		elif scene is DungeonMapScreen:
			await _map(scene as DungeonMapScreen)
		elif scene is BattleScreen:
			await _battle(scene as BattleScreen)
		elif scene is RewardsScreen:
			await _rewards(scene as RewardsScreen)
		else:
			await driver.frames(10)
		var key: String = _progress_key()
		if key != _last_key:
			_last_key = key
			_stall = 0
		_stall += 1
		if _stall > 60:
			_check(false, "no progress in scene %s" % _scene_name())
			break
	_report()


func _scene_name() -> String:
	var current: Node = get_tree().current_scene
	return current.get_script().get_global_name() if current != null and current.get_script() != null else "?"


func _progress_key() -> String:
	var cleared: int = Session.dungeon_map.cleared.size() if Session.dungeon_map != null else -1
	var owned: int = Session.profile.owned_cards.size() if Session.profile != null else -1
	return "%s|%d|%d|%d|%d|%d" % [_scene_name(), Session.flags.size(), Session.gold, owned, cleared, Session.run.life if Session.run != null else -1]


func _report() -> void:
	var seconds: float = float(Time.get_ticks_msec() - _started_ms) / 1000.0
	if failures.is_empty():
		print("E2E PASSED in %.0fs (%d trial attempts, %d battles)" % [seconds, _trial_attempts, _battles])
	else:
		print("E2E FAILED: %d problem(s)" % failures.size())
		for line: String in trace:
			print(line)
		get_tree().root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://_screenshots/e2e_fail.png"))
	SaveSystem.delete(SAVE_PATH)
	get_tree().quit(0 if failures.is_empty() else 1)


# ---- Title -----------------------------------------------------------------------------


func _title(_screen: TitleScreen) -> void:
	_check(not Session.has_save(), "no save exists at the start")
	_check(driver.find_button("Continue") == null, "title has no Continue without a save")
	_check(driver.find_button("Settings") != null, "title has a Settings button")
	await driver.click_button("New Game")
	await driver.seconds(1.0)


# ---- Town ------------------------------------------------------------------------------


func _spot(scene: TownScene, id: String) -> TownScene.Spot:
	for spot: TownScene.Spot in scene.spots:
		if spot.id == id:
			return spot
	return null


func _walk_to(scene: TownScene, id: String, must_walk: bool = false) -> void:
	var spot: TownScene.Spot = _spot(scene, id)
	var elapsed: float = 0.0
	while elapsed < 9.0:
		var offset: Vector3 = spot.position - scene.player.position
		offset.y = 0.0
		if offset.length() < spot.radius * 0.55:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	var reached: bool = Vector2(scene.player.position.x - spot.position.x, scene.player.position.z - spot.position.z).length() < spot.radius
	if must_walk:
		_check(reached, "the hero can walk to the %s with the keyboard" % id)
	if not reached:
		scene.player.position = spot.position + Vector3(0, 0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _interact(scene: TownScene, id: String, walk: bool = false) -> void:
	await _walk_to(scene, id, walk)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)


func _town(scene: TownScene) -> void:
	# Overlays first.
	var overlay: Control = scene._overlay
	if overlay is WellspringChoice:
		await _choose_wellspring(overlay as WellspringChoice)
		return
	if overlay is VendorScreen:
		await _shop(overlay as VendorScreen)
		return
	if overlay is DeckbuilderScreen:
		await _edit_deck(overlay as DeckbuilderScreen)
		return
	if scene.dialogue.active:
		await driver.tap_key(KEY_E)
		await driver.seconds(0.4)
		return
	if driver.find_button("Enter") != null and scene._locked:
		await driver.click_button("Enter")
		await driver.seconds(1.5)
		return
	if scene._locked:
		await driver.frames(10)
		return
	if Session.flag(&"trial_cleared"):
		_final_checks(scene)
		_did["finished"] = true
		return
	if not Session.flag(&"wellspring_chosen"):
		_check(scene.hud._objective.text.contains("Wellspring"), "the first objective points at the Wellspring")
		_check(Session.gold == Session.STARTING_GOLD, "the game starts with %d gold" % Session.STARTING_GOLD)
		if not _did.has("elder"):
			_did["elder"] = true
			await _interact(scene, "elder")
			return
		await _interact(scene, "well", true)
		return
	if not _did.has("vendor"):
		_did["vendor"] = true
		await _interact(scene, "vendor")
		return
	if not _did.has("deck"):
		_did["deck"] = true
		await _interact(scene, "deck")
		return
	_trial_attempts += 1
	_note("entering the trial (attempt %d)" % _trial_attempts)
	if _trial_attempts > MAX_TRIAL_ATTEMPTS:
		_check(false, "the trial was cleared within %d attempts" % MAX_TRIAL_ATTEMPTS)
		_did["finished"] = true
		return
	_check(Session.deck_is_valid(), "the deck is legal before entering the dungeon")
	await _interact(scene, "guard")
	while scene.dialogue.active:
		await driver.tap_key(KEY_E)
		await driver.seconds(0.3)
	await _interact(scene, "gate")


func _choose_wellspring(choice: WellspringChoice) -> void:
	_check(choice._confirm.disabled, "the Wellspring needs a choice before confirming")
	var tile: Button = choice._tiles[Affinity.Type.A] as Button
	await driver.click(driver.center_of_control(tile))
	_check(choice.selected == Affinity.Type.A, "clicking the Ember tile selects it")
	await driver.click_button("Answer the call")
	await driver.seconds(0.8)
	_check(Session.has_profile() and Session.profile.primary_affinity == Affinity.Type.A, "the Wellspring sets the primary affinity")
	_check(Session.deck.size() == 45, "the starter deck has 45 cards")
	_check(Session.deck_is_valid(), "the starter deck is legal")
	_check(Session.owned_count("sellsword") == 3, "the collection holds the neutral starter cards")


func _shop(vendor: VendorScreen) -> void:
	var card: CardData = Session.content.card("ember_imp")
	var before_gold: int = Session.gold
	var before_owned: int = Session.owned_count(card.id)
	for tile: Control in vendor._tiles:
		if str(tile.get_meta("card_id")) == card.id:
			await driver.click(driver.center_of_control(tile.get_child(0) as Control))
	await driver.seconds(0.4)
	_check(driver.find_button("Buy") != null, "buying asks for confirmation")
	await driver.click_button("Buy")
	await driver.seconds(0.4)
	_check(Session.owned_count(card.id) == before_owned + 1, "the purchased card joins the collection")
	_check(Session.gold == before_gold - CardPricing.price(card), "the price is paid in gold")
	await driver.click_button("Leave")
	await driver.seconds(0.4)


func _edit_deck(screen: DeckbuilderScreen) -> void:
	var card: CardData = Session.content.card("ember_imp")
	var tile: Control = null
	for candidate: Node in screen._grid.get_children():
		if str(candidate.get_meta("card_id")) == card.id:
			tile = candidate as Control
	_check(tile != null, "the deck station lists the bought card")
	var view_center: Vector2 = driver.center_of_control(tile.get_child(0) as Control)
	await driver.click(view_center)
	_check(screen.editor.count(card) == 1, "clicking a card adds it to the deck")
	await driver.click(view_center, MOUSE_BUTTON_RIGHT)
	_check(screen.editor.count(card) == 0, "right-clicking removes it again")
	# Break a rule on purpose: 44 cards is illegal and the panel says so.
	var neutral: CardData = Session.content.card("sellsword")
	screen.editor.remove(neutral)
	screen.editor.remove(neutral)
	screen._refresh()
	_check(not screen.editor.is_valid(), "a 43 card deck is reported as illegal")
	await driver.click_button("Reset")
	_check(screen.editor.is_valid(), "Reset restores the saved legal deck")
	await driver.click(view_center)
	_check(screen.editor.count(card) == 1, "the new card is added again")
	await driver.click_button("Save Deck")
	await driver.seconds(0.3)
	_check(Session.deck.count_of(card.id) == 1 and Session.deck.size() == 46, "Save Deck stores the edited deck")
	_check(Session.deck_is_valid(), "the edited deck is legal")
	await driver.click_button("Close")
	await driver.seconds(0.4)


# ---- Dungeon map -----------------------------------------------------------------------


func _map(scene: DungeonMapScreen) -> void:
	if scene._modal != null:
		var modal: Control = scene._modal
		if modal is ChallengeScreen:
			await driver.click_button("Reveal")
			await driver.seconds(3.0)
			_check(driver.find_button("Continue") != null, "the challenge shows an outcome")
			await driver.click_button("Continue")
		elif modal is ShrineScreen:
			var before: int = Session.run.life
			await driver.click_button("Rest")
			await driver.seconds(1.2)
			_check(Session.run.life >= before, "the shrine never lowers life")
			await driver.click_button("Continue")
		await driver.seconds(1.0)
		return
	var tip: Button = driver.find_button("Got it")
	if tip != null:
		await driver.click(driver.button_center(tip))
	var available: Array[DungeonMap.MapNode] = scene.map.available()
	if available.is_empty():
		await driver.frames(10)
		return
	var button: MapNodeButton = scene._buttons[available[0].id] as MapNodeButton
	_note("map: entering %s (life %d)" % [available[0].title, Session.run.life])
	await driver.click(driver.center_of_control(button))
	await driver.seconds(1.0)


# ---- Battle ----------------------------------------------------------------------------


func _battle(screen: BattleScreen) -> void:
	_battles += 1
	var use_clicks: bool = _battles == 1
	screen.board.speed = 8.0
	var pilot: BattlePilot = BattlePilot.new(driver, screen)
	if not use_clicks:
		screen.set_bot(AIPlayer.new(AIPersonality.balanced()))
	if screen.tutorial != null and use_clicks:
		_check(true, "the tutorial layer is active in the first battle")
	var stalled: int = 0
	var events_seen: int = 0
	while true:
		if screen.mode == BattleScreen.Mode.OVER and screen._result_panel != null:
			break
		if screen.busy or screen.mode == BattleScreen.Mode.WAITING or not use_clicks:
			await driver.frames(6)
		else:
			await pilot.act()
			await driver.frames(3)
		if screen.game.events.size() == events_seen:
			stalled += 1
		else:
			stalled = 0
			events_seen = screen.game.events.size()
		if stalled > 500:
			_check(false, "battle %d kept making progress" % _battles)
			return
		if float(Time.get_ticks_msec() - _started_ms) / 1000.0 > TIME_LIMIT_SECONDS:
			return
	var won: bool = screen.game.winner == 0
	_note("battle %d vs %s: %s in %d turns (life %d)" % [_battles, screen.context.enemy_name, "won" if won else "lost", screen.game.turn, screen.game.players[0].life])
	await driver.seconds(1.2)
	await driver.click_button("Continue")
	await driver.seconds(1.0)


# ---- Rewards and trial complete --------------------------------------------------------


func _rewards(scene: RewardsScreen) -> void:
	var back: Button = driver.find_button("Return to town")
	if back != null:
		await driver.seconds(1.8)
		var owned_before: int = 0
		for card: CardData in Session.profile.owned_cards:
			owned_before += 1
		_check(Session.profile.intro_dungeon_cleared, "clearing the trial attunes the player")
		await driver.click(driver.button_center(back))
		await driver.seconds(1.0)
		return
	if not scene._cards.is_empty() and scene._selected < 0:
		var gold_before: int = Session.gold
		await driver.click(driver.center_of_control(scene._cards[0]))
		await driver.seconds(0.3)
		_check(scene._take_button != null and not scene._take_button.disabled, "choosing a reward card enables Take")
		var offered: CardData = scene._offer.cards[0]
		var owned_before: int = Session.owned_count(offered.id)
		var reward_gold: int = scene._offer.gold
		var take: Button = driver.find_button("Take")
		await driver.click(driver.button_center(take))
		await driver.seconds(1.5)
		_check(Session.gold == gold_before + reward_gold, "victory pays %d gold" % reward_gold)
		_check(Session.owned_count(offered.id) == owned_before + 1, "the chosen reward card joins the collection")
		return
	await driver.click_button("Continue")
	await driver.seconds(1.0)


# ---- Final assertions ------------------------------------------------------------------


func _final_checks(scene: TownScene) -> void:
	var granted: Array[CardData] = CampaignStart.attunement_cards(Session.content, Session.profile.primary_affinity)
	for card: CardData in granted:
		_check(Session.owned_count(card.id) >= 1, "attunement card %s is owned" % card.display_name)
	_check(Session.profile.intro_dungeon_cleared, "the intro dungeon is marked cleared")
	_check(Session.gold > Session.STARTING_GOLD - 30, "gold was earned in the dungeon")
	_check(not Session.in_dungeon(), "no dungeon run is active back in town")
	_check(SaveSystem.exists(SAVE_PATH), "the game was saved")
	var saved: Dictionary = SaveSystem.read(SAVE_PATH)
	_check(int(saved.get("gold", -1)) == Session.gold, "the save holds the current gold")
	_check(bool((saved.get("flags", {}) as Dictionary).get("trial_cleared", false)), "the save remembers the cleared trial")
	var fresh: Node = Node.new()
	fresh.free()
	_check(scene.hud._objective.text.contains("cleared"), "the town objective reflects the cleared trial")
