shader_type canvas_item;
render_mode blend_add;
// Overnight Nov 4-5, Part 5: the Mirrored card finish (The Shattered Gallery's prize) - a silver sheen laid over a whole card (CardView), no
// new art. A faint cool wash plus a bright band that sweeps across every few seconds.
uniform float wash = 0.06;

void fragment() {
	float band = UV.x * 0.8 + UV.y * 0.5 - mod(TIME * 0.35, 2.6) + 0.5;
	float sheen = smoothstep(0.0, 0.1, band) * (1.0 - smoothstep(0.1, 0.3, band));
	float edge = 1.0 - smoothstep(0.0, 0.08, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
	vec3 col = vec3(0.6, 0.68, 0.8) * (wash + sheen * 0.45 + edge * 0.18);
	COLOR = vec4(col, 1.0);
}
