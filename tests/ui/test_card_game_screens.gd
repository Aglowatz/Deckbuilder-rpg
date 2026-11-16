extends GutTest
## Fable Nov 16b (Part 2): the four zone card minigames on screen - each opens on a one-screen "How to play" (three lines, an example, a
## "?" to bring it back), ends on a win or lose panel with the reward, pays exactly what the game it replaced paid, sits at that game's
## spot in its zone, and can be played with a controller.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.zone_run = null


func _in_zone(zone_id: String) -> void:
	Session.zone_run = ZoneRun.enter(zone_id, Session.profile, Session.deck)


func _open(screen: CardGameScreen, zone_id: String) -> CardGameScreen:
	_in_zone(zone_id)
	screen.zone_id = zone_id
	screen.seed_value = 41
	screen.animate = false
	add_child_autofree(screen)
	await wait_process_frames(3)
	return screen


## The reward the screen's last `game_finished` reported.
func _paid(screen: CardGameScreen) -> Dictionary:
	var parameters: Array = get_signal_parameters(screen, "game_finished")
	return parameters[1] as Dictionary if parameters != null and parameters.size() > 1 else {}


func _screens() -> Dictionary:
	return {"beefcake": RepsCardScreen.new(), "gourmand": OrderCardScreen.new(), "refusemancer": SortCardScreen.new(), "necrocrat": FileCardScreen.new()}


func test_each_zone_opens_its_card_game_at_the_old_game_s_spot() -> void:
	var scenes: Dictionary = {GainlandsScene: [RepsCardScreen, "minigame"], BuffetScene: [OrderCardScreen, "minigame"], HeapScene: [SortCardScreen, "minigame"], DnaScene: [FileCardScreen, "puzzle"]}
	for scene_script: GDScript in scenes.keys():
		var scene: Node = scene_script.new() as Node
		var made: OverlayScreen = scene.call("_make_%s_screen" % str(scenes[scene_script][1])) as OverlayScreen
		assert_true(is_instance_of(made, scenes[scene_script][0]), "%s opens %s" % [scene_script.get_global_name(), (scenes[scene_script][0] as GDScript).get_global_name()])
		made.free()
		scene.free()
	# The card-matching games are untouched: the D.N.A.'s Rec Room game and Dex's table.
	var dna: Node = DnaScene.new()
	var rec_room: OverlayScreen = dna.call("_make_minigame_screen") as OverlayScreen
	assert_true(rec_room is MatchGameScreen, "Kyle's matching game stays")
	rec_room.free()
	dna.free()
	assert_true(FileCardScreen.new().has_signal("solved"), "the terminal's game reports `solved` like the puzzle it replaced")
	assert_eq(str(ZoneDefs.get_def("necrocrat").spot_def("puzzle").get("title", "")), "Mail Room Filing Terminal")


func test_every_game_opens_on_a_how_to_play_that_the_question_mark_reopens() -> void:
	var screens: Dictionary = _screens()
	for zone_id: String in screens.keys():
		var screen: CardGameScreen = await _open(screens[zone_id] as CardGameScreen, zone_id)
		assert_eq(screen.state, "how", "%s opens on How to play" % zone_id)
		assert_true(screen.how_is_open())
		var how: Control = screen.find_child("HowToPlay", true, false) as Control
		assert_eq(screen.how_lines().size(), 3, "%s: three lines" % zone_id)
		for index: int in range(3):
			var line: Label = how.find_child("HowLine%d" % (index + 1), true, false) as Label
			assert_not_null(line)
			assert_lt(line.text.length(), 140, "%s line %d is short" % [zone_id, index + 1])
		var example: Control = how.find_child("Example", true, false) as Control
		assert_gt(example.get_child_count(), 1, "%s: the example shows cards" % zone_id)
		assert_false(example.find_children("*", "CardView", true, false).is_empty(), "%s: the example uses real cards" % zone_id)
		(how.find_child("PlayButton", true, false) as Button).pressed.emit()
		await wait_process_frames(2)
		assert_eq(screen.state, "playing")
		assert_false(screen.how_is_open())
		(screen.find_child("HowToPlayButton", true, false) as Button).pressed.emit()
		await wait_process_frames(2)
		assert_true(screen.how_is_open(), "%s: ? brings it back" % zone_id)
		assert_eq(screen.state, "how", "and the game waits")
		screen.hide_how()
		await wait_process_frames(2)
		assert_eq(screen.state, "playing")
		assert_ne(screen.music_cue(), "", "%s plays its zone's minigame music" % zone_id)
		assert_false(screen.find_child("Table", true, false).find_children("*", "CardView", true, false).is_empty() and not (screen is SortCardScreen), "%s: real cards on the table" % zone_id)
		screen.queue_free()
		await wait_process_frames(2)


