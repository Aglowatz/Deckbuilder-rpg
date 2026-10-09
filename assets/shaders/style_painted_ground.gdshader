shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled;
// Painted ground for the texture test (docs/art/texture_test.md): hand-painted grass, wildflower meadow and plaza stone, in world space, under the game's own toon bands.
// - Stochastic "triangle-grid" tiling (random rotation + offset per triangle, soft blend, textureGrad so mips never seam): no tile grid shows at any zoom.
// - Wildflower patches come from soft two-octave noise masks; the plaza stone is a noisy-edged disc round `plaza_center`.
// - Large-scale value/tint patches on top break up whatever repetition is left.
// - Normal maps lean the surface only a little (painted, not embossed) and fade out with distance; roughness only drives a faint sheen on the lit band.

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;
global uniform float style_ground_sat;

uniform sampler2D grass_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D grass_normal : filter_linear_mipmap, repeat_enable;
uniform sampler2D grass_rough : filter_linear_mipmap, repeat_enable;
uniform sampler2D flower_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D flower_normal : filter_linear_mipmap, repeat_enable;
uniform sampler2D flower_rough : filter_linear_mipmap, repeat_enable;
uniform sampler2D stone_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D stone_normal : filter_linear_mipmap, repeat_enable;
uniform sampler2D stone_rough : filter_linear_mipmap, repeat_enable;

// Metres covered by one texture tile.
uniform float grass_tile = 6.0;
uniform float flower_tile = 6.5;
uniform float stone_tile = 3.2;
uniform vec2 plaza_center = vec2(25.2, 12.47);
uniform float plaza_radius = 6.2;
uniform float fade_start = 26.0;
uniform float fade_end = 34.0;
uniform float flower_amount = 1.0;
uniform float macro_amount = 0.2;
uniform float tint_amount = 0.55;
uniform float normal_strength = 0.5;
uniform float normal_far = 18.0;
uniform float sheen = 0.1;
uniform float brightness = 1.0;

varying vec3 v_world;

struct Tri {
	vec2 uv0;
	vec2 uv1;
	vec2 uv2;
	mat2 r0;
	mat2 r1;
	mat2 r2;
	vec3 w;
};

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
	return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x), mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	return vnoise(p) * 0.6 + vnoise(p * 2.13 + 7.0) * 0.4;
}

mat2 rotation(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat2(vec2(c, s), vec2(-s, c));
}

// One triangle-grid vertex: its random offset + rotation of the texture.
void vertex_tile(vec2 uv, vec2 id, float salt, out vec2 out_uv, out mat2 out_rot) {
	vec2 h = hash22(id + salt);
	out_rot = rotation(h.x * 6.2831853);
	out_uv = out_rot * uv + h.yx * 7.31;
}

Tri make_tri(vec2 uv, float salt, float sharp) {
	Tri t;
	vec2 skewed = mat2(vec2(1.0, 0.0), vec2(-0.57735027, 1.15470054)) * (uv * 3.4641016 * 0.5);
	vec2 base = floor(skewed);
	vec3 f = vec3(fract(skewed), 0.0);
	f.z = 1.0 - f.x - f.y;
	vec2 v0;
	vec2 v1;
	vec2 v2;
	if (f.z > 0.0) {
		t.w = vec3(f.z, f.y, f.x);
		v0 = base;
		v1 = base + vec2(0.0, 1.0);
		v2 = base + vec2(1.0, 0.0);
	} else {
		t.w = vec3(-f.z, 1.0 - f.y, 1.0 - f.x);
		v0 = base + vec2(1.0, 1.0);
		v1 = base + vec2(1.0, 0.0);
		v2 = base + vec2(0.0, 1.0);
	}
	vertex_tile(uv, v0, salt, t.uv0, t.r0);
	vertex_tile(uv, v1, salt, t.uv1, t.r1);
	vertex_tile(uv, v2, salt, t.uv2, t.r2);
	t.w = pow(t.w, vec3(sharp));
	t.w /= (t.w.x + t.w.y + t.w.z);
	return t;
}


