class_name SpriteCosmetics
extends RefCounted
## Puts a `CosmeticState` (hat, cloak, cloak dye) on a `WorldSprite`: a cloak swaps the whole sprite set, a hat becomes a card on the head, the dye recolours the cloak.
## Items whose art has not been imported yet change nothing (the default look stays), so nothing breaks while the art is on its way.


## The art name (WIZARD, REDCAPE, ...) of an item id, "" for none or an unknown id.
static func art_name(item_id: String) -> String:
	if item_id == "":
		return ""
	var item: CosmeticData = CosmeticCatalog.find(item_id)
	return item.art_name if item != null else ""


## True when the art of this item is imported and complete: the hat's five images, or the cloak's whole sprite set.
static func art_ready(item: CosmeticData) -> bool:
	if item == null or item.art_name == "":
		return false
	if item.slot == CosmeticData.Slot.HAT:
		return SpriteLibrary.has_hat(item.art_name)
	return SpriteLibrary.has_cloak(item.art_name)


static func apply(sprite: WorldSprite, state: CosmeticState) -> void:
	if sprite == null:
		return
	var cloak_art: String = art_name(state.cloak_id) if state != null else ""
	sprite.set_character(SpriteLibrary.cloak_character(cloak_art))
	sprite.set_hat(art_name(state.hat_id) if state != null else "")
	var dye: int = state.cloak_dye if state != null else Dye.NATURAL
	if dye >= 0:
		sprite.set_dye(Dye.primary(dye), 1.0)
	else:
		sprite.set_dye(Color.WHITE, 0.0)
