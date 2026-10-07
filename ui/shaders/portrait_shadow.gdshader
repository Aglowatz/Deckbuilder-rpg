shader_type canvas_item;
// A soft drop shadow for a dialogue portrait: blurs the portrait's alpha, shifts it down and aside, and tints it black. Drawn on a ColorRect that is
// `pad` pixels bigger than the portrait on every side, so the shadow can leave the silhouette.

uniform sampler2D portrait : filter_linear, repeat_disable;
uniform vec2 rect_size = vec2(576.0, 832.0);
uniform vec2 image_size = vec2(512.0, 768.0);
uniform float pad = 32.0;
uniform float blur = 12.0;
uniform vec2 offset_px = vec2(9.0, 7.0);
uniform float strength = 0.45;
uniform bool flip = false;

float coverage(vec2 point_px) {
	vec2 uv = (point_px - vec2(pad)) / image_size;
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		return 0.0;
	}
	if (flip) {
		uv.x = 1.0 - uv.x;
	}
	return texture(portrait, uv).a;
}

void fragment() {
	vec2 here = UV * rect_size;
	float total = coverage(here - offset_px);
	for (int i = 0; i < 8; i++) {
		float angle = float(i) * 0.785398;
		vec2 dir = vec2(cos(angle), sin(angle));
		total += coverage(here - offset_px + dir * blur);
		total += coverage(here - offset_px + dir * blur * 0.5);
	}
	COLOR = vec4(0.0, 0.0, 0.0, total / 17.0 * strength);
}
