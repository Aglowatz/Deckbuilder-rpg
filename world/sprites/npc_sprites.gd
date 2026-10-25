class_name NpcSprites
extends RefCounted
## Which painted sprite set draws which list NPC (docs/art/world_rollout.md, "NPC sprites"). The set is the manifest key `SpriteLibrary` imported from the batch
## sheet (`tools/import_npc_sprites.sh`): the NPC ID without its prefix (NPC-HOB -> HOB, V-SABLE -> SABLE). Anything without a set stays a 3D model.

## List NPCs whose art carries another key (Rollo Spokes was Gus; his sprites are SPR-GUS).
const KEY_ALIASES: Dictionary = {"NPC-ROLLO": "GUS"}
## Characters that appear in the world as someone else's look (the Doppelganger in the Buffet is disguised as Escoffina).
const DISGUISES: Dictionary = {"NPC-DOPPEL": "ESCOFFINA"}
## The four ghosts: opacity, how high they float above the ground and how far they drift (metres).
const GHOSTS: Dictionary = {
	"ECTOMUND": {"alpha": 0.74, "hover": 0.16, "bob": 0.07},
	"KYLE": {"alpha": 0.7, "hover": 0.14, "bob": 0.07},
	"GERALD": {"alpha": 0.72, "hover": 0.15, "bob": 0.06},
	"AGNES": {"alpha": 0.72, "hover": 0.15, "bob": 0.06},
}
## The throwers are Big Hurl's set, the portal rippers and Beefcake station operators Rip Tearson's.
const THROWER: String = "HURL"
const RIPPER: String = "RIP"
## The facade citizens' subtle per-copy tints (a coat that is a shade off, never a different colour).
const CITIZEN_TINTS: Array[Color] = [
	Color(1.0, 1.0, 1.0), Color(1.0, 0.92, 0.9), Color(0.92, 0.97, 1.0), Color(0.96, 1.0, 0.92), Color(1.0, 0.96, 0.86),
	Color(0.94, 0.92, 1.0), Color(1.0, 0.9, 0.96), Color(0.9, 1.0, 0.98), Color(1.0, 0.94, 0.9),
]
## The corrupted four of the town are the same figures in their corrupted look (the freed look has no art yet).
const CORRUPTED: Dictionary = {"beefcake": "NPC-BRONSON", "gourmand": "NPC-GRAVOIS", "refusemancer": "NPC-MULLIGAN", "necrocrat": "NPC-PALLOR"}
## Fixes Oct 25, Part 3: heights (relative to the hero) that override the batch sheet's, which a re-import would bring back. Old Man
## Mountain is a yeti: the sheet's 0.6 drew him smaller than the hero; 1.5 reads as big beside the hero and still fits under the gym's lintel.
const HEIGHT_OVERRIDES: Dictionary = {"MOUNTAIN": 1.5}
## Meters above the top of a figure where a plate or quest marker floats.
const LABEL_GAP: float = 0.3


## The relative height (hero = 1.0) a character is drawn at: an override, else the manifest's `fallback`.
static func rel_height(character: String, fallback: float) -> float:
	return float(HEIGHT_OVERRIDES.get(character, fallback))


## The sprite character of a list NPC ID, "" when the NPC has no world sprite set (or the art is not imported).
static func character_for(npc_id: String) -> String:
	if npc_id == "" or npc_id == NpcRegistry.PLAYER_ID:
		return ""
	var source: String = str(DISGUISES.get(npc_id, ""))
	var key: String = source if source != "" else str(KEY_ALIASES.get(npc_id, npc_id.substr(npc_id.find("-") + 1)))
	if key == "PLAYER" or key == "VILLAGER" or not SpriteLibrary.has_character(key):
		return ""
	return key


## The character a zone / town NPC entry is drawn with: an explicit `sprite` key, else the list NPC ID's set. "" keeps the 3D model.
static func character_for_entry(entry: Dictionary) -> String:
	var explicit: String = str(entry.get("sprite", ""))
	if explicit != "":
		return explicit if SpriteLibrary.has_character(explicit) else ""
	return character_for(str(entry.get("npc_id", "")))


## A standing painted NPC ready to be placed with `ModelKit.place(parent, actor, pos, yaw, TownPlayer.MODEL_SCALE)`.
static func make_actor(character: String, tint: Color = Color.WHITE) -> SpriteActor:
	var actor: SpriteActor = SpriteActor.new()
	actor.character = character
	actor.follow_cosmetics = false
	actor.natural_scale = TownPlayer.MODEL_SCALE
	actor.turn_rate_degrees = 420.0
	actor.tint = tint
	actor.name = "Sprite_%s" % character.capitalize()
	return actor


static func ghost_style(character: String) -> Dictionary:
	return GHOSTS.get(character, {}) as Dictionary


## Height (metres above the feet) at which a name plate / quest marker of an NPC node sits; `fallback` for a 3D model.
static func label_height(node: Node, fallback: float) -> float:
	if not (node is SpriteActor or node is SpriteStroller):
		return fallback
	var sprite: WorldSprite = node.get("sprite") as WorldSprite
	return sprite.head_height() + LABEL_GAP if sprite != null else fallback


## The Beefcake who runs a Rift Express station: Rip Tearson's painted set when it is imported, else the tinted Barbarian model.
## Returns {"node": Node3D, "scale": float} - the multiplier on `TownPlayer.MODEL_SCALE` the caller places it with.
static func rift_operator() -> Dictionary:
	if SpriteLibrary.has_character(RIPPER):
		return {"node": make_actor(RIPPER), "scale": 1.0}
	var model: Node3D = ModelKit.character("Barbarian")
	ModelKit.tint(model, Color(1.0, 0.8, 0.65))
	return {"node": model, "scale": 1.3}


## Apparel Part 4: the Rescuer's sprite set: the disguise (SPR-RESCUER) until she is named at the castle gate, if it is imported; ELOWEN otherwise.
static func rescuer_key() -> String:
	return RescuerDisguise.sprite_key(SpriteLibrary.has_character(RescuerDisguise.SPRITE))
