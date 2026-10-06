class_name ProgressionContent
extends RefCounted
## Equipment (New brief, Part B - 10 real pieces, 2 per slot, replacing the original 5
## placeholders) and items. Written to .tres by tools/generate_content.gd.

const K := Modifier.Kind
const KW := CardEnums.Keyword


## New brief, Part B: 10 pieces, 2 per slot - a "basic" (tier 1) piece stocked at the equipment
## vendor from the start, and an "advanced" (tier 2) piece locked behind a level-up reward (see
## docs/design/progression.md). Every effect goes through the Modifier pipeline; new Modifier.Kind
## values added for this brief are documented in core/data/modifier.gd.
static func equipment() -> Dictionary:
	var result: Dictionary = {}
	_add(result, _piece("wicked_dagger", "Wicked Dagger", EquipmentData.Slot.WEAPON, "A blade with a reputation it didn't earn honestly. Your units get +1 attack.", [_mod(K.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0)]))
	_add(result, _piece("flamethrower", "Flamethrower", EquipmentData.Slot.WEAPON, "Alchemist's fire in a backpack tank. At the start of your turn, deal 1 damage to each opposing unit.", [_mod_effect(K.START_OF_TURN_EFFECT, _effect(CardEnums.EffectOp.DEAL_DAMAGE, 1, CardEnums.TargetKind.ALL_ENEMY_UNITS))], true))
	_add(result, _piece("extra_pocket", "Extra Pocket", EquipmentData.Slot.RELIC, "Sewn in where no one thinks to look. Max hand size +1.", [_mod(K.MAX_HAND_SIZE, 1)]))
	_add(result, _piece("cheaters_dice", "Cheater's Dice", EquipmentData.Slot.RELIC, "They only ever land the way you need them to. You always go first, but your opening hand is 1 card smaller.", [_mod(K.ALWAYS_FIRST, 1), _mod(K.OPENING_HAND_SIZE, -1)], true))
	_add(result, _piece("travelers_boots", "Traveler's Boots", EquipmentData.Slot.BOOTS, "Worn thin by roads longer than this one. Draw an extra card at the start of your first turn.", [_mod(K.FIRST_TURN_EXTRA_DRAW, 1)]))
	_add(result, _piece("hover_boots", "Hover Boots", EquipmentData.Slot.BOOTS, "A finger's width of clearance, always. Your units have Flying but cannot block.", [_mod(K.GRANT_KEYWORD_TO_UNITS, int(KW.FLYING), Modifier.ANY_COLOR, 0), _mod(K.CANNOT_BLOCK, 1)], true))
	_add(result, _piece("solid_plate", "Solid Plate", EquipmentData.Slot.ARMOR, "Unglamorous, unyielding. Your units get +1 defense.", [_mod(K.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)]))
	_add(result, _piece("thorned_loincloth", "Thorned Loincloth", EquipmentData.Slot.ARMOR, "Nobody enjoys being the one who has to remove this from a corpse. Max HP -5; whenever an enemy unit attacks you, it takes 1 damage.", [_mod(K.MAX_HP, -5), _mod_effect(K.RETALIATE_ON_ATTACK, _effect(CardEnums.EffectOp.DEAL_DAMAGE, 1, CardEnums.TargetKind.ALL_ATTACKERS))], true))
	_add(result, _piece("xray_goggles", "X-Ray Goggles", EquipmentData.Slot.HELM, "Everything looks the same underneath. The opponent's hand is revealed to you - it doesn't see through a face-down trap, though.", [_mod(K.REVEAL_OPPONENT_HAND, 1)]))
	_add(result, _piece("big_brain_beret", "Big Brain Beret", EquipmentData.Slot.HELM, "It itches, but it's undeniably working. Draw an extra card each turn, but you can play only one non-infrastructure card per turn.", [_mod(K.EXTRA_DRAWS, 1), _mod(K.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN, 1)], true))
	return result


