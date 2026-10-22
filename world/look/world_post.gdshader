shader_type canvas_item;
// World Look Test post pass (docs/art/world_look_test.md): tilt-shift blur, warm colour grade and vignette in ONE full-screen pass under the HUD.
//  - a sharp horizontal band centred on `focus_y` (screen fraction, 0 = top); blur grows towards the top (far) and bottom (near)
//  - `blur_far` / `blur_near` are the largest blur radius in pixels at the screen edge. Cheap on purpose: 8 jittered taps of the plain screen texture (no mip chain: generating the
//    screen mipmaps every frame cost about 2 ms on the iGPU, the whole pass now costs about 1 ms)
//  - grade: warmth (-1..1), saturation, vignette strength

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float focus_y = 0.58;
uniform float band = 0.12;
uniform float falloff = 0.36;
uniform float blur_far = 7.0;
uniform float blur_near = 6.0;
uniform float warmth = 0.25;
uniform float saturation = 1.08;
uniform float vignette = 0.28;
uniform float contrast = 1.04;
// Per-area palette (zone_looks.json "look"): soften the loudest greens and reds so nothing outshouts the characters. 0 = off.
uniform float green_calm = 0.0;
uniform float red_calm = 0.0;
// Graphics Tier 1 (docs/art/graphics_tier1.md, Part 2): the per-zone grade on top of the warmth - a split tint (the shadows lean one way, the highlights
// another: Crosspath violet shadows under gold highlights) and a gamma. White / white / 1.0 = no change.
uniform vec3 shadow_tint : source_color = vec3(1.0);
uniform vec3 highlight_tint : source_color = vec3(1.0);
uniform float gamma = 1.0;

const int TAPS = 8;
const float GOLDEN = 2.399963;

void fragment() {
	vec2 uv = SCREEN_UV;
	float d = uv.y - focus_y;
	float k = smoothstep(0.0, 1.0, clamp((abs(d) - band) / falloff, 0.0, 1.0));
	float radius = k * (d < 0.0 ? blur_far : blur_near);
	vec3 col;
	if (radius < 0.35) {
		col = textureLod(screen_tex, uv, 0.0).rgb;
	} else {
		vec2 px = SCREEN_PIXEL_SIZE * radius;
		float lod = 0.0;
		float jitter = fract(52.9829189 * fract(dot(FRAGCOORD.xy, vec2(0.06711056, 0.00583715)))) * 6.2831;
		vec3 sum = vec3(0.0);
		for (int i = 0; i < TAPS; i++) {
			float r = sqrt((float(i) + 0.5) / float(TAPS));
			float a = float(i) * GOLDEN + jitter;
			sum += textureLod(screen_tex, uv + vec2(cos(a), sin(a)) * r * px, lod).rgb;
		}
		col = sum / float(TAPS);
	}
	// Warm golden grade: push red up and blue down, a little more in the highlights.
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	vec3 warm = vec3(1.0 + 0.11 * warmth, 1.0 + 0.025 * warmth, 1.0 - 0.15 * warmth);
	col *= mix(vec3(1.0), warm, 0.6 + 0.4 * luma);
	luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, saturation);
	if (green_calm > 0.0 || red_calm > 0.0) {
		float mx = max(col.r, max(col.g, col.b));
		float mn = min(col.r, min(col.g, col.b));
		float chroma = mx - mn;
		float sat = chroma / max(mx, 0.001);
		float hue = 0.0;
		if (chroma > 0.001) {
			if (mx == col.r) {
				hue = mod((col.g - col.b) / chroma, 6.0) / 6.0;
			} else if (mx == col.g) {
				hue = ((col.b - col.r) / chroma + 2.0) / 6.0;
			} else {
				hue = ((col.r - col.g) / chroma + 4.0) / 6.0;
			}
		}
		float w_green = smoothstep(0.17, 0.25, hue) * (1.0 - smoothstep(0.42, 0.5, hue));
		float w_red = (1.0 - smoothstep(0.0, 0.05, hue)) + smoothstep(0.94, 1.0, hue);
		float loud = smoothstep(0.35, 0.8, sat);
		float calm = clamp((green_calm * w_green + red_calm * clamp(w_red, 0.0, 1.0)) * loud, 0.0, 0.9);
		col = mix(col, vec3(dot(col, vec3(0.299, 0.587, 0.114))) * 1.02 + col * 0.0, calm);
	}
	if (gamma != 1.0) {
		col = pow(max(col, vec3(0.0)), vec3(1.0 / gamma));
	}
	float split = smoothstep(0.12, 0.8, dot(col, vec3(0.299, 0.587, 0.114)));
	col *= mix(shadow_tint, highlight_tint, split);
	col = (col - 0.5) * contrast + 0.5;
	vec2 c = (uv - 0.5) * vec2(1.0, 0.8);
	col *= 1.0 - vignette * smoothstep(0.28, 0.78, length(c));
	COLOR = vec4(col, 1.0);
}
