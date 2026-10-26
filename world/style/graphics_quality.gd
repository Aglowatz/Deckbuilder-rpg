class_name GraphicsQuality
extends RefCounted
## Low / Medium / High: which expensive parts of the look are on (docs/art/style_guide.md, docs/art/graphics_tier1.md). `Settings.graphics_quality` stores the
## choice, `StyleRig` reads it. Medium is the 60 fps target on the development PC (an AMD integrated GPU); Low is the Safe Mode base and must never get heavier.
## Graphics Tier 1 (Oct 2026) added the upscaler choice, the FSR sharpness, the shadow filter per level and the knobs every new technique plugs into
## (cloud shadows, sprite normal maps, height fog, light shafts, effect lights). Every knob is a function of the level so the preset table stays in one place.

enum Level { LOW, MEDIUM, HIGH }

const NAMES: Array[String] = ["Low", "Medium", "High"]

## The upscaler setting (`Settings.upscaling_mode`): Auto picks per level (FSR 1 wherever the render scale is below native, plain bilinear at native).
enum Upscaler { AUTO, NATIVE, FSR1, FSR2 }
const UPSCALER_NAMES: Array[String] = ["Auto (per quality level)", "Off (native resolution)", "FSR 1 (spatial, cheapest)", "FSR 2 (temporal, sharper)"]
## The render scale setting (`Settings.render_scale_pct`, 0 = the level's own value).
const RENDER_SCALE_CHOICES: Array[int] = [0, 50, 62, 75, 85, 100]

## Overnight Oct 20 (playtest stability): the High-only passes an Iris Xe crashed on (tester 2: default High crashed before the intro,
## Medium ran) - volumetric fog and SSAO (compute passes) and MSAA - stay off on Intel integrated GPUs even on High (Settings sets this
## from GpuInfo at start). High keeps its full resolution, shadows and outline normals there. Tier 1: FSR 2 and shadow-casting effect lights too.
static var heavy_passes_allowed: bool = true


static func display_name(level: int) -> String:
	return NAMES[clampi(level, 0, NAMES.size() - 1)]


static func outlines(level: int) -> bool:
	return level >= Level.MEDIUM


## The outline also reads the normal buffer for crease lines on High; Medium keeps depth edges only (cheaper: no normal-roughness pass).
static func outline_normals(level: int) -> bool:
	return level >= Level.HIGH and forward_plus()


## Phase 2 (stability): the normal-roughness buffer and FSR exist on Forward+ only (the Compatibility renderer, a last-resort launcher,
## runs the same game without them).
static func forward_plus() -> bool:
	var method: String = RenderingServer.get_current_rendering_method()
	return method.is_empty() or method == "forward_plus"


static func volumetric_fog(level: int) -> bool:
	return level >= Level.HIGH and heavy_passes_allowed


static func ssao(level: int) -> bool:
	return level >= Level.HIGH and heavy_passes_allowed


## 0 = no shadows, 1 = a single soft cascade, 2 = full.
static func shadow_detail(level: int) -> int:
	return clampi(level, 0, 2)


## Tier 1: the sun shadow's blur in shadow-map texels and its PCF filter. The old Medium (blur 2.4, soft low) cost about 2.5 ms of GPU on the
## development iGPU (tools/fps_toggles.gd: blur 0 was +7.6 fps, the hard filter +5); crisp readable shadows suit the painted style better anyway.
static func shadow_blur(level: int) -> float:
	return [1.0, 1.2, 1.8][clampi(level, 0, 2)]


static func shadow_filter(level: int) -> int:
	return [RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW, RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW, RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM][clampi(level, 0, 2)]


static func glow(level: int) -> bool:
	return level >= Level.MEDIUM


## The most ambient particles alive at once (all emitters of a preset together).
static func ambient_particle_budget(level: int) -> int:
	return [120, 260, 400][clampi(level, 0, 2)]


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


## Internal 3D resolution (the dev PC is an integrated GPU, so fill rate is the budget): the upscaler fills in anything below 1.0.
## Tier 1: Medium went from 0.62 to 0.58 (about 1 ms of GPU at 1600x900) with a crisper default sharpness; at 0.5 the paintings go blocky.
static func render_scale(level: int) -> float:
	return [0.5, 0.58, 1.0][clampi(level, 0, 2)]


## The render scale in use: the player's percentage (`Settings.render_scale_pct`) when set, else the level's.
static func effective_render_scale(level: int) -> float:
	if Settings.upscaling_mode == Upscaler.NATIVE:
		return 1.0
	var pct: int = Settings.render_scale_pct
	if pct >= 50 and pct <= 100:
		return float(pct) / 100.0
	return render_scale(level)


## The viewport scaling mode for a level and the player's upscaler choice. FSR 2 (temporal) needs Forward+ and is never chosen for an Intel iGPU
## (`heavy_passes_allowed`); at native scale every upscaler is plain bilinear (nothing to upscale).
static func upscaler_mode(_level: int, choice: int, scale_value: float) -> int:
	if scale_value > 0.999 or not forward_plus():
		return Viewport.SCALING_3D_MODE_BILINEAR
	match choice:
		Upscaler.NATIVE:
			return Viewport.SCALING_3D_MODE_BILINEAR
		Upscaler.FSR2:
			return Viewport.SCALING_3D_MODE_FSR2 if heavy_passes_allowed else Viewport.SCALING_3D_MODE_FSR
	return Viewport.SCALING_3D_MODE_FSR


