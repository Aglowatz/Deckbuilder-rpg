class_name EighthBriefFinalSmoke
extends Node
## FINAL (eighth brief): the Verdant Heap flow with human-style input, end to end: the Path of the Refusemancer in town ->
## the Verdant Heap, the minimap reveals as you explore and POIs appear (full map on M) -> pick up a Magic Bean and grow
## a VINE BRIDGE at its sprout mound, cross it, step off into the stream once (respawn, -1 zone life, logged) ->
## mount a giant goat, smash the junk dam and CHARGE a junk barricade -> plant a bean, grow a BEANSTALK, climb Rust Peak,
## solve the Seed Shrine, take a TRASH CHUTE down -> slow-enemy battle -> fast-enemy hit -> interactables (compost bin,
## shrine, crops) -> hub heal -> quiz -> the Sort It Out! minigame -> the Landfill Depths mini dungeon -> a hidden chest ->
## hand in Unblock the Stream and obtain the Compost Boots. At the end every zone's new equipment piece is obtained through
## its real quest turn-in (D.N.A., Gainlands, Endless Buffet). Screenshots to _screenshots/brief8/. Run windowed:
##   Godot --path . res://tools/eighth_brief_final_launcher.tscn
## (the D.N.A., Gainlands and Buffet regressions are run first by `tools/run_eighth_brief_final_smoke.sh`).
## Deliberate shortcuts (stated, like the earlier smokes): the Refusemancer gate flag is set directly (beating Thistlebark
## is covered by the corrupted-NPC smoke); long walks fall back to a short teleport when the crude no-pathfinding mover gets
## stuck behind a prop; the player is placed near an enemy so it notices them; the other zones' equipment quests are
## completed by setting their objective counters/flags and then really turning the quest in.
## Exit code 0 = every check passed; 1 = a check failed.

const STALL_LIMIT: float = 25.0
const SHOT_DIR: String = "res://_screenshots/brief8/"
const TAG: String = "eighth_brief_final_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.C)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)
	await _town_path(town)
	var zone: HeapScene = await _enter_the_heap(town)
	if zone == null:
		_finish(false, "never reached the Verdant Heap")
		return
	await _explore_and_reveal(zone)
	await _areas_tour(zone)
	await _accept_quests(zone)
	await _bean_and_bridge(zone)
	await _fall_in_the_stream(zone)
	await _ride_and_charge(zone)
	await _beanstalk_puzzle_and_chute(zone)
	zone = await _slow_enemy_battle(zone)
	await _fast_enemy_hit(zone)
	await _interactables(zone)
	await _hub_heal(zone)
	await _quiz(zone)
	await _sort_it_out(zone)
	await _hidden_chest(zone)
	zone = await _mini_dungeon(zone)
	await _hand_in_dam_quest(zone)
	await _final_state(zone)
	await _other_zones_equipment()
	_finish(_failures.is_empty(), "town -> Path of the Refusemancer -> Verdant Heap: minimap reveal + POIs -> bean -> vine bridge -> stream fall (-1 life) -> goat mount -> dam + barricade charge -> beanstalk -> Seed Shrine -> trash chute -> slow battle -> fast hit -> interactables -> hub heal -> quiz -> Sort It Out! -> chest -> Landfill Depths -> Compost Boots; all four zones' new equipment obtained (%d screenshots)" % _shots)


# ---- Steps ------------------------------------------------------------------------------


func _town_path(town: TownScene) -> void:
	_check(town.minimap != null and town.minimap.visible, "the town HUD has a minimap")
	Session.set_flag(CorruptedNpcs.unlock_flag(HeapZone.ID))
	var anchor: Vector3 = town.town.anchors["portal_refusemancer"] as Vector3
	await _walk_to(town, anchor, 1.6)
	await driver.frames(4)
	await _shot("h_01_town_path_of_the_refusemancer")
	var label: String = ""
	for spot: TownScene.Spot in town.spots:
		if spot.id == "portal_refusemancer":
			label = spot.title
	_check(label == "Path of the Refusemancer", "the town exit is called the Path of the Refusemancer (got '%s')" % label)


func _enter_the_heap(town: TownScene) -> HeapScene:
	await driver.tap_key(KEY_E)
	var zone: HeapScene = await _wait_for(HeapScene) as HeapScene
	_check(zone != null, "the Path of the Refusemancer leads into the Verdant Heap")
	if zone != null:
		await driver.seconds(1.2)
		_check(Session.zone_run != null and Session.zone_run.zone_id == HeapZone.ID, "a zone visit starts for the Verdant Heap")
		_check(Session.zone_run.life == Session.zone_run.max_life(), "entering starts at full zone life")
		await _shot("h_02_heap_arrival_hub")
	return zone


func _chest_clear(zone: HeapScene) -> void:
	for poi: MapPoi in zone._collect_pois():
		for id: Variant in zone.builder.chest_positions().keys():
			var chest: Vector3 = zone.builder.chest_positions()[id] as Vector3
			if Vector2(poi.pos.x - chest.x, poi.pos.z - chest.z).length() < 0.5:
				_fail("a POI (%s) sits on top of hidden chest %s" % [poi.label, str(id)])


