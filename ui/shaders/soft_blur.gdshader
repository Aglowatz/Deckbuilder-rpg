shader_type canvas_item;
// Fable Nov 16b (Part 2): a soft blur for a picture used as a backdrop behind a game table (a zone's loading painting behind a card
// minigame), with a tint over it so the table in front reads.

uniform float radius = 5.0;
uniform vec4 shade : source_color = vec4(0.04, 0.03, 0.07, 0.35);

void fragment() {
	vec2 step_size = TEXTURE_PIXEL_SIZE * radius;
	vec4 sum = vec4(0.0);
	for (int x = -3; x <= 3; x++) {
		for (int y = -3; y <= 3; y++) {
			sum += texture(TEXTURE, UV + vec2(float(x), float(y)) * step_size);
		}
	}
	vec4 blurred = sum / 49.0;
	COLOR = vec4(mix(blurred.rgb, shade.rgb, shade.a), 1.0);
}
