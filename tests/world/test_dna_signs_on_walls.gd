extends GutTest
## Fixes Oct 27, Part 3: every D.N.A. sign, poster and memo hangs flat on a wall (or is pinned to a cubicle partition) at a readable height, facing into
## the floor in front of it, one per wall face - none stands in a walkway or hangs over a doorway - and its "Read the sign" spot is reachable.

var layout: DnaLayout


func before_all() -> void:
	layout = DnaLayout.new()
	layout.build()


func test_every_sign_is_on_a_wall_or_a_partition() -> void:
	assert_gt(layout.signs.size(), 15)
	for sign: DnaLayout.Sign in layout.signs:
		if sign.face_step == Vector2i.ZERO:
			assert_eq(sign.style, "memo", "%s: only memos stay pinned on a partition" % sign.key)
			assert_true(layout._on_partition(sign.pos), "%s is on a partition" % sign.key)
			continue
		var wall: Vector2i = sign.face_cell + sign.face_step
		assert_true(layout.is_floor(sign.face_cell.x, sign.face_cell.y), "%s: floor in front" % sign.key)
		assert_true(layout._mountable_wall(wall), "%s: a full-height wall behind it" % sign.key)
		var face: Vector2 = Vector2(sign.face_cell.x + 0.5 + sign.face_step.x * 0.5, sign.face_cell.y + 0.5 + sign.face_step.y * 0.5)
		var normal: Vector2 = -Vector2(sign.face_step)
		var p: Vector2 = Vector2(sign.pos.x, sign.pos.z)
		assert_almost_eq((p - face).dot(normal), DnaLayout.SIGN_OFF_WALL, 0.01, "%s: flat on the wall" % sign.key)
		assert_lt(absf((p - face).dot(Vector2(normal.y, -normal.x))), 0.5 - 0.375 * sign.size + 0.01, "%s: within its wall face" % sign.key)
		var facing: Vector2 = Vector2(sin(deg_to_rad(sign.yaw)), cos(deg_to_rad(sign.yaw)))
		assert_gt(facing.dot(normal), 0.99, "%s: faces into the room" % sign.key)
		var half: float = 0.375 * sign.size
		assert_between(sign.pos.y - half, 0.9, 1.6, "%s: its bottom at a readable height" % sign.key)
		assert_lt(sign.pos.y + half + 0.18, 2.45, "%s: hangers and all, under the wall lamps' height" % sign.key)
		assert_ne(posmod(wall.x + wall.y, DnaInterior.SCONCE_STEP), 2, "%s: not on a sconce's face" % sign.key)


func test_one_sign_per_wall_face() -> void:
	var seen: Dictionary = {}
	for sign: DnaLayout.Sign in layout.signs:
		if sign.face_step == Vector2i.ZERO:
			continue
		var key: Vector4i = Vector4i(sign.face_cell.x, sign.face_cell.y, sign.face_step.x, sign.face_step.y)
		assert_false(seen.has(key), "%s shares a face with %s" % [sign.key, seen.get(key, "")])
		seen[key] = sign.key


func test_no_sign_stands_in_the_walkway_and_each_can_be_read() -> void:
	for sign: DnaLayout.Sign in layout.signs:
		assert_true(_reachable(sign.pos), "%s: a hero can stand within reading reach" % sign.key)
		if sign.face_step == Vector2i.ZERO:
			continue
		var p: Vector2 = Vector2(sign.pos.x, sign.pos.z)
		var facing: Vector2 = Vector2(sin(deg_to_rad(sign.yaw)), cos(deg_to_rad(sign.yaw)))
		# a hero can stand in front of it (the spot's 1.4 m reach), and nothing hangs out into the floor: 0.3 m in front is open floor
		var front: Vector2 = p + facing * 0.6
		assert_true(layout.is_floor(int(floor(front.x)), int(floor(front.y))), "%s: open floor in front" % sign.key)
		assert_false(layout._front_blocked(front), "%s: nothing solid in front of it" % sign.key)


## Open floor (no blocker within a hero's body) within 1.2 m of `pos` (the sign spot reaches 1.4 m).
func _reachable(pos: Vector3) -> bool:
	for step: int in range(24):
		var angle: float = TAU * float(step) / 24.0
		for reach: float in [0.6, 0.9, 1.2]:
			var p: Vector2 = Vector2(pos.x, pos.z) + Vector2(cos(angle), sin(angle)) * reach
			if not layout.is_floor(int(floor(p.x)), int(floor(p.y))):
				continue
			var clear: bool = true
			for prop: DnaLayout.Prop in layout.props:
				if prop.radius > 0.0 and Vector2(prop.pos.x, prop.pos.z).distance_to(p) < prop.radius + StorybookScale.BODY_RADIUS:
					clear = false
					break
			if clear:
				return true
	return false
