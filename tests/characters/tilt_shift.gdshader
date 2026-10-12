shader_type canvas_item;
// Tilt-shift: a sharp horizontal band around `focus_y` (screen fraction), blurring towards the top and bottom of the screen.
// Drawn on a CanvasLayer under the HUD, so the interface stays sharp.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float focus_y = 0.55;
uniform float band = 0.13;
uniform float falloff = 0.34;
uniform float max_radius_px = 9.0;
uniform float amount : hint_range(0.0, 1.0) = 1.0;

const int TAPS = 14;
const float GOLDEN = 2.399963;

void fragment() {
	float d = max(abs(SCREEN_UV.y - focus_y) - band, 0.0) / falloff;
	float k = smoothstep(0.0, 1.0, clamp(d, 0.0, 1.0)) * amount;
	if (k < 0.01) {
		COLOR = vec4(textureLod(screen_tex, SCREEN_UV, 0.0).rgb, 1.0);
	} else {
		vec2 px = SCREEN_PIXEL_SIZE * max_radius_px * k;
		vec3 sum = vec3(0.0);
		float wsum = 0.0;
		for (int i = 0; i < TAPS; i++) {
			float r = sqrt((float(i) + 0.5) / float(TAPS));
			float a = float(i) * GOLDEN;
			vec2 off = vec2(cos(a), sin(a)) * r * px;
			sum += textureLod(screen_tex, SCREEN_UV + off, k * 1.2).rgb;
			wsum += 1.0;
		}
		COLOR = vec4(sum / wsum, 1.0);
	}
}
