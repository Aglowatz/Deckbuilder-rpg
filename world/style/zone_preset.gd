class_name ZonePreset
extends RefCounted
## One lighting + environment preset (sky, sun, fog, ambient, grading, bloom, SSAO, outline, ambient particles) from docs/art/style_guide.md, section 11.
## `StylePresets.get_preset(id)` returns one; `StyleRig` turns it into a WorldEnvironment, lights, the outline pass and shader globals.

var id: StringName = &"town"
var title: String = ""

# Sky / background
var use_sky: bool = true
var sky_top: Color = Color("5b8fd0")
var sky_horizon: Color = Color("ffd9a8")
var ground_horizon: Color = Color("e6bd8f")
var ground_bottom: Color = Color("6c5a6a")
var background_color: Color = Color(0.05, 0.05, 0.08)

# Key light (sun / moon) and ambient (the ambient colour IS the coloured shadow)
var sun_color: Color = Color("ffe2b0")
var sun_energy: float = 1.15
var sun_pitch: float = -42.0
var sun_yaw: float = -32.0
var ambient_color: Color = Color("9a8ad0")
var ambient_energy: float = 0.9

# Fog
var fog_color: Color = Color("f4cfa4")
var fog_density: float = 0.006
var fog_sky_affect: float = 0.4
var volumetric_density: float = 0.0
var volumetric_color: Color = Color("ffcf9a")

# Post
var exposure: float = 0.95
var filmic: bool = false
var glow_intensity: float = 0.35
var glow_threshold: float = 0.95
var saturation: float = 1.12
var contrast: float = 1.06
var brightness: float = 1.0
var ssao_radius: float = 1.2
var ssao_intensity: float = 1.5
var outline_color: Color = Color("2a1838")
var outline_strength: float = 0.62

# Toon shader globals
var rim_color: Color = Color("c8d4ff")
var highlight: Vector3 = Vector3(1.05, 1.0, 0.92)
var desaturate: float = 0.0
var wind: float = 1.0
var accent: Color = Color(0.92, 0.14, 0.1)

# Ambient particles around the player: [{"kind": "motes"|"leaves"|"fireflies"|"steam"|"sparkles"|"ash"|"petals", "color": Color, "amount": int}]
var particles: Array[Dictionary] = []

# Optional depth of field (far blur) distances
var dof_distance: float = 34.0
var dof_amount: float = 0.06


func with_id(new_id: StringName, new_title: String) -> ZonePreset:
	id = new_id
	title = new_title
	return self
