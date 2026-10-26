// Graphics Tier 1, Part 2 (docs/art/graphics_tier1.md): the zone's ground light map, a "baked" ambient occlusion built at load time by GroundLight
// (world/style/ground_light.gd) from every static occluder (buildings, walls, trees, big props): one small texture over the zone, R = how open the sky is
// above that spot (1 = open ground, 0 = deep under a canopy or against a wall). Every ground, wall, prop and character shader multiplies its albedo by it,
// so corners, the foot of walls, the ground under eaves and trees and the characters standing there all sit in the same soft shade, the way a lightmap
// would, for one texture fetch. The engine's SSAO (High only) adds the fine contact detail on top.
// Graphics Tier 2 (docs/art/graphics_tier2.md): the same texture's G and B channels carry a bounce colour - the chroma of the walls round a spot, so a warm
// plaster or brick wall tints the ground (and the feet of whoever stands there) beside it. Stored as signed red / blue deltas (0.5 = none); the green delta
// follows so the tint never changes the luminance. Still one texture fetch.
//   style_ground_light_rect: x, y = the map's world origin (x, z), z, w = 1 / its world size.
//   style_ground_light_amount: 0 = off (Low, or a zone without a map), 1 = the full darkening.
//   style_ground_light_tint: the colour the shade leans towards (the zone's ambient: never plain black).
//   style_ground_bounce: how much of the bounce colour shows (the zone style's light.bounce; 0 = off).

global uniform sampler2D style_ground_light;
global uniform vec4 style_ground_light_rect;
global uniform float style_ground_light_amount;
global uniform vec3 style_ground_light_tint;
global uniform float style_ground_bounce;

// The map at a world position: r = openness (1 = open), g / b = the bounce deltas (0.5 = none). Outside the map everything is open and untinted.
vec4 ground_light_sample(vec3 world) {
	if (style_ground_light_amount <= 0.001) {
		return vec4(1.0, 0.5, 0.5, 1.0);
	}
	vec2 uv = (world.xz - style_ground_light_rect.xy) * style_ground_light_rect.zw;
	float inside = step(0.0, uv.x) * step(0.0, uv.y) * step(uv.x, 1.0) * step(uv.y, 1.0);
	return mix(vec4(1.0, 0.5, 0.5, 1.0), texture(style_ground_light, uv), inside);
}

// The openness at a world position (1 = open).
float ground_light_open(vec3 world) {
	return ground_light_sample(world).r;
}

// Multiplies a colour by the ground light: `height` is the surface's height above the ground (metres; the shade fades out by `fade_height`, so walls darken at
// their foot and stay lit higher up) and `strength` how much of the darkening this surface takes (the ground 1.0, props 0.8, characters 0.5).
vec3 ground_light_apply(vec3 color, vec3 world, float height, float fade_height, float strength, float screen_y) {
	vec4 s = ground_light_sample(world);
	// The bottom of the screen is where the OcclusionFader cuts buildings away: the shade under a building that is no longer there would read as a dark
	// rectangle on the ground, so the map fades out over the lowest fifth of the screen (the tilt-shift blurs that band anyway).
	float base = style_ground_light_amount * strength * (1.0 - smoothstep(0.0, fade_height, height));
	float shade = (1.0 - s.r) * base * (1.0 - smoothstep(0.74, 0.92, screen_y));
	color = mix(color, color * style_ground_light_tint, shade);
	// Tier 2: the bounce colour, a luminance-preserving chroma tint from the walls round the spot. A soft warm tint left by a cut-away building is no
	// dark rectangle, so it fades out later and lower on the screen than the shade does.
	float dr = s.g * 2.0 - 1.0;
	float db = s.b * 2.0 - 1.0;
	float dg = -(0.299 * dr + 0.114 * db) / 0.587;
	return color * (1.0 + vec3(dr, dg, db) * base * (1.0 - smoothstep(0.84, 0.98, screen_y)) * style_ground_bounce);
}
