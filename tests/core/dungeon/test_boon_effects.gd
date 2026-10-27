extends GutTest
## Fixes Oct 27, Part 4: every boon and curse says what it does (BoonText, never the old "A boon: it fights on your side."), and does it: Cut the Line
## (the D.N.A.'s "Skip the queue") gives your units +1 attack in every fight of that run and is gone in the next run; every boon and curse of
## data/dungeons/dungeon_content.json changes exactly the numbers its text names.

const PLACEHOLDER: String = "A boon: it fights on your side."
const CONTENT: String = "res://data/dungeons/dungeon_content.json"


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)


func after_each() -> void:
	Session.save_enabled = true


## Every "boon:..." / "curse:..." token in the dungeon content file.
func _tokens() -> Array[String]:
	var result: Array[String] = []
	var text: String = FileAccess.get_file_as_string(CONTENT)
	var pattern: RegEx = RegEx.create_from_string("\"((?:boon|curse):[^\"]+)\"")
	for found: RegExMatch in pattern.search_all(text):
		result.append(found.get_string(1))
	return result


## The boons built in code (rescues, markers, Primm's castle, the freed leaders).
func _code_boons() -> Array[ModifierSource]:
	var result: Array[ModifierSource] = [HouseOfGainsDungeon.heartlift_boon(), PathologyLab.rescuer_boon(), RotheartDungeon.severed_boon()] as Array[ModifierSource]
	for zone_id: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		result.append(PrimmBoss.leader_boon(zone_id))
	for key: String in MainDungeons.ids():
		var def: MainDungeonDef = MainDungeons.def(key)
		for event: Variant in def.events.values():
			for choice: DungeonEvent.Choice in (event as DungeonEvent).choices:
				for outcome: DungeonEvent.Outcome in choice.outcomes:
					if outcome.kind == DungeonEvent.OutcomeKind.BOON and outcome.boon != null:
						result.append(outcome.boon)
	return result


func _unit_attack_and_defense(game: GameState) -> Vector2i:
	var unit: CardInstance = game.create_token(0, CardBuilder.token("boon_probe", "Probe", 2, 3))
	return Vector2i(game.get_attack(unit), game.get_defense(unit))


func _enemy() -> PlayerSetup:
	return PlayerSetup.create(GameFactory.make_deck())


func test_no_badge_falls_back_to_the_placeholder() -> void:
	var sources: Array[ModifierSource] = []
	for token: String in _tokens():
		sources.append(DungeonBuilder.boon_from(token.split(":", true, 1)[1]))
	sources.append_array(_code_boons())
	assert_gt(sources.size(), 25)
	for badge: RuleBadges.Badge in RuleBadges.for_boons(sources):
		assert_ne(badge.text, PLACEHOLDER, "%s still says the placeholder" % badge.name)
		assert_false(badge.text.strip_edges().is_empty(), badge.name)
		assert_eq(badge.side, RuleBadges.SIDE_PLAYER)
	var cut: RuleBadges.Badge = RuleBadges.for_boons([DungeonBuilder.boon_from("Cut the Line|atk=1")] as Array[ModifierSource])[0]
	assert_eq(cut.tooltip(), "Your units get +1 attack for the rest of this run.\n\nApplies to you only.")


func test_each_token_reads_its_own_numbers_and_curses_are_curses() -> void:
	for token: String in _tokens():
		var spec: String = token.split(":", true, 1)[1]
		var source: ModifierSource = DungeonBuilder.boon_from(spec)
		var text: String = BoonText.describe(source)
		assert_eq(BoonText.is_curse(source), token.begins_with("curse:"), token)
		for pair: String in spec.split("|")[1].split(","):
			var kv: PackedStringArray = pair.split("=")
			var value: int = int(kv[1])
			var signed: String = ("+%d" % value) if value > 0 else str(value)
			var words: String = {"max_hp": "max HP", "atk": "attack", "def": "defense", "start_hp": "HP at the start of each fight"}[kv[0]]
			assert_true(text.contains("%s %s" % [signed, words]), "%s -> %s" % [token, text])


