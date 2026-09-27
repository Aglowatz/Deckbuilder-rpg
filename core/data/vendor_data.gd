class_name VendorData
extends Resource
## A vendor's full stock list and each item's unlock `Condition` (see `docs/design/
## open_questions.md` D37). Stock starts small and grows with progress: an entry whose condition
## is not yet met is still "known" (so the vendor can tease it as "???") but is not for sale.

@export var vendor_name: String = ""
@export var entries: Array[VendorStockEntry] = []
## Only appears at all (even as a teaser) once this is met - for a vendor that is itself a
## secret, like a hidden merchant. Null = the vendor is always around.
@export var appears_when: Condition = null


func add(card_id: String, unlock: Condition = null) -> VendorStockEntry:
	var entry: VendorStockEntry = VendorStockEntry.new()
	entry.card_id = card_id
	entry.unlock = unlock
	entries.append(entry)
	return entry


## Card ids currently for sale.
func available_card_ids(state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for entry: VendorStockEntry in entries:
		if Condition.met(entry.unlock, state):
			result.append(entry.card_id)
	return result


## Card ids known to exist but not yet unlocked (for a "???" teaser row).
func locked_card_ids(state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for entry: VendorStockEntry in entries:
		if not Condition.met(entry.unlock, state):
			result.append(entry.card_id)
	return result


func teaser_for(card_id: String) -> String:
	for entry: VendorStockEntry in entries:
		if entry.card_id == card_id:
			return Condition.teaser(entry.unlock)
	return ""


## The whole vendor is visible (its stock may still be partly locked/teased).
func is_open(state: UnlockState) -> bool:
	return Condition.met(appears_when, state)


## Every card in a full deck's non-land, non-token cards, priced/gated by rarity: common cards
## unlock once `gate` (usually the vendor's home dungeon being cleared) is met; uncommon/rare/
## mythic unlock progressively further behind lifetime gold spent, so the stall visibly grows as
## the player plays. Neutral cards and the player's own colors (their starting deck is always
## two colors) are always available once `gate` is met.
static func graduated(content: ContentSet, own_colors: Array[Affinity.Type], gate: Condition) -> VendorData:
	var data: VendorData = VendorData.new()
	var ids: Array = content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = content.cards[str(id)] as CardData
		if card.color == Affinity.Type.NEUTRAL or own_colors.has(card.color):
			data.add(card.id, gate)
			continue
		var spend_threshold: int = [80, 180, 320, 500][int(card.rarity)]
		data.add(card.id, Condition.all_of([gate, Condition.gold_spent(spend_threshold)] as Array[Condition]))
	return data
