extends GutTest
## The music director and manager (docs/audio/music_integration.md): the game's states map to the right cues, and the manager's stack / resume / duck state
## works (headless: no audio plays, the state is real).

var _manager: MusicManager


func before_each() -> void:
	AudioRegistry.reload()
	_manager = MusicManager.new()
	add_child_autofree(_manager)


func _context(board: String, boss: bool = false) -> BattleContext:
	var context: BattleContext = BattleContext.new()
	context.board_key = board
	context.is_boss = boss
	return context


# ---- Director --------------------------------------------------------------------------------------


func test_town_changes_only_after_all_four_zones() -> void:
	var flags: Dictionary = {}
	assert_eq(MusicDirector.town(flags), "MUS-TOWN")
	for zone_id: String in ["beefcake", "gourmand", "necrocrat"]:
		flags[str(ZoneCompletion.flag_name(zone_id))] = true
	assert_eq(MusicDirector.town(flags), "MUS-TOWN", "partial recovery keeps the base theme")
	flags[str(ZoneCompletion.flag_name("refusemancer"))] = true
	assert_eq(MusicDirector.town(flags), "MUS-TOWN-FREED")


func test_each_zone_follows_its_own_completion_flag() -> void:
	var flags: Dictionary = {str(ZoneCompletion.flag_name("gourmand")): true}
	assert_eq(MusicDirector.zone_area("gourmand", flags), "MUS-GOUR-FREED")
	assert_eq(MusicDirector.zone_area("beefcake", flags), "MUS-BEEF-EXP")
	assert_eq(MusicDirector.zone_area("necrocrat", flags), "MUS-NECRO-EXP")
	assert_eq(MusicDirector.zone_area("refusemancer", flags), "MUS-REF-EXP")


func test_capital_districts_are_broken_until_their_path_is_freed() -> void:
	var flags: Dictionary = {}
	assert_eq(MusicDirector.capital_area("transit", flags, true), "MUS-CAP-BEEF-BROKEN")
	flags[str(ZoneCompletion.flag_name("beefcake"))] = true
	assert_eq(MusicDirector.capital_area("transit", flags, true), "MUS-CAP-BEEF-RESTORED")
	assert_eq(MusicDirector.capital_area("hungry", flags, true), "MUS-CAP-GOUR-BROKEN")
	assert_eq(MusicDirector.capital_area("grave", flags, true), "MUS-CAP-NECRO-BROKEN")
	assert_eq(MusicDirector.capital_area("reek", flags, true), "MUS-CAP-REF-BROKEN")
	assert_eq(MusicDirector.capital_area("crease", flags, false), "MUS-CREASE")
	assert_eq(MusicDirector.capital_area("ward", flags, true), "MUS-CAP-CORRECTION")
	assert_eq(MusicDirector.capital_area("outskirts", flags, false), "MUS-CAP-OUT-EXP")
	assert_eq(MusicDirector.capital_area("perfection", flags, true), "MUS-CAP-FACADE-EXP")
	flags[str(CapitalZone.FLAG_FREED)] = true
	assert_eq(MusicDirector.capital_area("perfection", flags, true), "MUS-CAP-RESTORED")


func test_battles_are_chosen_by_board() -> void:
	assert_eq(MusicDirector.for_battle(_context("town")), "MUS-TOWN-BATTLE")
	assert_eq(MusicDirector.for_battle(_context("graveyard")), "MUS-GRAVE-BATTLE")
	assert_eq(MusicDirector.for_battle(_context("zone:beefcake")), "MUS-BEEF-BATTLE")
	assert_eq(MusicDirector.for_battle(_context("zone:necrocrat")), "MUS-NECRO-BATTLE")
	assert_eq(MusicDirector.for_battle(_context("BB-HOG")), "MUS-BEEF-DUN-BATTLE")
	assert_eq(MusicDirector.for_battle(_context("BB-HOG", true)), "MUS-BEEF-BOSS")
	assert_eq(MusicDirector.for_battle(_context("BB-ROT", true)), "MUS-REF-BOSS")
	assert_eq(MusicDirector.for_battle(_context("BB-S-GOUR", true)), "MUS-OMAKASE-BOSS")
	assert_eq(MusicDirector.for_battle(_context("BB-S-TOWN")), "MUS-VAULT-BATTLE")
	assert_eq(MusicDirector.for_battle(_context("dungeon:hollow", true)), "MUS-TUT-BOSS")
	assert_eq(MusicDirector.for_battle(_context("BB-PC")), "MUS-CASTLE-BATTLE")
	assert_eq(MusicDirector.for_battle(_context("BB-LAB", true)), "MUS-SIPHON-BOSS")
	assert_eq(MusicDirector.for_battle(_context("")), "MUS-TOWN-BATTLE", "an unknown board still gets a fight song")


