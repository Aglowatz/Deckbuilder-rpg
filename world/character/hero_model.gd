class_name HeroModel
extends RefCounted
## The playable hero: the unarmored KayKit Rogue (leather tunic, no weapons, no cape) with a hat on the head bone and a swaying cloak on the chest bone.
## Equipment (helm, armor, ...) is stat-only and never drawn: only the two cosmetic slots show. Used by the town/zone player, the wardrobe preview and the tailor.

const BASE_MODEL: String = "res://assets/KayKit-Character-Pack-Adventures-1.0/Characters/Rogue.glb"
const GEAR_NODES: PackedStringArray = ["Knife_Offhand", "1H_Crossbow", "2H_Crossbow", "Knife", "Throwable", "Rogue_Cape"]
const HAT_NODE: String = "HatSlot"
const CLOAK_NODE: String = "CloakSlot"


## A fresh hero model wearing `state` (or the session's cosmetics when null). The returned node is the glTF root (an AnimationPlayer inside plays Idle / Walking_A / ...).
static func build(state: CosmeticState = null) -> Node3D:
	var model: Node3D = ModelKit.scene(BASE_MODEL).instantiate() as Node3D
	model.name = "Hero"
	model.set_meta("hero_model", true)
	ContactShadow.attach(model, 0.5)
	_hide_gear(model)
	refresh(model, state if state != null else Session.cosmetics)
	return model


static func _hide_gear(model: Node3D) -> void:
	for node_name: String in GEAR_NODES:
		for node: Node in model.find_children(node_name, "Node3D", true, false):
			(node as Node3D).visible = false


static func skeleton_of(model: Node) -> Skeleton3D:
	var found: Array[Node] = model.find_children("*", "Skeleton3D", true, false)
	return found[0] as Skeleton3D if not found.is_empty() else null


## Rebuilds the hat and the cloak from `state` (old ones are removed).
static func refresh(model: Node3D, state: CosmeticState) -> void:
	var skeleton: Skeleton3D = skeleton_of(model)
	if skeleton == null:
		return
	_clear(skeleton, HAT_NODE)
	_clear(skeleton, CLOAK_NODE)
	if state == null:
		return
	if state.hat_id != "":
		var hat: Node3D = CosmeticMeshes.build_hat(state.hat_id, state.hat_dye)
		if hat != null:
			var slot: BoneAttachment3D = _slot(skeleton, HAT_NODE, "head")
			slot.add_child(hat)
			hat.position = CosmeticMeshes.HAT_OFFSET
			_toon(hat)
	if state.cloak_id != "":
		var cloak: Node3D = CosmeticMeshes.build_cloak(state.cloak_id, state.cloak_dye)
		if cloak != null:
			var slot2: BoneAttachment3D = _slot(skeleton, CLOAK_NODE, "chest")
			slot2.add_child(cloak)
			cloak.position = CosmeticMeshes.CLOAK_OFFSET
			CloakSway.attach(cloak, model, 1.35 if bool(cloak.get_meta("scarf", false)) else 1.0)
			_toon(cloak)


static func _clear(skeleton: Skeleton3D, slot_name: String) -> void:
	var old: Node = skeleton.get_node_or_null(slot_name)
	if old != null:
		skeleton.remove_child(old)
		old.queue_free()


static func _slot(skeleton: Skeleton3D, slot_name: String, bone: String) -> BoneAttachment3D:
	var attachment: BoneAttachment3D = BoneAttachment3D.new()
	attachment.name = slot_name
	attachment.bone_name = bone
	skeleton.add_child(attachment)
	return attachment


## Cosmetics are built after the scene's StyleRig converted its meshes (the rig also catches late additions, the wardrobe preview has no rig): convert directly.
static func _toon(node: Node) -> void:
	StyleToon.apply(node)


## Names of the animations the hero needs (all present on the KayKit rig).
static func has_core_animations(model: Node) -> bool:
	var player: AnimationPlayer = ModelKit.animation_player(model)
	if player == null:
		return false
	for animation_name: String in ["Idle", "Walking_A", "Running_A", "Interact"]:
		if not player.has_animation(animation_name):
			return false
	return true


## Fixed outfits for the hero-shaped NPCs and display mannequins (the tailor and her window dummy): [hat id, hat dye, cloak id, cloak dye].
const NPC_LOOKS: Dictionary = {
	"tailor": ["hat_top_hat", 10, "cloak_scarf", 8],
	"mannequin": ["hat_party", 7, "cloak_star", 6],
}


static func npc_look(kind: String) -> CosmeticState:
	var spec: Array = NPC_LOOKS.get(kind, ["", 0, "", 0]) as Array
	var look: CosmeticState = CosmeticState.new()
	for item_id: String in [str(spec[0]), str(spec[2])]:
		if item_id != "":
			look.grant(item_id)
	look.equip(CosmeticData.Slot.HAT, str(spec[0]))
	look.equip(CosmeticData.Slot.CLOAK, str(spec[2]))
	look.set_dye(CosmeticData.Slot.HAT, int(spec[1]))
	look.set_dye(CosmeticData.Slot.CLOAK, int(spec[3]))
	return look
