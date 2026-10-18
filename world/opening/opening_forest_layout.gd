class_name OpeningForestLayout
extends RefCounted
## The Opening Forest as data (docs/art/opening_forest.md, paint-over docs/art/paintovers/opening_forest_reference.png): where the ground is walkable, where
## the path runs, where the camp, the hooded figure, the cave and the secrets are. Pure data and queries, no nodes: `StartingAreaBuilder` builds the scene
## from it and the tests read it directly.
##
## Metres, x east, z south; the camera looks north. A small clearing at the front holds the camp; a worn path winds back and right to the cave mouth in a
## vine-draped cliff, framed by the roots of a giant ancient tree. A spur to the west leads to a mossy nook (optional, a chest). The floor is a union of
## circles and capsules (`floor_sdf` < 0 inside); everything outside it is forest, rock or cliff, so the treeline itself is the wall.

## The clearing: (x, z, radius) circles.
const CLEARING: Array[Vector3] = [Vector3(0.0, 0.0, 5.2), Vector3(2.2, -2.4, 4.0), Vector3(-2.4, 0.6, 3.6)]
## The worn path from the clearing to the cave mouth (centre line) and its half width: 4.4 m wide, more than four hero widths (playbook 20).
const PATH: Array[Vector2] = [Vector2(1.8, -2.5), Vector2(3.6, -6.5), Vector2(6.4, -10.0), Vector2(8.6, -13.6), Vector2(10.0, -17.0), Vector2(10.4, -19.4)]
const PATH_HALF: float = 2.2
## The spur from the clearing to the west nook (3.4 m wide, a side path).
const SPUR: Array[Vector2] = [Vector2(0.6, -3.6), Vector2(-1.4, -6.2), Vector2(-3.0, -7.8)]
const SPUR_HALF: float = 1.7
## Small open places off the main shapes: (x, z, radius).
const POCKETS: Dictionary = {
	"nook": Vector3(-4.2, -8.8, 2.6),
	"apron": Vector3(10.4, -18.0, 3.0),
	"tunnel": Vector3(-6.3, 2.2, 1.2),
	"east": Vector3(6.8, -3.0, 1.3),
	"roots": Vector3(13.9, -18.2, 1.5),
	"station": Vector3(6.4, -17.4, 2.0),
}
## The Path-ology Lab hatch's pocket (south-east, on the camera side): floor only once the Lab is revealed (postgame).
const LAB_POCKET: Vector3 = Vector3(4.3, 4.2, 1.5)

## Walkability destinations (the probe checks each is reached from the spawn).
const SPAWN: Vector3 = Vector3(-0.4, 0.0, 1.0)
const GATE: Vector3 = Vector3(10.4, 0.0, -19.4)
const TUNNEL: Vector3 = Vector3(-6.5, 0.0, 2.4)
const LAB: Vector3 = Vector3(4.3, 0.0, 3.6)
## The three hidden chests (ids as before, gold unchanged): no marker, no glow, the 1.5 m prompt is the only tell (docs/design/secrets.md).
const HIDDEN_CHESTS: Dictionary = {
	"start_west": {"pos": Vector3(-5.0, 0.0, -9.5), "gold": 40},
	"start_east": {"pos": Vector3(7.4, 0.0, -3.1), "gold": 25},
	"start_cave": {"pos": Vector3(14.6, 0.0, -18.6), "gold": 70},
}
## Where things stand that are not walking destinations: the camp pieces, the hooded figure, the cave mouth, the giant tree, the postgame NPCs.
const MARKS: Dictionary = {
	"bedroll": Vector3(-2.3, 0.0, 1.5),
	"pack": Vector3(-3.6, 0.0, 1.0),
	"lantern": Vector3(-1.2, 0.0, 2.0),
	"rescuer": Vector3(-2.6, 0.0, -0.1),
	"cave_mouth": Vector3(10.4, 0.0, -21.6),
	"giant_tree": Vector3(15.2, 0.0, -22.8),
	"station": Vector3(5.9, 0.0, -18.2),
	"rescuer_post": Vector3(-3.2, 0.0, -1.4),
}
## Solid things on the floor: (x, z, radius). The camp's pack and lantern; the dark of the cave mouth (the hero stops at its lip); rim boulders that
## bite into the clearing (`OpeningForestModels` puts a mossy boulder on each).
const CAMP_BLOCKERS: Array[Vector3] = [Vector3(-3.6, 1.0, 0.42), Vector3(-1.2, 2.0, 0.16)]
const MOUTH_BLOCKER: Vector3 = Vector3(10.4, -21.3, 0.9)
const RIM_BLOCKERS: Array[Vector3] = [Vector3(-4.6, -2.6, 0.9), Vector3(5.2, 0.6, 0.8), Vector3(-1.6, 4.3, 0.7)]
## Where the hero may wander to the treeline without talking themselves back: the nook, the secrets.
const QUIET: Array[Vector3] = [Vector3(-4.2, -8.8, 3.4), Vector3(-6.3, 2.2, 2.2), Vector3(6.8, -3.0, 2.2), Vector3(13.9, -18.2, 2.2), Vector3(-2.0, -6.0, 2.0)]

