shader_type canvas_item;
// Noise-threshold dissolve with a glowing edge. Used on a CanvasGroup around a card.
uniform sampler2D noise;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color : source_color = vec4(1.0, 0.7, 0.3, 1.0);

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float n = texture(noise, UV * 2.0).r;
	float threshold = progress * 1.25 - 0.1;
	float edge = smoothstep(threshold - 0.08, threshold, n) - smoothstep(threshold, threshold + 0.1, n);
	float alive = step(threshold, n);
	vec3 rgb = mix(base.rgb, edge_color.rgb, clamp(edge * 2.0, 0.0, 1.0));
	COLOR = vec4(rgb, base.a * max(alive, edge));
}
