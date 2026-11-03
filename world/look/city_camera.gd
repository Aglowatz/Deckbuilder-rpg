class_name CityCamera
extends RefCounted
## Overnight Nov 2-3, Part 5: the Capital's own camera (`Settings.city_camera`, "City camera" in Settings; the Dev Menu cycles it). Both new ones
## keep the game's fixed facing (north, the swivel turns it), so the keys and the stick move the hero the same way as everywhere else.
## - Standard: the usual CameraRig angle and zoom (nothing changes).
## - Raised: a steeper ~29 degree pitch from a little farther back, aimed higher, so the roofs, spires and the sky over the castle show.
## - Low: HD-2D, close behind and a little to the right of the hero (over the shoulder) at about head height, looking slightly up so the
##   facades, towers and the castle loom; a softer follow (lag), a tilt-shift that is sharp round the hero and soft near and far, and a
##   pull-in: the lens never goes into a building (it slides in along the line to the hero's head).
## `CapitalScene` sets `in_capital` while it is the current scene; outside it every call returns the Standard values.

const MODE_NAMES: Array[String] = ["Standard", "Raised", "Low"]
const STANDARD: int = 0
const RAISED: int = 1
const LOW: int = 2

## Raised: pitch (degrees), distance as a share of the normal distance, the extra upward aim (degrees).
const RAISED_PITCH: float = 29.0
const RAISED_DISTANCE: float = 1.0  # Nov 3 critic: 10 % closer than the first try (the hero read small)
const RAISED_TILT: float = 9.0  # Nov 3 critic: aimed higher so the skyline and the sky over the castle are in frame
## Low: pitch, distance (metres at Normal zoom), the over-the-shoulder sideways offset, the extra upward aim, the follow rate.
const LOW_PITCH: float = 9.0
const LOW_DISTANCE: float = 4.8
const LOW_SHOULDER: float = 0.8
const LOW_TILT: float = 13.0
const LOW_FOLLOW: float = 2.6
## The pull-in: the lens stops this far short of the first blocked point on the line from the hero's head (metres), sampled every PULL_STEP.
const PULL_MARGIN: float = 0.45
const PULL_STEP: float = 0.25
const HEAD: float = 1.4
## The pull-in never brings the lens closer to the hero's head than this (metres): past it the fader ghosts what is in the way.
const PULL_MIN: float = 1.8

static var in_capital: bool = false


## The mode in effect: the setting inside the Capital, Standard anywhere else.
static func mode() -> int:
	return clampi(Settings.city_camera, 0, 2) if in_capital else STANDARD


static func active() -> bool:
	return mode() != STANDARD


## The camera's offset from the hero for the scene's `offset` (its look pitch and distance), like `CameraRig.shape`.
static func shape(offset: Vector3) -> Vector3:
	var m: int = mode()
	if m == STANDARD:
		return CameraRig.shape(offset)
	var zoom: float = Settings.camera_zoom / Settings.ZOOM_DEFAULT
	var yaw: float = atan2(offset.x, offset.z) + deg_to_rad(CameraRig.swivel)
	var pitch: float = deg_to_rad(RAISED_PITCH if m == RAISED else LOW_PITCH)
	var length: float = (CameraRig.normal_distance() * RAISED_DISTANCE if m == RAISED else LOW_DISTANCE) * zoom
	var back: Vector3 = Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * length
	if m == LOW:
		# over the right shoulder: the lens a little to the right of the line behind the hero (the view's right, turned by the swivel)
		back += Vector3(cos(yaw), 0.0, -sin(yaw)) * LOW_SHOULDER + Vector3(0.0, HEAD * 0.6, 0.0)
	return back


## Degrees added to the look rig's aim above the hero (positive looks up).
static func extra_tilt() -> float:
	match mode():
		RAISED:
			return RAISED_TILT
		LOW:
			return LOW_TILT
	return 0.0


## How fast the camera catches up with its target (the zone camera's lerp rate; Low trails a little).
static func follow_rate() -> float:
	return LOW_FOLLOW if mode() == LOW else 5.0


## Low only: the lens pulled in along the line from the hero's head to `desired` so it stays out of anything `blocked` says is solid
## (a Callable(Vector3) -> bool on ground positions). Other modes return `desired`.
static func pull_in(hero: Vector3, desired: Vector3, blocked: Callable) -> Vector3:
	if mode() != LOW:
		return desired
	var head: Vector3 = hero + Vector3(0.0, HEAD, 0.0)
	var span: float = head.distance_to(desired)
	if span < 0.01:
		return desired
	var steps: int = maxi(1, int(span / PULL_STEP))
	for index: int in range(1, steps + 1):
		var t: float = float(index) / float(steps)
		var p: Vector3 = head.lerp(desired, t)
		if bool(blocked.call(Vector3(p.x, 0.0, p.z))):
			var keep: float = maxf(minf(PULL_MIN, span), t * span - PULL_MARGIN) / span
			return head.lerp(desired, keep)
	return desired


## The look changes of the mode over `values` (a look dictionary already adjusted by CameraRig): FOV and the tilt-shift.
static func adjust(values: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	match mode():
		RAISED:
			result["fov"] = float(values.get("fov", CameraRig.BASE_FOV)) - 2.0
			result["band"] = clampf(float(values.get("band", 0.13)) + 0.03, 0.02, 0.45)
			result["blur_far"] = float(values.get("blur_far", 7.0)) * 0.85
		LOW:
			# HD-2D: a wider lens close in, sharp round the hero (the middle of the frame), soft near and far
			result["fov"] = float(values.get("fov", CameraRig.BASE_FOV)) + 8.0
			result["focus"] = 0.52
			result["band"] = 0.16
			result["blur_far"] = float(values.get("blur_far", 7.0)) * 0.8
			result["blur_near"] = float(values.get("blur_near", 6.0)) * 0.7
	return result
