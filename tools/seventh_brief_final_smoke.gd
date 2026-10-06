class_name SeventhBriefFinalSmoke
extends Node
## FINAL (seventh brief): the Endless Buffet flow with human-style input, end to end: the Path of the Gourmand in
## town -> the Endless Buffet, the minimap reveals as you explore and POIs appear (full map on M) -> a JELLY
## BOUNCE PAD up to Butter Butte (and its chest) -> the rotating LAZY SUSAN carries you -> a CROUTON RAFT: step off
## into the soup once (respawn, -1 zone HP, logged), then ride it properly across -> a GOLEM GATE opens for an
## ingredient -> slow-enemy battle -> fast-enemy hit -> interactables (fountain, oven, taste test, fortune cookie)
## -> hub heal -> quiz -> the Order Up! minigame -> the Mystery Stew puzzle -> the Walk-In Freezer mini dungeon ->
## a hidden chest. Screenshots every new area and screen to _screenshots/brief7/. Run windowed:
##   Godot --path . res://tools/seventh_brief_final_launcher.tscn
## (the D.N.A. and Gainlands regressions are `tools/run_sixth_brief_final_smoke.sh`, run first by the runner script).
## Deliberate shortcuts (stated, like the earlier smokes): the Gourmand gate flag is set directly (beating Maris
## is covered by the corrupted-NPC smoke); the quest and battle gates and the far districts are opened with flags
## and the player is placed at the foot of a pad / near an enemy (the real conditions are unit-tested and the
## ingredient gate is passed for real); long walks fall back to a short teleport when the crude no-pathfinding
## mover gets stuck behind a prop; the player is placed near an enemy so it notices them quickly.
## Exit code 0 = every check passed; 1 = a check failed.

const STALL_LIMIT: float = 25.0
const SHOT_DIR: String = "res://_screenshots/brief7/"
const TAG: String = "seventh_brief_final_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)
	await _town_path(town)
	var zone: BuffetScene = await _enter_the_buffet(town)
	if zone == null:
		_finish(false, "never reached the Endless Buffet")
		return
	await _explore_and_reveal(zone)
	await _areas_tour(zone)
	await _pick_saffron(zone)
	await _jelly_pad(zone)
	await _lazy_susan(zone)
	await _raft_and_soup(zone)
	await _golem_gate(zone)
	zone = await _slow_enemy_battle(zone)
	await _fast_enemy_hit(zone)
	await _interactables(zone)
	await _hub_heal(zone)
	await _quiz(zone)
	await _order_up(zone)
	await _stew_puzzle(zone)
	await _hidden_chest(zone)
	zone = await _mini_dungeon(zone)
	await _final_state(zone)
	_finish(_failures.is_empty(), "town -> Path of the Gourmand -> Endless Buffet: minimap reveal + POIs -> jelly pad -> lazy susan -> raft (fall in once: -1 HP) -> golem gate -> slow battle -> fast hit -> interactables -> hub heal -> quiz -> Order Up! -> stew puzzle -> chest -> Walk-In Freezer (%d screenshots)" % _shots)


# ---- Steps ------------------------------------------------------------------------------


func _town_path(town: TownScene) -> void:
	_check(town.minimap != null and town.minimap.visible, "the town HUD has a minimap")
	Session.set_flag(CorruptedNpcs.unlock_flag(BuffetZone.ID))
	var anchor: Vector3 = town.town.anchors["portal_gourmand"] as Vector3
	await _walk_to(town, anchor, 1.6)
	await driver.frames(4)
	await _shot("g_01_town_path_of_the_gourmand")
	var label: String = ""
	for spot: TownScene.Spot in town.spots:
		if spot.id == "portal_gourmand":
			label = spot.title
	_check(label == "Path of the Gourmand", "the town exit is called the Path of the Gourmand (got '%s')" % label)


func _enter_the_buffet(town: TownScene) -> BuffetScene:
	await driver.tap_key(KEY_E)
	var zone: BuffetScene = await _wait_for(BuffetScene) as BuffetScene
	_check(zone != null, "the Path of the Gourmand leads into the Endless Buffet")
	if zone != null:
		await driver.seconds(1.2)
		_check(Session.zone_run != null and Session.zone_run.zone_id == BuffetZone.ID, "a zone visit starts for the Endless Buffet")
		_check(Session.zone_run.hp == Session.zone_run.max_hp(), "entering starts at full zone HP")
		await _shot("g_02_buffet_arrival_hub")
	return zone


func _chest_clear(zone: BuffetScene) -> void:
	for poi: MapPoi in zone._collect_pois():
		for id: Variant in zone.builder.chest_positions().keys():
			var chest: Vector3 = zone.builder.chest_positions()[id] as Vector3
			if Vector2(poi.pos.x - chest.x, poi.pos.z - chest.z).length() < 0.5:
				_fail("a POI (%s) sits on top of hidden chest %s" % [poi.label, str(id)])


