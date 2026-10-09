shader_type canvas_item;
// Clips what a Control draws to a circle (the minimap inside UI-MINIMAP-FRAME): `center` and `radius` are in the control's own pixels.
uniform vec2 center = vec2(125.0, 125.0);
uniform float radius = 88.0;
varying vec2 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	float d = length(local_position - center);
	COLOR.a *= 1.0 - smoothstep(radius - 1.5, radius, d);
}
