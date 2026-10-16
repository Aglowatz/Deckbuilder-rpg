class_name CapitalLayout
extends RefCounted
## The Capital's map as plain data (no scene nodes), so it can be unit-tested headless: a 1 m cell grid (ground /
## solid / void), regions, routes, buildings, props, signs, rifts, anchors, hidden chests and enemy homes. `CapitalBuilder`
## turns it into meshes; `CapitalScene` makes it playable.
##
## Coordinates: metres, x east, z south, y up (the ground is flat). The Capital is ONE walkable zone in two halves joined
## through the great wall (rows WALL_Z0..WALL_Z1): OUTSIDE (south, the wasteland) the Gate Road from town up to the
## Approved Gate (the outside hub), the resistance camp, the rift fields, the ruined outpost, the Old Service Tunnels'
## mouth in the wall and the secret wall passage; INSIDE (north, Primm's Perfection) the Gate Plaza round the Primm statue
## fountain (the inside hub), the palace approach (a straight grand avenue between identical houses up to the stair of
## Primm's Castle on its hill at the city's heart), the Reek and Grave Row in the west, the Transit Yards, the Hungry
## Quarter and the Correction Ward in the east. Routes are data (`routes`), so the declutter rules of the rollout playbook
## (section 5) can be tested. The resistance hideout, the Crease, is a separate underground hall far to the south
## (reached by hatches and ladders, never walked to). Region table: docs/art/capital_slice.md.

const W: int = 120
const H: int = 157
## The y (z) of the great wall's rows and the gate opening's x range (inclusive cells).
const WALL_Z0: int = 72
const WALL_Z1: int = 75
const GATE_X0: int = 55
const GATE_X1: int = 64
## Brief 16, Group C: the secret passage through the wall, far along the LEFT-hand side of the city wall (cells, 2 m wide). No sign points to it.
const PASSAGE_X0: int = 22
const PASSAGE_W: int = 2
## The last row of the outside (the Gate Road leaves the map south of it, toward town).
const OUT_Z1: int = 121
## The underground hideout's first row (its own light layer, far south of the outside).
const CREASE_Z0: int = 134
## The castle hill: no ground here, the hill and Primm's Castle stand on it (cells).
const HILL: Rect2i = Rect2i(47, 0, 27, 12)

## The declutter rules (docs/art/zone_rollout_playbook.md section 5).
const MAIN_ROUTE_WIDTH: float = 4.2
const SPUR_WIDTH: float = 3.6
const ROUTE_CLEARANCE: float = 2.4
const ANCHOR_CLEARANCE: float = 5.5
## The Gate Plaza: an open round about the Primm statue fountain; the hub's things stand round its rim.
const PLAZA_CENTER: Vector2 = Vector2(60.0, 58.0)
const PLAZA_RADIUS: float = 10.5

## Region ids (several rects may share one id), outside then inside, in reading order.
const OUTSIDE_REGIONS: Array[String] = ["gate", "camp", "rifts", "outpost", "tunnels", "passage"]
const INSIDE_REGIONS: Array[String] = ["plaza", "approach", "reek", "grave", "transit", "hungry", "ward"]

## The stand-in landmarks (positions and sizes w x h x d), built by `CapitalLandmarks`; the art pass replaces each in place.
const CASTLE: Vector3 = Vector3(60.0, 0.0, -21.0)
const CASTLE_SIZE: Vector3 = Vector3(78.0, 46.0, 44.0)
const HILL_HEIGHT: float = 7.0
const FOUNTAIN_SIZE: Vector3 = Vector3(7.0, 6.5, 7.0)
const WATCHTOWER: Vector2 = Vector2(91.0, 96.5)
const TUNNEL_MOUTH: Vector2 = Vector2(96.0, 76.0)
const TRAM_SHED: Rect2 = Rect2(104.5, 49.5, 10.0, 6.0)
const RIFT_CRYSTALS: Array[Vector2] = [Vector2(40.0, 89.5), Vector2(21.0, 99.0)]
const CAMP_FIRE: Vector2 = Vector2(34.5, 113.5)
const CAMP_TENTS: Array[Vector2] = [Vector2(29.0, 116.5), Vector2(40.5, 116.5)]
const CAMP_LEAN_TO: Vector2 = Vector2(23.5, 116.5)
## Blocking circles of the stand-ins that stand on walkable ground (x, z, radius), for the layout-only readers (walkability, tests). The
## fountain and the crystals are props with these circles; the watchtower and the camp are only circles (their models are landmarks).
const LANDMARK_BLOCKERS: Array[Vector3] = [
	Vector3(60.0, 58.0, 3.3),     # the Primm statue fountain (the inside hub's centre)
	Vector3(91.0, 96.5, 3.4),     # the broken watchtower (the ruined outpost)
	Vector3(40.0, 89.5, 1.6),     # rift crystals A (the rift fields)
	Vector3(21.0, 99.0, 1.6),     # rift crystals B
	Vector3(29.0, 116.5, 1.6),    # the camp: the west tent
	Vector3(40.5, 116.5, 1.6),    # the east tent
	Vector3(23.5, 116.5, 1.4),    # the lean-to
	# the camp's ruined flank walls (the art pass, CAP-HERO-RESISTANCE-CAMP: the camp shelters in old stone ruins), x 19 and x 45.5, z 112..119
	Vector3(19.0, 112.4, 0.75), Vector3(19.0, 113.7, 0.75), Vector3(19.0, 115.0, 0.75), Vector3(19.0, 116.3, 0.75), Vector3(19.0, 117.6, 0.75), Vector3(19.0, 118.9, 0.75),
	Vector3(45.5, 112.4, 0.75), Vector3(45.5, 113.7, 0.75), Vector3(45.5, 115.0, 0.75), Vector3(45.5, 116.3, 0.75), Vector3(45.5, 117.6, 0.75), Vector3(45.5, 118.9, 0.75),
]
## The camp's ruined walls (CapitalLandmarks.camp): the two flank walls on the floor (their circles above). No back wall: the camp's camera stands
## south of the hero, where it would fill the lens.
const CAMP_RUINS: Array[Rect2] = [Rect2(18.6, 112.0, 0.8, 7.3), Rect2(45.1, 112.0, 0.8, 7.3)]

## Where each region paint-over is shot from (the hero's standing spot; the camera looks north from behind):
## `bash tools/capital_po_shots.sh`. Camera spots, not anchors (VD-10): each stands off every spot and enemy home.
const PO_CAMERAS: Dictionary = {
	"po_gate_road": Vector2(60.0, 101.0), "po_resistance_camp": Vector2(34.5, 115.6), "po_rift_fields": Vector2(30.0, 101.5),
	"po_ruined_outpost": Vector2(92.0, 109.5), "po_gate_plaza": Vector2(54.0, 53.0), "po_transit_yards": Vector2(96.0, 64.0),
	"po_hungry_quarter": Vector2(100.0, 41.0), "po_grave_row": Vector2(22.0, 34.0), "po_the_reek": Vector2(17.5, 64.0),
	"po_palace_approach": Vector2(60.0, 35.5),
}

enum Cell { VOID, GROUND, SOLID }
enum Floor { NONE, GRAVEL, ROAD, PLAZA, LAWN, GRAY, SOIL, METAL, TILE, HUB, GRASS, DEAD }


class Building:
	extends RefCounted
	var rect: Rect2 = Rect2()
	var height: float = 5.0
	## "house" (identical facade house), "ruin", "factory", "stall", "shop" (painted facade storefront), "crypt",
	## "hall", "tower", "wall", "ward", "castle", "hut", "shed" (the tram shed).
	var style: String = "ruin"
	## Lean in degrees (crumbling buildings tilt a little).
	var lean: float = 0.0
	var variant: int = 0
	var tint: Color = Color.WHITE
	## Which of the broken-service districts it belongs to ("" = none) - freed districts repair/re-light it.
	var district: String = ""


