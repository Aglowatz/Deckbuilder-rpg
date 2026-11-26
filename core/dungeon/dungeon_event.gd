class_name DungeonEvent
extends RefCounted
## A story event node of a zone dungeon (Part E): a short scene with a few choices, each with
## outcomes (heal, lose HP, gold, a dungeon-wide boon, a card...). Pure data; `EventResolver`
## applies it. All text (title, body, choice labels, results) lives in the zone's story file under
## `event.<id>.title`, `.body`, `.choice.<n>` and `.result.<n>`; this class only holds the mechanics.
## An outcome of kind NEXT chains into another event ("forms that require other forms").

## LOSE_CARD (Fix pass Nov 4 (B)): a random non-basic card leaves the run's deck for the rest of this run (it is back after the run).
## HINT (Fable Nov 20): no effect; its `event_id` is the choice's own bracket text.
## Nov 25 night (Part G, the encounter library): CHECK_UNITS - a deck-building check: `event_id` "path,count,damage"; with at least `count`
## units of that Path in the run's deck the player gets `boon` for the rest of the dungeon, otherwise loses `damage` HP. REVEAL_UNIT - a
## random unit of the run's deck is shown: attack at least `amount` gives `boon`, less and EVERY copy of it leaves the deck for this run.
## SHRED_TYPE - every card of the type in `event_id` ("wonder", "tool"...) leaves the run's deck for this run (back after the run).
enum OutcomeKind { NOTHING, HEAL, DAMAGE, GOLD, PAY_GOLD, BOON, CARD, NEXT, LOSE_CARD, HINT, CHECK_UNITS, REVEAL_UNIT, SHRED_TYPE }


class Outcome:
	extends RefCounted
	var kind: OutcomeKind = OutcomeKind.NOTHING
	var amount: int = 0
	var boon: ModifierSource
	var card_id: String = ""
	var event_id: String = ""

	## One-line description for the choice button's hint ("Heal 4", "Lose 2 HP"...).
	func describe() -> String:
		match kind:
			OutcomeKind.HEAL:
				return "heal %d" % amount
			OutcomeKind.DAMAGE:
				return "lose %d HP" % amount
			OutcomeKind.GOLD:
				return "gain %d gold" % amount
			OutcomeKind.PAY_GOLD:
				return "pay %d gold" % amount
			OutcomeKind.BOON:
				if boon == null:
					return "boon: ?"
				return "%s: %s, %s" % ["curse" if _is_curse() else "boon", boon.source_name, BoonText.short(boon)]  # Fixes Oct 27: what it does; Fable Nov 20: no brackets inside the button's brackets
			OutcomeKind.CARD:
				return "gain a card"
			OutcomeKind.LOSE_CARD:
				return "a random card leaves your deck for this run"
			OutcomeKind.NEXT:
				return "continue..."
			OutcomeKind.CHECK_UNITS:
				var parts: PackedStringArray = event_id.split(",")
				return "if your deck has %s or more %s units: %s; if not, lose %s HP" % [parts[1], parts[0].capitalize(), _boon_words(), parts[2]]
			OutcomeKind.REVEAL_UNIT:
				return "a random unit of your deck is revealed: attack %d or more, %s; less, every copy of it leaves your deck for this run" % [amount, _boon_words()]
			OutcomeKind.SHRED_TYPE:
				return "every %s in your deck is shredded for this run" % event_id.capitalize()
		return ""

	## The boon of a check, in the words of a choice button ("Head Chef's Nod: your units get +1 attack").
	func _boon_words() -> String:
		return "%s (%s)" % [boon.source_name, BoonText.short(boon)] if boon != null else "a boon"

	## A boon whose numbers are all negative is a curse on the run (shown as one on the choice button).
	func _is_curse() -> bool:
		return boon != null and BoonText.is_curse(boon)

