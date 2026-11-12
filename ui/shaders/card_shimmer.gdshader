shader_type canvas_item;
render_mode blend_add;
// Fable Nov 12 (Part 3): one bright band that crosses a card once (a buff shimmer). `progress` runs 0..1 (tweened), then the rect is freed.
uniform vec4 tint : source_color = vec4(0.62, 0.9, 0.64, 1.0);
uniform float progress = 0.0;

void fragment() {
	float band = UV.x * 0.7 + (1.0 - UV.y) * 0.5 - progress * 1.6 + 0.2;
	float sheen = smoothstep(-0.14, 0.0, band) * (1.0 - smoothstep(0.0, 0.14, band));
	COLOR = vec4(tint.rgb * sheen * 0.75, 1.0);
}
