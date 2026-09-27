class_name CardIcons
extends RefCounted
## Placeholder card art: game-icons.net silhouettes (see CREDITS.md). Icons are looked up by
## card id; lands and tokens have their own entries.

const BASE: String = "res://assets/icons/game-icons/"

const BY_ID: Dictionary = {
	"sellsword": "lorc/visored-helm",
	"cave_bat": "lorc/bat-wing",
	"stone_sentinel": "lorc/stone-tower",
	"field_medic": "delapouite/first-aid-kit",
	"merchant": "delapouite/coins-pile",
	"ironclad": "lorc/armor-vest",
	"healing_idol": "delapouite/healing",
	"rusty_curse": "lorc/cursed-star",
	"pitfall": "sbed/spikes-full",
	"supply_cache": "skoll/open-treasure-chest",
	"ember_imp": "lorc/imp",
	"blade_dancer": "lorc/sword-spin",
	"raider": "delapouite/viking-head",
	"blazing_charger": "delapouite/charging-bull",
	"firebolt": "lorc/fire-ray",
	"flame_burst": "lorc/flame-spin",
	"warcry": "delapouite/trumpet",
	"scorching_ward": "lorc/fire-shield",
	"frost_sentry": "delapouite/ice-golem",
	"sage": "delapouite/wizard-face",
	"whispering_shade": "lorc/ghost",
	"dissolve": "lorc/acid-blob",
	"recall": "lorc/return-arrow",
	"deep_insight": "lorc/crystal-ball",
	"snare": "lorc/wolf-trap",
	"sea_warden": "delapouite/fish-monster",
	"mossback_bear": "delapouite/bear-head",
	"rampaging_boar": "lorc/boar-tusks",
	"stag_warden": "lorc/stag-head",
	"ancient_treant": "cathelineau/tree-face",
	"thornback_colossus": "delapouite/mammoth",
	"growth": "lorc/sprout",
	"rejuvenate": "delapouite/health-potion",
	"bone_servant": "lorc/skeleton-inside",
	"grave_tender": "lorc/tombstone",
	"martyr": "lorc/bleeding-heart",
	"soul_drain": "lorc/spectre",
	"bloodthirst_wolf": "lorc/wolf-head",
	"dark_bargain": "lorc/broken-skull",
	"necromancer": "delapouite/skull-staff",
	"token_spirit": "lorc/ghost-ally",
	"land_affinity_a": "carl-olsen/flame",
	"land_affinity_b": "lorc/drop",
	"land_affinity_c": "lorc/leaf-swirl",
	"land_affinity_d": "lorc/skull-crossed-bones",
}

const UI_ICONS: Dictionary = {
	"life": "lorc/heart-inside",
	"attack": "lorc/crossed-swords",
	"graveyard": "lorc/tombstone",
	"trap": "sbed/spikes-full",
	"gems": "lorc/gems",
	"hourglass": "lorc/hourglass",
	"magic": "lorc/magic-swirl",
	"fountain": "lorc/fountain",
	"rune": "lorc/rune-stone",
	"campfire": "lorc/campfire",
	"map": "lorc/treasure-map",
	"skull": "lorc/skull-crack",
	"coins": "delapouite/coins-pile",
	"heal": "delapouite/healing",
}

static var _cache: Dictionary = {}


static func for_card(card: CardData) -> Texture2D:
	var key: String = str(BY_ID.get(card.id, ""))
	if key == "":
		key = "lorc/magic-swirl"
	return _load(key)


static func ui(name: String) -> Texture2D:
	return _load(str(UI_ICONS.get(name, "lorc/magic-swirl")))


static func _load(key: String) -> Texture2D:
	if not _cache.has(key):
		_cache[key] = load(BASE + key + ".svg") as Texture2D
	return _cache[key] as Texture2D


static func icon_material(tint: Color) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://ui/shaders/icon_mask.gdshader") as Shader
	material.set_shader_parameter("tint", tint)
	return material


## A TextureRect showing a UI/card icon as a tinted glyph.
static func glyph(texture: Texture2D, tint: Color, size: Vector2) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	rect.texture = texture
	rect.custom_minimum_size = size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.material = icon_material(tint)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect
