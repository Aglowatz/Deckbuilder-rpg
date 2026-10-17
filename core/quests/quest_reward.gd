class_name QuestReward
extends Resource
## A bundle of rewards (any combination): a finished quest's payout lives on `QuestData` itself; this is the milestone payout one objective can carry
## (a zone's main quest line pays a Path Pack at its gatekeeper and an equipment piece at its midpoint). Paid by `Session.pay_quest_reward`.

@export var gold: int = 0
@export var xp: int = 0
@export var item_ids: Array[String] = []
@export var card_ids: Array[String] = []
@export var equipment_ids: Array[String] = []
@export var pack_ids: Array[String] = []
@export var unlock_flags: Array[String] = []


static func of(gold_amount: int = 0, xp_amount: int = 0) -> QuestReward:
	var made: QuestReward = QuestReward.new()
	made.gold = gold_amount
	made.xp = xp_amount
	return made


func with_packs(ids: Array[String]) -> QuestReward:
	pack_ids = ids
	return self


func with_equipment(ids: Array[String]) -> QuestReward:
	equipment_ids = ids
	return self


func with_cards(ids: Array[String]) -> QuestReward:
	card_ids = ids
	return self


func with_items(ids: Array[String]) -> QuestReward:
	item_ids = ids
	return self


func is_empty() -> bool:
	return gold <= 0 and xp <= 0 and item_ids.is_empty() and card_ids.is_empty() and equipment_ids.is_empty() and pack_ids.is_empty()


## "1 Path Pack, Hustle Boots, 40 gold" - the same wording as `QuestData.reward_summary`.
func summary() -> String:
	return ", ".join(QuestReward.describe(gold, xp, item_ids, card_ids, equipment_ids, pack_ids))


## Player-facing names of a reward bundle, in display order: packs and equipment first (the exciting part), then cards, items, gold, XP.
static func describe(gold_amount: int, xp_amount: int, items: Array[String], cards: Array[String], equipment: Array[String], packs: Array[String]) -> PackedStringArray:
	var parts: PackedStringArray = []
	for pack_id: String in packs:
		var pack: PackData = PackCatalog.find(pack_id)
		parts.append(pack.display_name if pack != null else pack_id.capitalize())
	for equipment_id: String in equipment:
		parts.append(QuestReward.equipment_name(equipment_id))
	for card_id: String in cards:
		parts.append(QuestReward.card_name(card_id))
	for item_id: String in items:
		parts.append(QuestReward.item_name(item_id))
	if gold_amount > 0:
		parts.append("%d gold" % gold_amount)
	if xp_amount > 0:
		parts.append("%d XP" % xp_amount)
	return parts


static func equipment_name(equipment_id: String) -> String:
	var content: ContentSet = QuestReward._content()
	var piece: EquipmentData = content.equipment_piece(equipment_id) if content != null else null
	return piece.source_name if piece != null and piece.source_name != "" else equipment_id.capitalize()


static func card_name(card_id: String) -> String:
	var content: ContentSet = QuestReward._content()
	var card: CardData = content.card(card_id) if content != null else null
	return card.display_name if card != null and card.display_name != "" else card_id


static func item_name(item_id: String) -> String:
	var content: ContentSet = QuestReward._content()
	var item: ItemData = content.item(item_id) if content != null else null
	return item.display_name if item != null and item.display_name != "" else item_id.capitalize()


static func _content() -> ContentSet:
	var loop: MainLoop = Engine.get_main_loop()
	if not (loop is SceneTree):
		return null
	var session: Node = (loop as SceneTree).root.get_node_or_null("Session")
	return session.get("content") as ContentSet if session != null else null