## FSR sharpening (0 = sharpest, 2 = softest; the engine default is 0.2): the player's "Sharpness" slider (0 soft .. 1 crisp) maps onto it.
## Painted textures and sprites keep their brush edges at the crisp end; the default sits at 0.8 (tuned by screenshots, docs/art/graphics_tier1.md).
static func fsr_sharpness(sharpness_setting: float) -> float:
	return lerpf(0.8, 0.0, clampf(sharpness_setting, 0.0, 1.0))


## MSAA only on High (it costs about 12 ms at 1600x900 here); Medium uses FXAA + the upscaler, Low uses neither. Never with FSR 2 (unsupported together).
static func msaa(level: int) -> int:
	return Viewport.MSAA_2X if level >= Level.HIGH and heavy_passes_allowed and Settings.upscaling_mode != Upscaler.FSR2 else Viewport.MSAA_DISABLED


## FXAA on Medium, and on High where MSAA is not allowed (an Intel iGPU). FSR 2 is temporal anti-aliasing already: no FXAA on top.
static func fxaa(level: int) -> bool:
	return level == Level.MEDIUM or (level >= Level.HIGH and not heavy_passes_allowed)


static func apply_to_viewport(viewport: Viewport, level: int) -> void:
	var scale_value: float = effective_render_scale(level)
	var mode: int = upscaler_mode(level, Settings.upscaling_mode, scale_value)
	viewport.scaling_3d_mode = mode as Viewport.Scaling3DMode
	viewport.scaling_3d_scale = scale_value
	viewport.fsr_sharpness = fsr_sharpness(Settings.sharpness)
	viewport.msaa_3d = msaa(level) as Viewport.MSAA
	var ssaa_ok: bool = RenderingServer.get_current_rendering_method() != "gl_compatibility"
	var temporal: bool = mode == Viewport.SCALING_3D_MODE_FSR2
	viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if fxaa(level) and ssaa_ok and not temporal else Viewport.SCREEN_SPACE_AA_DISABLED


## How many dressing lights (lanterns, fires) stay on at once: the nearest ones to the hero (lights beyond the budget are switched off).
static func light_budget(level: int) -> int:
	return [3, 6, 12][clampi(level, 0, 2)]


## Tier 1: the mesh visibility range of a zone (`StyleRig.cull_distance`) is scaled down on Low, where the CPU side (draw calls) is the limit.
static func cull_scale(level: int) -> float:
	return [0.8, 1.0, 1.0][clampi(level, 0, 2)]


# ---- Tier 1 techniques (docs/art/graphics_tier1.md) -------------------------------------------------------------------------------------------


## Soft cloud shadows sliding over the ground (one unlit noise plane): Medium and up (Low never gets heavier).
static func cloud_shadows(level: int) -> bool:
	return level >= Level.MEDIUM


## Painted character cards shade with a generated normal map (lanterns, the sun and effect lights shape them): Medium and up.
static func sprite_normals(level: int) -> bool:
	return level >= Level.MEDIUM


## Low height fog cards in hollows and fake god-ray cards through canopies: Medium a few, High more (volumetric fog stays High-only, see `volumetric_fog`).
static func haze_cards(level: int) -> int:
	return [0, 6, 10][clampi(level, 0, 2)]


## Short-lived effect lights (card plays, hits, spells, level-ups, chests) alive at once.
static func effect_lights(level: int) -> int:
	return [1, 3, 6][clampi(level, 0, 2)]


## Effect lights cast shadows on High only (never on an Intel iGPU).
static func effect_light_shadows(level: int) -> bool:
	return level >= Level.HIGH and heavy_passes_allowed


# ---- Tier 2 techniques (docs/art/graphics_tier2.md) -------------------------------------------------------------------------------------------


## Water refraction (the bed through the shallows): Medium and up (a screen copy and a depth read).
static func water_refraction(level: int) -> bool:
	return level >= Level.MEDIUM


## How many of the nearest dressing lanterns cast shadows in a night scene (StyleRig gates it on the preset's sun energy): none on Low, one on Medium, two on High.
static func lantern_shadows(level: int) -> int:
	return [0, 1, 2][clampi(level, 0, 2)]


## The default level for this machine: a discrete GPU gets High, an integrated or unknown one Medium, an older Intel iGPU or a software
## renderer Low. Overnight Oct 20: decided from the GPU's name (`GpuInfo`) - on D3D12 the engine reports every iGPU as discrete, so v0.4.0
## put integrated GPUs on High (the Iris Xe tester's crash before the intro, fixed by choosing Medium).
static func recommended() -> int:
	return GpuInfo.recommended_level(GpuInfo.current_kind())


## The preset table (one row per level) for the settings screen and docs/art/graphics_tier1.md: every knob in one place.
static func table() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for level: int in range(NAMES.size()):
		rows.append({
			"name": NAMES[level],
			"render_scale": render_scale(level),
			"msaa": level >= Level.HIGH and heavy_passes_allowed,
			"fxaa": fxaa(level),
			"shadows": shadow_detail(level),
			"shadow_blur": shadow_blur(level),
			"ssao": ssao(level),
			"outlines": outlines(level),
			"outline_normals": outline_normals(level),
			"bloom": glow(level),
			"volumetric_fog": volumetric_fog(level),
			"foliage_density": foliage_density(level),
			"ambient_particles": ambient_particles_scale(level),
			"ambient_particle_budget": ambient_particle_budget(level),
			"light_budget": light_budget(level),
			"decal_budget": GroundDecals.BUDGETS[level],
			"cull_scale": cull_scale(level),
			"cloud_shadows": cloud_shadows(level),
			"sprite_normals": sprite_normals(level),
			"haze_cards": haze_cards(level),
			"effect_lights": effect_lights(level),
			"effect_light_shadows": effect_light_shadows(level),
		})
	return rows
