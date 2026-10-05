class_name StylePresets
extends RefCounted
## The per-zone presets (docs/art/style_guide.md, section 11). Values are starting points tuned by screenshots.

const TOWN: StringName = &"town"
const START: StringName = &"start"
const DNA: StringName = &"dna"
const GAINLANDS: StringName = &"gainlands"
const BUFFET: StringName = &"buffet"
const HEAP: StringName = &"heap"
const CAPITAL_FACADE: StringName = &"capital_facade"
const CAPITAL_OUTSKIRTS: StringName = &"capital_outskirts"
const CAPITAL_DARK: StringName = &"capital_dark"
const CAPITAL_FREED: StringName = &"capital_freed"
const BATTLE: StringName = &"battle"
const DUNGEON: StringName = &"dungeon"
const ARENA: StringName = &"arena"


static func ids() -> Array[StringName]:
	return [TOWN, START, DNA, GAINLANDS, BUFFET, HEAP, CAPITAL_FACADE, CAPITAL_OUTSKIRTS, CAPITAL_DARK, CAPITAL_FREED, BATTLE, DUNGEON, ARENA]


## The preset for a zone id (`DnaZone.ID` etc.) - the Capital resolves its own variant, see `capital`.
static func for_zone(zone_id: String) -> StringName:
	match zone_id:
		"necrocrat":
			return DNA
		"beefcake":
			return GAINLANDS
		"gourmand":
			return BUFFET
		"refusemancer":
			return HEAP
		"final":
			return CAPITAL_OUTSKIRTS
	return TOWN


static func capital(dark: bool, freed: bool) -> StringName:
	if freed:
		return CAPITAL_FREED
	return CAPITAL_DARK if dark else CAPITAL_OUTSKIRTS


