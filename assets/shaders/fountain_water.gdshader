shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, specular_schlick_ggx;

// Nov 2 pass, Part 6: the Crosspath fountain's water. Solid geometry (the pool disc and the four spout ribbons) with a two-layer scrolling
// noise for the current and a foam band where the layers crest; the vertex colour carries each spout's Path colour (and their blend in the
// pool), so one material draws every stream. `use_uv` scrolls along a ribbon's UV (down the stream) instead of world space (the pool).
uniform float flow_speed = 0.55;
uniform float glow = 0.3;
uniform float foam = 0.6;
uniform float alpha = 0.9;
uniform bool use_uv = false;

varying vec3 vcol;
varying vec2 wpos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	vcol = COLOR.rgb;
	wpos = use_uv ? UV * vec2(2.0, 6.0) : (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	float t = TIME * flow_speed;
	vec2 drift = use_uv ? vec2(0.0, -t * 2.2) : vec2(t, -t * 0.7);
	float n = noise(wpos * 3.0 + drift) * 0.6 + noise(wpos * 7.0 - drift * 1.4) * 0.4;
	float crest = smoothstep(0.58, 0.78, n) * foam;
	vec3 water = vcol;
	vec3 col = mix(water, vec3(1.0), crest);
	ALBEDO = col;
	ALPHA = alpha;
	EMISSION = col * glow;
	ROUGHNESS = 0.12;
	METALLIC = 0.0;
	SPECULAR = 0.6;
}
