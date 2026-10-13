class_name PropClusters
extends RefCounted
## Reusable little vignettes (vertical slice, Part B) so an area can be dressed quickly and naturally: a doorstep with pots and a flower box, a stack of crates and barrels by a wall,
## a stall with sacks and a cart, a garden bed edged in stone, a bench nook with a lantern, a well corner, a fenced garden, a banner lamp. Local frame: origin on the ground,
## the wall or back is -z and the open side (where the hero walks) +z. Each cluster root carries meta: "circles" (Array of Vector3 x, z, r in the local frame, solid pieces only),
## "lights" are on the member props (KitLights finds them), "length" (metres along x) and "depth" (metres along z).

const NAMES: Array[String] = ["doorstep", "crates", "market_set", "garden_bed", "bench_nook", "well_corner", "fence_garden", "banner_lamp", "barrel_pair"]


static func make(cluster_name: String, seed_value: int = 0) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Cluster_%s" % cluster_name
	var circles: Array[Vector3] = []
	var clumps: Array[Dictionary] = []
	var length: float = 3.0
	var depth: float = 1.5
	match cluster_name:
		"doorstep":
			_add(root, PropKit.flowerpot(seed_value), Vector3(-1.55, 0, 0.7), 0.0, circles)
			_add(root, PropKit.flowerpot(seed_value + 1), Vector3(1.6, 0, 0.55), 0.0, circles)
			_add(root, PropKit.planter(1.4, seed_value), Vector3(2.9, 0, 0.2), 0.0, circles)
			_add(root, PropKit.barrel(seed_value), Vector3(-2.6, 0, 0.1), 0.0, circles)
			_add(root, PropKit.crate(0.66, seed_value), Vector3(-3.3, 0, 0.55), 22.0, circles)
			clumps.append({"pos": Vector3(-2.2, 0, 1.0), "radius": 0.7, "count": 7, "cells": [2, 0, 5]})
			clumps.append({"pos": Vector3(3.5, 0, 1.0), "radius": 0.8, "count": 8, "cells": [2, 3, 0]})
			length = 7.0
			depth = 1.6
		"crates":
			_add(root, PropKit.crate(1.0, seed_value), Vector3(0.0, 0, 0.0), 6.0, circles)
			var top: Node3D = PropKit.crate(0.66, seed_value + 1)
			_add(root, top, Vector3(0.05, 0.9, -0.05), 28.0, circles, false)
			_add(root, PropKit.crate(0.66, seed_value + 2), Vector3(1.05, 0, 0.25), -14.0, circles)
			_add(root, PropKit.barrel(seed_value), Vector3(1.95, 0, 0.0), 0.0, circles)
			_add(root, PropKit.barrel(seed_value + 1), Vector3(2.75, 0, 0.35), 0.0, circles)
			_add(root, PropKit.sack(seed_value), Vector3(-1.0, 0, 0.4), 20.0, circles)
			_add(root, PropKit.sack(seed_value + 1), Vector3(-1.5, 0, 0.0), -30.0, circles)
			clumps.append({"pos": Vector3(3.5, 0, 0.6), "radius": 0.6, "count": 6, "cells": [0, 1, 2]})
			length = 5.0
			depth = 1.2
		"market_set":
			_add(root, PropKit.stall(seed_value), Vector3(0, 0, 0), 0.0, circles)
			_add(root, PropKit.cart(seed_value), Vector3(4.2, 0, 0.0), -90.0 + 15.0, circles)
			_add(root, PropKit.barrel(seed_value), Vector3(-2.4, 0, -0.4), 0.0, circles)
			_add(root, PropKit.crate(0.66, seed_value), Vector3(-2.9, 0, 0.5), 15.0, circles)
			_add(root, PropKit.sack(seed_value + 2), Vector3(2.2, 0, 1.3), 40.0, circles)
			clumps.append({"pos": Vector3(-3.4, 0, 1.2), "radius": 0.8, "count": 6, "cells": [0, 1, 2]})
			length = 8.0
			depth = 2.6
		"garden_bed":
			_add(root, PropKit.stone_wall(4.2), Vector3(0, 0, -0.9), 0.0, circles, false)
			_add(root, PropKit.stone_wall(2.0), Vector3(-2.2, 0, 0.0), 90.0, circles, false)
			_add(root, PropKit.stone_wall(2.0), Vector3(2.2, 0, 0.0), 90.0, circles, false)
			clumps.append({"pos": Vector3(-1.1, 0, -0.2), "radius": 0.9, "count": 14, "cells": [2, 3, 0, 2]})
			clumps.append({"pos": Vector3(1.1, 0, -0.2), "radius": 0.9, "count": 14, "cells": [2, 0, 4, 3]})
			clumps.append({"pos": Vector3(0.0, 0, 0.5), "radius": 0.8, "count": 10, "cells": [0, 2, 1]})
			circles.append(Vector3(0, -0.9, 1.0))
			length = 4.6
			depth = 2.0
		"bench_nook":
			_add(root, PropKit.bench(), Vector3(0, 0, 0), 0.0, circles, false)
			circles.append(Vector3(0, 0, 0.55))
			_add(root, PropKit.lantern_post(), Vector3(1.6, 0, -0.1), 0.0, circles)
			_add(root, PropKit.planter(1.2, seed_value), Vector3(-1.7, 0, 0.0), 0.0, circles, false)
			clumps.append({"pos": Vector3(-0.2, 0, -0.7), "radius": 0.9, "count": 9, "cells": [2, 3, 5]})
			length = 4.4
			depth = 1.4
		"well_corner":
			_add(root, PropKit.well(), Vector3(0, 0, 0), 0.0, circles)
			_add(root, PropKit.barrel(seed_value), Vector3(1.8, 0, 0.9), 0.0, circles)
			_add(root, PropKit.crate(0.66, seed_value), Vector3(-1.9, 0, 0.9), 12.0, circles)
			_add(root, PropKit.sack(seed_value), Vector3(-1.5, 0, 1.6), 40.0, circles)
			clumps.append({"pos": Vector3(2.0, 0, -0.9), "radius": 0.9, "count": 8, "cells": [0, 2, 5]})
			length = 4.2
			depth = 2.2
		"fence_garden":
			_add(root, PropKit.fence(4.2, true), Vector3(0, 0, 0), 0.0, circles, false)
			_add(root, PropKit.fence(1.6, true), Vector3(-2.1, 0, -0.8), 90.0, circles, false)
			clumps.append({"pos": Vector3(-0.8, 0, -0.5), "radius": 0.9, "count": 12, "cells": [2, 3, 0]})
			clumps.append({"pos": Vector3(1.0, 0, -0.45), "radius": 0.8, "count": 10, "cells": [2, 4, 0]})
			clumps.append({"pos": Vector3(0.0, 0, 0.3), "radius": 1.2, "count": 7, "cells": [0, 1]})
			circles.append(Vector3(-1.4, 0, 0.3))
			circles.append(Vector3(0.0, 0, 0.3))
			circles.append(Vector3(1.4, 0, 0.3))
			length = 4.4
			depth = 1.8
		"banner_lamp":
			_add(root, PropKit.lantern_post(true), Vector3(0, 0, 0), 0.0, circles)
			clumps.append({"pos": Vector3(0.2, 0, 0.35), "radius": 0.7, "count": 7, "cells": [2, 0, 3]})
			length = 1.6
			depth = 1.2
		"barrel_pair":
			_add(root, PropKit.barrel(seed_value), Vector3(0, 0, 0), 0.0, circles)
			_add(root, PropKit.barrel(seed_value + 1), Vector3(0.9, 0, 0.3), 0.0, circles)
			_add(root, PropKit.crate(0.66, seed_value), Vector3(-0.8, 0, 0.35), 18.0, circles)
			length = 2.6
			depth = 1.0
		_:
			root.free()
			return null
	if not clumps.is_empty():
		KitFoliage.clumps(root, clumps, seed_value + 11)
	root.set_meta("circles", circles)
	root.set_meta("length", length)
	root.set_meta("depth", depth)
	return root


static func _add(root: Node3D, prop: Node3D, pos: Vector3, yaw: float, circles: Array[Vector3], solid: bool = true) -> void:
	if prop == null:
		return
	root.add_child(prop)
	prop.position = pos
	prop.rotation_degrees.y += yaw
	var radius: float = float(prop.get_meta("radius", 0.0))
	if solid and radius > 0.0 and pos.y < 0.5:
		circles.append(Vector3(pos.x, pos.z, radius))
