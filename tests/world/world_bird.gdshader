shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled;
// A far-off bird (WorldAmbient): an upright camera-facing card with a flapping two-winged silhouette drawn in the shader.

uniform float flap_rate = 5.0;
uniform float phase = 0.0;
uniform vec3 color : source_color = vec3(0.22, 0.17, 0.2);
uniform vec2 card_size = vec2(3.0, 1.6);

void vertex() {
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	vec3 back = normalize(vec3(INV_VIEW_MATRIX[2].x, 0.0, INV_VIEW_MATRIX[2].z));
	mat4 face = mat4(vec4(right, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(back, 0.0), MODEL_MATRIX[3]);
	VERTEX = vec3(VERTEX.x * card_size.x, VERTEX.y * card_size.y, 0.0);
	MODELVIEW_MATRIX = VIEW_MATRIX * face;
}

void fragment() {
	vec2 p = vec2(UV.x * 2.0 - 1.0, 1.0 - UV.y * 2.0);
	float flap = sin(TIME * flap_rate + phase);
	float ax = abs(p.x);
	// Wing line: sweeps up and back while flapping; the body is the thick middle.
	float line = flap * 0.62 * pow(ax, 1.4) - 0.16 * (1.0 - ax) + 0.05 * ax;
	float thick = 0.1 * (1.0 - ax) + 0.035;
	float wing = smoothstep(thick, thick - 0.035, abs(p.y - line)) * step(ax, 0.97);
	float body = smoothstep(0.17, 0.1, length(vec2(p.x * 1.6, p.y + 0.12)));
	float m = max(wing, body);
	ALBEDO = color;
	ALPHA = m * 0.9;
}
