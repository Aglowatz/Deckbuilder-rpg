// Graphics Tier 2 (docs/art/graphics_tier2.md): one shared wind for the whole zone. Grass blades, the painted foliage cards, the kit's tree cards, the
// toon shader's foliage sway and the hanging cloth (banners, flags and their icons) all read the same direction and the same gust front, so a gust
// visibly sweeps across the field, through the trees and into the banners in one motion instead of each system breathing to its own clock. The zone's
// `style_wind` global (the style file's `wind`) still scales everything; each shader keeps its own amplitude uniform.

// The wind's direction (world space, horizontal).
const vec3 STYLE_WIND_DIR = vec3(0.86, 0.0, 0.5);

// A gust front sweeping along the wind direction (0 = lull, 1 = a full gust): a main wave and a slower, longer one so the pattern never visibly repeats.
float style_wind_gust(vec2 world_xz, float time) {
	float along = dot(world_xz, STYLE_WIND_DIR.xz);
	float a = sin(along * 0.11 - time * 1.1);
	float b = sin(along * 0.037 - time * 0.45 + 1.3);
	float g = 0.5 + 0.5 * (0.65 * a + 0.35 * b);
	return g * g;
}

// A quick per-object flutter riding the gust (-1 .. 1); `phase` separates neighbours.
float style_wind_flutter(vec2 world_xz, float time, float phase) {
	return sin(time * 2.6 + world_xz.x * 1.9 + world_xz.y * 1.4 + phase);
}

// The hanging cloth's offset at a vertex (local space): along the cloth's normal only, zero at the top edge, growing with the square of the distance
// down the cloth, at most about 3.5 % of the cloth's length; the wind's push through the cloth sets the lean, the shared gust front plus a little
// flutter the motion. Shared by the toon shaders and the banner icon shader so an icon never parts from its cloth.
// cloth.xyz = the cloth's normal (local), cloth.w = its length; top_phase = the top edge's local height and a phase per banner.
vec3 hang_offset(vec3 v, mat4 model, vec4 cloth, vec2 top_phase, float time) {
	float down = clamp((top_phase.x - v.y) / cloth.w, 0.0, 1.0);
	vec3 n = normalize(cloth.xyz);
	vec3 wind_local = normalize(transpose(mat3(model)) * STYLE_WIND_DIR);
	float push = dot(wind_local, n);
	float lean = mix(0.35, 1.0, abs(push)) * (push < 0.0 ? -1.0 : 1.0);
	float gust = 0.4 + 0.4 * style_wind_gust(model[3].xz, time) + 0.15 * sin(time * 0.85 + top_phase.y) + 0.08 * sin(time * 2.4 + top_phase.y * 1.7);
	return n * lean * gust * down * down * cloth.w * 0.035;
}