var lab_open: bool = false


func _init(open_lab: bool = false) -> void:
	lab_open = open_lab


## Signed distance (metres) to the edge of the walkable floor: negative inside, positive outside.
func floor_sdf(p: Vector2) -> float:
	var best: float = 1.0e9
	for circle: Vector3 in CLEARING:
		best = minf(best, p.distance_to(Vector2(circle.x, circle.y)) - circle.z)
	best = minf(best, polyline_distance(p, PATH) - PATH_HALF)
	best = minf(best, polyline_distance(p, SPUR) - SPUR_HALF)
	for key: String in POCKETS.keys():
		var pocket: Vector3 = POCKETS[key] as Vector3
		best = minf(best, p.distance_to(Vector2(pocket.x, pocket.y)) - pocket.z)
	if lab_open:
		best = minf(best, p.distance_to(Vector2(LAB_POCKET.x, LAB_POCKET.y)) - LAB_POCKET.z)
	return best


func is_floor(p: Vector2) -> bool:
	return floor_sdf(p) <= 0.0


## Distance from `p` to the path's centre line (the painted dirt and the flagstones follow it).
func path_distance(p: Vector2) -> float:
	return polyline_distance(p, PATH)


static func polyline_distance(p: Vector2, line: Array[Vector2]) -> float:
	var best: float = 1.0e9
	for index: int in range(line.size() - 1):
		best = minf(best, p.distance_to(Geometry2D.get_closest_point_to_segment(p, line[index], line[index + 1])))
	return best


## True when `p` is in front of walkable ground as the camera sees it (the ground within `reach` metres north of it, in a widening wedge, is floor):
## nothing tall may stand there or it would fill the screen between the camera and the hero.
func camera_side(p: Vector2, reach: float = 9.0) -> bool:
	var d: float = 1.0
	while d <= reach:
		for side: float in [-1.0, 0.0, 1.0]:
			if floor_sdf(p + Vector2(side * d * 0.35, -d)) <= 0.0:
				return true
		d += 1.0
	return false


## True when the self-talk at the treeline should stay quiet at `p` (the nook and the secrets are for exploring).
func is_quiet(p: Vector2) -> bool:
	for circle: Vector3 in QUIET:
		if p.distance_to(Vector2(circle.x, circle.y)) < circle.z:
			return true
	return false


## Every walking destination: spawn, gate, tunnel, lab, hidden_chest_<id>.
func anchors() -> Dictionary:
	var result: Dictionary = {"spawn": SPAWN, "gate": GATE, "tunnel": TUNNEL, "lab": LAB}
	for id: String in HIDDEN_CHESTS.keys():
		result["hidden_chest_%s" % id] = (HIDDEN_CHESTS[id] as Dictionary)["pos"]
	return result


## Every solid thing on the floor the layout knows of (the camp, the cave's lip, the rim boulders).
func blockers() -> Array[Vector3]:
	var result: Array[Vector3] = CAMP_BLOCKERS.duplicate()
	result.append(MOUTH_BLOCKER)
	result.append_array(RIM_BLOCKERS)
	return result


func mark(id: String) -> Vector3:
	return MARKS.get(id, Vector3.ZERO) as Vector3


## The walkable floor's xz rectangle, a metre round it (the minimap's extent).
func bounds() -> Rect2:
	# (x, z, radius) of every shape; a lambda would capture the rect by value, so a plain loop
	var shapes: Array[Vector3] = CLEARING.duplicate()
	for p: Vector2 in PATH:
		shapes.append(Vector3(p.x, p.y, PATH_HALF))
	for p: Vector2 in SPUR:
		shapes.append(Vector3(p.x, p.y, SPUR_HALF))
	for key: String in POCKETS.keys():
		shapes.append(POCKETS[key] as Vector3)
	shapes.append(LAB_POCKET)
	var rect: Rect2 = Rect2(Vector2(SPAWN.x, SPAWN.z), Vector2.ZERO)
	for shape: Vector3 in shapes:
		rect = rect.merge(Rect2(Vector2(shape.x - shape.z, shape.y - shape.z), Vector2(shape.z, shape.z) * 2.0))
	return rect.grow(1.0)
