shader_type sky;
// Painted-looking sky for the World Look Test (docs/art/world_look_test.md): warm golden haze at the horizon, a soft golden band above it, then soft blue.
// Cloud sprites and the sun glow are separate cards (world_sky.gd); this is only the gradient.

uniform vec3 horizon_color : source_color = vec3(0.96, 0.82, 0.64);
uniform vec3 gold_color : source_color = vec3(1.0, 0.8, 0.5);
uniform vec3 mid_color : source_color = vec3(0.66, 0.77, 0.92);
uniform vec3 zenith_color : source_color = vec3(0.36, 0.55, 0.84);
uniform vec3 sun_dir = vec3(-0.42, 0.62, 0.67);
uniform vec3 sun_color : source_color = vec3(1.0, 0.86, 0.6);
// A painted sky picture (a zone kit SKY backdrop such as DNA-SKY-GLOOM) wrapped round the dome: its bottom row at the horizon, its top row overhead, mirrored
// twice round the compass so there is no seam. `panorama_mix` 0 keeps the gradient alone; the gradient still shows through the lowest sliver at the horizon.
uniform sampler2D panorama_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform float panorama_mix : hint_range(0.0, 1.0) = 0.0;
uniform float panorama_stretch = 1.25;

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

void sky() {
	vec3 d = normalize(EYEDIR);
	float h = max(d.y, 0.0);
	vec3 col = horizon_color;
	col = mix(col, gold_color, smoothstep(0.0, 0.05, h));
	col = mix(col, mid_color, smoothstep(0.05, 0.3, h));
	col = mix(col, zenith_color, smoothstep(0.25, 0.95, h));
	// Soft brushed variation: long horizontal streaks, very low contrast.
	float az = atan(d.x, d.z);
	float streak = vnoise(vec2(az * 3.0, h * 26.0)) * 0.6 + vnoise(vec2(az * 7.0 + 3.0, h * 60.0)) * 0.4;
	col *= 0.975 + 0.05 * streak;
	// Warm glow on the sun's side of the sky.
	float s = max(dot(d, normalize(sun_dir)), 0.0);
	col += sun_color * (pow(s, 5.0) * 0.12 + pow(s, 40.0) * 0.18);
	if (panorama_mix > 0.0) {
		float u = abs(fract(az / 6.2831853 + 0.5) * 2.0 - 1.0);
		float v = 1.0 - clamp(h * panorama_stretch, 0.0, 1.0);
		vec3 pano = texture(panorama_tex, vec2(u, v)).rgb;
		col = mix(col, pano, panorama_mix * smoothstep(0.0, 0.035, h));
	}
	COLOR = col;
}