func test_gate_envoys_use_their_paths_combat_song() -> void:
	for pair: Array in [["beefcake", "MUS-BEEF-BATTLE"], ["gourmand", "MUS-GOUR-BATTLE"], ["necrocrat", "MUS-NECRO-BATTLE"], ["refusemancer", "MUS-REF-BATTLE"]]:
		var envoy: BattleContext = _context("town")
		envoy.town_npc_id = str(pair[0])
		assert_eq(MusicDirector.for_battle(envoy), str(pair[1]))


func test_special_duels_have_their_own_cues() -> void:
	var shiro: BattleContext = _context("town")
	shiro.is_ninja_boss = true
	assert_eq(MusicDirector.for_battle(shiro), "MUS-SHIRO-BOSS")
	var cairn: BattleContext = _context("graveyard")
	cairn.is_graveyard_boss = true
	assert_eq(MusicDirector.for_battle(cairn), "MUS-GRAVE-BATTLE")
	var warden: BattleContext = _context("town")
	warden.is_vault_boss = true
	assert_eq(MusicDirector.for_battle(warden), "MUS-VAULT-BOSS")
	var spotless: BattleContext = _context("capital:out")
	spotless.zone_id = CapitalZone.ID
	spotless.zone_enemy_type = CapitalEnemies.SPOTLESS
	assert_eq(MusicDirector.for_battle(spotless), "MUS-CAP-ENFORCER")
	var wretch: BattleContext = _context("capital:in")
	wretch.zone_id = CapitalZone.ID
	wretch.zone_enemy_type = CapitalEnemies.WRETCH
	assert_eq(MusicDirector.for_battle(wretch), "MUS-CAP-RIFT")
	var tidybot: BattleContext = _context("capital:in")
	tidybot.zone_id = CapitalZone.ID
	tidybot.zone_enemy_type = CapitalEnemies.TIDYBOT
	assert_eq(MusicDirector.for_battle(tidybot), "MUS-CAP-FACADE-BATTLE")
	var outside: BattleContext = _context("capital:out")
	outside.zone_id = CapitalZone.ID
	outside.zone_enemy_type = CapitalEnemies.OFFICER
	assert_eq(MusicDirector.for_battle(outside), "MUS-CAP-ENFORCER")


func test_primm_follows_the_actual_phase() -> void:
	for phase: int in range(PrimmBoss.PHASES):
		var context: BattleContext = _context("boss:final", true)
		context.boss_phase = phase
		assert_eq(MusicDirector.for_battle(context), "MUS-PRIMM-0%d" % (phase + 1))
		assert_eq(String(PrimmBoss.phase(phase).music), "MUS-PRIMM-0%d" % (phase + 1))


func test_vendor_screens_map_to_their_shop_theme() -> void:
	for screen_id: String in ["VS-SABLE", "VS-TONIC", "VS-BEETSWORTH", "VS-THREADWELL", "VS-FENWICK", "VS-ALEMBIC", "VS-FIGSLY", "VS-BENCHLEY", "VS-LEDGERBONE", "VS-MIREPOIX", "VS-GRISTLE", "VS-BELLOWS"]:
		var cue: String = MusicDirector.shop(screen_id)
		assert_true(AudioRegistry.has_id(cue), cue)
	assert_eq(MusicDirector.shop("VS-ALEMBIC", true), "MUS-SHOP-ALEMBIC-POST")
	assert_eq(MusicDirector.shop(""), "")


func test_every_cue_the_director_names_exists() -> void:
	var names: Array[String] = []
	for zone_id: Variant in MusicDirector.PATHS.keys():
		for key: Variant in (MusicDirector.PATHS[zone_id] as Dictionary).keys():
			names.append(str((MusicDirector.PATHS[zone_id] as Dictionary)[key]))
	for dungeon: Variant in MusicDirector.DUNGEONS.keys():
		for key: Variant in (MusicDirector.DUNGEONS[dungeon] as Dictionary).keys():
			names.append(str((MusicDirector.DUNGEONS[dungeon] as Dictionary)[key]))
	for cue: Variant in MusicDirector.BOARD_CUE.values():
		names.append(str(cue))
	for cue: String in names:
		assert_true(AudioRegistry.has_id(cue), cue)


func test_fallback_is_never_empty_for_a_known_scene() -> void:
	assert_eq(MusicDirector.fallback_id("MUS-NOT-A-REAL-BATTLE"), "MUS-TOWN-BATTLE")
	assert_eq(MusicDirector.fallback_id("MUS-NOT-A-REAL-CUE"), "MUS-TOWN")
	assert_ne(MusicDirector.fallback_id("MUS-SHOP-NOBODY"), "")


# ---- Manager ---------------------------------------------------------------------------------------


func test_base_track_does_not_restart_when_asked_again() -> void:
	_manager.set_base("MUS-TOWN")
	var first: int = _manager.event_log().size()
	_manager.set_base("MUS-TOWN")
	assert_eq(_manager.event_log().size(), first)
	assert_eq(_manager.current_id(), "MUS-TOWN")


