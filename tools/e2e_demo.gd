class_name E2EDemo
extends Node
## Plays the whole demo through the real UI: title -> new game -> starting area (wake up, choose
## an element) -> dungeon map (tries the in-dungeon deck builder once) -> tutorial battle ->
## challenge -> battle -> shrine -> boss (forcing a multi-level jump on the first win, walking
## through the level-up recap -> equipment choice -> card offer chain) -> rewards (on-element
## picks grow the deck to 45) -> town (buy a card, edit and save the deck, open a hidden chest,
## buy and equip an item from Wick, challenge a corrupted NPC and use the equipped item mid-duel -
## a real loss here is retried, not scripted to win, D71 - then the now-unlocked zone entrance,
## reopen the deck builder with the B hotkey). Mouse clicks and key presses are injected with
## UiDriver; battles use BattlePilot clicks for the tutorial battle and the corrupted-NPC fight,
## the AI for the rest. Failed tutorial duels send the player back to the starting area to retry,
## same as a human would see; a lost corrupted-NPC duel just returns to town and is retried there
## (D68 - they can always be challenged again).

const SAVE_PATH: String = "user://e2e_save.json"
const TIME_LIMIT_SECONDS: float = 900.0

var driver: UiDriver
var failures: PackedStringArray = []
var trace: PackedStringArray = []
var _started_ms: int = 0
var _did: Dictionary = {}
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
	# The launcher passes --no-save (so nothing here can ever touch the real player's save),
	# which disables Session.save_game() entirely - but this run needs real saves to happen, to
	# its own safe path above, so it can verify save/load. Re-enable now that the path is safe.
	Session.save_enabled = true
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
		elif scene is StartingAreaScene:
			await _starting_area(scene as StartingAreaScene)
		elif scene is TownScene:
			await _town(scene as TownScene)
		elif scene is DungeonMapScreen:
			await _map(scene as DungeonMapScreen)
		elif scene is BattleScreen:
			await _battle(scene as BattleScreen)
		elif scene is RewardsScreen:
			await _rewards(scene as RewardsScreen)
		elif scene is ZonePlaceholderScene:
			await _zone_placeholder(scene as ZonePlaceholderScene)
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
		print("E2E PASSED in %.0fs (%d battles)" % [seconds, _battles])
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


# ---- Starting area -----------------------------------------------------------------------


func _starting_area(scene: StartingAreaScene) -> void:
	if scene.dialogue.active:
		await driver.tap_key(KEY_E)
		await driver.seconds(0.4)
		return
	var choice: ElementChoiceScreen = _find_element_choice(scene)
	if choice != null:
		await _choose_element(choice)
		return
	if scene._locked:
		if driver.find_button("Enter") != null:
			await driver.click_button("Enter")
			await driver.seconds(1.0)
		else:
			await driver.frames(10)
		return
	_check(Session.flag(&"awakened"), "the wake-up dialogue played")
	await _walk_to_gate(scene)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)


func _find_element_choice(scene: StartingAreaScene) -> ElementChoiceScreen:
	for child: Node in scene._overlay_layer.get_children():
		if child is ElementChoiceScreen:
			return child as ElementChoiceScreen
	return null


## Part C: the element choice happens before the dungeon even starts. Always picks Ember (A) -
## every later Ember-specific check in this driver depends on that.
func _choose_element(choice: ElementChoiceScreen) -> void:
	_check(choice._confirm.disabled, "the element choice needs a pick before confirming")
	var tile: Button = choice._tiles[Affinity.Type.A] as Button
	await driver.click(driver.center_of_control(tile))
	_check(choice.selected == Affinity.Type.A, "clicking the Ember tile selects it")
	await driver.click_button("Begin")
	await driver.seconds(1.0)
	_check(Session.has_profile() and Session.profile.primary_affinity == Affinity.Type.A, "choosing an element sets the primary affinity")
	_check(Session.deck.size() == TrialOfTheHollow.STARTER_DECK_SIZE, "the starter deck is %d cards" % TrialOfTheHollow.STARTER_DECK_SIZE)
	_check(not Session.deck_is_valid(), "the starter deck is short of the plain 45-card minimum")
	_check(Session.in_dungeon(), "choosing an element enters the tutorial dungeon")


func _walk_to_gate(scene: StartingAreaScene) -> void:
	var gate: Vector3 = scene.area.anchors.get("gate", Vector3.ZERO) as Vector3
	var elapsed: float = 0.0
	while elapsed < 9.0:
		var offset: Vector3 = gate - scene.player.position
		offset.y = 0.0
		if offset.length() < StartingAreaScene.INTERACT_RADIUS * 0.55:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	var reached: bool = Vector2(scene.player.position.x - gate.x, scene.player.position.z - gate.z).length() < StartingAreaScene.INTERACT_RADIUS
	_check(reached, "the hero can walk to the cave mouth with the keyboard")
	if not reached:
		scene.player.position = gate + Vector3(0, 0, 0.4)
		await driver.frames(3)


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


## Scrolls `control`'s nearest ScrollContainer ancestor so it is actually on screen before a click
## lands on it - a grid of every card in the game (vendor stock, the deck station's collection)
## does not all fit in one screen, and a click computed from an off-screen control's position
## lands wherever that coordinate falls (or nowhere), not on the control itself.
func _scroll_into_view(control: Control) -> void:
	var scroller: ScrollContainer = null
	var node: Node = control.get_parent()
	while node != null:
		if node is ScrollContainer:
			scroller = node as ScrollContainer
			break
		node = node.get_parent()
	if scroller == null:
		return
	scroller.scroll_vertical = maxi(0, roundi(control.position.y - 40.0))
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


## New brief, Part D: hidden chests have no Spot (see tools/zone_entrances_smoke.gd's own copy of
## this same walker for hidden chests, which have no Spot either).
func _walk_to_position(scene: TownScene, target: Vector3, radius: float) -> void:
	var elapsed: float = 0.0
	while elapsed < 9.0:
		var offset: Vector3 = target - scene.player.position
		offset.y = 0.0
		if offset.length() < radius * 0.55:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	var reached: bool = Vector2(scene.player.position.x - target.x, scene.player.position.z - target.z).length() < radius
	if not reached:
		scene.player.position = target + Vector3(0, 0, 0.4)
		await driver.frames(3)


