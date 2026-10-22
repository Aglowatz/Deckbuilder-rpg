shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled;
// The batched warm light pools of the kit (KitPools.build_glow): vertex colour = the light and its strength, times the soft round texture, added to the ground.
// Graphics Tier 1: like the AO skirts, the pools fade out over the lowest fifth of the screen where the OcclusionFader cuts buildings away (the lit window
// of a building that is no longer there glowed on the bare ground).

uniform sampler2D soft_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float bottom_fade_start = 0.74;
uniform float bottom_fade_end = 0.92;

void fragment() {
	vec4 t = texture(soft_tex, UV);
	float keep = 1.0 - smoothstep(bottom_fade_start, bottom_fade_end, SCREEN_UV.y);
	ALBEDO = COLOR.rgb * t.rgb;
	ALPHA = COLOR.a * t.a * keep;
}
