extends GutTest
## The audio registry (docs/audio/music_integration.md): every catalogue ID has an entry with a loadable file, aliases play their target, loops loop,
## levels are evened and never clip.


func before_each() -> void:
	AudioRegistry.reload()


func test_every_catalogue_row_has_an_entry_and_a_file() -> void:
	var sheet: Dictionary = AudioRegistry.catalogue()
	var order: Array = sheet["order"] as Array
	assert_gt(order.size(), 140, "the catalogue lists 144 cues")
	var missing: Array[String] = []
	for id: Variant in order:
		var entry: AudioRegistry.Entry = AudioRegistry.entry(str(id))
		if entry == null or not AudioRegistry.is_playable(str(id)):
			missing.append(str(id))
	assert_eq(missing, [] as Array[String], "every ID resolves to a loadable file")


func test_aliases_play_the_file_of_their_target() -> void:
	for pair: Array in [["MUS-VAULT-BOSS", "MUS-VAULT-BATTLE"]]:
		var alias: AudioRegistry.Entry = AudioRegistry.entry(str(pair[0]))
		assert_not_null(alias, str(pair[0]))
		assert_eq(alias.alias_of, str(pair[1]))
		assert_eq(AudioRegistry.file_for(str(pair[0])), AudioRegistry.file_for(str(pair[1])))


## Music Pass 1 (Oct 31): the Hollow Warden has its own track now, no longer MUS-TUT-BATTLE's file.
func test_tut_boss_plays_its_own_file() -> void:
	var boss: AudioRegistry.Entry = AudioRegistry.entry("MUS-TUT-BOSS")
	assert_not_null(boss)
	assert_eq(boss.alias_of, "")
	assert_eq(AudioRegistry.file_for("MUS-TUT-BOSS"), "res://assets/audio/music/MUS-TUT-BOSS.ogg")
	assert_ne(AudioRegistry.file_for("MUS-TUT-BOSS"), AudioRegistry.file_for("MUS-TUT-BATTLE"))
	assert_true(AudioRegistry.is_playable("MUS-TUT-BOSS"))


## Music Pass 2 (Oct 31): the four side-dungeon bosses have their own tracks now, no longer their battle track's file.
## Music Pass 3 (Oct 31): Dr. Ambrose Siphon and Captain Spotless (tunnels) too.
func test_side_dungeon_bosses_play_their_own_files() -> void:
	for pair: Array in [["MUS-SWOLY-BOSS", "MUS-SWOLY-BATTLE"], ["MUS-OMAKASE-BOSS", "MUS-OMAKASE-BATTLE"], ["MUS-WAIT-BOSS", "MUS-WAIT-BATTLE"],
			["MUS-PANDA-BOSS", "MUS-PANDA-BATTLE"], ["MUS-SIPHON-BOSS", "MUS-LAB-BATTLE"], ["MUS-TUNNEL-BOSS", "MUS-TUNNEL-BATTLE"]]:
		var boss: AudioRegistry.Entry = AudioRegistry.entry(str(pair[0]))
		assert_not_null(boss, str(pair[0]))
		assert_eq(boss.alias_of, "", str(pair[0]))
		assert_eq(AudioRegistry.file_for(str(pair[0])), "res://assets/audio/music/%s.ogg" % str(pair[0]))
		assert_ne(AudioRegistry.file_for(str(pair[0])), AudioRegistry.file_for(str(pair[1])))
		assert_true(AudioRegistry.is_playable(str(pair[0])))


func test_loops_loop_and_stings_do_not() -> void:
	assert_true(AudioRegistry.entry("MUS-TOWN").loop)
	assert_false(AudioRegistry.entry("STG-VICTORY").loop)
	assert_false(AudioRegistry.entry("MUS-MEM-01").loop)
	assert_eq(AudioRegistry.entry("STG-VICTORY").kind, AudioRegistry.Kind.STING)
	assert_false(AudioRegistry.entry("MUS-LULLABY").gameplay, "motif masters are references, not triggers")
	assert_false(AudioRegistry.entry("MUS-PRIMM-MOTIF").gameplay)
	var stream: AudioStream = AudioRegistry.stream("MUS-TOWN")
	assert_true(stream is AudioStreamOggVorbis)
	assert_true((stream as AudioStreamOggVorbis).loop)


func test_levels_are_evened_and_never_clip() -> void:
	for id: String in AudioRegistry.ids():
		var entry: AudioRegistry.Entry = AudioRegistry.entry(id)
		assert_between(entry.volume_db, -12.0, 9.0, id)
	assert_almost_eq(AudioRegistry.base_volume_db(AudioRegistry.Kind.LOOP, -21.0, -2.0), 0.5, 0.01)
	assert_almost_eq(AudioRegistry.base_volume_db(AudioRegistry.Kind.STING, -23.0, -4.3), 2.8, 0.01, "the peak ceiling holds a hot sting back")


func test_alias_target_is_read_from_the_notes() -> void:
	assert_eq(AudioRegistry.alias_target({"notes": "Compatibility alias — use MUS-TUT-BATTLE for this dungeon boss", "related": "MUS-TUT-BATTLE"}), "MUS-TUT-BATTLE")
	assert_eq(AudioRegistry.alias_target({"notes": "v03 compatibility alias: reuses MUS-OMAKASE-BATTLE for all Omakase fights.", "related": "MUS-OMAKASE-BATTLE"}), "MUS-OMAKASE-BATTLE")
	assert_eq(AudioRegistry.alias_target({"notes": "v01 draft", "related": "MUS-X"}), "")
