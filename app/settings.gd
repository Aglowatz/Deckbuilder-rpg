extends Node
## Player settings (volumes, fullscreen), persisted to user://settings.cfg.

const PATH: String = "user://settings.cfg"
const BUS_MUSIC: StringName = &"Music"
const BUS_SFX: StringName = &"SFX"

## Emitted when the minimap setting changes (a live HUD hides or shows its minimap at once).
signal minimap_toggled(visible_now: bool)
## Emitted when the graphics quality or depth-of-field setting changes (live `StyleRig`s re-apply at once).
signal graphics_changed

var master_volume: float = 0.8
var music_volume: float = 0.6
var sfx_volume: float = 0.8
var fullscreen: bool = false
## Whether the HUD minimap is drawn (the M full map always works).
var show_minimap: bool = true
## Low / Medium / High (`GraphicsQuality.Level`): outlines, volumetrics, SSAO, shadows, DOF, foliage density.
var graphics_quality: int = GraphicsQuality.Level.MEDIUM
## Optional subtle depth of field (never on Low).
var depth_of_field: bool = false
## How far the 3D camera sits from the hero, as a multiple of each area's base offset (mouse wheel changes it; remembered).
const ZOOM_MIN: float = 1.0
const ZOOM_MAX: float = 2.3
const ZOOM_DEFAULT: float = 1.5
var camera_zoom: float = ZOOM_DEFAULT


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(BUS_MUSIC)
	_ensure_bus(BUS_SFX)
	load_settings()
	apply()


func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, &"Master")


func apply() -> void:
	_set_bus(&"Master", master_volume)
	_set_bus(BUS_MUSIC, music_volume)
	_set_bus(BUS_SFX, sfx_volume)
	# Screenshot/test runs keep their own window mode.
	if DisplayServer.get_name() == "headless":
		return
	var mode: DisplayServer.WindowMode = (
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)


func _set_bus(bus_name: StringName, linear: float) -> void:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))
	AudioServer.set_bus_mute(index, linear <= 0.001)


func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "minimap", show_minimap)
	config.set_value("video", "quality", graphics_quality)
	config.set_value("video", "dof", depth_of_field)
	config.set_value("video", "zoom", camera_zoom)
	config.save(PATH)


func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(PATH) != OK:
		graphics_quality = GraphicsQuality.recommended()
		return
	master_volume = float(config.get_value("audio", "master", master_volume))
	music_volume = float(config.get_value("audio", "music", music_volume))
	sfx_volume = float(config.get_value("audio", "sfx", sfx_volume))
	fullscreen = bool(config.get_value("video", "fullscreen", fullscreen))
	show_minimap = bool(config.get_value("video", "minimap", show_minimap))
	graphics_quality = clampi(int(config.get_value("video", "quality", GraphicsQuality.recommended())), 0, 2)
	depth_of_field = bool(config.get_value("video", "dof", depth_of_field))
	camera_zoom = clampf(float(config.get_value("video", "zoom", camera_zoom)), ZOOM_MIN, ZOOM_MAX)


## Mouse wheel zoom in every 3D scene (UI that scrolls swallows the wheel first, so lists still scroll).
func _unhandled_input(event: InputEvent) -> void:
	var wheel: InputEventMouseButton = event as InputEventMouseButton
	if wheel == null or not wheel.pressed:
		return
	if wheel.button_index == MOUSE_BUTTON_WHEEL_UP:
		set_camera_zoom(camera_zoom - 0.1)
	elif wheel.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		set_camera_zoom(camera_zoom + 0.1)


func set_camera_zoom(value: float) -> void:
	var clamped: float = clampf(value, ZOOM_MIN, ZOOM_MAX)
	if is_equal_approx(clamped, camera_zoom):
		return
	camera_zoom = clamped
	_zoom_dirty = 0.6


var _zoom_dirty: float = 0.0


func _process(delta: float) -> void:
	if _zoom_dirty > 0.0:
		_zoom_dirty -= delta
		if _zoom_dirty <= 0.0:
			save_settings()