class Prop:
	extends RefCounted
	var kind: String = ""
	var pos: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var model_scale: float = 1.0
	## Blocks movement within this radius (0 = decoration only).
	var radius: float = 0.0
	var variant: int = 0
	var district: String = ""


class Sign:
	extends RefCounted
	var key: String = ""
	var pos: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var size: float = 1.0
	## "sign" (post sign), "poster" (framed), "banner" (a hung decree), "wall" (painted on a wall).
	var style: String = "sign"


class Area:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var rect: Rect2i = Rect2i()


class Rift:
	extends RefCounted
	var id: String = ""
	var pos: Vector2 = Vector2.ZERO
	var radius: float = 1.8
	var big: bool = false
	## Sealable rifts can be closed (after beating their guardian) for a reward; big ones stay until Primm falls.
	var sealable: bool = false
	## Gold / item / card / equipment for sealing it.
	var reward: Dictionary = {}


var cells: PackedByteArray = PackedByteArray()
var floors: PackedByteArray = PackedByteArray()
var areas: Array[Area] = []
var buildings: Array[Building] = []
var props: Array[Prop] = []
var signs: Array[Sign] = []
var rifts: Array[Rift] = []
var anchors: Dictionary = {}
var chests: Dictionary = {}
var enemy_spawns: Array[Dictionary] = []
## The routes: [{id, a: Vector2, b: Vector2, width}] (centre lines; main roads 4.2 m or more, spurs 3.6 m).
var routes: Array[Dictionary] = []
## Static obstacles (x, z, radius), indexed by the builder.
var obstacles: Array[Vector3] = []
## Where the gate barrier stands (circles that block the opening until the gate is open): [Vector3(x, z, radius)].
var gate_blockers: Array[Vector3] = []
## Cracks in the ground: [{pos: Vector2, yaw: float, length: float}].
var cracks: Array[Dictionary] = []
## Where the outside's wasteland pieces gather (`CapitalWasteland`): [Vector3(x, z, radius)] at the edges, off every route and anchor.
var wasteland_clusters: Array[Vector3] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build() -> void:
	_rng.seed = 1010
	cells.resize(W * H)
	floors.resize(W * H)
	_routes()
	_ground()
	_areas()
	_anchors()
	_chests()
	_rifts()
	_walls_and_gate()
	_plaza()
	_palace_approach()
	_reek()
	_grave_row()
	_transit_yards()
	_hungry_quarter()
	_ward()
	_gate_road()
	_camp()
	_rift_fields()
	_tunnels()
	_outpost()
	_crease()
	_enemies()
	_cracks()
	_clusters()
	_index_obstacles()


# ---- Grid helpers ----------------------------------------------------------------------------------


func in_bounds(cx: int, cz: int) -> bool:
	return cx >= 0 and cz >= 0 and cx < W and cz < H


func cell_at(cx: int, cz: int) -> Cell:
	if not in_bounds(cx, cz):
		return Cell.VOID
	return cells[cz * W + cx] as Cell


func floor_at(cx: int, cz: int) -> Floor:
	if not in_bounds(cx, cz):
		return Floor.NONE
	return floors[cz * W + cx] as Floor


func is_ground_cell(cx: int, cz: int) -> bool:
	return cell_at(cx, cz) == Cell.GROUND


func cell_of(x: float, z: float) -> Vector2i:
	return Vector2i(int(floorf(x)), int(floorf(z)))


func _set_cells(rect: Rect2i, cell: Cell, floor_kind: Floor = Floor.NONE) -> void:
	for cz: int in range(rect.position.y, rect.end.y):
		for cx: int in range(rect.position.x, rect.end.x):
			if in_bounds(cx, cz):
				cells[cz * W + cx] = cell
				if floor_kind != Floor.NONE:
					floors[cz * W + cx] = floor_kind


func _floor_rect(rect: Rect2i, floor_kind: Floor) -> void:
	for cz: int in range(rect.position.y, rect.end.y):
		for cx: int in range(rect.position.x, rect.end.x):
			if in_bounds(cx, cz) and cells[cz * W + cx] != Cell.VOID:
				floors[cz * W + cx] = floor_kind


func walkable_cell_count() -> int:
	var count: int = 0
	for value: int in cells:
		if value == Cell.GROUND:
			count += 1
	return count


## True north of the great wall (inside the city).
static func is_inside_z(z: float) -> bool:
	return z < float(WALL_Z0)


# ---- Routes --------------------------------------------------------------------------------------------


func _route(id: String, a: Vector2, b: Vector2, width: float) -> void:
	routes.append({"id": id, "a": a, "b": b, "width": width})


func _routes() -> void:
	# Outside: the Gate Road from town through the gate, the wall road along the wall's foot, the south road past the camp and the outpost, the
	# west and east tracks that close the two loops (gate - wall road - track - south road - gate, on each side).
	_route("gate_road", Vector2(60.0, 120.5), Vector2(60.0, 69.0), 6.0)
	_route("wall_road_w", Vector2(10.0, 81.5), Vector2(57.0, 81.5), MAIN_ROUTE_WIDTH)
	_route("wall_road_e", Vector2(63.0, 81.5), Vector2(108.0, 81.5), MAIN_ROUTE_WIDTH)
	_route("south_road_w", Vector2(10.0, 106.0), Vector2(57.0, 106.0), MAIN_ROUTE_WIDTH)
	_route("south_road_e", Vector2(63.0, 106.0), Vector2(108.0, 106.0), MAIN_ROUTE_WIDTH)
	_route("west_track", Vector2(10.0, 81.5), Vector2(10.0, 106.0), MAIN_ROUTE_WIDTH)
	_route("east_track", Vector2(108.0, 81.5), Vector2(108.0, 106.0), MAIN_ROUTE_WIDTH)
	# Inside: the grand avenue from the plaza to the castle stair (the gate road ends at the plaza's rim, the plaza is open), the forecourt along the castle hill, the two ring streets, the plaza boulevards,
	# the district separators and lanes. Every district sits on a loop.
	_route("avenue", Vector2(60.0, 47.5), Vector2(60.0, 14.0), 6.0)
	_route("forecourt", Vector2(36.5, 15.0), Vector2(83.5, 15.0), MAIN_ROUTE_WIDTH)
	_route("ring_w", Vector2(38.5, 15.0), Vector2(38.5, 70.0), MAIN_ROUTE_WIDTH)
	_route("ring_e", Vector2(81.5, 15.0), Vector2(81.5, 70.0), MAIN_ROUTE_WIDTH)
	_route("boulevard_w", Vector2(19.0, 58.0), Vector2(50.0, 58.0), MAIN_ROUTE_WIDTH)
	_route("boulevard_e", Vector2(70.0, 58.0), Vector2(100.0, 58.0), MAIN_ROUTE_WIDTH)
	_route("separator_w", Vector2(4.0, 35.0), Vector2(38.5, 35.0), MAIN_ROUTE_WIDTH)
	_route("separator_e1", Vector2(81.5, 21.0), Vector2(115.5, 21.0), MAIN_ROUTE_WIDTH)
	_route("separator_e2", Vector2(81.5, 45.0), Vector2(115.5, 45.0), MAIN_ROUTE_WIDTH)
	_route("grave_lane", Vector2(19.0, 4.0), Vector2(19.0, 35.0), MAIN_ROUTE_WIDTH)
	_route("reek_lane", Vector2(19.0, 35.0), Vector2(19.0, 70.0), MAIN_ROUTE_WIDTH)
	_route("hungry_lane", Vector2(100.0, 21.0), Vector2(100.0, 45.0), MAIN_ROUTE_WIDTH)
	_route("transit_lane", Vector2(100.0, 45.0), Vector2(100.0, 58.0), MAIN_ROUTE_WIDTH)


