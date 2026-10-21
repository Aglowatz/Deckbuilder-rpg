class_name AreaCaches
extends RefCounted
## Overnight Oct 20 (playtest stability, Phase 2): the world-art caches - painted textures, kit models and materials, each zone's own
## materials and models, map and battle-board pictures - kept every area the player had visited alive for the whole session. A tour
## of the six areas grew from 1.3k to 3.9k resources and 161 to 946 MB of textures (1.86 GB of video memory on an integrated GPU, whose
## video memory is the laptop's RAM); on Vulkan the same tour ran out of driver objects (VK_ERROR_TOO_MANY_OBJECTS) in the fourth zone.
## SceneManager calls `release` when the player moves to a DIFFERENT area (never zone <-> battle, so a zone's fights stay quick):
## the old area's art is freed with its scene, the new area builds its own. Only caches of things a scene rebuilds on demand are here -
## no data tables, no once-per-session flags, no menu backgrounds or card art (used everywhere and bounded by what exists).


## Clears the world-art caches; returns how many entries were dropped (the game log notes it).
static func release() -> int:
	var dropped: int = 0
	for cache: Dictionary in _dictionaries():
		dropped += cache.size()
		cache.clear()
	PaintedTriplanar.clear_cache()
	KitTextures.clear()
	KitFoliage.clear_cache()
	EnvKit.clear_cache()
	DnaMaterials.reset_cache()
	return dropped


static func _dictionaries() -> Array[Dictionary]:
	return [
		PaintedLibrary._textures,
		PaintedClasses._atlas_cache,
		StyleTerrain._cache,
		StyleWater._cache,
		StyleGrass._materials,
		PathTool._patch_cache,
		ModelKit._cache,
		BuffetMaterials._cache,
		BuffetModels._cache,
		BuffetProps._meshes,
		CapitalKit._cache,
		CapitalMaterials._cache,
		CapitalProps._portrait_textures,
		DnaBuilder._scene_cache,
		DnaBuilder._part_cache,
		GainlandsMaterials._cache,
		HeapMaterials._cache,
		HeapModels._cache,
		MapArt._textures,
		Battleboards._textures,
		# Zone banners, loading-screen paintings and vendor stage pictures are per area; the title and menus reload theirs on demand.
		KeyArt._textures,
		Bestiary._art_cache,
	] as Array[Dictionary]
