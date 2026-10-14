class_name CameraRig
extends RefCounted
## The overworld camera of the Art Bible (G-02): a fixed facing direction with a small swivel, three angle presets and three zoom presets (nine combinations).
##
## Scenes keep one `camera_offset` (the look's pitch and distance, see `WorldLookRig.base_offset()`) and place the camera at `hero + CameraRig.shape(camera_offset)`.
## `shape` re-aims that offset at the chosen angle preset, pushes it out to the zoom preset (a character is about 11% of the screen height at Normal), and turns it by the
## swivel. `adjust` returns the tilt-shift, FOV and blur changes of the combination, applied by `WorldLookRig` on top of the zone's look.
##
## The choice (angle, zoom) lives in `Settings` (settings.cfg, not per save); the swivel is transient and eases back to zero when the key is released.

const ANGLE_NAMES: Array[String] = ["Cinematic", "Classic", "Overview"]
const ZOOM_NAMES: Array[String] = ["Close", "Normal", "Far"]
## Camera pitch in degrees per angle preset.
const ANGLE_PITCH: Array[float] = [20.0, 30.0, 45.0]
## Zoom presets as `Settings.camera_zoom` values (Normal is `Settings.ZOOM_DEFAULT`).
const ZOOM_VALUES: Array[float] = [1.2, 1.5, 1.9]
## FOV added per angle preset: a steeper view is flatter (longer lens) so verticals do not splay.
const ANGLE_FOV: Array[float] = [0.0, -2.0, -4.0]
## Tilt-shift per angle: more ground is visible when high, so the blur is gentler and the sharp band wider.
const ANGLE_BLUR: Array[float] = [1.0, 0.9, 0.72]
const ANGLE_BAND: Array[float] = [0.0, 0.02, 0.05]
const ANGLE_FOCUS: Array[float] = [0.0, -0.02, -0.05]
## A high view foreshortens the hero: bring the camera in a little so the hero stays about the same size.
const ANGLE_DISTANCE: Array[float] = [1.0, 0.95, 0.86]
## Per zoom preset: FOV, blur scale, band width.
const ZOOM_FOV: Array[float] = [-3.0, 0.0, 2.0]
const ZOOM_BLUR: Array[float] = [1.2, 1.0, 0.8]
const ZOOM_BAND: Array[float] = [-0.02, 0.0, 0.04]

## The hero is this fraction of the screen height at Normal zoom and Cinematic angle.
const HERO_SCREEN_FRACTION: float = 0.11
const MAX_SWIVEL_DEGREES: float = 18.0
const SWIVEL_SPEED: float = 6.0
const BASE_FOV: float = 44.0

## The swivel in degrees (+ turns the view to the right) and where it is heading.
static var swivel: float = 0.0
static var swivel_target: float = 0.0
## Overworld scenes with a world look rig alive (the camera keys do nothing in menus, battles and the title).
static var active_rigs: int = 0


## The camera-to-hero distance at Normal zoom, Cinematic angle: the hero fills `HERO_SCREEN_FRACTION` of the screen height.
static func normal_distance() -> float:
	var visible_height: float = StorybookScale.HERO_HEIGHT / HERO_SCREEN_FRACTION
	return visible_height / (2.0 * tan(deg_to_rad(BASE_FOV) * 0.5))


static func angle_index() -> int:
	return clampi(Settings.camera_angle, 0, ANGLE_PITCH.size() - 1)


## 0 Close, 1 Normal, 2 Far: the preset nearest to the current zoom (the mouse wheel fine-tunes between them).
static func zoom_index() -> int:
	var best: int = 1
	var best_gap: float = 1e9
	for index: int in range(ZOOM_VALUES.size()):
		var gap: float = absf(ZOOM_VALUES[index] - Settings.camera_zoom)
		if gap < best_gap:
			best_gap = gap
			best = index
	return best


static func combo_name() -> String:
	return "%s / %s" % [ANGLE_NAMES[angle_index()], ZOOM_NAMES[zoom_index()]]


## The camera offset from the hero for a scene's `offset` (its look pitch and distance before the zoom): angle preset, zoom, swivel.
static func shape(offset: Vector3) -> Vector3:
	var base: Vector3 = WorldLookRig.base_offset()
	var flat: float = Vector2(offset.x, offset.z).length()
	var pitch: float = atan2(offset.y, maxf(flat, 0.0001))
	var base_pitch: float = atan2(base.y, maxf(Vector2(base.x, base.z).length(), 0.0001))
	var yaw: float = atan2(offset.x, offset.z) + deg_to_rad(swivel)
	var index: int = angle_index()
	var new_pitch: float = deg_to_rad(ANGLE_PITCH[index]) + (pitch - base_pitch)
	var ratio: float = offset.length() / maxf(base.length(), 0.0001)
	var length: float = normal_distance() * ANGLE_DISTANCE[index] * ratio * (Settings.camera_zoom / Settings.ZOOM_DEFAULT)
	return Vector3(sin(yaw) * cos(new_pitch), sin(new_pitch), cos(yaw) * cos(new_pitch)) * length


## Tilt-shift and FOV for the current combination, applied over `values` (a look dictionary): returns the changed keys.
static func adjust(values: Dictionary) -> Dictionary:
	var a: int = angle_index()
	var z: int = zoom_index()
	var result: Dictionary = {}
	result["fov"] = float(values.get("fov", BASE_FOV)) + ANGLE_FOV[a] + ZOOM_FOV[z]
	result["focus"] = clampf(float(values.get("focus", 0.62)) + ANGLE_FOCUS[a], 0.15, 0.9)
	result["band"] = clampf(float(values.get("band", 0.13)) + ANGLE_BAND[a] + ZOOM_BAND[z], 0.02, 0.45)
	result["blur_far"] = float(values.get("blur_far", 7.0)) * ANGLE_BLUR[a] * ZOOM_BLUR[z]
	result["blur_near"] = float(values.get("blur_near", 6.0)) * ANGLE_BLUR[a] * ZOOM_BLUR[z]
	return result


## Eases the swivel toward its target (called once per frame by the world look rig).
static func tick(delta: float) -> void:
	swivel = lerpf(swivel, swivel_target, 1.0 - exp(-SWIVEL_SPEED * delta))
	if absf(swivel - swivel_target) < 0.02:
		swivel = swivel_target


## Held keys and the right stick set the swivel target: left key -1, right key +1, stick axis -1..1; released it returns to 0.
static func read_input() -> void:
	var amount: float = 0.0
	if InputMap.has_action(&"camera_swivel_left") and Input.is_action_pressed(&"camera_swivel_left"):
		amount -= 1.0
	if InputMap.has_action(&"camera_swivel_right") and Input.is_action_pressed(&"camera_swivel_right"):
		amount += 1.0
	var stick: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	if absf(stick) > 0.25:
		amount += stick
	swivel_target = clampf(amount, -1.0, 1.0) * MAX_SWIVEL_DEGREES


static func reset_swivel() -> void:
	swivel = 0.0
	swivel_target = 0.0