## Distance from (x, z) to the nearest route's edge (negative inside a route).
func route_edge_distance(x: float, z: float) -> float:
	var best: float = INF
	var p: Vector2 = Vector2(x, z)
	for route: Dictionary in routes:
		var a: Vector2 = route["a"] as Vector2
		var b: Vector2 = route["b"] as Vector2
		best = minf(best, p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b)) - float(route["width"]) * 0.5)
	return best


## Distance from a rect (a building's footprint) to the nearest route's edge (negative when it overlaps one).
func rect_route_distance(rect: Rect2) -> float:
	var best: float = INF
	for route: Dictionary in routes:
		var a: Vector2 = route["a"] as Vector2
		var b: Vector2 = route["b"] as Vector2
		var half: float = float(route["width"]) * 0.5
		# sample the route's centre line and measure each point to the rect
		var steps: int = maxi(1, int(a.distance_to(b) / 0.5))
		for index: int in range(steps + 1):
			var p: Vector2 = a.lerp(b, float(index) / float(steps))
			var dx: float = maxf(maxf(rect.position.x - p.x, 0.0), p.x - rect.end.x)
			var dz: float = maxf(maxf(rect.position.y - p.y, 0.0), p.y - rect.end.y)
			best = minf(best, Vector2(dx, dz).length() - half)
	return best


# ---- Ground and areas --------------------------------------------------------------------------------


func _ground() -> void:
	_set_cells(Rect2i(2, WALL_Z1 + 1, 116, OUT_Z1 - WALL_Z1), Cell.GROUND, Floor.GRAVEL)  # the outside (z 76..121)
	_set_cells(Rect2i(2, 2, 116, WALL_Z0 - 2), Cell.GROUND, Floor.ROAD)                   # the city inside the wall (z 2..71)
	_set_cells(Rect2i(GATE_X0, WALL_Z0, GATE_X1 - GATE_X0 + 1, WALL_Z1 - WALL_Z0 + 1), Cell.GROUND, Floor.ROAD)  # the gate
	_set_cells(Rect2i(PASSAGE_X0, WALL_Z0, PASSAGE_W, WALL_Z1 - WALL_Z0 + 1), Cell.GROUND, Floor.GRAVEL)  # the secret passage through the wall
	_set_cells(HILL, Cell.VOID)                                                           # the castle hill (the stair climbs it)
	_set_cells(Rect2i(4, CREASE_Z0, 37, 21), Cell.GROUND, Floor.HUB)                      # the Crease (x 4..40, z 134..154)
	# District floors (inside every floor is painted idyllic; the kinds keep each district's tone).
	_floor_rect(Rect2i(2, 2, 37, 33), Floor.GRAY)                       # Grave Row
	_floor_rect(Rect2i(2, 37, 37, 35), Floor.SOIL)                      # the Reek
	_floor_rect(Rect2i(84, 2, 34, 19), Floor.GRAY)                      # the Correction Ward
	_floor_rect(Rect2i(84, 23, 34, 22), Floor.TILE)                     # the Hungry Quarter
	_floor_rect(Rect2i(84, 47, 34, 25), Floor.METAL)                    # the Transit Yards
	_floor_rect(Rect2i(41, 17, 38, 31), Floor.LAWN)                     # the palace approach's lawns
	# Routes: cracked road outside, cream streets inside; the avenue, the forecourt and the Gate Plaza are paved.
	for route: Dictionary in routes:
		_paint_route(route)
	_floor_rect(Rect2i(55, 13, 11, 35), Floor.PLAZA)
	_floor_rect(Rect2i(36, 12, 48, 6), Floor.PLAZA)
	for cz: int in range(44, WALL_Z0):
		for cx: int in range(41, 80):
			if Vector2(float(cx) + 0.5, float(cz) + 0.5).distance_to(PLAZA_CENTER) <= PLAZA_RADIUS + 2.5 or cz >= 66:
				floors[cz * W + cx] = Floor.PLAZA


func _paint_route(route: Dictionary) -> void:
	var a: Vector2 = route["a"] as Vector2
	var b: Vector2 = route["b"] as Vector2
	var half: float = float(route["width"]) * 0.5
	var box: Rect2 = Rect2(a, Vector2.ZERO).expand(b).grow(half + 1.0)
	for cz: int in range(int(box.position.y), int(box.end.y) + 1):
		for cx: int in range(int(box.position.x), int(box.end.x) + 1):
			if not in_bounds(cx, cz) or cells[cz * W + cx] != Cell.GROUND:
				continue
			var p: Vector2 = Vector2(float(cx) + 0.5, float(cz) + 0.5)
			if p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b)) <= half:
				floors[cz * W + cx] = Floor.ROAD


func _add_area(id: String, title: String, rect: Rect2i) -> void:
	var area: Area = Area.new()
	area.id = id
	area.title = title
	area.rect = rect
	areas.append(area)


## First match wins (`area_at`), so the small and the overlapping rects come first.
func _areas() -> void:
	_add_area("crease", "The Crease", Rect2i(4, CREASE_Z0, 37, 21))
	# Inside.
	_add_area("plaza", "The Gate Plaza", Rect2i(41, 47, 39, WALL_Z0 - 47))
	_add_area("approach", "The Palace Approach", Rect2i(41, 12, 39, 35))
	_add_area("approach", "The Palace Approach", Rect2i(36, 0, 48, 12))
	_add_area("grave", "Grave Row", Rect2i(2, 2, 39, 35))
	_add_area("reek", "The Reek", Rect2i(2, 37, 39, WALL_Z0 - 37))
	_add_area("ward", "The Correction Ward", Rect2i(80, 2, 38, 21))
	_add_area("hungry", "The Hungry Quarter", Rect2i(80, 23, 38, 24))
	_add_area("transit", "The Transit Yards", Rect2i(80, 47, 38, WALL_Z0 - 47))
	# Outside (the gate opening counts as the Gate Road).
	_add_area("passage", "The Wall Passage", Rect2i(16, WALL_Z0, 14, 7))
	_add_area("gate", "The Gate Road", Rect2i(44, WALL_Z0, 32, OUT_Z1 - WALL_Z0 + 1))
	_add_area("rifts", "The Rift Fields", Rect2i(2, WALL_Z1 + 1, 42, 26))
	_add_area("camp", "The Resistance Camp", Rect2i(2, 102, 42, OUT_Z1 - 101))
	_add_area("tunnels", "The Old Service Tunnels", Rect2i(76, WALL_Z1 + 1, 42, 15))
	_add_area("outpost", "The Ruined Outpost", Rect2i(76, 91, 42, OUT_Z1 - 90))


func area_at(x: float, z: float) -> Area:
	var cell: Vector2i = cell_of(x, z)
	for area: Area in areas:
		if area.rect.has_point(cell):
			return area
	return null


# ---- Anchors, chests, rifts ------------------------------------------------------------------------------


func _anchor(anchor_name: String, x: float, z: float) -> void:
	anchors[anchor_name] = Vector3(x, 0.0, z)


