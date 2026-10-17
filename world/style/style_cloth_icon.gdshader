shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
// An icon painted on a hanging banner (the ruler's emblem): unshaded like the other pictograms, and moving with its banner's cloth in the toon shaders'
// hang mode (Gainlands v2, Part E): the same offset, the same per-instance parameters (in this quad's own local frame), so the icon never parts from the cloth.

global uniform float style_wind;
uniform sampler2D icon : source_color, filter_linear_mipmap, repeat_disable;
uniform float wind_amount = 1.5;
instance uniform vec4 hang = vec4(0.0);
instance uniform vec2 hang_top_phase = vec2(0.0);
const vec3 STYLE_WIND_DIR = vec3(0.86, 0.0, 0.5);

vec3 hang_offset(vec3 v, mat4 model, vec4 cloth, vec2 top_phase, float time) {
	float down = clamp((top_phase.x - v.y) / cloth.w, 0.0, 1.0);
	vec3 n = normalize(cloth.xyz);
	vec3 wind_local = normalize(transpose(mat3(model)) * STYLE_WIND_DIR);
	float push = dot(wind_local, n);
	float lean = mix(0.35, 1.0, abs(push)) * (push < 0.0 ? -1.0 : 1.0);
	float gust = 0.55 + 0.35 * sin(time * 0.85 + top_phase.y) + 0.1 * sin(time * 2.4 + top_phase.y * 1.7);
	return n * lean * gust * down * down * cloth.w * 0.035;
}

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
