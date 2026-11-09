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
## Overnight Nov 8-9, Part 1.2 (full playthroughs): `--path=<zone id>` picks the Path (its zone first), `--real=1` has the BattlePilot play the
## gatekeepers and every dungeon boss for real (a lost or stalled fight is then decreed and logged as DEV HELP), `--saveload=1` (default)
## saves and reloads at every zone change and once mid-dungeon, `--postgame=1` (default) goes on to the Lab, the Gallery and Swolympus.
var _path_zone: String = "beefcake"
var _real: bool = false
var _saveload: bool = true
var _notes: PackedStringArray = []
var _mid_dungeon_checked: bool = false
var _current_zone: String = ""
var _fights: Dictionary = {"won": 0, "lost": 0, "stalled": 0, "decreed": 0}
## Overnight Nov 9, Part 1: `--full=1` - every fight real (every node of every dungeon, the tutorial cave, the side dungeons, the gatekeepers);
## a loss respawns per the rules and the bot tries again (a deck rebuilt from the collection between tries); MAX_TRIES losses on one fight
## is logged as a WALL and only then decreed. No level or deck catch-up. Gold earned is summed from every gain.
const MAX_TRIES: int = 4
var _full: bool = false
var _gold_earned: int = 0
var _last_gold: int = 0
var _losses: PackedStringArray = []
var _walls: PackedStringArray = []
var _wall_started: int = 0
var _last_win: bool = false


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	driver = UiDriver.new(get_tree())
	_path_zone = _arg("path", "beefcake")
	_real = _arg("real", "0") == "1"
	_saveload = _arg("saveload", "1") == "1"
	_full = _arg("full", "0") == "1"
	if _full:
		_real = true
		Settings.battle_speed = Settings.BATTLE_SPEEDS.size() - 1
		EventBus.gold_changed.connect(_on_gold)
	_wall_started = Time.get_ticks_msec()
	print("%s: path %s, real fights %s, save/load %s" % [TAG, _path_zone, _real, _saveload])
	await driver.frames(5)
	await _forest_and_tutorial()
	var town: TownScene = await _to_town()
	_step(town != null, "the town loads after the tutorial")
	if town == null:
		_finish()
		return
	await _early_chain(town)
	# Fixes Nov 8: the four zone lines wait for Maren's send-off (PathDirection), which the bot takes AFTER beating its own gatekeeper - the
	# "gatekeeper beaten early" order every player can now take.
	_step(not Session.quest_log.is_active(QuestDefinitions.zone_main_id(_path_zone)), "the zone main lines wait for Maren's send-off")
	town = await _brannoch(town)
	var snapshot_after: int = int(_arg("snapshot_after", "0"))
	var zones_done: int = 0
	var order: Array[String] = [_path_zone]
	for other: String in Gatekeepers.IDS:
		if other != _path_zone:
			order.append(other)
	if _full:
		_tend_deck("after the tutorial")
	for zone_id: String in order:
		town = await _zone(town, zone_id)
		if _full and town != null:
			_tend_deck("after %s" % zone_id)
		if town == null:
			_step(false, "%s: lost the town" % zone_id)
			_finish()
			return
		zones_done += 1
		if snapshot_after > 0 and snapshot_after <= Gatekeepers.IDS.size() and zones_done >= snapshot_after:
			await _save_progress_snapshot(_arg("snapshot", "midgame_real"))
			_finish()
			return
	await _undercroft(town)
	if _full:
		_tend_deck("before the Capital")
	await _capital_and_castle()
	if _arg("postgame", "1") == "1" and Session.flag(&"primm_defeated"):
		if _full:
			_tend_deck("before the postgame")
		await _postgame()
	# Overnight Oct 31 - Nov 1: --snapshot_after=5 saves after Primm's castle (a postgame snapshot for the postgame critic).
	if snapshot_after > Gatekeepers.IDS.size():
		await _save_progress_snapshot(_arg("snapshot", "postgame_real"), ProgressionModel.level_for("S-BEEF", 23))
	_finish()


## `--snapshot_after=N --snapshot=<name>` (after `--`): the value of a user argument.
func _arg(key: String, fallback: String) -> String:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--%s=" % key):
			return arg.get_slice("=", 1)
	return fallback


## Overnight Oct 30-31, Part 1: a real-progress snapshot for a mid-game critic. The story so far was played by the bot (the cave, Maren's
## chain, Brannoch, N zones with their favours, side and main dungeons, memories); the battles were decreed, so the level, the deck, the
## gear, the items and the gold are set to what the expected player has at this point (`ProgressionModel`, `docs/design/sim/economy_model.md`).
## `at_level` > 0 sets the level outright (the postgame snapshot: the expected player after Primm, who meets Swolympus at 23).
func _save_progress_snapshot(snapshot_name: String, at_level: int = 0) -> void:
	var next_zone: String = ProgressionModel.ZONE_ORDER[mini(Session.completed_zone_count(), ProgressionModel.ZONE_ORDER.size() - 1)]
	var level: int = at_level if at_level > 0 else maxi(ProgressionModel.level_for("zone:%s" % next_zone, 13), Session.profile.level)
	DevActions.set_level(level, true)
	var path: Affinity.Type = Session.profile.primary_affinity
	var deck: Deck = ProgressionModel.reference_deck(Session.content, path, level)
	for card: CardData in deck.cards:
		if Session.profile.owned_copies(card.id) < deck.count_of(card.id):
			Session.profile.owned_cards.append(card)
	EventBus.collection_changed.emit()
	Session.save_deck_to_slot(Session.deck_box.active, deck, "%s deck" % Affinity.display_name(path))
	for slot_value: int in EquipmentData.Slot.values():
		Session.profile.unlock_equipment_slot(slot_value as EquipmentData.Slot)
	Session.pending_equipment_choices = 0
	for piece_id: String in ProgressionModel.equipment_for(level):
		var piece: EquipmentData = Session.content.equipment_piece(piece_id)
		if piece != null:
			Session.grant_equipment(piece)
			Session.equip_item(piece)
	var items: Dictionary = ProgressionModel.items_for(level)
	for item_id: Variant in items:
		var item: ItemData = Session.content.item(str(item_id))
		for _use: int in range(int(items[item_id])):
			if item != null:
				Session.add_item(item)
	# Gold: the expected profile's purse after the second zone's freed stock plus a stop's income (economy model rows 16-18).
	Session.gold = 0
	Session.add_gold(600 + 300 * maxi(0, Session.completed_zone_count() - 2))  # Oct 31 - Nov 1: a later snapshot carries a fuller purse
	Session.add_pack("general_2", 2)
	Session.add_pack("path_%s" % Affinity.display_name(path).to_lower(), 1)
	DevActions.full_heal()
	Session.save_game()
	var said: String = DevActions.save_snapshot(snapshot_name)
	_step(said.begins_with("Snapshot saved"), "%s at L%d (%d cards, %d gear, %d gold, zones freed %d)" % [said, Session.profile.level, Session.deck.size(), Session.profile.equipment.size(), Session.gold, Session.completed_zone_count()])
	await _shot("p_snapshot_%s" % snapshot_name)


# ---- 1b. Maren's early-game chain ---------------------------------------------------------------------------------------------------------


