shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
#include "res://assets/shaders/style_wind.gdshaderinc"
// An icon painted on a hanging banner (the ruler's emblem): unshaded like the other pictograms, and moving with its banner's cloth in the toon shaders'
// hang mode (Gainlands v2, Part E): the same offset (`hang_offset` from style_wind.gdshaderinc), the same per-instance parameters (in this quad's own
// local frame), so the icon never parts from the cloth.

global uniform float style_wind;
uniform sampler2D icon : source_color, filter_linear_mipmap, repeat_disable;
uniform float wind_amount = 1.5;
instance uniform vec4 hang = vec4(0.0);
instance uniform vec2 hang_top_phase = vec2(0.0);

void vertex() {
	if (hang.w > 0.0) {
		VERTEX += hang_offset(VERTEX, MODEL_MATRIX, hang, hang_top_phase, TIME) * style_wind;
	}
}

void fragment() {
	vec4 c = texture(icon, UV);
	ALBEDO = c.rgb;
	ALPHA = c.a;
	ALPHA_SCISSOR_THRESHOLD = 0.4;
}
