shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_back, fog_disabled;
// Soft cloud shadows drifting over the ground and water: a big plane just above the ground that darkens (with a violet tint) where a world-space noise field is dense.

uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform vec2 drift = vec2(0.6, 0.25);
uniform float scale = 0.011;
uniform float strength = 0.16;
uniform vec3 tint : source_color = vec3(0.16, 0.12, 0.3);
uniform vec3 follow_pos = vec3(0.0);
uniform float radius = 140.0;

varying vec3 v_world;

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = v_world.xz * scale + drift * TIME * 0.02;
	float n = texture(noise_tex, p).r * 0.65 + texture(noise_tex, p * 2.3 + 0.37).r * 0.35;
	float shade = smoothstep(0.52, 0.72, n);
	float edge = 1.0 - smoothstep(radius * 0.6, radius, length(v_world.xz - follow_pos.xz));
	ALBEDO = tint;
	ALPHA = shade * strength * edge;
}
