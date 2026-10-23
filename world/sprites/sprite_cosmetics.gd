class_name SpriteCosmetics
extends RefCounted
## Puts a `CosmeticState` (hat, cloak, cloak dye) on a `WorldSprite`: a cloak swaps the whole sprite set, a hat becomes a card on the head, the dye recolours the cloak.
## Items whose art has not been imported yet change nothing (the default look stays), so nothing breaks while the art is on its way.

## Hats whose imported sheet is held back for a redo (docs/art/import_oct22_final.md): treated as "arriving soon" (not sold, not worn) until a good sheet
## replaces it. LEAFCROWN is painted as an upright ring, so on the hero it stands on the head like a hoop instead of lying on the hair.
const HELD_HATS: Array[String] = ["LEAFCROWN"]


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
		return not HELD_HATS.has(item.art_name) and SpriteLibrary.has_hat(item.art_name)
	return SpriteLibrary.has_cloak(item.art_name)


static func apply(sprite: WorldSprite, state: CosmeticState) -> void:
	if sprite == null:
		return
	var cloak_art: String = art_name(state.cloak_id) if state != null else ""
	sprite.set_character(SpriteLibrary.cloak_character(cloak_art))
	var hat_art: String = art_name(state.hat_id) if state != null else ""
	sprite.set_hat("" if HELD_HATS.has(hat_art) else hat_art)
	var dye: int = state.cloak_dye if state != null else Dye.NATURAL
	# Apparel Part 3: the dye recolours the plain hooded cloak only. It finds the cloak by its hue, and a red cape sits next to the hair and skin hues, a patchwork has
	# many; the four named cloaks wear their own colours.
	if dye >= 0 and dye_applies(state):
		sprite.set_dye(Dye.primary(dye), 1.0)
	else:
		sprite.set_dye(Color.WHITE, 0.0)


## True when the cloak dye shows on this look (Apparel Part 3: only on the plain hooded cloak).
static func dye_applies(state: CosmeticState) -> bool:
	return state == null or art_name(state.cloak_id) == "" or not SpriteLibrary.has_cloak(art_name(state.cloak_id))
