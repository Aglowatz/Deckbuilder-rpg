shader_type canvas_item;
// Shows a texture only inside the circle that touches the middle of its four sides (a medallion cut out of an image), with a soft edge.
void fragment() {
	float d = distance(UV, vec2(0.5));
	COLOR.a *= 1.0 - smoothstep(0.47, 0.5, d);
}