## Overnight Oct 22: since Oct 20 the story's main quests wait for Maren's errands (the merchants, the first deck edit, the store room
## ghosts, the armory). The bot is about the story, so it hears her welcome and finishes the four errands through the quest log.
func _early_chain(town: TownScene) -> void:
	Session.set_flag(&"maren_met")
	Session.set_flag(&"elder_greeted")
	for quest_id: String in [QuestDefinitions.MERCHANTS, QuestDefinitions.FIRST_DECK_EDIT, QuestDefinitions.GHOSTS, QuestDefinitions.ARMORY]:
		if not Session.quest_log.is_completed(quest_id):
			Session.start_quest(quest_id, false)
			Session.complete_quest(quest_id)
	Session.refresh_quests()
	await driver.seconds(0.5)
	await _dismiss_dialogue(town.dialogue)
	await _dismiss_popups()
	_step(Session.quest_log.is_completed(QuestDefinitions.ARMORY), "Maren's early-game chain is done (merchants, deck edit, ghosts, armory)")


# ---- 1. The forest and the tutorial -------------------------------------------------------------------------------------------------------


func _forest_and_tutorial() -> void:
	Session.new_game()
	SceneManager.change_scene("res://scenes/starting_area.tscn")
	var forest: Node = await _wait_for(StartingAreaScene)
	_step(forest != null, "the starting forest loads on a new game")
	await driver.seconds(1.5)
	await _shot("p_01_forest")
	Session.begin_intro_trial(_path_type())
	var map: Node = await _wait_for(DungeonMapScreen)
	_step(map != null and Session.dungeon_map != null, "the Forgotten Cave (the tutorial dungeon) opens after choosing a Path")
	await driver.seconds(1.0)
	await _shot("p_02_tutorial_map")
	if _full and map != null:
		# Overnight Nov 9, Part 1: the tutorial cave played for real, node by node, the Hollow Warden included
		await _boss_for_real(func() -> bool: return Session.flag(&"trial_cleared"), "the Forgotten Cave", "TUTORIAL")
		for _i: int in range(10):
			await driver.seconds(0.5)
			await _dismiss_popups()
			var here: Node = get_tree().current_scene
			var talk: Node = here.get("dialogue") if here != null and "dialogue" in here else null
			if talk is DialogueBox and (talk as DialogueBox).active:
				await _dismiss_dialogue(talk as DialogueBox)
	if not Session.flag(&"trial_cleared"):
		# Decree: the Hollow Warden falls; the trial completes as its rewards screen would.
		Session.complete_trial()
	Session.claim_own_path(false)  # the cave-mouth scene (skipped here) marks the own Path
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
	_current_zone = zone_id
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
	await _win(battle, "%s gatekeeper" % zone_id)
	if _full:
		var tries: int = 1
		while not _last_win and tries < MAX_TRIES:
			town = await _wait_for(TownScene) as TownScene
			if town == null:
				return null
			await driver.seconds(1.5)
			await _clear_overlays(town)
			_tend_deck("before %s gatekeeper try %d" % [zone_id, tries + 1])
			battle = null
			for _attempt: int in range(3):
				await _clear_overlays(town)
				await _walk_up(town, "npc_%s" % zone_id)
				await driver.tap_key(KEY_E)
				await _dismiss_dialogue(town.dialogue)
				battle = await _wait_for_short(BattleScreen) as BattleScreen
				if battle != null:
					break
			if battle == null:
				_step(false, "%s: the gatekeeper can be challenged again after a loss" % zone_id)
				return town
			tries += 1
			await _win(battle, "%s gatekeeper (try %d)" % [zone_id, tries])
		if not _last_win:
			_wall("%s gatekeeper: lost %d times" % [zone_id, tries])
			town = await _wait_for(TownScene) as TownScene
			await _clear_overlays(town)
			await _walk_up(town, "npc_%s" % zone_id)
			await driver.tap_key(KEY_E)
			await _dismiss_dialogue(town.dialogue)
			battle = await _wait_for_short(BattleScreen) as BattleScreen
			if battle != null:
				_fights["decreed"] = int(_fights["decreed"]) + 1
				await _force_win(battle)
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		return null
	await driver.seconds(1.5)
	await _dismiss_dialogue(town.dialogue)
	await _dismiss_popups()
	_step(Gatekeepers.is_cleared(Session.flags, zone_id), "%s: the gatekeeper is beaten and the road opens" % zone_id)
	if not Session.flag(StringName(PathDirection.FLAG)):
		town = await _path_direction(town)
	# a level-up in the same fight can add the level track's own-Path Pack too (Beefcake, level 4)
	_step(Session.profile.pack_count(pack_id) >= packs_before + 1, "%s: the gatekeeper pays the Path Pack (step reward)" % zone_id)
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
	await _save_load("enter_%s" % zone_id, ZoneScene)
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
		var side_first: bool = false
		if _full and side_map != null:
			var side_plan: DungeonCatalog.Blueprint = DungeonCatalog.find(side)
			await _boss_for_real(func() -> bool: return Session.flag(Session.side_cleared_flag(side_plan)), "%s side dungeon %s" % [zone_id, side], side)
			side_first = Session.flag(Session.side_cleared_flag(side_plan))
			await _wait_for(ZoneScene)
			await driver.seconds(1.0)
			await _dismiss_popups()
		else:
			side_first = bool(Session.resolve_mini_dungeon(true).get("first_clear", false))
		_step(side_first and Session.owned_equipment_ids().has(str(ExpansionGear.DUNGEON_GEAR.get(side, ""))), "%s: its first clear pays its piece of gear" % zone_id)
	else:
		_step(true, "%s: the side dungeon is a postgame bonus (skipped)" % zone_id)
	# The main dungeon: the leader freed, the zone free.
	Session.begin_zone_visit(zone_id)
	Session.enter_main_dungeon()
	var main_map: Node = await _wait_for(DungeonMapScreen)
	_step(main_map != null, "%s: the main dungeon opens" % zone_id)
	await _shot("p_%s_03_dungeon" % zone_id)
	if _saveload and not _mid_dungeon_checked:
		main_map = await _mid_dungeon_check(zone_id)
	if _real and main_map != null:
		var nth_dungeon: String = (["D-HOG", "D-HFA", "D-TTK", "D-ROT"] as Array[String])[mini(Session.completed_zone_count(), 3)]
		await _boss_for_real(func() -> bool: return Session.is_zone_completed(zone_id), "%s boss" % zone_id, nth_dungeon)
		_step(Session.is_zone_completed(zone_id), "%s: beating the boss frees the zone" % zone_id)
	else:
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
	var reloaded: Node = await _save_load("town_after_%s" % zone_id, TownScene)
	if reloaded is TownScene:
		town = reloaded as TownScene
	await _shot("p_%s_04_memory" % zone_id)
	# Oct 21: the Rescuer waits at the cave mouth after each freed zone, one scene each, in order.
	var cave: String = StoryBeats.cave_mouth_scene(Session.flags, Session.completed_zone_count())
	_step(not cave.is_empty() and town._npcs.has("rescuer"), "%s: the Rescuer waits at the cave mouth (%s)" % [zone_id, cave])
	if town._npcs.has("rescuer"):
		await _walk_up(town, "rescuer")
		await driver.tap_key(KEY_E)
		await _click_through(town)
		_step(Session.flag(StringName(cave + "_seen")) and not town._npcs.has("rescuer"), "%s: her Cave Mouth scene plays and she slips away" % zone_id)
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
	var castle: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	_step(castle != null, "the castle opens")
	# Oct 21: Plume has the Rescuer seized at the gate on the first castle run, and names her.
	if castle != null:
		await driver.seconds(1.5)
		_step(castle._dialogue.active, "the castle gate: the capture scene plays as the map opens")
		await _dismiss_dialogue(castle._dialogue)
	_step(Session.flag(&"elowen_seized") and RoyalFamily.fill("{rescuer}") == "Elowen", "Plume names her: {rescuer} reads Elowen from now on")
	var ending: Node = null
	if _real and castle != null:
		await _boss_for_real(func() -> bool: return Session.flag(&"primm_defeated"), "Primm", "D-PC")
		_step(Session.flag(&"primm_defeated"), "Primm is defeated")
		_step(Session.quest_log.is_completed(QuestDefinitions.FREE_ZONES), "Free the Four Zones completes")
		ending = await _wait_for(EndingScreen)
		if ending == null:
			_note("DEV HELP: the ending did not start by itself after Primm; changed scene to it")
			SceneManager.change_scene(Session.ENDING_SCENE)
			ending = await _wait_for(EndingScreen)
	else:
		var result: Dictionary = Session.resolve_main_dungeon(true)
		_step(str(result.get("kind", "")) == "primm_defeated" and Session.flag(&"primm_defeated"), "Primm is defeated")
		_step(Session.quest_log.is_completed(QuestDefinitions.FREE_ZONES), "Free the Four Zones completes")
		SceneManager.change_scene(Session.ENDING_SCENE)
		ending = await _wait_for(EndingScreen)
	_step(ending != null, "the ending plays")
	await driver.seconds(1.0)
	await _shot("p_ending")
	await _after_the_ending()