func _explore_and_reveal(zone: HeapScene) -> void:
	var fog: FogOfWar = zone.minimap.fog
	var start_count: int = fog.revealed_count()
	var start_pois: int = MapView.visible_pois(zone._collect_pois(), fog).size()
	_check(start_count > 50, "the minimap starts with the hub area revealed (%d cells)" % start_count)
	_check(start_pois >= 2, "hub points of interest are already on the map (%d)" % start_pois)
	var quiz_spot: ZoneSpot = _spot(zone, "quiz")
	var quiz_known: bool = MapView.visible_pois(zone._collect_pois(), fog).any(func(poi: MapPoi) -> bool: return poi.kind == MapPoi.Kind.QUIZ)
	_check(not quiz_known, "the quiz master is NOT on the map before exploring")
	await _shot("h_03_minimap_start")
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	await _walk_to(zone, zone.builder.anchor("hub") + Vector3(-10.0, 0, 0.0), 2.0)
	await _walk_to(zone, quiz_spot.position, quiz_spot.radius)
	await driver.seconds(0.5)
	var later_count: int = fog.revealed_count()
	_check(later_count > start_count + 200, "walking around reveals more of the map (%d -> %d cells)" % [start_count, later_count])
	quiz_known = MapView.visible_pois(zone._collect_pois(), fog).any(func(poi: MapPoi) -> bool: return poi.kind == MapPoi.Kind.QUIZ)
	_check(quiz_known, "the quiz master appears on the map once its area is explored")
	var marker_found: bool = false
	for poi: MapPoi in MapView.visible_pois(zone._collect_pois(), fog):
		if poi.kind == MapPoi.Kind.QUEST_GIVER and poi.quest_marker:
			marker_found = true
	_check(marker_found, "a quest giver with an available quest shows the '!' marker")
	_chest_clear(zone)
	await _shot("h_04_minimap_after_exploring_quiz")
	await driver.tap_key(KEY_M)
	await driver.seconds(0.4)
	_check(zone._overlay is FullMapScreen, "M opens the full map in the Verdant Heap")
	await _shot("h_05_heap_full_map_with_legend")
	await driver.tap_key(KEY_M)
	await driver.seconds(0.3)
	_check(zone._overlay == null, "M closes the full map again")
	zone._invulnerable = 0.0


func _areas_tour(zone: HeapScene) -> void:
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	for place: String in ["marigold", "hob", "heal", "compost_bin", "shrine", "trough", "stable_1", "crop_2", "quiz", "minigame", "mound_a", "pickup_bean_1", "mound_west", "sorrel", "mound_east", "land_center", "stable_2", "barricade_dam", "barricade_gate", "mound_b", "mini_dungeon", "main_dungeon"]:
		zone.player.position = zone.builder.anchor(place) + Vector3(0, 0, 2.2)
		if not zone.builder.is_walkable(zone.player.position):
			zone.player.position = zone.builder.anchor(place) + Vector3(0, 0, 3.4)
		zone.player.position.y = zone.builder.height_at(zone.player.position)
		zone._camera.position = zone.player.position + zone.camera_offset
		await driver.seconds(0.8)
		await _shot("h_06_area_%s" % place)
	zone._invulnerable = 0.0
	zone.player.position = zone.builder.anchor("spawn")
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.frames(10)


func _accept_quests(zone: HeapScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	var spot: ZoneSpot = _spot(zone, "marigold")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("h_07_marigold_dialogue_and_quest")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.3)
	_check(Session.quest_log.is_active(HeapZone.QUEST_DAM), "Druid Marigold handed out Unblock the Stream")


func _pick(zone: HeapScene, pickup_id: String) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "pickup_" + pickup_id)
	await _walk_to(zone, spot.position, 1.0)
	await driver.frames(3)
	var before: int = HeapInteractables.stock(HeapZone.pickup_kind(pickup_id))
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(HeapInteractables.stock(HeapZone.pickup_kind(pickup_id)) == before + 1, "picked up %s" % str(HeapZone.PICKUPS[pickup_id]))


func _wait_not_busy(zone: HeapScene, limit: float) -> void:
	var waited: float = 0.0
	while (zone.player.airborne or zone._locked or zone._busy) and waited < limit:
		await driver.frames(3)
		waited += 3.0 / 60.0


func _bean_and_bridge(zone: HeapScene) -> void:
	await _pick(zone, "bean_1")
	await _shot("h_08_magic_bean_picked_up")
	var growth: HeapGrowth.Growth = HeapGrowth.find("bridge_west")
	var spot: ZoneSpot = _spot(zone, "grow_bridge_west")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	_check(zone.heap.is_in_hazard(Vector3(22.0, 0.0, HeapLayout.stream_z(22.0))), "the west span is just stream before it is grown")
	await _shot("h_09_sprout_mound_before_growing")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.8)
	await _shot("h_10_vine_bridge_growing")
	await _wait_not_busy(zone, 10.0)
	await driver.seconds(0.3)
	_check(HeapInteractables.is_grown(growth), "planting the bean grows the vine bridge for good")
	_check(HeapInteractables.stock("bean") == 0, "the bean was planted")
	_check(not zone.heap.is_in_hazard(Vector3(22.0, 0.0, HeapLayout.stream_z(22.0))), "the grown bridge holds in the middle of the stream")
	await _shot("h_11_vine_bridge_grown")
	# Walk across it with the keys.
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	var life_before: int = Session.zone_run.life
	await _walk_to(zone, Vector3(22.0, 0.0, HeapLayout.stream_z(22.0) + 4.6), 0.6)
	await _walk_to(zone, zone.builder.anchor("land_west"), 1.2)
	await driver.seconds(0.4)
	_check(zone.player.position.z < HeapLayout.stream_z(22.0) - HeapLayout.STREAM_HALF_WIDTH, "walked over the vine bridge to the north bank (z %.1f)" % zone.player.position.z)
	_check(Session.zone_run.life == life_before, "crossing a grown bridge costs nothing")
	await _shot("h_12_north_bank_after_the_bridge")


