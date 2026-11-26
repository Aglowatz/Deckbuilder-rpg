extends CardTestBase
## Nov 25 night (Part A): the owner's quick fixes.
##   A.1 The "Before the fight" panel says "These rules are in play:" (centred) and no longer "The same icons stay on screen ...".
##   A.2 Every way out of the Shuffle House puts the hero on its doorstep, facing out (not in front of Crosspath's fountain).
##   A.3 Membership Cancellation costs 1 less and destroys a tool or a wonder; Resting In Peace Clause shuffles 5 Clauses;
##       Counterweight deals 5.


func _sheet_row(id: String) -> PackedStringArray:
	var file: FileAccess = FileAccess.open("res://data/source/card_list.csv", FileAccess.READ)
	while file != null and not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() > 14 and row[14] == id:
			return row
	return PackedStringArray()


func _badge(rule_name: String) -> RuleBadges.Badge:
	var badge: RuleBadges.Badge = RuleBadges.Badge.new()
	badge.name = rule_name
	badge.text = "It does a thing."
	badge.kind = "encounter"
	return badge


# ---- A.1 ---------------------------------------------------------------------------------------------------------------------------


func test_the_panel_says_these_rules_are_in_play_centred() -> void:
	var badges: Array[RuleBadges.Badge] = [_badge("Specimen Conditions"), _badge("Enhanced Specimens")]
	assert_eq(RulesBrief.note_text(badges), "These rules are in play:")
	var holder: Control = Control.new()
	add_child_autofree(holder)
	var brief: RulesBrief = RulesBrief.open(holder, badges, "Before the fight: Escaped Specimen", func() -> void: pass, false)
	var note: Label = brief.find_child("BriefNote", true, false) as Label
	assert_not_null(note)
	assert_eq(note.text.replace(char(0xA0), " ").strip_edges(), "These rules are in play:")
	assert_eq(note.horizontal_alignment, HORIZONTAL_ALIGNMENT_CENTER, "centred")
	for path: String in ["res://ui/widgets/rules_brief.gd", "res://ui/dungeon/node_card.gd", "res://ui/dungeon/dungeon_map_screen.gd", "res://world/zone/zone_scene.gd"]:
		assert_false(FileAccess.get_file_as_string(path).contains("same icons stay on screen during the fight"), "%s no longer says it" % path)


# ---- A.2 ---------------------------------------------------------------------------------------------------------------------------


func test_the_doorstep_is_in_front_of_the_steps_and_faces_out() -> void:
	var spot: Vector3 = TownShuffleHouse.exit_spot()
	assert_gt(spot.z, TownShuffleHouse.door_spot().z, "a step out from the door, on the path side")
	assert_true(TownShuffleHouse.in_forecourt(spot), "in the house's forecourt")
	assert_gt(spot.distance_to(TownLayout.PLAZA), 20.0, "not by the fountain")
	var obstacles: Array[Vector3] = []
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	TownShuffleHouse.build(root, obstacles)
	for circle: Vector3 in obstacles:
		assert_gt(Vector2(circle.x, circle.y).distance_to(Vector2(spot.x, spot.z)), circle.z + 0.3, "the doorstep is free to stand on")
	var out: Vector3 = TownShuffleHouse.exit_facing() - spot
	assert_gt(out.z, 0.0, "facing away from the house")


func test_every_way_out_of_a_house_draft_arrives_at_the_door() -> void:
	Session.arrive_at_shuffle_house = false
	Session._back_to_shuffle_house("open")
	assert_true(Session.arrive_at_shuffle_house, "a Classic Draft")
	for challenge: String in ["high", "halls", "mystery", "dungeon"]:
		Session.arrive_at_shuffle_house = false
		Session._back_to_shuffle_house(challenge)
		assert_true(Session.arrive_at_shuffle_house, challenge)
	Session.arrive_at_shuffle_house = false
	Session._back_to_shuffle_house("zone:" + DraftChallenges.ZONES[0])
	assert_false(Session.arrive_at_shuffle_house, "Trey's zone drafts go back to their zone")
	Session.arrive_at_shuffle_house = false
	var source: String = FileAccess.get_file_as_string("res://app/game_session.gd")
	for fn: String in ["func _complete_draft_battle", "func _complete_draft_dungeon_battle", "func finish_draft_dungeon", "func finish_draft_cash_out"]:
		var start: int = source.find(fn)
		assert_gt(start, -1, fn)
		var body: String = source.substr(start, source.find("\nfunc ", start + 5) - start)
		assert_true(body.contains("_back_to_shuffle_house("), "%s sends the hero to the house's door" % fn)
	var town: String = FileAccess.get_file_as_string("res://world/town_scene.gd")
	assert_true(town.contains("if Session.arrive_at_shuffle_house:"), "the town reads it on arrival")
	assert_true(town.contains("_step_out_of_shuffle_house()"), "and when the house's screens close or a parked town comes back")


# ---- A.3 ---------------------------------------------------------------------------------------------------------------------------


func test_membership_cancellation_is_cheaper_and_destroys_a_tool_or_a_wonder() -> void:
	var card: CardData = CardSet.card("NB-06")
	assert_eq(card.rules_text, "Destroy target tool or wonder.")
	assert_eq(_sheet_row("NB-06")[3], "1(N)(B)")
	assert_eq(card.energy_value(), 3, "1, a Necrocrat and a Beefcake energy (it was 2 and both)")
	var game: GameState = _game()
	_energy(game)
	var wonder: CardInstance = _field(game, 1, "R-11")
	var hp: int = game.players[1].hp
	_play(game, "NB-06", [wonder.uid] as Array[int])
	assert_false(game.players[1].field.has(wonder), "a wonder is destroyed")
	assert_eq(game.players[1].hp, hp, "no HP loss any more")
	var tool: CardInstance = _field(game, 1, "R-17")
	_play(game, "NB-06", [tool.uid] as Array[int])
	assert_false(game.players[1].field.has(tool), "a tool still is")


func test_resting_in_peace_clause_and_counterweight_hit_harder() -> void:
	assert_string_contains(CardSet.card("N-19").rules_text, "Shuffle 5 Clause tokens")
	assert_true(CardSet.card("N-19").script_text.contains("shuffle_into(opp,T-12,5)"))
	assert_eq(CardSet.card("B-19").rules_text, "When an opposing unit attacks, deal 5 damage to it.")
	assert_true(CardSet.card("B-19").script_text.contains("damage(trig,5)"))
	var game: GameState = _game()
	_energy(game)
	var before: int = game.players[1].deck.size()
	_play(game, "N-19")
	assert_eq(game.players[1].deck.size() - before, 5, "five Clauses go into the opponent's deck")
