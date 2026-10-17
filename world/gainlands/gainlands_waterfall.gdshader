shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix;
// Gainlands v2: a waterfall sheet down a sandstone cliff. Streaks scroll down (UV.y grows downwards), the edges and the lip feather out, the foot whitens into
// foam. One quad strip per fall; no textures (the streaks are a cheap hash of the column and the scrolled row).

uniform vec3 water_color : source_color = vec3(0.55, 0.82, 0.98);
uniform vec3 foam_color : source_color = vec3(0.96, 0.99, 1.0);
uniform float speed = 1.1;
uniform float streaks = 26.0;
uniform float opacity = 0.82;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	float column = floor(UV.x * streaks);
	float jitter = hash(vec2(column, 1.7));
	float flow = UV.y * 3.0 - TIME * speed * (0.8 + jitter * 0.6);
	float streak = smoothstep(0.35, 0.95, fract(flow + jitter * 4.0)) * (0.5 + 0.5 * hash(vec2(column, floor(flow))));
	float edge = smoothstep(0.0, 0.12, UV.x) * smoothstep(1.0, 0.88, UV.x);
	float lip = smoothstep(0.0, 0.08, UV.y);
	float foam = smoothstep(0.72, 1.0, UV.y);
	vec3 col = mix(water_color, foam_color, clamp(streak * 0.55 + foam, 0.0, 1.0));
	ALBEDO = col;
	ALPHA = opacity * edge * lip * (0.55 + 0.45 * streak + foam * 0.4);
}
