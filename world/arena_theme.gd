class_name ArenaTheme
extends RefCounted
## What makes the battle table look like the zone it is fought in (docs/art/graphics_loop.md, BB-* tasks): the zone's light and grade, a tint for the hex tiles, the ring of
## rim dressing, the far-side landmark and the ground patch palettes. Pure data; `ArenaBackdrop` builds it. The generic table (no zone, practice duels) keeps the meadow.

const NATURE_HEX: String = "decoration/nature"
const PROPS_HEX: String = "decoration/props"

var zone_id: String = ""
## Zone light and grade (a `StylePresets` id), adapted to a table seen from above.
var preset_id: StringName = StylePresets.BATTLE
var tile_tint: Color = Color.WHITE
## Rim dressing: Array of [folder, model, weight, min_scale, max_scale].
var rim: Array = []
var rim_scale: float = 1.7
## Landmark behind the enemy: Array of [folder, model, x, z, yaw, scale] (placed relative to the far-side anchor) and the glow colour of its lantern.
var landmark: Array = []
var glow_color: Color = Color("ffb867")
## Colour of the spot pool over the play area and of the back light.
var pool_color: Color = Color("ffd8a0")
var back_color: Color = Color("7a8cff")
## Patch palettes for the ground variation: moss/earth/stone triplets.
var moss: Array[Color] = [Color("4f7a3a"), Color("6a9a48")]
var earth: Array[Color] = [Color("7e7a50"), Color("676442"), Color("4e4a34")]
var stone: Array[Color] = [Color("5a5a64"), Color("7a7a80")]
## Size multiplier and extra count of the ground patches (a themed table paints bigger, softer patches so the tile colour does not show through as dots).
var patch_scale: float = 1.0
var patch_extra: int = 0
## Keep the meadow trees, mountains and flags (only the generic table and the Gainlands do).
var meadow: bool = true
## The two blue banners at the sides of the table (generic meadow only).
var banners: bool = true


