class_name RewardLookup
extends RefCounted
## Fable Nov 21 (Part 5.5): what a reward IS, in full, for the reward boxes: a reward shows an icon and its name, and hovering it shows
## everything there is to know (what kind of thing it is, what it does, its drawback, where it goes). Also finds a reward by the name
## an older result dictionary carries ("equipment_name": "Head Chef's Ladle"), so every reward path can show the thing itself.


## The card, item or piece of equipment called `text` (its display name or its id); null when nothing matches.
static func find(content: ContentSet, text: String) -> Variant:
	if content == null or text.strip_edges().is_empty():
		return null
	for source: Dictionary in [content.equipment, content.zone_equipment]:
		for id: Variant in source.keys():
			var piece: EquipmentData = source[id] as EquipmentData
			if piece != null and (piece.source_name == text or piece.id == text):
				return piece
	for id: Variant in content.items.keys():
		var item: ItemData = content.items[id] as ItemData
		if item != null and (item.display_name == text or item.id == text):
			return item
	for source: Dictionary in [content.cards, content.multipath_cards, content.zone_cards]:
		for id: Variant in source.keys():
			var card: CardData = source[id] as CardData
			if card != null and (card.display_name == text or card.id == text):
				return card
	return null


## "Epic Weapon" / "Item" / "Card": the short kind line under a reward's name.
static func kind_text(thing: Variant) -> String:
	if thing is EquipmentData:
		var piece: EquipmentData = thing as EquipmentData
		return GearText.kind_line(piece)  # "Relic  -  Uncommon": the slot, then the rarity (one display order, Nov 23)
	if thing is ItemData:
		return "Item"
	if thing is CardData:
		return "Card"
	if thing is PackData:
		return "Unopened pack"
	return ""


## Everything about a reward, as the hover text: what it does, its drawback, how it is used and where to find it afterwards.
static func full_info(thing: Variant) -> String:
	var lines: PackedStringArray = []
	if thing is EquipmentData:
		var piece: EquipmentData = thing as EquipmentData
		lines.append(kind_text(piece))
		lines.append(GearText.effect(piece))
		if not GearText.flavour(piece).is_empty():
			lines.append("\"%s\"" % GearText.flavour(piece))
		lines.append("It is in your gear now: open the Character page (C) to wear it.")
	elif thing is ItemData:
		var item: ItemData = thing as ItemData
		lines.append("Item. %s" % item.description)
		lines.append("One use and it is gone." if item.uses <= 1 else "%d uses." % item.uses)
		if item.backfire_chance > 0.0:
			lines.append("It can backfire (%d %% of the time, %d damage to you)." % [int(round(item.backfire_chance * 100.0)), item.backfire_damage])
		lines.append("It is in your bag now: equip it on the Character page (C) to use it in a fight.")
	elif thing is CardData:
		var card: CardData = thing as CardData
		lines.append("%s card. %s" % [CardEnums.Rarity.keys()[int(card.rarity)].capitalize(), card.rules_text])
		lines.append("It is in your collection now: build it into a deck at the Deck Station.")
	elif thing is PackData:
		var pack: PackData = thing as PackData
		lines.append("An unopened pack. Open it from the Packs menu.")
		if pack.guarantee_epic_or_legendary:
			lines.append("Gilded: a sure Epic or Legendary inside.")
	return "\n".join(lines)


static func name_of(thing: Variant) -> String:
	if thing is EquipmentData:
		return (thing as EquipmentData).source_name
	if thing is ItemData:
		return (thing as ItemData).display_name
	if thing is CardData:
		return (thing as CardData).display_name
	if thing is PackData:
		return (thing as PackData).display_name
	return ""
