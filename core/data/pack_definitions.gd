class_name PackDefinitions
extends RefCounted
## The starting pack data, in code. `tools/generate_packs.gd` writes it to `data/packs/*.tres` ONLY where a file does not exist
## yet, so hand-tuned weights and prices in the .tres files are never overwritten. All numbers are placeholders (balance is out
## of scope): tune them in the .tres files.

const PATH_COLORS: Dictionary = {
	Affinity.Type.A: Color(0.93, 0.38, 0.2),
	Affinity.Type.B: Color(0.95, 0.76, 0.25),
	Affinity.Type.C: Color(0.38, 0.74, 0.38),
	Affinity.Type.D: Color(0.6, 0.42, 0.88),
}
const PATH_ICONS: Dictionary = {
	Affinity.Type.A: "delapouite/biceps",
	Affinity.Type.B: "delapouite/fork-knife-spoon",
	Affinity.Type.C: "lorc/recycle",
	Affinity.Type.D: "lorc/tombstone",
}


static func all() -> Array[PackData]:
	var packs: Array[PackData] = []
	var order: int = 10
	for path: Affinity.Type in Affinity.colored_types():
		packs.append(path_pack(path, order))
		order += 1
	order = 30
	for path: Affinity.Type in Affinity.colored_types():
		packs.append(gilded_pack(path, order))
		order += 1
	packs.append(prismatic(50))
	packs.append(general(1, 60))
	packs.append(general(2, 61))
	return packs


static func path_pack(path: Affinity.Type, order: int) -> PackData:
	var pack: PackData = PackData.new()
	pack.id = PackRules.path_pack_id(path)
	pack.display_name = "%s Pack" % Affinity.display_name(path)
	pack.kind = PackData.Kind.PATH
	pack.path = path
	pack.pool_paths = [path] as Array[Affinity.Type]
	pack.include_neutral = true
	pack.card_count = 3
	pack.rarity_weights = [60, 28, 10, 2] as Array[int]
	pack.art_color = PATH_COLORS[path] as Color
	pack.art_icon = str(PATH_ICONS[path])
	pack.frame_style = "foil"
	pack.price = 150
	pack.sold_by = PackData.VENDOR_PACK
	pack.unlock = Condition.flag("zone_%s_completed" % PackRules.zone_for_path(path))  # = ZoneCompletion.flag_name (a test checks it)
	pack.order = order
	return pack


static func gilded_pack(path: Affinity.Type, order: int) -> PackData:
	var pack: PackData = path_pack(path, order)
	pack.id = PackRules.gilded_pack_id(path)
	pack.display_name = "Gilded %s Pack" % Affinity.display_name(path)
	pack.kind = PackData.Kind.GILDED
	pack.guarantee_epic_or_legendary = true
	pack.rarity_weights = [40, 30, 22, 8] as Array[int]
	pack.frame_style = "gilded"
	pack.price = 600
	pack.sold_by = PackData.VENDOR_BLACK_MARKET
	return pack


static func prismatic(order: int) -> PackData:
	var pack: PackData = PackData.new()
	pack.id = PackRules.PRISMATIC_ID
	pack.display_name = "Prismatic Pack"
	pack.kind = PackData.Kind.PRISMATIC
	pack.pool_paths = [] as Array[Affinity.Type]
	pack.include_neutral = true
	pack.include_multipath = true
	pack.guarantee_multipath = true
	pack.card_count = 4
	pack.rarity_weights = [50, 28, 17, 5] as Array[int]
	pack.art_color = Color(0.85, 0.6, 0.95)
	pack.art_icon = "lorc/rainbow-star"
	pack.frame_style = "prismatic"
	pack.price = 900
	pack.sold_by = PackData.VENDOR_PACK
	pack.unlock = Condition.postgame()
	pack.order = order
	return pack


static func general(tier: int, order: int) -> PackData:
	var pack: PackData = PackData.new()
	pack.id = PackRules.GENERAL_1_ID if tier == 1 else PackRules.GENERAL_2_ID
	pack.display_name = "General Pack" if tier == 1 else "General Pack, Tier II"
	pack.kind = PackData.Kind.GENERAL
	pack.general_tier = tier
	pack.pool_paths = [] as Array[Affinity.Type]
	pack.include_neutral = true
	pack.vendor_selection_only = true
	pack.card_count = 3
	pack.art_color = Color(0.7, 0.72, 0.8) if tier == 1 else Color(0.55, 0.78, 0.95)
	pack.art_icon = "faithtoken/card-random"
	pack.frame_style = "plain" if tier == 1 else "foil"
	pack.sold_by = PackData.VENDOR_CARD
	pack.order = order
	if tier == 1:
		pack.rarity_weights = [70, 30, 0, 0] as Array[int]
		pack.max_rarity = CardEnums.Rarity.UNCOMMON
		pack.price = 100
	else:
		pack.rarity_weights = [58, 28, 11, 3] as Array[int]
		pack.price = 220
	return pack

