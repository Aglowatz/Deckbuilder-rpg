shader_type canvas_item;
// Soft vertical gradient with a warm glow, used for menu backgrounds.
uniform vec4 top : source_color = vec4(0.10, 0.07, 0.17, 1.0);
uniform vec4 bottom : source_color = vec4(0.32, 0.17, 0.20, 1.0);
uniform vec4 glow : source_color = vec4(0.95, 0.62, 0.28, 1.0);
uniform vec2 glow_pos = vec2(0.5, 0.95);
uniform float glow_size = 0.7;

void fragment() {
	vec4 c = mix(top, bottom, smoothstep(0.0, 1.0, UV.y));
	float g = 1.0 - smoothstep(0.0, glow_size, distance(UV * vec2(1.6, 1.0), glow_pos * vec2(1.6, 1.0)));
	c.rgb += glow.rgb * g * g * 0.45;
	COLOR = c;
}
