class_name TenthBriefFinalSmoke
extends Node
## FINAL (brief 10): the Capital, the Castle, the boss and the ending with human-style input (real injected keys/clicks), end to end:
## 1 enter the Capital through the town's last gate (walk + E), 2 the SECRET ENTRANCE (a hidden hatch found by exploring: no marker, no map icon)
## which sneaks past the gate into the hideout and out into the city, 3 back out and the GATE BATTLE (Entry Examination) which opens the gate,
## 4 the Showcase Quarter (the facade) and its hollow citizens, 5 a RIFT hazard (contact damage), 6 one Path QUEST (the Necrocrat burial: offer, stamp,
## plot, hand-in, reward, insight, quest log), 7 the CASTLE run through a branch that dead-ends and doubles back to the boss's three phases,
## 8 the ENDING sequence (credits, the postgame announcement, the changed Capital), 9 a 3+ Path deck is legal after the unlock.
## Deliberate shortcuts (stated): duels are resolved by forcing the win (a human-played duel is covered by the earlier e2e flows), long walks
## fall back to teleports between far-apart places, and the quest steps move between districts by teleport.
## Screenshots: _screenshots/brief10/.   Godot --path . res://tools/tenth_brief_final_launcher.tscn

const SHOT_DIR: String = "res://_screenshots/brief10/"
const TAG: String = "tenth_brief_final_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	# Shortcut (stated): the Capital is the END of the game, so the player is an endgame-level character (max HP), not a level-1 one.
	Session.profile.max_hp = PlayerProfile.ENDGAME_MAX_HP
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)
	if OS.get_cmdline_user_args().has("--castle_only"):
		Session.set_flag(CapitalZone.FLAG_GATE_OPEN)
		Session.set_flag(CapitalZone.FLAG_INSIDE)
		Session.enter_zone(CapitalZone.ID)
		await _wait_for(CapitalScene)
		if OS.get_cmdline_user_args().has("--with_city"):
			await _flow_facade()
			await _flow_rift()
			await _flow_quest()
		await _flow_castle()
		await _flow_ending()
		await _flow_postgame_deck()
		_finish(_failures.is_empty(), "castle-only debug run (%d screenshots)" % _shots)
		return
	await _flow_enter_capital(town)
	await _flow_secret_entrance()
	await _flow_gate_battle()
	await _flow_facade()
	await _flow_rift()
	await _flow_quest()
	await _flow_castle()
	await _flow_ending()
	await _flow_postgame_deck()
	_finish(_failures.is_empty(), "Capital via the gate battle and the secret entrance, facade, rift, quest, castle with a dead end, boss phases, ending, postgame deck (%d screenshots)" % _shots)


# ---- 1: the town's final entrance leads to the Capital --------------------------------------------------------


func _flow_enter_capital(town: TownScene) -> void:
	_check(Session.completed_zone_count() == 0, "no zone is free: the Capital is still reachable from the start")
	await _walk_to(town, town.town.anchors["portal_final"] as Vector3, 1.6)
	await driver.seconds(0.4)
	await _shot("01_town_final_entrance")
	await driver.tap_key(KEY_E)
	var zone: CapitalScene = await _wait_for(CapitalScene) as CapitalScene
	_check(zone != null, "the town's last entrance leads to the Capital")
	if zone == null:
		return
	await driver.seconds(1.5)
	_check(zone.hud.find_child("ServiceDebuffsPanel", true, false) != null, "the HUD shows the broken services")
	var panel: Control = zone.hud.find_child("ServiceDebuffsPanel", true, false) as Control
	_check(panel != null and panel.tooltip_text.length() > 10, "with a tooltip")
	_check(CapitalDebuffs.active(Session.flags).size() == 4, "all four services are broken")
	_check(not Session.flag(CapitalZone.FLAG_GATE_OPEN), "the gate is closed")
	await _shot("02_capital_outskirts_and_debuffs")


# ---- 2: the secret entrance ----------------------------------------------------------------------------------------