## Oct 21: the postgame beats - the royal funeral in Grave Row (through Old Hob), Isla home at Brannoch's gate, Maren's news of the capture.
func _after_the_ending() -> void:
	Session.return_from_ending()
	var capital: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	if capital == null:
		_step(false, "back in the Capital after the ending")
		return
	await driver.seconds(2.0)
	await _dismiss_dialogue(capital.dialogue)
	await _dismiss_popups()
	_step(OldHob.funeral_waiting(Session.flags), "the royal funeral waits in Grave Row")
	var hob: ZoneSpot = null
	for spot: ZoneSpot in capital.spots:
		if spot.id == ZoneScene.OLD_HOB_KEY:
			hob = spot
	_step(hob != null, "Old Hob stands in Grave Row")
	if hob != null:
		capital.player.position = hob.position + Vector3(0.0, 0.0, 1.0)
		await driver.frames(6)
		await driver.tap_key(KEY_E)
		var guard: int = 0
		while guard < 40 and not Session.flag(&"royal_funeral_seen"):
			guard += 1
			await driver.tap_key(KEY_E)
			await driver.seconds(0.3)
		await _shot("p_funeral")
	_step(Session.flag(&"royal_funeral_seen"), "the royal funeral plays")
	var town: TownScene = await _to_town()
	if town == null:
		return
	await _walk_up(town, "guard")
	await driver.tap_key(KEY_E)
	await _click_through(town)
	_step(Session.flag(&"isla_home") and town._npcs.has("isla"), "Isla walks home through her father's gate")
	await _shot("p_isla")
	await _walk_up(town, "elder")
	await driver.tap_key(KEY_E)
	await _click_through(town)
	_step(Session.flag(&"maren_capture_seen"), "Maren has news of the capture")
	_step(town._npcs.has("hob") and OldHob.town_scene(Session.flags) == "hob_town_after_funeral", "Old Hob is back by the cairn")


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
		elif _reward_popup() != null:
			# Fixes Oct 27 / Cards Oct 27: a card-pick box (the gatekeepers' pick, a boss's) keeps the hero still until answered and no
			# longer closes on a click beside the cards: choose the first card (1), then Keep (Enter). A box without a pick closes on Enter.
			await driver.tap_key(KEY_1)
			await driver.seconds(0.25)
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


func _reward_popup() -> RewardPopup:
	for node: Node in get_tree().root.find_children("*", "RewardPopup", true, false):
		if (node as Control).is_visible_in_tree():
			return node as RewardPopup
	return null


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
	print("%s: fights %s" % [TAG, _fights])
	_full_summary()
	for note: String in _notes:
		print("%s: NOTE %s" % [TAG, note])
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
		elif not town.find_children("*", "RewardPopup", true, false).is_empty():
			# Fixes Oct 27 / Cards Oct 27: a card-pick box (the gatekeepers' pick) no longer closes on a click beside the cards and keeps the
			# hero still until answered: choose the first card (1), then Keep (Enter). A box with no pick closes on Enter too.
			await driver.tap_key(KEY_1)
			await driver.seconds(0.2)
			await driver.tap_key(KEY_ENTER)
		else:
			await driver.click(Vector2(960, 540))
		await driver.seconds(0.35)


# ---- Overnight Nov 8-9, Part 1.2: Paths, real fights, save/load, postgame ------------------------------------------------------------------


func _path_type() -> Affinity.Type:
	for t: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]:
		if PathDirection.zone_of(t) == _path_zone:
			return t
	return Affinity.Type.BEEFCAKE


func _note(text: String) -> void:
	_notes.append(text)
	print("%s: NOTE %s" % [TAG, text])


## A duel the story needs won: decreed (the old bot), or played by the BattlePilot with `--real=1`. A real loss or a stalled duel is then
## decreed and logged as DEV HELP, so the run goes on and the report shows where the simple player could not win.
func _win(battle: BattleScreen, label: String) -> void:
	if not _real:
		_fights["decreed"] = int(_fights["decreed"]) + 1
		await _force_win(battle)
		return
	_last_win = false
	var result: String = await _pilot_fight(battle)
	var level: int = Session.profile.level if Session.profile != null else 0
	if _full and result == "lost":
		_fights["lost"] = int(_fights["lost"]) + 1
		var deck_text: String = "%s, %d cards" % [Session.deck.deck_name, Session.deck.size()] if Session.deck != null else "?"
		_losses.append("%s - level %d, deck %s, turn %d" % [label, level, deck_text, battle.game.turn if battle.game != null else -1])
		print("%s: LOSS %s" % [TAG, _losses[_losses.size() - 1]])
		# the loss plays out as a loss: the result panel, then the respawn the rules give
		await driver.seconds(0.8)
		for _i: int in range(20):
			if not is_instance_valid(battle) or battle._result_shown:
				break
			await driver.seconds(0.2)
		if is_instance_valid(battle) and get_tree().current_scene == battle:
			battle._continue()
		await driver.seconds(1.5)
		return
	match result:
		"won":
			_last_win = true
			_fights["won"] = int(_fights["won"]) + 1
			print("%s: fight won for real: %s (level %d)" % [TAG, label, level])
		"lost":
			_fights["lost"] = int(_fights["lost"]) + 1
			_note("DEV HELP: the pilot LOST %s at level %d (turn %d) - decreed" % [label, level, battle.game.turn if battle.game != null else -1])
		_:
			_fights["stalled"] = int(_fights["stalled"]) + 1
			_note("DEV HELP: %s stalled or ran past the time limit at level %d - decreed" % [label, level])
	if not is_instance_valid(battle):
		return
	if result == "lost" and Session.in_dungeon():
		# a dungeon loss plays out as a loss (the run ends, the hero is carried out); _boss_for_real then decrees the dungeon from its entrance
		await driver.seconds(0.8)
		if is_instance_valid(battle) and get_tree().current_scene == battle:
			battle._continue()
		await driver.seconds(1.0)
		return
	if result == "won" or (result == "lost" and battle.mode == BattleScreen.Mode.OVER):
		if result == "lost":
			_fights["decreed"] = int(_fights["decreed"]) + 1
			battle.context.won = true
			if battle.game != null:
				battle.game.players[0].hp = maxi(battle.game.players[0].hp, 1)
		await driver.seconds(0.8)
		if is_instance_valid(battle) and get_tree().current_scene == battle:
			battle._continue()
		await driver.seconds(1.0)
	else:
		_fights["decreed"] = int(_fights["decreed"]) + 1
		await _force_win(battle)


