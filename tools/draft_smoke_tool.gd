extends RefCounted
## Draft mode, Phase 1 (Part 5): the draft smoke. A whole draft and run in each of the four zones, automated and headless,
## through the Session's own functions: the fee, 32 picks (one reroll), a save and a reload in the middle, the deck, the rivals,
## real fights played to the end by two AIs with the draft's stand-in profile, the rewards and the kept card.
##   Godot --headless --path . -s res://tools/draft_smoke.gd        (bash tools/run_draft_smoke.sh)

var checks: int = 0
var failed: int = 0


func check(ok: bool, what: String) -> void:
	checks += 1
	if not ok:
		failed += 1
		print("draft_smoke: FAILED - %s" % what)


func run() -> bool:
	Session.save_enabled = false
	for zone_id: String in DraftChallenges.ZONES:
		_zone(zone_id)
	print("draft_smoke: %s - %d checks, %d failed" % ["OK" if failed == 0 else "FAILED", checks, failed])
	return failed == 0


func _zone(zone_id: String) -> void:
	Session.new_game()
	Session.ensure_game()
	DevActions.set_level(12, true)
	Session.gold = 300
	var id: String = DraftChallenges.zone_id_for(zone_id)
	var real: PlayerProfile = Session.profile
	var worn: int = real.equipment.size()
	check(Session.draft_fee(id) == 0, "%s: the first attempt is free" % zone_id)
	check(Session.start_draft(id, [] as Array[int]), "%s: the draft starts" % zone_id)
	var guard: int = 0
	var rerolled: bool = false
	var reloaded: bool = false
	while Session.draft != null and Session.draft.phase == DraftState.PHASE_PICK and guard < 100:
		guard += 1
		check((Session.draft.offer["options"] as Array).size() == 3, "%s: three options at step %d" % [zone_id, Session.draft.step])
		if guard == 6 and not rerolled:
			rerolled = Session.draft_reroll()
			check(rerolled, "%s: the reroll" % zone_id)
		if guard == 12 and not reloaded:
			reloaded = true
			var offer: Array = (Session.draft.offer["options"] as Array).duplicate()
			var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
			check(Session.from_dict(data), "%s: the save loads in the middle of a draft" % zone_id)
			check(Session.draft != null and (Session.draft.offer["options"] as Array) == offer, "%s: the same offer after the reload" % zone_id)
			real = Session.profile
			worn = real.equipment.size()
		Session.draft_pick(guard % 3)
	var draft: DraftState = Session.draft
	check(draft.cards.size() == 25 and draft.equipment.size() == 5 and draft.items.size() == 2, "%s: 25 cards, 5 pieces, 2 items" % zone_id)
	check(DraftEngine.build_deck(Session.content, draft).cards.size() == 35, "%s: a 35-card deck" % zone_id)
	check(Session.draft_begin_run(), "%s: the run begins" % zone_id)
	check(draft.rivals.size() == 3, "%s: three rivals" % zone_id)
	var fights: int = 0
	while not draft.is_finished() and fights < 6:
		fights += 1
		var context: BattleContext = Session.make_draft_battle()
		Session._draft_real_profile = Session.profile
		Session.profile = context.draft_profile
		check(context.draft_profile.equipment.size() == 5, "%s fight %d: the drafted equipment only" % [zone_id, fights])
		_play(context)
		check(context.game.is_over(), "%s fight %d: the fight ends" % [zone_id, fights])
		var result: Dictionary = Session.resolve_draft_battle(context)
		check(Session.profile == real, "%s fight %d: the real profile is back" % [zone_id, fights])
		check(bool(result.get("over", false)) == draft.is_finished(), "%s fight %d: the result knows whether the run is over" % [zone_id, fights])
		print("draft_smoke: %s fight %d vs %s: %s (%d-%d)" % [zone_id, fights, context.enemy_name, "won" if context.won else "lost", draft.wins, draft.losses])
	check(draft.is_finished(), "%s: the run ends at 3 wins or 2 losses" % zone_id)
	check(int(draft.result.get("gold", 0)) > 0, "%s: something for every result" % zone_id)
	check(real.equipment.size() == worn, "%s: the main loadout is untouched" % zone_id)
	if draft.full_win():
		check(Session.flag(StringName(DraftChallenges.won_flag(id))), "%s: the win is recorded" % zone_id)
		check(Session.draft_keep(draft.cards[0]), "%s: one card is kept" % zone_id)
	else:
		check(not Session.draft_keep(draft.cards[0]), "%s: no card without a full win" % zone_id)
	Session.close_draft()
	check(Session.draft == null, "%s: the draft is put away" % zone_id)
	check(Session.draft_fee(id) == DraftRules.entry_fee(), "%s: the next attempt costs the fee" % zone_id)


## Plays a draft fight to the end: a decent player (Elite search) against the rival's own AI.
func _play(context: BattleContext) -> void:
	var game: GameState = context.game
	var player_ai: AIPlayer = AIPlayer.for_foe(ZoneDecks.personality(Session.content, "Balanced"), AIPlayer.Skill.ELITE)
	player_ai.deterministic = true
	context.ai.deterministic = true
	var ais: Array[AIPlayer] = [player_ai, context.ai]
	var steps: int = 0
	while not game.is_over() and steps < BalanceSim.MAX_STEPS_PER_GAME:
		steps += 1
		var who: int = game.awaiting_player()
		var action: GameAction = ais[who].choose_action(game)
		if not game.apply_action(action):
			if not game.apply_action(GameAction.pass_phase(who)):
				break