func _flow_secret_entrance() -> void:
	var zone: CapitalScene = get_tree().current_scene as CapitalScene
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	_check(bool(def.spot_def("tunnel_in").get("hidden", false)), "the tunnel hatch is a hidden spot (no marker, no plate, no minimap icon)")
	for spot: ZoneSpot in zone.spots:
		if spot.id == "tunnel_in":
			_check(not spot.marker.visible and not spot.plate.visible, "no marker or plate is shown at the hatch")
	_check(not zone._collect_pois().any(func(poi: MapPoi) -> bool: return poi.label.contains("Collapsed")), "and it is not on the map")
	# Explore the south-west of the Outskirts: walk the last stretch to the hatch.
	var hatch: Vector3 = zone.builder.anchor("tunnel_in")
	await _teleport(zone, hatch + Vector3(5.0, 0.0, 4.0))
	await driver.seconds(0.5)
	await _walk_to(zone, hatch + Vector3(0.0, 0.0, 0.3), 1.4)
	await driver.seconds(0.4)
	_check(zone._near != null and zone._near.id == "tunnel_in", "only up close does a prompt appear")
	await _shot("03_secret_hatch_prompt")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(zone.dialogue)
	await driver.seconds(1.6)
	_check(Session.found_secret(CapitalZone.SECRET_TUNNEL), "the secret was found (docs/design/secrets.md)")
	_check(zone.player.position.z > CapitalBuilder.CREASE_Z, "the tunnel leads into the hideout (the Crease)")
	_check(not Session.flag(CapitalZone.FLAG_GATE_OPEN), "without opening the gate: the player sneaked past it")
	await _shot("04_the_crease_hideout")
	# The hideout: heal spot, vendor, resistance NPCs; the shaft network is down (Blackout).
	_check(_has_spot(zone, "heal") and _has_spot(zone, "fig") and _has_spot(zone, "wren"), "the hideout has a heal spot, a black market and resistance NPCs")
	await _teleport(zone, zone.builder.anchor("shaft_plaza") + Vector3(0, 0, -0.9))
	await driver.seconds(0.3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(zone.dialogue.active, "the service shaft says the network is down (no travel while the Beefcake service is broken)")
	await _dismiss(zone.dialogue)
	# Up the ladder into the city (through the manhole by the gate), still without the gate.
	await _teleport(zone, zone.builder.anchor("ladder_up") + Vector3(0, 0, 0.5))
	await driver.seconds(0.3)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(1.8)
	_check(zone.player.position.z < float(CapitalLayout.WALL_Z0) and zone.player.position.z > 40.0, "up the ladder: inside the walls at the manhole, gate still closed")
	await _shot("05_inside_the_walls_via_the_tunnel")
	# And back out through the tunnel to the Outskirts for the gate battle.
	await _teleport(zone, zone.builder.anchor("manhole") + Vector3(0, 0, 0.4))
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(1.8)
	await _teleport(zone, zone.builder.anchor("tunnel_out") + Vector3(0, 0, -0.4))
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(1.8)
	_check(zone.player.position.z > 60.0 and zone.player.position.z < 90.0, "back out through the tunnel in the Outskirts")


# ---- 3: the gate battle ----------------------------------------------------------------------------------------------


func _flow_gate_battle() -> void:
	var zone: CapitalScene = get_tree().current_scene as CapitalScene
	var captain: Vector3 = zone.builder.anchor("spotless")
	await _teleport(zone, captain + Vector3(0, 0, 5.0))
	await _walk_to(zone, captain + Vector3(0, 0, 1.0), 1.5)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(zone.dialogue.active, "Captain Spotless states the absurd entry requirements")
	await _shot("06_spotless_dialogue")
	await _dismiss(zone.dialogue)
	await driver.seconds(0.6)
	await _shot("07_gate_battle_offer")
	_check(await driver.click_button("Take the examination"), "the Entry Examination is a card battle")
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null and battle.context.zone_battle and battle.context.zone_enemy_type == CapitalEnemies.SPOTLESS, "the gate battle opened")
	if battle == null:
		return
	await driver.seconds(1.5)
	_check(battle.find_child("ServiceDebuffsPanel", true, false) != null, "the duel shows the broken services")
	_check(battle.context.game.players[1].hp > ZoneEnemies.info(CapitalZone.ID, CapitalEnemies.OFFICER).hp, "a challenging opponent")
	await _shot("08_gate_battle")
	await _force_win(battle)
	zone = await _wait_for(CapitalScene) as CapitalScene
	_check(zone != null and Session.flag(CapitalZone.FLAG_GATE_OPEN), "winning opened the gate")
	await driver.seconds(1.2)
	await _dismiss(zone.dialogue)
	await _shot("09_gate_open")
	await _walk_to(zone, zone.builder.anchor("gate_inside"), 1.6)
	await driver.seconds(0.5)
	_check(zone.player.position.z < float(CapitalLayout.WALL_Z0), "the player walked through the gate into the city")


