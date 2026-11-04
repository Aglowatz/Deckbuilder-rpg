class_name EventResolver
extends RefCounted
## Applies one choice of a `DungeonEvent` to the dungeon run (HP, boons, cards) and reports what
## else happened (gold for the Session to pay or receive, the next chained event). Pure core logic.


class Result:
	extends RefCounted
	var ok: bool = true
	var reason: String = ""
	var gold_delta: int = 0
	var hp_delta: int = 0
	var boons: Array[ModifierSource] = []
	var cards: Array[CardData] = []
	## Cards that left the run's deck for the rest of the run (LOSE_CARD).
	var lost_cards: Array[CardData] = []
	## The id of the event this choice leads into ("" = the event is over).
	var next_event: String = ""
	var choice_index: int = -1


## Resolves `choice_index` of `event`. `gold_available` guards PAY_GOLD choices (the player never goes
## below 0 gold); the resolver itself never touches the Session's gold - callers apply `gold_delta`.
## Cards Oct 27, Part 3: `to_deck` = the card also joins the run's deck (the tutorial cave); otherwise it is only reported in `cards` for the
## caller to add to the collection.
static func resolve(event: DungeonEvent, choice_index: int, run: DungeonRun, content: ContentSet, gold_available: int, to_deck: bool = true, rng: RandomNumberGenerator = null) -> Result:
	var result: Result = Result.new()
	result.choice_index = choice_index
	if choice_index < 0 or choice_index >= event.choices.size():
		result.ok = false
		result.reason = "No such choice."
		return result
	var choice: DungeonEvent.Choice = event.choices[choice_index]
	if choice.gold_cost() > gold_available:
		result.ok = false
		result.reason = "Not enough gold (%d needed)." % choice.gold_cost()
		return result
	for outcome: DungeonEvent.Outcome in choice.outcomes:
		match outcome.kind:
			DungeonEvent.OutcomeKind.HEAL:
				var before: int = run.hp
				run.heal(outcome.amount)
				result.hp_delta += run.hp - before
			DungeonEvent.OutcomeKind.DAMAGE:
				var before_damage: int = run.hp
				run.lose_hp(outcome.amount)
				result.hp_delta += run.hp - before_damage
			DungeonEvent.OutcomeKind.GOLD:
				result.gold_delta += outcome.amount
			DungeonEvent.OutcomeKind.PAY_GOLD:
				result.gold_delta -= outcome.amount
			DungeonEvent.OutcomeKind.BOON:
				if outcome.boon != null:
					run.add_dungeon_source(outcome.boon)
					result.boons.append(outcome.boon)
			DungeonEvent.OutcomeKind.CARD:
				var card: CardData = content.card(outcome.card_id)
				if card != null:
					if to_deck:
						run.gain_card(card)
					result.cards.append(card)
			DungeonEvent.OutcomeKind.LOSE_CARD:
				var candidates: Array[CardData] = []
				for card: CardData in run.current_deck().cards:
					if not card.is_basic:
						candidates.append(card)
				if not candidates.is_empty():
					var roll: RandomNumberGenerator = rng
					if roll == null:
						roll = RandomNumberGenerator.new()
						roll.randomize()
					var victim: CardData = RngUtil.pick(candidates, roll) as CardData
					if run.lose_card(victim):
						result.lost_cards.append(victim)
			DungeonEvent.OutcomeKind.NEXT:
				result.next_event = outcome.event_id
	return result