func test_reps_pays_what_the_rep_counter_paid() -> void:
	var screen: RepsCardScreen = await _open(RepsCardScreen.new(), "beefcake") as RepsCardScreen
	screen.hide_how()
	var gold: int = Session.gold
	watch_signals(screen)
	await screen.autoplay(8)
	await wait_process_frames(2)
	assert_true(screen.game.is_won())
	var panel: Control = screen.result_panel()
	assert_not_null(panel, "a win panel")
	assert_true(bool(panel.get_meta("won")))
	assert_eq((panel.find_child("Stars", true, false) as Label).text, "★★★")
	assert_true(Session.flag(ZoneDefs.get_def("beefcake").flag_minigame_first))
	var first_gold: int = int(RepGame.STAR_REWARDS[3]["gold"]) * 2 + int(RepGame.FIRST_CLEAR_BONUS["gold"])
	assert_eq(int(_paid(screen)["gold"]), first_gold, "the first win pays the Rep Counter's first-clear reward")
	assert_true(bool(_paid(screen)["first_win"]))
	assert_eq(str(_paid(screen)["item"]), str(RepGame.FIRST_CLEAR_BONUS["item"]))
	assert_gte(Session.gold - gold, first_gold, "and the gold is in the purse (a quest that counts the win may add its own)")
	assert_string_contains((panel.find_child("Reward", true, false) as Label).text, "+%d gold" % first_gold)
	gold = Session.gold
	(panel.find_child("PlayAgain", true, false) as Button).pressed.emit()
	await wait_process_frames(2)
	assert_null(screen.result_panel())
	assert_eq(screen.game.streak, 0, "a new set is dealt")
	await screen.autoplay(8, 1)
	await wait_process_frames(2)
	assert_eq(screen.game.stars(), 2, "one miss: two stars")
	assert_eq(int(_paid(screen)["gold"]), int(RepGame.STAR_REWARDS[2]["gold"]) / 2 + int(RepGame.REPEAT_REWARD["gold"]), "a later win pays the repeat reward")
	assert_false(bool(_paid(screen)["first_win"]))


func test_reps_a_lost_set_pays_nothing() -> void:
	var screen: RepsCardScreen = await _open(RepsCardScreen.new(), "beefcake") as RepsCardScreen
	screen.hide_how()
	var gold: int = Session.gold
	await screen.autoplay(0, 4)
	await wait_process_frames(2)
	assert_true(screen.game.is_lost())
	var panel: Control = screen.result_panel()
	assert_not_null(panel, "a lose panel")
	assert_false(bool(panel.get_meta("won")))
	assert_eq(Session.gold, gold)
	assert_false(Session.flag(ZoneDefs.get_def("beefcake").flag_minigame_first))
	assert_not_null(panel.find_child("PlayAgain", true, false))
	assert_not_null(panel.find_child("LeaveButton", true, false))


