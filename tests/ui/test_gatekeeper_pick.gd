extends GutTest
## Fixes Oct 27, Part 1: the card pick after each zone gatekeeper (Brick Bronson, Prudence Pallor, Moss Mulligan, Chef Fennel Gravois) - the
## offer is never short, each card takes a mouse click (the card art no longer swallows it), a key and the pad, Skip still works, and the
## dungeon's elite / boss pick screen does the same.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.pending_popups.clear()


func after_each() -> void:
	Session.pending_popups.clear()
	Session.pending_reward = null
	Session.save_enabled = true


## A won gatekeeper fight, as the battle screen hands it to `complete_battle`.
func _won(npc_id: String) -> BattleContext:
	var context: BattleContext = Session.make_npc_challenge_battle(npc_id)
	context.won = true
	return context


func _pick_box(npc_id: String) -> RewardPopup:
	Session.pending_popups.clear()
	Session.queue_world_pick(_won(npc_id))
	assert_eq(Session.pending_popups.size(), 1, "%s queues a pick" % npc_id)
	if Session.pending_popups.is_empty():
		return null
	var popup: RewardPopup = RewardPopup.make(Session.pending_popups.pop_front() as RewardSummary)
	add_child_autofree(popup)
	return popup


func test_each_gatekeeper_offers_three_cards_of_its_path() -> void:
	for npc_id: String in CorruptedNpcs.IDS:
		var context: BattleContext = _won(npc_id)
		context.enemy_name = "%s (offer test)" % npc_id  # a fresh name: never the smaller repeat pick
		Session.pending_popups.clear()
		Session.queue_world_pick(context)
		var summary: RewardSummary = Session.pending_popups[0] as RewardSummary
		assert_eq(summary.card_choices.size(), RewardPicks.COUNT, "%s offers three" % npc_id)
		for card: CardData in summary.card_choices:
			assert_not_null(card)
			assert_true(RewardPicks.is_pure_path(card, CorruptedNpcs.element(npc_id)), "%s offered %s" % [npc_id, card.id])