func _anchors() -> void:
	# The Gate Road (the outside hub): the arrival from town, the queue, the gate captain and his guards at the gate.
	_anchor("spawn", 60.0, 114.0)
	_anchor("exit", 60.0, 119.5)
	_anchor("spotless", 60.0, 77.5)
	_anchor("guard_height", 50.0, 77.5)
	_anchor("guard_queue", 70.0, 77.5)
	_anchor("queue_sign", 53.5, 88.0)
	# The resistance camp (south-west), the rift fields (north-west, under the wall), the Old Service Tunnels (north-east), the ruined outpost (south-east).
	_anchor("camp", CAMP_FIRE.x, CAMP_FIRE.y)
	_anchor("kestrel", 29.5, 111.0)
	_anchor("checkpoint_a", 15.5, 95.0)
	_anchor("tunnel_in", 4.5, 88.5)
	_anchor("old_tunnels", 96.0, 78.0)
	_anchor("checkpoint_b", 97.0, 112.5)
	# The gate and the Gate Plaza (the inside hub).
	_anchor("gate_inside", 60.0, 69.5)
	_anchor("guard_in_1", 54.5, 68.5)
	_anchor("guard_in_2", 65.5, 68.5)
	_anchor("plaza_statue", PLAZA_CENTER.x, PLAZA_CENTER.y)
	_anchor("fountain", PLAZA_CENTER.x, PLAZA_CENTER.y)
	_anchor("exit_booth", 71.0, 63.0)
	_anchor("complaint_1", 49.0, 63.0)
	_anchor("manhole", 48.5, 52.0)
	_anchor("net_plaza", 71.5, 52.0)
	# The palace approach: the facade's things in one line on each verge of the avenue, the citizens on the avenue and in the alleys between the
	# identical houses, the castle door at the foot of the stair.
	_anchor("facade_gate", 60.0, 46.0)
	_anchor("portrait_f1", 54.6, 21.5)
	_anchor("poster_f2", 65.4, 21.5)
	_anchor("speaker_1", 54.6, 28.5)
	_anchor("speaker_2", 65.4, 28.5)
	_anchor("poster_f1", 54.6, 35.5)
	_anchor("portrait_f2", 65.4, 35.5)
	_anchor("portrait_f3", 54.6, 42.0)
	_anchor("speaker_3", 65.4, 42.0)
	_anchor("complaint_2", 65.4, 45.5)
	for index: int in range(_facade_citizen_spots().size()):
		_anchor("citizen_%d" % (index + 1), _facade_citizen_spots()[index].x, _facade_citizen_spots()[index].y)
	_anchor("door_1", 51.5, 24.2)
	_anchor("door_2", 68.5, 24.2)
	_anchor("door_3", 45.5, 38.2)
	_anchor("door_4", 74.5, 38.2)
	_anchor("castle_door", 60.0, 13.0)
	_anchor("net_approach", 67.0, 15.0)
	_anchor("portrait_a1", 45.0, 10.5)
	_anchor("portrait_a2", 75.0, 11.0)
	_anchor("portrait_a3", 53.0, 12.4)
	_anchor("poster_a1", 67.0, 12.4)
	_anchor("approach_sign", 71.0, 12.4)
	# The Reek (Refusemancers), west, behind the passage.
	_anchor("fern", 27.5, 46.0)
	_anchor("heap_1", 4.5, 40.5)
	_anchor("heap_2", 31.0, 67.5)
	_anchor("heap_3", 5.0, 69.0)
	_anchor("sick_patch", 29.0, 40.0)
	_anchor("seed", 5.0, 52.0)
	_anchor("net_reek", 32.0, 52.5)
	# Grave Row (Necrocrats), north-west.
	_anchor("pell", 28.5, 26.0)
	_anchor("permit_window", 8.0, 24.5)
	_anchor("stamp", 7.0, 13.0)
	_anchor("pell_plot", 26.5, 6.0)
	_anchor("net_grave", 32.5, 30.5)
	# The Transit Yards (Beefcakes), south-east: the energy wheels in a row along the wall, the tram shed, the cable.
	_anchor("rollo", 106.0, 62.0)
	_anchor("wheel_1", 91.0, 70.0)
	_anchor("wheel_2", 101.0, 70.0)
	_anchor("wheel_3", 111.0, 70.0)
	_anchor("cable", 110.0, 58.5)
	_anchor("net_transit", 86.0, 63.5)
	# The Hungry Quarter (Gourmands), east: the identical row either side of its lane.
	_anchor("marlo", 95.0, 33.0)
	_anchor("recipe_1", 95.0, 26.0)
	_anchor("recipe_2", 115.5, 29.8)
	_anchor("recipe_3", 113.0, 41.5)
	_anchor("dispenser", 105.5, 38.5)
	_anchor("net_hungry", 95.5, 40.5)
	# The Correction Ward, north-east.
	_anchor("ward_window", 100.0, 13.5)
	_anchor("ward_patient", 110.0, 8.0)
	_anchor("ward_speaker", 96.0, 5.5)
	# The Crease (the hideout): everything is underground, south of the world.
	var dz: float = float(CREASE_Z0 - 100)
	_anchor("crease_spawn", 22.0, 116.0 + dz)
	_anchor("rift_station", 28.0, 112.0 + dz)
	_anchor("wren", 14.0, 106.0 + dz)
	_anchor("fig", 31.0, 106.0 + dz)
	_anchor("fig_crate", 36.0, 110.0 + dz)
	_anchor("heal", 22.0, 104.0 + dz)
	_anchor("ladder_up", 7.0, 112.0 + dz)
	_anchor("tunnel_out", 38.0, 114.0 + dz)
	for index: int in range(NETWORK_DESTINATIONS.size()):
		_anchor("shaft_" + NETWORK_DESTINATIONS[index], 9.0 + 5.0 * float(index), 118.5 + dz)


## The service-tunnel network's destinations: shaft id -> the street anchor it surfaces at.
const NETWORK_DESTINATIONS: Array[String] = ["plaza", "reek", "grave", "hungry", "transit", "approach"]


## The nine citizens of Perfection: pairs on the avenue (each side), three in the middle alleys between the identical houses (they stroll 3 m about
## their spots, so each spot keeps clear of the doors).
func _facade_citizen_spots() -> Array[Vector2]:
	return [Vector2(58.0, 25.0), Vector2(62.0, 25.0), Vector2(58.0, 31.0), Vector2(62.0, 31.0), Vector2(58.0, 40.0), Vector2(62.0, 40.0), Vector2(46.5, 32.0), Vector2(73.5, 32.0), Vector2(51.5, 32.0)] as Array[Vector2]


func _chests() -> void:
	var dz: float = float(CREASE_Z0 - 100)
	chests = {
		"chest_wreck": Vector3(8.5, 0.0, 119.5),
		"chest_rock": Vector3(115.0, 0.0, 77.5),
		"chest_reek": Vector3(13.0, 0.0, 53.5),
		"chest_crypt": Vector3(3.5, 0.0, 30.0),
		"chest_cellar": Vector3(116.0, 0.0, 36.0),
		"chest_wheel": Vector3(115.5, 0.0, 66.0),
		"chest_lane": Vector3(37.5, 0.0, 3.0),
		"chest_corner": Vector3(86.0, 0.0, 3.0),
		"chest_ward": Vector3(115.5, 0.0, 4.0),
		# Polish round: two behind the facade houses, two in the Crease, one in the ward's far end, one in the farthest corner of Grave Row.
		"chest_facade_back": Vector3(77.8, 0.0, 25.0),
		"chest_facade_west": Vector3(42.0, 0.0, 32.0),
		"chest_crease_e": Vector3(40.2, 0.0, 100.8 + dz),
		"chest_crease_w": Vector3(4.8, 0.0, 100.8 + dz),
		"chest_ward_n": Vector3(90.5, 0.0, 11.5),
		"chest_yard_corner": Vector3(2.4, 0.0, 2.4),
	}