func _fall_in_the_stream(zone: HeapScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 0.0
	var zc: float = HeapLayout.stream_z(22.0)
	await _walk_to(zone, Vector3(22.0, 0.0, zc - 3.0), 0.6)
	await driver.seconds(0.4)
	var life_before: int = Session.zone_run.life
	var log_before: int = Session.zone_log.size()
	await _walk_to(zone, Vector3(22.0, 0.0, zc), 0.5)
	await driver.frames(3)
	await _hold(KEY_D, true)
	var waited: float = 0.0
	while not zone._falling and waited < 5.0:
		await driver.frames(2)
		waited += 2.0 / 60.0
	await _hold(KEY_D, false)
	_check(zone._falling, "stepping off the bridge into the stream starts a fall")
	await driver.seconds(0.35)
	await _shot("h_13_splash_into_the_stream")
	var guard: int = 0
	while (zone._falling or zone._locked) and guard < 300:
		guard += 1
		await driver.frames(3)
	await driver.seconds(0.5)
	_check(Session.zone_run.life == life_before - HeapZone.HAZARD_DAMAGE, "the dunk cost exactly 1 zone life (%d -> %d)" % [life_before, Session.zone_run.life])
	_check(zone.heap.layout.surface_at(zone.player.position.x, zone.player.position.z) == HeapLayout.Surface.GROUND, "...and you respawn on dry ground at the last safe spot")
	_check(Session.zone_log.size() == log_before + 1, "the dunk is logged (%s)" % Session.zone_log[Session.zone_log.size() - 1])
	await _shot("h_14_respawned_minus_one_life")
	zone._invulnerable = 600.0


func _ride_and_charge(zone: HeapScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	var spot: ZoneSpot = _spot(zone, "stable_2")
	await _walk_to(zone, zone.builder.anchor("land_west"), 1.5)
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await _shot("h_15_stable_goat")
	_check(not zone.is_riding(), "on foot before mounting")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(zone.is_riding(), "E at the stable mounts the giant goat")
	_check(zone.player.speed_multiplier > 1.4, "a mount is faster (x%.1f)" % zone.player.speed_multiplier)
	_check(zone.heap.mounted, "the world knows you are mounted (the scree opens up)")
	await _shot("h_16_riding_the_goat")
	await _clear_popups(zone)
	# On foot you cannot smash; mounted, charge the dam first (the Unblock the Stream objective).
	var dam: HeapGrowth.Barricade = HeapGrowth.find_barricade("dam")
	await _walk_to(zone, Vector3(40.0, 0.0, 36.6), 1.0)
	await _shot("h_17_charging_the_dam")
	await _hold(KEY_A, true)
	var waited: float = 0.0
	while not HeapInteractables.is_smashed(dam) and waited < 6.0:
		await driver.frames(2)
		waited += 2.0 / 60.0
	await _hold(KEY_A, false)
	_check(HeapInteractables.is_smashed(dam), "the mounted charge smashes the junk dam")
	await driver.seconds(0.3)
	await _shot("h_18_junk_dam_smashed")
	_check(Session.quest_log.objectives_met_count(QuestCatalog.find(HeapZone.QUEST_DAM), Session.unlock_state()) == 1, "Unblock the Stream's objective is done")
	# Now the barricade plugging the middle gap of the tyre wall.
	var gate: HeapGrowth.Barricade = HeapGrowth.find_barricade("gate")
	_check(not zone.builder.is_walkable(Vector3(50.0, 0.0, HeapLayout.WALL_Z)), "the barricade plugs the middle gap")
	await _walk_to(zone, Vector3(50.0, 0.0, 34.0), 0.8)
	await _shot("h_19_charging_the_barricade")
	await _hold(KEY_W, true)
	waited = 0.0
	while not HeapInteractables.is_smashed(gate) and waited < 6.0:
		await driver.frames(2)
		waited += 2.0 / 60.0
	await driver.seconds(0.5)
	await _hold(KEY_W, false)
	_check(HeapInteractables.is_smashed(gate), "charging the junk barricade smashes it")
	_check(zone.builder.is_walkable(Vector3(50.0, 0.0, HeapLayout.WALL_Z)), "the gap is open afterwards")
	await _shot("h_20_barricade_smashed")
	await _walk_to(zone, Vector3(50.0, 0.0, 26.0), 1.0)
	_check(zone.player.position.z < HeapLayout.WALL_Z - 1.0, "rode through the gap into the Landfill Rim (z %.1f)" % zone.player.position.z)
	# Dismount with Q on flat ground.
	await driver.tap_key(KEY_Q)
	await driver.seconds(0.4)
	_check(not zone.is_riding(), "Q dismounts")
	_check(is_equal_approx(zone.player.speed_multiplier, 1.0), "...and you are back to walking speed")
	await _shot("h_21_dismounted_in_the_landfill_rim")


func _beanstalk_puzzle_and_chute(zone: HeapScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	await _pick(zone, "bean_3")
	var growth: HeapGrowth.Growth = HeapGrowth.find("ladder_b")
	var spot: ZoneSpot = _spot(zone, "grow_ladder_b")
	await _walk_to(zone, Vector3(22.0, 0.0, 33.0), 1.5)
	await _walk_to(zone, zone.builder.anchor("land_west") + Vector3(0, 0, -8.0), 1.5)
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(1.0)
	await _shot("h_22_beanstalk_growing")
	await _wait_not_busy(zone, 10.0)
	_check(HeapInteractables.is_grown(growth), "planting the second bean grows the beanstalk")
	await _shot("h_23_beanstalk_grown")
	_check(zone.heap.layout.surface_at(zone.player.position.x, zone.player.position.z) != HeapLayout.Surface.PEAK, "on the ground before climbing")
	await driver.tap_key(KEY_E)
	await driver.seconds(1.4)
	await _shot("h_24_climbing_the_beanstalk")
	await _wait_not_busy(zone, 10.0)
	await driver.seconds(0.4)
	var peak: HeapLayout.Peak = zone.heap.layout.peak_at(zone.player.position.x, zone.player.position.z)
	_check(peak != null and peak.id == "rust", "the beanstalk carried you to the top of Rust Peak")
	_check(absf(zone.player.position.y - 7.0) < 0.6, "...at the summit's height (y %.1f)" % zone.player.position.y)
	await _shot("h_25_rust_peak_summit")
	# The Seed Shrine puzzle.
	var puzzle_spot: ZoneSpot = _spot(zone, "puzzle")
	await _walk_to(zone, puzzle_spot.position, puzzle_spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(zone._overlay is GrowthGridScreen, "the shrine opens the garden puzzle")
	if zone._overlay is GrowthGridScreen:
		var screen: GrowthGridScreen = zone._overlay as GrowthGridScreen
		await _shot("h_26_seed_shrine_start")
		await driver.click(driver.center_of_control(screen._buttons[0]))
		await driver.seconds(0.1)
		_check(not Session.flag(HeapZone.FLAG_PUZZLE_SOLVED), "one seed does not solve it")
		await _shot("h_27_seed_shrine_one_seed")
		await driver.click_button("Reset the garden")
		await driver.seconds(0.2)
		var satchel: EquipmentData = Session.content.equipment_piece("seed_satchel")
		_check(not Session.profile.owned_equipment.has(satchel), "the satchel is not owned before solving")
		for cell: int in GrowthGrid.shortest_solution():
			await driver.click(driver.center_of_control(screen._buttons[cell]))
			await driver.seconds(0.06)
		await driver.seconds(0.4)
		_check(Session.flag(HeapZone.FLAG_PUZZLE_SOLVED), "the right plantings bloom the whole garden")
		_check(Session.profile.owned_equipment.has(satchel), "solving rewards the Refusemancer Seed Satchel")
		await _shot("h_28_seed_shrine_solved")
		await driver.click_button("Leave")
		await driver.seconds(0.3)
	# The summit chest, then the trash chute down.
	var chest: Vector3 = zone.builder.chest_positions()["chest_peak_b"] as Vector3
	var gold_before: int = Session.gold
	await _walk_to(zone, chest, HeapScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.found_secret("heap_chest_peak_b"), "the summit chest was found")
	_check(Session.gold > gold_before, "the summit chest paid gold")
	await _clear_popups(zone)
	var chute: HeapLayout.Chute = zone.heap.layout.chutes[1]
	var slides_before: int = int(Session.counters.get(HeapZone.COUNTER_SLIDES, 0))
	await _walk_to(zone, Vector3(chute.pos.x - 3.0, 0.0, chute.pos.y), 0.8)
	await _shot("h_29_trash_chute_before")
	await _hold(KEY_D, true)
	var waited: float = 0.0
	while not zone.player.airborne and waited < 6.0:
		await driver.frames(2)
		waited += 2.0 / 60.0
	await _hold(KEY_D, false)
	_check(zone.player.airborne, "stepping onto the chute launches the slide")
	await driver.seconds(0.9)
	await _shot("h_30_sliding_down_the_junk_mountain")
	await _wait_not_busy(zone, 12.0)
	await driver.seconds(0.6)
	_check(zone.heap.layout.surface_at(zone.player.position.x, zone.player.position.z) == HeapLayout.Surface.GROUND, "the chute drops you on the ground")
	_check(int(Session.counters.get(HeapZone.COUNTER_SLIDES, 0)) == slides_before + 1, "the slide was counted")
	await _shot("h_31_chute_landing")


func _find_enemy(zone: HeapScene, type: String, north_only: bool = false) -> ZoneEnemy:
	for enemy: ZoneEnemy in zone.enemies:
		if enemy.info.id == type and (not north_only or enemy.home.z < 30.0):
			return enemy
	return null


func _spot_near(zone: HeapScene, center: Vector3) -> Vector3:
	for distance: float in [3.0, 3.5, 4.0, 2.5]:
		for angle: int in range(0, 360, 30):
			var candidate: Vector3 = center + Vector3(cos(deg_to_rad(float(angle))), 0.0, sin(deg_to_rad(float(angle)))) * distance
			if zone.builder.is_walkable(candidate) and zone.builder.has_line_of_sight(candidate, center) and _body_clear(zone, candidate, center):
				return candidate
	return center


func _body_clear(zone: HeapScene, a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(2, int(a.distance_to(b) / 0.4))
	for i: int in range(steps + 1):
		if not zone.builder.is_walkable(a.lerp(b, float(i) / float(steps)), 0.4):
			return false
	return true


func _slow_enemy_battle(zone: HeapScene) -> HeapScene:
	await _clear_popups(zone)
	var enemy: ZoneEnemy = _find_enemy(zone, HeapEnemies.GOLEM, true)
	_check(enemy != null, "a Mossy Trash Golem roams the Rust Peak yards")
	if enemy == null:
		return zone
	var life_before: int = Session.zone_run.life
	var enemies_before: int = int(Session.counters.get(HeapZone.COUNTER_ENEMIES, 0))
	zone.player.position = _spot_near(zone, enemy.position)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.frames(4)
	await _shot("h_32_trash_golem_approaching")
	zone._spawn_grace = 0.0
	zone._invulnerable = 5.0
	for other: ZoneEnemy in zone.enemies:
		other.cooldown = 0.0
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "touching a slow enemy starts a card battle")
	if battle == null:
		return zone
	_check(battle.context.zone_battle, "it is a zone battle")
	_check(battle.game.players[0].life == life_before, "the battle starts at the persisted zone life (%d)" % life_before)
	await _shot("h_33_heap_battle_refusemancer_deck")
	await _play_battle(battle)
	var life_end: int = battle.game.players[0].life
	var won: bool = battle.context.won
	await _shot("h_34_heap_battle_result")
	await driver.click_button("Continue")
	zone = await _wait_for(HeapScene) as HeapScene
	await driver.seconds(1.0)
	if zone != null:
		_check(Session.zone_run != null, "back in the Verdant Heap after the battle")
		_check(zone.heap.is_barricade_standing("gate") == false and zone.heap.is_barricade_standing("dam") == false, "smashed barricades stay smashed after the scene reloads")
		_check(zone.heap.bridge_progress.get("bridge_west", 0.0) == 1.0, "grown bridges stay grown after the scene reloads")
		if won:
			_check(Session.zone_run.life == life_end, "life after the battle is what was left, with no free heal (%d)" % life_end)
			_check(int(Session.counters.get(HeapZone.COUNTER_ENEMIES, 0)) == enemies_before + 1, "the zone's enemy counter went up")
		else:
			_check(Session.zone_run.life == Session.zone_run.max_life(), "a loss wakes you at the Compost Grange at full life")
			_check(Session.zone_log[Session.zone_log.size() - 1].begins_with("Mucking-out fee"), "the mucking-out fee was logged")
		await _clear_popups(zone)
		await _shot("h_35_back_in_the_heap_after_battle")
	_note("heap battle result this run: %s" % ("won" if won else "lost (woke at hub, fee paid)"))
	return zone


func _fast_enemy_hit(zone: HeapScene) -> void:
	await _clear_popups(zone)
	var gulls: ZoneEnemy = _find_enemy(zone, HeapEnemies.GULLS, true)
	if gulls == null:
		gulls = _find_enemy(zone, HeapEnemies.GULLS)
	_check(gulls != null, "a Junk Gull Flock roams the Verdant Heap")
	if gulls == null:
		return
	if Session.zone_run.life <= 3:
		Session.zone_run.fully_heal()
	var start_life: int = Session.zone_run.life
	gulls.cooldown = 0.0
	gulls.state = ZoneEnemy.State.PATROL
	var saved_ranges: Dictionary = {}
	for other: ZoneEnemy in zone.enemies:
		if other != gulls:
			other.cooldown = 600.0
			other.state = ZoneEnemy.State.PATROL
			saved_ranges[other] = other.info.aggro_range
			other.info.aggro_range = 0.0
	zone.player.position = _spot_near(zone, gulls.position)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	zone._spawn_grace = 0.0
	zone._invulnerable = 0.0
	await driver.frames(3)
	await _shot("h_36_gulls_approaching")
	var waited: float = 0.0
	while Session.zone_run.life >= start_life and waited < 12.0:
		await driver.frames(3)
		waited += 3.0 / 60.0
	_check(Session.zone_run.life == start_life - HeapEnemies.GULL_DAMAGE, "the gulls hit for exactly 2 (life %d -> %d)" % [start_life, Session.zone_run.life])
	_check(zone.life_bar._last_life == Session.zone_run.life, "the HUD life bar shows the new life")
	await driver.frames(4)
	await _shot("h_37_gulls_hit_flash_and_life")
	_check(zone._invulnerable > 0.0, "the hit grants a short invulnerability window")
	for other: ZoneEnemy in zone.enemies:
		if other != gulls:
			other.cooldown = 0.0
			other.info.aggro_range = float(saved_ranges.get(other, other.info.aggro_range))
	zone._invulnerable = 0.0
	zone.player.position = zone.builder.anchor("spawn")
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.5)


func _stand_at(zone: HeapScene, spot_id: String) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	var spot: ZoneSpot = _spot(zone, spot_id)
	zone.player.position = spot.position + Vector3(0, 0, spot.radius * 0.6)
	if not zone.builder.is_walkable(zone.player.position):
		zone.player.position = spot.position + Vector3(0, 0, spot.radius * 0.9)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.frames(6)


func _interactables(zone: HeapScene) -> void:
	await _clear_popups(zone)
	var run: ZoneRun = Session.zone_run
	run.life = 3
	EventBus.zone_life_changed.emit(run.life, run.max_life())
	# The compost bin needs two piles of junk.
	await _stand_at(zone, "compost_bin")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("h_38_compost_bin_needs_junk")
	await _dismiss_dialogue(zone.dialogue)
	_check(int(Session.counters.get(HeapZone.COUNTER_COMPOSTED, 0)) == 0, "no cocktail without junk")
	for id: String in ["junk_1", "junk_2"]:
		await _stand_at(zone, "pickup_" + id)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.3)
	await _stand_at(zone, "compost_bin")
	var max_before: int = run.max_life()
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(run.max_life() == max_before + 1, "the compost bin turned two piles of junk into +1 max life this visit")
	await _shot("h_39_compost_cocktail")
	# The druid shrine.
	await _stand_at(zone, "shrine")
	await _shot("h_40_druid_shrine")
	var life_before: int = run.life
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(run.life > life_before and run.max_life() == max_before + 2, "the shrine's blessing healed and raised max life")
	# Crop plots: plant with fertilizer, then it grows.
	await _stand_at(zone, "pickup_fert_1")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _stand_at(zone, "crop_1")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	var now: float = Time.get_unix_time_from_system()
	_check(HeapInteractables.crop_state(run, 1, now) == "growing", "planting a crop starts it growing")
	await driver.seconds(1.2)
	await _shot("h_41_crop_growing")
	# Fast-forward the crop (wall-clock) to prove the harvest: the plant time is moved back.
	run.visit_counts["crop_1"] = int(now) - int(HeapGrowth.CROP_SECONDS) - 2
	zone._refresh_crops()
	await driver.seconds(0.3)
	await _shot("h_42_crop_ripe")
	var gold: int = Session.gold
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(Session.gold == gold + HeapInteractables.HARVEST_GOLD, "harvesting a ripe crop pays gold")
	_check(int(Session.counters.get(HeapZone.COUNTER_HARVESTS, 0)) == 1, "the harvest was counted")
	# The trough pays for the last pile of junk.
	await _stand_at(zone, "pickup_junk_3")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _stand_at(zone, "trough")
	gold = Session.gold
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(Session.gold == gold + HeapInteractables.FEED_GOLD, "feeding the trough paid gold")
	await _shot("h_43_trough_fed")


func _hub_heal(zone: HeapScene) -> void:
	await _clear_popups(zone)
	var run: ZoneRun = Session.zone_run
	run.life = maxi(1, run.max_life() - 4)
	EventBus.zone_life_changed.emit(run.life, run.max_life())
	var hurt: int = run.life
	zone._spawn_grace = 600.0
	var spot: ZoneSpot = _spot(zone, "heal")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(hurt < run.max_life() and run.life == run.max_life(), "the Harvest Meal heals to full (%d -> %d)" % [hurt, run.life])
	await _shot("h_44_hub_heal_harvest_meal")
	await _clear_popups(zone)
	var hob: ZoneSpot = _spot(zone, "hob")
	await _walk_to(zone, hob.position, hob.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("h_45_farmer_hob_dialogue_and_quest_offer")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(Session.quest_log.is_active(HeapZone.QUEST_FERT), "Farmer Hob handed out Fertilizer Run")
	_check(zone._overlay is VendorScreen, "Hob opens the Refusemancer card vendor")
	if zone._overlay is VendorScreen:
		await driver.click_button("Got it")
		await _shot("h_46_refusemancer_vendor")
		var tile: Control = _find_meta_tile(zone._overlay, "card_id", "compost_golem")
		_check(tile != null, "a Compost Golem card is for sale")
		var owned: int = Session.owned_count("compost_golem")
		if tile != null:
			await driver.click(tile.get_global_rect().position + Vector2(60, 90))
			await driver.seconds(0.3)
			await driver.click_button("Buy")
			await driver.seconds(0.4)
		_check(Session.owned_count("compost_golem") == owned + 1, "buying adds the Refusemancer card")
		await driver.click_button("Leave")
		await driver.seconds(0.3)


func _quiz(zone: HeapScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "quiz")
	var gold_before: int = Session.gold
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("h_47_elder_fennel_dialogue")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(zone._overlay is QuizScreen, "the quiz master opens the quiz")
	if not (zone._overlay is QuizScreen):
		return
	var story: ZoneStoryText = ZoneStoryText.for_zone(HeapZone.ID)
	var shot_done: bool = false
	for _round: int in story.quiz_questions.size():
		var button: Button = null
		var correct_text: String = ""
		for question: Dictionary in story.quiz_questions:
			correct_text = str((question["a"] as Array)[int(question["correct"])])
			button = driver.find_button(correct_text, zone._overlay)
			if button != null:
				break
		_check(button != null, "a right answer is on screen (the quiz shuffles question order)")
		if not shot_done:
			shot_done = true
			await _shot("h_48_quiz_question")
		if button != null:
			await driver.click(driver.button_center(button))
			await driver.seconds(0.3)
	await _shot("h_49_quiz_result")
	_check(Session.flag(HeapZone.FLAG_QUIZ_DONE), "finishing the quiz sets the Heap's quiz flag")
	_check(Session.gold > gold_before, "a perfect score paid out (%d -> %d gold)" % [gold_before, Session.gold])
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _sort_it_out(zone: HeapScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "minigame")
	await _wait_not_busy(zone, 8.0)
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	zone.player.position = zone.builder.anchor("minigame") + Vector3(0, 0, 2.0)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.5)
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("h_50_blue_ribbon_bev_dialogue")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(zone._overlay is SortGameScreen, "Bev launches Sort It Out!")
	if not (zone._overlay is SortGameScreen):
		return
	var screen: SortGameScreen = zone._overlay as SortGameScreen
	var gold_before: int = Session.gold
	await _shot("h_51_sort_it_out_start")
	await driver.click_button("Start the run")
	await driver.seconds(0.5)
	await _shot("h_52_sort_it_out_countdown")
	var guard: int = 0
	var shot_taken: bool = false
	var wrong_done: bool = false
	while not screen.game.is_finished() and guard < 9000:
		guard += 1
		await driver.frames(1)
		if screen._state != "playing" or not screen.game.front_visible(screen._clock):
			continue
		var piece: int = screen.game.next_piece
		var wanted: int = SortGame.bin_of(piece)
		if not shot_taken and piece == 6:
			shot_taken = true
			await _shot("h_53_sort_it_out_belt")
		if SortGame.spawn_time(piece) + 0.35 > screen._clock:
			continue
		if piece == 2 and not wrong_done:
			wrong_done = true
			var wrong_bin: int = (wanted + 1) % SortGame.BIN_COUNT
			await driver.tap_key(KEY_1 + wrong_bin)
			await driver.frames(3)
			continue
		await driver.tap_key(KEY_1 + wanted)
	await driver.seconds(1.6)
	_check(screen.game.is_finished(), "the run finished")
	_check(screen.game.outcomes.has(0), "a wrong bin counted as a mistake")
	_check(screen.game.stars() >= 2, "sorting nearly everything right earned stars (%d sorted, %d stars)" % [screen.game.correct_count(), screen.game.stars()])
	_check(Session.gold > gold_before and Session.flag(HeapZone.FLAG_SORT_FIRST), "the run paid out with the one-time first-clear bonus")
	await _shot("h_54_sort_it_out_result")
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _hidden_chest(zone: HeapScene) -> void:
	await _clear_popups(zone)
	var id: String = "chest_log"
	var pos: Vector3 = zone.builder.chest_positions()[id] as Vector3
	var gold_before: int = Session.gold
	zone.player.position = _spot_near(zone, pos)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._spawn_grace = 20.0
	zone._invulnerable = 20.0
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.frames(4)
	await _walk_to(zone, pos, HeapScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	await _shot("h_55_log_chest_prompt_only_no_marker")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.found_secret("heap_%s" % id), "opening the stash marks its secret found")
	_check(Session.gold > gold_before, "the stash paid gold (%d -> %d)" % [gold_before, Session.gold])
	await _shot("h_56_log_chest_opened")


func _mini_dungeon(zone: HeapScene) -> HeapScene:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "mini_dungeon")
	Session.zone_run.fully_heal()
	zone._spawn_grace = 20.0
	zone._invulnerable = 20.0
	zone.player.position = spot.position + Vector3(0, 0, 3.0)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.6)
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await _shot("h_57_landfill_depths_entrance")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _shot("h_58_landfill_depths_prompt")
	var life_at_entry: int = Session.zone_run.life
	await driver.click_button("Climb in")
	var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	_check(map_screen != null, "the mini dungeon opens the node map")
	if map_screen == null:
		return zone
	_check(Session.mini_active and Session.run.life == life_at_entry, "the run starts at the zone's current life (%d)" % life_at_entry)
	await driver.seconds(1.2)
	await _shot("h_59_landfill_depths_map")
	var battles: int = 0
	while battles < MiniDungeon.BATTLE_COUNT:
		map_screen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
		if map_screen == null:
			_note("exit: no node map, scene=%s" % get_tree().current_scene); break
		await driver.seconds(0.6)
		var available: Array[DungeonMap.MapNode] = Session.dungeon_map.available()
		if available.is_empty():
			_note("exit: no available node"); break
		var button: MapNodeButton = map_screen._buttons[available[0].id] as MapNodeButton
		var life_before: int = Session.run.life
		await driver.click(driver.center_of_control(button))
		var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
		if battle == null:
			_note("exit: no battle screen, scene=%s" % get_tree().current_scene); break
		battles += 1
		_check(battle.game.players[0].life == life_before, "landfill battle %d starts at the carried life (%d)" % [battles, life_before])
		if battles == 1:
			await _shot("h_60_landfill_battle_1")
		await _play_battle(battle)
		var won: bool = battle.context.won
		await driver.click_button("Continue")
		if not won:
			_note("exit: lost"); break
		var next: Node = await _wait_scene_either()
		if next is RewardsScreen:
			await driver.seconds(1.2)
			if battles == MiniDungeon.BATTLE_COUNT:
				await _shot("h_61_landfill_final_reward")
			await driver.click_button("Continue")
			await driver.seconds(0.6)
			if get_tree().current_scene is HeapScene:
				_note("exit: heap scene"); break
	var settle: int = 0
	while Session.mini_active and settle < 200:
		settle += 1
		await driver.frames(5)
		if get_tree().current_scene is BattleScreen:
			await _play_battle(get_tree().current_scene as BattleScreen)
			await driver.click_button("Continue")
		elif driver.find_button("Continue", get_tree().current_scene) != null:
			await driver.click_button("Continue")
			await driver.seconds(0.4)
	zone = await _wait_for(HeapScene) as HeapScene
	await driver.seconds(1.0)
	if zone != null:
		await _shot("h_62_back_from_the_landfill")
	_check(not Session.mini_active, "the mini dungeon run ended and returned to the zone")
	if Session.flag(HeapZone.FLAG_MINI_CLEARED):
		_check(Session.owned_count("heap_mother") == 1, "clearing it granted the unique Mother of the Heap")
	_note("mini dungeon: %d battle(s) fought, cleared=%s (a loss wakes you at the hub; the clear path is unit-tested)" % [battles, str(Session.flag(HeapZone.FLAG_MINI_CLEARED))])
	return zone