// Corners whose (sharpened) weight is negligible are not sampled: most of a triangle is one tile, so this is usually one or two taps, not three.
const float SKIP = 0.02;

vec4 tri_color_grad(sampler2D tex, Tri t, vec2 dx, vec2 dy) {
	vec4 sum = vec4(0.0);
	float used = 0.0;
	if (t.w.x > SKIP) {
		sum += textureGrad(tex, t.uv0, t.r0 * dx, t.r0 * dy) * t.w.x;
		used += t.w.x;
	}
	if (t.w.y > SKIP) {
		sum += textureGrad(tex, t.uv1, t.r1 * dx, t.r1 * dy) * t.w.y;
		used += t.w.y;
	}
	if (t.w.z > SKIP) {
		sum += textureGrad(tex, t.uv2, t.r2 * dx, t.r2 * dy) * t.w.z;
		used += t.w.z;
	}
	return sum / used;
}

// Roughness only feeds a faint sheen, so one tap from the triangle corner with the largest weight is enough.
float tri_rough(sampler2D tex, Tri t, vec2 dx, vec2 dy) {
	if (t.w.x >= t.w.y && t.w.x >= t.w.z) {
		return textureGrad(tex, t.uv0, t.r0 * dx, t.r0 * dy).r;
	}
	if (t.w.y >= t.w.z) {
		return textureGrad(tex, t.uv1, t.r1 * dx, t.r1 * dy).r;
	}
	return textureGrad(tex, t.uv2, t.r2 * dx, t.r2 * dy).r;
}

