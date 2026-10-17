class_name TownExpansion
extends RefCounted
## The buildings out in the hub's fields and on its shore. Crosspath pass, Part B: the seventeen toy KayKit huts, wells, towers and camping tents of
## the old "polish round" are gone; what stays is a handful of storybook-scale kit buildings placed with a purpose, each with its own little
## vignette: a farmhouse with a fenced garden at the edge of the south-west field, a fisher's cottage on the lake's west shore, a boat shed beside
## the dock and a wayside cottage with a garden by the meadow road. Every site keeps clear of the roads and stands inside the walkable country
## (`TownBounds`); `tests/world/test_crosspath_cleanup.gd` checks both.


## One site: a BuildingKit preset (and overrides) at x / z, facing `yaw` (0 = south), and the clusters dressed round it in its own frame
## ([cluster name, local x (+ = to the right of the door), local z (+ = out in front of the front face), yaw offset]).
class Site:
	var label: String
	var preset: String
	var overrides: Dictionary
	var pos: Vector3
	var yaw: float
	var vignette: Array

	static func make(label_value: String, preset_value: String, x: float, z: float, yaw_value: float, vignette_value: Array = [], overrides_value: Dictionary = {}) -> Site:
		var site: Site = Site.new()
		site.label = label_value
		site.preset = preset_value
		site.overrides = overrides_value
		site.pos = Vector3(x, 0.0, z)
		site.yaw = yaw_value
		site.vignette = vignette_value
		return site


static func sites() -> Array[Site]:
	return [
		# the south-west field: a thatched farmhouse looking over its field, a fenced vegetable garden beside the door
		Site.make("Farmhouse", "cottage", 12.4, 50.2, 0.0, [["fence_garden", 5.4, 1.6, 0.0], ["garden_bed", 5.2, 3.4, 0.0], ["barrel_pair", -3.6, 0.9, 0.0]]),
		# the lake's west shore (Part D): the fisher's cottage faces the water across the lane, barrels by its side
		Site.make("Fisher's cottage", "cottage", 50.0, 27.2, 90.0, [["barrel_pair", -3.2, -1.6, 0.0]], {"width": 5.0, "depth": 4.4}),
		# beside the dock: a small stone boat shed
		Site.make("Boat shed", "stone_hut", 50.6, 45.6, 90.0, [["crates", -3.4, -1.5, 0.0]], {"width": 4.6, "depth": 3.8}),
		# the meadow road: a wayside cottage facing the road, its garden to the south
		Site.make("Wayside cottage", "home_a", 42.2, 55.4, -90.0, [["fence_garden", -4.4, 1.4, 0.0], ["bench_nook", 3.6, 1.2, 0.0]], {"width": 6.0, "depth": 5.4, "floors": 1}),
	]


## The sites as `TownLayout.Shop` rows (kind "kit", no key): footprints and obstacle circles like every other kit building.
static func shops() -> Array[TownLayout.Shop]:
	var result: Array[TownLayout.Shop] = []
	for site: Site in sites():
		result.append(TownLayout._kit("", site.preset, site.pos.x, site.pos.z, site.yaw, site.label, site.overrides))
	return result


## Places every site under `root`, registers its footprint and its vignette's solid circles on the town. Returns the world positions by label.
static func build(root: Node3D, town: TownBuilder) -> Dictionary:
	var placed: Dictionary = {}
	var list: Array[Site] = sites()
	var rows: Array[TownLayout.Shop] = shops()
	for index: int in range(list.size()):
		var site: Site = list[index]
		var shop: TownLayout.Shop = rows[index]
		var building: Node3D = TownKit.place_building(root, town, shop)
		building.name = "Outskirt_%s" % site.label.replace(" ", "_").replace("'", "")
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(site.yaw))
		for item: Variant in site.vignette:
			var entry: Array = item as Array
			var cluster: Node3D = PropClusters.make(str(entry[0]), index * 7 + 3)
			if cluster == null:
				continue
			var local: Vector3 = Vector3(float(entry[1]), 0.0, shop.footprint.y * 0.5 + float(entry[2]))
			TownKit.place_cluster(root, town, cluster, site.pos + basis * local, site.yaw + float(entry[3]))
		placed[site.label] = site.pos
	return placed
