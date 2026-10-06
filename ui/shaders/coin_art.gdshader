shader_type canvas_item;
// Token art on a table coin or tile: the centre square of the 2:3 art, clipped to a circle or a rounded square.
uniform float corner : hint_range(0.0, 0.5) = 0.5;

void fragment() {
	vec2 p = abs(UV - vec2(0.5));
	vec2 q = p - vec2(0.5 - corner);
	float d = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - corner;
	// The art is 2:3; show its middle square (the subject sits upper-middle, so bias slightly up).
	vec2 uv = vec2(UV.x, 0.08 + UV.y * (2.0 / 3.0) * 1.0 + 0.0);
	vec4 c = texture(TEXTURE, uv);
	COLOR = vec4(c.rgb, c.a * (1.0 - smoothstep(-0.01, 0.0, d)));
}
