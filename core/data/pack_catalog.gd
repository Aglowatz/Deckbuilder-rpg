class_name PackCatalog
extends RefCounted
## Loads every pack from `data/packs/*.tres` (written once by `tools/generate_packs.gd` from `PackDefinitions`; the .tres files
## are what the game reads, so they are the place to tune weights and prices) and the pack-system config.

const DIR: String = "res://data/packs/"
const CONFIG_PATH: String = "res://data/packs/pack_config.tres"

static var _cache: Array[PackData] = []
static var _config: PackConfig


static func all() -> Array[PackData]:
	if _cache.is_empty():
		var dir: DirAccess = DirAccess.open(DIR)
		if dir != null:
			var names: PackedStringArray = dir.get_files()
			names.sort()
			for file_name: String in names:
				var clean: String = file_name.trim_suffix(".remap")
				if clean.ends_with(".tres") and clean != "pack_config.tres":
					var pack: PackData = load(DIR + clean) as PackData
					if pack != null:
						_cache.append(pack)
		_cache.sort_custom(func(a: PackData, b: PackData) -> bool: return a.order < b.order)
	return _cache


static func find(pack_id: String) -> PackData:
	for pack: PackData in all():
		if pack.id == pack_id:
			return pack
	return null


static func config() -> PackConfig:
	if _config == null:
		_config = load(CONFIG_PATH) as PackConfig
		if _config == null:
			_config = PackConfig.new()
	return _config


## Every pack a vendor (`PackData.VENDOR_*`) can sell, in shop order.
static func sold_by(vendor: String) -> Array[PackData]:
	var result: Array[PackData] = []
	for pack: PackData in all():
		if pack.sold_by == vendor:
			result.append(pack)
	return result


static func path_pack(path: Affinity.Type) -> PackData:
	return find(PackRules.path_pack_id(path))


static func gilded_pack(path: Affinity.Type) -> PackData:
	return find(PackRules.gilded_pack_id(path))
