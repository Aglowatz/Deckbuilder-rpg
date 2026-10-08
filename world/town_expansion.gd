class_name TownExpansion
extends RefCounted
## Polish round, Group A: ~18 more cottages, sheds, a barn, a bakery, a well and market stalls so the town reads bigger. Every site is
## one building (or stall) on the centre of an otherwise empty grass hex, on the edges and in the gaps around the districts, never in
## the middle of a main lane; the hex around it stays open. `tests/world/test_walkability_town.gd` proves the vendors, NPCs, chests and
## zone exits are still reachable with a wide body after these are placed.

## One site: the hex it stands in, what it is, how big and which way it faces (yaw 999 = face the town centre).
class Site:
	var cell: Vector2i
	var kind: String
	var model: String
	var scale_value: float
	var radius: float
	var yaw: float
	var label: String

	static func make(cell_value: Vector2i, kind_value: String, model_value: String, scale_value_in: float, radius_value: float, label_value: String, yaw_value: float = 999.0) -> Site:
		var site: Site = Site.new()
		site.cell = cell_value
		site.kind = kind_value
		site.model = model_value
		site.scale_value = scale_value_in
		site.radius = radius_value
		site.label = label_value
		site.yaw = yaw_value
		return site


static func sites() -> Array[Site]:
	return [
		# West Woods: a hamlet along the forest road
		Site.make(Vector2i(-5, 2), "building", "home_A", 1.25, 0.7, "Woodcutter's cottage"),
		Site.make(Vector2i(-4, 7), "building", "home_B", 1.25, 0.7, "Forester's cottage"),
		Site.make(Vector2i(-3, 8), "building", "well", 1.4, 0.55, "Hamlet well"),
		# North Uplands: a lookout and a shepherd's cottage
		Site.make(Vector2i(2, -3), "building", "tower_A", 1.1, 0.8, "Lookout tower"),
		Site.make(Vector2i(6, -3), "building", "home_A", 1.2, 0.7, "Shepherd's cottage"),
		# Harbor Dock: fisher folk, a bakery and a net shed
		Site.make(Vector2i(16, 0), "building", "home_B", 1.25, 0.7, "Fisher's cottage"),
		Site.make(Vector2i(14, 2), "building", "market", 1.1, 0.85, "Harbor bakery"),
		Site.make(Vector2i(15, 6), "building", "lumbermill", 1.0, 0.8, "Net shed"),
		# Beefcake Flats: a farm, a training yard and cottages along the south road
		Site.make(Vector2i(4, 13), "building", "lumbermill", 1.35, 0.95, "Flats barn"),
		Site.make(Vector2i(2, 16), "building", "home_B", 1.25, 0.7, "Farmhouse"),
		Site.make(Vector2i(11, 17), "building", "home_A", 1.25, 0.7, "Gatekeeper's cottage"),
		Site.make(Vector2i(11, 15), "building", "archeryrange", 1.1, 0.9, "Archery range"),
		Site.make(Vector2i(10, 19), "building", "home_B", 1.2, 0.7, "Wayside cottage"),
		Site.make(Vector2i(12, 12), "building", "barracks", 1.0, 0.8, "Watch shed"),
		# Market stalls on the quiet edges of the central lanes
		Site.make(Vector2i(0, 2), "stall", "cabbage", 1.5, 0.6, "Greengrocer's stall"),
		Site.make(Vector2i(11, 1), "stall", "loaf", 1.5, 0.6, "Baker's stall"),
		Site.make(Vector2i(12, 1), "building", "well", 1.4, 0.55, "Codex-side well"),
	]


## Places every site under `root` and registers its footprint as an obstacle. Returns the world positions by label (for the tests and docs).
static func build(root: Node3D, town: TownBuilder) -> Dictionary:
	var placed: Dictionary = {}
	var centre: Vector3 = TownLayout.PLAZA
	for site: Site in sites():
		var pos: Vector3 = town.cell_center(site.cell.x, site.cell.y)
		var yaw: float = site.yaw
		if yaw > 900.0:
			yaw = rad_to_deg(atan2(centre.x - pos.x, centre.z - pos.z))
			yaw = snappedf(yaw, 15.0)
		if site.kind == "stall":
			_stall(root, pos, yaw, site.model)
		else:
			ModelKit.place(root, ModelKit.building(site.model), pos, yaw, site.scale_value)
		town.obstacles.append(Vector3(pos.x, pos.z, site.radius))
		placed[site.label] = pos
	return placed


static func _stall(root: Node3D, pos: Vector3, yaw: float, good: String) -> void:
	ModelKit.place(root, ModelKit.kit_model(ModelKit.KENNEY_NATURE, "tent_detailedOpen"), pos, yaw, 1.6)
	var forward: Vector3 = Vector3(sin(deg_to_rad(yaw)), 0.0, cos(deg_to_rad(yaw)))
	var table_pos: Vector3 = pos + forward * 0.55
	var table: Node3D = ModelKit.place(root, ModelKit.prop("crate_long_A"), table_pos, yaw, 2.1)
	ModelKit.tint(table, Color(0.78, 0.6, 0.5))
	var right: Vector3 = Vector3(forward.z, 0.0, -forward.x)
	for index: int in range(3):
		var spot: Vector3 = table_pos + right * (float(index) - 1.0) * 0.38 + Vector3(0.0, 0.42, 0.0)
		ModelKit.place(root, ModelKit.kit_model(ModelKit.KENNEY_FOOD, good), spot, float(index) * 70.0, 0.6)