func _explore_and_reveal(zone: BuffetScene) -> void:
	var fog: FogOfWar = zone.minimap.fog
	var start_count: int = fog.revealed_count()
	var start_pois: int = MapView.visible_pois(zone._collect_pois(), fog).size()
	_check(start_count > 50, "the minimap starts with the hub area revealed (%d cells)" % start_count)
	_check(start_pois >= 2, "hub points of interest are already on the map (%d)" % start_pois)
	var quiz_spot: ZoneSpot = _spot(zone, "quiz")
	var quiz_known: bool = MapView.visible_pois(zone._collect_pois(), fog).any(func(poi: MapPoi) -> bool: return poi.kind == MapPoi.Kind.QUIZ)
	_check(not quiz_known, "the quiz master is NOT on the map before exploring")
	await _shot("g_03_minimap_start")
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
	await _shot("g_04_minimap_after_exploring_quiz")
	await driver.tap_key(KEY_M)
	await driver.seconds(0.4)
	_check(zone._overlay is FullMapScreen, "M opens the full map in the Endless Buffet")
	await _shot("g_05_buffet_full_map_with_legend")
	await driver.tap_key(KEY_M)
	await driver.seconds(0.3)
	_check(zone._overlay == null, "M closes the full map again")
	zone._invulnerable = 0.0


func _areas_tour(zone: BuffetScene) -> void:
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	for place: String in ["odalys", "dolcetta", "heal", "oven", "soup_fountain", "fortune_cookie", "old_meatloaf", "quiz", "pickup_truffle", "minigame", "taste_test", "pickup_saffron", "pickup_sea_salt", "land_butte_down", "bank_west", "bank_center", "bank_east", "land_center", "gate_ingredient", "gate_quest", "gate_battle"]:
		zone.player.position = zone.builder.anchor(place) + Vector3(0, 0, 1.4)
		if not zone.builder.is_walkable(zone.player.position):
			zone.player.position = zone.builder.anchor(place) + Vector3(0, 0, 3.0)
		zone.player.position.y = zone.builder.height_at(zone.player.position)
		zone._camera.position = zone.player.position + zone.camera_offset
		await driver.seconds(0.8)
		await _shot("g_06_area_%s" % place)
	zone._invulnerable = 0.0
	zone.player.position = zone.builder.anchor("spawn")
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.frames(10)


func _pick_saffron(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "pickup_saffron")
	var gathered_before: int = int(Session.counters.get(BuffetZone.COUNTER_GATHERED, 0))
	await _walk_to(zone, spot.position, 1.0)
	await driver.frames(3)
	await _shot("g_07_saffron_prompt")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(BuffetInteractables.stock("saffron") == 1, "picking up the saffron puts it in the stock")
	_check(int(Session.counters.get(BuffetZone.COUNTER_GATHERED, 0)) == gathered_before + 1, "the pickup counts toward Pantry Run")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	_check(BuffetInteractables.stock("saffron") == 1, "a second E does not pick up another one this visit")
	await _shot("g_08_saffron_picked_up")


func _wait_not_airborne(zone: BuffetScene, limit: float) -> void:
	var waited: float = 0.0
	while (zone.player.airborne or zone._locked) and waited < limit:
		await driver.frames(3)
		waited += 3.0 / 60.0