func test_a_mouse_click_on_each_gatekeepers_card_picks_and_keeps_it() -> void:
	for npc_id: String in CorruptedNpcs.IDS:
		var popup: RewardPopup = _pick_box(npc_id)
		await wait_process_frames(2)
		var tile: Control = popup.find_child("Pick_1", true, false) as Control
		assert_eq(tile.mouse_filter, Control.MOUSE_FILTER_STOP)
		for view: Node in tile.find_children("*", "CardView", true, false):
			assert_eq((view as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE, "the card does not swallow the click")
		var click: InputEventMouseButton = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		tile.gui_input.emit(click)
		var card: CardData = popup.summary.card_choices[1]
		assert_eq(popup.summary.picked, card, "%s: the click picks the second card" % npc_id)
		var before: int = Session.profile.owned_copies(card.id)
		popup._on_confirmed()
		var after: int = Session.profile.owned_copies(card.id)
		assert_true(after == before + 1 or after == Session.copy_cap(card), "%s: the picked card joins the collection" % npc_id)
		popup.queue_free()


func test_keys_and_the_pad_pick_too() -> void:
	var popup: RewardPopup = _pick_box("necrocrat")
	await wait_process_frames(2)
	assert_false(popup.frame.click_anywhere, "a click beside the cards does not skip the pick")
	assert_eq(popup.frame.pad_first_focus(), popup.frame.button, "keyboard: no card focus, the button")
	var key: InputEventKey = InputEventKey.new()
	key.keycode = KEY_3
	key.pressed = true
	popup._input(key)
	assert_eq(popup.summary.picked, popup.summary.card_choices[2], "3 picks the third card")
	key.keycode = KEY_LEFT
	popup._input(key)
	assert_eq(popup.summary.picked, popup.summary.card_choices[1], "Left steps back")
	# The pad: A on a focused card is the same click (PadClick).
	var tile: Control = popup.find_child("Pick_0", true, false) as Control
	assert_true(tile.is_in_group(PadClick.GROUP))
	PadClick.click(tile)
	assert_eq(popup.summary.picked, popup.summary.card_choices[0], "the pad's A picks the focused card")


func test_skip_takes_nothing() -> void:
	var popup: RewardPopup = _pick_box("refusemancer")
	await wait_process_frames(2)
	assert_eq(popup.frame.button.text, "Skip")
	var owned: Dictionary = {}
	for card: CardData in popup.summary.card_choices:
		owned[card.id] = Session.profile.owned_copies(card.id)
	popup._on_confirmed()
	for card: CardData in popup.summary.card_choices:
		assert_eq(Session.profile.owned_copies(card.id), int(owned[card.id]), "skipping adds no %s" % card.id)


func test_a_pick_closed_by_another_screen_goes_back_to_the_queue() -> void:
	var popup: RewardPopup = _pick_box("gourmand")
	await wait_process_frames(1)
	RewardPopup.requeue_if_unanswered(popup)
	assert_eq(Session.pending_popups.size(), 1, "the unanswered pick is shown again later")
	assert_eq(Session.pending_popups[0], popup.summary)
	RewardPopup.requeue_if_unanswered(popup)
	assert_eq(Session.pending_popups.size(), 1, "only once")


func test_a_short_pool_still_offers_three() -> void:
	# No card is of the "Neutral" Path alone: the Path's pool is empty, so the pick fills from Colorless (never an empty box).
	for seed_value: int in range(1, 6):
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = seed_value
		var picks: Array[CardData] = RewardPicks.choose(Session.content, rng, [] as Array[Affinity.Type], Affinity.Type.BEEFCAKE, 3, false, false, {}, {}, int(Affinity.Type.NEUTRAL))
		assert_eq(picks.size(), RewardPicks.COUNT)
		for card: CardData in picks:
			assert_true(card.paths().is_empty(), "%s is Colorless" % card.id)
			assert_ne(card.rarity, CardEnums.Rarity.LEGENDARY)
	# Every card of a Path at its copy cap: still three (capped cards convert to essence as usual).
	var owned: Dictionary = {}
	var caps: Dictionary = {}
	for card: CardData in Session.content.cards.values():
		owned[card.id] = 9
		caps[card.id] = 1
	var rng2: RandomNumberGenerator = RandomNumberGenerator.new()
	rng2.seed = 3
	assert_eq(RewardPicks.choose(Session.content, rng2, [] as Array[Affinity.Type], Affinity.Type.BEEFCAKE, 3, false, false, owned, caps, int(Affinity.Type.GOURMAND)).size(), RewardPicks.COUNT)


func test_the_dungeon_elite_and_boss_pick_takes_a_click_a_key_and_the_pad() -> void:
	for boss: bool in [false, true]:
		var offer: RewardOffer = RewardOffer.new()
		offer.gold = 10
		offer.enemy_name = "Pick Test Boss" if boss else "Pick Test Elite"
		offer.is_boss = boss
		var context: BattleContext = _won("beefcake")
		context.town_npc_id = ""
		context.enemy_name = offer.enemy_name
		offer.cards = Session.reward_pick(context, boss)
		assert_eq(offer.cards.size(), RewardPicks.COUNT, "a %s pick offers three" % ("boss" if boss else "elite"))
		Session.pending_reward = offer
		var screen: RewardsScreen = (load("res://scenes/rewards.tscn") as PackedScene).instantiate() as RewardsScreen
		add_child_autofree(screen)
		await wait_process_frames(2)
		var key: InputEventKey = InputEventKey.new()
		key.keycode = KEY_2
		key.pressed = true
		screen._input(key)
		assert_eq(screen._selected, 1, "2 picks the second card")
		assert_false(screen._take_button.disabled)
		var click: InputEventMouseButton = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		screen._cards[0].gui_input.emit(click)
		assert_eq(screen._selected, 0, "a click picks the first")
		PadClick.click(screen._cards[2])
		assert_eq(screen._selected, 2, "the pad's A picks the third")
		screen.queue_free()
		await wait_process_frames(1)
