extends GutTest
## Fresh eyes Oct 30: a challenge's outcome is explained in numbers (the critic could not tell whether the Hollow Well had passed).


func _result(cards: Array[CardData], success: bool) -> ChallengeResult:
	var result: ChallengeResult = ChallengeResult.new()
	result.revealed = cards
	result.success = success
	return result


func test_infrastructure_count_is_spelled_out() -> void:
	var challenge: ChallengeData = ChallengeData.new()
	challenge.kind = ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT
	challenge.reveal_count = 5
	challenge.threshold = 3
	var cards: Array[CardData] = [GameFactory.infra(Affinity.Type.BEEFCAKE), GameFactory.infra(Affinity.Type.BEEFCAKE), GameFactory.vanilla(2, 2), GameFactory.infra(Affinity.Type.BEEFCAKE), GameFactory.vanilla(1, 1)]
	assert_eq(ChallengeResolver.explain(challenge, _result(cards, true)), "3 of the 5 cards were Infrastructure; 3 were needed.")
	# Fresh eyes round 2 (Oct 31): the verb agrees with its number ("1 ... was", "2 were").
	challenge.threshold = 1
	var one: Array[CardData] = [GameFactory.infra(Affinity.Type.BEEFCAKE), GameFactory.vanilla(2, 2), GameFactory.vanilla(1, 1)]
	assert_eq(ChallengeResolver.explain(challenge, _result(one, true)), "1 of the 3 cards was Infrastructure; 1 was needed.")


func test_first_unit_attack_names_the_unit() -> void:
	var challenge: ChallengeData = ChallengeData.new()
	challenge.kind = ChallengeData.Kind.FIRST_UNIT_ATTACK
	challenge.threshold = 3
	var unit: CardData = GameFactory.vanilla(2, 2)
	var text: String = ChallengeResolver.explain(challenge, _result([GameFactory.infra(Affinity.Type.GOURMAND), unit] as Array[CardData], false))
	assert_true(text.contains(unit.display_name) and text.contains("2 attack") and text.contains("3 was needed"), text)
	assert_eq(ChallengeResolver.explain(challenge, _result([GameFactory.infra(Affinity.Type.GOURMAND)] as Array[CardData], false)), "No unit came up; one with 3 attack was needed.")


func test_total_cost_and_the_choice_kinds() -> void:
	var challenge: ChallengeData = ChallengeData.new()
	challenge.kind = ChallengeData.Kind.TOP_N_TOTAL_COST
	challenge.threshold = 4
	var text: String = ChallengeResolver.explain(challenge, _result([GameFactory.vanilla(2, 2), GameFactory.vanilla(1, 1)] as Array[CardData], false))
	assert_true(text.begins_with("The 2 cards cost") and text.ends_with("4 was needed."), text)
	challenge.kind = ChallengeData.Kind.PAY_HP
	assert_eq(ChallengeResolver.explain(challenge, _result([] as Array[CardData], true)), "", "a choice has no rule to explain")


func test_heals_on_success_reads_the_outcome_list() -> void:
	var challenge: ChallengeData = ChallengeData.new()
	assert_false(ChallengeResolver.heals_on_success(challenge))
	var heal: ChallengeOutcome = ChallengeOutcome.new()
	heal.kind = ChallengeOutcome.Kind.HEAL
	challenge.on_success.append(heal)
	assert_true(ChallengeResolver.heals_on_success(challenge))