static func get_preset(id: StringName) -> ZonePreset:
	var p: ZonePreset = ZonePreset.new()
	match id:
		TOWN:
			p.with_id(id, "Main town: warm, cozy, golden")
			p.sky_top = Color("5f8fd8")
			p.sky_horizon = Color("ffd7a0")
			p.ground_horizon = Color("f0c690")
			p.sun_color = Color("ffdca0")
			p.sun_energy = 1.05
			p.sun_pitch = -30.0
			p.sun_yaw = -35.0
			p.ambient_color = Color("8070c8")
			p.ambient_energy = 0.4
			p.fog_color = Color("f6c9a0")
			p.fog_density = 0.0022
			p.volumetric_density = 0.012
			p.volumetric_color = Color("ffc98a")
			p.saturation = 1.06
			p.contrast = 1.1
			p.glow_intensity = 0.1
			p.glow_threshold = 1.15
			p.exposure = 0.82
			p.rim_color = Color("ffe0b8")
			p.particles = [{"kind": "motes", "color": Color(1.0, 0.86, 0.55, 0.8), "amount": 60}, {"kind": "leaves", "color": Color("d98a3a"), "amount": 14}]
		START:
			p.with_id(id, "Starting area: soft, mysterious")
			p.sky_top = Color("2a2e6a")
			p.sky_horizon = Color("a98ac4")
			p.ground_horizon = Color("6c5a96")
			p.ground_bottom = Color("2a2048")
			p.sun_color = Color("d6d0ff")
			p.sun_energy = 0.8
			p.sun_pitch = -48.0
			p.ambient_color = Color("6c6ac0")
			p.ambient_energy = 1.0
			p.fog_color = Color("7a70b8")
			p.fog_density = 0.016
			p.volumetric_density = 0.03
			p.volumetric_color = Color("9a90e0")
			p.saturation = 1.1
			p.glow_intensity = 0.6
			p.glow_threshold = 0.85
			p.rim_color = Color("a8c8ff")
			p.highlight = Vector3(0.98, 1.0, 1.1)
			p.particles = [{"kind": "fireflies", "color": Color(0.7, 1.0, 0.85, 1.0), "amount": 30}, {"kind": "motes", "color": Color(0.8, 0.8, 1.0, 0.6), "amount": 40}]
		DNA:
			p.with_id(id, "D.N.A.: near-monochrome, red accent")
			p.use_sky = false
			p.background_color = Color(0.04, 0.045, 0.05)
			p.sun_color = Color("dfe6ee")
			p.sun_energy = 0.9
			p.sun_pitch = -58.0
			p.ambient_color = Color("5a6470")
			p.ambient_energy = 1.0
			p.fog_color = Color("333a42")
			p.fog_density = 0.02
			p.fog_sky_affect = 1.0
			p.volumetric_density = 0.02
			p.volumetric_color = Color("8a96a2")
			p.exposure = 0.95
			p.saturation = 0.92
			p.contrast = 1.14
			p.glow_threshold = 0.9
			p.outline_color = Color("0a0c10")
			p.outline_strength = 0.7
			p.rim_color = Color("b8c4d0")
			p.highlight = Vector3(1.0, 1.0, 1.02)
			p.desaturate = 0.93
			p.wind = 0.2
			p.accent = Color("e0221a")
			p.particles = [{"kind": "motes", "color": Color(0.8, 0.85, 0.9, 0.6), "amount": 40}, {"kind": "paper", "color": Color(0.85, 0.85, 0.85, 1.0), "amount": 8}]
		GAINLANDS:
			p.with_id(id, "Gainlands: bright, sunny, big skies")
			p.sky_top = Color("2f86e8")
			p.sky_horizon = Color("c8ecff")
			p.ground_horizon = Color("d8f0ff")
			p.ground_bottom = Color("6aa0d8")
			p.sun_color = Color("fff3d0")
			p.sun_energy = 1.5
			p.sun_pitch = -52.0
			p.sun_yaw = -25.0
			p.ambient_color = Color("78b8ff")
			p.ambient_energy = 1.0
			p.fog_color = Color("cfeaff")
			p.fog_density = 0.0028
			p.fog_sky_affect = 0.3
			p.saturation = 1.22
			p.contrast = 1.05
			p.glow_intensity = 0.3
			p.outline_color = Color("1c2a5a")
			p.outline_strength = 0.55
			p.rim_color = Color("fff0c0")
			p.highlight = Vector3(1.06, 1.03, 0.92)
			p.wind = 1.5
			p.particles = [{"kind": "petals", "color": Color("ff9ac8"), "amount": 24}, {"kind": "sparkles", "color": Color(1.0, 1.0, 0.8, 1.0), "amount": 20}]
		BUFFET:
			p.with_id(id, "Endless Buffet: warm, saturated, appetizing")
			p.sky_top = Color("d86a4a")
			p.sky_horizon = Color("ffc070")
			p.ground_horizon = Color("f0a860")
			p.ground_bottom = Color("8a4a3a")
			p.sun_color = Color("ffc878")
			p.sun_energy = 1.3
			p.sun_pitch = -40.0
			p.sun_yaw = -40.0
			p.ambient_color = Color("e888a8")
			p.ambient_energy = 0.95
			p.fog_color = Color("ffd8a0")
			p.fog_density = 0.005
			p.volumetric_density = 0.015
			p.volumetric_color = Color("ffd29a")
			p.saturation = 1.28
			p.glow_intensity = 0.45
			p.outline_color = Color("5a1a2a")
			p.rim_color = Color("ffe8b0")
			p.highlight = Vector3(1.08, 1.02, 0.9)
			p.particles = [{"kind": "steam", "color": Color(1.0, 0.95, 0.85, 0.5), "amount": 20}, {"kind": "sparkles", "color": Color(1.0, 0.9, 0.5, 1.0), "amount": 18}]
		HEAP:
			p.with_id(id, "Verdant Dump: earthy, rust, golden hour")
			p.sky_top = Color("6a8cc0")
			p.sky_horizon = Color("ffc47a")
			p.ground_horizon = Color("e8b070")
			p.ground_bottom = Color("8a6a3a")
			p.sun_color = Color("ffc884")
			p.sun_energy = 1.3
			p.sun_pitch = -22.0
			p.sun_yaw = -50.0
			p.ambient_color = Color("8a8a58")
			p.ambient_energy = 1.0
			p.fog_color = Color("f0c890")
			p.fog_density = 0.007
			p.volumetric_density = 0.02
			p.volumetric_color = Color("ffc47a")
			p.saturation = 1.2
			p.glow_intensity = 0.4
			p.outline_color = Color("3a2a14")
			p.rim_color = Color("ffd08a")
			p.highlight = Vector3(1.08, 1.0, 0.88)
			p.particles = [{"kind": "motes", "color": Color(1.0, 0.8, 0.45, 0.8), "amount": 50}, {"kind": "fireflies", "color": Color(0.8, 1.0, 0.4, 1.0), "amount": 16}]
		CAPITAL_FACADE:
			p.with_id(id, "Capital facade: unnaturally clean pastel")
			p.sky_top = Color("a8d8f0")
			p.sky_horizon = Color("ffe8f0")
			p.ground_horizon = Color("f8e8f0")
			p.ground_bottom = Color("d8c8e0")
			p.sun_color = Color("fff0f4")
			p.sun_energy = 1.35
			p.sun_pitch = -55.0
			p.ambient_color = Color("b8f0d8")
			p.ambient_energy = 1.1
			p.fog_color = Color("fff0f6")
			p.fog_density = 0.0015
			p.saturation = 0.9
			p.brightness = 1.05
			p.outline_color = Color("8a6a9a")
			p.outline_strength = 0.4
			p.rim_color = Color("ffffff")
			p.particles = [{"kind": "sparkles", "color": Color(1.0, 0.95, 1.0, 1.0), "amount": 30}]
		CAPITAL_OUTSKIRTS:
			p.with_id(id, "Capital outskirts: desaturated, unsettling")
			p.sky_top = Color("3c3a5c")
			p.sky_horizon = Color("a28aa8")
			p.ground_horizon = Color("807088")
			p.ground_bottom = Color("2a2430")
			p.sun_color = Color("c0b0e0")
			p.sun_energy = 0.8
			p.sun_pitch = -52.0
			p.ambient_color = Color("8a7ab0")
			p.ambient_energy = 0.9
			p.fog_color = Color("7a6a90")
			p.fog_density = 0.011
			p.volumetric_density = 0.025
			p.volumetric_color = Color("8a70b0")
			p.saturation = 0.78
			p.contrast = 1.1
			p.glow_intensity = 0.55
			p.outline_color = Color("120c1c")
			p.outline_strength = 0.7
			p.rim_color = Color("e060ff")
			p.desaturate = 0.45
			p.wind = 0.6
			p.accent = Color("ff3aa8")
			p.particles = [{"kind": "ash", "color": Color(0.75, 0.7, 0.8, 0.7), "amount": 50}, {"kind": "sparkles", "color": Color("ff50d0"), "amount": 14}]
		CAPITAL_DARK:
			p = get_preset(CAPITAL_OUTSKIRTS)
			p.with_id(id, "Capital outskirts, service down: dark")
			p.sky_top = Color("14132a")
			p.sky_horizon = Color("3a2f50")
			p.ground_horizon = Color("2a2438")
			p.sun_energy = 0.45
			p.ambient_color = Color("5a5478")
			p.ambient_energy = 0.8
			p.fog_color = Color("2a2438")
			p.fog_density = 0.014
		CAPITAL_FREED:
			p.with_id(id, "Capital freed: bright and warm")
			p.sky_top = Color("6fa8e0")
			p.sky_horizon = Color("ffe0a8")
			p.ground_horizon = Color("e8d4a8")
			p.ground_bottom = Color("9a8a6a")
			p.sun_color = Color("ffe6b0")
			p.sun_energy = 1.3
			p.ambient_color = Color("c8b8f0")
			p.fog_color = Color("f0e0c0")
			p.fog_density = 0.002
			p.saturation = 1.18
			p.particles = [{"kind": "sparkles", "color": Color(1.0, 0.95, 0.7, 1.0), "amount": 30}, {"kind": "petals", "color": Color("ffb0d0"), "amount": 18}]
		BATTLE:
			p.with_id(id, "Battle backdrop: warm key, rich shadows")
			p.sun_energy = 1.1
			p.ambient_color = Color("8a78c8")
			p.fog_density = 0.01
			p.volumetric_density = 0.015
			p.particles = [{"kind": "motes", "color": Color(1.0, 0.85, 0.6, 0.7), "amount": 40}]
		DUNGEON:
			p.with_id(id, "Dungeon map diorama: cool cave with warm lamps")
			p.sky_top = Color("1b1230")
			p.sky_horizon = Color("5a3550")
			p.ground_horizon = Color("4a2c48")
			p.ground_bottom = Color("1a1024")
			p.sun_color = Color("c8a0ff")
			p.sun_energy = 0.75
			p.ambient_color = Color("6a5aa8")
			p.ambient_energy = 0.9
			p.fog_color = Color("3c2544")
			p.fog_density = 0.012
			p.volumetric_density = 0.02
			p.volumetric_color = Color("8a60c8")
			p.saturation = 1.05
			p.particles = [{"kind": "motes", "color": Color(0.8, 0.7, 1.0, 0.7), "amount": 40}]
		ARENA:
			p.with_id(id, "Arena: dusk crowd light")
			p.sky_top = Color("241a44")
			p.sky_horizon = Color("a05a5a")
			p.ground_horizon = Color("7a4a52")
			p.ground_bottom = Color("1c1230")
			p.sun_color = Color("ffc890")
			p.sun_energy = 1.0
			p.ambient_color = Color("8a6aa8")
			p.fog_color = Color("5a3a52")
			p.fog_density = 0.01
			p.particles = [{"kind": "sparkles", "color": Color(1.0, 0.85, 0.5, 1.0), "amount": 20}]
		_:
			p = get_preset(TOWN)
	return p
