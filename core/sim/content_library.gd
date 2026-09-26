class_name ContentLibrary
extends RefCounted
## Loads the generated .tres content from data/ into a ContentSet.

const CARD_DIR: String = "res://data/cards/"
const DECK_DIR: String = "res://data/decks/"
const CHALLENGE_DIR: String = "res://data/encounters/challenges/"
const AI_DIR: String = "res://data/ai/"


static func load_all() -> ContentSet:
	var content: ContentSet = ContentSet.new()
	for path: String in _tres_files(CARD_DIR):
		var card: CardData = load(path) as CardData
		if card == null:
			continue
		if card.is_token:
			content.tokens[card.id] = card
		elif card.is_land():
			content.lands[int(card.color)] = card
		else:
			content.cards[card.id] = card
	for path: String in _tres_files(DECK_DIR):
		var deck: Deck = load(path) as Deck
		if deck != null:
			content.decks.append(deck)
	for path: String in _tres_files(CHALLENGE_DIR):
		var challenge: ChallengeData = load(path) as ChallengeData
		if challenge != null:
			content.challenges.append(challenge)
	for path: String in _tres_files(AI_DIR):
		var personality: AIPersonality = load(path) as AIPersonality
		if personality != null:
			content.personalities.append(personality)
	return content


static func _tres_files(dir_path: String) -> Array[String]:
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return files
	for file_name: String in dir.get_files():
		var clean: String = file_name.trim_suffix(".remap")
		if clean.ends_with(".tres"):
			files.append(dir_path + clean)
	files.sort()
	return files
