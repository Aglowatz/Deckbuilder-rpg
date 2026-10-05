class_name GraphicsQuality
extends RefCounted
## Low / Medium / High: which expensive parts of the look are on (docs/art/style_guide.md). `Settings.graphics_quality` stores the choice,
## `StyleRig` reads it. Medium is the 60 fps target on the development PC.

enum Level { LOW, MEDIUM, HIGH }

const NAMES: Array[String] = ["Low", "Medium", "High"]


static func display_name(level: int) -> String:
	return NAMES[clampi(level, 0, NAMES.size() - 1)]


static func outlines(level: int) -> bool:
	return level >= Level.MEDIUM


static func volumetric_fog(level: int) -> bool:
	return level >= Level.HIGH


static func ssao(level: int) -> bool:
	return level >= Level.HIGH


## 0 = no shadows, 1 = a single soft cascade, 2 = full.
static func shadow_detail(level: int) -> int:
	return clampi(level, 0, 2)


static func glow(level: int) -> bool:
	return level >= Level.MEDIUM


static func ambient_particles_scale(level: int) -> float:
	return [0.35, 0.8, 1.0][clampi(level, 0, 2)]


## Share of decorative foliage kept (grass tufts, bushes, flowers): scatter code keeps an item when `keep_item` says so.
static func foliage_density(level: int) -> float:
	return [0.4, 0.75, 1.0][clampi(level, 0, 2)]


## A stable per-item decision so the same items stay or go every run (no flicker when the setting changes).
static func keep_item(level: int, index: int) -> bool:
	var hash_value: int = (index * 2654435761) & 0xFFFF
	return float(hash_value) / 65535.0 < foliage_density(level)


## Depth of field is optional on top of the level (a settings toggle) and never on Low.
static func dof_allowed(level: int) -> bool:
	return level >= Level.MEDIUM


## Internal 3D resolution (the dev PC is an integrated GPU, so fill rate is the budget): FSR upscales anything below 1.0.
static func render_scale(level: int) -> float:
	return [0.5, 0.62, 1.0][clampi(level, 0, 2)]


## MSAA only on High (it costs about 12 ms at 1600x900 here); Medium uses FXAA + the upscaler, Low uses neither.
static func msaa(level: int) -> int:
	return Viewport.MSAA_2X if level >= Level.HIGH else Viewport.MSAA_DISABLED


static func fxaa(level: int) -> bool:
	return level == Level.MEDIUM


static func apply_to_viewport(viewport: Viewport, level: int) -> void:
	var scale_value: float = render_scale(level)
	viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if scale_value < 0.999 else Viewport.SCALING_3D_MODE_BILINEAR
	viewport.scaling_3d_scale = scale_value
	viewport.msaa_3d = msaa(level) as Viewport.MSAA
	viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if fxaa(level) else Viewport.SCREEN_SPACE_AA_DISABLED


## How many dressing lights (lanterns, fires) stay on at once: the nearest ones to the hero (lights beyond the budget are switched off).
static func light_budget(level: int) -> int:
	return [3, 6, 12][clampi(level, 0, 2)]
