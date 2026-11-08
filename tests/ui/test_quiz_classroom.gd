extends GutTest
## Overnight Nov 7-8, Part 6.1: the trivia classroom - the zone's quiz-giver as the teacher, the question on the chalkboard, answer
## feedback with a streak, and each zone's own quiz name.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_every_path_zone_has_a_teacher_and_its_own_quiz_name() -> void:
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer"]:
		var teacher: Dictionary = QuizScreen.teacher_for(ZoneDefs.get_def(zone_id))
		assert_false(teacher.is_empty(), "%s has a quiz-giver" % zone_id)
		assert_ne(QuizScreen.title_for(zone_id), "Pop Quiz", zone_id)
	assert_eq(QuizScreen.title_for("necrocrat"), "Compliance Re-Certification")
	assert_ne(QuizScreen.title_for("beefcake"), QuizScreen.title_for("necrocrat"), "no more D.N.A. title in the Gainlands")


func test_answers_get_feedback_and_a_streak() -> void:
	Session.zone_run = null  # outside a zone: the D.N.A. quiz
	var screen: QuizScreen = QuizScreen.new()
	screen.feedback_seconds = 0.0
	add_child_autofree(screen)
	await get_tree().process_frame
	assert_not_null(screen.find_child("Chalkboard", true, false))
	assert_not_null(screen.find_child("Teacher", true, false))
	var board: Label = screen.find_child("BoardQuestion", true, false) as Label
	assert_false(board.text.is_empty(), "the question is chalked on the board")
	var right: int = int((screen._story.quiz_questions[0] as Dictionary)["correct"])
	screen._answer(right)
	await get_tree().process_frame
	screen._answer(int((screen._story.quiz_questions[1] as Dictionary)["correct"]))
	await get_tree().process_frame
	var streak: Label = screen.find_child("Streak", true, false) as Label
	assert_string_contains(streak.text, "x2", "two right in a row")
