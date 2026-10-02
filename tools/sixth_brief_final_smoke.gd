class_name SixthBriefFinalSmoke
extends Node
## FINAL (sixth brief): the Gainlands flow with human-style input, end to end: town -> Beefcake Path ->
## the Gainlands, the minimap reveals as you explore and POIs appear (full map on M) -> run the hamster
## wheel -> get THROWN to a floating island (a chest up there) -> come back -> use a PORTAL (unlocked by the
## wheel) -> FALL off an island (respawn at the last safe spot, -1 zone life, logged) -> slow-enemy battle
## -> fast-enemy hit -> hub heal -> quiz -> Rep Counter minigame -> power-routing puzzle -> mini dungeon
## -> a ground chest. Screenshots every new area and screen to _screenshots/brief6/. Run windowed:
##   Godot --path . res://tools/sixth_brief_final_launcher.tscn
## (the D.N.A. regression is `tools/run_fifth_brief_final_smoke.sh`, run first by the runner script).
## Deliberate shortcuts (stated, like the earlier smokes): the Beefcake gate flag is set directly
## (beating Torvin is covered by the corrupted-NPC smoke); long walks fall back to a short teleport when
## the crude no-pathfinding mover gets stuck behind a prop; the player is placed near an enemy so it
## notices them quickly; the minigame presses are timed from the screen's own clock (a player watches
## the rings).
## Exit code 0 = every check passed; 1 = a check failed.

const STALL_LIMIT: float = 25.0
const SHOT_DIR: String = "res://_screenshots/brief6/"
const TAG: String = "sixth_brief_final_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)
	await _town_minimap_and_path(town)
	var zone: GainlandsScene = await _enter_the_gainlands(town)
	if zone == null:
		_finish(false, "never reached the Gainlands")
		return
	await _explore_and_reveal(zone)
	await _hub_and_areas(zone)
	await _run_the_wheel(zone)
	await _thrown_to_an_island(zone)
	await _portal_to_delt_deck(zone)
	await _fall_off_an_island(zone)
	await _portal_home(zone)
	zone = await _slow_enemy_battle(zone)
	await _fast_enemy_hit(zone)
	await _hub_heal(zone)
	await _quiz(zone)
	await _rep_counter(zone)
	await _power_puzzle(zone)
	await _ground_chest(zone)
	zone = await _mini_dungeon(zone)
	await _final_state(zone)
	_finish(_failures.is_empty(), "town -> Beefcake Path -> Gainlands: minimap reveal + POIs -> wheel -> throw to island + chest -> portal -> fall (-1 life) -> slow battle -> fast hit -> hub heal -> quiz -> rep counter -> puzzle -> chest -> mini dungeon (%d screenshots)" % _shots)


# ---- Steps ------------------------------------------------------------------------------


func _town_minimap_and_path(town: TownScene) -> void:
	_check(town.minimap != null and town.minimap.visible, "the town HUD has a minimap")
	await _shot("f_01_town_minimap")
	await driver.tap_key(KEY_M)
	await driver.seconds(0.4)
	_check(town._overlay is FullMapScreen, "M opens the full map in town")
	await _shot("f_02_town_full_map")
	await driver.tap_key(KEY_M)
	await driver.seconds(0.3)
	_check(town._overlay == null, "M closes the full map")
	Session.set_flag(CorruptedNpcs.unlock_flag(GainlandsZone.ID))
	var anchor: Vector3 = town.town.anchors["portal_beefcake"] as Vector3
	await _walk_to(town, anchor, 1.6)
	await driver.frames(4)
	await _shot("f_03_town_beefcake_path")
	var label: String = ""
	for spot: TownScene.Spot in town.spots:
		if spot.id == "portal_beefcake":
			label = spot.title
	_check(label == "Beefcake Path", "the town exit is called the Beefcake Path (got '%s')" % label)