## The play script's pilot loop (tools/play_script.gd `_pilot`): "won", "lost" or "stalled".
func _pilot_fight(battle: BattleScreen) -> String:
	if _full:
		return await _ai_fight(battle)
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	var started: int = Time.get_ticks_msec()
	var last_turn: int = -1
	var stuck: int = 0
	while is_instance_valid(battle) and battle.mode != BattleScreen.Mode.OVER and float(Time.get_ticks_msec() - started) / 1000.0 < 420.0:
		if battle.busy or battle.mode == BattleScreen.Mode.WAITING:
			await driver.seconds(0.2)
			continue
		var got_it: Button = driver.find_button("Got it")
		if got_it != null:
			await driver.click(driver.button_center(got_it))
			await driver.seconds(0.2)
		var confirm: Button = driver.find_button("End Turn", battle)
		await pilot.act()
		await driver.seconds(0.2)
		for node: Node in get_tree().root.find_children("*", "Button", true, false):
			var dialog: Button = node as Button
			if dialog != confirm and dialog.is_visible_in_tree() and dialog.text.strip_edges() == "End Turn":
				await driver.click(driver.button_center(dialog))
				await driver.seconds(0.2)
				break
		if battle.game != null and battle.game.turn != last_turn:
			last_turn = battle.game.turn
			stuck = 0
		else:
			stuck += 1
		if stuck == 30 or stuck == 70:
			pilot.skip_hand()
		if stuck == 40:
			var skip: Button = driver.find_button("Skip tips")
			if skip != null:
				await driver.click(driver.button_center(skip))
		if stuck > 120:
			return "stalled"
	if not is_instance_valid(battle):
		return "won"
	if battle.mode != BattleScreen.Mode.OVER:
		return "stalled"
	# the result panel arrives a moment after the last blow
	for _i: int in range(20):
		if battle._result_shown:
			break
		await driver.seconds(0.2)
	return "won" if battle.context.won else "lost"


## Maren's send-off: walk up, E, read it all. Starts the four zone lines and tracks the hero's own.
func _path_direction(town: TownScene) -> TownScene:
	await _clear_overlays(town)
	await _walk_up(town, "elder")
	await driver.tap_key(KEY_E)
	await _click_through(town)
	var own: String = PathDirection.own_main_quest(Session.profile.primary_affinity)
	_step(Session.flag(StringName(PathDirection.FLAG)) and Session.quest_log.is_active(own), "Maren sends the hero down their own Path (the four zone lines start)")
	_step(Session.quest_log.tracked_id() == own, "the hero's own Path line is the tracked quest")
	return town


func _digest() -> Dictionary:
	var true_flags: int = 0
	for key: Variant in Session.flags.keys():
		if typeof(Session.flags[key]) == TYPE_BOOL and bool(Session.flags[key]):
			true_flags += 1
	var active: Array = Session.quest_log.active.duplicate()
	active.sort()
	var names: Array = []
	for key: Variant in Session.flags.keys():
		if typeof(Session.flags[key]) == TYPE_BOOL and bool(Session.flags[key]):
			names.append(str(key))
	names.sort()
	return {
		"flag_names": ",".join(PackedStringArray(names)),
		"active": ",".join(PackedStringArray(active)), "completed": Session.quest_log.completed.size(), "flags": true_flags,
		"gold": Session.gold, "level": Session.profile.level, "deck": Session.deck.size() if Session.deck != null else -1,
		"gear": Session.owned_equipment_ids().size(), "cleared": Session.cleared_dungeons.size(), "secrets": Session.found_secrets.size(),
	}


## Saves a snapshot through the real save path, loads it through the real load path and checks the game came back the same.
func _save_load(label: String, kind: Variant) -> Node:
	if not _saveload:
		return null
	await _dismiss_popups()
	var snapshot_name: String = "bot_%s_%s" % [_path_zone, label]
	var before: Dictionary = _digest()
	var kind_before: String = Session.scene_kind()
	DevActions.save_snapshot(snapshot_name)
	DevActions.load_snapshot(snapshot_name)
	await driver.frames(10)
	var scene: Node = await _wait_for(kind)
	if scene != null:
		await driver.seconds(2.0)
		if "dialogue" in scene and scene.get("dialogue") is DialogueBox:
			await _dismiss_dialogue(scene.get("dialogue") as DialogueBox)
		await _dismiss_popups()
	var after: Dictionary = _digest()
	var diffs: PackedStringArray = []
	for key: Variant in before.keys():
		if key == "flag_names":
			var was: PackedStringArray = str(before[key]).split(",")
			var now: PackedStringArray = str(after[key]).split(",")
			for f: String in now:
				if not f in was:
					diffs.append("+flag " + f)
			for f: String in was:
				if not f in now:
					diffs.append("-flag " + f)
		elif key != "flags" and str(before[key]) != str(after[key]):
			diffs.append("%s %s -> %s" % [key, before[key], after[key]])
	_step(scene != null and diffs.is_empty(), "save/load at %s (%s): %s" % [label, kind_before, "the same state" if diffs.is_empty() and scene != null else ("no scene; " if scene == null else "") + ", ".join(diffs)])
	return scene


## Once per run, in the first main dungeon: one node in, save, load. The dungeon run is never saved, so the hero must come back in the
## zone (not Crosspath) with no run, and the next entry must start a fresh map.
func _mid_dungeon_check(zone_id: String) -> Node:
	_mid_dungeon_checked = true
	var map: DungeonMap = Session.dungeon_map
	if map != null and not map.available().is_empty():
		DevActions.walk_map_to(map, map.available()[0].id)
	var cleared_before: int = map.cleared.size() if map != null else 0
	var snapshot_name: String = "bot_%s_mid_dungeon" % _path_zone
	var kind_saved: String = Session.scene_kind()
	DevActions.save_snapshot(snapshot_name)
	DevActions.load_snapshot(snapshot_name)
	await driver.frames(10)
	var zone: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	if zone != null:
		await driver.seconds(2.0)
		await _dismiss_dialogue(zone.dialogue)
		await _dismiss_popups()
	_step(kind_saved == "zone:%s" % zone_id, "mid-dungeon save records the zone (%s)" % kind_saved)
	_step(zone != null and zone.def.id == zone_id and not Session.in_dungeon(), "mid-dungeon load: back in %s with no dungeon run (it had %d cleared nodes)" % [zone_id, cleared_before])
	if zone == null:
		var town: TownScene = await _to_town()
		if town == null:
			return null
	Session.begin_zone_visit(zone_id)
	Session.enter_main_dungeon()
	var again: Node = await _wait_for(DungeonMapScreen)
	_step(again != null and Session.dungeon_map != null and Session.dungeon_map.cleared.size() <= 1, "re-entering starts the dungeon over (%d cleared)" % (Session.dungeon_map.cleared.size() if Session.dungeon_map != null else -1))
	return again