// Slope (world x/z) of a tangent-space normal map sample (green up in the image) after undoing each tile's rotation.
vec2 tri_slope(sampler2D tex, Tri t, vec2 dx, vec2 dy) {
	vec2 sum = vec2(0.0);
	float used = 0.0;
	if (t.w.x > SKIP) {
		vec3 n = textureGrad(tex, t.uv0, t.r0 * dx, t.r0 * dy).xyz * 2.0 - 1.0;
		sum += vec2(n.x, -n.y) / max(n.z, 0.2) * t.r0 * t.w.x;
		used += t.w.x;
	}
	if (t.w.y > SKIP) {
		vec3 n = textureGrad(tex, t.uv1, t.r1 * dx, t.r1 * dy).xyz * 2.0 - 1.0;
		sum += vec2(n.x, -n.y) / max(n.z, 0.2) * t.r1 * t.w.y;
		used += t.w.y;
	}
	if (t.w.z > SKIP) {
		vec3 n = textureGrad(tex, t.uv2, t.r2 * dx, t.r2 * dy).xyz * 2.0 - 1.0;
		sum += vec2(n.x, -n.y) / max(n.z, 0.2) * t.r2 * t.w.z;
		used += t.w.z;
	}
	return sum / used;
}

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = v_world.xz;
	float dist_cam = distance(v_world, CAMERA_POSITION_WORLD);
	bool near_lod = dist_cam < normal_far;

	// Masks.
	float flower_n = fbm(p * 0.075 + 11.0) + (vnoise(p * 0.45 + 3.0) - 0.5) * 0.22;
	float flower_mask = smoothstep(0.52, 0.7, flower_n) * flower_amount;
	float plaza_d = length(p - plaza_center) + (fbm(p * 0.7 + 21.0) - 0.5) * 0.9;
	float stone_mask = 1.0 - smoothstep(plaza_radius - 0.35, plaza_radius + 0.1, plaza_d);
	flower_mask *= 1.0 - smoothstep(0.0, 1.0, stone_mask);

	// Grass base (always), flowers and stone only where their masks reach.
	vec2 uv_g = p / grass_tile;
	vec2 dxg = dFdx(uv_g);
	vec2 dyg = dFdy(uv_g);
	Tri tg = make_tri(uv_g, 1.0, 5.0);
	vec3 col = tri_color_grad(grass_albedo, tg, dxg, dyg).rgb;
	float rough = 0.9;
	vec2 slope = vec2(0.0);
	float bump = 0.6;
	if (near_lod) {
		slope = tri_slope(grass_normal, tg, dxg, dyg);
		rough = tri_rough(grass_rough, tg, dxg, dyg);
	}
	if (flower_mask > 0.003) {
		vec2 uv_f = p / flower_tile;
		vec2 dxf = dFdx(uv_f);
		vec2 dyf = dFdy(uv_f);
		Tri tf = make_tri(uv_f, 5.0, 5.0);
		vec3 fcol = tri_color_grad(flower_albedo, tf, dxf, dyf).rgb;
		col = mix(col, fcol, flower_mask);

		if (near_lod) {
			slope = mix(slope, tri_slope(flower_normal, tf, dxf, dyf), flower_mask);
			rough = mix(rough, tri_rough(flower_rough, tf, dxf, dyf), flower_mask);
		}
	}
	if (stone_mask > 0.003) {
		vec2 uv_s = p / stone_tile;
		vec2 dxs = dFdx(uv_s);
		vec2 dys = dFdy(uv_s);
		Tri ts = make_tri(uv_s, 9.0, 9.0);
		vec3 scol = tri_color_grad(stone_albedo, ts, dxs, dys).rgb;
		col = mix(col, scol, stone_mask);

		if (near_lod) {
			slope = mix(slope, tri_slope(stone_normal, ts, dxs, dys), stone_mask);
			rough = mix(rough, tri_rough(stone_rough, ts, dxs, dys), stone_mask);
			bump = mix(bump, 1.0, stone_mask);
		}
	}

	// Large-scale value + tint variation (the tile grid never lines up with it).
	float macro = fbm(p * 0.09 + 40.0) * 0.55 + fbm(p * 0.27 + 5.0) * 0.45;
	float tint_n = vnoise(p * 0.06 + 31.0);
	float plain = 1.0 - stone_mask * 0.6;
	col *= 1.0 + (macro - 0.5) * 2.0 * macro_amount * plain;
	col *= mix(vec3(1.0), mix(vec3(1.07, 1.02, 0.9), vec3(0.92, 1.0, 1.08), tint_n), tint_amount * plain);
	col *= brightness;

	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, style_ground_sat);
	col = mix(col, vec3(luma), style_desaturate);
	ALBEDO = col;
	ROUGHNESS = rough;

	// Only a gentle lean: the painting stays flat, the relief just catches the light.
	float fade_normal = 1.0 - smoothstep(normal_far * 0.6, normal_far, dist_cam);
	vec2 lean = slope * bump * normal_strength * fade_normal;
	vec3 n_world = normalize(vec3(lean.x, 1.0, lean.y));
	NORMAL = normalize((VIEW_MATRIX * vec4(n_world, 0.0)).xyz);

	// Soft edge into the hex ground beyond the test area.
	// Opaque (cheap on the iGPU): the soft edge into the hex ground is a dither.
	float fade = 1.0 - smoothstep(fade_start, fade_end, length(p - plaza_center));
	if (fade < hash21(floor(FRAGCOORD.xy))) {
		discard;
	}
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float soft = max(style_band_soft, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	float b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = mix(0.74 * b1, 0.98, b2);
	vec3 half_vec = normalize(LIGHT + VIEW);
	float glint = smoothstep(0.55, 0.9, pow(max(dot(NORMAL, half_vec), 0.0), mix(6.0, 40.0, 1.0 - ROUGHNESS))) * (1.0 - ROUGHNESS) * sheen * b2;
	DIFFUSE_LIGHT += LIGHT_COLOR * (level + glint) / PI * mix(vec3(1.0), style_highlight, b2);
}