func _add_rift(id: String, x: float, z: float, radius: float, big: bool, sealable: bool, reward: Dictionary = {}) -> void:
	var rift: Rift = Rift.new()
	rift.id = id
	rift.pos = Vector2(x, z)
	rift.radius = radius
	rift.big = big
	rift.sealable = sealable
	rift.reward = reward
	rifts.append(rift)
	_anchor("rift_" + id, x, z)
	if sealable:
		_anchor("seal_" + id, x + radius + 1.6, z + 0.4)


func _rifts() -> void:
	for entry: Dictionary in CapitalRifts.all():
		_add_rift(str(entry["id"]), float(entry["x"]), float(entry["z"]), float(entry["radius"]), bool(entry["big"]), bool(entry["sealable"]), entry["reward"] as Dictionary)


# ---- Props / buildings / signs helpers ----------------------------------------------------------------------


func _prop(kind: String, x: float, z: float, yaw: float = 0.0, model_scale: float = 1.0, radius: float = 0.0, variant: int = 0, district: String = "") -> Prop:
	var prop: Prop = Prop.new()
	prop.kind = kind
	prop.pos = Vector3(x, 0.0, z)
	prop.yaw = yaw
	prop.model_scale = model_scale
	prop.radius = radius
	prop.variant = variant
	prop.district = district
	props.append(prop)
	return prop


## A prop standing exactly on its anchor (the builder finds stateful props by their anchor's position).
func _prop_at(kind: String, anchor_name: String, radius: float = 0.0, yaw: float = 0.0, district: String = "", variant: int = 0) -> Prop:
	var pos: Vector3 = anchors[anchor_name] as Vector3
	return _prop(kind, pos.x, pos.z, yaw, 1.0, radius, variant, district)


func _sign(key: String, x: float, z: float, yaw: float = 0.0, size: float = 1.0, style: String = "sign") -> void:
	var sign_data: Sign = Sign.new()
	sign_data.key = key
	sign_data.pos = Vector3(x, 0.0, z)
	sign_data.yaw = yaw
	sign_data.size = size
	sign_data.style = style
	signs.append(sign_data)


## A building: marks its cells SOLID and records it for the builder.
func _building(style: String, x: float, z: float, w: float, d: float, height: float, lean: float = 0.0, district: String = "", variant: int = 0) -> Building:
	var building: Building = Building.new()
	building.style = style
	building.rect = Rect2(x, z, w, d)
	building.height = height
	building.lean = lean
	building.district = district
	building.variant = variant
	buildings.append(building)
	_set_cells(Rect2i(int(floorf(x)), int(floorf(z)), int(ceilf(x + w)) - int(floorf(x)), int(ceilf(z + d)) - int(floorf(z))), Cell.SOLID)
	return building


## A neat row of identical buildings (the city is perfect: the same size, the same gap, the same height).
func _row(style: String, x: float, z: float, w: float, d: float, height: float, count: int, step: Vector2, district: String, lean: float = 0.0) -> void:
	for index: int in range(count):
		_building(style, x + step.x * float(index), z + step.y * float(index), w, d, height, lean * (1.0 if index % 2 == 0 else -1.0), district, index % 3)


# ---- The great wall and the gate --------------------------------------------------------------------------------------


func _walls_and_gate() -> void:
	# The great wall (9 m, five hero-heights: the Cinematic camera sees about 6 degrees above the horizon, so a taller wall would hide the castle from
	# every outside view): rows WALL_Z0..WALL_Z1 across the whole width except the gate opening; two 14 m towers frame the gate. The left-hand
	# wall is two pieces with a 2 m gap between them (the secret passage).
	var depth: float = float(WALL_Z1 - WALL_Z0 + 1)
	_building("wall", 2.0, float(WALL_Z0), float(PASSAGE_X0 - 2), depth, 9.0, 0.0, "", 0)
	_building("wall", float(PASSAGE_X0 + PASSAGE_W), float(WALL_Z0), float(GATE_X0 - 5 - PASSAGE_X0 - PASSAGE_W), depth, 9.0, 0.0, "", 0)
	_building("wall", float(GATE_X1 + 6), float(WALL_Z0), float(118 - GATE_X1 - 6), depth, 9.0, 0.0, "", 0)
	_building("tower", float(GATE_X0 - 5), float(WALL_Z0) - 0.5, 5.0, depth + 1.0, 14.0, 0.0, "", 0)
	_building("tower", float(GATE_X1 + 1), float(WALL_Z0) - 0.5, 5.0, depth + 1.0, 14.0, 0.0, "", 1)
	# The barrier that closes the opening: circles along the gap, removed when the gate battle is won.
	var gx: float = float(GATE_X0) + 0.5
	while gx <= float(GATE_X1) + 1.0:
		gate_blockers.append(Vector3(gx, float(WALL_Z0) + 1.0, 1.15))
		gx += 1.4
	# Plaques on the towers' faces (never in the opening, where the hero walks).
	_sign("sign.gate_main", 52.5, float(WALL_Z0) - 0.8, 0.0, 1.3, "wall")
	_sign("sign.gate_inside", 67.5, float(WALL_Z1) + 1.3, 180.0, 1.3, "wall")
	_sign("sign.gate_requirements", 65.8, 85.0, 270.0, 1.0, "sign")
	_sign("sign.gate_height", 47.0, 77.5, 0.0, 0.9, "sign")
	_sign("sign.gate_exit_inside", 72.5, 66.5, 180.0, 0.9, "sign")
	# The secret passage: only a subtle hint from the outside - a crack up the wall beside a gap half-hidden by dry scrub and a few loose stones.
	var passage_x: float = float(PASSAGE_X0) + float(PASSAGE_W) * 0.5
	_prop("wall_crack", float(PASSAGE_X0) - 0.15, float(WALL_Z1) + 1.02, 0.0, 1.0, 0.0)
	_prop("wall_crack", float(PASSAGE_X0 + PASSAGE_W) + 0.4, float(WALL_Z1) + 1.02, 0.0, 0.7, 0.0, 1)
	_prop("loose_stones", passage_x - 0.5, float(WALL_Z1) + 1.7, 20.0, 1.0, 0.0)
	_prop("loose_stones", passage_x + 1.1, float(WALL_Z1) + 2.2, 80.0, 0.8, 0.0, 1)
	_prop("scrub", passage_x - 1.3, float(WALL_Z1) + 1.7, 0.0, 1.0, 0.0)
	_prop("scrub", passage_x + 0.2, float(WALL_Z1) + 1.5, 40.0, 1.15, 0.0, 1)
	_prop("scrub", passage_x + 1.4, float(WALL_Z1) + 1.8, 110.0, 0.9, 0.0, 2)
	anchors["wall_passage"] = Vector3(passage_x, 0.0, float(WALL_Z0) + 2.0)
	_prop("gate_barrier", 60.0, float(WALL_Z0) + 1.0, 0.0, 1.0, 0.0)


# ---- The Gate Plaza (the inside hub) ----------------------------------------------------------------------------------------