## Brief 5: equipment that only the D.N.A. zone hands out (kept out of `equipment`, which the town
## equipment vendor and its tests treat as the 10 vendor pieces).
static func zone_equipment() -> Dictionary:
	var result: Dictionary = {}
	_add(result, _piece("courier_lanyard", "Soul Courier's Lanyard", EquipmentData.Slot.RELIC, "Everything is routed exactly where you need it. Draw an extra card on your first turn, and max hand size +1.", [_mod(K.FIRST_TURN_EXTRA_DRAW, 1), _mod(K.MAX_HAND_SIZE, 1)], true))
	_add(result, _piece("swole_belt", "Gainsmith's Lifting Belt", EquipmentData.Slot.ARMOR, "Brace the core, brace the deck. Max HP +3 and your units get +1 defense.", [_mod(K.MAX_HP, 3), _mod(K.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)], true))
	_add(result, _piece("head_chef_ladle", "Head Chef's Ladle", EquipmentData.Slot.WEAPON, "Heavy, battered and trusted by a hundred golems. At the start of your turn, gain 1 HP.", [_mod_effect(K.START_OF_TURN_EFFECT, _effect(CardEnums.EffectOp.GAIN_HP, 1, CardEnums.TargetKind.CONTROLLER))], true))
	_add(result, _piece("seed_satchel", "Refusemancer Seed Satchel", EquipmentData.Slot.RELIC, "Every pocket holds something that wants to grow. At the start of your turn, your units get +0/+1 permanently.", [_mod_effect(K.START_OF_TURN_EFFECT, _effect_ab(CardEnums.EffectOp.BUFF, 0, 1, CardEnums.TargetKind.ALL_ALLY_UNITS))], true))
	_add_zone_pieces(result)
	ArenaContent.add_equipment(result)
	return result


const G := CardEnums.TargetKind
const D := CardEnums.Duration
const K2 := CardEnums.Keyword


