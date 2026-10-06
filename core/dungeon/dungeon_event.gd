class_name DungeonEvent
extends RefCounted
## A story event node of a zone dungeon (Part E): a short scene with a few choices, each with
## outcomes (heal, lose HP, gold, a dungeon-wide boon, a card...). Pure data; `EventResolver`
## applies it. All text (title, body, choice labels, results) lives in the zone's story file under
## `event.<id>.title`, `.body`, `.choice.<n>` and `.result.<n>`; this class only holds the mechanics.
## An outcome of kind NEXT chains into another event ("forms that require other forms").

enum OutcomeKind { NOTHING, HEAL, DAMAGE, GOLD, PAY_GOLD, BOON, CARD, NEXT }


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
				return "boon: %s" % (boon.source_name if boon != null else "?")
			OutcomeKind.CARD:
				return "gain a card"
			OutcomeKind.NEXT:
				return "continue..."
		return ""


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


static func next(event_id: String) -> Outcome:
	var outcome: Outcome = _outcome(OutcomeKind.NEXT)
	outcome.event_id = event_id
	return outcome
