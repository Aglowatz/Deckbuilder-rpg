extends GutTest
## Fable big pass Nov 23 (Part 3): the draft screens. Trey Pickett's cart offers only its zone's draft; the pick screen, the deck
## builder (any number of the drafted cards, the Infrastructure steppers, the 35-card minimum), the next-opponent reveal with the
## rival's equipment as battle effects, and the Shuffle House's menu.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	Session.draft = null
	Session.pending_draft_result = {}


func after_each() -> void:
	Session.draft = null
	Session.pending_draft_result = {}


func _open(zone: String) -> OverlayScreen:
	var screen: OverlayScreen = DraftHubScreen.for_state(zone, {})
	add_child_autofree(screen)
	await get_tree().process_frame
	return screen


func _draft_to(phase: String, challenge: String = "zone:beefcake") -> void:
	assert_true(Session.start_draft(challenge, [int(Affinity.Type.BEEFCAKE)] as Array[int]), "the draft starts")
	if phase == DraftState.PHASE_PICK:
		return
	var guard: int = 0
	while Session.draft.phase == DraftState.PHASE_PICK and guard < 100:
		Session.draft_pick(guard % 3)
		guard += 1
	if phase == DraftState.PHASE_RUN:
		assert_true(Session.draft_begin_run())


func test_treys_cart_offers_only_its_zones_draft_on_his_backdrop() -> void:
	var screen: OverlayScreen = await _open("beefcake")
	assert_true(screen is DraftHubScreen)
	var backdrop: Control = screen.find_child("Backdrop", true, false) as Control
	assert_not_null(backdrop, "the cart's picture (VS-TREY) is behind the menu")
	if backdrop != null:
		assert_not_null((backdrop.get_child(0) as TextureRect).texture)
		assert_gt(backdrop.size.x, 100.0, "and it fills the screen")
	assert_not_null(screen.find_child("Challenge_zone_beefcake", true, false), "this zone's draft")
	assert_null(screen.find_child("Challenge_open", true, false), "no Open Draft at the cart")
	assert_null(screen.find_child("PathChoice", true, false), "choosing Paths happens at the Shuffle House")
	assert_not_null(screen.find_child("ShuffleHouseNote", true, false), "the menu says how the Shuffle House opens and when more Paths do")
	var pay: Label = screen.find_child("RewardLine", true, false) as Label
	assert_true(pay.text.contains("Entry: free"), "entry is free")
	var portrait: TextureRect = screen.find_child("HostPortrait", true, false) as TextureRect
	assert_not_null(portrait.texture, "Trey himself, in his own portrait")


func test_the_pick_screen_has_three_options_the_reroll_and_the_side_panel() -> void:
	_draft_to(DraftState.PHASE_PICK)
	var screen: OverlayScreen = await _open("beefcake")
	assert_true(screen is DraftScreen)
	assert_not_null(screen.find_child("Baize", true, false), "the baize of the mock-up")
	var options: Node = screen.find_child("Options", true, false)
	assert_eq(options.get_child_count(), 3)
	var first: Button = screen.find_child("Card0", true, false) as Button
	assert_gt(float(first.get_meta(&"zoom_height", 0.0)), CardHoverZoom.TARGET_HEIGHT, "an offered card grows further on hover than elsewhere")
	assert_gte(first.custom_minimum_size.y, 540.0, "and is large to begin with")
	var reroll: Button = screen.find_child("Reroll", true, false) as Button
	assert_not_null(reroll.icon, "the reroll icon (ICON-UI-REROLL)")
	for part: String in ["CostCurve", "PathSplit", "EquipmentSlots", "ItemSlots", "NextUp"]:
		assert_not_null(screen.find_child(part, true, false), part)
	assert_eq(screen.find_child("EquipmentSlots", true, false).get_child_count(), 5)
	assert_eq(screen.find_child("ItemSlots", true, false).get_child_count(), 2)
	first.pressed.emit()
	await get_tree().process_frame
	assert_eq(Session.draft.cards.size(), 1, "clicking the card itself takes it")