func _enter_the_gainlands(town: TownScene) -> GainlandsScene:
	await driver.tap_key(KEY_E)
	var zone: GainlandsScene = await _wait_for(GainlandsScene) as GainlandsScene
	_check(zone != null, "the Beefcake Path leads into the Gainlands")
	if zone != null:
		await driver.seconds(1.2)
		_check(Session.zone_run != null and Session.zone_run.zone_id == GainlandsZone.ID, "a zone visit starts for the Gainlands")
		_check(Session.zone_run.life == Session.zone_run.max_life(), "entering starts at full zone life")
		await _shot("f_04_gainlands_arrival_hub")
	return zone


func _chest_clear(zone: GainlandsScene) -> void:
	# The map must never show a hidden chest: no POI stands where a chest is.
	for poi: MapPoi in zone._collect_pois():
		for id: Variant in zone.builder.chest_positions().keys():
			var chest: Vector3 = zone.builder.chest_positions()[id] as Vector3
			if Vector2(poi.pos.x - chest.x, poi.pos.z - chest.z).length() < 0.5:
				_fail("a POI (%s) sits on top of hidden chest %s" % [poi.label, str(id)])


func _explore_and_reveal(zone: GainlandsScene) -> void:
	var fog: FogOfWar = zone.minimap.fog
	var start_count: int = fog.revealed_count()
	var start_pois: int = MapView.visible_pois(zone._collect_pois(), fog).size()
	_check(start_count > 50, "the minimap starts with the hub area revealed (%d cells)" % start_count)
	_check(start_pois >= 2, "hub points of interest are already on the map (%d)" % start_pois)
	var quiz_spot: ZoneSpot = _spot(zone, "quiz")
	var quiz_known: bool = MapView.visible_pois(zone._collect_pois(), fog).any(func(poi: MapPoi) -> bool: return poi.kind == MapPoi.Kind.QUIZ)
	_check(not quiz_known, "the quiz master is NOT on the map before exploring")
	await _shot("f_05_minimap_start")
	zone._spawn_grace = 600.0
	await _walk_to(zone, zone.builder.anchor("hub") + Vector3(0, 0, -12.0), 2.0)
	await _walk_to(zone, quiz_spot.position, quiz_spot.radius)
	await driver.seconds(0.5)
	var later_count: int = fog.revealed_count()
	_check(later_count > start_count + 200, "walking around reveals more of the map (%d -> %d cells)" % [start_count, later_count])
	quiz_known = MapView.visible_pois(zone._collect_pois(), fog).any(func(poi: MapPoi) -> bool: return poi.kind == MapPoi.Kind.QUIZ)
	_check(quiz_known, "the quiz master appears on the map once its area is explored")
	var pois: Array[MapPoi] = MapView.visible_pois(zone._collect_pois(), fog)
	var marker_found: bool = false
	for poi: MapPoi in pois:
		if poi.kind == MapPoi.Kind.QUEST_GIVER and poi.quest_marker:
			marker_found = true
	_check(marker_found, "a quest giver with an available quest shows the '!' marker")
	_chest_clear(zone)
	await _shot("f_06_minimap_after_exploring_quiz")
	await driver.tap_key(KEY_M)
	await driver.seconds(0.4)
	_check(zone._overlay is FullMapScreen, "M opens the full map in the Gainlands")
	await _shot("f_07_gainlands_full_map_with_legend")
	await driver.tap_key(KEY_M)
	await driver.seconds(0.3)
	_check(zone._overlay == null, "M closes the full map again")


func _hub_and_areas(zone: GainlandsScene) -> void:
	zone._spawn_grace = 600.0
	zone._invulnerable = 600.0
	for place: String in ["station", "tony", "heal", "protein_stand", "flex_mirror", "mini_dungeon", "main_dungeon", "puzzle", "minigame", "spot_me", "run_wheel", "thrower_pec", "ripper_delt", "thrower_east"]:
		zone.player.position = zone.builder.anchor(place) + Vector3(0, 0, 1.2)
		zone.player.position.y = zone.builder.height_at(zone.player.position)
		zone._camera.position = zone.player.position + zone.camera_offset
		await driver.seconds(0.8)
		await _shot("f_08_area_%s" % place)
	zone._invulnerable = 0.0
	zone.player.position = zone.builder.anchor("spawn")
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.frames(10)


