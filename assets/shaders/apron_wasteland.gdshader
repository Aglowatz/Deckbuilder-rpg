shader_type spatial;
// Fable Nov 15 (Part 1): the endless ground under a zone (WorldScenery's apron) as the Capital's wasteland - cracked ash (TEX-CAP-ASH)
// with patches of broken paving (TEX-CAP-CRACKEDROAD), tinted by the zone. The ash is sampled at two scales so no repeat shows from the
// high camera, and a slow noise darkens and lightens it in big soft areas. Unshaded, like the tiled apron, so the scene fog still
// dissolves it into the background and it reads the same in every light.
render_mode unshaded, cull_disabled;

uniform sampler2D ash_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D paving_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform vec4 tint : source_color = vec4(0.62, 0.7, 0.66, 1.0);
uniform float tile_size = 7.0;
uniform float paving_tile = 4.2;
uniform float paving_amount = 0.34;
uniform float brightness = 1.0;
uniform float macro_variation = 0.2;

varying vec3 world_pos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_pos.xz;
	vec3 ash = texture(ash_tex, p / tile_size).rgb;
	// the second sample: bigger and turned, so the first one's repeat is broken up
	vec2 turned = vec2(p.x * 0.8 - p.y * 0.6, p.x * 0.6 + p.y * 0.8);
	vec3 ash_far = texture(ash_tex, turned / (tile_size * 2.7)).rgb;
	vec3 color = mix(ash, ash_far, 0.45);
	// broken paving in patches (the old roads and yards), soft-edged, where a slow noise runs high
	float patches = value_noise(p * 0.045 + vec2(3.7, 9.1)) * 0.65 + value_noise(p * 0.13) * 0.35;
	float paved = smoothstep(1.0 - paving_amount - 0.06, 1.0 - paving_amount + 0.06, patches);
	vec3 paving = texture(paving_tex, p / paving_tile).rgb;
	// (the paving's own green weeds and purple seams are pulled most of the way to grey: the zone's tint colours it)
	float paving_grey = dot(paving, vec3(0.3, 0.5, 0.2));
	paving = mix(paving, vec3(paving_grey), 0.55);
	color = mix(color, paving, paved);
	float macro = value_noise(p * 0.02 + vec2(11.0, 5.0));
	color *= 1.0 + (macro - 0.5) * 2.0 * macro_variation;
	ALBEDO = color * tint.rgb * brightness;
}