func test_the_deck_builder_plays_any_number_of_the_picks_and_sets_each_basic() -> void:
	_draft_to(DraftState.PHASE_DECK)
	var screen: OverlayScreen = await _open("beefcake")
	assert_true(screen is DraftScreen)
	for part: String in ["DeckGrid", "DeckPanel", "RuleChecks", "CostCurve", "DeckStats", "DeckList", "LockDeck", "SuggestDeck"]:
		assert_not_null(screen.find_child(part, true, false), part)
	assert_eq(screen.find_child("DeckGrid", true, false).get_child_count(), 25, "every drafted card is on the left")
	var draft: DraftState = Session.draft
	assert_eq(DraftEngine.deck_size(draft), 35, "the suggested deck: 20 picks and 15 basics")
	# bring every benched card back: all 25 may be played
	for index: int in draft.bench.duplicate():
		assert_true(Session.draft_toggle_card(index))
	assert_eq(draft.bench.size(), 0)
	assert_eq(DraftEngine.deck_size(draft), 40)
	assert_true(DraftEngine.deck_ready(draft), "25 drafted cards and 15 basics is a legal deck")
	# the Infrastructure stepper
	var path: int = int(Affinity.Type.BEEFCAKE)
	assert_true(Session.draft_add_basic(path, -3))
	assert_eq(int(draft.basics[path]), 12)
	assert_true(DraftEngine.deck_ready(draft), "37 cards")
	assert_true(Session.draft_add_basic(path, -3))
	assert_false(DraftEngine.deck_ready(draft), "34 cards: one short of the minimum")
	assert_false(DraftEngine.deck_problem(draft).is_empty())
	(screen as DraftScreen)._refresh()
	await get_tree().process_frame
	assert_true((screen.find_child("LockDeck", true, false) as Button).disabled, "a short deck cannot be locked")
	assert_not_null(screen.find_child("DeckProblem", true, false), "and the panel says why")
	assert_true(Session.draft_add_basic(path, 1))
	assert_true(DraftEngine.deck_ready(draft), "35 again")
	assert_false(Session.draft_add_basic(path, 100) and int(draft.basics[path]) > DraftRules.deck_max_basics(), "never more basics than the cap")
	assert_lte(int(draft.basics[path]), DraftRules.deck_max_basics())


func test_the_reveal_shows_the_next_opponent_large_with_their_equipment_as_battle_effects() -> void:
	_draft_to(DraftState.PHASE_RUN)
	var screen: OverlayScreen = await _open("beefcake")
	assert_true(screen is DraftHubScreen, "the run is the hub's")
	var rival: Dictionary = DraftRun.next_rival(Session.draft)
	var portrait: TextureRect = screen.find_child("OpponentPortrait", true, false) as TextureRect
	assert_not_null(portrait.texture, "the opponent, large in the middle")
	assert_eq((screen.find_child("OpponentName", true, false) as Label).text, str(rival["name"]))
	var gear: Node = screen.find_child("RivalGear", true, false)
	assert_eq(gear.get_child_count(), (rival["equipment"] as Array).size(), "one battle effect per piece the rival wears")
	assert_not_null(screen.find_child("Fight", true, false))
	assert_not_null(screen.find_child("ReviewDeck", true, false))
	assert_not_null(screen.find_child("YourDeck", true, false))
	# the same pieces ride into the fight as badges under the rival's name
	var context: BattleContext = Session.make_draft_battle()
	var enemy_badges: int = 0
	for badge: RuleBadges.Badge in context.rule_badges:
		enemy_badges += 1 if badge.side == RuleBadges.SIDE_ENEMY else 0
	assert_eq(enemy_badges, (rival["equipment"] as Array).size())
	assert_eq(context.board_key, "draft", "on the house table")


func test_the_shuffle_house_menu_has_every_table_and_locks_by_the_story() -> void:
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))
	var screen: OverlayScreen = await _open("")
	assert_true(screen is DraftHubScreen)
	assert_eq(screen.find_child("Tiles", true, false).get_child_count(), 15, "the Open Draft, six pairs, three and four Paths, three win-three tables, the Halls, Mystery Mini, the dungeon drafts")
	assert_not_null((screen.find_child("HostPortrait", true, false) as TextureRect).texture, "Octavia Eightfold")
	var pair_tile: Button = screen.find_child("Tile_pair_1_2", true, false) as Button
	assert_not_null(pair_tile)
	assert_not_null(pair_tile.find_child("State", true, false), "a two-Path table is locked before any zone is freed")
	assert_true((screen.find_child("PathsRule", true, false) as Label).text.contains("first zone is freed"), "and the menu says when it opens")
	# choosing it explains the lock and disables Start
	pair_tile.pressed.emit()
	await get_tree().process_frame
	assert_true((screen.find_child("Start", true, false) as Button).disabled)
	assert_not_null(screen.find_child("Notice", true, false))
	# the Open Draft: one Path for now
	(screen.find_child("Tile_open", true, false) as Button).pressed.emit()
	await get_tree().process_frame
	assert_not_null(screen.find_child("PathChoice", true, false), "the Open Draft lets you choose your Path here")
	assert_false((screen.find_child("Start", true, false) as Button).disabled)
