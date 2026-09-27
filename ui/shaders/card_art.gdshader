shader_type canvas_item;
// Placeholder card art background: gradient + soft glow + faint diagonal sheen + vignette.
uniform vec4 top : source_color = vec4(0.6, 0.3, 0.2, 1.0);
uniform vec4 bottom : source_color = vec4(0.15, 0.08, 0.1, 1.0);
uniform vec4 glow : source_color = vec4(1.0, 0.8, 0.5, 1.0);

void fragment() {
	vec4 c = mix(top, bottom, smoothstep(0.0, 1.0, UV.y));
	float d = distance(UV, vec2(0.5, 0.45));
	c.rgb += glow.rgb * (1.0 - smoothstep(0.0, 0.55, d)) * 0.35;
	float sheen = smoothstep(0.0, 1.0, sin((UV.x + UV.y) * 9.0) * 0.5 + 0.5);
	c.rgb += vec3(0.03) * sheen;
	float edge = smoothstep(0.35, 0.75, d);
	c.rgb *= 1.0 - edge * 0.35;
	COLOR = vec4(c.rgb, 1.0);
}
