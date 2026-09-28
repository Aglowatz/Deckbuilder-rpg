class_name ProgressionContent
extends RefCounted
## Placeholder equipment and items (Part E) proving the equip/unequip/use framework works end to
## end. Written to .tres by tools/generate_content.gd like the rest of the placeholder content;
## real gear replaces these later.

const K := Modifier.Kind


static func equipment() -> Dictionary:
	var result: Dictionary = {}
	_add(result, _piece("scavengers_helm", "Scavenger's Helm", EquipmentData.Slot.HELM, "A dented helm that still turns a blade. Sharpens focus: one more card in your opening hand.", [_mod(K.MAX_HAND_SIZE, 1)]))
	_add(result, _piece("worn_blade", "Worn Blade", EquipmentData.Slot.WEAPON, "Notched from use, never from failure. Your creatures hit a little harder.", [_mod(K.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0)]))
	_add(result, _piece("padded_vest", "Padded Vest", EquipmentData.Slot.ARMOR, "Thick enough to matter, light enough to forget you're wearing it. +3 max life.", [_mod(K.MAX_LIFE, 3)]))
	_add(result, _piece("quick_boots", "Quick Boots", EquipmentData.Slot.BOOTS, "Light feet, faster starts. One more card in your opening hand.", [_mod(K.OPENING_HAND_SIZE, 1)]))
	_add(result, _piece("minor_relic", "Minor Relic", EquipmentData.Slot.RELIC, "A shard of something older than the Hollow. Your spells cost a little less.", [_mod(K.COST_CHANGE, -1, Modifier.ANY_COLOR)]))
	return result


static func items() -> Dictionary:
	var result: Dictionary = {}
	_add_item(result, "healing_draught", "Healing Draught", "A common camp remedy.", 3, CardEnums.EffectOp.GAIN_LIFE, 3)
	_add_item(result, "vitality_charm", "Vitality Charm", "A small, steady comfort.", 2, CardEnums.EffectOp.GAIN_LIFE, 2)
	_add_item(result, "reckless_tonic", "Reckless Tonic", "One big gulp - use it wisely, there is only one.", 1, CardEnums.EffectOp.GAIN_LIFE, 6)
	return result


static func _piece(id: String, title: String, slot: EquipmentData.Slot, description: String, modifiers: Array[Modifier]) -> EquipmentData:
	var piece: EquipmentData = EquipmentData.new()
	piece.id = id
	piece.source_name = title
	piece.source_kind = ModifierSource.SourceKind.EQUIPMENT
	piece.slot = slot
	piece.description = description
	piece.modifiers = modifiers
	return piece


static func _mod(kind: Modifier.Kind, value: int, color: int = Modifier.ANY_COLOR, value2: int = 0) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.value = value
	modifier.value2 = value2
	modifier.color = color
	return modifier


static func _add(result: Dictionary, piece: EquipmentData) -> void:
	result[piece.id] = piece


static func _add_item(result: Dictionary, id: String, title: String, description: String, uses: int, op: CardEnums.EffectOp, amount: int) -> void:
	var data: ItemData = ItemData.new()
	data.id = id
	data.display_name = title
	data.description = description
	data.uses = uses
	var effect: EffectData = EffectData.new()
	effect.op = op
	effect.amount = amount
	data.effect = effect
	result[id] = data
