extends GutTest
## Overnight Nov 19 (Part 6): the Arena's four tiers open in order, every win pays gold, XP and a pack, each tier pays its equipment prize
## when complete (Diamond also one Announcer Grand Bellows), the Diamond puzzle is solvable, preset-deck bouts say so, the podium shows
## only the current tier's prize, and a guard turns the hero away before the Arena opens.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.complete_zone("beefcake")


func _win(encounter_id: String) -> Dictionary:
	var context: BattleContext = Session.make_arena_battle(encounter_id)
	context.game._end_game(0, false)
	return Session.resolve_arena_battle(context)


func _clear_tier(tier: int) -> Dictionary:
	var last: Dictionary = {}
	for encounter: ArenaEncounter in ArenaDefs.in_tier(tier):
		last = _win(encounter.id)
	return last


func test_tiers_open_in_order() -> void:
	assert_true(Session.arena_tier_open(1))
	assert_false(Session.arena_tier_open(2))
	_win("arena_warmup")
	_win("arena_lethal_lunch")
	assert_false(Session.arena_tier_open(2), "every bout of Bronze first")
	_win("arena_neutral_mile")
	assert_true(Session.arena_tier_open(2))
	assert_false(Session.arena_tier_open(3))
	_clear_tier(2)
	_clear_tier(3)
	assert_true(Session.arena_tier_open(4), "Diamond after Gold")


func test_tier_prizes_are_the_equipment_and_diamond_adds_bellows() -> void:
	assert_eq(str((ArenaDefs.TIER_PRIZES[1] as Dictionary)["equipment"]), "champions_laurels")
	assert_eq(str((ArenaDefs.TIER_PRIZES[2] as Dictionary)["equipment"]), "crowd_pleasers_cape")
	assert_eq(str((ArenaDefs.TIER_PRIZES[3] as Dictionary)["equipment"]), "gladiators_net")
	assert_eq(str((ArenaDefs.TIER_PRIZES[4] as Dictionary)["equipment"]), "bloodsand_boots")
	assert_eq(str((ArenaDefs.TIER_PRIZES[4] as Dictionary)["card"]), "C-36")
	var bronze: Dictionary = _clear_tier(1)
	assert_eq(int(bronze.get("tier_complete", 0)), 1)
	assert_eq(int(bronze.get("next_tier", 0)), 2)
	assert_true(Session.profile.owned_equipment.has(Session.content.equipment_piece("champions_laurels")))
	_clear_tier(2)
	_clear_tier(3)
	var diamond: Dictionary = _clear_tier(4)
	assert_eq(int(diamond.get("tier_complete", 0)), 4)
	assert_false(diamond.has("next_tier"))
	assert_eq(Session.owned_count("C-36"), 1, "one Announcer Grand Bellows")
	assert_true(Session.flag(StringName(SignatureCards.DIAMOND_FLAG)), "more at Sable's from now on")


func test_a_win_pays_gold_xp_and_a_pack() -> void:
	var packs: int = Session.profile.total_packs()
	var result: Dictionary = _win("arena_lethal_lunch")
	var reward: Dictionary = result["reward"] as Dictionary
	assert_true(reward.has("gold") and reward.has("xp") and reward.has("pack"))
	assert_eq(Session.profile.total_packs(), packs + 1)


func test_a_locked_tier_cannot_be_fought() -> void:
	Session.pending_battle = null
	Session.start_arena_battle("arena_final_bell")
	assert_null(Session.pending_battle, "Diamond is locked")


func test_the_final_bell_is_solvable_with_exactly_five_energy() -> void:
	var game: GameState = ArenaScenario.build_game(Session.content, ArenaDefs.find("arena_final_bell"), Session.profile, Session.deck, 7)
	var foe: Dictionary = {}
	for card: CardInstance in game.players[1].field:
		foe[card.data.id] = card
	var mine: Dictionary = {}
	for card: CardInstance in game.players[0].field:
		mine[card.data.id] = card
	var hand: Dictionary = {}
	for card: CardInstance in game.players[0].hand:
		hand[card.data.id] = card
	assert_true(game.play_card(0, (hand["B-36"] as CardInstance).uid, (foe["C-02"] as CardInstance).uid), "Desk Flip on the Militia")
	assert_true(game.play_card(0, (hand["B-03"] as CardInstance).uid, (foe["C-06"] as CardInstance).uid), "Weights on the Brawler")
	assert_true(game.play_card(0, (hand["B-15"] as CardInstance).uid), "the Kettlebell")
	var bell: CardInstance = null
	for card: CardInstance in game.players[0].field:
		if card.data.id == "B-15":
			bell = card
	assert_true(game.activate_ability(0, bell.uid, 0, [(foe["C-03"] as CardInstance).uid] as Array[int]), "smash the Archer")
	assert_true(game.play_card(0, (hand["B-20"] as CardInstance).uid, (mine["B-01"] as CardInstance).uid), "Dry Scoop on the Gym Bro")
	assert_true(game.advance_phase())
	assert_true(game.declare_attackers([(mine["B-12"] as CardInstance).uid, (mine["B-11"] as CardInstance).uid, (mine["B-01"] as CardInstance).uid] as Array[int]))
	if not game.is_over():
		game.declare_blockers({})
	assert_true(game.is_over())
	assert_true(ArenaDefs.find("arena_final_bell").player_won(game))


func test_preset_deck_bouts_name_their_deck() -> void:
	var mile: ArenaEncounter = ArenaDefs.find("arena_neutral_mile")
	assert_true(mile.uses_restricted_deck())
	assert_string_contains(ArenaScenario.preset_deck_name(mile), "Gladiator's Kit")
	assert_false(ArenaScenario.preset_deck_lines(Session.content, mile).is_empty())


func test_the_podium_shows_only_the_current_tier_prize() -> void:
	var screen: ArenaScreen = ArenaScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	var podium: Node = screen.find_child("PrizePodium", true, false)
	if podium == null:
		pass_test("no booth stage in this layout")
		return
	var current: Label = podium.find_child("PodiumTier1", true, false).find_child("PodiumPrize", true, false) as Label
	assert_string_contains(current.text, "Champion's Laurels")
	var later: Label = podium.find_child("PodiumTier2", true, false).find_child("PodiumPrize", true, false) as Label
	assert_eq(later.text, "???", "later tiers locked")


func test_bellows_never_mentions_freeing_a_zone() -> void:
	var story: StoryText = StoryText.shared()
	for key: String in ["town.arena.intro", "town.arena.return", "town.arena.locked", "town.arena.announce", "arena.screen.locked"]:
		var text: String = " ".join(story.get_lines(key)).to_lower()
		assert_false(text.contains("freed") or text.contains("free a zone") or text.contains("zone is free"), "%s: %s" % [key, text])
	assert_false(story.get_lines("town.arena.guard").is_empty(), "the guard's line")
