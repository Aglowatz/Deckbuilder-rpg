class_name SignFacing
extends RefCounted
## Overnight Nov 19 (Part 8.5): every sign board, signpost and plaque faces the default camera (which looks north, from +z), so its icon reads.
## Many stood edge-on (yaw 90 / 270) or turned away. Free-standing boards turn to face the camera; a plaque hung on a wall that faces sideways
## or away comes off the wall and stands on its own posts just in front of it, facing the camera. Used by the zone builders; probed by
## tests/world/test_sign_facing_nov19.gd.

## The most a sign may turn away from the camera and still read (degrees).
const LIMIT: float = 30.0
## How far a plaque taken off a sideways wall stands out from it (metres).
const OFF_WALL: float = 0.9


## The angle between a sign's face and the camera (0 = straight at it), from the node's yaw in degrees (its board faces local +z).
static func angle_to_camera(node_yaw_degrees: float) -> float:
	return absf(wrapf(node_yaw_degrees, -180.0, 180.0))


## The world direction a board faces for a node yaw (degrees).
static func face_direction(node_yaw_degrees: float) -> Vector3:
	var rad: float = deg_to_rad(node_yaw_degrees)
	return Vector3(sin(rad), 0.0, cos(rad))


## For a layout sign whose node turns by (yaw + offset): {"yaw", "style", "pos"} after the rule. `hung` = it is flat on a wall.
static func fix(pos: Vector3, yaw: float, style: String, offset: float, hung: bool) -> Dictionary:
	var node_yaw: float = yaw + offset
	if hung and angle_to_camera(node_yaw) <= LIMIT:
		return {"yaw": yaw, "style": style, "pos": pos, "moved": false}
	var new_pos: Vector3 = pos
	var new_style: String = style
	var moved: bool = false
	if hung:
		new_pos = pos + face_direction(node_yaw) * OFF_WALL
		new_style = "sign"
		moved = true
	return {"yaw": -offset, "style": new_style, "pos": new_pos, "moved": moved}