func _hand_in_dam_quest(zone: HeapScene) -> void:
	if zone == null:
		return
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	var boots: EquipmentData = Session.content.equipment_piece("compost_boots")
	_check(not Session.profile.owned_equipment.has(boots), "the Compost Boots are not owned before the hand-in")
	var spot: ZoneSpot = _spot(zone, "marigold")
	zone.player.position = spot.position + Vector3(0, 0, 0.8)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.6)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("h_63_marigold_thanks_for_the_dam")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	await _clear_popups(zone)
	_check(Session.quest_log.is_completed(HeapZone.QUEST_DAM), "handing in Unblock the Stream completes it")
	_check(Session.profile.owned_equipment.has(boots), "the quest rewarded the Compost Boots")
	_check(boots.tooltip_text().contains(boots.flavor_text) and boots.slot == EquipmentData.Slot.BOOTS, "the boots have a description, flavor text and the Boots slot")
	await _shot("h_64_compost_boots_obtained")
	await driver.tap_key(KEY_C)
	await driver.seconds(0.6)
	await _shot("h_65_character_screen_with_the_new_gear")
	await driver.tap_key(KEY_C)
	await driver.seconds(0.3)


func _final_state(zone: HeapScene) -> void:
	if zone == null:
		return
	await driver.tap_key(KEY_J)
	await driver.seconds(0.4)
	await _shot("h_66_quest_log_in_the_heap")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.3)
	var fog: FogOfWar = Session.fog_for(HeapZone.ID, zone.builder.map_bounds())
	_check(fog.revealed_count() > 1200, "the Verdant Heap fog of war ended up well explored (%d cells)" % fog.revealed_count())
	var saved: Dictionary = Session.to_dict()
	_check((saved.get("map_fog", {}) as Dictionary).has(HeapZone.ID), "the reveal is in the save, per zone")
	_check(not Session.zone_log.is_empty(), "the zone log has entries (stream falls / fees)")
	_chest_clear(zone)
	await _shot("h_67_final_minimap")


