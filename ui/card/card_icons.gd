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
	"beefcake_imp": "lorc/imp",
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
	"cubicle_zombie": "delapouite/shambling-zombie",
	"overdue_intern": "darkzaitzev/running-ninja",
	"middle_manager": "delapouite/tie",
	"soul_auditor": "delapouite/warlock-eye",
	"performance_review": "lorc/scroll-unfurled",
	"mandatory_fun_day": "delapouite/party-popper",
	"death_benefits": "delapouite/full-folder",
	"take_a_number": "delapouite/ticket",
	"hr_reaper": "delapouite/plague-doctor-profile",
	"deceased_ceo": "delapouite/imperial-crown",
	"land_affinity_a": "carl-olsen/flame",
	"land_affinity_b": "lorc/drop",
	"land_affinity_c": "lorc/leaf-swirl",
	"land_affinity_d": "lorc/skull-crossed-bones",
}

## New brief, Part F: item icons, looked up by item id (same game-icons.net silhouette style).
const BY_ITEM_ID: Dictionary = {
	"healing_draught": "delapouite/health-potion",
	"vitality_charm": "delapouite/healing",
	"reckless_tonic": "lorc/potion-ball",
	"healing_salve": "delapouite/health-potion",
	"field_bandage": "delapouite/hand-bandage",
	"scroll_of_insight": "lorc/scroll-unfurled",
	"firebrand_charm": "lorc/fire-punch",
	"sharpening_stone": "lorc/muscle-up",
	"binding_chains": "lorc/manacles",
	"silence_powder": "lorc/powder",
	"grave_dust": "delapouite/graveyard",
	"summoning_charm": "lorc/magic-portal",
	"ward_sigil": "delapouite/temporary-shield",
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
	# New brief, Part A: level-up popup bonus-row icons.
	"hand": "lorc/poker-hand",
	"item_slot": "delapouite/backpack",
	"copies": "delapouite/up-card",
	"card_choice": "faithtoken/card-pick",
	"vendor": "delapouite/shop",
	"equipment_unlock": "lorc/unlocking",
	"level_badge": "delapouite/star-medal",
	"lock": "lorc/padlock",
}

## New brief, Part B: equipment piece icons, looked up by equipment id (same silhouette style as
## BY_ITEM_ID). One entry per equipment piece (`data/equipment/*.tres`) - 2 per slot (basic/
## advanced), replacing the original 5 placeholders.
const BY_EQUIPMENT_ID: Dictionary = {
	"wicked_dagger": "lorc/broad-dagger",
	"flamethrower": "delapouite/flamethrower",
	"extra_pocket": "lorc/shiny-purse",
	"cheaters_dice": "delapouite/dice-six-faces-six",
	"travelers_boots": "delapouite/cowboy-boot",
	"hover_boots": "lorc/feathered-wing",
	"solid_plate": "lorc/breastplate",
	"thorned_loincloth": "lorc/spiked-armor",
	"xray_goggles": "delapouite/steampunk-goggles",
	"big_brain_beret": "lorc/brainstorm",
	"courier_lanyard": "delapouite/key-card",
}

static var _cache: Dictionary = {}


static func for_card(card: CardData) -> Texture2D:
	var key: String = str(BY_ID.get(card.id, ""))
	if key == "":
		key = "lorc/magic-swirl"
	return _load(key)


static func for_item(item: ItemData) -> Texture2D:
	var key: String = str(BY_ITEM_ID.get(item.id, ""))
	if key == "":
		key = "delapouite/health-potion"
	return _load(key)


static func for_equipment(equipment: EquipmentData) -> Texture2D:
	var key: String = str(BY_EQUIPMENT_ID.get(equipment.id, ""))
	if key == "":
		key = "lorc/gem-pendant"
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
