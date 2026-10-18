class_name StoryPlaythrough
extends Node
## Overnight Oct 16, Block 5a: a bot that plays the main story from a new game to Primm's defeat, windowed, and prints a pass/fail list.
## Real input where it is cheap (walking the hub's roads, E at gatekeepers, Brannoch, Maren and the Undercroft hatch, the keys of the quest
## tracker); debug helpers where a step would take minutes of play: battles are won by decree (the duel ends in the hero's favour through
## the normal completion path), a favour's steps are set by their flags, dungeons are resolved as cleared (the same call their last node makes).
##   Godot --path . --resolution 1600x900 res://tools/story_playthrough_launcher.tscn     (bash tools/run_story_playthrough.sh)
## Exit code 0 = every step passed.

const SHOT_DIR: String = "res://_screenshots/playthrough/"
const TAG: String = "playthrough"
## Zone id -> one of its favours and how to finish its steps (flags / counters), the side dungeon to clear (or "" when it is postgame).
const FAVOURS: Dictionary = {
	"beefcake": {"quest": "gain_power", "side": ""},
	"necrocrat": {"quest": "dna_onboarding", "side": "S-NECRO"},
	"gourmand": {"quest": "buf_mend", "side": "S-GOUR"},
	"refusemancer": {"quest": "heap_dam", "side": "S-REF"},
}

var driver: UiDriver
var _steps: Array[Array] = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	await _forest_and_tutorial()
	var town: TownScene = await _to_town()
	_step(town != null, "the town loads after the tutorial")
	if town == null:
		_finish()
		return
	_step(Session.quest_log.is_active(QuestDefinitions.zone_main_id("beefcake")), "the zone main lines start on the first visit to town")
	town = await _brannoch(town)
	for zone_id: String in Gatekeepers.IDS:
		town = await _zone(town, zone_id)
		if town == null:
			_step(false, "%s: lost the town" % zone_id)
			_finish()
			return
	await _undercroft(town)
	await _capital_and_castle()
	_finish()


# ---- 1. The forest and the tutorial -------------------------------------------------------------------------------------------------------


func _forest_and_tutorial() -> void:
	Session.new_game()
	SceneManager.change_scene("res://scenes/starting_area.tscn")
	var forest: Node = await _wait_for(StartingAreaScene)
	_step(forest != null, "the starting forest loads on a new game")
	await driver.seconds(1.5)
	await _shot("p_01_forest")
	Session.begin_intro_trial(Affinity.Type.BEEFCAKE)
	var map: Node = await _wait_for(DungeonMapScreen)
	_step(map != null and Session.dungeon_map != null, "the Forgotten Cave (the tutorial dungeon) opens after choosing a Path")
	await driver.seconds(1.0)
	await _shot("p_02_tutorial_map")
	# Decree: the Hollow Warden falls; the trial completes as its rewards screen would.
	Session.complete_trial()
	_step(Session.flag(&"trial_cleared") and Session.deck != null and Session.deck.size() >= DeckValidator.MIN_DECK_SIZE, "the tutorial clears with a legal deck")


# ---- 2. Brannoch on the imperial road ------------------------------------------------------------------------------------------------------


func _brannoch(town: TownScene) -> TownScene:
	await _walk_up(town, "guard")
	await driver.tap_key(KEY_E)
	await _dismiss_dialogue(town.dialogue)
	await driver.seconds(0.4)
	_step(Session.quest_log.is_active(QuestDefinitions.FREE_ZONES), "Brannoch gives Free the Four Zones on the imperial road")
	await _shot("p_03_brannoch")
	return town


# ---- 3. One zone: gatekeeper, road, favour, side dungeon, main dungeon, Maren -----------------------------------------------------------