## Plays a dungeon's boss (every phase) for real on the real map: the nodes before it are walked through by the Dev Menu's map walk (DEV
## HELP, logged), the boss is chosen on the map like a click, every fight goes to `_win`, and every box after it is read. Ends when `done`
## says so and the game has left the map and the fight; a run that cannot reach that is decreed with `fallback`.
func _boss_for_real(done: Callable, label: String, expected_key: String = "", fallback: Callable = Callable()) -> void:
	var started: int = Time.get_ticks_msec()
	var fights: int = 0
	var chose: int = 0
	var walked: bool = false
	var tries: int = 1
	var limit: float = 5400.0 if _full else 900.0
	while float(Time.get_ticks_msec() - started) / 1000.0 < limit:
		await driver.seconds(0.3)
		if SceneManager.busy:
			continue
		var scene: Node = get_tree().current_scene
		if _full and await _unstick(scene, fights):
			continue
		# Overnight Nov 9, Part 1 (--full): every node is played - a node screen (challenge, shrine, event, treasure) is driven like a player
		if _full and scene is DungeonMapScreen and (scene as DungeonMapScreen)._modal != null:
			await _drive_modal((scene as DungeonMapScreen)._modal)
			continue
		if scene is RewardsScreen:
			await _take_rewards(scene as RewardsScreen)
			continue
		if scene is BattleScreen:
			var battle: BattleScreen = scene as BattleScreen
			if battle.mode != BattleScreen.Mode.OVER:
				fights += 1
				await _win(battle, "%s (fight %d)" % [label, fights])
			elif battle._result_shown:
				battle._continue()
				await driver.seconds(1.0)
			continue
		if scene is EndingScreen:
			return
		if scene is DungeonMapScreen:
			var map_screen: DungeonMapScreen = scene as DungeonMapScreen
			if map_screen._dialogue != null and map_screen._dialogue.active:
				await _dismiss_dialogue(map_screen._dialogue)
				continue
			if driver.find_button("Continue") != null or driver.find_button("Next level") != null or _reward_popup() != null or _slot_choice() != null:
				await _dismiss_popups()
				continue
			if done.call():
				continue  # the map closes by itself after the last boss
			var map: DungeonMap = Session.dungeon_map
			if map == null or map.boss() == null:
				continue
			var boss_id: int = map.boss().id
			if _full:
				var next_id: int = _pick_node(map)
				if next_id < 0:
					continue
				map_screen._on_node_chosen(next_id)
				await driver.seconds(1.2)
				continue
			if not map.is_available(boss_id) and map.current != boss_id:
				var skipped: int = DevActions.walk_map_to(map, boss_id)
				if not walked:
					walked = true
					_note("DEV HELP: %s - walked the map to the boss (%d nodes skipped)" % [label, skipped])
				_grant_lab_boon()
				_catch_up(expected_key, label)
			chose += 1
			if chose > 6:
				break
			map_screen._on_node_chosen(boss_id)
			await driver.seconds(1.5)
			continue
		if not done.call() and (scene is ZoneScene or scene is TownScene or scene is StartingAreaScene) and fights > 0:
			await driver.seconds(1.5)
			await _dismiss_popups()
			if _full:
				# carried out (a loss): wake at the respawn point, rebuild the deck from the collection, walk back in and start over
				var box_out: Node = scene.get("dialogue") if "dialogue" in scene else null
				if box_out is DialogueBox and (box_out as DialogueBox).active:
					await _dismiss_dialogue(box_out as DialogueBox)
				if tries >= MAX_TRIES:
					_wall("%s: carried out %d times" % [label, tries])
				else:
					tries += 1
					fights = 0
					_tend_deck("%s try %d" % [label, tries])
					print("%s: re-entering %s (try %d)" % [TAG, label, tries])
					await _reenter(expected_key)
					continue
			_note("DEV HELP: %s - lost on the real map and carried out; the dungeon is decreed from its entrance" % label)
			break
		if done.call():
			for _i: int in range(6):
				await _dismiss_popups()
				var box: Node = scene.get("dialogue") if scene != null and "dialogue" in scene else null
				if box is DialogueBox and (box as DialogueBox).active:
					await _dismiss_dialogue(box as DialogueBox)
				await driver.seconds(0.3)
			return
		# not the map, not a fight, not done: a cut-scene or a box between phases
		await _dismiss_popups()
		var talk: Node = scene.get("dialogue") if scene != null and "dialogue" in scene else null
		if talk is DialogueBox and (talk as DialogueBox).active:
			await _dismiss_dialogue(talk as DialogueBox)
		else:
			await driver.tap_key(KEY_E)
	_note("DEV HELP: %s never finished on the real map (%d fights, %d boss picks, scene %s) - decreed" % [label, fights, chose, get_tree().current_scene.name if get_tree().current_scene != null else "none"])
	if fallback.is_valid():
		fallback.call()
		return
	if not Session.in_dungeon() and not expected_key.is_empty():
		await _reenter(expected_key)
	if Session.main_dungeon_active:
		Session.resolve_main_dungeon(true)
	elif Session.in_dungeon():
		Session.resolve_mini_dungeon(true)