func _jelly_pad(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	var pad: BuffetLayout.Pad = zone.buf.layout.pads[0]
	var butte: BuffetLayout.Mesa = zone.buf.layout.mesas[0]
	var bounces_before: int = int(Session.counters.get(BuffetZone.COUNTER_BOUNCES, 0))
	await _walk_to(zone, Vector3(pad.pos.x - 3.5, 0.0, pad.pos.y + 1.0), 1.0)
	await driver.frames(3)
	await _shot("g_09_jelly_pad_before_the_bounce")
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	# Walk onto the pad with the keys: east.
	await _hold(KEY_D, true)
	await _hold(KEY_W, true)
	var waited: float = 0.0
	while not zone.player.airborne and waited < 6.0:
		await driver.frames(2)
		waited += 2.0 / 60.0
	await _hold(KEY_D, false)
	await _hold(KEY_W, false)
	_check(zone.player.airborne, "stepping on the jelly pad launches you")
	await driver.seconds(0.55)
	await _shot("g_10_mid_air_bounce_camera_follows")
	await _wait_not_airborne(zone, 8.0)
	await driver.seconds(0.15)
	await _shot("g_11_bounce_landing_crumbs")
	_check(zone.buf.layout.surface_at(zone.player.position.x, zone.player.position.z) == BuffetLayout.Surface.MESA, "you landed on Butter Butte's top")
	_check(absf(zone.player.position.y - butte.height) < 0.8, "...at the mesa's height (y %.1f)" % zone.player.position.y)
	await driver.seconds(1.0)
	_check(int(Session.counters.get(BuffetZone.COUNTER_BOUNCES, 0)) == bounces_before + 1, "the bounce was counted")
	await _shot("g_12_butter_butte_top")
	# The chest and the honey up there.
	var chest: Vector3 = zone.builder.chest_positions()["chest_butte"] as Vector3
	var gold_before: int = Session.gold
	await _walk_to(zone, chest, BuffetScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	await _shot("g_13_mesa_chest_prompt_only")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.found_secret("buf_chest_butte"), "the mesa chest was found")
	_check(Session.gold > gold_before, "the mesa chest paid gold (%d -> %d)" % [gold_before, Session.gold])
	await _clear_popups(zone)
	var honey: ZoneSpot = _spot(zone, "pickup_honey")
	await _walk_to(zone, honey.position, 1.0)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	_check(BuffetInteractables.stock("honey") == 1, "the honey is up on the Butte")
	# And back down by the pad on top.
	var back: BuffetLayout.Pad = zone.buf.layout.pads[1]
	await _walk_to(zone, Vector3(back.pos.x, 0.0, back.pos.y), 0.5)
	await _wait_not_airborne(zone, 8.0)
	await driver.seconds(1.2)
	_check(zone.buf.layout.surface_at(zone.player.position.x, zone.player.position.z) == BuffetLayout.Surface.GROUND, "the pad on top bounces you back down to the ground")
	await _shot("g_14_back_down_from_the_butte")
	zone._invulnerable = 0.0


func _lazy_susan(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	var susan: BuffetLayout.Susan = zone.buf.layout.susans[0]
	var south: Vector3 = Vector3(susan.center.x, 0.0, susan.center.y + 2.9)
	var rides_before: int = int(Session.counters.get(BuffetZone.COUNTER_RIDES, 0))
	await _walk_to(zone, zone.builder.anchor("bank_center"), 1.5)
	await _shot("g_15_lazy_susan_from_the_bank")
	await _walk_to(zone, south, 0.5)
	await driver.frames(4)
	var start: Vector2 = Vector2(zone.player.position.x - susan.center.x, zone.player.position.z - susan.center.y)
	_check(not zone.buf.platform_under(zone.player.position, 0.0).is_empty(), "you are standing on the lazy susan")
	await driver.seconds(1.5)
	await _shot("g_16_riding_the_lazy_susan")
	await driver.seconds(1.5)
	var now: Vector2 = Vector2(zone.player.position.x - susan.center.x, zone.player.position.z - susan.center.y)
	_check(absf(start.angle_to(now)) > 0.8, "the turning platter carried you round (%.2f rad)" % absf(start.angle_to(now)))
	_check(absf(start.length() - now.length()) < 0.8, "...around its pillar, not off it (radius %.1f -> %.1f)" % [start.length(), now.length()])
	_check(int(Session.counters.get(BuffetZone.COUNTER_RIDES, 0)) == rides_before + 1, "the ride was counted")
	_check(Session.zone_run.hp == Session.zone_run.max_hp(), "riding costs nothing")
	# Wait until we are carried to the north rim, then step off onto the north bank.
	var guard: int = 0
	while zone.player.position.z > susan.center.y - 2.4 and guard < 900:
		guard += 1
		await driver.frames(3)
	await _hold(KEY_W, true)
	guard = 0
	while zone.buf.layout.surface_at(zone.player.position.x, zone.player.position.z) == BuffetLayout.Surface.SOUP or not zone.buf.platform_under(zone.player.position, 0.0).is_empty():
		guard += 1
		if guard > 200:
			break
		await driver.frames(2)
	await driver.seconds(0.4)
	await _hold(KEY_W, false)
	_check(zone.player.position.z < susan.center.y - BuffetLayout.RIVER_HALF_WIDTH, "stepped off the other side onto the north bank (z %.1f)" % zone.player.position.z)
	_check(Session.zone_run.hp == Session.zone_run.max_hp(), "no fall on the way off")
	await _shot("g_17_north_bank_after_the_susan")


func _wait_raft_docked(zone: BuffetScene, raft: BuffetLayout.Raft, at_south: bool, limit: float) -> bool:
	var target: Vector2 = raft.a if at_south else raft.b
	var waited: float = 0.0
	while waited < limit:
		if zone.buf.layout.raft_position(raft, zone.buf.time).distance_to(target) < 0.05:
			return true
		await driver.frames(3)
		waited += 3.0 / 60.0
	return false


func _raft_and_soup(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 0.0
	var raft: BuffetLayout.Raft = zone.buf.layout.rafts[0]
	# Back to the south bank of the west crossing (the susan put us on the north bank).
	zone.player.position = zone.builder.anchor("bank_west")
	zone._camera.position = zone.player.position + zone.camera_offset
	zone.last_safe = zone.player.position
	await driver.seconds(0.6)
	var docked: bool = await _wait_raft_docked(zone, raft, true, 30.0)
	_check(docked, "the crouton raft docks at the south bank")
	await _shot("g_18_raft_docked_at_the_bank")
	await _walk_to(zone, Vector3(raft.a.x, 0.0, raft.a.y), 0.7)
	await driver.frames(3)
	_check(not zone.buf.platform_under(zone.player.position, 0.0).is_empty(), "you are standing on the raft")
	var rides_before: int = int(Session.counters.get(BuffetZone.COUNTER_RIDES, 0))
	await driver.seconds(3.2)
	await _shot("g_19_riding_the_crouton_raft")
	# Mid-river: deliberately step off into the soup, once.
	var hp_before: int = Session.zone_run.hp
	var log_before: int = Session.zone_log.size()
	var safe: Vector3 = zone.last_safe
	await _hold(KEY_A, true)
	var waited: float = 0.0
	while not zone._falling and waited < 5.0:
		await driver.frames(2)
		waited += 2.0 / 60.0
	await _hold(KEY_A, false)
	_check(zone._falling, "stepping off the raft into the soup starts a fall")
	await driver.seconds(0.35)
	await _shot("g_20_splash_into_the_gravy")
	var guard: int = 0
	while (zone._falling or zone._locked) and guard < 300:
		guard += 1
		await driver.frames(3)
	await driver.seconds(0.5)
	_check(Session.zone_run.hp == hp_before - BuffetZone.SOUP_DAMAGE, "the soup dunk cost exactly 1 zone HP (%d -> %d)" % [hp_before, Session.zone_run.hp])
	_check(zone.player.position.distance_to(safe) < 1.5 and zone.buf.layout.surface_at(zone.player.position.x, zone.player.position.z) == BuffetLayout.Surface.GROUND, "...and you respawn on dry ground at the last safe spot")
	_check(Session.zone_log.size() == log_before + 1, "the dunk is logged (%s)" % Session.zone_log[Session.zone_log.size() - 1])
	await _shot("g_21_respawned_minus_one_HP")
	# Now do it properly: board again and ride all the way over.
	zone._invulnerable = 600.0
	await _clear_popups(zone)
	docked = await _wait_raft_docked(zone, raft, true, 30.0)
	await _walk_to(zone, Vector3(raft.a.x, 0.0, raft.a.y), 0.7)
	await driver.frames(3)
	_check(not zone.buf.platform_under(zone.player.position, 0.0).is_empty(), "boarded the raft again")
	docked = await _wait_raft_docked(zone, raft, false, 30.0)
	_check(docked, "the raft carried you to the north bank")
	await _shot("g_22_raft_docked_on_the_far_side")
	var north: Vector3 = zone.builder.anchor("land_west")
	await _walk_to(zone, north, 1.2)
	await driver.seconds(0.4)
	_check(zone.player.position.z < raft.b.y and zone.buf.layout.surface_at(zone.player.position.x, zone.player.position.z) == BuffetLayout.Surface.GROUND, "you stepped off onto the north bank (z %.1f)" % zone.player.position.z)
	_check(Session.zone_run.hp == hp_before - BuffetZone.SOUP_DAMAGE, "the second crossing cost nothing")
	_check(int(Session.counters.get(BuffetZone.COUNTER_RIDES, 0)) >= rides_before + 1, "the rides were counted")
	await _shot("g_23_gravy_bank_west")


func _golem_gate(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	var gate: BuffetGates.Gate = BuffetGates.find("ingredient")
	var spot: ZoneSpot = _spot(zone, "gate_ingredient")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	_check(not BuffetInteractables.gate_is_open(gate), "Brisket's gate starts closed")
	_check(not zone.builder.is_walkable(zone.builder.anchor("gate_ingredient")), "...and the golem blocks the gap")
	await _shot("g_24_brisket_blocks_the_gate")
	# Without the ingredient he refuses (take the saffron out of the bag for a moment).
	var stock: int = BuffetInteractables.stock("saffron")
	Session.counters[BuffetZone.stock_key("saffron")] = 0
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("g_25_brisket_wants_saffron")
	await _dismiss_dialogue(zone.dialogue)
	_check(not BuffetInteractables.gate_is_open(gate), "no saffron, no entry")
	Session.counters[BuffetZone.stock_key("saffron")] = stock
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("g_26_brisket_takes_the_saffron")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(1.8)
	_check(BuffetInteractables.gate_is_open(gate), "handing over the saffron opens the gate for good")
	_check(BuffetInteractables.stock("saffron") == 0, "the saffron was used up")
	await _shot("g_27_gate_open_golem_steps_aside")
	await _walk_to(zone, Vector3(22.0, 0.0, 26.0), 1.0)
	await driver.seconds(0.4)
	_check(zone.player.position.z < BuffetLayout.FENCE_Z - 1.0, "you walked through the gap into the Cheddar Cliffs (z %.1f)" % zone.player.position.z)
	await _shot("g_28_cheddar_cliffs_beyond_the_gate")


func _find_enemy(zone: BuffetScene, type: String, north_only: bool = false) -> ZoneEnemy:
	for enemy: ZoneEnemy in zone.enemies:
		if enemy.info.id == type and (not north_only or enemy.home.z < 30.0):
			return enemy
	return null


func _spot_near(zone: BuffetScene, center: Vector3) -> Vector3:
	for distance: float in [3.0, 3.5, 4.0, 2.5]:
		for angle: int in range(0, 360, 30):
			var candidate: Vector3 = center + Vector3(cos(deg_to_rad(float(angle))), 0.0, sin(deg_to_rad(float(angle)))) * distance
			if zone.builder.is_walkable(candidate) and zone.builder.has_line_of_sight(candidate, center) and _body_clear(zone, candidate, center):
				return candidate
	return center


func _body_clear(zone: BuffetScene, a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(2, int(a.distance_to(b) / 0.4))
	for i: int in range(steps + 1):
		if not zone.builder.is_walkable(a.lerp(b, float(i) / float(steps)), 0.4):
			return false
	return true


func _slow_enemy_battle(zone: BuffetScene) -> BuffetScene:
	await _clear_popups(zone)
	var enemy: ZoneEnemy = _find_enemy(zone, BuffetEnemies.LOAF, true)
	_check(enemy != null, "a Meatloaf Golem roams the Cheddar Cliffs")
	if enemy == null:
		return zone
	var hp_before: int = Session.zone_run.hp
	var enemies_before: int = int(Session.counters.get(BuffetZone.COUNTER_ENEMIES, 0))
	zone.player.position = _spot_near(zone, enemy.position)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.frames(4)
	await _shot("g_29_meatloaf_golem_approaching")
	zone._spawn_grace = 0.0
	zone._invulnerable = 5.0
	for other: ZoneEnemy in zone.enemies:
		other.cooldown = 0.0
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "touching a slow enemy starts a card battle")
	if battle == null:
		return zone
	_check(battle.context.zone_battle, "it is a zone battle")
	_check(battle.game.players[0].hp == hp_before, "the battle starts at the persisted zone HP (%d)" % hp_before)
	await _shot("g_30_buffet_battle_gourmand_deck")
	await _play_battle(battle)
	var hp_end: int = battle.game.players[0].hp
	var won: bool = battle.context.won
	await _shot("g_31_buffet_battle_result")
	await driver.click_button("Continue")
	zone = await _wait_for(BuffetScene) as BuffetScene
	await driver.seconds(1.0)
	if zone != null:
		_check(Session.zone_run != null, "back in the Endless Buffet after the battle")
		_check(Session.flag(BuffetZone.FLAG_GATE_INGREDIENT) and zone.buf.is_gate_open("ingredient"), "the opened gate stays open after the scene reloads")
		if won:
			_check(Session.zone_run.hp == hp_end, "HP after the battle is what was left, with no free heal (%d)" % hp_end)
			_check(int(Session.counters.get(BuffetZone.COUNTER_ENEMIES, 0)) == enemies_before + 1, "the zone's enemy counter went up")
		else:
			_check(Session.zone_run.hp == Session.zone_run.max_hp(), "a loss wakes you at the Grand Pantry at full HP")
			_check(Session.zone_log[Session.zone_log.size() - 1].begins_with("Dish duty fee"), "the dish duty fee was logged")
		await _clear_popups(zone)
		await _shot("g_32_back_in_the_buffet_after_battle")
	_note("buffet battle result this run: %s" % ("won" if won else "lost (woke at hub, fee paid)"))
	return zone


func _fast_enemy_hit(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	var ball: ZoneEnemy = _find_enemy(zone, BuffetEnemies.MEATBALL, true)
	if ball == null:
		ball = _find_enemy(zone, BuffetEnemies.MEATBALL)
	_check(ball != null, "a Runaway Meatball roams the Endless Buffet")
	if ball == null:
		return
	if Session.zone_run.hp <= 3:
		Session.zone_run.fully_heal()
	var start_hp: int = Session.zone_run.hp
	ball.cooldown = 0.0
	ball.state = ZoneEnemy.State.PATROL
	var saved_ranges: Dictionary = {}
	for other: ZoneEnemy in zone.enemies:
		if other != ball:
			other.cooldown = 600.0
			other.state = ZoneEnemy.State.PATROL
			saved_ranges[other] = other.info.aggro_range
			other.info.aggro_range = 0.0
	zone.player.position = _spot_near(zone, ball.position)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	zone._spawn_grace = 0.0
	zone._invulnerable = 0.0
	await driver.frames(3)
	await _shot("g_33_meatball_approaching")
	var waited: float = 0.0
	while Session.zone_run.hp >= start_hp and waited < 12.0:
		await driver.frames(3)
		waited += 3.0 / 60.0
	_check(Session.zone_run.hp == start_hp - BuffetEnemies.MEATBALL_DAMAGE, "the meatball hit for exactly 2 (HP %d -> %d)" % [start_hp, Session.zone_run.hp])
	_check(zone.hp_bar._last_hp == Session.zone_run.hp, "the HUD HP bar shows the new HP")
	await driver.frames(4)
	await _shot("g_34_meatball_hit_flash_and_HP")
	_check(zone._invulnerable > 0.0, "the hit grants a short invulnerability window")
	for other: ZoneEnemy in zone.enemies:
		if other != ball:
			other.cooldown = 0.0
			other.info.aggro_range = float(saved_ranges.get(other, other.info.aggro_range))
	zone._invulnerable = 0.0
	zone.player.position = zone.builder.anchor("spawn")
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.5)


func _stand_at(zone: BuffetScene, spot_id: String) -> void:
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


func _interactables(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	Session.add_gold(100)
	zone.hud.set_gold(Session.gold)
	var run: ZoneRun = Session.zone_run
	run.hp = 2
	EventBus.zone_hp_changed.emit(run.hp, run.max_hp())
	# The soup fountain: real healing, three ladles per visit.
	await _stand_at(zone, "soup_fountain")
	await _shot("g_35_soup_fountain_prompt")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(run.hp == 2 + BuffetInteractables.FOUNTAIN_HEAL, "a ladle of soup heals %d" % BuffetInteractables.FOUNTAIN_HEAL)
	await _shot("g_36_soup_fountain_heal")
	# The Grand Oven needs honey + basil + ghost pepper: we have honey; fetch the other two by hand.
	await _stand_at(zone, "oven")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _shot("g_37_oven_missing_ingredients")
	await _dismiss_dialogue(zone.dialogue)
	_check(int(Session.counters.get(BuffetZone.COUNTER_BAKED, 0)) == 0, "no pie without all three ingredients")
	for id: String in ["basil", "hot_pepper"]:
		await _stand_at(zone, "pickup_" + id)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.3)
	_check(BuffetInteractables.can_bake(), "honey + basil + ghost pepper are in the bag")
	await _stand_at(zone, "oven")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(int(Session.counters.get(BuffetZone.COUNTER_BAKED, 0)) == 1, "the oven baked a Hearty Pot Pie")
	_check(int(Session.profile.item_uses_remaining.get(BuffetZone.PIE_ITEM_ID, 0)) > 0, "...which is in the item bag")
	await _shot("g_38_oven_pie_baked")
	# The fortune cookie: costs 5 gold, shows a hint about a secret.
	await _stand_at(zone, "fortune_cookie")
	var gold: int = Session.gold
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(Session.gold == gold - BuffetInteractables.COOKIE_COST, "a fortune cookie costs %d gold" % BuffetInteractables.COOKIE_COST)
	_check(zone.dialogue.active, "the cookie shows a fortune")
	await _shot("g_39_fortune_cookie_hint")
	await _dismiss_dialogue(zone.dialogue)
	# The taste test: 8 gold for a random effect (we count it, whatever the roll).
	await _stand_at(zone, "taste_test")
	gold = Session.gold
	var tastes: int = int(Session.counters.get(BuffetZone.COUNTER_TASTES, 0))
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.gold >= gold - BuffetInteractables.TASTE_COST, "the taste test costs %d gold (a tip may come back)" % BuffetInteractables.TASTE_COST)
	_check(int(Session.counters.get(BuffetZone.COUNTER_TASTES, 0)) == tastes + 1, "the taste test was counted")
	await _shot("g_40_taste_test_result")


func _hub_heal(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	var run: ZoneRun = Session.zone_run
	run.hp = maxi(1, run.max_hp() - 4)
	EventBus.zone_hp_changed.emit(run.hp, run.max_hp())
	var hurt: int = run.hp
	zone._spawn_grace = 600.0
	var spot: ZoneSpot = _spot(zone, "heal")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(hurt < run.max_hp() and run.hp == run.max_hp(), "the Hearty Meal heals to full (%d -> %d)" % [hurt, run.hp])
	await _shot("g_41_hub_heal_hearty_meal")
	# The vendor sells Gourmand cards (and Dolcetta hands out Bake Me a Pie).
	await _clear_popups(zone)
	var dolcetta: ZoneSpot = _spot(zone, "dolcetta")
	await _walk_to(zone, dolcetta.position, dolcetta.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("g_42_dolcetta_dialogue_and_quest_offer")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(Session.quest_log.is_active(BuffetZone.QUEST_PIE), "Dolcetta handed out Bake Me a Pie")
	_check(zone._overlay is VendorScreen, "Dolcetta opens the Gourmand card vendor")
	if zone._overlay is VendorScreen:
		await driver.click_button("Got it")
		await _shot("g_43_gourmand_vendor")
		var tile: Control = _find_meta_tile(zone._overlay, "card_id", "G-02")
		_check(tile != null, "a Meatloaf Golem card is for sale")
		var owned: int = Session.owned_count("G-02")
		if tile != null:
			await driver.click(tile.get_global_rect().position + Vector2(60, 90))
			await driver.seconds(0.3)
			await driver.click_button("Buy")
			await driver.seconds(0.4)
		_check(Session.owned_count("G-02") == owned + 1, "buying adds the Gourmand card")
		await driver.click_button("Leave")
		await driver.seconds(0.3)
	# Quest counters count from acceptance, so bake a second pie now (the pantry stock is topped up directly:
	# each pickup is once per visit, which is covered above).
	for id: String in BuffetZone.OVEN_RECIPE:
		Session.counters[BuffetZone.stock_key(id)] = 1
	await _stand_at(zone, "oven")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.quest_log.objectives_met_count(QuestCatalog.find(BuffetZone.QUEST_PIE), Session.unlock_state()) == 1, "baking after accepting the quest completes its objective")
	await _clear_popups(zone)
	# The pie is baked: the quest is ready to hand in (the vendor opens after the conversation).
	await _walk_to(zone, dolcetta.position, dolcetta.radius)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	if zone._overlay is VendorScreen:
		await driver.click_button("Leave")
		await driver.seconds(0.3)
	await _clear_popups(zone)
	_check(Session.quest_log.is_completed(BuffetZone.QUEST_PIE), "handing the pie in completes Bake Me a Pie")
	await _shot("g_44_pie_quest_handed_in")


func _quiz(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "quiz")
	var gold_before: int = Session.gold
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("g_45_lady_brioche_dialogue")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(zone._overlay is QuizScreen, "the quiz master opens the quiz")
	if not (zone._overlay is QuizScreen):
		return
	var story: ZoneStoryText = ZoneStoryText.for_zone(BuffetZone.ID)
	var shot_done: bool = false
	for question: Dictionary in story.quiz_questions:
		var correct_text: String = str((question["a"] as Array)[int(question["correct"])])
		var button: Button = driver.find_button(correct_text, zone._overlay)
		_check(button != null, "the right answer is on screen: %s" % correct_text)
		if not shot_done:
			shot_done = true
			await _shot("g_46_quiz_question")
		if button != null:
			await driver.click(driver.button_center(button))
			await driver.seconds(0.3)
	await _shot("g_47_quiz_result")
	_check(Session.flag(BuffetZone.FLAG_QUIZ_DONE), "finishing the quiz sets the Buffet's quiz flag")
	_check(Session.gold > gold_before, "a perfect score paid out (%d -> %d gold)" % [gold_before, Session.gold])
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _order_up(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "minigame")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("g_48_chef_turbo_dialogue")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(zone._overlay is OrderGameScreen, "Chef Turbo launches Order Up!")
	if not (zone._overlay is OrderGameScreen):
		return
	var screen: OrderGameScreen = zone._overlay as OrderGameScreen
	var gold_before: int = Session.gold
	await _shot("g_49_order_up_start")
	await driver.click_button("Start the shift")
	await driver.seconds(0.5)
	await _shot("g_50_order_up_countdown")
	var guard: int = 0
	var shot_ticket: bool = false
	var tossed: bool = false
	while not screen.game.is_finished() and guard < 6000:
		guard += 1
		await driver.frames(1)
		if screen._state != "playing" or screen.game.is_finished() or screen.game.in_gap(screen._clock):
			continue
		var recipe: Array = screen.game.recipe()
		var wanted: int = int(recipe[screen.game.plate.size()])
		if screen.game.current == 0 and not tossed and screen.game.plate.size() == 1:
			tossed = true
			var wrong: int = OrderGame.CHEESE if wanted != OrderGame.CHEESE else OrderGame.TOMATO
			await driver.tap_key(KEY_1 + wrong)
			await driver.frames(4)
			_check(screen.game.mistakes == 1 and screen.game.plate.size() == 0, "a wrong ingredient tosses the plate")
			await _shot("g_51_order_up_tossed_plate")
			continue
		if not shot_ticket and screen.game.current == 3 and screen.game.plate.size() == 2:
			shot_ticket = true
			await _shot("g_52_order_up_ticket_in_progress")
		await driver.seconds(0.18)
		await driver.tap_key(KEY_1 + wanted)
	await driver.seconds(2.6)
	_check(screen.game.is_finished(), "the shift finished")
	_check(screen.game.stars() >= 2, "assembling every dish in order earned stars (%d points, %d stars)" % [screen.game.points(), screen.game.stars()])
	_check(Session.gold > gold_before and Session.flag(BuffetZone.FLAG_ORDER_FIRST), "the shift paid out with the one-time first-clear bonus")
	await _shot("g_53_order_up_result")
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _stew_puzzle(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	# The Pancake Plateau is behind Colonel Casserole: the real fight is unit-tested; here the gate flag is set
	# and the player is dropped at the foot of the orange pad, which then launches them for real.
	Session.set_flag(BuffetZone.FLAG_GATE_BATTLE)
	zone.buf.open_gate("battle")
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	var pad: BuffetLayout.Pad = zone.buf.layout.pads[4]
	zone.player.position = Vector3(pad.pos.x - 2.5, 0.0, pad.pos.y + 1.0)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.6)
	await _hold(KEY_D, true)
	var waited: float = 0.0
	while not zone.player.airborne and waited < 6.0:
		await driver.frames(2)
		waited += 2.0 / 60.0
	await _hold(KEY_D, false)
	_check(zone.player.airborne, "the orange pad launches you towards the Pancake Summit")
	await _wait_not_airborne(zone, 8.0)
	await driver.seconds(1.0)
	_check(zone.buf.layout.surface_at(zone.player.position.x, zone.player.position.z) == BuffetLayout.Surface.MESA, "you landed on the Pancake Summit")
	await _shot("g_54_pancake_summit")
	var spot: ZoneSpot = _spot(zone, "puzzle")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(zone._overlay is RecipePuzzleScreen, "the stew pot opens the recipe puzzle")
	if not (zone._overlay is RecipePuzzleScreen):
		return
	var screen: RecipePuzzleScreen = zone._overlay as RecipePuzzleScreen
	await _shot("g_55_stew_puzzle_start")
	# A wrong stew first: the first four ingredients in pantry order.
	for ingredient: int in range(4):
		await driver.click(driver.center_of_control(screen._ingredient_buttons[ingredient]))
		await driver.seconds(0.08)
	await driver.click_button("Serve the stew")
	await driver.seconds(0.4)
	_check(not Session.flag(BuffetZone.FLAG_PUZZLE_SOLVED), "a wrong stew does not solve it")
	await _shot("g_56_stew_puzzle_wrong_attempt")
	await driver.click_button("Empty the pot")
	await driver.seconds(0.3)
	for ingredient: int in RecipePuzzle.SOLUTION:
		await driver.click(driver.center_of_control(screen._ingredient_buttons[ingredient]))
		await driver.seconds(0.08)
	await _shot("g_57_stew_puzzle_solution_in_the_pot")
	var ladle: EquipmentData = Session.content.equipment_piece("head_chef_ladle")
	_check(not Session.profile.owned_equipment.has(ladle), "the ladle is not owned before solving")
	await driver.click_button("Serve the stew")
	await driver.seconds(0.5)
	_check(Session.flag(BuffetZone.FLAG_PUZZLE_SOLVED), "the right stew solves the puzzle")
	_check(Session.profile.owned_equipment.has(ladle), "solving rewards the Head Chef's Ladle")
	await _shot("g_58_stew_puzzle_solved")
	await driver.click_button("Leave")
	await driver.seconds(0.3)
	# The pad on top bounces you back down.
	var back: BuffetLayout.Pad = zone.buf.layout.pads[5]
	await _walk_to(zone, Vector3(back.pos.x, 0.0, back.pos.y), 0.5)
	await _wait_not_airborne(zone, 8.0)
	await driver.seconds(1.0)
	_check(zone.buf.layout.surface_at(zone.player.position.x, zone.player.position.z) == BuffetLayout.Surface.GROUND, "the pad bounces you back down from the summit")


func _hidden_chest(zone: BuffetScene) -> void:
	await _clear_popups(zone)
	var id: String = "chest_loaf"
	var pos: Vector3 = zone.builder.chest_positions()[id] as Vector3
	var gold_before: int = Session.gold
	zone.player.position = pos + Vector3(2.5, 0, 0.5)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._spawn_grace = 20.0
	zone._invulnerable = 20.0
	await driver.frames(4)
	await _walk_to(zone, pos, BuffetScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	await _shot("g_59_loaf_chest_prompt_only_no_marker")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.found_secret("buf_%s" % id), "opening the stash marks its secret found")
	_check(Session.gold > gold_before, "the stash paid gold (%d -> %d)" % [gold_before, Session.gold])
	await _shot("g_60_loaf_chest_opened")


func _mini_dungeon(zone: BuffetScene) -> BuffetScene:
	await _clear_popups(zone)
	# Layer-Cake Town is behind Sir Loin: the quest condition is unit-tested, the gate flag is set here.
	Session.set_flag(BuffetZone.FLAG_GATE_QUEST)
	zone.buf.open_gate("quest")
	var spot: ZoneSpot = _spot(zone, "mini_dungeon")
	zone._spawn_grace = 20.0
	zone._invulnerable = 20.0
	zone.player.position = spot.position + Vector3(0, 0, 3.0)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.6)
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await _shot("g_61_walk_in_freezer_entrance")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _shot("g_62_walk_in_freezer_prompt")
	var hp_at_entry: int = Session.zone_run.hp
	await driver.click_button("Open the door")
	var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	_check(map_screen != null, "the mini dungeon opens the node map")
	if map_screen == null:
		return zone
	_check(Session.mini_active and Session.run.hp == hp_at_entry, "the run starts at the zone's current HP (%d)" % hp_at_entry)
	await driver.seconds(1.2)
	await _shot("g_63_walk_in_freezer_map")
	var battles: int = 0
	while battles < MiniDungeon.BATTLE_COUNT:
		map_screen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
		if map_screen == null:
			break
		await driver.seconds(0.6)
		var available: Array[DungeonMap.MapNode] = Session.dungeon_map.available()
		if available.is_empty():
			break
		var button: MapNodeButton = map_screen._buttons[available[0].id] as MapNodeButton
		var hp_before: int = Session.run.hp
		await driver.click(driver.center_of_control(button))
		var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
		if battle == null:
			break
		battles += 1
		_check(battle.game.players[0].hp == hp_before, "freezer battle %d starts at the carried HP (%d)" % [battles, hp_before])
		if battles == 1:
			await _shot("g_64_freezer_battle_1")
		await _play_battle(battle)
		var won: bool = battle.context.won
		await driver.click_button("Continue")
		if not won:
			break
		var next: Node = await _wait_scene_either()
		if next is RewardsScreen:
			await driver.seconds(1.2)
			if battles == MiniDungeon.BATTLE_COUNT:
				await _shot("g_65_freezer_final_reward")
			await driver.click_button("Continue")
			await driver.seconds(0.6)
			if get_tree().current_scene is BuffetScene:
				break
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
	zone = await _wait_for(BuffetScene) as BuffetScene
	await driver.seconds(1.0)
	if zone != null:
		await _shot("g_66_back_from_the_freezer")
	_check(not Session.mini_active, "the mini dungeon run ended and returned to the zone")
	if Session.flag(BuffetZone.FLAG_MINI_CLEARED):
		_check(Session.owned_count("G-28") == 1, "clearing it granted the unique Colossus of the Endless Buffet")
	_note("mini dungeon: %d battle(s) fought, cleared=%s (a loss wakes you at the hub; the clear path is unit-tested)" % [battles, str(Session.flag(BuffetZone.FLAG_MINI_CLEARED))])
	return zone


func _final_state(zone: BuffetScene) -> void:
	if zone == null:
		return
	await driver.tap_key(KEY_J)
	await driver.seconds(0.4)
	await _shot("g_67_quest_log_in_the_buffet")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.3)
	var fog: FogOfWar = Session.fog_for(BuffetZone.ID, zone.builder.map_bounds())
	_check(fog.revealed_count() > 1200, "the Endless Buffet fog of war ended up well explored (%d cells)" % fog.revealed_count())
	var saved: Dictionary = Session.to_dict()
	_check((saved.get("map_fog", {}) as Dictionary).has(BuffetZone.ID), "the reveal is in the save, per zone")
	_check(not Session.zone_log.is_empty(), "the zone log has entries (soup falls / fees)")
	_chest_clear(zone)
	await _shot("g_68_final_minimap")


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
		if scene != null and not SceneManager.busy and (scene is RewardsScreen or scene is BuffetScene):
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _spot(zone: BuffetScene, id: String) -> ZoneSpot:
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


## Closes whatever is blocking the world: a dialogue, a level-up popup (earned from quiz/quest XP).
func _clear_popups(zone: BuffetScene) -> void:
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