# ---- 4: The Showcase Quarter ---------------------------------------------------------------------------------------------


func _flow_facade() -> void:
	var zone: CapitalScene = get_tree().current_scene as CapitalScene
	await _walk_to(zone, zone.builder.anchor("facade_gate"), 1.8)
	await _teleport(zone, zone.builder.anchor("fountain") + Vector3(0, 0, 4.5))
	await driver.seconds(0.8)
	await _shot("10_primms_perfection_facade")
	var citizen: Vector3 = zone.builder.anchor("citizen_3")
	await _teleport(zone, citizen + Vector3(0, 0, 1.2))
	await driver.seconds(0.3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(zone.dialogue.active, "a facade citizen speaks")
	var first_line: String = zone.dialogue._text.text
	_check(first_line.contains("identical"), "with an approved phrase (%s)" % first_line.left(40))
	await _dismiss(zone.dialogue)
	for repeat: int in range(1):
		await driver.tap_key(KEY_E)
		await driver.seconds(0.4)
		await _dismiss(zone.dialogue)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _shot("11_citizen_slip")
	await _dismiss(zone.dialogue)
	var door: Vector3 = zone.builder.anchor("door_1")
	await _teleport(zone, door + Vector3(0, 0, 0.3))
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(zone.dialogue.active and zone.dialogue._text.text.contains("painted"), "a facade door does not open: it is painted on")
	await _dismiss(zone.dialogue)
	# Deface a portrait: a real effect.
	var gold: int = Session.gold
	await _teleport(zone, zone.builder.anchor("portrait_f1") + Vector3(0, 0, 0.5))
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.gold == gold + CapitalZone.DEFACE_REWARD, "defacing propaganda paid a small reward")


# ---- 5: a rift ------------------------------------------------------------------------------------------------------------


func _flow_rift() -> void:
	var zone: CapitalScene = get_tree().current_scene as CapitalScene
	var rift: Vector3 = zone.builder.anchor("rift_reek")
	await _teleport(zone, rift + Vector3(-5.0, 0.0, 3.5))
	await driver.seconds(0.8)
	await _shot("12_corrupted_reek_and_rift_approach")
	zone._spawn_grace = 0.0
	zone._invulnerable = 0.0
	var before: int = Session.zone_run.hp
	await _walk_to(zone, rift, 0.8)
	await driver.seconds(0.5)
	await _shot("13_rift_contact")
	_check(Session.zone_run.hp < before, "touching a rift hurts (%d -> %d HP)" % [before, Session.zone_run.hp])
	_check(zone.capital.rift_nodes.has("reek"), "the rift is on the map's scenery")
	# Healing at the hideout is only a teleport away: restore HP for the rest of the flow.
	Session.zone_run.fully_heal()


# ---- 6: one Path quest (the Necrocrat burial) -------------------------------------------------------------------------------


