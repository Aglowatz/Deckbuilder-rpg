shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never, depth_test_disabled, cull_disabled;
// Screen-space outline (docs/art/style_guide.md, section 3): depth + normal edge detection on a full-screen quad parented to the camera.
// One pass for every pack, subtle, tinted (never pure black), fading with distance.

uniform sampler2D depth_tex : hint_depth_texture, filter_nearest, repeat_disable;
uniform sampler2D normal_tex : hint_normal_roughness_texture, filter_nearest, repeat_disable;
uniform vec4 line_color : source_color = vec4(0.12, 0.07, 0.16, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.7;
uniform float thickness = 1.0;
uniform float depth_threshold = 0.9;
uniform float normal_threshold = 0.45;
uniform float fade_start = 28.0;
uniform float fade_end = 70.0;

float linear_depth(vec2 uv, mat4 inv_proj) {
	float d = texture(depth_tex, uv).x;
	vec3 ndc = vec3(uv * 2.0 - 1.0, d);
	vec4 view = inv_proj * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 px = thickness / VIEWPORT_SIZE;
	float c = linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
	float l = linear_depth(SCREEN_UV + vec2(-px.x, 0.0), INV_PROJECTION_MATRIX);
	float r = linear_depth(SCREEN_UV + vec2(px.x, 0.0), INV_PROJECTION_MATRIX);
	float u = linear_depth(SCREEN_UV + vec2(0.0, -px.y), INV_PROJECTION_MATRIX);
	float dn = linear_depth(SCREEN_UV + vec2(0.0, px.y), INV_PROJECTION_MATRIX);
	float edge_d = abs(l - c) + abs(r - c) + abs(u - c) + abs(dn - c);
	edge_d = edge_d / max(c, 0.5);
	float depth_edge = smoothstep(depth_threshold * 0.05, depth_threshold * 0.12, edge_d);
	vec3 n = texture(normal_tex, SCREEN_UV).xyz * 2.0 - 1.0;
	vec3 nl = texture(normal_tex, SCREEN_UV + vec2(-px.x, 0.0)).xyz * 2.0 - 1.0;
	vec3 nr = texture(normal_tex, SCREEN_UV + vec2(px.x, 0.0)).xyz * 2.0 - 1.0;
	vec3 nu = texture(normal_tex, SCREEN_UV + vec2(0.0, -px.y)).xyz * 2.0 - 1.0;
	vec3 nd = texture(normal_tex, SCREEN_UV + vec2(0.0, px.y)).xyz * 2.0 - 1.0;
	float edge_n = length(n - nl) + length(n - nr) + length(n - nu) + length(n - nd);
	float normal_edge = smoothstep(normal_threshold, normal_threshold + 0.5, edge_n);
	float edge = max(depth_edge, normal_edge * 0.8);
	float fade = 1.0 - smoothstep(fade_start, fade_end, c);
	float sky = step(0.0001, texture(depth_tex, SCREEN_UV).x);
	ALBEDO = line_color.rgb;
	ALPHA = edge * strength * fade * sky;
}