func _plaza() -> void:
	# The Primm statue fountain at the centre of an empty round; the hub's things on its rim, each facing in.
	_prop("fountain", PLAZA_CENTER.x, PLAZA_CENTER.y, 0.0, 1.55, 3.3)
	_prop_at("booth", "exit_booth", 0.9, 270.0, "", 2)
	_prop_at("complaint_box", "complaint_1", 0.35, 90.0)
	_prop_at("manhole", "manhole")
	_prop_at("manhole", "net_plaza")
	for lamp: Vector2 in [Vector2(51.0, 49.0), Vector2(69.0, 49.0), Vector2(50.5, 67.0), Vector2(69.5, 67.0)]:
		_prop("lamp_perfect", lamp.x, lamp.y, 0.0, 1.0, 0.25)
	_prop("bench", 47.0, 54.4, 90.0)
	_prop("bench", 73.0, 54.4, 270.0)
	_sign("sign.plaza_main", 54.0, 49.0, 0.0, 1.2, "banner")
	_sign("sign.facade_welcome", 66.0, 49.0, 0.0, 1.2, "banner")
	_sign("sign.plaza_exit_interview", 73.5, 60.5, 270.0, 0.8, "sign")
	_sign("sign.plaza_complaints", 46.0, 63.0, 90.0, 0.8, "sign")
	_sign("sign.net_plaza", 74.0, 52.0, 270.0, 0.7, "sign")


# ---- The palace approach (the Showcase: identical houses either side of the grand avenue) ------------------------------------------


func _palace_approach() -> void:
	# Sixteen identical houses: four rows of four, two columns each side of the avenue, the same 4 m square, the same gap. The two nearest the
	# plaza beside the avenue are painted storefronts (doors that do not open).
	var xs: Array[float] = [43.5, 49.5, 66.5, 72.5]
	var zs: Array[float] = [19.5, 26.5, 33.5, 40.5]
	var shop_index: int = 0
	for column: int in range(xs.size()):
		for row: int in range(zs.size()):
			var is_shop: bool = (column == 1 or column == 2) and row == 3
			if is_shop:
				shop_index += 1
			var house: Building = _building("shop" if is_shop else "house", xs[column], zs[row], 4.0, 4.0, 3.4 if not is_shop else 3.8, 0.0, "facade", shop_index)
			house.tint = Color.WHITE
	# The verges: portraits, posters and loudspeakers at their spots, lamps between them, one line each side.
	for portrait: String in ["portrait_f1", "portrait_f2", "portrait_f3"]:
		_prop_at("portrait", portrait, 0.45, 90.0 if (anchors[portrait] as Vector3).x < 60.0 else 270.0)
	for poster: String in ["poster_f1", "poster_f2"]:
		_prop_at("portrait", poster, 0.45, 90.0 if (anchors[poster] as Vector3).x < 60.0 else 270.0, "", 2)
	for speaker: String in ["speaker_1", "speaker_2", "speaker_3"]:
		_prop_at("loudspeaker", speaker, 0.3, 90.0 if (anchors[speaker] as Vector3).x < 60.0 else 270.0)
	_prop_at("complaint_box", "complaint_2", 0.35, 270.0)
	for lamp_z: float in [25.0, 32.0, 38.8]:
		_prop("lamp_perfect", 54.6, lamp_z, 0.0, 1.0, 0.25)
		_prop("lamp_perfect", 65.4, lamp_z, 0.0, 1.0, 0.25)
	_sign("sign.facade_hats", 42.0, 26.0, 90.0, 0.8, "sign")
	_sign("sign.facade_smile", 78.0, 33.0, 270.0, 0.8, "sign")
	_sign("sign.facade_shop_1", 51.5, 40.3, 0.0, 0.9, "wall")
	_sign("sign.facade_shop_2", 68.5, 40.3, 0.0, 0.9, "wall")
	# The forecourt at the foot of Primm's Castle: the approach's portraits flank the stair; the castle and its hill are a stand-in (CapitalLandmarks).
	for portrait: String in ["portrait_a1", "portrait_a2", "portrait_a3"]:
		_prop_at("portrait", portrait, 0.45, 0.0, "", 1)
	_prop_at("portrait", "poster_a1", 0.45, 0.0, "", 2)
	_prop_at("manhole", "net_approach")
	_prop("lamp_perfect", 44.0, 18.6, 0.0, 1.0, 0.25)
	_prop("lamp_perfect", 76.0, 18.6, 0.0, 1.0, 0.25)
	_sign("sign.castle_warning", 71.0, 12.4, 0.0, 0.9, "sign")
	_sign("sign.net_approach", 64.5, 18.6, 0.0, 0.7, "sign")


# ---- The Reek (Refusemancers: garbage hidden behind the facade) -----------------------------------------------------


func _reek() -> void:
	# The Reek's back lane: the passage through the wall comes out at its south end between the leaning rear walls of the houses (the same size,
	# broken), the compost heaps in the corners, Old Fern's shack by the sick patch, junk in two tidy piles.
	_row("ruin", 3.0, 62.5, 4.5, 3.5, 5.0, 2, Vector2(6.5, 0.0), "refusemancer", 4.0)
	_building("ruin", 24.5, 62.5, 4.0, 3.5, 5.0, -3.0, "refusemancer", 1)
	_building("ruin", 9.5, 39.5, 5.0, 3.5, 5.5, 3.0, "refusemancer", 2)
	for heap_anchor: String in ["heap_1", "heap_2", "heap_3"]:
		_prop_at("compost_heap", heap_anchor, 0.0, 0.0, "refusemancer")
	_prop_at("sick_patch", "sick_patch", 0.0, 0.0, "refusemancer")
	var fern_pos: Vector3 = anchors["fern"] as Vector3
	_prop("stall_shack", fern_pos.x + 3.0, fern_pos.z - 1.5, 270.0, 1.0, 1.4)
	_prop_at("seed_jar", "seed")
	_prop_at("manhole", "net_reek")
	for junk: Vector3 in [Vector3(33.5, 63.5, 0.0), Vector3(25.5, 52.5, 1.0)]:
		_prop("junk_pile", junk.x, junk.y, 30.0 + junk.z * 70.0, 1.3, 1.3, int(junk.z), "refusemancer")
	_sign("sign.reek_main", 22.0, 39.0, 0.0, 1.0, "wall")
	_sign("sign.reek_untidy", 15.0, 57.5, 90.0, 0.9, "sign")
	_sign("sign.reek_sick_patch", 32.0, 40.0, 270.0, 0.8, "sign")
	_sign("sign.net_reek", 34.5, 52.5, 270.0, 0.7, "sign")


# ---- Grave Row (Necrocrats: the permit-locked cemetery) ---------------------------------------------------------------


func _grave_row() -> void:
	# The Grave Row lane: a straight cemetery lane lined with two perfect rows of identical headstones, crypts at the north end, the permit office
	# on the west, the Pell parlour and the family plot on the east.
	_row("crypt", 5.0, 3.0, 4.0, 4.0, 4.5, 2, Vector2(5.5, 0.0), "necrocrat")
	_building("crypt", 30.5, 2.5, 3.5, 4.0, 4.5, 0.0, "necrocrat", 2)
	for index: int in range(10):
		var z: float = 9.5 + float(index) * 2.2
		_prop("grave", 14.4, z, 90.0, 1.0, 0.45, index % 3, "necrocrat")
		_prop("grave", 23.6, z, 270.0, 1.0, 0.45, (index + 1) % 3, "necrocrat")
	var pell_pos: Vector3 = anchors["pell"] as Vector3
	_prop("parlor", pell_pos.x + 3.5, pell_pos.z - 1.0, 270.0, 1.0, 1.8)
	var permit: Vector3 = anchors["permit_window"] as Vector3
	_prop("permit_office", permit.x, permit.z - 1.4, 0.0, 1.0, 1.6)
	_prop("notary_booth", 3.8, 13.0, 90.0, 1.0, 0.9)
	_prop_at("family_plot", "pell_plot")
	_prop_at("manhole", "net_grave")
	_sign("sign.grave_main", 19.0, 2.6, 0.0, 1.0, "wall")
	_sign("sign.grave_permit", 11.0, 24.5, 270.0, 0.9, "sign")
	_sign("sign.grave_plot", 26.5, 9.0, 0.0, 0.8, "sign")
	_sign("sign.net_grave", 34.5, 30.5, 270.0, 0.7, "sign")


