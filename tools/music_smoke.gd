class_name MusicSmoke
extends Node
## Music integration smoke (docs/audio/music_integration.md, Part D): a new game through the forest, the town (and its graveyard), a shop, a battle, a zone,
## its dungeon, the boss, the zone being freed and the Capital, checking after each step which cue the MusicManager is playing, that stings fire, that a
## shop is one override (purchases do not retrigger it) and that every crossfade is smooth (the total level never jumps more than a fraction of a dB per
## frame). It drives the Session / SceneManager API directly (the music is not input-dependent) and runs windowed so the real audio mixer is active:
##   bash tools/run_music_smoke.sh      (log: _screenshots/music_smoke.log; MUSIC_LOG=1 also prints every music event)
## Exit code 0 = every check passed.

const STALL_LIMIT: float = 25.0
const SMOOTH_STEP_DB: float = 1.0

var _failures: PackedStringArray = []
var _worst_step_db: float = 0.0
## The Master bus is tapped to measure what the mixer really outputs, per cue: {id: [peak, sum of squares, samples]}.
var _capture: AudioEffectCapture
var _levels: Dictionary = {}
var _overall_peak: float = 0.0


func run() -> void:
	_capture = AudioEffectCapture.new()
	_capture.buffer_length = 0.5
	AudioServer.add_bus_effect(0, _capture)
	Session.save_enabled = false
	Session.new_game()
	await _frames(10)

	# 1. The forest (the game starts there).
	var forest: Node = await _scene(StartingAreaScene)
	_check(forest != null, "the starting forest loads")
	await _expect("the forest", "MUS-FOREST", 3.0)

	# 2. The town, with a crossfade from the forest.
	SceneManager.go_to_town()
	var town: TownScene = await _scene(TownScene) as TownScene
	_check(town != null, "the town loads")
	if town == null:
		_finish("the town never loaded")
		return
	await _watch_fade(2.0)
	await _expect("the town", "MUS-TOWN", 1.0)

	# 3. The graveyard corner of the town has its own theme and hands back.
	var cairn: Vector3 = town.town.anchors.get("graveyard_cairn", Vector3.ZERO) as Vector3
	var home: Vector3 = town.player.position
	town.player.position = cairn + Vector3(0.0, 0.0, 1.0)
	await _seconds(1.2)
	await _expect("the graveyard", "MUS-GRAVE-EXP", 2.0)
	town.player.position = home
	await _seconds(1.5)
	await _expect("back in the plaza", "MUS-TOWN", 3.0)

	# 4. A shop: its theme is one override for the whole visit; purchases do not retrigger it; closing resumes the town music.
	Session.gold = 500
	var shop: PackShopScreen = PackShopScreen.make(PackData.VENDOR_PACK, "town.pack_vendor")
	town._overlay_layer.add_child(shop)
	await _seconds(0.6)
	await _expect("Fenwick's shop", "MUS-SHOP-FENWICK", 2.0)
	var plays_before: int = _count_events("play ")
	for purchase: int in range(3):
		Audio.sting(&"STG-PURCHASE")
		await _seconds(0.4)
	_check(Audio.music.last_sting() == "STG-PURCHASE", "a purchase fires the purchase sting")
	_check(_count_events("play ") == plays_before, "purchases do not restart the shop theme (%d new plays)" % (_count_events("play ") - plays_before))
	await _expect("still in the shop after purchases", "MUS-SHOP-FENWICK", 0.5)
	shop.queue_free()
	await _seconds(2.0)
	await _expect("the town again after the shop", "MUS-TOWN", 1.0)
	_check(_has_event("play MUS-TOWN from"), "the town music resumed where it left off")

	# 5. A battle (a corrupted gate envoy fights to its Path's combat song), the result sting, and the way back.
	Session.challenge_corrupted_npc("beefcake")
	var battle: BattleScreen = await _scene(BattleScreen) as BattleScreen
	_check(battle != null, "the battle loads")
	await _seconds(1.0)
	await _expect("the Beefcake gate envoy", "MUS-BEEF-BATTLE", 2.0)
	Audio.sfx(&"victory")
	_check(Audio.music.last_sting() == "STG-VICTORY", "the victory sting fires")
	await _seconds(0.5)
	SceneManager.go_to_town()
	await _scene(TownScene)
	await _seconds(2.0)
	await _expect("the town after the battle", "MUS-TOWN", 2.0)

	# 6. A zone, its dungeon, the boss.
	Session.enter_zone("beefcake")
	var zone: Node = await _scene(ZoneScene)
	_check(zone != null, "the Gainlands load")
	await _watch_fade(2.0)
	await _expect("the Gainlands", "MUS-BEEF-EXP", 1.0)
	Session.enter_main_dungeon()
	var dungeon: Node = await _scene(DungeonMapScreen)
	_check(dungeon != null, "the House of Gains' map loads")
	await _watch_fade(2.0)
	await _expect("the House of Gains map", "MUS-BEEF-DUN-EXP", 1.0)
	var boss: DungeonMap.MapNode = Session.dungeon_map.boss()
	Session.start_battle(Session.make_dungeon_battle(boss))
	await _scene(BattleScreen)
	await _seconds(1.5)
	await _expect("the House of Gains boss", "MUS-BEEF-BOSS", 2.0)

	# 7. The zone freed: the boss falls, the zone returns with its freed arrangement and the zone sting.
	Session.finish_main_dungeon(true)
	await _scene(ZoneScene)
	await _seconds(2.0)
	await _expect("the freed Gainlands", "MUS-BEEF-FREED", 2.0)
	_check(Audio.music.last_sting() == "STG-ZONE-BEEF", "freeing the Gainlands fires its zone sting (got '%s')" % Audio.music.last_sting())

	# 8. The Capital: every area has its own cue; with all four zones free the districts are restored.
	for zone_id: String in ["gourmand", "necrocrat", "refusemancer"]:
		Session.complete_zone(zone_id)
	Session.enter_zone(CapitalZone.ID)
	var capital: CapitalScene = await _scene(CapitalScene) as CapitalScene
	_check(capital != null, "the Capital loads")
	if capital == null:
		_finish("the Capital never loaded")
		return
	await _seconds(1.0)
	for area: CapitalLayout.Area in capital.capital.layout.areas:
		var center: Vector2 = Vector2(float(area.rect.position.x) + float(area.rect.size.x) * 0.5, float(area.rect.position.y) + float(area.rect.size.y) * 0.5)
		capital.player.position = Vector3(center.x, capital.player.position.y, center.y)
		await _seconds(1.6)
		var inside: bool = capital._inside
		var want: String = MusicDirector.capital_area(area.id, Session.flags, inside)
		await _expect("the Capital's %s" % area.id, want, 3.0)
	_finish("forest -> town -> graveyard -> shop -> battle -> zone -> dungeon -> boss -> zone freed -> Capital")