func _flow_quest() -> void:
	var zone: CapitalScene = get_tree().current_scene as CapitalScene
	await _teleport(zone, zone.builder.anchor("pell") + Vector3(0, 0, 1.2))
	await driver.seconds(0.3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _shot("14_quest_offer_pell")
	await _dismiss(zone.dialogue)
	_check(Session.quest_log.active.has(CapitalZone.QUEST_BURIAL), "Widow Pell's quest was accepted")
	await _teleport(zone, zone.builder.anchor("stamp") + Vector3(0, 0, 0.6))
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.flag(CapitalZone.FLAG_STAMP), "found the Stamp of Final Approval")
	await _teleport(zone, zone.builder.anchor("pell_plot") + Vector3(0, 0, 0.6))
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	await _dismiss(zone.dialogue)
	_check(Session.flag(CapitalZone.FLAG_LAID_TO_REST), "Mr. Pell was laid to rest")
	var gold: int = Session.gold
	await _teleport(zone, zone.builder.anchor("pell") + Vector3(0, 0, 1.2))
	await driver.seconds(0.3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _shot("15_quest_handin")
	await _dismiss(zone.dialogue)
	await driver.seconds(0.6)
	await _clear_overlays(zone)
	_check(Session.quest_log.completed.has(CapitalZone.QUEST_BURIAL) or Session.completed_quests.has(CapitalZone.QUEST_BURIAL), "the quest completed")
	_check(Session.gold > gold, "gold was rewarded")
	_check(Session.owned_count("N-23") > 0, "a card was rewarded")
	_check(Session.flag(CapitalZone.insight_flag("necrocrat")), "and a story insight into Primm")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.8)
	await _shot("16_quest_log")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)
	if zone._overlay != null:
		zone._close_overlay()
	# Enemies: a slow battle-starter chases, and a fast damage type exists.
	_check(zone.enemies.any(func(enemy: ZoneEnemy) -> bool: return enemy.info.kind == ZoneEnemyInfo.Kind.BATTLE and enemy.info.chase_speed < ZoneEnemies.PLAYER_SPEED), "slow battle-starting enemies roam")
	_check(zone.enemies.any(func(enemy: ZoneEnemy) -> bool: return enemy.info.kind == ZoneEnemyInfo.Kind.DAMAGE), "and fast damage-dealing ones")


# ---- 7: the castle: a dead end that doubles back, then the boss's three phases -----------------------------------------------


func _flow_castle() -> void:
	var zone: CapitalScene = get_tree().current_scene as CapitalScene
	await _teleport(zone, zone.builder.anchor("castle_door") + Vector3(0, 0, 1.4))
	await driver.seconds(0.8)
	await _shot("17_castle_approach")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(await driver.click_button("Enter the castle"), "the castle door asks to enter")
	var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	_check(map_screen != null and Session.main_dungeon_active, "entered Primm's Castle")
	if map_screen == null:
		return
	await driver.seconds(1.0)
	_check(map_screen.map.nodes.size() >= 20, "%d nodes (20+)" % map_screen.map.nodes.size())
	_check(map_screen.map.problems().is_empty(), "the map is sound")
	var visited: Array[String] = []
	var steps: int = 0
	var doubled_back: bool = false
	var saw_boss_phases: int = 0
	while steps < 160:
		steps += 1
		var scene: Node = get_tree().current_scene
		if steps % 10 == 0:
			print("%s: castle loop %d scene=%s busy=%s" % [TAG, steps, scene.get_class() if scene == null else str(scene.get_script().get_global_name()), str(SceneManager.busy)])
		if scene is EndingScreen:
			break
		if scene is CapitalScene:
			break
		if scene is DungeonMapScreen:
			map_screen = scene as DungeonMapScreen
			await _dismiss_map_story(map_screen)
			if map_screen.find_child("CutsceneScreen", true, false) != null:
				await _advance_cutscene(map_screen)
				continue
			if map_screen._busy or map_screen._modal != null:
				await _drive_modal(map_screen)
				await driver.seconds(0.4)
				continue
			var options: Array[DungeonMap.MapNode] = map_screen.map.available()
			if options.is_empty():
				await driver.seconds(0.5)
				continue
			# The first time at the Portrait Gallery, take the dead-end alcove and watch the party double back.
			var node: DungeonMap.MapNode = _pick(map_screen.map, options)
			print("%s: castle step %d -> %s (HP %d)" % [TAG, steps, node.title, Session.run.hp])
			if node.return_to >= 0 and not doubled_back:
				await _shot("18_castle_map_before_dead_end")
			var branch_point: int = node.return_to
			visited.append(node.title)
			var button: MapNodeButton = map_screen._buttons[node.id] as MapNodeButton
			await driver.click(driver.center_of_control(button))
			await driver.seconds(0.6)
			await _handle_node(node)
			if node.return_to >= 0:
				var now: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
				await driver.seconds(0.8)
				if now != null:
					doubled_back = now.map.current == branch_point and now.map.is_cleared(node.id)
					_check(doubled_back, "the dead end '%s' was cleared and the party doubled back to its branch point" % node.title)
					await _shot("19_castle_map_after_doubling_back")
		elif scene is BattleScreen:
			var context: BattleContext = (scene as BattleScreen).context
			if context.boss_phase >= 0:
				saw_boss_phases += 1
				await driver.seconds(1.2)
				_check((scene as BattleScreen).find_child("PhaseRulePanel", true, false) != null, "boss phase %d shows its rule" % (context.boss_phase + 1))
				await _shot("2%d_boss_phase_%d" % [context.boss_phase, context.boss_phase + 1])
			await _force_win(scene)
		elif scene is RewardsScreen:
			if steps % 10 == 0:
				var names: PackedStringArray = []
				for node: Node in scene.find_children("*", "Button", true, false):
					if (node as Button).is_visible_in_tree():
						names.append("%s%s" % [(node as Button).text, "(off)" if (node as Button).disabled else ""])
				print("%s: rewards buttons: %s ; children: %s" % [TAG, ", ".join(names), ", ".join(scene.get_children().map(func(child: Node) -> String: return child.get_class() + ":" + child.name))])
				await _shot("2z_rewards_%d" % steps)
			await _finish_rewards(scene as RewardsScreen)
		else:
			await driver.seconds(0.5)
	_check(visited.size() >= 14, "walked %d nodes: %s" % [visited.size(), ", ".join(visited)])
	_check(doubled_back, "a dead-end branch was taken")
	_check(saw_boss_phases == PrimmBoss.PHASES, "the boss was fought in %d phases" % saw_boss_phases)
	_check(Session.profile.postgame_unlocked, "beating Primm unlocked the postgame")