func test_cut_the_line_raises_attack_in_every_fight_of_the_run_and_ends_with_it() -> void:
	var found: DungeonEvent = null
	var index: int = -1
	for key: String in MainDungeons.ids():
		for event: Variant in MainDungeons.def(key).events.values():
			var choices: Array[DungeonEvent.Choice] = (event as DungeonEvent).choices
			for i: int in range(choices.size()):
				for outcome: DungeonEvent.Outcome in choices[i].outcomes:
					if outcome.kind == DungeonEvent.OutcomeKind.BOON and outcome.boon != null and outcome.boon.source_name == "Cut the Line":
						found = event as DungeonEvent
						index = i
	assert_not_null(found, "the D.N.A.'s Skip the queue event offers Cut the Line")
	if found == null:
		return
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	var base: Vector2i = _unit_attack_and_defense(run.start_encounter(_enemy()))
	var result: EventResolver.Result = EventResolver.resolve(found, index, run, Session.content, 100)
	assert_eq(result.boons.size(), 1)
	for fight: int in range(3):
		var game: GameState = run.start_encounter(_enemy())
		var stats: Vector2i = _unit_attack_and_defense(game)
		assert_eq(stats.x, base.x + 1, "fight %d: +1 attack" % (fight + 1))
		assert_eq(stats.y, base.y, "fight %d: defense unchanged" % (fight + 1))
		game._end_game(0, false)
		run.finish_encounter(game)
	var next_run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	assert_eq(_unit_attack_and_defense(next_run.start_encounter(_enemy())), base, "the next run starts without it")


func test_every_content_boon_and_curse_does_what_it_says() -> void:
	for token: String in _tokens():
		var spec: String = token.split(":", true, 1)[1]
		var stats: Dictionary = {}
		for pair: String in spec.split("|")[1].split(","):
			var kv: PackedStringArray = pair.split("=")
			stats[kv[0]] = int(kv[1])
		var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
		var max_before: int = run.max_hp()
		var hp_before: int = run.hp
		var base: Vector2i = _unit_attack_and_defense(run.start_encounter(_enemy()))
		run.add_dungeon_source(DungeonBuilder.boon_from(spec))
		var max_change: int = int(stats.get("max_hp", 0))
		assert_eq(run.max_hp(), max_before + max_change, "%s: max HP" % token)
		assert_eq(run.hp, mini(hp_before + maxi(max_change, 0), run.max_hp()), "%s: current HP follows (a curse takes what is above the new max)" % token)
		var game: GameState = run.start_encounter(_enemy())
		assert_eq(game.players[0].max_hp, max_before + max_change, "%s: the fight's max HP" % token)
		assert_eq(game.players[0].hp, run.hp + int(stats.get("start_hp", 0)), "%s: the fight's starting HP" % token)
		var now: Vector2i = _unit_attack_and_defense(game)
		assert_eq(now.x, base.x + int(stats.get("atk", 0)), "%s: unit attack" % token)
		assert_eq(now.y, base.y + int(stats.get("def", 0)), "%s: unit defense" % token)


func test_a_start_of_fight_boon_adds_hp_each_fight_without_piling_up() -> void:
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	run.add_dungeon_source(MainDungeonDef.boon_source("Unreflected", [CardBuilder.modifier(Modifier.Kind.STARTING_HP, 2)] as Array[Modifier]))
	for fight: int in range(3):
		var game: GameState = run.start_encounter(_enemy())
		assert_eq(game.players[0].hp, run.max_hp() + 2, "fight %d starts 2 above the carried HP" % (fight + 1))
		game._end_game(0, false)
		run.finish_encounter(game)
		assert_eq(run.hp, run.max_hp(), "the bonus is spent in that fight only")