func _process(_delta: float) -> void:
	if _capture == null:
		return
	var available: int = _capture.get_frames_available()
	if available <= 0:
		return
	var frames: PackedVector2Array = _capture.get_buffer(available)
	var id: String = Audio.music.current_id() if Audio.music != null else ""
	var row: Array = _levels.get(id, [0.0, 0.0, 0]) as Array
	for frame: Vector2 in frames:
		var peak: float = maxf(absf(frame.x), absf(frame.y))
		row[0] = maxf(float(row[0]), peak)
		row[1] = float(row[1]) + (frame.x * frame.x + frame.y * frame.y) * 0.5
		row[2] = int(row[2]) + 1
	_overall_peak = maxf(_overall_peak, float(row[0]))
	_levels[id] = row


# ---- Helpers ------------------------------------------------------------------------------


func _frames(count: int) -> void:
	for step: int in range(count):
		await get_tree().process_frame


func _seconds(duration: float) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout


func _scene(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await _frames(5)
		elapsed += 5.0 / 60.0
	return null


## Waits up to `limit` seconds for the music manager to report `id`.
func _expect(label: String, id: String, limit: float) -> void:
	var elapsed: float = 0.0
	while Audio.music.current_id() != id and elapsed < limit:
		await _seconds(0.1)
		elapsed += 0.1
	_check(Audio.music.current_id() == id, "%s plays %s (is '%s')" % [label, id, Audio.music.current_id()])


## Samples the total mixer level over `duration` seconds (a crossfade) and records the biggest frame-to-frame jump.
func _watch_fade(duration: float) -> void:
	var previous: float = NAN
	var elapsed: float = 0.0
	var worst: float = 0.0
	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var power: float = 0.0
		for voice: Dictionary in Audio.music.voices():
			power += pow(10.0, float(voice["level_db"]) / 10.0)
		var total: float = 10.0 * log(maxf(power, 1e-12)) / log(10.0)
		if not is_nan(previous) and previous > -60.0 and total > -60.0:
			worst = maxf(worst, absf(total - previous))
		previous = total
	_worst_step_db = maxf(_worst_step_db, worst)
	_check(worst < SMOOTH_STEP_DB, "the crossfade is smooth (largest frame-to-frame level change %.2f dB)" % worst)


func _count_events(prefix: String) -> int:
	var count: int = 0
	for line: String in Audio.music.event_log():
		if line.contains(" " + prefix):
			count += 1
	return count


func _has_event(text: String) -> bool:
	for line: String in Audio.music.event_log():
		if line.contains(text):
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if condition:
		print("music_smoke: ok    ", message)
	else:
		_failures.append(message)
		print("music_smoke: FAIL  ", message)
		push_error("music_smoke: " + message)


func _finish(reason: String) -> void:
	print("music_smoke: mixer output (Master bus, default volumes), per cue: peak dBFS / RMS dBFS")
	var ids: Array = _levels.keys()
	ids.sort()
	for id: Variant in ids:
		var row: Array = _levels[id] as Array
		var samples: int = int(row[2])
		if samples < 4800:
			continue
		var rms: float = sqrt(float(row[1]) / float(samples))
		print("music_smoke:   %-26s peak %6.1f  rms %6.1f" % [str(id), linear_to_db(maxf(float(row[0]), 1e-6)), linear_to_db(maxf(rms, 1e-6))])
	_check(_overall_peak < 1.0, "the mixer output never clips (peak %.1f dBFS)" % linear_to_db(maxf(_overall_peak, 1e-6)))
	print("music_smoke: events:")
	for line: String in Audio.music.event_log():
		print("music_smoke:   ", line)
	var ok: bool = _failures.is_empty()
	print("music_smoke: %s - %s (worst crossfade step %.2f dB)" % ["OK" if ok else "FAILED", reason, _worst_step_db])
	get_tree().quit(0 if ok else 1)