static func for_zone(zone: String) -> ArenaTheme:
	var theme: ArenaTheme = ArenaTheme.new()
	theme.zone_id = zone
	var food: String = ModelKit.KENNEY_FOOD
	var survival: String = ModelKit.KENNEY_SURVIVAL
	var furniture: String = "res://assets/kenney-furniture-kit/models/"
	match zone:
		"hollow":
			theme.preset_id = StylePresets.START
			theme.tile_tint = Color(0.78, 0.92, 1.0)
			theme.banners = false
			theme.rim_scale = 1.8
			theme.glow_color = Color("5ff0d8")
			theme.pool_color = Color("e8e0ff")
			theme.back_color = Color("5a6ad8")
			theme.moss = [Color("2a6a5a"), Color("4a9a7a")]
			theme.earth = [Color("6a6a70"), Color("505058"), Color("383840")]
			var nature_kit: String = ModelKit.KENNEY_NATURE
			theme.rim = [
				[nature_kit, "mushroom_tanGroup", 1.4, 1.4, 2.0], [nature_kit, "mushroom_redGroup", 0.8, 1.4, 2.0], [nature_kit, "plant_bush", 1.0, 1.3, 1.8],
				[NATURE_HEX, "rock_single_B", 1.6, 1.0, 1.5], [NATURE_HEX, "rock_single_D", 1.4, 1.0, 1.5], [NATURE_HEX, "tree_single_A_cut", 0.8, 1.0, 1.3],
				[nature_kit, "stone_largeA", 0.6, 1.2, 1.8],
			]
			theme.landmark = [
				["buildings/blue", "building_mine_blue", 0.0, 0.0, 0.0, 2.6], [NATURE_HEX, "rock_single_E", -3.0, 0.6, 0.0, 2.4], [NATURE_HEX, "rock_single_B", 3.0, 0.6, 0.0, 2.4],
				[nature_kit, "mushroom_tanGroup", -1.8, 2.0, 0.0, 3.0], [nature_kit, "mushroom_tanGroup", 1.8, 2.0, 0.0, 3.0],
			]
		"necrocrat":
			theme.preset_id = StylePresets.DNA
			theme.tile_tint = Color(0.68, 0.78, 0.86)
			theme.meadow = false
			theme.rim_scale = 1.9
			theme.glow_color = Color("d8f0ff")
			theme.pool_color = Color("e0f0ff")
			theme.back_color = Color("5a7090")
			theme.moss = [Color("3a4650"), Color("4a5864")]
			theme.earth = [Color("5a5448"), Color("48443a"), Color("302e28")]
			theme.stone = [Color("2a323a"), Color("424c56")]
			theme.rim = [
				[furniture, "cardboardBoxClosed", 1.4, 1.0, 1.3], [furniture, "cardboardBoxOpen", 1.0, 1.0, 1.3], [furniture, "books", 1.4, 1.0, 1.4],
				[furniture, "trashcan", 0.9, 1.0, 1.3], [furniture, "pottedPlant", 0.8, 1.0, 1.3], [furniture, "bookcaseClosed", 0.7, 0.9, 1.1],
				[furniture, "chairDesk", 0.7, 1.0, 1.2], [furniture, "sideTableDrawers", 0.5, 1.0, 1.2],
			]
			theme.landmark = [
				[furniture, "bookcaseClosedWide", 0.0, 0.0, 0.0, 3.2], [furniture, "bookcaseClosed", -3.4, 0.4, 8.0, 2.8], [furniture, "bookcaseClosed", 3.4, 0.4, -8.0, 2.8],
				[furniture, "lampRoundFloor", -2.0, 1.8, 0.0, 2.6], [furniture, "desk", 2.0, 2.2, 180.0, 2.4],
			]
		"beefcake":
			theme.preset_id = StylePresets.GAINLANDS
			theme.tile_tint = Color(1.0, 0.98, 0.86)
			theme.glow_color = Color("fff0c0")
			theme.pool_color = Color("fff0c8")
			theme.back_color = Color("78b8e8")
			theme.earth = [Color("c8a870"), Color("a88850"), Color("86683c")]
			theme.rim = [
				[PROPS_HEX, "target", 1.0, 1.0, 1.3], [PROPS_HEX, "weaponrack", 0.9, 1.0, 1.2], [PROPS_HEX, "crate_A_big", 1.0, 1.0, 1.3],
				[PROPS_HEX, "barrel", 1.0, 1.0, 1.3], [PROPS_HEX, "sack", 0.8, 1.0, 1.3], [PROPS_HEX, "wheelbarrow", 0.5, 1.0, 1.1], [PROPS_HEX, "bucket_water", 0.7, 1.0, 1.2],
			]
			theme.landmark = [
				[PROPS_HEX, "tent", 0.0, 0.0, 0.0, 2.8], [PROPS_HEX, "flag_blue", -3.4, 0.8, 12.0, 3.4], [PROPS_HEX, "flag_blue", 3.4, 0.8, -12.0, 3.4],
				[PROPS_HEX, "target", -2.6, 2.0, 20.0, 1.9], [PROPS_HEX, "weaponrack", 2.4, 1.9, -20.0, 1.9],
			]
		"gourmand":
			theme.preset_id = StylePresets.BUFFET
			theme.tile_tint = Color(1.25, 1.0, 0.8)
			theme.meadow = false
			theme.rim_scale = 3.4
			theme.glow_color = Color("ffc070")
			theme.pool_color = Color("ffd0a0")
			theme.back_color = Color("ff8a70")
			theme.moss = [Color("e8b078"), Color("f0c890")]
			theme.patch_scale = 1.6
			theme.patch_extra = 1
			theme.earth = [Color("f0d8a8"), Color("e0b878"), Color("c89050")]
			theme.stone = [Color("fff0d8"), Color("e8c8a0")]
			theme.rim = [
				[food, "cupcake", 1.0, 1.0, 1.3], [food, "donut", 1.0, 1.0, 1.3], [food, "pie", 0.8, 1.0, 1.2], [food, "cookie", 1.0, 1.0, 1.4],
				[food, "bread", 0.7, 1.0, 1.3], [food, "broccoli", 0.9, 1.0, 1.4], [food, "carrot", 0.8, 1.0, 1.4], [food, "pancakes", 0.6, 1.0, 1.2],
				[food, "sausage", 0.6, 1.0, 1.3], [food, "cheese", 0.7, 1.0, 1.3],
			]
			theme.landmark = [
				[food, "cake", 0.0, 0.0, 0.0, 11.0], [food, "cupcake", -4.0, 1.0, 0.0, 6.0], [food, "cupcake", 4.0, 1.0, 0.0, 6.0],
				[food, "utensil-fork", -5.6, 1.6, 20.0, 9.0], [food, "utensil-spoon", 5.6, 1.6, -20.0, 9.0],
			]
		"refusemancer":
			theme.preset_id = StylePresets.HEAP
			theme.meadow = false
			theme.rim_scale = 1.9
			theme.tile_tint = Color(1.0, 0.94, 0.7)
			theme.glow_color = Color("ffc47a")
			theme.back_color = Color("8a6aa0")
			theme.moss = [Color("6a7a30"), Color("8a9a3a")]
			theme.earth = [Color("a88850"), Color("8a6a3a"), Color("6a5028")]
			theme.patch_scale = 1.4
			theme.stone = [Color("5a5448"), Color("7a7060")]
			theme.rim = [
				[survival, "barrel", 1.0, 1.0, 1.3], [survival, "barrel-open", 0.8, 1.0, 1.3], [survival, "box", 1.0, 1.0, 1.4], [survival, "box-large", 0.8, 1.0, 1.2],
				[survival, "bucket", 0.8, 1.0, 1.3], [survival, "resource-planks", 0.8, 1.0, 1.3], [survival, "tree-log", 0.7, 1.0, 1.3], [survival, "metal-panel", 0.7, 1.0, 1.2],
				[survival, "rock-c", 0.7, 1.0, 1.4], [survival, "bottle-large", 0.6, 1.0, 1.5],
			]
			theme.landmark = [
				[survival, "box-large", 0.0, 0.0, 10.0, 3.6], [survival, "box-large", -1.6, 0.4, -20.0, 3.0], [survival, "barrel", 1.8, 0.6, 0.0, 3.2],
				[survival, "tree-log", -3.6, 0.2, 40.0, 3.2], [survival, "tree-log", 3.4, 0.2, -50.0, 3.2], [survival, "metal-panel", 0.2, -1.2, 0.0, 3.6],
			]
		"final":
			theme.preset_id = StylePresets.CAPITAL_INSIDE
			theme.tile_tint = Color(1.0, 0.92, 0.98)
			theme.meadow = false
			theme.rim_scale = 1.8
			theme.glow_color = Color("ffd8e8")
			theme.back_color = Color("a890e0")
			theme.patch_scale = 1.5
			theme.moss = [Color("4a9a52"), Color("66b060")]
			theme.earth = [Color("e8d0c0"), Color("d8b8a8"), Color("c8a898")]
			theme.stone = [Color("f0e0d8"), Color("d8c8c8")]
			var nature_kit: String = ModelKit.KENNEY_NATURE
			theme.rim = [
				[nature_kit, "plant_bushLarge", 1.6, 1.4, 1.9], [nature_kit, "plant_bush", 1.2, 1.4, 1.8], [nature_kit, "flower_redC", 1.0, 1.6, 2.2], [nature_kit, "flower_purpleC", 1.0, 1.6, 2.2],
				[nature_kit, "flower_yellowC", 1.0, 1.6, 2.2], [PROPS_HEX, "flag_blue", 0.7, 1.0, 1.2], [furniture, "pottedPlant", 0.8, 1.3, 1.7],
			]
			theme.landmark = [
				[furniture, "wallDoorwayWide", 0.0, 0.0, 0.0, 4.4], [PROPS_HEX, "flag_blue", -3.6, 0.8, 8.0, 4.2], [PROPS_HEX, "flag_blue", 3.6, 0.8, -8.0, 4.2],
				[furniture, "pottedPlant", -2.2, 1.8, 0.0, 3.0], [furniture, "pottedPlant", 2.2, 1.8, 0.0, 3.0],
			]
		_:
			theme.rim = [
				[NATURE_HEX, "rock_single_B", 2.0, 1.0, 1.5], [NATURE_HEX, "rock_single_D", 2.0, 1.0, 1.5], [NATURE_HEX, "rock_single_E", 1.5, 1.0, 1.4],
				[PROPS_HEX, "barrel", 1.0, 1.0, 1.3], [PROPS_HEX, "crate_A_big", 1.0, 1.0, 1.3], [PROPS_HEX, "sack", 1.0, 1.0, 1.4],
				[PROPS_HEX, "resource_lumber", 0.6, 1.0, 1.2], [NATURE_HEX, "tree_single_A_cut", 0.6, 1.0, 1.3],
			]
			theme.landmark = [
				[PROPS_HEX, "tent", 0.0, 0.0, 0.0, 2.6], [PROPS_HEX, "flag_blue", -3.2, 0.8, -12.0, 3.4], [PROPS_HEX, "flag_blue", 3.2, 0.8, 12.0, 3.4],
				[PROPS_HEX, "weaponrack", 2.0, 1.8, -20.0, 1.8],
			]
	return theme


## A node for one `[folder, model, ...]` entry: the KayKit hex kit for the two relative folders, the Kenney kits by their full path.
static func make_node(folder: String, model: String) -> Node3D:
	if folder.begins_with("res://"):
		return ModelKit.kit_model(folder, model)
	return ModelKit.hex_model(folder, model)


## The zone's light and grade adapted to a table seen from above: the generic table uses the BATTLE preset as is; a zone preset loses its volumetric haze and gets a lower
## ambient so the spot pool and the shadows carry the mood (and the dimmed UI stays readable).
func table_preset() -> ZonePreset:
	var preset: ZonePreset = StylePresets.get_preset(preset_id)
	if preset_id == StylePresets.BATTLE:
		return preset
	preset.volumetric_density = 0.0
	preset.ambient_energy = minf(preset.ambient_energy, 0.5)
	preset.sun_energy = minf(preset.sun_energy, 0.9)
	preset.glow_intensity = minf(preset.glow_intensity, 0.2)
	return preset
