extends GutTest
## Cards Oct 27, Part 3: every card won, picked or found goes to the collection, never straight into the deck - except in the
## Forgotten Cave's first run (the tutorial), whose picks build the starting deck. The Deck Station's "New" badge and the one-time tip.


func before_each() -> void:
	Session.new_game()


func after_all() -> void:
	Session.new_game()


func _pick(card: CardData) -> void:
	var offer: RewardOffer = RewardOffer.new()
	offer.taken = card
	Session.pending_reward = offer
	Session.apply_rewards()


func _event_with_card(card_id: String) -> DungeonEvent:
	var event: DungeonEvent = DungeonEvent.new()
	var choice: DungeonEvent.Choice = DungeonEvent.Choice.new()
	choice.outcomes.append(DungeonEvent.card(card_id))
	event.choices.append(choice)
	return event


func test_the_tutorials_first_run_adds_the_pick_to_the_deck_and_the_collection() -> void:
	Session.choose_starting_path(Affinity.Type.BEEFCAKE)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	assert_true(Session.rewards_go_to_deck(), "the cave's first run")
	var shot_putter: CardData = Session.content.card("B-10")
	var deck_before: int = Session.run.current_deck().size()
	_pick(shot_putter)
	assert_eq(Session.run.current_deck().count_of("B-10"), 1, "joins the run's deck")
	assert_eq(Session.run.current_deck().size(), deck_before + 1)
	assert_eq(Session.owned_count("B-10"), 1, "and the collection")
	assert_false(Session.new_cards.has("B-10"), "no New badge in the tutorial")
	assert_false(Session.take_collection_tip(), "no tip in the tutorial")
	Session.complete_trial()
	assert_eq(Session.deck.count_of("B-10"), 1, "the first clear builds the deck from the run")
	assert_true(Session.profile.intro_dungeon_cleared)


func test_after_the_cave_a_pick_goes_to_the_collection_only() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	assert_false(Session.rewards_go_to_deck())
	var shot_putter: CardData = Session.content.card("B-10")
	var deck_before: int = Session.deck.size()
	var run_before: int = Session.run.current_deck().size()
	_pick(shot_putter)
	assert_eq(Session.owned_count("B-10"), 1, "in the collection")
	assert_eq(Session.run.current_deck().size(), run_before, "not in the run's deck")
	assert_eq(Session.run.current_deck().count_of("B-10"), 0)
	assert_eq(Session.deck.size(), deck_before, "not in the saved deck")
	assert_true(Session.new_cards.has("B-10"), "the Deck Station's New badge")
	assert_true(Session.take_collection_tip(), "the one-time tip fires once")
	assert_false(Session.take_collection_tip(), "and only once")
	assert_true(Session.flag(&"tip_collection_deck"))


func test_a_replay_of_the_cave_leaves_the_deck_alone() -> void:
	Session.ensure_game(Affinity.Type.NECROCRAT)
	var deck_ids: Array[String] = DeckBox.ids_of(Session.deck)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	_pick(Session.content.card("N-16"))
	Session.complete_trial()
	assert_eq(DeckBox.ids_of(Session.deck), deck_ids, "exactly as it was")
	assert_eq(Session.owned_count("N-16"), 1)


func test_events_and_challenges_only_loan_a_card_to_the_deck_in_the_tutorial() -> void:
	Session.ensure_game(Affinity.Type.GOURMAND)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	var result: EventResolver.Result = EventResolver.resolve(_event_with_card("G-04"), 0, Session.run, Session.content, 0, false)
	assert_true(result.ok)
	assert_eq(result.cards.size(), 1, "reported for the collection")
	assert_eq(Session.run.current_deck().count_of("G-04"), 0, "not in the run's deck")
	var loaned: EventResolver.Result = EventResolver.resolve(_event_with_card("G-04"), 0, Session.run, Session.content, 0, true)
	assert_eq(loaned.cards.size(), 1)
	assert_eq(Session.run.current_deck().count_of("G-04"), 1, "the tutorial flag adds it to the run")
	# The Session's event path adds it to the collection either way.
	var via_session: EventResolver.Result = Session.resolve_dungeon_event(_event_with_card("G-05"), 0)
	assert_true(via_session.ok)
	assert_eq(Session.owned_count("G-05"), 1)
	assert_eq(Session.run.current_deck().count_of("G-05"), 0)


func test_new_badges_survive_a_save_and_clear_when_the_station_closes() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.add_cards([Session.content.card("B-10")] as Array[CardData])
	assert_true(Session.new_cards.has("B-10"))
	var data: Dictionary = Session.to_dict()
	Session.new_game()
	assert_true(Session.from_dict(data))
	assert_true(Session.new_cards.has("B-10"), "saved")
	Session.mark_new_cards_viewed()
	assert_true(Session.new_cards.is_empty())
	# An old save without the key loads with no badges.
	data.erase("new_cards")
	Session.new_game()
	assert_true(Session.from_dict(data))
	assert_true(Session.new_cards.is_empty())


func test_world_picks_quests_and_chests_never_touch_the_deck() -> void:
	Session.ensure_game(Affinity.Type.REFUSEMANCER)
	var deck_ids: Array[String] = DeckBox.ids_of(Session.deck)
	Session.take_reward_pick(Session.content.card("R-09"))
	Session.grant_chest_reward({"card": "R-07", "gold": 5})
	assert_eq(Session.owned_count("R-09"), 1)
	assert_eq(Session.owned_count("R-07"), 1)
	assert_eq(DeckBox.ids_of(Session.deck), deck_ids)
	assert_true(Session.new_cards.has("R-09") and Session.new_cards.has("R-07"))