func test_order_up_win_and_lose() -> void:
	var screen: OrderCardScreen = await _open(OrderCardScreen.new(), "gourmand") as OrderCardScreen
	screen.hide_how()
	var gold: int = Session.gold
	watch_signals(screen)
	await screen.autoplay(3)
	await wait_process_frames(2)
	assert_true(screen.game.is_won())
	assert_true(bool(screen.result_panel().get_meta("won")))
	assert_eq(int(_paid(screen)["gold"]), int(OrderGame.STAR_REWARDS[3]["gold"]) * 2 + int(OrderGame.FIRST_CLEAR_BONUS["gold"]), "the old Order Up!'s first-clear reward")
	assert_eq(str(_paid(screen)["item"]), str(OrderGame.FIRST_CLEAR_BONUS["item"]))
	assert_true(Session.flag(ZoneDefs.get_def("gourmand").flag_minigame_first))
	screen.play_again()
	await wait_process_frames(2)
	gold = Session.gold
	await screen.autoplay(0, 3)
	await wait_process_frames(2)
	assert_true(screen.game.is_lost())
	assert_false(bool(screen.result_panel().get_meta("won")))
	assert_eq(Session.gold, gold, "a closed kitchen pays nothing")


func test_order_up_picks_swaps_and_the_bell() -> void:
	var screen: OrderCardScreen = await _open(OrderCardScreen.new(), "gourmand") as OrderCardScreen
	screen.hide_how()
	await wait_process_frames(2)
	var bell: Button = screen.find_child("Bell", true, false) as Button
	assert_true(bell.disabled, "nothing to ring with an empty plate")
	(screen.find_child("Card1", true, false) as Button).pressed.emit()
	await wait_process_frames(1)
	assert_eq(screen.game.picked, [0] as Array[int])
	assert_false(bell.disabled)
	var row_before: Array[CardData] = screen.game.row.duplicate()
	(screen.find_child("SwapRow", true, false) as Button).pressed.emit()
	await wait_process_frames(1)
	assert_eq(screen.game.swaps_left, 1)
	assert_ne(screen.game.row, row_before, "six new cards")
	assert_true(screen.game.picked.is_empty())


func test_sort_it_out_win_and_lose() -> void:
	var screen: SortCardScreen = await _open(SortCardScreen.new(), "refusemancer") as SortCardScreen
	screen.hide_how()
	var gold: int = Session.gold
	watch_signals(screen)
	screen.autoplay(20)
	await wait_process_frames(2)
	assert_eq(screen.game.correct_count(), 20)
	assert_true(bool(screen.result_panel().get_meta("won")))
	assert_eq(int(_paid(screen)["gold"]), int(SortGame.STAR_REWARDS[3]["gold"]) * 2 + int(SortGame.FIRST_CLEAR_BONUS["gold"]), "the old Sort It Out!'s first-clear reward")
	assert_eq(str(_paid(screen)["item"]), str(SortGame.FIRST_CLEAR_BONUS["item"]))
	screen.play_again()
	await wait_process_frames(2)
	assert_eq(screen.game.next_card, 0)
	gold = Session.gold
	screen.autoplay(5, 5)
	await wait_process_frames(2)
	assert_true(screen.game.is_lost())
	assert_false(bool(screen.result_panel().get_meta("won")))
	assert_eq(Session.gold, gold)


func test_sort_it_out_the_belt_waits_while_how_to_play_is_open() -> void:
	var screen: SortCardScreen = await _open(SortCardScreen.new(), "refusemancer") as SortCardScreen
	await wait_process_frames(10)
	assert_eq(screen.clock, 0.0, "the belt does not run behind How to play")
	screen.hide_how()
	await wait_process_frames(10)
	assert_gt(screen.clock, 0.0)
	var at: float = screen.clock
	screen.show_how()
	await wait_process_frames(10)
	assert_almost_eq(screen.clock, at, 0.05, "and stops again when ? is opened")