func test_overrides_stack_and_hand_back() -> void:
	_manager.set_base("MUS-TOWN")
	var shop: int = _manager.push("MUS-SHOP-SABLE")
	assert_eq(_manager.current_id(), "MUS-SHOP-SABLE")
	assert_eq(_manager.push("MUS-SHOP-SABLE"), shop, "opening the same shop again does not stack it")
	var battle: int = _manager.push("MUS-TOWN-BATTLE")
	assert_eq(_manager.current_id(), "MUS-TOWN-BATTLE")
	_manager.pop(battle)
	assert_eq(_manager.current_id(), "MUS-SHOP-SABLE")
	_manager.pop(shop)
	assert_eq(_manager.current_id(), "MUS-TOWN")
	assert_eq(_manager.overlay_ids(), [] as Array[String])


func test_the_base_can_change_under_an_override() -> void:
	_manager.set_base("MUS-TOWN")
	var battle: int = _manager.push("MUS-TOWN-BATTLE")
	_manager.set_base("MUS-BEEF-EXP")
	assert_eq(_manager.current_id(), "MUS-TOWN-BATTLE", "the battle keeps playing")
	_manager.pop(battle)
	assert_eq(_manager.current_id(), "MUS-BEEF-EXP", "and the new area's music is what returns")


func test_popping_an_unknown_token_changes_nothing() -> void:
	_manager.set_base("MUS-TOWN")
	_manager.push("MUS-DECK")
	_manager.pop(9999)
	assert_eq(_manager.current_id(), "MUS-DECK")
	_manager.clear_overlays()
	assert_eq(_manager.current_id(), "MUS-TOWN")


func test_stings_duck_the_music_and_the_dialogue_duck_stacks() -> void:
	assert_true(_manager.sting("STG-VICTORY"))
	assert_eq(_manager.last_sting(), "STG-VICTORY")
	assert_false(_manager.sting("STG-NOT-A-STING"))
	_manager.set_dialogue_duck(1, true)
	_manager.set_dialogue_duck(2, true)
	_manager.set_dialogue_duck(1, false)
	_manager.set_dialogue_duck(2, false)
	assert_eq(_manager.overlay_ids(), [] as Array[String])


func test_crossfade_keeps_its_loudness_and_ends_with_one_voice() -> void:
	_manager.set_base("MUS-TOWN", 0.0)
	_manager.advance(0.05)
	_manager.set_base("MUS-BEEF-EXP", 2.0)
	_manager.advance(0.0)
	_manager.advance(1.0)
	var voices: Array[Dictionary] = _manager.voices()
	assert_eq(voices.size(), 2, "both tracks sound during the fade")
	var power: float = 0.0
	for voice: Dictionary in voices:
		power += pow(sin(float(voice["gain"]) * PI * 0.5), 2.0)
	assert_almost_eq(power, 1.0, 0.05, "equal-power: the sum of the two stays at full loudness")
	_manager.advance(1.2)
	assert_eq(_manager.voices().size(), 1)
	assert_eq(str(_manager.voices()[0]["id"]), "MUS-BEEF-EXP")


func test_the_area_track_resumes_where_it_left_off() -> void:
	_manager.set_base("MUS-BEEF-EXP", 0.0)
	for step: int in range(40):
		_manager.advance(0.25)
	var battle: int = _manager.push("MUS-BEEF-BATTLE", 0.5)
	for step: int in range(8):
		_manager.advance(0.25)
	_manager.pop(battle, 0.5)
	_manager.advance(0.1)
	var resumed: String = ""
	for line: String in _manager.event_log():
		if line.contains("play MUS-BEEF-EXP from"):
			resumed = line
	assert_ne(resumed, "", "the area track came back from a saved position, not from the top")
	assert_true(resumed.contains("from 10."), resumed)


func test_a_story_cue_hands_back_when_it_ends() -> void:
	_manager.set_base("MUS-TOWN", 0.0)
	_manager.advance(0.05)
	_manager.push("MUS-MEM-01", 0.5, true)
	assert_eq(_manager.current_id(), "MUS-MEM-01")
	for step: int in range(70):
		_manager.advance(1.0)
	assert_eq(_manager.current_id(), "MUS-TOWN", "the 64 s memory ended and the town music is back")
	assert_eq(_manager.overlay_ids(), [] as Array[String])


func test_dialogue_ducks_the_music_a_little_and_releases() -> void:
	_manager.set_base("MUS-TOWN", 0.0)
	_manager.advance(0.05)
	_manager.set_dialogue_duck(7, true)
	_manager.advance(0.5)
	assert_almost_eq(_manager.duck_db(), MusicManager.DIALOGUE_DUCK_DB, 0.01)
	assert_lt(MusicManager.DIALOGUE_DUCK_DB, -3.0)
	assert_gt(MusicManager.DIALOGUE_DUCK_DB, -8.0, "slightly, not a mute")
	_manager.set_dialogue_duck(7, false)
	_manager.advance(0.1)
	assert_gt(_manager.duck_db(), MusicManager.DIALOGUE_DUCK_DB, "it eases back rather than snapping")
	_manager.advance(1.0)
	assert_almost_eq(_manager.duck_db(), 0.0, 0.01)
