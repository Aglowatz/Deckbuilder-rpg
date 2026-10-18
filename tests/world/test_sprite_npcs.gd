extends GutTest
## Part D of the world rollout and the NPC sprite rollout: every town NPC of the list (Elder Maren, Gatekeeper Brannoch, Sable, Tilly Tonic, Foil Fenwick, Bertram Beetsworth,
## Pip Threadwell, the four corrupted NPCs, the badger baker) is a painted sprite in the town: they turn to face the hero when he is near and use their TALK pose while the
## dialogue is open; the shop-window mannequin and the Secret Dealer (no list NPC) are still 3D models.

const SPRITE_NPCS: Dictionary = {
	"elder": "ELDER", "guard": "GATEKEEPER", "vendor": "SABLE", "item_vendor": "TONIC", "pack_vendor": "FENWICK",
	"equipment_vendor": "BEETSWORTH", "tailor": "THREADWELL",
	"npc_beefcake": "BRONSON", "npc_gourmand": "GRAVOIS", "npc_refusemancer": "MULLIGAN", "npc_necrocrat": "PALLOR",
}


func _town() -> TownScene:
	Session.save_enabled = false
	var scene: TownScene = (load("res://scenes/town.tscn") as PackedScene).instantiate() as TownScene
	add_child_autofree(scene)
	return scene


func test_the_town_npcs_are_sprites_and_only_the_unnamed_ones_are_models() -> void:
	var town: TownScene = _town()
	await get_tree().process_frame
	for id: String in SPRITE_NPCS.keys():
		var npc: Node3D = town._npcs[id] as Node3D
		assert_true(npc is SpriteActor, "%s is a painted sprite" % id)
		assert_eq((npc as SpriteActor).character, SPRITE_NPCS[id])
		assert_true(SpriteLibrary.info(str(SPRITE_NPCS[id])).get("has_talk", false), "%s has a TALK pose" % id)
	for id: String in ["mannequin"]:
		assert_false((town._npcs[id] as Node3D) is SpriteActor, "%s is still a 3D model (a shop-window dummy, no list NPC)" % id)
	assert_not_null(town._baker, "the badger baker walks the plaza")
	assert_eq(town._baker.character, "VILLAGER")


func test_they_use_the_talk_pose_during_dialogue_and_face_the_hero() -> void:
	var town: TownScene = _town()
	await get_tree().process_frame
	var elder: SpriteActor = town._npcs["elder"] as SpriteActor
	town.player.position = elder.position + Vector3(0.0, 0.0, 2.0)
	town._talk_npc("elder", "Elder Maren", ["Hello."] as Array[String])
	for frame: int in range(8):
		await get_tree().process_frame
	assert_true(town.dialogue.active)
	assert_true(elder.talking, "the TALK pose while the dialogue is open")
	assert_eq(elder.sprite.current_key, "FRONT_TALK")
	var guard: SpriteActor = town._npcs["guard"] as SpriteActor
	assert_false(guard.talking, "only the one being talked to")
	while town.dialogue.active:
		town.dialogue.press()
		await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	assert_false(elder.talking)
	# Close to the hero an NPC turns to him (the idle life of every NPC: NpcHp).
	var sable: SpriteActor = town._npcs["vendor"] as SpriteActor
	town.player.position = sable.position + Vector3(1.6, 0.0, 0.0)
	for frame: int in range(300):
		await get_tree().process_frame
	var yaw: float = sable.rotation.y
	var expected: float = atan2(1.6, 0.0)
	assert_almost_eq(angle_difference(yaw, expected), 0.0, 0.45, "Sable turned towards the hero")


func test_the_baker_is_talkable_and_wanders() -> void:
	var town: TownScene = _town()
	await get_tree().process_frame
	var start: Vector3 = town._baker.world_position()
	for frame: int in range(240):
		await get_tree().process_frame
	var spot: TownScene.Spot = null
	for candidate: TownScene.Spot in town.spots:
		if candidate.id == "baker":
			spot = candidate
	assert_not_null(spot, "he has a talk spot")
	assert_almost_eq(spot.position.distance_to(town._baker.world_position()), 0.0, 0.01, "the spot follows him")
	assert_gt(town._baker.world_position().distance_to(start), 0.3, "he walked somewhere in four seconds")
	assert_true(town.town.is_walkable(town._baker.world_position(), 0.2), "and stayed on the town's paths")


## Overnight Oct 17 (Phase 2, NPC life): two townsfolk stroll their own loops away from the square, stay on walkable ground and talk to passers-by.
func test_townsfolk_stroll_their_own_loops() -> void:
	var town: TownScene = _town()
	await get_tree().process_frame
	assert_eq(town._strollers.size(), 3, "three strollers besides the baker (well yard, Maren's lane, Arena gate)")
	var starts: Array[Vector3] = []
	for stroller: SpriteWanderer in town._strollers:
		assert_eq(stroller.character, "VILLAGER", "Playtest v0.4.0 Part B: CITIZEN only walks the Capital")
		starts.append(stroller.world_position())
	for _frame: int in range(240):
		await get_tree().process_frame
	var moved: int = 0
	for index: int in range(town._strollers.size()):
		var stroller: SpriteWanderer = town._strollers[index]
		assert_true(town.town.is_walkable(stroller.world_position(), 0.2), "stroller %d stays on walkable ground" % index)
		if stroller.world_position().distance_to(starts[index]) > 0.3:
			moved += 1
	assert_gt(moved, 0, "they walk")
	assert_gte(town.npc_barks.entry_count(), 13, "the town's NPCs, the baker and the strollers all have lines")