## `tokens` is the same dict `ContentDefinitions.build_tokens()` produces - Summoning Charm summons the sheet's Militia token.
static func items(tokens: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {}
	_add_item(result, "healing_draught", "Healing Draught", "A common camp remedy.", 3, CardEnums.EffectOp.GAIN_HP, 3)
	_add_item(result, "vitality_charm", "Vitality Charm", "A small, steady comfort.", 2, CardEnums.EffectOp.GAIN_HP, 2)
	_add_item(result, "reckless_tonic", "Reckless Tonic", "One big gulp - use it wisely, there is only one.", 1, CardEnums.EffectOp.GAIN_HP, 6)
	# New brief, Part F: 10 basic consumables, usable in battle (item bar, targeting where the
	# effect needs it) as well as between fights - the same effect either way.
	_add_item(result, "healing_salve", "Healing Salve", "Heal 4 HP.", 3, CardEnums.EffectOp.GAIN_HP, 4, 0, D.PERMANENT, G.CONTROLLER)
	_add_item(result, "field_bandage", "Field Bandage", "Mend 3 damage from one of your units.", 3, CardEnums.EffectOp.HEAL, 3, 0, D.PERMANENT, G.CHOSEN_UNIT_ALLY)
	_add_item(result, "scroll_of_insight", "Scroll of Insight", "Draw a card.", 2, CardEnums.EffectOp.DRAW, 1, 0, D.PERMANENT, G.CONTROLLER)
	_add_item(result, "firebrand_charm", "Firebrand Charm", "Deal 2 damage to an enemy unit.", 2, CardEnums.EffectOp.DEAL_DAMAGE, 2, 0, D.PERMANENT, G.CHOSEN_UNIT_ENEMY)
	_add_item(result, "sharpening_stone", "Sharpening Stone", "Give a unit +2/+2 until end of turn.", 3, CardEnums.EffectOp.BUFF, 2, 2, D.END_OF_TURN, G.CHOSEN_UNIT_ALLY)
	_add_item(result, "binding_chains", "Binding Chains", "Return an enemy unit to its owner's hand.", 1, CardEnums.EffectOp.SEND_BACK, 0, 0, D.PERMANENT, G.CHOSEN_UNIT_ENEMY)
	_add_item(result, "silence_powder", "Silence Powder", "The opponent tosses a random card.", 2, CardEnums.EffectOp.TOSS, 1, 0, D.PERMANENT, G.OPPONENT)
	_add_item(result, "grave_dust", "Grave Dust", "The opponent buries their top 3 cards.", 2, CardEnums.EffectOp.BURY, 3, 0, D.PERMANENT, G.OPPONENT)
	var militia: CardData = tokens.get("T-16") as CardData
	if militia == null:
		militia = CardBuilder.token("T-16", "Militia", 1, 1)
	_add_item(result, "summoning_charm", "Summoning Charm", "Summon a 1/1 Militia token.", 1, CardEnums.EffectOp.SUMMON_TOKEN, 1, 0, D.PERMANENT, G.CONTROLLER, null, militia)
	_add_item(result, "ward_sigil", "Ward Sigil", "Give a unit Untouchable until end of turn.", 2, CardEnums.EffectOp.GRANT_KEYWORD, 0, 0, D.END_OF_TURN, G.CHOSEN_UNIT_ALLY, K2.UNTOUCHABLE)
	_add_item(result, "hearty_pie", "Hearty Pot Pie", "Baked at the Grand Pantry oven. Heal 6 HP.", 1, CardEnums.EffectOp.GAIN_HP, 6, 0, D.PERMANENT, G.CONTROLLER)
	return result


static func _piece(id: String, title: String, slot: EquipmentData.Slot, description: String, modifiers: Array[Modifier], advanced: bool = false) -> EquipmentData:
	var piece: EquipmentData = EquipmentData.new()
	piece.id = id
	piece.source_name = title
	piece.source_kind = ModifierSource.SourceKind.EQUIPMENT
	piece.slot = slot
	piece.description = description
	piece.modifiers = modifiers
	piece.advanced = advanced
	return piece


static func _mod(kind: Modifier.Kind, value: int, color: int = Modifier.ANY_COLOR, value2: int = 0) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.value = value
	modifier.value2 = value2
	modifier.color = color
	return modifier


## A modifier whose payload is a full EffectData (START_OF_TURN_EFFECT, RETALIATE_ON_ATTACK, ...).
static func _mod_effect(kind: Modifier.Kind, effect_data: EffectData) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.effect = effect_data
	return modifier


static func _effect(op: CardEnums.EffectOp, amount: int, target: CardEnums.TargetKind) -> EffectData:
	var effect: EffectData = EffectData.new()
	effect.op = op
	effect.amount = amount
	effect.target = target
	return effect


static func _effect_ab(op: CardEnums.EffectOp, amount: int, amount2: int, target: CardEnums.TargetKind) -> EffectData:
	var effect: EffectData = _effect(op, amount, target)
	effect.amount2 = amount2
	return effect


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


## Brief 8, Part C: one extra piece per zone beyond the puzzle rewards, each with its own new modifier hook (slots varied:
## relic, weapon, helm, boots). Obtained as zone quest rewards (see `ZoneQuestDefinitions`):
##  - Compliance Clipboard (D.N.A., relic)       <- *Compliance Audit* (END_OF_TURN_EFFECT)
##  - Spotter's Barbell (Gainlands, weapon)      <- *Clear the Lanes* (ON_CREATURE_ENTER_EFFECT)
##  - Head Chef's Toque (Endless Buffet, helm)   <- *Bake Me a Pie* (LIFE_GAIN_BONUS)
##  - Compost Boots (Verdant Dump, boots)        <- *Unblock the Stream* (ON_ALLY_DEATH_EFFECT)
static func _add_zone_pieces(result: Dictionary) -> void:
	var clipboard: EquipmentData = _piece("compliance_clipboard", "Compliance Clipboard", EquipmentData.Slot.RELIC, "At the end of your turn, the opponent loses 1 HP.", [_mod_effect(K.END_OF_TURN_EFFECT, _effect(CardEnums.EffectOp.LOSE_HP, 1, CardEnums.TargetKind.OPPONENT))], true)
	clipboard.flavor_text = "Every box ticked is a little paper cut. Nobody has ever read what it says."
	_add(result, clipboard)
	var barbell: EquipmentData = _piece("spotters_barbell", "Spotter's Barbell", EquipmentData.Slot.WEAPON, "Whenever a unit enters the field under your control, deal 1 damage to the opponent.", [_mod_effect(K.ON_UNIT_ENTER_EFFECT, _effect(CardEnums.EffectOp.DEAL_DAMAGE, 1, CardEnums.TargetKind.OPPONENT))], true)
	barbell.flavor_text = "Every new face gets a free rep. Somebody is always counting out loud."
	_add(result, barbell)
	var toque: EquipmentData = _piece("head_chef_toque", "Head Chef's Toque", EquipmentData.Slot.HELM, "Whenever you gain HP, gain 1 extra HP.", [_mod(K.HP_GAIN_BONUS, 1)], true)
	toque.flavor_text = "Tall, white and slightly stained. Seconds are always an option while it is on."
	_add(result, toque)
	var boots: EquipmentData = _piece("compost_boots", "Compost Boots", EquipmentData.Slot.BOOTS, "Whenever a unit of yours dies, your units get +0/+1 permanently.", [_mod_effect(K.ON_ALLY_DEATH_EFFECT, _effect_ab(CardEnums.EffectOp.BUFF, 0, 1, CardEnums.TargetKind.ALL_ALLY_UNITS))], true)
	boots.flavor_text = "Squelch, squelch, grow. What falls feeds what stands."
	_add(result, boots)
