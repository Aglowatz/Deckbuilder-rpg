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


const G := CardEnums.TargetKind
const D := CardEnums.Duration
const K2 := CardEnums.Keyword


## `tokens` is the same dict `ContentDefinitions.build_tokens()` produces - Summoning Charm reuses
## the existing "token_spirit" token rather than defining a near-duplicate.
static func items(tokens: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {}
	_add_item(result, "healing_draught", "Healing Draught", "A common camp remedy.", 3, CardEnums.EffectOp.GAIN_LIFE, 3)
	_add_item(result, "vitality_charm", "Vitality Charm", "A small, steady comfort.", 2, CardEnums.EffectOp.GAIN_LIFE, 2)
	_add_item(result, "reckless_tonic", "Reckless Tonic", "One big gulp - use it wisely, there is only one.", 1, CardEnums.EffectOp.GAIN_LIFE, 6)
	# New brief, Part F: 10 basic consumables, usable in battle (item bar, targeting where the
	# effect needs it) as well as between fights - the same effect either way.
	_add_item(result, "healing_salve", "Healing Salve", "Heal 4 life.", 3, CardEnums.EffectOp.GAIN_LIFE, 4, 0, D.PERMANENT, G.CONTROLLER)
	_add_item(result, "field_bandage", "Field Bandage", "Mend 3 damage from one of your creatures.", 3, CardEnums.EffectOp.HEAL, 3, 0, D.PERMANENT, G.CHOSEN_CREATURE_ALLY)
	_add_item(result, "scroll_of_insight", "Scroll of Insight", "Draw a card.", 2, CardEnums.EffectOp.DRAW, 1, 0, D.PERMANENT, G.CONTROLLER)
	_add_item(result, "firebrand_charm", "Firebrand Charm", "Deal 2 damage to an enemy creature.", 2, CardEnums.EffectOp.DEAL_DAMAGE, 2, 0, D.PERMANENT, G.CHOSEN_CREATURE_ENEMY)
	_add_item(result, "sharpening_stone", "Sharpening Stone", "Give a creature +2/+2 until end of turn.", 3, CardEnums.EffectOp.BUFF, 2, 2, D.END_OF_TURN, G.CHOSEN_CREATURE_ALLY)
	_add_item(result, "binding_chains", "Binding Chains", "Return an enemy creature to its owner's hand.", 1, CardEnums.EffectOp.RETURN_TO_HAND, 0, 0, D.PERMANENT, G.CHOSEN_CREATURE_ENEMY)
	_add_item(result, "silence_powder", "Silence Powder", "The opponent discards a random card.", 2, CardEnums.EffectOp.DISCARD, 1, 0, D.PERMANENT, G.OPPONENT)
	_add_item(result, "grave_dust", "Grave Dust", "The opponent mills 3 cards.", 2, CardEnums.EffectOp.MILL, 3, 0, D.PERMANENT, G.OPPONENT)
	var spirit: CardData = tokens.get("token_spirit") as CardData
	if spirit == null:
		spirit = CardBuilder.token("token_spirit", "Spirit", 1, 1)
	_add_item(result, "summoning_charm", "Summoning Charm", "Summon a 1/1 Spirit token.", 1, CardEnums.EffectOp.SUMMON_TOKEN, 1, 0, D.PERMANENT, G.CONTROLLER, null, spirit)
	_add_item(result, "ward_sigil", "Ward Sigil", "Give a creature Guard until end of turn.", 2, CardEnums.EffectOp.GRANT_KEYWORD, 0, 0, D.END_OF_TURN, G.CHOSEN_CREATURE_ALLY, K2.GUARD)
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


static func _add_item(
	result: Dictionary, id: String, title: String, description: String, uses: int,
	op: CardEnums.EffectOp, amount: int, amount2: int = 0,
	duration: CardEnums.Duration = CardEnums.Duration.PERMANENT,
	target: CardEnums.TargetKind = CardEnums.TargetKind.CONTROLLER,
	keyword: Variant = null, token: CardData = null,
) -> void:
	var data: ItemData = ItemData.new()
	data.id = id
	data.display_name = title
	data.description = description
	data.uses = uses
	var effect: EffectData = EffectData.new()
	effect.op = op
	effect.amount = amount
	effect.amount2 = amount2
	effect.duration = duration
	effect.target = target
	if keyword != null:
		effect.keyword = keyword as CardEnums.Keyword
	if token != null:
		effect.token = token
	data.effect = effect
	result[id] = data
