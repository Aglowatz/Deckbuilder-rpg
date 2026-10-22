shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled;
// Graphics Tier 1, Part 2 (docs/art/graphics_tier1.md): a low fog card - one flat quad laid just above the ground in a hollow (a lake shore, the foot of a
// field, a graveyard) that reads as a bank of mist: a soft round mask, two octaves of slowly drifting world-space noise, the zone's fog colour, and a
// fade when the camera gets close so it never fills the screen. Costs one quad of alpha; volumetric fog stays High-only.

uniform vec3 color : source_color = vec3(0.95, 0.81, 0.64);
uniform float strength : hint_range(0.0, 1.0) = 0.35;
uniform float drift = 0.35;
uniform float noise_scale = 0.09;
uniform float near_fade = 11.0;
uniform float seed = 0.0;

varying vec3 v_world;
varying vec2 v_uv;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x), mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_uv = UV;
}

void fragment() {
	vec2 p = v_world.xz * noise_scale + vec2(TIME * drift * 0.02 + seed, TIME * drift * 0.013 - seed);
	float n = vnoise(p) * 0.6 + vnoise(p * 2.7 + 11.0) * 0.4;
	float bank = smoothstep(0.32, 0.78, n);
	float mask = 1.0 - smoothstep(0.35, 1.0, length(v_uv * 2.0 - 1.0));
	float near = smoothstep(near_fade * 0.5, near_fade, distance(v_world, CAMERA_POSITION_WORLD));
	ALBEDO = color;
	ALPHA = bank * mask * strength * near;
}
