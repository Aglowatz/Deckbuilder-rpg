shader_type canvas_item;
// World Look Test post pass (docs/art/world_look_test.md): tilt-shift blur, warm colour grade and vignette in ONE full-screen pass under the HUD.
//  - a sharp horizontal band centred on `focus_y` (screen fraction, 0 = top); blur grows towards the top (far) and bottom (near)
//  - `blur_far` / `blur_near` are the largest blur radius in pixels at the screen edge; the blur reads the screen's mip chain, so few taps are needed
//  - grade: warmth (-1..1), saturation, vignette strength

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float focus_y = 0.58;
uniform float band = 0.12;
uniform float falloff = 0.36;
uniform float blur_far = 7.0;
uniform float blur_near = 6.0;
uniform float warmth = 0.25;
uniform float saturation = 1.08;
uniform float vignette = 0.28;
uniform float contrast = 1.04;

const int TAPS = 10;
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
		float lod = clamp(log2(radius) - 1.4, 0.0, 4.0);
		vec3 sum = vec3(0.0);
		for (int i = 0; i < TAPS; i++) {
			float r = sqrt((float(i) + 0.5) / float(TAPS));
			float a = float(i) * GOLDEN;
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
	col = (col - 0.5) * contrast + 0.5;
	vec2 c = (uv - 0.5) * vec2(1.0, 0.8);
	col *= 1.0 - vignette * smoothstep(0.28, 0.78, length(c));
	COLOR = vec4(col, 1.0);
}
