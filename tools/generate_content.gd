extends SceneTree
## Writes the non-card content (decks, challenges, AI personalities, equipment, items) to .tres files under data/.
## The cards and tokens are written by `tools/import_cards.sh --write` (run that first: the decks reference those files).
## Run from the project root:
##   Godot --headless --path . -s res://tools/generate_content.gd

const DECK_DIR: String = "res://data/decks/"
const CHALLENGE_DIR: String = "res://data/encounters/challenges/"
const AI_DIR: String = "res://data/ai/"
const EQUIPMENT_DIR: String = "res://data/equipment/"
const ITEM_DIR: String = "res://data/items/"
const ZONE_EQUIPMENT_DIR: String = "res://data/equipment/zone/"


func _init() -> void:
	var content: ContentSet = ContentDefinitions.build()
	# Point every card at its imported file, so decks, challenges and items reference the files instead of embedding copies.
	for card: CardData in content.all_collectible():
		card.take_over_path("%s%s.tres" % [CardImporter.CARD_DIR, card.id])
	for infra: Variant in content.infrastructure.values():
		(infra as CardData).take_over_path("%s%s.tres" % [CardImporter.CARD_DIR, (infra as CardData).id])
	for token: Variant in content.tokens.values():
		(token as CardData).take_over_path("%s%s.tres" % [CardImporter.TOKEN_DIR, (token as CardData).id])
	var saved: int = 0
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