func _zone(town: TownScene, zone_id: String) -> TownScene:
	var main_id: String = QuestDefinitions.zone_main_id(zone_id)
	var pack_id: String = "path_%s" % zone_id
	var packs_before: int = Session.profile.pack_count(pack_id)
	# The gatekeeper: E, his lines, the duel (won by decree), back in town with the road open.
	# A leftover announcement (a memory's "Second Path" card) can still be up: clear it, and try the gatekeeper twice like a player would.
	var battle: BattleScreen = null
	for _attempt: int in range(2):
		await _clear_overlays(town)
		await _walk_up(town, "npc_%s" % zone_id)
		await driver.tap_key(KEY_E)
		await _dismiss_dialogue(town.dialogue)
		battle = await _wait_for_short(BattleScreen) as BattleScreen
		if battle != null:
			break
	_step(battle != null, "%s: talking to %s starts the duel" % [zone_id, Gatekeepers.display_name(zone_id)])
	if battle == null:
		return town
	_step(battle.context.board_key == Gatekeepers.board_key(zone_id), "%s: the duel is on the zone's own battleboard" % zone_id)
	await _shot("p_%s_01_duel" % zone_id)
	await _force_win(battle)
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		return null
	await driver.seconds(1.5)
	await _dismiss_dialogue(town.dialogue)
	await _dismiss_popups()
	_step(Gatekeepers.is_cleared(Session.flags, zone_id), "%s: the gatekeeper is beaten and the road opens" % zone_id)
	_step(Session.profile.pack_count(pack_id) == packs_before + 1, "%s: the gatekeeper pays the Path Pack (step reward)" % zone_id)
	_step(town.hub_obstacles != null and town.hub_obstacles.is_cleared(zone_id), "%s: the obstacle stands cleared" % zone_id)
	await _shot("p_%s_02_cleared" % zone_id)
	# Down the road into the zone.
	var mouth: Vector3 = town.town.anchors["portal_%s_mouth" % zone_id] as Vector3
	var out: Vector3 = TownBuilder.PORTAL_OUT[zone_id] as Vector3
	_teleport(town, mouth - out * 5.0)
	await _walk_to(town, mouth + out * 1.5, 6.0)
	var zone: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	_step(zone != null and zone.def.id == zone_id, "%s: walking down the road enters the zone" % zone_id)
	if zone == null:
		return await _to_town()
	await driver.seconds(2.0)
	await _dismiss_dialogue(zone.dialogue)
	await _dismiss_popups()
	_step(Session.quest_log.current_index(QuestCatalog.find(main_id), Session.unlock_state()) == 2, "%s: the main line moves to its favour step" % zone_id)
	# A favour (its steps by flag), handed in.
	var favour: String = str((FAVOURS[zone_id] as Dictionary)["quest"])
	Session.start_quest(favour)
	_finish_favour(favour)
	await driver.frames(4)
	var turned_in: bool = Session.turn_in_quest(favour) or Session.quest_log.is_completed(favour)
	await _dismiss_popups()
	var gear: String = str(QuestDefinitions.MIDPOINT_GEAR[zone_id])
	_step(turned_in and Session.owned_equipment_ids().has(gear), "%s: a favour done pays the midpoint gear (%s)" % [zone_id, gear])
	# The side dungeon, first clear.
	var side: String = str((FAVOURS[zone_id] as Dictionary)["side"])
	if side != "":
		Session.set_flag(DungeonCatalog.side_unlock_flag(side))
		Session.enter_mini_dungeon()
		var side_map: Node = await _wait_for(DungeonMapScreen)
		_step(side_map != null, "%s: the side dungeon %s opens" % [zone_id, side])
		var side_result: Dictionary = Session.resolve_mini_dungeon(true)
		_step(bool(side_result.get("first_clear", false)) and Session.owned_equipment_ids().has(str(ExpansionGear.DUNGEON_GEAR.get(side, ""))), "%s: its first clear pays its piece of gear" % zone_id)
	else:
		_step(true, "%s: the side dungeon is a postgame bonus (skipped)" % zone_id)
	# The main dungeon: the leader freed, the zone free.
	Session.begin_zone_visit(zone_id)
	Session.enter_main_dungeon()
	var main_map: Node = await _wait_for(DungeonMapScreen)
	_step(main_map != null, "%s: the main dungeon opens" % zone_id)
	await _shot("p_%s_03_dungeon" % zone_id)
	var result: Dictionary = Session.resolve_main_dungeon(true)
	_step(str(result.get("kind", "")) == "zone_freed" and Session.is_zone_completed(zone_id), "%s: beating the boss frees the zone" % zone_id)
	_step(Session.quest_log.is_completed(main_id), "%s: its main quest line completes" % zone_id)
	_step(Session.owned_equipment_ids().has(str(ExpansionGear.DUNGEON_GEAR.get(zone_id, ""))), "%s: the main dungeon's first clear pays its gear" % zone_id)
	# Back to town: Maren's memory fragment.
	town = await _to_town()
	if town == null:
		return null
	var memory_before: int = Session.pending_memory()
	await _dismiss_popups()
	await _walk_up(town, "elder")
	await driver.tap_key(KEY_E)
	await _click_through(town)
	_step(memory_before > 0 and Session.pending_memory() == 0, "%s: Maren gives back a memory fragment" % zone_id)
	await _shot("p_%s_04_memory" % zone_id)
	return town