# ---- The Transit Yards (Beefcakes: the energy wheels and the dead lines) -----------------------------------------------


func _transit_yards() -> void:
	# The tram shed (a long open shed over the dead tram) in the north-east block, the three energy wheels in a row along the wall, two pylons at
	# its ends, the big rift in the north-west block.
	_building("shed", TRAM_SHED.position.x, TRAM_SHED.position.y, TRAM_SHED.size.x, TRAM_SHED.size.y, 6.5, 0.0, "beefcake", 0)
	for wheel: String in ["wheel_1", "wheel_2", "wheel_3"]:
		var pos: Vector3 = anchors[wheel] as Vector3
		_prop("energy_wheel", pos.x, pos.z - 3.0, 0.0, 1.0, 2.6, 0, "beefcake")
	var rollo_pos: Vector3 = anchors["rollo"] as Vector3
	_prop("crate_stack", rollo_pos.x + 3.5, rollo_pos.z + 1.5, 0.0, 1.0, 1.0)
	_prop_at("power_cable", "cable", 0.0, 0.0, "beefcake")
	for pylon_x: float in [86.0, 106.0]:
		_prop("pylon", pylon_x, 66.0, 0.0, 1.0, 0.5, 0, "beefcake")
	_prop_at("manhole", "net_transit")
	_sign("sign.transit_main", 109.5, 48.9, 0.0, 1.0, "wall")
	_sign("sign.transit_cardio", 90.0, 61.5, 0.0, 0.9, "sign")
	_sign("sign.transit_cable", 113.5, 58.5, 270.0, 0.8, "sign")
	_sign("sign.net_transit", 84.0, 63.5, 90.0, 0.7, "sign")


# ---- The Hungry Quarter (Gourmands: shuttered stalls, the paste dispenser) -------------------------------------------------


func _hungry_quarter() -> void:
	# The identical row: three identical shuttered stall-houses each side of the lane, mirrored about it; the dispenser on the lane's east side.
	_row("stall", 86.0, 25.5, 4.0, 3.5, 3.6, 3, Vector2(0.0, 5.5), "gourmand")
	_row("stall", 110.0, 25.5, 4.0, 3.5, 3.6, 3, Vector2(0.0, 5.5), "gourmand")
	_prop_at("paste_dispenser", "dispenser", 0.8, 90.0, "gourmand")
	var marlo_pos: Vector3 = anchors["marlo"] as Vector3
	_prop("kitchen_cart", marlo_pos.x - 0.5, marlo_pos.z - 2.6, 0.0, 1.0, 1.2, 0, "gourmand")
	for recipe: String in ["recipe_1", "recipe_2", "recipe_3"]:
		_prop_at("recipe_card", recipe, 0.0, 0.0, "gourmand")
	_prop_at("manhole", "net_hungry")
	_sign("sign.hungry_main", 100.0, 23.6, 0.0, 1.0, "wall")
	_sign("sign.hungry_paste", 108.2, 36.0, 270.0, 0.9, "sign")
	_sign("sign.hungry_closed", 92.5, 37.5, 90.0, 0.8, "sign")
	_sign("sign.net_hungry", 97.0, 43.0, 90.0, 0.7, "sign")


# ---- The Correction Ward (north-east) ------------------------------------------------------------------------------------------------


func _ward() -> void:
	# A walled white ward with its door to the south (the window beside it), beds in a perfect row inside.
	_building("ward", 88.0, 3.0, 1.0, 11.0, 4.5, 0.0, "", 0)
	_building("ward", 88.0, 3.0, 26.0, 1.0, 4.5, 0.0, "", 0)
	_building("ward", 113.0, 3.0, 1.0, 11.0, 4.5, 0.0, "", 0)
	_building("ward", 88.0, 13.0, 10.0, 1.0, 4.5, 0.0, "", 0)
	_building("ward", 104.0, 13.0, 10.0, 1.0, 4.5, 0.0, "", 0)
	for index: int in range(5):
		_prop("bed", 99.0 + float(index) * 3.0, 6.0, 0.0, 1.0, 0.0)
	_prop_at("loudspeaker", "ward_speaker", 0.3)
	_prop("window_booth", 103.0, 12.2, 0.0, 1.0, 0.0)  # beside the door, never in it
	_sign("sign.ward_main", 93.0, 14.6, 0.0, 1.0, "wall")
	_sign("sign.ward_permit", 96.5, 15.6, 0.0, 0.8, "sign")


# ---- The Gate Road (the outside hub) -------------------------------------------------------------------------------------------------------


func _gate_road() -> void:
	# The road from town runs straight at the gate; a rope queue lines its west kerb, the height post stands by the height inspector.
	for index: int in range(6):
		_prop("queue_post", 54.4, 90.0 + float(index) * 2.0, 0.0, 1.0, 0.0)
	_prop("height_post", 48.5, 76.8, 0.0, 1.0, 0.25)
	_sign("sign.out_welcome", 65.6, 110.0, 270.0, 1.1, "banner")
	_sign("sign.out_queue", 53.5, 88.0, 90.0, 0.9, "sign")
	_sign("sign.out_exit_rules", 65.6, 117.5, 270.0, 0.8, "sign")
	for z: float in [92.0, 102.0, 112.0]:
		_prop("lamp_street", 54.6, z, 0.0, 1.0, 0.25, 0, "beefcake")
		_prop("lamp_street", 65.4, z, 0.0, 1.0, 0.25, 0, "beefcake")


# ---- The resistance camp (a small warm refuge, south-west) ---------------------------------------------------------------------------------


func _camp() -> void:
	_prop_at("campfire", "camp", 0.8)
	# the tents, the lean-to and the lantern rope are a stand-in (CapitalLandmarks.camp), their circles in LANDMARK_BLOCKERS
	_prop("crate_stack", 24.0, 112.5, 15.0, 1.0, 1.0)
	_prop("wreck_stack", 5.5, 117.0, 30.0, 1.4, 1.6)
	# The abandoned checkpoint on the west track, between the camp and the rift fields.
	_prop_at("booth", "checkpoint_a", 0.9, 90.0, "", 1)
	_sign("sign.out_abandoned_a", 15.5, 97.5, 90.0, 0.8, "sign")


# ---- The rift fields (north-west, under the wall) and the secret ways in -------------------------------------------------------------------


func _rift_fields() -> void:
	for crystal: Vector2 in RIFT_CRYSTALS:
		_prop("rift_crystals", crystal.x, crystal.y, crystal.x * 7.0, 1.0, 1.6)
	_prop_at("tunnel_hatch_cover", "tunnel_in")
	_prop("toppled_statue", 5.0, 93.0, 80.0, 1.3, 1.6)
	_sign("sign.out_rift", 16.0, 86.5, 90.0, 0.8, "sign")
	_sign("sign.out_tunnel_clue", 7.0, 85.5, 0.0, 0.6, "sign")


# ---- The Old Service Tunnels (north-east: the mini dungeon's mouth in the wall, a stand-in of CapitalLandmarks) ---------------------------------


func _tunnels() -> void:
	_sign("sign.out_old_works", 113.5, 86.0, 270.0, 0.6, "sign")


# ---- The ruined outpost (south-east: the broken watchtower and its fallen walls) -----------------------------------------------------------


