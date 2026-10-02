class_name QuizRules
extends RefCounted
## Part G: the Quiz Master's rules. Four multiple-choice questions about the Necrocrats (Afterlife
## Services and Labor); questions and rewards are data in `ZoneStoryText`. Retries are unlimited.
## Rewards (designer decision): the FIRST time you pass (>= PASS_SCORE correct) pays the large
## reward for that score (`quiz_rewards`); afterwards EVERY finished attempt pays the small flat
## `quiz_repeat_reward`. Failing before you have ever passed pays nothing.

## The D.N.A.'s flag (kept for tests); other zones use `ZoneDef.flag_quiz_passed`.
const PASS_SCORE: int = 3
const PASSED_FLAG: StringName = &"dna_quiz_passed"


## The payout for finishing a quiz with `correct` answers right, given whether it was passed before.
static func payout(story: ZoneStoryText, correct: int, passed_before: bool) -> Dictionary:
	var nothing: Dictionary = {"gold": 0, "xp": 0, "item": "", "first_pass": false}
	if passed_before:
		var repeat: Dictionary = story.quiz_repeat_reward
		return {"gold": int(repeat.get("gold", 0)), "xp": int(repeat.get("xp", 0)), "item": "", "first_pass": false}
	if correct < PASS_SCORE:
		return nothing
	var top: int = story.quiz_rewards.size() - 1
	var tier: Dictionary = story.quiz_rewards[clampi(correct, 0, top)] as Dictionary
	return {"gold": int(tier.get("gold", 0)), "xp": int(tier.get("xp", 0)), "item": str(tier.get("item", "")), "first_pass": true}


## How many of `answers` (chosen answer index per question) are right.
static func score(story: ZoneStoryText, answers: Array[int]) -> int:
	var correct: int = 0
	for index: int in range(mini(answers.size(), story.quiz_questions.size())):
		if answers[index] == int((story.quiz_questions[index] as Dictionary)["correct"]):
			correct += 1
	return correct


## Applies a finished quiz to the Session: pays, records the first pass, sets the "took the quiz"
## flag (the audit quest's objective). Returns the payout dictionary.
static func apply(story: ZoneStoryText, correct: int) -> Dictionary:
	var passed_before: bool = Session.flag(ZoneDefs.current().flag_quiz_passed)
	var reward: Dictionary = payout(story, correct, passed_before)
	if bool(reward["first_pass"]):
		Session.set_flag(ZoneDefs.current().flag_quiz_passed)
	if int(reward["gold"]) > 0:
		Session.add_gold(int(reward["gold"]))
	var item_id: String = str(reward["item"])
	if not item_id.is_empty() and Session.content.item(item_id) != null:
		Session.add_item(Session.content.item(item_id))
	if int(reward["xp"]) > 0:
		Session.pending_level_ups.append_array(Session.add_xp(int(reward["xp"])))
	Session.set_flag(ZoneDefs.current().flag_quiz_done)
	Session.refresh_quests()
	Session.save_game()
	return reward