func _town(scene: TownScene) -> void:
	# Overlays first.
	var overlay: Control = scene._overlay
	if overlay is VendorScreen:
		await _shop(overlay as VendorScreen)
		return
	if overlay is DeckbuilderScreen:
		# The full add/remove/validate/save exercise (_edit_deck) already ran once, at the deck
		# station; reopening it later via the B hotkey (FINAL) just needs to prove the hotkey
		# itself works, not repeat that whole test against the same card a second time. Gated on
		# "deck_edited" (set at the END of _edit_deck), not "deck" (set BEFORE the station is even
		# walked to, to guard the step itself starting only once) - checking "deck" here would
		# always see it already true and skip _edit_deck entirely.
		if _did.has("deck_edited"):
			await _check_deck_builder_reopened(overlay as DeckbuilderScreen)
		else:
			await _edit_deck(overlay as DeckbuilderScreen)
			_did["deck_edited"] = true
		return
	if overlay is CharacterScreen:
		await _check_character_screen(overlay as CharacterScreen)
		return
	if overlay is ItemVendorScreen:
		await _shop_item(overlay as ItemVendorScreen)
		return
	if scene.dialogue.active:
		await driver.tap_key(KEY_E)
		await driver.seconds(0.4)
		return
	if scene._locked:
		await driver.frames(10)
		return
	if not _did.has("vendor"):
		_did["vendor"] = true
		await _interact(scene, "vendor")
		return
	# New brief, FINAL: town exploration -> open one hidden chest (Part D).
	if not _did.has("chest"):
		_did["chest"] = true
		await _open_a_hidden_chest(scene)
		return
	if not _did.has("deck"):
		_did["deck"] = true
		await _interact(scene, "deck")
		return
	# New brief, FINAL: buy an item from Wick (Part F).
	if not _did.has("item_vendor"):
		_did["item_vendor"] = true
		await _interact(scene, "item_vendor")
		return
	if not _did.has("character"):
		_did["character"] = true
		await driver.tap_key(KEY_C)
		await driver.seconds(0.6)
		return
	# New brief, FINAL: equip the bought item (Part F), then challenge and defeat a corrupted NPC
	# (Part E) while actually using that item mid-duel, then walk into their now-unlocked zone
	# entrance (Part C) and back, then reopen the deck builder with the B hotkey (Part B).
	if not _did.has("equip_item"):
		_did["equip_item"] = true
		await driver.tap_key(KEY_C)
		await driver.seconds(0.6)
		return
	# Balance (D71) targets ~55-70% for a level-3 reference deck, not a guaranteed win - a real
	# loss is a legitimate outcome, not a bug, and D68 says they can always be challenged again.
	# Retry (a few times, not forever) instead of treating one loss as fatal to the whole run.
	if scene._portal_is_locked("ember") and int(_did.get("npc_attempts", 0)) < 3:
		_did["npc_attempts"] = int(_did.get("npc_attempts", 0)) + 1
		await _interact(scene, "npc_ember")
		return
	if not _did.has("zone_portal"):
		_did["zone_portal"] = true
		_check(not scene._portal_is_locked("ember"), "defeating the corrupted NPC unlocked the Ember entrance (%d attempt(s))" % int(_did.get("npc_attempts", 0)))
		await _interact(scene, "portal_ember")
		return
	if not _did.has("deck_hotkey"):
		_did["deck_hotkey"] = true
		await driver.tap_key(KEY_B)
		await driver.seconds(0.6)
		return
	_final_checks(scene)
	_did["finished"] = true


## Part G: a placeholder zone portal - walk in, check the sign/tint, walk back out.
func _zone_placeholder(scene: ZonePlaceholderScene) -> void:
	_check(scene.info != null and scene.info.id == "ember", "the Ember portal leads to the Ember placeholder zone")
	await _walk_to_portal(scene)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(1.0)


func _walk_to_portal(scene: ZonePlaceholderScene) -> void:
	var portal: Vector3 = scene.area.anchors.get("portal", Vector3.ZERO) as Vector3
	var elapsed: float = 0.0
	while elapsed < 6.0:
		var offset: Vector3 = portal - scene.player.position
		offset.y = 0.0
		if offset.length() < ZonePlaceholderScene.INTERACT_RADIUS * 0.55:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	if Vector2(scene.player.position.x - portal.x, scene.player.position.z - portal.z).length() >= ZonePlaceholderScene.INTERACT_RADIUS:
		scene.player.position = portal + Vector3(0, 0, 0.4)
		await driver.frames(3)


## Part C: the player only ever owns 3 of their own element's cards (the tutorial reward picks) -
## every other card of that element is unowned but already unlocked (VendorData.graduated: a
## player's own color needs only the trial-cleared gate, no gold-spent threshold), so it is always
## for sale. A different color (e.g. the old "recall") would now be gold-gated and might not be.
var _shop_card_id: String = ""
var _bought_item_id: String = ""


func _first_unowned_own_color_card() -> CardData:
	var ids: Array = Session.content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var candidate: CardData = Session.content.card(str(id))
		if candidate.color == Session.profile.primary_affinity and Session.owned_count(candidate.id) == 0:
			return candidate
	return null


