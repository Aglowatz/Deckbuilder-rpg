// Shared helpers of the painted texture system (docs/art/style_guide.md, "Painted textures"): noise, stochastic triangle-grid tiling (random rotation + offset per
// triangle, so no tile grid shows at any zoom), triplanar sampling, and the toon light bands used by every painted material.

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy);
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

// One triangle-grid lookup shared by every layer of a surface: per corner a random rotation and offset (metres), and the sharpened blend weights.
struct Tri {
	mat2 r0;
	mat2 r1;
	mat2 r2;
	vec2 o0;
	vec2 o1;
	vec2 o2;
	vec3 w;
};

void tri_corner(vec2 id, float salt, out mat2 rot, out vec2 offset) {
	vec2 h = hash22(id + salt);
	rot = rotation(h.x * 6.2831853);
	offset = h.yx * 53.0;
}

// `cell`: metres per triangle cell.
Tri make_tri(vec2 p, float cell, float salt, float sharp) {
	Tri t;
	vec2 skewed = mat2(vec2(1.0, 0.0), vec2(-0.57735027, 1.15470054)) * (p / cell * 3.4641016 * 0.5);
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
	tri_corner(v0, salt, t.r0, t.o0);
	tri_corner(v1, salt, t.r1, t.o1);
	tri_corner(v2, salt, t.r2, t.o2);
	t.w = pow(t.w, vec3(sharp));
	t.w /= (t.w.x + t.w.y + t.w.z);
	return t;
}

// Corners whose (sharpened) weight is negligible are not sampled: most of a triangle is one tile, so this is usually one or two taps.
const float SKIP = 0.02;

vec3 tri_color_grad(sampler2D tex, Tri t, vec2 p, vec2 dpx, vec2 dpy, float tile, bool aligned) {
	if (aligned) {
		t.r0 = mat2(1.0);
		t.r1 = mat2(1.0);
		t.r2 = mat2(1.0);
	}
	vec3 sum = vec3(0.0);
	float used = 0.0;
	if (t.w.x > SKIP) {
		sum += textureGrad(tex, (t.r0 * p + t.o0) / tile, t.r0 * dpx / tile, t.r0 * dpy / tile).rgb * t.w.x;
		used += t.w.x;
	}
	if (t.w.y > SKIP) {
		sum += textureGrad(tex, (t.r1 * p + t.o1) / tile, t.r1 * dpx / tile, t.r1 * dpy / tile).rgb * t.w.y;
		used += t.w.y;
	}
	if (t.w.z > SKIP) {
		sum += textureGrad(tex, (t.r2 * p + t.o2) / tile, t.r2 * dpx / tile, t.r2 * dpy / tile).rgb * t.w.z;
		used += t.w.z;
	}
	return sum / used;
}

// Normal+roughness pack (R,G = tangent normal xy, B = roughness): returns vec3(slope x, slope z, roughness) after undoing each tile's rotation.
vec3 tri_nr_grad(sampler2D tex, Tri t, vec2 p, vec2 dpx, vec2 dpy, float tile, bool aligned) {
	if (aligned) {
		t.r0 = mat2(1.0);
		t.r1 = mat2(1.0);
		t.r2 = mat2(1.0);
	}
	vec3 sum = vec3(0.0);
	float used = 0.0;
	if (t.w.x > SKIP) {
		vec3 n = textureGrad(tex, (t.r0 * p + t.o0) / tile, t.r0 * dpx / tile, t.r0 * dpy / tile).rgb;
		sum += vec3(((n.xy * 2.0 - 1.0) * vec2(1.0, -1.0)) * t.r0, n.z) * t.w.x;
		used += t.w.x;
	}
	if (t.w.y > SKIP) {
		vec3 n = textureGrad(tex, (t.r1 * p + t.o1) / tile, t.r1 * dpx / tile, t.r1 * dpy / tile).rgb;
		sum += vec3(((n.xy * 2.0 - 1.0) * vec2(1.0, -1.0)) * t.r1, n.z) * t.w.y;
		used += t.w.y;
	}
	if (t.w.z > SKIP) {
		vec3 n = textureGrad(tex, (t.r2 * p + t.o2) / tile, t.r2 * dpx / tile, t.r2 * dpy / tile).rgb;
		sum += vec3(((n.xy * 2.0 - 1.0) * vec2(1.0, -1.0)) * t.r2, n.z) * t.w.z;
		used += t.w.z;
	}
	return sum / used;
}

// Triplanar albedo (two taps at most: the dominant axes), `p` in metres, `tile` metres per texture repeat.
vec3 triplanar_color(sampler2D tex, vec3 p, vec3 n, float tile) {
	vec3 w = pow(abs(n), vec3(6.0));
	w /= (w.x + w.y + w.z);
	vec3 col = vec3(0.0);
	float used = 0.0;
	if (w.x > 0.04) {
		col += texture(tex, p.zy / tile).rgb * w.x;
		used += w.x;
	}
	if (w.y > 0.04) {
		col += texture(tex, p.xz / tile + 0.37).rgb * w.y;
		used += w.y;
	}
	if (w.z > 0.04) {
		col += texture(tex, p.xy / tile + 0.71).rgb * w.z;
		used += w.z;
	}
	return col / max(used, 0.001);
}

// The game's banded toon light (same constants as style_toon / style_terrain), plus an optional faint sheen from roughness.
vec3 toon_bands(vec3 light_color, float t, float soft_amount, vec3 highlight, float band_mid, float band_lit, out float b2) {
	float soft = max(soft_amount, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = mix(band_mid * b1, band_lit, b2);
	return light_color * level / PI * mix(vec3(1.0), highlight, b2);
}