## The postgame: Rip's forest tip and the Lab (Under the Forest), the cracked mirror and the Shattered Gallery, Old Man Mountain and Swolympus.
func _postgame() -> void:
	var town: TownScene = await _to_town()
	if town == null:
		_step(false, "postgame: the town loads")
		return
	_step(Session.quest_log.is_active(QuestDefinitions.UNDER_THE_FOREST), "postgame: Under the Forest is given")
	_step(Session.quest_log.is_active("loose_ends"), "postgame: Loose Ends is given")
	# 1. Rip at the Rift Station
	await _clear_overlays(town)
	await _walk_up(town, "rift_station")
	await driver.tap_key(KEY_E)
	await _dismiss_dialogue(town.dialogue)
	await driver.seconds(0.8)
	_step(Session.flag(&"rip_forest_tip"), "postgame: Rip tells of the forest (step 1)")
	var forest_button: Button = driver.find_button("Forest")
	if forest_button == null:
		forest_button = driver.find_button("forest")
	if forest_button != null:
		await driver.click(driver.button_center(forest_button))
		await driver.seconds(1.0)
		for _i: int in range(30):
			if get_tree().current_scene is StartingAreaScene:
				break
			await _dismiss_dialogue(town.dialogue if is_instance_valid(town) else null)
			await driver.seconds(0.5)
	if not (get_tree().current_scene is StartingAreaScene):
		await driver.tap_key(KEY_ESCAPE)
		_note("DEV HELP: postgame - the Rift Express to the forest was not driven; went to the forest directly")
		SceneManager.go_to_start_area()
	var forest: Node = await _wait_for(StartingAreaScene)
	await driver.seconds(2.0)
	if forest != null and "dialogue" in forest:
		await _dismiss_dialogue(forest.get("dialogue") as DialogueBox)
	_step(forest != null and Session.flag(StringName(QuestDefinitions.FLAG_FOREST_ARRIVED)), "postgame: back in the forest (step 2)")
	await _save_load("forest_postgame", StartingAreaScene)
	# 2. The Lab (the walk to the hatch is skipped: DEV HELP)
	_note("DEV HELP: postgame - walking to the Lab hatch skipped (entered through the hatch's own calls)")
	Session.set_flag(StringName(QuestDefinitions.FLAG_LAB_ENTERED))
	Session.enter_lab()
	var lab_map: Node = await _wait_for(DungeonMapScreen)
	_step(lab_map != null, "postgame: the Lab opens (step 3)")
	if _real and lab_map != null:
		await _boss_for_real(func() -> bool: return Session.flag(PathologyLab.FLAG_RESCUER_FREED), "the Lab", "D-LAB")
	elif lab_map != null:
		_grant_lab_boon()
		Session.resolve_mini_dungeon(true)
	await driver.seconds(2.0)
	_step(Session.flag(PathologyLab.FLAG_RESCUER_FREED) and Session.quest_log.is_completed(QuestDefinitions.UNDER_THE_FOREST), "postgame: Elowen is freed and Under the Forest completes")
	# 3. The Shattered Gallery: the cracked mirror at the castle door
	town = await _to_town()
	if town == null:
		return
	var mouth: Vector3 = town.town.anchors["portal_final_mouth"] as Vector3
	_teleport(town, mouth + Vector3(0.0, 0.0, 5.0))
	await _walk_to(town, mouth + Vector3(0.0, 0.0, -1.5), 6.0)
	var capital: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	if capital == null:
		_step(false, "postgame: the Capital loads")
		return
	await driver.seconds(2.0)
	await _dismiss_dialogue(capital.dialogue)
	await _dismiss_popups()
	var mirror: ZoneSpot = null
	for spot: ZoneSpot in capital.spots:
		if spot.id == "gallery_mirror":
			mirror = spot
	_step(mirror != null, "postgame: the cracked mirror stands by the castle door")
	if mirror != null:
		capital.player.position = mirror.position + Vector3(0.0, 0.0, 1.0)
		await driver.frames(8)
		await driver.tap_key(KEY_E)
		await driver.seconds(1.0)
		await _dismiss_dialogue(capital.dialogue)
		_step(Session.flag(StringName(ShatteredGallery.FLAG_MIRROR_SEEN)), "postgame: looking into the mirror counts (Gallery step)")
		var through: Button = driver.find_button("Step through")
		_step(through != null or Session.side_unlocked(ShatteredGallery.DUNGEON_ID), "postgame: the Gallery opens from the mirror")
		if through != null:
			await driver.click(driver.button_center(through))
			await driver.seconds(1.0)
			var deck_ok: Button = driver.find_button("Use this deck")
			if deck_ok != null:
				await driver.click(driver.button_center(deck_ok))
		var gallery_map: Node = await _wait_for_short(DungeonMapScreen)
		if gallery_map == null and Session.side_unlocked(ShatteredGallery.DUNGEON_ID):
			_note("DEV HELP: postgame - the Gallery entry was not driven through its dialog; entered with the Dev Menu's travel")
			DevActions.travel_dungeon(ShatteredGallery.DUNGEON_ID)
			gallery_map = await _wait_for(DungeonMapScreen)
		_step(gallery_map != null, "postgame: the Shattered Gallery's map opens")
		if gallery_map != null:
			if _real:
				await _boss_for_real(func() -> bool: return Session.flag(ShatteredGallery.FLAG_CLEARED), "the Gallery", "S-GALLERY")
			else:
				Session.resolve_mini_dungeon(true)
			await driver.seconds(2.0)
			_step(Session.flag(ShatteredGallery.FLAG_CLEARED), "postgame: the Shattered Gallery is cleared")
	# 4. Swolympus: Old Man Mountain's "Only the Worthy..." (by flag/counter: DEV HELP), then the climb
	_note("DEV HELP: postgame - Old Man Mountain's shake errand done by its counter; Swolympus entered with the Dev Menu's travel")
	Session.start_quest("side_s_beef")
	Session.bump_counter(GainlandsZone.COUNTER_SHAKES)
	Session.refresh_quests()
	Session.turn_in_quest("side_s_beef")
	_step(Session.quest_log.is_completed("side_s_beef") and Session.side_unlocked("S-BEEF"), "postgame: Only the Worthy... opens Mount Swolympus")
	DevActions.travel_dungeon("S-BEEF")
	var climb: Node = await _wait_for(DungeonMapScreen)
	_step(climb != null, "postgame: the Ascent of Mount Swolympus opens")
	var climb_name: String = DungeonCatalog.find("S-BEEF").dungeon_name
	if climb != null:
		if _real:
			await _boss_for_real(func() -> bool: return Session.cleared_dungeons.has(climb_name), "Swolympus", "S-BEEF")
		else:
			Session.resolve_mini_dungeon(true)
		await driver.seconds(2.0)
	_step(Session.cleared_dungeons.has(climb_name), "postgame: Swolympus is climbed (Loose Ends step 1)")
	var loose: QuestData = QuestCatalog.find("loose_ends")
	_step(loose != null and Session.quest_log.objective_met(loose, 0, Session.unlock_state()) and Session.quest_log.objective_met(loose, 1, Session.unlock_state()), "postgame: Loose Ends shows Swolympus and the forest done (the arena bout is left)")
	await _shot("p_postgame_end")


## Skipping the Lab's nodes skips Cell 4, where Elowen joins (her boon on the run): give it as the cell would.
func _grant_lab_boon() -> void:
	if Session.dungeon_key == PathologyLab.DUNGEON_ID and Session.run != null and not PathologyLab.rescued(Session.run):
		Session.run.dungeon_sources.append(PathologyLab.rescuer_boon())
		_note("DEV HELP: the Lab - Cell 4 skipped by the map walk; Elowen's boon given as the cell gives it")


## The nodes before a boss were skipped by the map walk, and with them their XP and rewards: bring the hero to the expected player's level,
## deck and gear for this dungeon (ProgressionModel, as the snapshots do), logged as DEV HELP. Never lowers anything.
func _catch_up(expected_key: String, label: String) -> void:
	if expected_key.is_empty() or Session.profile == null:
		return
	var level: int = ProgressionModel.level_for(expected_key, Session.profile.level)
	if level <= Session.profile.level:
		return
	_note("DEV HELP: %s - level %d -> %d with the reference deck and gear (the skipped nodes' XP)" % [label, Session.profile.level, level])
	DevActions.set_level(level, true)
	var path: Affinity.Type = Session.profile.primary_affinity
	var deck: Deck = ProgressionModel.reference_deck(Session.content, path, level)
	for card: CardData in deck.cards:
		if Session.profile.owned_copies(card.id) < deck.count_of(card.id):
			Session.profile.owned_cards.append(card)
	EventBus.collection_changed.emit()
	Session.save_deck_to_slot(Session.deck_box.active, deck, "%s deck" % Affinity.display_name(path))
	for slot_value: int in EquipmentData.Slot.values():
		Session.profile.unlock_equipment_slot(slot_value as EquipmentData.Slot)
	Session.pending_equipment_choices = 0
	for piece_id: String in ProgressionModel.equipment_for(level):
		var piece: EquipmentData = Session.content.equipment_piece(piece_id)
		if piece != null:
			Session.grant_equipment(piece)
			Session.equip_item(piece)
	if Session.run != null:
		Session.run.hp = maxi(Session.run.hp, Session.profile.base_max_hp())