func test_file_in_order_approved_gives_the_terminal_s_one_time_reward() -> void:
	var def: ZoneDef = ZoneDefs.get_def("necrocrat")
	var screen: FileCardScreen = await _open(FileCardScreen.new(), "necrocrat") as FileCardScreen
	screen.hide_how()
	watch_signals(screen)
	await screen.autoplay(-1, 1)
	await wait_process_frames(2)
	assert_true(screen.game.approved)
	assert_true(bool(screen.result_panel().get_meta("won")))
	assert_signal_emit_count(screen, "solved", 1, "the first approval is the puzzle's `solved`")
	var piece: EquipmentData = Session.content.equipment_piece(def.puzzle_equipment_id)
	assert_string_contains((screen.result_panel().find_child("Reward", true, false) as Label).text, piece.source_name, "the result names the one-time reward")
	assert_not_null(screen.find_child("StampMark", true, false))
	assert_eq((screen.find_child("StampMark", true, false) as Label).text, "APPROVED")
	# The zone scene sets the flag on `solved`; afterwards the game can be replayed, with nothing more to earn.
	Session.set_flag(def.flag_puzzle_solved)
	screen.play_again()
	await wait_process_frames(2)
	await screen.autoplay(-1, 1)
	await wait_process_frames(2)
	assert_signal_emit_count(screen, "solved", 1, "no second reward")
	assert_string_contains((screen.result_panel().find_child("Reward", true, false) as Label).text, "Already won")


func test_file_in_order_the_free_check_then_rejected() -> void:
	var screen: FileCardScreen = await _open(FileCardScreen.new(), "necrocrat") as FileCardScreen
	screen.hide_how()
	watch_signals(screen)
	await screen.autoplay(1, 1)
	await wait_process_frames(2)
	assert_false(screen.game.is_over(), "the first wrong stamp is free")
	assert_null(screen.result_panel())
	assert_string_contains((screen.find_child("Checks", true, false) as Label).text, "used")
	await screen.stamp()
	await wait_process_frames(2)
	assert_true(screen.game.rejected)
	assert_false(bool(screen.result_panel().get_meta("won")))
	assert_eq((screen.find_child("StampMark", true, false) as Label).text, "REJECTED")
	assert_signal_not_emitted(screen, "solved")


func test_file_in_order_two_clicks_swap_two_cards() -> void:
	var screen: FileCardScreen = await _open(FileCardScreen.new(), "necrocrat") as FileCardScreen
	screen.hide_how()
	await wait_process_frames(2)
	var first: CardData = screen.game.cards[0]
	var third: CardData = screen.game.cards[2]
	(screen.find_child("Slot1", true, false) as Button).pressed.emit()
	await wait_process_frames(1)
	assert_eq(screen.game.swaps, 0, "the first click only picks the card up")
	(screen.find_child("Slot3", true, false) as Button).pressed.emit()
	await wait_process_frames(2)
	assert_eq(screen.game.swaps, 1)
	assert_eq(screen.game.cards[0], third)
	assert_eq(screen.game.cards[2], first)
	(screen.find_child("Slot2", true, false) as Button).pressed.emit()
	(screen.find_child("Slot2", true, false) as Button).pressed.emit()
	await wait_process_frames(1)
	assert_eq(screen.game.swaps, 1, "clicking the same card again puts it down")


