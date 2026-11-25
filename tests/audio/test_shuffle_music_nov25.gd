extends GutTest
## Fable Nov 25, Part 5 (the owner's decision 6): the Shuffle House's own music. Techno carnival-casino on the house's screens and
## the Shuffled Halls' map (MUS-SHUFFLE-EXP), fast electronic combat music for the fights there (MUS-SHUFFLE-BATTLE), its most
## intense version for Octavia (MUS-SHUFFLE-BOSS). All three are scores of the game's own toolkit (tools/music/scores/).

const IDS: Array[String] = ["MUS-SHUFFLE-EXP", "MUS-SHUFFLE-BATTLE", "MUS-SHUFFLE-BOSS"]


func after_each() -> void:
	Session.draft = null


func test_the_three_tracks_are_in_the_game_as_loops() -> void:
	for id: String in IDS:
		var found: AudioRegistry.Entry = AudioRegistry.entry(id)
		assert_not_null(found, "%s is in the registry" % id)
		if found == null:
			continue
		assert_true(ResourceLoader.exists(found.file), "%s has its file (%s)" % [id, found.file])
		assert_true(found.loop, "%s loops" % id)
		assert_between(found.duration, 100.0, 150.0, "%s is about two minutes" % id)
		assert_true(FileAccess.file_exists("res://tools/music/scores/%s.py" % id), "%s has its score in the toolkit" % id)
	assert_eq(AudioRegistry.entry("MUS-SHUFFLE-EXP").category, "Exploration")
	assert_eq(AudioRegistry.entry("MUS-SHUFFLE-BATTLE").category, "Combat")
	assert_eq(AudioRegistry.entry("MUS-SHUFFLE-BOSS").category, "Boss")


func test_the_halls_and_the_house_play_their_own_music() -> void:
	assert_eq(MusicDirector.dungeon_exploration("D-SHUFFLE"), "MUS-SHUFFLE-EXP", "the Shuffled Halls' map")
	assert_eq(MusicDirector.shuffle_house(), "MUS-SHUFFLE-EXP", "the Shuffle House's screens")
	# nothing borrows the card-game tune or the Arena's cues any more
	var cues: Dictionary = MusicDirector.DUNGEONS["D-SHUFFLE"] as Dictionary
	for key: String in ["exp", "battle", "boss"]:
		assert_true(str(cues[key]).begins_with("MUS-SHUFFLE-"), "the Halls' %s cue is its own" % key)


func _context(boss: bool) -> BattleContext:
	var context: BattleContext = BattleContext.new()
	context.board_key = "draft"
	context.draft = true
	context.is_boss = boss
	return context


func test_fights_on_the_house_table_have_the_electronic_combat_music() -> void:
	assert_eq(Battleboards.board_for("draft"), MusicDirector.SHUFFLE_BOARD)
	# a table fight in the house (no draft state: a Halls fight carries the board itself)
	assert_eq(MusicDirector.for_battle(_context(false)), "MUS-SHUFFLE-BATTLE")
	var halls: BattleContext = BattleContext.new()
	halls.board_key = "BB-SHUFFLE"
	assert_eq(MusicDirector.for_battle(halls), "MUS-SHUFFLE-BATTLE", "a dealer of the Shuffled Halls")
	halls.is_boss = true
	assert_eq(MusicDirector.for_battle(halls), "MUS-SHUFFLE-BOSS", "Octavia at the Big Wheel: the most intense version")
	# Classic and High Rollers
	for challenge: String in [DraftArena.CLASSIC_ID, DraftArena.HIGH_ID, DraftArena.daily_id()]:
		Session.draft = DraftState.new()
		Session.draft.challenge_id = challenge
		assert_eq(MusicDirector.for_battle(_context(false)), "MUS-SHUFFLE-BATTLE", challenge)
	# a zone draft at Trey's cart is played on the same table but is not in the house: it keeps the song it had
	Session.draft = DraftState.new()
	Session.draft.challenge_id = "zone:beefcake"
	var cart: BattleContext = _context(false)
	cart.zone_id = "beefcake"
	assert_false(MusicDirector.for_battle(cart).begins_with("MUS-SHUFFLE"), "a zone draft keeps its zone's battle song")


func test_the_scores_are_original_toolkit_scores() -> void:
	var shared: String = FileAccess.get_file_as_string("res://tools/music/scores/_shuffle.py")
	for idea: String in ["HOUSE_HOOK", "CASINO_TUNE", "DEAL_RIFF"]:
		assert_true(shared.contains(idea), "the %s is written out in the score" % idea)
	assert_true(shared.contains("All of it is original"))
	for id: String in IDS:
		var score: String = FileAccess.get_file_as_string("res://tools/music/scores/%s.py" % id)
		assert_true(score.contains("Original"), "%s says how it was made" % id)
	# the three have their own tempo and key (the bible's rule for a batch)
	var battle: String = FileAccess.get_file_as_string("res://tools/music/scores/MUS-SHUFFLE-BATTLE.py")
	var boss: String = FileAccess.get_file_as_string("res://tools/music/scores/MUS-SHUFFLE-BOSS.py")
	assert_true(battle.contains("bpm=172") and boss.contains("bpm=184"), "the boss track is the faster one")
	assert_true(boss.contains("hot=True"), "and carries the extra layers")
