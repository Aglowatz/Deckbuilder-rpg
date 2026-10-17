extends GutTest
## Battle sounds (docs/audio/sound_direction.md, "Battle"): each Path has its own summon and death, each resource and token its own gain and spend,
## cards land by weight, hits by size, and every sound name the code plays has a sound behind it.

const SYNTH_NAMES: Array[String] = ["boing", "ding", "lever_clunk", "pack_chime_epic", "pack_chime_uncommon", "pack_fanfare_legendary", "pack_whoosh", "smoke_bomb", "splash", "vault_grind"]


func _card(type: CardEnums.CardType, cost: int, color: Affinity.Type = Affinity.Type.NEUTRAL) -> CardData:
	var data: CardData = CardData.new()
	data.type = type
	data.generic_cost = cost
	data.color = color
	return data


func test_each_path_has_its_own_summon_and_death() -> void:
	var bank: SfxBank = SfxBank.load_from()
	var summons: Dictionary = {}
	for color: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NEUTRAL]:
		var data: CardData = _card(CardEnums.CardType.UNIT, 3, color)
		var summon: String = str(BattleSounds.summon(data))
		var death: String = str(BattleSounds.death(data))
		assert_true(bank.is_playable(summon), summon)
		assert_true(bank.is_playable(death), death)
		summons[bank.layer_sets(summon)[0]] = true
	assert_eq(summons.size(), 5, "five different first layers: every Path sounds distinct")


func test_cards_land_by_weight_and_type() -> void:
	assert_eq(BattleSounds.play(_card(CardEnums.CardType.UNIT, 1)), &"card_play_cheap")
	assert_eq(BattleSounds.play(_card(CardEnums.CardType.UNIT, 3)), &"card_play")
	assert_eq(BattleSounds.play(_card(CardEnums.CardType.UNIT, 6)), &"card_play_heavy")
	assert_eq(BattleSounds.play(_card(CardEnums.CardType.SPELL, 1)), &"spell_cast")
	assert_eq(BattleSounds.play(_card(CardEnums.CardType.SPELL, 5)), &"spell_cast_big")
	assert_eq(BattleSounds.play(_card(CardEnums.CardType.WONDER, 4)), &"wonder_play")


func test_every_resource_and_token_has_a_gain_and_a_spend() -> void:
	var bank: SfxBank = SfxBank.load_from()
	var seen: Dictionary = {}
	for kind: int in ResourceKind.all_with_tokens():
		for gained: bool in [true, false]:
			var event: String = str(BattleSounds.resource(kind, gained))
			assert_true(bank.is_playable(event), event)
			seen[event] = true
	assert_eq(seen.size(), ResourceKind.all_with_tokens().size() * 2, "each kind sounds different")


func test_hits_by_size() -> void:
	assert_eq(BattleSounds.hit(1, false), &"hit_light")
	assert_eq(BattleSounds.hit(3, false), &"hit_medium")
	assert_eq(BattleSounds.hit(6, false), &"hit_heavy")
	assert_eq(BattleSounds.hit(2, true), &"hit_player")


func test_every_sound_the_code_plays_exists() -> void:
	var bank: SfxBank = SfxBank.load_from()
	var catalog: Dictionary = AudioCatalog.sounds()
	var names: Dictionary = {}
	var regex: RegEx = RegEx.create_from_string("(?:Audio\\.sfx|Audio\\.sfx_at|Audio\\.play|_sfx)\\(&\"([a-z0-9_]+)\"")
	for dir: String in ["res://ui", "res://world", "res://app", "res://scenes"]:
		for path: String in _scripts(dir):
			for found: RegExMatch in regex.search_all(FileAccess.get_file_as_string(path)):
				names[found.get_string(1)] = path
	assert_gt(names.size(), 40, "the scan finds the calls")
	for sound: Variant in names.keys():
		var known: bool = bank.is_playable(str(sound)) or catalog.has(StringName(str(sound))) or SYNTH_NAMES.has(str(sound)) \
			or _sting_names().has(str(sound))
		assert_true(known, "%s (%s) has a sound" % [sound, names[sound]])


func _sting_names() -> Array[String]:
	return ["victory", "defeat", "level_up"]


func _scripts(dir: String) -> Array[String]:
	var result: Array[String] = []
	var access: DirAccess = DirAccess.open(dir)
	if access == null:
		return result
	for file: String in access.get_files():
		if file.ends_with(".gd"):
			result.append(dir.path_join(file))
	for sub: String in access.get_directories():
		result.append_array(_scripts(dir.path_join(sub)))
	return result
