shader_type canvas_item;
// Darkens the screen edges; draws over a full-screen ColorRect.
uniform float strength : hint_range(0.0, 1.5) = 0.75;
uniform float softness : hint_range(0.1, 1.5) = 0.75;
uniform vec4 tint : source_color = vec4(0.03, 0.02, 0.06, 1.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	uv.x *= 1.2;
	float d = length(uv);
	float v = smoothstep(0.25, 0.25 + softness, d) * strength;
	COLOR = vec4(tint.rgb, clamp(v, 0.0, 1.0));
}
