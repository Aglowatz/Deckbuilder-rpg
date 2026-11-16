class_name CardQuizGame
extends RefCounted
## Fable Nov 16c (Part 1): the card quiz, which replaces the classroom trivia in all four Path zones (same teacher, same rewards, same
## pass mark: `QuizRules`). Four questions about the game's real cards, dealt from the zone's own Path plus the colourless cards
## (`CardGamePool`):
##   - ART: a cropped piece of a card's painting, "Which card is this?", four card names;
##   - COST: a card's painting and name, "What does it cost?", four numbers;
##   - POWER: a unit's painting and name, "What is its power?", four numbers.
## A quiz is two ART questions, one COST and one POWER, in a shuffled order; the four cards are all different. Pure rules:
## `CardQuizScreen` is the classroom.

enum Kind { ART, COST, POWER }

const QUESTIONS: int = 4
const CHOICES: int = 4
## The kinds one quiz asks (shuffled).
const KINDS: Array[Kind] = [Kind.ART, Kind.ART, Kind.COST, Kind.POWER]
## The cropped piece of an ART question: this share of the painting's width and height...
const CROP_SHARE: Vector2 = Vector2(0.46, 0.34)
## ...taken from inside this part of it (the middle: the edges are often plain background).
const CROP_ZONE: Rect2 = Rect2(0.08, 0.1, 0.84, 0.7)


class Question:
	extends RefCounted
	var kind: Kind = Kind.ART
	var card: CardData
	var choices: Array[String] = []
	## The index of the right choice.
	var correct: int = 0
	## ART: the piece shown, in 0-1 units of the painting.
	var crop: Rect2 = Rect2(0, 0, 1, 1)

	func prompt() -> String:
		match kind:
			Kind.COST:
				return "What does %s cost?" % card.display_name
			Kind.POWER:
				return "What is the POWER of %s?" % card.display_name
		return "Which card is this?"


var questions: Array[Question] = []
## The chosen choice index per answered question.
var answers: Array[int] = []


## Deals a quiz from `pool` (cards that have a painting are asked about; without any, every card is). Fewer than eight cards: no quiz.
static func deal(pool: Array[CardData], rng: RandomNumberGenerator, has_art: Callable = Callable()) -> CardQuizGame:
	var game: CardQuizGame = CardQuizGame.new()
	var painted: Array[CardData] = []
	for card: CardData in pool:
		if not has_art.is_valid() or bool(has_art.call(card)):
			painted.append(card)
	if painted.size() < QUESTIONS * 2:
		painted = pool.duplicate()
	if painted.size() < QUESTIONS * 2:
		return game
	var deck: Array[CardData] = painted.duplicate()
	_shuffle(deck, rng)
	var kinds: Array[Kind] = KINDS.duplicate()
	_shuffle(kinds, rng)
	var used: Dictionary = {}
	for kind: Kind in kinds:
		var card: CardData = _pick(deck, used, kind)
		if card == null:
			continue
		used[card.id] = true
		match kind:
			Kind.ART:
				game.questions.append(_art_question(card, painted, rng))
			Kind.COST:
				game.questions.append(_number_question(Kind.COST, card, card.energy_value(), rng))
			Kind.POWER:
				game.questions.append(_number_question(Kind.POWER, card, card.attack, rng))
	return game


static func _pick(deck: Array[CardData], used: Dictionary, kind: Kind) -> CardData:
	for card: CardData in deck:
		if used.has(card.id):
			continue
		if kind == Kind.POWER and not card.is_unit():
			continue
		return card
	return null


static func _art_question(card: CardData, pool: Array[CardData], rng: RandomNumberGenerator) -> Question:
	var question: Question = Question.new()
	question.kind = Kind.ART
	question.card = card
	# The wrong names: cards of the same type first (a unit among units is a fair question), then any.
	var others: Array[CardData] = []
	for other: CardData in pool:
		if other.id != card.id and other.display_name != card.display_name and other.type == card.type:
			others.append(other)
	_shuffle(others, rng)
	if others.size() < CHOICES - 1:
		for other: CardData in pool:
			if other.id != card.id and other.display_name != card.display_name and not others.has(other):
				others.append(other)
	var names: Array[String] = [card.display_name]
	for other: CardData in others:
		if names.size() >= CHOICES:
			break
		if not names.has(other.display_name):
			names.append(other.display_name)
	_place(question, names, rng)
	var room: Vector2 = CROP_ZONE.size - CROP_SHARE
	question.crop = Rect2(CROP_ZONE.position + Vector2(rng.randf() * room.x, rng.randf() * room.y), CROP_SHARE)
	return question


static func _number_question(kind: Kind, card: CardData, value: int, rng: RandomNumberGenerator) -> Question:
	var question: Question = Question.new()
	question.kind = kind
	question.card = card
	# Three wrong numbers near the right one, none below zero, all different.
	var numbers: Array[int] = [value]
	var steps: Array[int] = [-2, -1, 1, 2, 3, -3, 4]
	_shuffle(steps, rng)
	for step: int in steps:
		if numbers.size() >= CHOICES:
			break
		if value + step >= 0 and not numbers.has(value + step):
			numbers.append(value + step)
	var up: int = value + 1
	while numbers.size() < CHOICES:
		if not numbers.has(up):
			numbers.append(up)
		up += 1
	var right: String = str(value)
	numbers.sort()
	for number: int in numbers:
		question.choices.append(str(number))
	question.correct = question.choices.find(right)
	return question


## Puts `names` (the right one first) into the question in a shuffled order.
static func _place(question: Question, names: Array[String], rng: RandomNumberGenerator) -> void:
	var right: String = names[0]
	_shuffle(names, rng)
	question.choices = names
	question.correct = names.find(right)


static func _shuffle(list: Array, rng: RandomNumberGenerator) -> void:
	for i: int in range(list.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var held: Variant = list[i]
		list[i] = list[j]
		list[j] = held


func index() -> int:
	return answers.size()


func current() -> Question:
	return questions[index()] if index() < questions.size() else null


func is_over() -> bool:
	return answers.size() >= questions.size()


## Answers the current question; true when `choice` was right.
func answer(choice: int) -> bool:
	var question: Question = current()
	if question == null:
		return false
	answers.append(choice)
	return choice == question.correct


func correct_count() -> int:
	var count: int = 0
	for i: int in range(answers.size()):
		if answers[i] == questions[i].correct:
			count += 1
	return count


## The old trivia's pass mark: three of four.
func passed() -> bool:
	return is_over() and correct_count() >= QuizRules.PASS_SCORE


## Stars on the result panel: four right 3, three right 2, two right 1 (not a pass), fewer none.
func stars() -> int:
	return clampi(correct_count() - 1, 0, 3)
