extends SceneTree
## Writes the placeholder content (ContentDefinitions) to .tres files under data/.
## Run from the project root:
##   Godot --headless --path . -s res://tools/generate_content.gd

const CARD_DIR: String = "res://data/cards/"
const DECK_DIR: String = "res://data/decks/"
const CHALLENGE_DIR: String = "res://data/encounters/challenges/"
const AI_DIR: String = "res://data/ai/"
const EQUIPMENT_DIR: String = "res://data/equipment/"
const ITEM_DIR: String = "res://data/items/"
const ZONE_CARD_DIR: String = "res://data/cards/zone/"
const ZONE_EQUIPMENT_DIR: String = "res://data/equipment/zone/"


func _init() -> void:
	var content: ContentSet = ContentDefinitions.build()
	var saved: int = 0
	# Tokens first so cards that summon them reference the saved file instead of embedding it.
	for token: CardData in content.tokens.values():
		saved += _save(token, CARD_DIR + token.id + ".tres")
	for land: CardData in content.lands.values():
		saved += _save(land, CARD_DIR + land.id + ".tres")
	for card: CardData in content.cards.values():
		saved += _save(card, CARD_DIR + card.id + ".tres")
	for zone_card: CardData in content.zone_cards.values():
		saved += _save(zone_card, ZONE_CARD_DIR + zone_card.id + ".tres")
	for zone_piece: Variant in content.zone_equipment.values():
		saved += _save(zone_piece as EquipmentData, ZONE_EQUIPMENT_DIR + (zone_piece as EquipmentData).id + ".tres")
	for deck: Deck in content.decks:
		saved += _save(deck, DECK_DIR + _slug(deck.deck_name) + ".tres")
	for challenge: ChallengeData in content.challenges:
		saved += _save(challenge, CHALLENGE_DIR + challenge.id + ".tres")
	for personality: AIPersonality in content.personalities:
		saved += _save(personality, AI_DIR + _slug(personality.personality_name) + ".tres")
	for piece: Variant in content.equipment.values():
		saved += _save(piece as EquipmentData, EQUIPMENT_DIR + (piece as EquipmentData).id + ".tres")
	for consumable: Variant in content.items.values():
		saved += _save(consumable as ItemData, ITEM_DIR + (consumable as ItemData).id + ".tres")
	print("Generated %d resource files." % saved)
	quit(0)


func _save(resource: Resource, path: String) -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	resource.take_over_path(path)
	var err: int = ResourceSaver.save(resource, path)
	if err != OK:
		push_error("Failed to save %s (error %d)" % [path, err])
		return 0
	return 1


func _slug(text: String) -> String:
	return text.to_lower().replace(" & ", "_").replace("'", "").replace(" ", "_")
