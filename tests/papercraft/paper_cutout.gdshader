shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;
// Papercraft cut-out: the sprite, a thin white paper border grown out of its alpha, a darker "thickness" rim on the lower-right and a bright catch-light on the upper-left.

uniform sampler2D albedo_tex : source_color, filter_linear;
uniform vec2 texel = vec2(0.002, 0.0013);   // 1 / texture size
uniform float border_px = 7.0;               // white paper border width in texels
uniform float thick_px = 3.5;                // thickness rim offset in texels (towards lower right)
uniform vec3 paper_white : source_color = vec3(0.97, 0.95, 0.90);
uniform vec3 paper_edge : source_color = vec3(0.70, 0.67, 0.62);
uniform float brightness = 1.0;

float cover(vec2 uv, float radius) {
	float best = 0.0;
	for (int i = 0; i < 12; i++) {
		float a = float(i) * 0.5235988;
		best = max(best, texture(albedo_tex, uv + vec2(cos(a), sin(a)) * radius * texel).a);
	}
	for (int j = 0; j < 8; j++) {
		float a2 = float(j) * 0.785398 + 0.39;
		best = max(best, texture(albedo_tex, uv + vec2(cos(a2), sin(a2)) * radius * 0.5 * texel).a);
	}
	return best;
}

void fragment() {
	vec4 c = texture(albedo_tex, UV);
	float body = smoothstep(0.35, 0.65, c.a);
	float grown = smoothstep(0.2, 0.6, cover(UV, border_px));
	vec2 shift = vec2(thick_px, thick_px) * texel;
	float grown_thick = smoothstep(0.2, 0.6, cover(UV - shift, border_px));
	// catch-light: border pixels whose upper-left neighbour is outside the border
	float lit = 1.0 - smoothstep(0.2, 0.6, cover(UV + vec2(-2.5, -2.5) * texel, border_px));
	vec3 border = mix(paper_white, vec3(1.0), lit * 0.9);
	vec3 col = c.rgb * brightness;
	vec3 result = mix(paper_edge, border, grown);
	result = mix(result, col, body);
	float alpha = max(grown, grown_thick);
	ALBEDO = result;
	ALPHA = alpha;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