## Back into the dungeon a real loss carried the hero out of (expected_key names it), so it can be decreed from its entrance.
func _reenter(expected_key: String) -> void:
	DevActions.full_heal()
	var side_plan: DungeonCatalog.Blueprint = DungeonCatalog.find(expected_key) if expected_key.begins_with("S-") else null
	match expected_key:
		"TUTORIAL":
			Session.begin_intro_trial(_path_type())
		"S-NECRO", "S-GOUR", "S-REF":
			if side_plan != null:
				Session.begin_zone_visit(side_plan.zone_id if not side_plan.zone_id.is_empty() else _current_zone)
			Session.enter_mini_dungeon()
		"D-LAB":
			Session.enter_lab()
		"S-GALLERY", "S-BEEF":
			DevActions.travel_dungeon(expected_key)
		_:
			var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(expected_key)
			var zone: String = plan.zone_id if plan != null else ""
			if expected_key != "D-PC" and not _current_zone.is_empty():
				zone = _current_zone
			if not zone.is_empty():
				Session.begin_zone_visit(zone)
				Session.enter_main_dungeon()
	await _wait_for(DungeonMapScreen)
	await driver.seconds(1.0)
	_grant_lab_boon()


# ---- Overnight Nov 9, Part 1: --full (every fight real) ---------------------------------------------------------------------------------


func _on_gold(total: int) -> void:
	if total > _last_gold:
		_gold_earned += total - _last_gold
	_last_gold = total


func _wall(text: String) -> void:
	_walls.append(text)
	_note("WALL: %s - decreed after %d tries" % [text, MAX_TRIES])


## The next node a player would take: a shrine when hurt, otherwise the first open node (dead-end treasure and fights included, as a
## completionist would); the boss last of all.
func _pick_node(map: DungeonMap) -> int:
	var open: Array[DungeonMap.MapNode] = map.available()
	if open.is_empty():
		# standing on an unfinished node (a lost or interrupted fight, the boss after a respawn): take it again
		if map.current >= 0 and not map.is_cleared(map.current) and map.node(map.current) != null and map.node(map.current).kind != DungeonMap.Kind.START:
			return map.current
		# nothing open from here: any unfinished node next to a finished one (logged, so a real dead end shows in the report)
		for candidate: DungeonMap.MapNode in map.nodes:
			if not map.is_cleared(candidate.id) and candidate.kind != DungeonMap.Kind.START and map.neighbour_cleared(candidate.id):
				_note("DEV HELP: %s map - nothing open from node %d (%s, next %s, cleared %s); took node %d" % [map.dungeon_name, map.current, DungeonMap.Kind.keys()[map.node(map.current).kind], str(map.node(map.current).next), str(map.cleared), candidate.id])
				return candidate.id
		return -1
	var hurt: bool = Session.run != null and Session.run.hp * 10 < Session.run.max_hp() * 6
	var best: DungeonMap.MapNode = null
	var best_score: int = -999
	for node: DungeonMap.MapNode in open:
		var score: int = 0
		match node.kind:
			DungeonMap.Kind.SHRINE:
				score = 50 if hurt else 5
			DungeonMap.Kind.TREASURE:
				score = 30
			DungeonMap.Kind.EVENT, DungeonMap.Kind.RESCUE:
				score = 25
			DungeonMap.Kind.BATTLE, DungeonMap.Kind.CHALLENGE:
				score = 20
			DungeonMap.Kind.ELITE:
				score = 0 if hurt else 15
			DungeonMap.Kind.BOSS:
				score = -10
		if score > best_score:
			best_score = score
			best = node
	return best.id


## A node screen (challenge, shrine, event, treasure): press what a player would press until it closes.
func _drive_modal(modal: Control) -> void:
	var prefer: Array[String] = ["Reveal", "Open the chest", "Rest", "Continue", "Leave it (no test)"]
	for _guard: int in range(40):
		if not is_instance_valid(modal) or not modal.is_inside_tree():
			return
		await driver.seconds(0.35)
		var buttons: Array[Button] = []
		for node: Node in modal.find_children("*", "Button", true, false):
			var button: Button = node as Button
			if button.is_visible_in_tree() and not button.disabled:
				buttons.append(button)
		if buttons.is_empty():
			await driver.tap_key(KEY_ENTER)
			continue
		var chosen: Button = null
		for text: String in prefer:
			for button: Button in buttons:
				if button.text.strip_edges() == text:
					chosen = button
					break
			if chosen != null:
				break
		if chosen == null:
			chosen = buttons[0]  # an event's first choice
		await driver.click(driver.button_center(chosen))
	if is_instance_valid(modal) and modal.is_inside_tree():
		_note("DEV HELP: a %s node screen would not close - finished by its signal" % modal.get_class())
		modal.emit_signal("finished")


## Between tries and after each zone: open every pack, put on the best gear in each open slot, and take the Deck Station's own "Suggest a
## deck" for the hero's Path from the whole collection (what a player who uses that button would fight with).
func _tend_deck(why: String) -> void:
	if Session.profile == null:
		return
	var opened: int = PacksScreen.open_all().size()
	for slot_value: int in EquipmentData.Slot.values():
		var slot: EquipmentData.Slot = slot_value as EquipmentData.Slot
		if not Session.profile.has_equipment_slot(slot):
			continue
		var best: EquipmentData = Session.profile.equipped_in(slot)
		for item: EquipmentData in Session.profile.owned_equipment:
			if item == null or item.slot != slot:
				continue
			if best == null or item.tier * 10 + int(item.rarity) > best.tier * 10 + int(best.rarity):
				best = item
		if best != null and best != Session.profile.equipped_in(slot):
			Session.equip_item(best)
	var infrastructure: Array[CardData] = []
	for color: Affinity.Type in Affinity.colored_types():
		infrastructure.append(Session.content.infrastructure[int(color)] as CardData)
	var paths: Array[Affinity.Type] = [Session.profile.primary_affinity]
	var deck: Deck = DeckInsights.suggest(Session.profile.owned_cards, paths, Session.profile.level, infrastructure, DeckValidator.min_deck_size())
	if deck != null and deck.size() >= DeckValidator.min_deck_size():
		Session.save_deck_to_slot(Session.deck_box.active, deck, "%s deck" % Affinity.display_name(paths[0]))
	print("%s: tend deck (%s): %d packs opened, deck %d cards, level %d, gold %d" % [TAG, why, opened, Session.deck.size() if Session.deck != null else 0, Session.profile.level, Session.gold])


