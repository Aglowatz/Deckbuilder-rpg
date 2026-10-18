shader_type spatial;
// Opening Forest: soft drifting mist. Ground layers are flat quads a little above the floor; far banks are upright cards between the trunks.
// Two octaves of value noise scrolled in different directions give slow drifting wisps; the quad's own UV fades the edges so no border shows,
// and a depth fade softens where the mist meets the ground, a rock or a trunk. Unshaded, fog-free (it IS the fog), cheap.
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, fog_disabled, shadows_disabled;

uniform vec4 tint : source_color = vec4(0.55, 0.72, 0.78, 1.0);
uniform float strength = 0.35;
uniform float scale = 0.18;
uniform vec2 drift = vec2(0.035, 0.012);
uniform float soft = 1.2;
uniform float seed = 0.0;
uniform sampler2D depth_tex : hint_depth_texture, filter_linear;

varying vec3 world_pos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 17.0) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = (abs(NORMAL.y) > 0.5 ? world_pos.xz : vec2(world_pos.x + world_pos.z, world_pos.y * 1.6)) * scale;
	float n = noise(p + drift * TIME * 10.0) * 0.62 + noise(p * 2.3 - drift.yx * TIME * 14.0 + 3.1) * 0.38;
	n = smoothstep(0.32, 0.86, n);
	vec2 e = min(UV, 1.0 - UV);
	float edge = smoothstep(0.0, 0.32, e.x) * smoothstep(0.0, 0.32, e.y);
	float scene_depth = texture(depth_tex, SCREEN_UV).r;
	vec4 view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, scene_depth, 1.0);
	float behind = -view.z / view.w;
	float fade = clamp((behind + VERTEX.z) / soft, 0.0, 1.0);
	ALBEDO = tint.rgb;
	ALPHA = strength * n * edge * fade;
}