func _run_the_wheel(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "run_wheel")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	_check(not Session.flag(GainlandsZone.FLAG_WHEEL_POWERED), "the grid starts unpowered")
	await driver.tap_key(KEY_E)
	await driver.seconds(1.4)
	await _shot("f_09_running_the_hamster_wheel")
	var guard: int = 0
	while not Session.flag(GainlandsZone.FLAG_WHEEL_POWERED) and guard < 400:
		guard += 1
		await driver.frames(3)
	_check(Session.flag(GainlandsZone.FLAG_WHEEL_POWERED), "running the colossal wheel powers the grid")
	await driver.seconds(1.0)
	await _shot("f_10_wheel_powered")
	await _clear_popups(zone)


func _talk_and_confirm(zone: GainlandsScene, spot_id: String, confirm_text: String) -> void:
	var spot: ZoneSpot = _spot(zone, spot_id)
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("f_11_%s_dialogue" % spot_id)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	await _shot("f_12_%s_confirm" % spot_id)
	await driver.click_button(confirm_text)


func _wait_not_airborne(zone: GainlandsScene, limit: float) -> void:
	var waited: float = 0.0
	while (zone.player.airborne or zone._locked) and waited < limit:
		await driver.frames(3)
		waited += 3.0 / 60.0


func _thrown_to_an_island(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	var throws_before: int = int(Session.counters.get(GainlandsTravel.COUNTER_THROWS, 0))
	await _talk_and_confirm(zone, "travel_thrower_pec", "Throw me!")
	await driver.seconds(1.15)
	_check(zone.player.airborne, "you are in the air after the Beefcake grabs you")
	await _shot("f_13_mid_air_throw_camera_follows")
	await driver.seconds(0.9)
	await _shot("f_14_throw_arc_over_the_map")
	await _wait_not_airborne(zone, 10.0)
	await driver.seconds(0.2)
	var island: GainlandsLayout.Island = zone.gain.island_under(zone.player.position)
	_check(island != null and island.id == "pec", "you landed on Pec Perch")
	_check(absf(zone.player.position.y - island.height) < 0.6, "...at the island's height (y %.1f)" % zone.player.position.y)
	await _shot("f_15_landing_dust_and_impact")
	await driver.seconds(1.2)
	_check(int(Session.counters.get(GainlandsTravel.COUNTER_THROWS, 0)) == throws_before + 1, "the throw was counted")
	await _shot("f_16_pec_perch_island")
	# The chest on the island: no marker, prompt only when very close.
	var chest: Vector3 = zone.builder.chest_positions()["chest_pec"] as Vector3
	var gold_before: int = Session.gold
	zone._spawn_grace = 600.0
	await _walk_to(zone, chest, GainlandsScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	await _shot("f_17_island_chest_prompt_only")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.found_secret("gain_chest_pec"), "the island chest was found")
	_check(Session.gold > gold_before, "the island chest paid gold (%d -> %d)" % [gold_before, Session.gold])
	await _shot("f_18_island_chest_opened")
	await _clear_popups(zone)
	# And the way home: the return thrower.
	await _talk_and_confirm(zone, "travel_thrower_pec_back", "Throw me!")
	await _wait_not_airborne(zone, 12.0)
	await driver.seconds(1.0)
	_check(zone.gain.island_under(zone.player.position) == null, "the return throw lands you back on the main land")


func _portal_to_delt_deck(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	var portals_before: int = int(Session.counters.get(GainlandsTravel.COUNTER_PORTALS, 0))
	var spot: ZoneSpot = _spot(zone, "travel_ripper_delt")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	await _shot("f_19_portal_ripper_confirm")
	await driver.click_button("Step through")
	await driver.seconds(0.9)
	await _shot("f_20_portal_torn_open")
	await _wait_not_airborne(zone, 12.0)
	await driver.seconds(0.8)
	var island: GainlandsLayout.Island = zone.gain.island_under(zone.player.position)
	_check(island != null and island.id == "delt", "the portal led to Delt Deck")
	_check(int(Session.counters.get(GainlandsTravel.COUNTER_PORTALS, 0)) == portals_before + 1, "the portal trip was counted")
	await _shot("f_21_delt_deck_after_portal")


func _fall_off_an_island(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	var island: GainlandsLayout.Island = zone.gain.island_under(zone.player.position)
	_check(island != null, "standing on an island before the fall")
	if island == null:
		return
	await driver.seconds(0.5)
	var safe: Vector3 = zone.last_safe
	var life_before: int = Session.zone_run.life
	var log_before: int = Session.zone_log.size()
	_check(zone.gain.island_under(safe) == island, "the last safe spot is on this island (%.1f, %.1f)" % [safe.x, safe.z])
	var _unused_safe: Vector3 = safe
	await _shot("f_22_before_the_edge")
	# Walk east until the rim: hold D.
	await _hold(KEY_D, true)
	var waited: float = 0.0
	while not zone._falling and waited < 8.0:
		await driver.frames(2)
		waited += 2.0 / 60.0
	await _hold(KEY_D, false)
	_check(zone._falling, "stepping off the edge starts a fall")
	await driver.seconds(0.5)
	await _shot("f_23_falling_off_the_island")
	var guard: int = 0
	while (zone._falling or zone._locked) and guard < 300:
		guard += 1
		await driver.frames(3)
	await driver.seconds(0.4)
	_check(Session.zone_run.life == life_before - GainlandsZone.FALL_DAMAGE, "the fall cost exactly 1 zone life (%d -> %d)" % [life_before, Session.zone_run.life])
	_check(zone.gain.island_under(zone.player.position) == island, "you respawn on the island")
	var rim_distance: float = Vector2(zone.player.position.x - island.center.x, zone.player.position.z - island.center.y).length()
	_check(zone.player.position.distance_to(zone.last_safe) < 1.0 and rim_distance <= island.radius - GainlandsScene.RIM_SAFE_DISTANCE + 0.2, "...at the last safe spot, well inside the island (%.1f of %.1f from the centre)" % [rim_distance, island.radius])
	_check(Session.zone_log.size() == log_before + 1, "the fall is logged (%s)" % Session.zone_log[Session.zone_log.size() - 1])
	await _shot("f_24_respawned_minus_one_life")


func _portal_home(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	zone._spawn_grace = 600.0
	zone._invulnerable = 5.0
	var spot: ZoneSpot = _spot(zone, "travel_ripper_delt_back")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	await driver.click_button("Step through")
	await _wait_not_airborne(zone, 12.0)
	await driver.seconds(1.0)
	_check(zone.gain.island_under(zone.player.position) == null, "the return portal brings you back to the main land")
	zone._spawn_grace = 0.0
	zone._invulnerable = 0.0


func _find_enemy(zone: GainlandsScene, type: String) -> ZoneEnemy:
	for enemy: ZoneEnemy in zone.enemies:
		if enemy.info.id == type:
			return enemy
	return null


func _spot_near(zone: GainlandsScene, center: Vector3) -> Vector3:
	for distance: float in [3.0, 3.5, 4.0, 2.5]:
		for angle: int in range(0, 360, 30):
			var candidate: Vector3 = center + Vector3(cos(deg_to_rad(float(angle))), 0.0, sin(deg_to_rad(float(angle)))) * distance
			if zone.builder.is_walkable(candidate) and zone.builder.has_line_of_sight(candidate, center) and _body_clear(zone, candidate, center):
				return candidate
	return center


## True when a body-wide path (radius 0.4) between the two points is free of props and trees.
func _body_clear(zone: GainlandsScene, a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(2, int(a.distance_to(b) / 0.4))
	for i: int in range(steps + 1):
		if not zone.builder.is_walkable(a.lerp(b, float(i) / float(steps)), 0.4):
			return false
	return true


func _slow_enemy_battle(zone: GainlandsScene) -> GainlandsScene:
	await _clear_popups(zone)
	var enemy: ZoneEnemy = _find_enemy(zone, GainlandsEnemies.GOLEM)
	_check(enemy != null, "a Protein Shake Golem roams the Gainlands")
	if enemy == null:
		return zone
	var enemy_id: String = enemy.instance_id
	var life_before: int = Session.zone_run.life
	var enemies_before: int = int(Session.counters.get(GainlandsZone.COUNTER_ENEMIES, 0))
	zone.player.position = _spot_near(zone, enemy.position)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.frames(4)
	await _shot("f_25_golem_approaching")
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
	await _shot("f_26_gainlands_battle_beefcake_deck")
	await _play_battle(battle)
	var life_end: int = battle.game.players[0].life
	var won: bool = battle.context.won
	await _shot("f_27_gainlands_battle_result")
	await driver.click_button("Continue")
	zone = await _wait_for(GainlandsScene) as GainlandsScene
	await driver.seconds(1.0)
	if zone != null:
		_check(Session.zone_run != null, "back in the Gainlands after the battle")
		if won:
			_check(Session.zone_run.life == life_end, "life after the battle is what was left, with no free heal (%d)" % life_end)
			_check(int(Session.counters.get(GainlandsZone.COUNTER_ENEMIES, 0)) == enemies_before + 1, "the zone's enemy counter went up")
		else:
			_check(Session.zone_run.life == Session.zone_run.max_life(), "a loss wakes you at the Swole Station at full life")
			_check(Session.zone_log[Session.zone_log.size() - 1].begins_with("Protein tab"), "the protein tab was logged")
		await _clear_popups(zone)
		await _shot("f_28_back_in_gainlands_after_battle")
	_note("gainlands battle result this run: %s" % ("won" if won else "lost (woke at hub, fee paid)"))
	return zone


func _fast_enemy_hit(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	var sprite: ZoneEnemy = _find_enemy(zone, GainlandsEnemies.SPRITE)
	_check(sprite != null, "a Sprinting Energy Sprite roams the Gainlands")
	if sprite == null:
		return
	if Session.zone_run.life <= 3:
		Session.zone_run.fully_heal()
	var start_life: int = Session.zone_run.life
	sprite.cooldown = 0.0
	sprite.state = ZoneEnemy.State.PATROL
	var saved_ranges: Dictionary = {}
	for other: ZoneEnemy in zone.enemies:
		if other != sprite:
			other.cooldown = 600.0
			other.state = ZoneEnemy.State.PATROL
			saved_ranges[other] = other.info.aggro_range
			other.info.aggro_range = 0.0
	zone.player.position = sprite.position + Vector3(3.5, 0.0, 0.0)
	if not zone.builder.is_walkable(zone.player.position):
		zone.player.position = sprite.position + Vector3(-3.5, 0.0, 0.0)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._camera.position = zone.player.position + zone.camera_offset
	zone._spawn_grace = 0.0
	zone._invulnerable = 0.0
	await driver.frames(3)
	await _shot("f_29_sprite_approaching")
	var waited: float = 0.0
	while Session.zone_run.life >= start_life and waited < 12.0:
		await driver.frames(3)
		waited += 3.0 / 60.0
	_check(Session.zone_run.life == start_life - GainlandsEnemies.SPRITE_DAMAGE, "the sprite hit for exactly 2 (life %d -> %d)" % [start_life, Session.zone_run.life])
	_check(zone.life_bar._last_life == Session.zone_run.life, "the HUD life bar shows the new life")
	await driver.frames(4)
	await _shot("f_30_sprite_hit_flash_and_life")
	_check(zone._invulnerable > 0.0, "the hit grants a short invulnerability window")
	for other: ZoneEnemy in zone.enemies:
		if other != sprite:
			other.cooldown = 0.0
			other.info.aggro_range = float(saved_ranges.get(other, other.info.aggro_range))
	zone._invulnerable = 0.0
	zone.player.position = zone.builder.anchor("spawn")
	zone._camera.position = zone.player.position + zone.camera_offset
	await driver.seconds(0.5)


func _hub_heal(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	if Session.zone_run.life >= Session.zone_run.max_life():
		Session.zone_run.damage(3)
		EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	var hurt: int = Session.zone_run.life
	zone._spawn_grace = 600.0
	var spot: ZoneSpot = _spot(zone, "heal")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(4)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(hurt < Session.zone_run.max_life() and Session.zone_run.life == Session.zone_run.max_life(), "the Cooldown Hot Tub heals to full (%d -> %d)" % [hurt, Session.zone_run.life])
	await _shot("f_31_hub_heal_hot_tub")
	# The vendor sells Beefcake cards.
	await _clear_popups(zone)
	var tony: ZoneSpot = _spot(zone, "tony")
	await _walk_to(zone, tony.position, tony.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("f_32_tony_dialogue_and_quest_offer")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(Session.quest_log.is_active(GainlandsZone.QUEST_LANES), "Tiny Tony handed out Clear the Lanes")
	_check(zone._overlay is VendorScreen, "Tony opens the Beefcake card vendor")
	if zone._overlay is VendorScreen:
		await driver.click_button("Got it")
		await _shot("f_33_beefcake_vendor")
		var tile: Control = _find_meta_tile(zone._overlay, "card_id", "gym_rat")
		_check(tile != null, "a Gym Rat is for sale")
		var owned: int = Session.owned_count("gym_rat")
		if tile != null:
			await driver.click(tile.get_global_rect().position + Vector2(60, 90))
			await driver.seconds(0.3)
			await driver.click_button("Buy")
			await driver.seconds(0.4)
		_check(Session.owned_count("gym_rat") == owned + 1, "buying adds the Beefcake card")
		await driver.click_button("Leave")
		await driver.seconds(0.3)


func _quiz(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "quiz")
	var gold_before: int = Session.gold
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("f_34_professor_quad_dialogue")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(zone._overlay is QuizScreen, "the quiz master opens the quiz")
	if not (zone._overlay is QuizScreen):
		return
	var story: ZoneStoryText = ZoneStoryText.for_zone(GainlandsZone.ID)
	var shot_done: bool = false
	for question: Dictionary in story.quiz_questions:
		var correct_text: String = str((question["a"] as Array)[int(question["correct"])])
		var button: Button = driver.find_button(correct_text, zone._overlay)
		_check(button != null, "the right answer is on screen: %s" % correct_text)
		if not shot_done:
			shot_done = true
			await _shot("f_35_quiz_question")
		if button != null:
			await driver.click(driver.button_center(button))
			await driver.seconds(0.3)
	await _shot("f_36_quiz_result")
	_check(Session.flag(GainlandsZone.FLAG_QUIZ_DONE), "finishing the quiz sets the Gainlands quiz flag")
	_check(Session.gold > gold_before, "a perfect score paid out (%d -> %d gold)" % [gold_before, Session.gold])
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _rep_counter(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "minigame")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	await _shot("f_37_jazzy_jules_dialogue")
	await _dismiss_dialogue(zone.dialogue)
	await driver.seconds(0.4)
	_check(zone._overlay is RepGameScreen, "Jazzy Jules launches the Rep Counter")
	if not (zone._overlay is RepGameScreen):
		return
	var screen: RepGameScreen = zone._overlay as RepGameScreen
	var gold_before: int = Session.gold
	await _shot("f_38_rep_counter_start")
	await driver.click_button("Start the set")
	await driver.seconds(0.5)
	await _shot("f_39_rep_counter_countdown")
	var rep: int = 0
	var guard: int = 0
	var shot_taken: bool = false
	while rep < RepGame.REPS and guard < 4000:
		guard += 1
		await driver.frames(1)
		if screen._state != "playing":
			continue
		var beat: float = RepGame.BEATS[rep]
		if not shot_taken and screen._clock > beat - 0.4:
			shot_taken = true
			await _shot("f_40_rep_counter_rings_closing")
		if screen._clock >= beat - 0.012:
			if rep == 2:
				rep += 1
				continue
			await driver.tap_key(KEY_SPACE)
			rep += 1
	await driver.seconds(1.8)
	var game: RepGame = screen.game
	_check(game.is_finished(), "the set finished")
	_check(game.points() >= RepGame.THREE_STAR_POINTS - 3, "timed presses scored points (%d / %d)" % [game.points(), RepGame.max_points()])
	_check(game.ratings.has(RepGame.Rating.MISS), "a skipped rep counted as a miss")
	_check(game.stars() >= 1, "the set earned stars (%d)" % game.stars())
	_check(Session.gold > gold_before and Session.flag(GainlandsZone.FLAG_REPS_FIRST), "the performance paid out with the one-time first-clear bonus")
	await _shot("f_41_rep_counter_result")
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _power_puzzle(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "puzzle")
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(zone._overlay is WheelPuzzleScreen, "the control panel opens the power puzzle")
	if not (zone._overlay is WheelPuzzleScreen):
		return
	var screen: WheelPuzzleScreen = zone._overlay as WheelPuzzleScreen
	await _shot("f_42_power_puzzle_start")
	# A wrong attempt first: every wheel feeds its first machine.
	for wheel: int in range(WheelPuzzle.WHEELS):
		await driver.click(driver.center_of_control(screen._buttons[wheel]))
		await driver.seconds(0.08)
	await driver.click_button("Engage the grid")
	await driver.seconds(0.4)
	_check(not Session.flag(GainlandsZone.FLAG_PUZZLE_SOLVED), "a wrong setup does not solve it")
	await _shot("f_43_power_puzzle_wrong_attempt")
	await driver.click_button("Reset")
	await driver.seconds(0.3)
	var solution: Array = WheelPuzzle.solutions()[0] as Array
	for wheel: int in range(WheelPuzzle.WHEELS):
		for press: int in range(int(solution[wheel])):
			await driver.click(driver.center_of_control(screen._buttons[wheel]))
			await driver.seconds(0.08)
	await _shot("f_44_power_puzzle_solution_set")
	var belt: EquipmentData = Session.content.equipment_piece("swole_belt")
	_check(not Session.profile.owned_equipment.has(belt), "the belt is not owned before solving")
	await driver.click_button("Engage the grid")
	await driver.seconds(0.5)
	_check(Session.flag(GainlandsZone.FLAG_PUZZLE_SOLVED), "the right setup solves the puzzle")
	_check(Session.profile.owned_equipment.has(belt), "solving rewards the Gainsmith's Lifting Belt")
	await _shot("f_45_power_puzzle_solved")
	await driver.click_button("Leave")
	await driver.seconds(0.3)


func _ground_chest(zone: GainlandsScene) -> void:
	await _clear_popups(zone)
	var id: String = "chest_ground_1"
	var pos: Vector3 = zone.builder.chest_positions()[id] as Vector3
	var gold_before: int = Session.gold
	zone.player.position = pos + Vector3(2.5, 0, 0.5)
	zone.player.position.y = zone.builder.height_at(zone.player.position)
	zone._spawn_grace = 20.0
	zone._invulnerable = 20.0
	await driver.frames(4)
	await _walk_to(zone, pos, GainlandsScene.HIDDEN_CHEST_RADIUS)
	await driver.frames(4)
	await _shot("f_46_ground_chest_prompt_only_no_marker")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.found_secret("gain_%s" % id), "opening the stash marks its secret found")
	_check(Session.gold > gold_before, "the stash paid gold (%d -> %d)" % [gold_before, Session.gold])
	await _shot("f_47_ground_chest_opened")


func _mini_dungeon(zone: GainlandsScene) -> GainlandsScene:
	await _clear_popups(zone)
	var spot: ZoneSpot = _spot(zone, "mini_dungeon")
	zone._spawn_grace = 20.0
	zone._invulnerable = 20.0
	await _walk_to(zone, spot.position, spot.radius)
	await driver.frames(3)
	await _shot("f_48_iron_cavern_entrance")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _shot("f_49_iron_cavern_prompt")
	var life_at_entry: int = Session.zone_run.life
	await driver.click_button("Chalk up")
	var map_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	_check(map_screen != null, "the mini dungeon opens the node map")
	if map_screen == null:
		return zone
	_check(Session.mini_active and Session.run.life == life_at_entry, "the run starts at the zone's current life (%d)" % life_at_entry)
	await driver.seconds(1.2)
	await _shot("f_50_iron_cavern_map")
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
		var life_before: int = Session.run.life
		await driver.click(driver.center_of_control(button))
		var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
		if battle == null:
			break
		battles += 1
		_check(battle.game.players[0].life == life_before, "mini dungeon battle %d starts at the carried life (%d)" % [battles, life_before])
		if battles == 1:
			await _shot("f_51_iron_cavern_battle_1")
		await _play_battle(battle)
		var won: bool = battle.context.won
		await driver.click_button("Continue")
		if not won:
			break
		var next: Node = await _wait_scene_either()
		if next is RewardsScreen:
			await driver.seconds(1.2)
			if battles == MiniDungeon.BATTLE_COUNT:
				await _shot("f_52_iron_cavern_final_reward")
			await driver.click_button("Continue")
			await driver.seconds(0.6)
			if get_tree().current_scene is GainlandsScene:
				break
	zone = await _wait_for(GainlandsScene) as GainlandsScene
	await driver.seconds(1.0)
	if zone != null:
		await _shot("f_53_back_from_the_iron_cavern")
	_check(not Session.mini_active, "the mini dungeon run ended and returned to the zone")
	if Session.flag(GainlandsZone.FLAG_MINI_CLEARED):
		_check(Session.owned_count("iron_titan") == 1, "clearing it granted the unique Iron Titan card")
	_note("mini dungeon: %d battle(s) fought, cleared=%s (a loss wakes you at the hub; the clear path is unit-tested)" % [battles, str(Session.flag(GainlandsZone.FLAG_MINI_CLEARED))])
	return zone


func _final_state(zone: GainlandsScene) -> void:
	if zone == null:
		return
	await driver.tap_key(KEY_J)
	await driver.seconds(0.4)
	await _shot("f_54_quest_log_in_the_gainlands")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.3)
	var fog: FogOfWar = Session.fog_for(GainlandsZone.ID, zone.builder.map_bounds())
	_check(fog.revealed_count() > 1500, "the Gainlands fog of war ended up well explored (%d cells)" % fog.revealed_count())
	var saved: Dictionary = Session.to_dict()
	_check((saved.get("map_fog", {}) as Dictionary).has(GainlandsZone.ID), "the reveal is in the save, per zone")
	_check(not Session.zone_log.is_empty(), "the zone log has entries (falls / fees)")
	_chest_clear(zone)
	# Same maps in the other walkable areas: placeholder zone + back in town.
	await _shot("f_55_final_minimap")


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
		if scene != null and not SceneManager.busy and (scene is RewardsScreen or scene is GainlandsScene):
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _spot(zone: GainlandsScene, id: String) -> ZoneSpot:
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
func _clear_popups(zone: GainlandsScene) -> void:
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