## Every other zone's new equipment piece, obtained through its real quest turn-in: the objectives are satisfied by
## setting their counters/flags (the zones' own e2e flows already play those actions), then the quest is accepted and
## turned in through `Session`, which grants the reward.
func _other_zones_equipment() -> void:
	var cases: Array[Dictionary] = [
		{"quest": "dna_audit", "piece": "compliance_clipboard", "zone": DnaZone.ID},
		{"quest": "gain_lanes", "piece": "spotters_barbell", "zone": GainlandsZone.ID},
		{"quest": "buf_pie", "piece": "head_chef_toque", "zone": BuffetZone.ID},
	]
	for case: Dictionary in cases:
		var quest: QuestData = QuestCatalog.find(str(case["quest"]))
		var piece: EquipmentData = Session.content.equipment_piece(str(case["piece"]))
		_check(quest != null and piece != null, "%s and %s exist" % [str(case["quest"]), str(case["piece"])])
		if quest == null or piece == null:
			continue
		_check(not Session.profile.owned_equipment.has(piece), "%s is not owned yet" % piece.source_name)
		_check(Session.start_quest(quest.id), "%s can be accepted" % quest.title)
		for objective: QuestObjective in quest.objectives:
			var condition: Condition = objective.condition
			if condition.kind == Condition.Kind.COUNTER:
				Session.counters[condition.key] = int(Session.counters.get(condition.key, 0)) + condition.amount
			elif condition.kind == Condition.Kind.FLAG_SET:
				Session.set_flag(StringName(condition.key))
		Session.refresh_quests()
		_check(Session.turn_in_quest(quest.id), "%s can be handed in" % quest.title)
		_check(Session.profile.owned_equipment.has(piece), "%s (%s) was obtained from %s" % [piece.source_name, EquipmentData.slot_name(piece.slot), quest.title])
		_check(not piece.flavor_text.is_empty() and not piece.description.is_empty() and CardIcons.BY_EQUIPMENT_ID.has(piece.id), "%s has a description, flavor text and an icon" % piece.source_name)
	var slots: Dictionary = {}
	for id: String in ["compliance_clipboard", "spotters_barbell", "head_chef_toque", "compost_boots"]:
		slots[Session.content.equipment_piece(id).slot] = true
	_check(slots.size() == 4, "the four zone pieces use four different slots")