func test_a_controller_reaches_every_control_of_every_game() -> void:
	var screens: Dictionary = _screens()
	for zone_id: String in screens.keys():
		var screen: CardGameScreen = await _open(screens[zone_id] as CardGameScreen, zone_id)
		screen.hide_how()
		await wait_process_frames(3)
		var table: Control = screen.find_child("Table", true, false) as Control
		var buttons: Array[Node] = table.find_children("*", "BaseButton", true, false)
		assert_gt(buttons.size(), 1, "%s has buttons" % zone_id)
		var first: Control = null
		for node: Node in buttons:
			var button: BaseButton = node as BaseButton
			assert_eq(button.focus_mode, Control.FOCUS_ALL, "%s: %s takes the focus" % [zone_id, button.name])
			if first == null and not button.disabled:
				first = button
		# Walk the focus over the table: every enabled button is reached.
		var seen: Dictionary = {first: true}
		var frontier: Array[Control] = [first]
		while not frontier.is_empty():
			var from: Control = frontier.pop_back()
			for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
				var next: Control = PadFocus.neighbor(from, direction, screen)
				if next != null and not seen.has(next):
					seen[next] = true
					frontier.append(next)
		for node: Node in buttons:
			if not (node as BaseButton).disabled:
				assert_true(seen.has(node), "%s: the D-pad reaches %s" % [zone_id, node.name])
		assert_true(seen.has(screen.find_child("HowToPlayButton", true, false)), "%s: and the ? button" % zone_id)
		screen.queue_free()
		await wait_process_frames(2)


# ---- Fable Nov 16c: the card quiz (it was the classroom trivia) --------------------------------------------------------------------


func _quiz(zone_id: String, seed_value: int = 11) -> CardQuizScreen:
	var screen: CardQuizScreen = CardQuizScreen.new()
	screen.skip_how = true
	screen.seed_value = seed_value
	screen.feedback_seconds = 0.0
	return await _open(screen, zone_id) as CardQuizScreen


func test_the_card_quiz_deals_four_questions_from_the_zone_s_own_cards() -> void:
	for zone_id: String in ["beefcake", "gourmand", "refusemancer", "necrocrat"]:
		var pool: Array[CardData] = CardGamePool.cards(Session.content, zone_id)
		for seed_value: int in [1, 2, 3, 4, 5, 6]:
			var rng: RandomNumberGenerator = RandomNumberGenerator.new()
			rng.seed = seed_value
			var game: CardQuizGame = CardQuizGame.deal(pool, rng)
			assert_eq(game.questions.size(), CardQuizGame.QUESTIONS, "%s seed %d" % [zone_id, seed_value])
			var kinds: Dictionary = {}
			var cards: Dictionary = {}
			for question: CardQuizGame.Question in game.questions:
				kinds[question.kind] = int(kinds.get(question.kind, 0)) + 1
				cards[question.card.id] = true
				assert_true(pool.has(question.card), "a card of the zone's Path or a colourless one")
				assert_eq(question.choices.size(), CardQuizGame.CHOICES)
				var distinct: Dictionary = {}
				for choice: String in question.choices:
					distinct[choice] = true
				assert_eq(distinct.size(), CardQuizGame.CHOICES, "four different answers")
				match question.kind:
					CardQuizGame.Kind.ART:
						assert_eq(question.choices[question.correct], question.card.display_name)
						assert_true(Rect2(0, 0, 1, 1).encloses(question.crop), "the piece lies inside the painting")
						assert_lt(question.crop.size.x * question.crop.size.y, 0.25, "a piece, not the whole painting")
					CardQuizGame.Kind.COST:
						assert_eq(question.choices[question.correct], str(question.card.energy_value()))
					CardQuizGame.Kind.POWER:
						assert_true(question.card.is_unit())
						assert_eq(question.choices[question.correct], str(question.card.attack))
			assert_eq(int(kinds.get(CardQuizGame.Kind.ART, 0)), 2, "two picture questions")
			assert_eq(int(kinds.get(CardQuizGame.Kind.COST, 0)), 1)
			assert_eq(int(kinds.get(CardQuizGame.Kind.POWER, 0)), 1)
			assert_eq(cards.size(), 4, "four different cards")


func test_the_card_quiz_keeps_the_trivia_s_pass_mark() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	var game: CardQuizGame = CardQuizGame.deal(CardGamePool.cards(Session.content, "necrocrat"), rng)
	game.answer((game.current().correct + 1) % 4)
	for _index: int in range(2):
		game.answer(game.current().correct)
	assert_false(game.passed(), "not over yet")
	game.answer(game.current().correct)
	assert_true(game.is_over())
	assert_eq(game.correct_count(), 3)
	assert_eq(QuizRules.PASS_SCORE, 3)
	assert_true(game.passed(), "three of four pass")


