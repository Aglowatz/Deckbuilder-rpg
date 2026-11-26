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
	## Nov 25 night (Part G): what a check found ("You have 6 Gourmand units: the chef nods."), one line each, shown under the result.
	var notes: Array[String] = []
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
			DungeonEvent.OutcomeKind.CHECK_UNITS:
				_check_units(outcome, run, result)
			DungeonEvent.OutcomeKind.REVEAL_UNIT:
				_reveal_unit(outcome, run, result, rng)
			DungeonEvent.OutcomeKind.SHRED_TYPE:
				_shred_type(outcome, run, result)
	return result


## Nov 25 night (Part G): a deck-building check - enough units of the Path in the run's deck earns the boon, otherwise the HP cost.
static func _check_units(outcome: DungeonEvent.Outcome, run: DungeonRun, result: Result) -> void:
	var parts: PackedStringArray = outcome.event_id.split(",")
	if parts.size() < 3:
		return
	var path: int = path_of_word(parts[0])
	var needed: int = int(parts[1])
	var have: int = 0
	for card: CardData in run.current_deck().cards:
		if card.is_unit() and (path < 0 or card.paths().has(path as Affinity.Type)):
			have += 1
	var path_name: String = parts[0].capitalize()
	if have >= needed:
		if outcome.boon != null:
			run.add_dungeon_source(outcome.boon)
			result.boons.append(outcome.boon)
		result.notes.append("Your deck has %d %s units (%d needed): you pass." % [have, path_name, needed])
	else:
		var before: int = run.hp
		run.lose_hp(int(parts[2]))
		result.hp_delta += run.hp - before
		result.notes.append("Your deck has %d %s unit%s (%d needed): you fail, and lose %s HP." % [have, path_name, "" if have == 1 else "s", needed, parts[2]])


## Nov 25 night (Part G): a random unit of the run's deck is revealed; strong enough earns the boon, too weak and every copy of it leaves
## the deck for the rest of this run (the real deck is untouched: it is back after the run).
static func _reveal_unit(outcome: DungeonEvent.Outcome, run: DungeonRun, result: Result, rng: RandomNumberGenerator) -> void:
	var units: Array[CardData] = []
	for card: CardData in run.current_deck().cards:
		if card.is_unit():
			units.append(card)
	if units.is_empty():
		result.notes.append("Your deck has no unit to reveal. Nothing happens.")
		return
	var roll: RandomNumberGenerator = rng
	if roll == null:
		roll = RandomNumberGenerator.new()
		roll.randomize()
	var shown: CardData = RngUtil.pick(units, roll) as CardData
	if shown.attack >= outcome.amount:
		if outcome.boon != null:
			run.add_dungeon_source(outcome.boon)
			result.boons.append(outcome.boon)
		result.notes.append("Revealed: %s (attack %d, %d needed). It passes." % [shown.display_name, shown.attack, outcome.amount])
		return
	var copies: int = 0
	for card: CardData in run.current_deck().cards.duplicate():
		if card.id == shown.id and run.lose_card(card):
			copies += 1
			result.lost_cards.append(card)
	result.notes.append("Revealed: %s (attack %d, %d needed). Too weak: %d cop%s shredded for this run." % [shown.display_name, shown.attack, outcome.amount, copies, "y" if copies == 1 else "ies"])


## Nov 25 night (Part G): a patrol - every card of the type leaves the run's deck for the rest of this run.
static func _shred_type(outcome: DungeonEvent.Outcome, run: DungeonRun, result: Result) -> void:
	var type_value: int = CardEnums.CardType.keys().find(outcome.event_id.to_upper())
	if type_value < 0:
		return
	var shredded: int = 0
	for card: CardData in run.current_deck().cards.duplicate():
		if int(card.type) == type_value and run.lose_card(card):
			shredded += 1
			result.lost_cards.append(card)
	result.notes.append(("%d %s%s shredded for this run." % [shredded, outcome.event_id.capitalize(), "" if shredded == 1 else "s"]) if shredded > 0 else "You carry no %s. The patrol finds nothing to shred." % outcome.event_id.capitalize())


## "gourmand" -> the Path; -1 for "any" or a word that is no Path.
static func path_of_word(word: String) -> int:
	for path: Affinity.Type in Affinity.colored_types():
		if Affinity.display_name(path).to_lower() == word.strip_edges().to_lower():
			return int(path)
	return -1
