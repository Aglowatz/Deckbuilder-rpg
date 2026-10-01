class_name QuizRules
extends RefCounted
## Part G: the Quiz Master's rules. Four multiple-choice questions about the Necrocrats (Afterlife
## Services and Labor); the questions and reward tiers are data in `ZoneStoryText`. The quiz can be
## retried as often as the player likes (limit chosen: none), but rewards only ever pay for
## IMPROVING on your best score - so a retry can raise your payout, never farm it. The Session
## counter `dna_quiz_best` stores the best score paid so far (-1 = never taken).

const BEST_COUNTER: String = "dna_quiz_best"


## The payout for scoring `correct` when `best_paid` was already paid (-1 = nothing yet): only the
## difference between the tiers, and the item only when it is newly reached.
static func payout(story: ZoneStoryText, correct: int, best_paid: int) -> Dictionary:
	var top: int = story.quiz_rewards.size() - 1
	var score: int = clampi(correct, 0, top)
	if score <= best_paid:
		return {"gold": 0, "xp": 0, "item": ""}
	var now: Dictionary = story.quiz_rewards[score] as Dictionary
	var before: Dictionary = story.quiz_rewards[best_paid] as Dictionary if best_paid >= 0 else {"gold": 0, "xp": 0, "item": ""}
	var item: String = str(now.get("item", ""))
	if item == str(before.get("item", "")):
		item = ""
	return {
		"gold": int(now.get("gold", 0)) - int(before.get("gold", 0)),
		"xp": int(now.get("xp", 0)) - int(before.get("xp", 0)),
		"item": item,
	}


## How many of `answers` (chosen answer index per question) are right.
static func score(story: ZoneStoryText, answers: Array[int]) -> int:
	var correct: int = 0
	for index: int in range(mini(answers.size(), story.quiz_questions.size())):
		if answers[index] == int((story.quiz_questions[index] as Dictionary)["correct"]):
			correct += 1
	return correct


## Applies a finished quiz to the Session: pays the improvement, records the best, sets the
## "took the quiz" flag (the audit quest's objective). Returns the payout dictionary.
static func apply(story: ZoneStoryText, correct: int) -> Dictionary:
	var best: int = int(Session.counters.get(BEST_COUNTER, -1))
	var reward: Dictionary = payout(story, correct, best)
	if correct > best:
		Session.counters[BEST_COUNTER] = correct
	if int(reward["gold"]) > 0:
		Session.add_gold(int(reward["gold"]))
	var item_id: String = str(reward["item"])
	if not item_id.is_empty() and Session.content.item(item_id) != null:
		Session.add_item(Session.content.item(item_id))
	if int(reward["xp"]) > 0:
		Session.pending_level_ups.append_array(Session.add_xp(int(reward["xp"])))
	Session.set_flag(DnaZone.FLAG_QUIZ_DONE)
	Session.refresh_quests()
	Session.save_game()
	return reward