## Prefers the first dead end (once), otherwise the first forward route.
func _pick(map: DungeonMap, options: Array[DungeonMap.MapNode]) -> DungeonMap.MapNode:
	if not _dead_end_done:
		for option: DungeonMap.MapNode in options:
			if option.return_to >= 0:
				_dead_end_done = true
				return option
	for option: DungeonMap.MapNode in options:
		if option.return_to < 0:
			return option
	return options[0]


var _dead_end_done: bool = false


# ---- 8: the ending -----------------------------------------------------------------------------------------------------------


func _flow_ending() -> void:
	var ending: EndingScreen = await _wait_for(EndingScreen) as EndingScreen
	_check(ending != null, "the ending sequence plays")
	if ending == null:
		return
	await driver.seconds(1.2)
	for beat: int in range(EndingDefs.BEATS.size()):
		if beat == 0 or beat == 2 or beat == 4:
			await _shot("30_ending_beat_%d" % (beat + 1))
		await driver.tap_key(KEY_SPACE)
		await driver.seconds(0.3)
		await driver.tap_key(KEY_SPACE)
		await driver.seconds(0.9)
	await driver.seconds(1.5)
	_check(ending._credits_running, "placeholder credits roll")
	await _shot("31_ending_credits")
	_check(await driver.click_button("Skip"), "credits can be skipped")
	await driver.seconds(1.2)
	var announcement: Node = ending.find_child("PostgameAnnouncement", true, false)
	_check(announcement != null, "the postgame is announced with a popup")
	await _shot("32_postgame_unlocked")
	_check(Session.profile.postgame_unlocked and Session.flag(&"primm_defeated"), "postgame_unlocked is set")
	_check(await driver.click_button("Continue"), "continue")
	var zone: CapitalScene = await _wait_for(CapitalScene) as CapitalScene
	_check(zone != null, "the player is returned to the world: the Capital")
	if zone == null:
		return
	await driver.seconds(1.5)
	await _clear_overlays(zone)
	await _dismiss(zone.dialogue)
	await _clear_overlays(zone)
	_check(Session.flag(CapitalZone.FLAG_FREED) and CapitalRifts.open_count(Session.flags) == 0, "the Capital changed: free, the rifts sealed")
	_check(zone.capital.rift_nodes.is_empty(), "no rifts in the world")
	_check(CapitalDebuffs.active(Session.flags).size() == 0, "no broken services remain")
	_check(zone.spots.any(func(spot: ZoneSpot) -> bool: return spot.id.begins_with("freed_")), "the freed leaders stand in the Crease")
	await _shot("33_changed_capital_castle_approach")
	await _teleport(zone, zone.builder.anchor("fountain") + Vector3(0, 0, 4.5))
	await driver.seconds(1.0)
	await _shot("34_changed_capital_facade_down")


# ---- 9: a 3+ Path deck is legal after the unlock -----------------------------------------------------------------------------


