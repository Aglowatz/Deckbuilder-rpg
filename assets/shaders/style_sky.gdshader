shader_type sky;
render_mode use_half_res_pass;
// The zone sky (docs/art/graphics_loop.md, G-04): a painted gradient with a horizon haze band, toon-banded drifting clouds on two layers
// (above the horizon, and a "cloud sea" below it, which is what the high-angle diorama camera actually sees), an optional sun disc with a soft
// glow and optional twinkling stars. The cubemap pass (ambient/reflections, unused by the rig) only gets the gradient, so it stays cheap.

uniform vec3 top_color : source_color = vec3(0.37, 0.56, 0.85);
uniform vec3 horizon_color : source_color = vec3(1.0, 0.84, 0.63);
uniform vec3 bottom_color : source_color = vec3(0.42, 0.35, 0.42);
uniform vec3 cloud_color : source_color = vec3(1.0, 0.95, 0.9);
uniform vec3 cloud_shade : source_color = vec3(0.62, 0.56, 0.78);
uniform float cloud_cover : hint_range(0.0, 1.0) = 0.5;
uniform float cloud_speed = 0.012;
uniform float cloud_scale = 1.6;
uniform float haze : hint_range(0.0, 1.0) = 0.5;
uniform float star_amount : hint_range(0.0, 1.0) = 0.0;
uniform float sun_glow : hint_range(0.0, 1.0) = 0.4;
uniform vec3 sun_color : source_color = vec3(1.0, 0.9, 0.7);

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

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.55;
	for (int i = 0; i < 3; i++) {
		v += a * vnoise(p);
		p = p * 2.07 + vec2(11.3, 5.7);
		a *= 0.5;
	}
	return v;
}

// One cloud layer on a plane `height` away; returns (coverage 0..1, shade 0..1: 1 = the lit top of the puff).
vec2 cloud_layer(vec3 dir, float height, float drift, float seed) {
	float denom = max(abs(dir.y), 0.08);
	vec2 p = dir.xz / denom * (height * cloud_scale) + vec2(TIME * cloud_speed * drift, TIME * cloud_speed * 0.4 * drift) + seed * 17.0;
	float n = fbm(p * 0.35);
	float edge = 1.0 - cloud_cover;
	// Two painted steps (body, then a lit crest) instead of a soft gradient.
	float body = smoothstep(edge - 0.02, edge + 0.07, n);
	float lit = smoothstep(edge + 0.1, edge + 0.17, n + 0.06 * (vnoise(p * 1.3) - 0.5));
	return vec2(body, lit);
}

void sky() {
	vec3 dir = EYEDIR;
	float y = dir.y;
	// Gradient: top -> horizon -> bottom, with the horizon colour held over a haze band.
	float up = clamp(y, 0.0, 1.0);
	float down = clamp(-y, 0.0, 1.0);
	vec3 col = mix(horizon_color, top_color, smoothstep(0.0, 0.45, up));
	col = mix(col, bottom_color, smoothstep(0.0, 0.95, down) * 0.9);
	if (AT_CUBEMAP_PASS) {
		COLOR = col;
	} else if (AT_HALF_RES_PASS) {
		// Distance fade of the clouds into the haze band at the horizon.
		float fade = smoothstep(0.0, 0.2, abs(y));
		vec2 near_layer = cloud_layer(dir, 1.0, 1.0, y < 0.0 ? 1.0 : 0.0);
		vec2 far_layer = cloud_layer(dir, 2.1, 0.55, y < 0.0 ? 3.0 : 2.0);
		vec3 shade = mix(cloud_shade, cloud_color, 0.35);
		vec3 far_col = mix(shade, cloud_color, far_layer.y * 0.6);
		col = mix(col, far_col, far_layer.x * 0.75 * fade);
		vec3 near_col = mix(shade, cloud_color, near_layer.y);
		col = mix(col, near_col, near_layer.x * 0.9 * fade);
		// Horizon haze.
		float band = exp(-abs(y) * 14.0) * haze;
		col = mix(col, horizon_color, band * 0.6);
		// Sun disc and glow.
		float sun_dot = max(dot(dir, normalize(LIGHT0_DIRECTION)), 0.0);
		col += sun_color * (smoothstep(0.9993, 0.9997, sun_dot) + pow(sun_dot, 24.0) * sun_glow * 0.5) * step(0.0, y + 0.1);
		// Stars (only above the horizon, only where the clouds do not cover).
		if (star_amount > 0.0 && y > 0.02) {
			vec2 sp = dir.xz / (y + 0.4) * 60.0;
			float h = hash21(floor(sp));
			float star = step(1.0 - 0.05 * star_amount, h) * (0.55 + 0.45 * sin(TIME * (1.5 + h * 3.0) + h * 40.0));
			col += vec3(1.0, 0.97, 0.9) * star * (1.0 - far_layer.x) * smoothstep(0.02, 0.2, y);
		}
		COLOR = col;
	} else {
		// The full-resolution pass only upsamples the half-resolution cloud/haze pass.
		COLOR = HALF_RES_COLOR.rgb;
	}
}