func _finish_favour(quest_id: String) -> void:
	match quest_id:
		"gain_power":
			Session.set_flag(GainlandsZone.FLAG_WHEEL_POWERED)
			Session.bump_counter(GainlandsZone.COUNTER_SHAKES)
		"dna_onboarding":
			Session.bump_counter(DnaZone.COUNTER_PUNCHED_IN)
			Session.bump_counter(DnaZone.COUNTER_COFFEE)
		"buf_mend":
			Session.set_flag(BuffetZone.FLAG_MENDED)
		"heap_dam":
			Session.set_flag(&"heap_smashed_dam")


# ---- 4. The Undercroft ----------------------------------------------------------------------------------------------------------------------


func _undercroft(town: TownScene) -> void:
	await _walk_up(town, "arena")
	_step(str(town.hud._prompt_label.text).contains("cellar"), "the Undercroft: the hatch is open after the first zone")
	await driver.tap_key(KEY_E)
	await _dismiss_dialogue(town.dialogue)
	await driver.seconds(0.8)
	var screen: Node = null
	for node: Node in town.find_children("*", "ArenaScreen", true, false):
		screen = node
	_step(screen != null, "the Undercroft: Grand Bellows' booth opens")
	await _shot("p_undercroft")
	if screen != null:
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.5)


# ---- 5. The Capital and the castle --------------------------------------------------------------------------------------------------------


func _capital_and_castle() -> void:
	var town: TownScene = await _to_town()
	if town == null:
		_step(false, "the town loads before the Capital")
		return
	var mouth: Vector3 = town.town.anchors["portal_final_mouth"] as Vector3
	_teleport(town, mouth + Vector3(0.0, 0.0, 5.0))
	await _walk_to(town, mouth + Vector3(0.0, 0.0, -1.5), 6.0)
	var capital: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	_step(capital != null and capital.def.id == CapitalZone.ID, "the imperial road enters the Capital")
	await driver.seconds(2.0)
	if capital != null:
		await _dismiss_dialogue(capital.dialogue)
		await _dismiss_popups()
	_step(CapitalDebuffs.active(Session.flags).is_empty(), "with all four zones free, every broken service is restored")
	await _shot("p_capital")
	Session.begin_zone_visit(CapitalZone.ID)
	Session.enter_main_dungeon()
	var castle: Node = await _wait_for(DungeonMapScreen)
	_step(castle != null, "the castle opens")
	var result: Dictionary = Session.resolve_main_dungeon(true)
	_step(str(result.get("kind", "")) == "primm_defeated" and Session.flag(&"primm_defeated"), "Primm is defeated")
	_step(Session.quest_log.is_completed(QuestDefinitions.FREE_ZONES), "Free the Four Zones completes")
	SceneManager.change_scene(Session.ENDING_SCENE)
	var ending: Node = await _wait_for(EndingScreen)
	_step(ending != null, "the ending plays")
	await driver.seconds(1.0)
	await _shot("p_ending")


# ---- Helpers --------------------------------------------------------------------------------------------------------------------------------


func _to_town() -> TownScene:
	SceneManager.go_to_town()
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town != null:
		await driver.seconds(2.5)
		await _dismiss_dialogue(town.dialogue)
		await _dismiss_popups()
	return town


func _walk_up(town: TownScene, spot_id: String) -> void:
	var target: Dictionary = QuestMarkerLayer.resolve_in(town.spots, spot_id)
	if target.is_empty():
		_step(false, "no spot %s in town" % spot_id)
		return
	var pos: Vector3 = target["pos"] as Vector3
	var start: Vector3 = pos + Vector3(0.0, 0.0, 2.6)
	if not town.town.is_walkable(start):
		start = pos + Vector3(0.0, 0.0, -2.6)
	_teleport(town, start)
	await _walk_to(town, pos, 3.0)
	await driver.frames(6)


