shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled;
// The batched AO skirts of the kit (KitPools.build_ao): vertex colour = the violet shade, alpha = strength. Graphics Tier 1: the pools fade out over the
// lowest fifth of the screen, where the OcclusionFader cuts buildings away - a skirt under a building that is no longer there read as a flat violet
// rectangle on the ground (Part 0 baseline, town_street).

uniform float bottom_fade_start = 0.74;
uniform float bottom_fade_end = 0.92;

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a * (1.0 - smoothstep(bottom_fade_start, bottom_fade_end, SCREEN_UV.y));
}