# ---- Helpers ------------------------------------------------------------------------------


func _play_battle(battle: BattleScreen) -> void:
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	battle.board.speed = 10.0
	var steps: int = 0
	var last_progress: int = 0
	while steps < 6000:
		steps += 1
		if battle.mode == BattleScreen.Mode.OVER and battle._result_panel != null:
			break
		if battle.busy or battle.mode == BattleScreen.Mode.WAITING:
			await driver.frames(4)
			continue
		var before: int = battle.game.events.size()
		await pilot.act()
		await driver.frames(3)
		if battle.game.events.size() != before:
			last_progress = steps
		if steps - last_progress > 60:
			break
	_check(battle.mode == BattleScreen.Mode.OVER, "the duel actually finishes (%d steps)" % steps)


func _wait_scene_either() -> Node:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene != null and not SceneManager.busy and (scene is RewardsScreen or scene is HeapScene):
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _spot(zone: HeapScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	_fail("no such spot: %s" % id)
	return zone.spots[0]


func _find_meta_tile(root: Node, meta: String, value: String) -> Control:
	for node: Node in root.find_children("*", "Control", true, false):
		if node.has_meta(meta) and str(node.get_meta(meta)) == value:
			return node as Control
	return null


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _dismiss_dialogue(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 30:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


func _clear_popups(zone: HeapScene) -> void:
	zone._spawn_grace = maxf(zone._spawn_grace, 600.0)
	var guard: int = 0
	while guard < 20 and (zone.dialogue.active or zone._overlay is LevelUpScreen):
		guard += 1
		if zone.dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.15)
		else:
			await driver.click_button("Continue")
			await driver.seconds(0.4)


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
		player.position = target + Vector3(0.0, 0.0, 0.4)
		player.position.y = (scene.builder as WalkableArea).height_at(player.position) if "builder" in scene else player.position.y
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
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
		_fail(message)


func _note(message: String) -> void:
	print("%s: note  %s" % [TAG, message])


func _fail(message: String) -> void:
	_failures.append(message)
	print("%s: FAIL  %s" % [TAG, message])
	push_error("%s: %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