func _full_summary() -> void:
	if not _full:
		return
	var hours: float = Session.playtime_seconds / 3600.0
	var wall: float = float(Time.get_ticks_msec() - _wall_started) / 3600000.0
	print("%s: FULL path=%s completed=%s postgame_lab=%s gallery=%s level=%d game_hours=%.2f wall_hours=%.2f gold_earned=%d gold_now=%d losses=%d walls=%d" % [
		TAG, _path_zone, Session.flag(&"primm_defeated"), Session.flag(PathologyLab.FLAG_RESCUER_FREED), Session.flag(ShatteredGallery.FLAG_CLEARED),
		Session.profile.level if Session.profile != null else 0, hours, wall, _gold_earned, Session.gold, _losses.size(), _walls.size()])
	for loss: String in _losses:
		print("%s: FULL loss %s" % [TAG, loss])
	for item: String in _walls:
		print("%s: FULL wall %s" % [TAG, item])


## The rewards screen after a fight: choose the rarest card of the pick (a player's usual choice) and take it, then Continue.
func _take_rewards(screen: RewardsScreen) -> void:
	await driver.seconds(0.4)
	if not is_instance_valid(screen) or not screen.is_inside_tree():
		return
	if screen._confirmed:
		# taken: the level-up panel(s) or a boss talk are up - press through them (the topmost button), never Take again
		var talk: Node = null
		for node: Node in screen.find_children("*", "DialogueBox", true, false):
			if (node as DialogueBox).active:
				talk = node
		if talk != null:
			await _dismiss_dialogue(talk as DialogueBox)
			return
		var last: Button = null
		for node: Node in screen.find_children("*", "Button", true, false):
			var button: Button = node as Button
			var label: String = button.text.strip_edges()
			if button.is_visible_in_tree() and not button.disabled and (label.begins_with("Next level") or label.begins_with("Continue") or label.begins_with("Got it") or label.begins_with("Done") or label.begins_with("Step outside") or label.begins_with("Onward")):
				last = button
		if last != null:
			await driver.click(driver.button_center(last))
		else:
			await _dismiss_popups()
		await driver.seconds(0.5)
		return
	if not screen._cards.is_empty() and is_instance_valid(screen._take_button) and screen._take_button.is_visible_in_tree():
		if screen._selected < 0:
			screen._select(screen._best_index())
			await driver.seconds(0.3)
		if is_instance_valid(screen) and is_instance_valid(screen._take_button) and not screen._take_button.disabled:
			screen._take_button.pressed.emit()
		await driver.seconds(0.8)
		return
	await _dismiss_popups()
	var go_on: Button = driver.find_button("Continue")
	if go_on != null:
		await driver.click(driver.button_center(go_on))
	else:
		await driver.tap_key(KEY_ENTER)
	await driver.seconds(0.6)


## Overnight Nov 9, Part 1: a stall guard for --full. When nothing has changed for STALL_SECONDS (same scene, same fights, same map
## progress), it logs the scene and every visible button, then presses what a player would to get past a box (Got it, Continue, Skip tips,
## OK, Close, Enter). Returns true when it acted.
const STALL_SECONDS: float = 20.0
var _stall_sig: String = ""
var _stall_since: int = 0
var _stall_kicks: int = 0


func _unstick(scene: Node, fights: int) -> bool:
	var cleared: int = Session.dungeon_map.cleared.size() if Session.dungeon_map != null else -1
	var sig: String = "%s|%d|%d|%d" % [scene.name if scene != null else "none", fights, cleared, int(_fights["won"]) + int(_fights["lost"])]
	var now: int = Time.get_ticks_msec()
	if sig != _stall_sig:
		_stall_sig = sig
		_stall_since = now
		_stall_kicks = 0
		return false
	if float(now - _stall_since) / 1000.0 < STALL_SECONDS:
		return false
	_stall_since = now
	_stall_kicks += 1
	var names: PackedStringArray = []
	for node: Node in get_tree().root.find_children("*", "Button", true, false):
		var button: Button = node as Button
		if button.is_visible_in_tree() and not button.text.strip_edges().is_empty():
			names.append("%s%s" % [button.text.strip_edges(), " (off)" if button.disabled else ""])
	var where: String = ""
	if Session.dungeon_map != null and Session.dungeon_map.node(Session.dungeon_map.current) != null:
		var here: DungeonMap.MapNode = Session.dungeon_map.node(Session.dungeon_map.current)
		where = " map current %d %s next %s cleared %s" % [here.id, DungeonMap.Kind.keys()[here.kind], str(here.next), str(Session.dungeon_map.cleared)]
	if scene is DungeonMapScreen:
		var ms: DungeonMapScreen = scene as DungeonMapScreen
		var tops: PackedStringArray = []
		for child: Node in ms.get_children():
			if child is CanvasItem and (child as CanvasItem).visible:
				tops.append("%s:%s" % [child.name, child.get_class()])
		var nxt: String = ""
		for n: DungeonMap.MapNode in Session.dungeon_map.available():
			nxt += " [%d %s scene=%s talk=%s story=%s]" % [n.id, DungeonMap.Kind.keys()[n.kind], n.scene, n.talk_before, n.story_before]
		where += " | busy=%s modal=%s dialogue=%s next:%s | tops %s" % [ms._busy, ms._modal, ms._dialogue.active if ms._dialogue != null else false, nxt, ",".join(tops.slice(-8))]
	print("%s: STALL %d at %s: buttons %s%s" % [TAG, _stall_kicks, sig, ", ".join(names), where])
	for text: String in ["Got it", "Skip tips", "Continue", "OK", "Close", "Next level", "Step outside", "Onward", "Take", "Leave"]:
		for node: Node in get_tree().root.find_children("*", "Button", true, false):
			var button: Button = node as Button
			if button.is_visible_in_tree() and not button.disabled and button.text.strip_edges().begins_with(text):
				await driver.click(driver.button_center(button))
				await driver.seconds(0.5)
				return true
	await driver.tap_key(KEY_ENTER if _stall_kicks % 2 == 1 else KEY_E)
	return true


## Overnight Nov 9, Part 1 (--full): the hero's seat is played by the game's own planning AI (AIPlayer, balanced personality, ELITE skill - the
## player the balance sims use) through BattleScreen.set_bot: every card, attack, block, mulligan and Peek goes through the real game rules
## and the real battle screen. No item use (a human would have that edge). "won", "lost" or "stalled".
func _ai_fight(battle: BattleScreen) -> String:
	var started: int = Time.get_ticks_msec()
	await driver.seconds(0.3)
	if is_instance_valid(battle) and battle.human_bot == null:
		battle.set_bot(AIPlayer.for_foe(AIPersonality.balanced(), AIPlayer.Skill.ELITE))
	var last_turn: int = -1
	var last_change: int = Time.get_ticks_msec()
	while is_instance_valid(battle) and battle.mode != BattleScreen.Mode.OVER:
		if float(Time.get_ticks_msec() - started) / 1000.0 > 600.0:
			return "stalled"
		for text: String in ["Got it", "Skip tips"]:
			var tip: Button = driver.find_button(text)
			if tip != null:
				await driver.click(driver.button_center(tip))
		if battle.game != null and battle.game.turn != last_turn:
			last_turn = battle.game.turn
			last_change = Time.get_ticks_msec()
		elif float(Time.get_ticks_msec() - last_change) / 1000.0 > 90.0:
			return "stalled"
		await driver.seconds(0.4)
	if not is_instance_valid(battle):
		return "won"
	for _i: int in range(20):
		if battle._result_shown:
			break
		await driver.seconds(0.2)
	return "won" if battle.context.won else "lost"