func _flow_postgame_deck() -> void:
	var zone: CapitalScene = await _wait_for(CapitalScene) as CapitalScene
	if zone == null:
		_check(false, "back in the Capital for the deck check")
		return
	var infrastructure: Array[CardData] = []
	for infra: Variant in Session.content.infrastructure.values():
		infrastructure.append(infra as CardData)
	for id: String in ["G-01", "R-02", "N-03"]:
		Session.add_cards([Session.card_by_id(id)] as Array[CardData])
	var editor: DeckEditor = DeckEditor.from(Session.profile, Session.deck, infrastructure)
	for id: String in ["G-01", "R-02", "N-03"]:
		editor.add(Session.card_by_id(id))
	_check(editor.deck.colors().size() >= 3, "a deck of %d Paths" % editor.deck.colors().size())
	_check(not DeckValidator.has_problem(editor.issues(), DeckValidator.Problem.TOO_MANY_COLORS), "is legal after the postgame unlock")
	Session.deck = editor.deck
	await driver.tap_key(KEY_B)
	await driver.seconds(1.0)
	await _shot("35_deck_builder_three_paths")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)
	if zone._overlay != null:
		zone._close_overlay()
	_check(Alchemy.tri_path_unlocked(Session.profile), "the Alchemist's tri-Path hook is available")


# ---- Helpers ---------------------------------------------------------------------------------------------------------------------


func _teleport(zone: CapitalScene, pos: Vector3) -> void:
	zone.player.position = pos
	zone.player.position.y = zone.builder.height_at(pos)
	zone._camera.position = zone.player.position + zone.camera_offset
	zone._spawn_grace = 60.0
	zone._invulnerable = 3.0
	Session.zone_run.fully_heal()
	await driver.seconds(0.4)


## Level-ups from XP rewards open an overlay that blocks the world: click through them.
func _clear_overlays(zone: ZoneScene) -> void:
	var guard: int = 0
	await driver.seconds(0.5)
	while zone._overlay != null and (zone._overlay is LevelUpScreen or zone._overlay is RewardPopup) and guard < 12:
		guard += 1
		var inner: Node = (zone._overlay as LevelUpScreen)._child_screen
		if inner is EquipmentSlotChoiceScreen:
			for slot: EquipmentData.Slot in [EquipmentData.Slot.HELM, EquipmentData.Slot.WEAPON, EquipmentData.Slot.ARMOR, EquipmentData.Slot.BOOTS, EquipmentData.Slot.RELIC]:
				if not Session.profile.has_equipment_slot(slot):
					(inner as EquipmentSlotChoiceScreen).chosen.emit(slot)
					break
			await driver.seconds(0.8)
			continue
		var next: Button = driver.find_button("Continue", zone._overlay)
		if next != null:
			await driver.click(driver.center_of_control(next))
		else:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.6)
	if zone._overlay != null and not ((zone._overlay is LevelUpScreen or zone._overlay is RewardPopup)):
		pass


func _has_spot(zone: ZoneScene, spot_id: String) -> bool:
	for spot: ZoneSpot in zone.spots:
		if spot.id == spot_id:
			return true
	return false


func _dismiss(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


func _dismiss_map_story(map_screen: DungeonMapScreen) -> void:
	var guard: int = 0
	while map_screen._dialogue != null and map_screen._dialogue.active and guard < 30:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


func _advance_cutscene(map_screen: DungeonMapScreen) -> void:
	var guard: int = 0
	while map_screen.find_child("CutsceneScreen", true, false) != null and guard < 30:
		guard += 1
		if guard == 2:
			await _shot("2x_castle_cutscene")
		await driver.tap_key(KEY_SPACE)
		await driver.seconds(0.3)
		await driver.tap_key(KEY_SPACE)
		await driver.seconds(0.4)


## Handles whatever the clicked node opened: a story, a cutscene, an event/treasure/shrine/challenge modal, or a battle.
func _handle_node(node: DungeonMap.MapNode) -> void:
	var guard: int = 0
	while guard < 60:
		guard += 1
		var scene: Node = get_tree().current_scene
		if not (scene is DungeonMapScreen):
			return
		var screen: DungeonMapScreen = scene as DungeonMapScreen
		if screen._dialogue != null and screen._dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.2)
			continue
		if screen.find_child("CutsceneScreen", true, false) != null:
			await _advance_cutscene(screen)
			continue
		if screen._modal != null:
			await _drive_modal(screen)
			return
		if screen._busy:
			return
		await driver.seconds(0.3)
		if screen.map.is_cleared(node.id):
			return