func _outpost() -> void:
	_building("ruin", 80.0, 112.5, 6.0, 4.0, 4.0, 5.0, "", 0)
	_building("ruin", 104.0, 113.0, 5.0, 4.0, 3.5, -6.0, "", 1)
	_prop_at("booth", "checkpoint_b", 0.9, 0.0, "", 1)
	_sign("sign.out_abandoned_b", 99.5, 110.0, 0.0, 0.8, "sign")


# ---- The Crease (the resistance hideout, underground) ------------------------------------------------------------------------------------


func _crease() -> void:
	var dz: int = CREASE_Z0 - 100
	var fz: float = float(dz)
	_set_cells(Rect2i(3, 99 + dz, 39, 1), Cell.SOLID)
	_set_cells(Rect2i(3, 121 + dz, 39, 1), Cell.SOLID)
	_set_cells(Rect2i(3, 99 + dz, 1, 23), Cell.SOLID)
	_set_cells(Rect2i(41, 99 + dz, 1, 23), Cell.SOLID)
	for column: float in [10.0, 18.0, 26.0, 34.0]:
		_prop("crease_column", column, 108.0 + fz, 0.0, 1.0, 0.5)
	_prop("crease_table", 14.0, 104.2 + fz, 0.0, 1.0, 1.1)
	_prop("crease_stall", 31.0, 104.2 + fz, 0.0, 1.0, 1.1)
	_prop("tea_urn", 22.0, 102.6 + fz, 0.0, 1.0, 0.7)
	_prop("map_table", 22.0, 110.0 + fz, 0.0, 1.0, 1.0)
	_prop("ladder", 7.0, 112.0 + fz, 0.0, 1.0, 0.0)
	_prop("tunnel_arch", 38.0, 114.0 + fz, 0.0, 1.0, 0.0)
	_prop("crease_crate", 36.0, 108.6 + fz, 0.0, 1.0, 0.8)
	for index: int in range(NETWORK_DESTINATIONS.size()):
		_prop("shaft_door", 9.0 + 5.0 * float(index), 119.0 + fz, 0.0, 1.0, 0.0, index)
	_prop("cot", 10.0, 102.0 + fz, 0.0, 1.0, 0.0)
	_prop("cot", 13.0, 102.0 + fz, 0.0, 1.0, 0.0)
	_sign("sign.crease_main", 22.0, 100.5 + fz, 0.0, 1.2, "banner")
	_sign("sign.crease_wrinkle", 31.0, 102.5 + fz, 0.0, 0.8, "wall")
	_sign("sign.crease_network", 22.0, 119.2 + fz, 0.0, 1.0, "wall")
	_sign("sign.crease_rules", 12.0, 100.8 + fz, 0.0, 0.8, "wall")


# ---- Enemies ---------------------------------------------------------------------------------------------------------------------------------


func _spawn(type: String, x: float, z: float, patrol: float, id: String = "") -> void:
	var entry: Dictionary = {"type": type, "home": Vector3(x, 0.0, z), "patrol": patrol}
	if not id.is_empty():
		entry["id"] = id
	enemy_spawns.append(entry)


## The same thirty enemies as before the layout pass (types, ids and rift guardians unchanged), each moved onto its region's open ground.
func _enemies() -> void:
	# Outside.
	_spawn("officer", 28.0, 96.0, 4.0)
	_spawn("inspector", 88.0, 88.0, 4.0)
	_spawn("tidybot", 60.0, 95.0, 6.0)
	_spawn("wretch", 20.0, 93.5, 3.0, "guard_out_a")
	_spawn("swarm", 32.5, 87.0, 4.0)
	_spawn("officer", 101.0, 117.0, 4.0)
	# The Gate Plaza: only the roving Tidy-Bots, on the boulevards.
	_spawn("tidybot", 44.0, 58.0, 3.5)
	_spawn("tidybot", 76.0, 58.0, 3.5)
	# The Reek.
	_spawn("officer", 19.0, 46.0, 4.0)
	_spawn("wretch", 5.0, 46.5, 2.5, "guard_reek")
	_spawn("tidybot", 28.0, 58.0, 4.0)
	# Grave Row.
	_spawn("inspector", 19.0, 14.0, 4.0)
	_spawn("wretch", 27.0, 19.5, 2.5, "guard_grave")
	_spawn("officer", 8.0, 18.5, 3.0)
	# The Transit Yards.
	_spawn("officer", 89.0, 58.0, 4.0)
	_spawn("tidybot", 113.0, 63.0, 3.0)
	_spawn("swarm", 93.0, 57.0, 2.0)
	_spawn("inspector", 100.0, 52.0, 3.0)
	# The Hungry Quarter.
	_spawn("inspector", 100.0, 28.0, 3.0)
	_spawn("wretch", 104.0, 27.0, 2.0, "guard_hungry")
	_spawn("tidybot", 100.0, 47.0, 3.0)
	# The palace approach, the pockets beside the castle hill, the ring streets and the Ward.
	_spawn("officer", 50.0, 15.0, 4.0)
	_spawn("inspector", 70.0, 15.0, 4.0)
	_spawn("wretch", 78.0, 11.0, 2.0, "guard_approach_e")
	_spawn("swarm", 38.5, 24.0, 3.0)
	_spawn("officer", 38.5, 44.0, 4.0)
	_spawn("tidybot", 81.5, 32.0, 4.0)
	_spawn("inspector", 103.0, 9.5, 3.0)
	_spawn("officer", 107.0, 11.5, 2.0)


## The id of the guardian that must fall before a rift can be sealed.
static func guardian_id(rift_id: String) -> String:
	return CapitalRifts.guardian_id(rift_id)


# ---- Cracks --------------------------------------------------------------------------------------------------------------------------------


func _cracks() -> void:
	# The city is spotless: cracks only round the rifts (the outside's cracked ground is its painted ash and `CapitalWasteland`).
	for rift: Rift in rifts:
		for index: int in range(5):
			var angle: float = TAU * float(index) / 5.0 + rift.radius
			cracks.append({"pos": rift.pos + Vector2(cos(angle), sin(angle)) * (rift.radius + 1.0), "yaw": rad_to_deg(angle), "length": 3.0 + rift.radius})


# ---- Wasteland clusters (outside) ------------------------------------------------------------------------------------------------------------


## The outside's dead trees, ruins and debris gather in a few clusters at the edges, never scattered over the roads or round the people.
func _clusters() -> void:
	for spot: Vector3 in [
		Vector3(4.5, 78.5, 2.4), Vector3(45.0, 99.0, 2.6), Vector3(48.0, 92.0, 2.6), Vector3(4.5, 104.0, 2.2), Vector3(18.5, 118.5, 2.4),
		Vector3(48.0, 117.5, 2.6), Vector3(72.0, 92.0, 2.6), Vector3(80.0, 89.0, 2.4), Vector3(115.0, 96.0, 2.4), Vector3(115.5, 118.0, 2.2),
		Vector3(72.5, 117.5, 2.6), Vector3(80.0, 98.0, 2.2),
	]:
		wasteland_clusters.append(spot)


# ---- Obstacles ---------------------------------------------------------------------------------------------------------------------------------


func _index_obstacles() -> void:
	for prop: Prop in props:
		if prop.radius > 0.0:
			obstacles.append(Vector3(prop.pos.x, prop.pos.z, prop.radius))
	# the stand-ins that are not props (the watchtower) block with their circle
	for blocker: Vector3 in LANDMARK_BLOCKERS:
		var covered: bool = false
		for prop: Prop in props:
			if prop.radius > 0.0 and Vector2(prop.pos.x - blocker.x, prop.pos.z - blocker.y).length() < 0.3:
				covered = true
		if not covered:
			obstacles.append(blocker)