func _force_win(battle: BattleScreen) -> void:
	var context: BattleContext = battle.context
	await driver.seconds(0.8)
	if context == null:
		return
	context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
	context.game._end_game(0, false)
	context.won = true
	Session.complete_battle(context)
	await driver.seconds(1.0)


func _click_through(town: TownScene) -> void:
	var guard: int = 0
	while guard < 60:
		guard += 1
		var memory: Node = null
		for node: Node in town.find_children("*", "MemoryScreen", true, false):
			memory = node
		if memory == null and not town.dialogue.active and driver.find_button("Continue") == null and _slot_choice() == null and Session.pending_memory() == 0:
			if guard > 3:
				break
		if driver.find_button("Continue") != null or driver.find_button("Next level") != null or _slot_choice() != null:
			await _dismiss_popups()
		elif memory != null:
			await driver.click(Vector2(960, 540))
		else:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.35)


func _teleport(town: TownScene, pos: Vector3) -> void:
	town.player.position = Vector3(pos.x, 0.0, pos.z)
	town._camera.position = town.player.position + CameraRig.shape(town.camera_offset)


func _walk_to(scene: Node, target: Vector3, limit: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < limit:
		if get_tree().current_scene != scene or not is_instance_valid(player):
			break
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < 0.5:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 30.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _dismiss_popups() -> void:
	for _guard: int in range(16):
		# Overnight Oct 17: a zone clear can gain several levels at once - the level-up screen says "Next level" until the last one.
		if driver.find_button("Continue") != null or driver.find_button("Next level") != null:
			await driver.tap_key(KEY_ENTER)
		elif _slot_choice() != null:
			# a level-up equipment-slot choice: take the Relic slot (most of the new gear is relics)
			var choice: EquipmentSlotChoiceScreen = _slot_choice()
			var tile: Button = choice._tiles.get(int(EquipmentData.Slot.RELIC), choice._tiles.values()[0]) as Button
			await driver.click(driver.button_center(tile))
			await driver.seconds(0.3)
			await driver.click_button("Choose")
		else:
			break
		await driver.seconds(0.5)


func _slot_choice() -> EquipmentSlotChoiceScreen:
	for node: Node in get_tree().root.find_children("*", "EquipmentSlotChoiceScreen", true, false):
		if (node as Control).is_visible_in_tree():
			return node as EquipmentSlotChoiceScreen
	return null


func _dismiss_dialogue(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue != null and is_instance_valid(dialogue) and dialogue.active and guard < 60:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


func _shot(name: String) -> void:
	_shots += 1
	await driver.frames(2)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var texture: Texture2D = get_tree().root.get_texture()
	if texture != null:
		texture.get_image().save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, name]))


func _step(ok: bool, message: String) -> void:
	_steps.append([ok, message])
	print("%s: %s  %s" % [TAG, "PASS" if ok else "FAIL", message])
	if not ok:
		push_error("%s: %s" % [TAG, message])


func _finish() -> void:
	var failed: int = 0
	for step: Array in _steps:
		if not bool(step[0]):
			failed += 1
	print("%s: ---- %d steps, %d passed, %d failed ----" % [TAG, _steps.size(), _steps.size() - failed, failed])
	for step: Array in _steps:
		print("%s: [%s] %s" % [TAG, "x" if bool(step[0]) else " ", str(step[1])])
	get_tree().quit(0 if failed == 0 else 1)


func _wait_for_short(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 6.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


## Clicks away any announcement, memory or reward box still on screen.
func _clear_overlays(town: TownScene) -> void:
	for _guard: int in range(20):
		var blocking: bool = false
		for kind: String in ["AnnouncementScreen", "MemoryScreen", "RewardPopup", "LevelUpScreen"]:
			if not town.find_children("*", kind, true, false).is_empty():
				blocking = true
		if not blocking and not town.dialogue.active and _slot_choice() == null and driver.find_button("Continue") == null:
			return
		if driver.find_button("Continue") != null or driver.find_button("Next level") != null or _slot_choice() != null:
			await _dismiss_popups()
		elif town.dialogue.active:
			await driver.tap_key(KEY_E)
		else:
			await driver.click(Vector2(960, 540))
		await driver.seconds(0.35)