func _drive_modal(screen: DungeonMapScreen) -> void:
	var guard: int = 0
	while is_instance_valid(screen) and screen._modal != null and guard < 30:
		guard += 1
		var modal: Node = screen._modal
		var picked: bool = false
		var choice: Button = modal.find_child("Choice0", true, false) as Button
		if choice != null and choice.is_visible_in_tree() and not choice.disabled:
			await driver.click(driver.center_of_control(choice))
			picked = true
		if not picked:
			for text: String in ["Continue", "Rest", "Reveal", "Open the chest", "Take"]:
				var button: Button = driver.find_button(text, modal)
				if button != null and not button.disabled:
					await driver.click(driver.center_of_control(button))
					picked = true
					break
		await driver.seconds(0.9)
	await driver.seconds(0.8)


## Shortcut (stated): a duel is resolved by forcing the win, then flows through the real results/rewards.
func _force_win(battle_scene: Node) -> void:
	var context: BattleContext = (battle_scene as BattleScreen).context
	await driver.seconds(0.5)
	if context == null:
		return
	context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
	context.game._end_game(0, false)
	context.won = true
	Session.complete_battle(context)
	await driver.seconds(1.5)


func _finish_rewards(rewards: RewardsScreen) -> void:
	await driver.seconds(1.0)
	for child: Node in rewards.get_children():
		if child is LevelUpScreen:
			var inner: Node = (child as LevelUpScreen)._child_screen
			if inner is EquipmentSlotChoiceScreen:
				# Level 5/10/15...: an equipment slot unlocks. Shortcut (stated): the choice is emitted directly.
				for slot: EquipmentData.Slot in [EquipmentData.Slot.HELM, EquipmentData.Slot.WEAPON, EquipmentData.Slot.ARMOR, EquipmentData.Slot.BOOTS, EquipmentData.Slot.RELIC]:
					if not Session.profile.has_equipment_slot(slot):
						(inner as EquipmentSlotChoiceScreen).chosen.emit(slot)
						break
				await driver.seconds(0.8)
				return
			var next: Button = driver.find_button("Continue", child)
			if next != null:
				await driver.click(driver.center_of_control(next))
			await driver.seconds(0.6)
			return
	var slot_screen: Node = null
	for child: Node in rewards.find_children("*", "Control", true, false):
		if child is EquipmentSlotChoiceScreen:
			slot_screen = child
			break
	if slot_screen != null:
		# Level 5/10/15...: choose an equipment slot. Shortcut (stated): the choice is emitted directly (clicking the tiles is covered by
		# the earlier brief's e2e).
		for slot: EquipmentData.Slot in [EquipmentData.Slot.HELM, EquipmentData.Slot.WEAPON, EquipmentData.Slot.ARMOR, EquipmentData.Slot.BOOTS, EquipmentData.Slot.RELIC]:
			if not Session.profile.has_equipment_slot(slot):
				(slot_screen as EquipmentSlotChoiceScreen).chosen.emit(slot)
				break
		await driver.seconds(0.8)
		return
	var button: Button = driver.find_button("Skip card", rewards)
	if button == null:
		button = driver.find_button("Continue", rewards)
	if button != null:
		await driver.click(driver.center_of_control(button))
	else:
		await driver.tap_key(KEY_E)
		await driver.tap_key(KEY_SPACE)
	await driver.seconds(0.6)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 30.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _walk_to(scene: Node, target: Vector3, radius: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < 14.0:
		var offset: Vector3 = target - player.position
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
	if Vector2(player.position.x - target.x, player.position.z - target.z).length() >= radius:
		_note("walk fell back to a short teleport near %s" % str(target))
		player.position = target + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held.get(key, false)) != down:
		_held[key] = down
		await driver.key(key, down)


func _shot(name: String) -> void:
	_shots += 1
	await driver.frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, name]))
	print("%s: screenshot -> %s.png" % [TAG, name])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])
		push_error("%s: %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)


func _note(message: String) -> void:
	print("%s: note  %s" % [TAG, message])
