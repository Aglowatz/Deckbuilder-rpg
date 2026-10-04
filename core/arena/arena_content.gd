class_name ArenaContent
extends RefCounted
## Brief 9, Part G: the four arena-exclusive pieces of equipment (prizes of the Grand Clashatorium, never sold). Each one
## runs on a NEW modifier hook added for it (`Modifier.Kind.START_OF_DUEL_EFFECT`, `ON_ATTACK_DECLARED_EFFECT`,
## `ON_ENEMY_CREATURE_ENTER_EFFECT`, `ON_PLAYER_DAMAGED_EFFECT`), all resolved through the normal Modifier pipeline.

const K := Modifier.Kind
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp

const IDS: Array[String] = ["champions_laurels", "crowd_pleasers_cape", "gladiators_net", "bloodsand_boots"]


static func add_equipment(result: Dictionary) -> void:
	var laurels: EquipmentData = _piece("champions_laurels", "Champion's Laurels", EquipmentData.Slot.HELM,
		"At the start of the duel, gain 4 life and draw a card.",
		[ProgressionContent._mod_effect(K.START_OF_DUEL_EFFECT, ProgressionContent._effect(O.GAIN_LIFE, 4, G.CONTROLLER)), ProgressionContent._mod_effect(K.START_OF_DUEL_EFFECT, ProgressionContent._effect(O.DRAW, 1, G.CONTROLLER))])
	laurels.flavor_text = "A little wilted, a little sweaty, entirely yours. The crowd chants your name. Mostly."
	result[laurels.id] = laurels
	var cape: EquipmentData = _piece("crowd_pleasers_cape", "Crowd-Pleaser's Cape", EquipmentData.Slot.ARMOR,
		"Each time you declare attackers, gain 1 life.",
		[ProgressionContent._mod_effect(K.ON_ATTACK_DECLARED_EFFECT, ProgressionContent._effect(O.GAIN_LIFE, 1, G.CONTROLLER))])
	cape.flavor_text = "Every charge earns a roar, and every roar is oddly nourishing."
	result[cape.id] = cape
	var net: EquipmentData = _piece("gladiators_net", "Gladiator's Net", EquipmentData.Slot.WEAPON,
		"Whenever an enemy creature enters the battlefield, it gets -1/-1 permanently.",
		[ProgressionContent._mod_effect(K.ON_ENEMY_CREATURE_ENTER_EFFECT, ProgressionContent._effect_ab(O.BUFF, -1, -1, G.TRIGGERING_CARD))])
	net.flavor_text = "Thrown from the stands by a very enthusiastic fishmonger. It holds, apparently."
	result[net.id] = net
	var boots: EquipmentData = _piece("bloodsand_boots", "Bloodsand Boots", EquipmentData.Slot.BOOTS,
		"Whenever you are dealt damage, draw a card.",
		[ProgressionContent._mod_effect(K.ON_PLAYER_DAMAGED_EFFECT, ProgressionContent._effect(O.DRAW, 1, G.CONTROLLER))])
	boots.flavor_text = "Every scar teaches you something. These boots have taken notes."
	result[boots.id] = boots


static func _piece(id: String, title: String, slot: EquipmentData.Slot, description: String, modifiers: Array[Modifier]) -> EquipmentData:
	return ProgressionContent._piece(id, title, slot, description, modifiers, false)