class Choice:
	extends RefCounted
	var outcomes: Array[Outcome] = []

	## The gold this choice costs up front (sum of its PAY_GOLD outcomes).
	func gold_cost() -> int:
		var total: int = 0
		for outcome: Outcome in outcomes:
			if outcome.kind == OutcomeKind.PAY_GOLD:
				total += outcome.amount
		return total

	func hint() -> String:
		var parts: PackedStringArray = []
		# Fable Nov 20: a choice may carry its own words ("hint:-5 HP; you take the first turn in the fight"): one set of brackets, as written
		for outcome: Outcome in outcomes:
			if outcome.kind == OutcomeKind.HINT:
				return outcome.event_id
		for outcome: Outcome in outcomes:
			var text: String = outcome.describe()
			if not text.is_empty():
				parts.append(text)
		return ", ".join(parts)


var id: String = ""
var choices: Array[Choice] = []


static func make(event_id: String) -> DungeonEvent:
	var event: DungeonEvent = DungeonEvent.new()
	event.id = event_id
	return event


## Adds a choice made of the given outcomes (build them with `heal`, `damage`, ...) and returns the event.
func choice(outcomes: Array[Outcome]) -> DungeonEvent:
	var added: Choice = Choice.new()
	added.outcomes = outcomes
	choices.append(added)
	return self


func title_key() -> String:
	return "event.%s.title" % id


func body_key() -> String:
	return "event.%s.body" % id


func choice_key(index: int) -> String:
	return "event.%s.choice.%d" % [id, index]


func result_key(index: int) -> String:
	return "event.%s.result.%d" % [id, index]


static func _outcome(kind: OutcomeKind, amount: int = 0) -> Outcome:
	var outcome: Outcome = Outcome.new()
	outcome.kind = kind
	outcome.amount = amount
	return outcome


static func nothing() -> Outcome:
	return _outcome(OutcomeKind.NOTHING)


static func hint_text(words: String) -> Outcome:
	var outcome: Outcome = _outcome(OutcomeKind.HINT)
	outcome.event_id = words
	return outcome


static func heal(amount: int) -> Outcome:
	return _outcome(OutcomeKind.HEAL, amount)


static func damage(amount: int) -> Outcome:
	return _outcome(OutcomeKind.DAMAGE, amount)


static func gold(amount: int) -> Outcome:
	return _outcome(OutcomeKind.GOLD, amount)


static func pay_gold(amount: int) -> Outcome:
	return _outcome(OutcomeKind.PAY_GOLD, amount)


static func boon(source: ModifierSource) -> Outcome:
	var outcome: Outcome = _outcome(OutcomeKind.BOON)
	outcome.boon = source
	return outcome


static func card(card_id: String) -> Outcome:
	var outcome: Outcome = _outcome(OutcomeKind.CARD)
	outcome.card_id = card_id
	return outcome


static func lose_card() -> Outcome:
	return _outcome(OutcomeKind.LOSE_CARD)


## Nov 25 night (Part G): the encounter library's checks and patrols (see OutcomeKind).
static func check_units(path_word: String, count: int, damage_amount: int, reward: ModifierSource) -> Outcome:
	var outcome: Outcome = _outcome(OutcomeKind.CHECK_UNITS, count)
	outcome.event_id = "%s,%d,%d" % [path_word, count, damage_amount]
	outcome.boon = reward
	return outcome


static func reveal_unit(min_attack: int, reward: ModifierSource) -> Outcome:
	var outcome: Outcome = _outcome(OutcomeKind.REVEAL_UNIT, min_attack)
	outcome.boon = reward
	return outcome


static func shred_type(type_word: String) -> Outcome:
	var outcome: Outcome = _outcome(OutcomeKind.SHRED_TYPE)
	outcome.event_id = type_word
	return outcome


static func next(event_id: String) -> Outcome:
	var outcome: Outcome = _outcome(OutcomeKind.NEXT)
	outcome.event_id = event_id
	return outcome
