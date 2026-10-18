shader_type canvas_item;
// Overnight Oct 17 (Phase 2 cycle 15): a picture shown inside a round medallion (the battle plate's enemy portrait).
void fragment() {
	float d = distance(UV, vec2(0.5));
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= 1.0 - smoothstep(0.47, 0.5, d);
}