func test_every_zone_s_quiz_spot_opens_the_card_quiz_with_its_teacher() -> void:
	for zone_id: String in ["beefcake", "gourmand", "refusemancer", "necrocrat"]:
		var screen: CardQuizScreen = await _quiz(zone_id)
		assert_false(screen.host_portrait().is_empty(), "%s has its quiz-giver" % zone_id)
		assert_eq(screen.screen_title, CardQuizScreen.title_for(zone_id))
		assert_eq(screen.music_cue(), "MUS-QUIZ")
		assert_eq(screen.how_lines().size(), 3)
		assert_not_null(screen.find_child("HowToPlayButton", true, false), "the ? button")
		assert_eq(screen.find_children("Answer?", "Button", true, false).size(), 4, "%s: four answers" % zone_id)
		assert_true(screen.find_children("*", "CardView", true, false).is_empty(), "%s: the card's face (its answer) is not shown before the answer" % zone_id)
		screen.queue_free()
		await wait_process_frames(1)
	assert_eq(CardQuizScreen.title_for("necrocrat"), "Compliance Re-Certification")


func test_a_passed_card_quiz_pays_the_trivia_s_reward_and_sets_the_d_n_a_s_quest_flags() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone("necrocrat")
	Session.level_track_grants = false  # the gold is counted exactly; the reward track pays its own
	var gold: int = Session.gold
	var screen: CardQuizScreen = await _quiz("necrocrat")
	await screen.autoplay(4)
	assert_eq(screen.state, "done")
	var panel: Control = screen.result_panel()
	assert_not_null(panel)
	assert_true(bool(panel.get_meta("won")))
	assert_eq(Session.gold - gold, int(story.quiz_rewards[4]["gold"]), "four right pays the old top reward")
	assert_true(Session.flag(DnaZone.FLAG_QUIZ_PASSED), "Pass Director Ectomund's Compliance quiz")
	assert_true(Session.flag(DnaZone.FLAG_QUIZ_DONE))
	# A later attempt, failed, still pays the small fee (as the trivia did).
	var after: int = Session.gold
	(panel.find_child("PlayAgain", true, false) as Button).pressed.emit()
	await wait_process_frames(2)
	assert_eq(screen.state, "playing")
	await screen.autoplay(4, 3)
	assert_false(bool(screen.result_panel().get_meta("won")))
	assert_eq(Session.gold - after, int(story.quiz_repeat_reward["gold"]))


func test_a_failed_first_card_quiz_pays_nothing() -> void:
	var gold: int = Session.gold
	var screen: CardQuizScreen = await _quiz("necrocrat")
	await screen.autoplay(4, 2)
	assert_eq(screen.game.correct_count(), 2)
	assert_false(bool(screen.result_panel().get_meta("won")), "two of four is not a pass")
	assert_eq(Session.gold, gold)
	assert_false(Session.flag(DnaZone.FLAG_QUIZ_PASSED))
	assert_true(Session.flag(DnaZone.FLAG_QUIZ_DONE), "the attempt is recorded")
	assert_string_contains((screen.result_panel().find_child("Reward", true, false) as Label).text, "No reward")


func test_an_answer_moves_the_card_quiz_to_the_next_question() -> void:
	var screen: CardQuizScreen = await _quiz("beefcake")
	var first: CardQuizGame.Question = screen.game.current()
	screen.feedback_seconds = 5.0
	screen.animate = false
	screen.answer(first.correct)
	await wait_process_frames(2)
	assert_eq(screen.game.index(), 1, "answered")
	assert_eq(screen.find_children("Answer?", "Button", true, false).size(), 4)

