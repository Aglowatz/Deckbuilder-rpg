class_name RescuerDisguise
extends RefCounted
## Apparel Part 4: from the prologue until Percival Plume names her at the castle gate (the flag `rescuer_named`, set mid-way through the `pc_capture` scene), the
## Rescuer travels disguised - hooded, her face behind a dark scarf, a dark cloak over the white lab coat. Every appearance in that stretch (the prologue, the Cave
## Mouth scenes, the castle gate up to the reveal) uses the disguise art NPC-RESCUER / SPR-RESCUER; from the reveal on, NPC-ELOWEN / SPR-ELOWEN. While the disguise
## art is not imported the old look stays. She keeps ONE NPC id (NPC-ELOWEN): only the picture changes.

const TRUE_ID: String = "NPC-ELOWEN"
const PORTRAIT: String = "NPC-RESCUER"
const SPRITE: String = "RESCUER"
const TRUE_SPRITE: String = "ELOWEN"


## True while she is still the unnamed Rescuer.
static func disguised() -> bool:
	return not RoyalFamily.rescuer_named()


## The portrait to draw for the Portrait Image ID `id`: the disguise for Elowen's portrait while she is unnamed and the disguise portrait exists, else `id` itself.
static func portrait_id(id: String) -> String:
	return portrait_for(id, RoyalFamily.rescuer_named(), Portraits.has_portrait(PORTRAIT))


## The rule itself (pure, for tests): who is shown for `id`, given the reveal and whether the disguise art exists.
static func portrait_for(id: String, named: bool, disguise_imported: bool) -> String:
	return PORTRAIT if id == TRUE_ID and not named and disguise_imported else id


## The sprite set key for her, given whether the disguise set is imported (the scene asks SpriteLibrary).
static func sprite_key(disguise_imported: bool) -> String:
	return SPRITE if disguise_imported and disguised() else TRUE_SPRITE
