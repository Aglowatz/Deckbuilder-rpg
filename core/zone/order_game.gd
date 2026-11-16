class_name OrderGame
extends RefCounted
## The reward rule of the Endless Buffet's minigame at Chef Flambe's pass (it was the ingredient-stacking "Order Up!"). Fable Nov 16c: the old game itself (its rules and its screen) is deleted; the card minigame that
## replaced it (`OrderCardGame`) pays through `apply_result`, so a win is worth exactly what it was. The FIRST win (>= 1 star) pays a large
## reward by stars plus a one-time bonus; every later win pays a small flat reward. A lost game pays nothing.

## Reward by stars: gold, xp. The first-ever win also pays FIRST_CLEAR_BONUS.
const STAR_REWARDS: Array[Dictionary] = [
	{"gold": 0, "xp": 0},
	{"gold": 20, "xp": 10},
	{"gold": 45, "xp": 20},
	{"gold": 80, "xp": 35},
]
const FIRST_CLEAR_BONUS: Dictionary = {"gold": 50, "item": "scroll_of_insight"}
const REPEAT_REWARD: Dictionary = {"gold": 10, "xp": 5}

static func apply_result(stars_earned: int) -> Dictionary:
	var result: Dictionary = {"gold": 0, "xp": 0, "item": "", "first_win": false, "stars": stars_earned}
	if stars_earned <= 0:
		return result
	var first_flag: StringName = ZoneDefs.current().flag_minigame_first
	if not Session.flag(first_flag):
		Session.set_flag(first_flag)
		result["first_win"] = true
		result["gold"] = int(STAR_REWARDS[stars_earned]["gold"]) * 2 + int(FIRST_CLEAR_BONUS["gold"])
		result["xp"] = int(STAR_REWARDS[stars_earned]["xp"]) * 2
		result["item"] = str(FIRST_CLEAR_BONUS["item"])
	else:
		result["gold"] = int(STAR_REWARDS[stars_earned]["gold"]) / 2 + int(REPEAT_REWARD["gold"])
		result["xp"] = int(REPEAT_REWARD["xp"])
	PackRewards.grant_minigame_prize(result)
	if int(result["gold"]) > 0:
		Session.add_gold(int(result["gold"]))
	if int(result["xp"]) > 0:
		Session.pending_level_ups.append_array(Session.add_xp(int(result["xp"])))
	if not str(result["item"]).is_empty() and Session.content.item(str(result["item"])) != null:
		Session.add_item(Session.content.item(str(result["item"])))
	Session.save_game()
	return result