## New brief, FINAL: the B hotkey (Part B) reopens the same deck builder screen from anywhere in
## town, not just the deck station - just confirms it opens and the bought card is still there.
func _check_deck_builder_reopened(screen: DeckbuilderScreen) -> void:
	var card: CardData = Session.content.card(_shop_card_id)
	_check(screen.editor.count(card) >= 1, "the B hotkey opens the same deck, still holding the earlier purchase")
	await driver.seconds(0.5)
	await driver.click_button("Close")
	await driver.seconds(0.4)


## New brief, Part D: opens one hidden chest - no Spot/marker, so this walks to a raw anchor
## position directly (see town_scene.gd HIDDEN_CHEST_RADIUS) rather than using a Spot id.
func _open_a_hidden_chest(scene: TownScene) -> void:
	var chest_id: String = "west_woods"
	var anchor: Vector3 = scene.town.anchors.get("hidden_chest_%s" % chest_id, Vector3.ZERO) as Vector3
	await _walk_to_position(scene, anchor, TownScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	_check(not Session.found_secret("hidden_chest_%s" % chest_id), "the hidden chest has not been found yet")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	_check(Session.found_secret("hidden_chest_%s" % chest_id), "opening it marks the secret found")


## New brief, Part F: buys the first available item from Wick, so there is something to equip.
func _shop_item(vendor: ItemVendorScreen) -> void:
	var tip: Button = driver.find_button("Got it")
	if tip != null:
		await driver.click(driver.button_center(tip))
		await driver.seconds(0.3)
	var item: ItemData = Session.content.item("healing_draught")
	_bought_item_id = item.id
	var before_gold: int = Session.gold
	var tile: Control = null
	for candidate: Node in vendor.find_children("*", "Control", true, false):
		if candidate.has_meta("item_id") and str(candidate.get_meta("item_id")) == item.id:
			tile = candidate as Control
	_check(tile != null, "Wick's stock includes a starter item")
	if tile != null:
		await driver.click(driver.center_of_control(tile))
	await driver.seconds(0.4)
	_check(driver.find_button("Buy") != null, "buying an item asks for confirmation")
	await driver.click_button("Buy")
	await driver.seconds(0.4)
	_check(Session.profile.owns_item(item), "the bought item joins the inventory")
	_check(Session.gold < before_gold, "the price is paid in gold")
	await driver.click_button("Leave")
	await driver.seconds(0.4)


func _shop(vendor: VendorScreen) -> void:
	var tip: Button = driver.find_button("Got it")
	if tip != null:
		await driver.click(driver.button_center(tip))
		await driver.seconds(0.3)
	var card: CardData = _first_unowned_own_color_card()
	_check(card != null, "there is an unowned card of the player's own element to buy")
	_shop_card_id = card.id
	var before_gold: int = Session.gold
	var before_owned: int = Session.owned_count(card.id)
	for tile: Control in vendor._tiles:
		if str(tile.get_meta("card_id")) == card.id:
			await _scroll_into_view(tile)
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
	var tip: Button = driver.find_button("Got it")
	if tip != null:
		await driver.click(driver.button_center(tip))
		await driver.seconds(0.3)
	var card: CardData = Session.content.card(_shop_card_id)
	var tile: Control = null
	for candidate: Node in screen._grid.get_children():
		if str(candidate.get_meta("card_id")) == card.id:
			tile = candidate as Control
	_check(tile != null, "the deck station lists the bought card")
	await _scroll_into_view(tile)
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
	if not _did.has("dungeon_deck"):
		_did["dungeon_deck"] = true
		await _try_dungeon_deck_builder(scene)
		return
	var available: Array[DungeonMap.MapNode] = scene.map.available()
	if available.is_empty():
		await driver.frames(10)
		return
	var button: MapNodeButton = scene._buttons[available[0].id] as MapNodeButton
	_note("map: entering %s (life %d)" % [available[0].title, Session.run.life])
	await driver.click(driver.center_of_control(button))
	await driver.seconds(1.0)


## Part C: a Deck button on the dungeon map opens the same Deck Station, editing the run's
## current (still 42-card, size-waived) deck. Opened once, checked, closed without changing it.
func _try_dungeon_deck_builder(scene: DungeonMapScreen) -> void:
	await driver.click_button("Deck")
	await driver.seconds(0.6)
	var screen: DungeonDeckbuilderScreen = null
	for child: Node in scene.get_children():
		if child is DungeonDeckbuilderScreen:
			screen = child as DungeonDeckbuilderScreen
	_check(screen != null, "the dungeon map's Deck button opens the in-dungeon deck builder")
	if screen == null:
		return
	_check(screen.editor.deck.size() == Session.run.current_deck().size(), "it edits the run's current deck")
	_check(screen.editor.is_valid(), "the size-waived starter deck is valid in the in-dungeon builder")
	var tip: Button = driver.find_button("Got it")
	if tip != null:
		await driver.click(driver.button_center(tip))
		await driver.seconds(0.3)
	await driver.click_button("Close")
	await driver.seconds(0.5)


# ---- Battle ----------------------------------------------------------------------------


## New brief, Part F: clicks the first usable equipped item on the item bar, and a legal target
## for it if it needs one. Returns false (try again next MAIN-phase tick) if nothing is usable
## right now (e.g. the only equipped item needs a target and none exists yet).
func _try_use_item_in_battle(screen: BattleScreen) -> bool:
	var item: ItemData = null
	var index: int = -1
	for i: int in range(Session.profile.equipped_item_ids.size()):
		var candidate: ItemData = Session.content.item(Session.profile.equipped_item_ids[i])
		if candidate != null and screen.game.can_use_item(0, candidate):
			item = candidate
			index = i
			break
	if item == null or index < 0 or index >= screen.item_bar.get_child_count():
		return false
	var slot: Control = screen.item_bar.get_child(index) as Control
	await driver.click(driver.center_of_control(slot))
	await driver.seconds(0.3)
	if screen.mode == BattleScreen.Mode.TARGETING:
		var options: Array[int] = screen._target_options
		if options.is_empty():
			return false
		var ref: int = options[0]
		if Targets.is_player(ref):
			await driver.click(screen.hud.portrait_rect(Targets.player_index(ref)).get_center())
		else:
			await driver.click(driver.center_of_control(screen.board.view_for(ref)))
		await driver.seconds(0.3)
	return true


func _battle(screen: BattleScreen) -> void:
	_battles += 1
	# New brief, FINAL: the corrupted-NPC fight (Part E) always uses real clicks, whichever battle
	# number it lands on, so the equipped item (Part F) can actually be clicked mid-duel.
	var is_corrupted_npc: bool = not screen.context.town_npc_id.is_empty()
	var use_clicks: bool = _battles == 1 or is_corrupted_npc
	screen.board.speed = 8.0
	var pilot: BattlePilot = BattlePilot.new(driver, screen)
	if not use_clicks:
		screen.set_bot(AIPlayer.new(AIPersonality.balanced()))
	if screen.tutorial != null and use_clicks:
		_check(true, "the tutorial layer is active in the first battle")
	var used_item: bool = not is_corrupted_npc
	var stalled: int = 0
	var events_seen: int = 0
	while true:
		if screen.mode == BattleScreen.Mode.OVER and screen._result_panel != null:
			break
		if screen.busy or screen.mode == BattleScreen.Mode.WAITING or not use_clicks:
			await driver.frames(6)
		elif not used_item and screen.mode == BattleScreen.Mode.MAIN and screen.item_bar != null:
			used_item = await _try_use_item_in_battle(screen)
			await driver.frames(3)
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
	if is_corrupted_npc:
		# A loss here is retried (see _town's npc_attempts loop, D71) rather than failed outright,
		# but using the item is expected every attempt regardless of outcome.
		_check(used_item, "an equipped item was actually used during the corrupted-NPC duel")
	var won: bool = screen.game.winner == 0
	_note("battle %d vs %s: %s in %d turns (life %d)" % [_battles, screen.context.enemy_name, "won" if won else "lost", screen.game.turn, screen.game.players[0].life])
	# Part E: force the first win's XP high enough to cross an equipment-choice level (5) and a
	# card-choice level (7) in one jump, so the multi-level LevelUpScreen chain (recap ->
	# equipment choice -> card offer) is exercised for real, not just left to natural pacing.
	if won and not _did.has("boosted_xp"):
		_did["boosted_xp"] = true
		screen.context.xp_reward = ProgressionTable.xp_to_reach(7) + 20
	await driver.seconds(1.2)
	await driver.click_button("Continue")
	await driver.seconds(1.0)


# ---- Rewards and trial complete --------------------------------------------------------


func _rewards(scene: RewardsScreen) -> void:
	for child: Node in scene.get_children():
		if child is LevelUpScreen:
			await _handle_level_up(child as LevelUpScreen)
			return
	var enter_town: Button = driver.find_button("Enter town")
	if enter_town != null:
		_check(Session.flag(&"trial_cleared"), "the trial is marked cleared once the boss falls")
		_check(Session.profile.intro_dungeon_cleared, "the intro dungeon is marked cleared")
		_check(Session.deck.size() == 45, "the deck grew to 45 cards via the 3 on-element reward picks (or was padded to exactly 45 if the Hollow Well cost one, D62)")
		_check(Session.deck_is_valid(), "the finished starter deck is a legal, plain (unwaived) deck")
		await driver.seconds(1.5)
		await driver.click(driver.button_center(enter_town))
		await driver.seconds(1.0)
		return
	if not scene._cards.is_empty() and scene._selected < 0:
		var gold_before: int = Session.gold
		var deck_before: int = Session.run.current_deck().size() if Session.run != null else -1
		await driver.click(driver.center_of_control(scene._cards[0]))
		await driver.seconds(0.3)
		_check(scene._take_button != null and not scene._take_button.disabled, "choosing a reward card enables Take")
		var offered: CardData = scene._offer.cards[0]
		if not Session.profile.intro_dungeon_cleared:
			_check(offered.color == Session.profile.primary_affinity, "the tutorial's first clear only offers %s cards" % Affinity.display_name(Session.profile.primary_affinity))
		var owned_before: int = Session.owned_count(offered.id)
		var reward_gold: int = scene._offer.gold
		var take: Button = driver.find_button("Take")
		await driver.click(driver.button_center(take))
		await driver.seconds(1.5)
		_check(Session.gold == gold_before + reward_gold, "victory pays %d gold" % reward_gold)
		_check(Session.owned_count(offered.id) == owned_before + 1, "the chosen reward card joins the collection")
		if deck_before >= 0 and Session.run != null:
			_check(Session.run.current_deck().size() == deck_before + 1, "the reward card also joins the run's current deck right away")
		return
	await driver.click_button("Continue")
	await driver.seconds(1.0)


## Part E (character screen): opened via the C hotkey (not a town spot) - check it shows the
## real profile state, then close it.
func _check_character_screen(screen: CharacterScreen) -> void:
	_check(screen.visible, "the C hotkey opens the character screen")
	_check(Session.profile.level >= 7, "the character screen reflects the level gained earlier")
	# New brief, FINAL: the second visit (after buying from Wick) equips the item so it can
	# actually be used in the corrupted-NPC fight right after this.
	if _did.has("equip_item") and not _bought_item_id.is_empty():
		var item: ItemData = Session.content.item(_bought_item_id)
		var equip_button: Button = driver.find_button("Equip")
		_check(equip_button != null, "the bought item shows an Equip button")
		if equip_button != null:
			await driver.click(driver.button_center(equip_button))
			await driver.seconds(0.3)
		_check(Session.profile.is_item_equipped(item), "the item is actually equipped")
	await driver.seconds(0.8)
	await driver.click_button("Close")
	await driver.seconds(0.5)


## Part E: walks the level-up recap -> equipment choice -> card offer chain, whichever step is
## currently showing, verifying each one actually took effect.
func _handle_level_up(level_up: LevelUpScreen) -> void:
	var choice: EquipmentSlotChoiceScreen = null
	for child: Node in level_up.get_children():
		if child is EquipmentSlotChoiceScreen:
			choice = child as EquipmentSlotChoiceScreen
	if choice != null:
		await _handle_equipment_choice(choice)
		return
	# Scoped to level_up's own subtree: RewardsScreen's earlier "Skip card"/"Continue" buttons are
	# still alive underneath (just visually covered), so an unscoped search would false-match them.
	if driver.find_button("Skip", level_up) != null:
		await _handle_level_card_offer(level_up)
		return
	# Otherwise: the multi-level recap list.
	_check(not level_up.levels_gained.is_empty(), "the level-up screen lists at least one level gained")
	var level_before: int = Session.profile.level - level_up.levels_gained.size()
	_check(Session.profile.level > level_before, "the profile is already at the new level while the recap shows")
	await driver.seconds(1.0)
	await driver.click(driver.button_center(driver.find_button("Continue", level_up)))
	await driver.seconds(0.5)


func _handle_equipment_choice(choice: EquipmentSlotChoiceScreen) -> void:
	var slots_before: int = Session.profile.equipment_slots.size()
	var pending_before: int = Session.pending_equipment_choices
	var tile: Button = choice._tiles.values()[0] as Button
	await driver.click(driver.center_of_control(tile))
	_check(not choice._confirm.disabled, "picking a tile enables Choose")
	await driver.click(driver.button_center(choice._confirm))
	await driver.seconds(0.8)
	_check(Session.profile.equipment_slots.size() == slots_before + 1, "choosing a slot unlocks it")
	_check(Session.pending_equipment_choices == pending_before - 1, "the pending equipment choice is consumed")


func _handle_level_card_offer(level_up: LevelUpScreen) -> void:
	var owned_before: int = Session.profile.owned_cards.size()
	var offers_before: int = Session.pending_level_card_offers.size()
	await _click_first_card_tile(level_up)
	await driver.seconds(0.8)
	_check(Session.profile.owned_cards.size() == owned_before + 1, "the level reward card joins the collection")
	_check(Session.pending_level_card_offers.size() == offers_before - 1, "the pending card offer is consumed")


## Searches only inside `root` (not the whole tree) - RewardsScreen's own earlier card row is
## still alive underneath the LevelUpScreen overlay, just visually covered, and would otherwise
## be found first.
func _click_first_card_tile(root: Node) -> void:
	var card_view: CardView = null
	for node: Node in root.find_children("*", "CardView", true, false):
		if node.is_visible_in_tree():
			card_view = node as CardView
			break
	if card_view != null:
		await driver.click(driver.center_of_control(card_view))


# ---- Final assertions ------------------------------------------------------------------


func _final_checks(scene: TownScene) -> void:
	_check(Session.deck_is_valid(), "the chosen starting deck is legal and fully owned in town")
	_check(Session.profile.intro_dungeon_cleared, "the intro dungeon is marked cleared")
	_check(Session.gold > Session.STARTING_GOLD - 30, "gold was earned in the dungeon")
	_check(not Session.in_dungeon(), "no dungeon run is active back in town")
	_check(SaveSystem.exists(SAVE_PATH), "the game was saved")
	var saved: Dictionary = SaveSystem.read(SAVE_PATH)
	_check(int(saved.get("gold", -1)) == Session.gold, "the save holds the current gold")
	_check(bool((saved.get("flags", {}) as Dictionary).get("trial_cleared", false)), "the save remembers the cleared trial")
	_check(bool((saved.get("flags", {}) as Dictionary).get("awakened", false)), "the save remembers the wake-up scene was played")
	_check(scene.hud._objective.text.contains("cleared"), "the town objective reflects the cleared trial")
