shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_back;
// Baked-look ambient occlusion for the kit (Part D): a soft, cool dark pool laid on the ground under buildings and props so corners, the foot of a wall and the space between
// props are darker without SSAO (which only runs on High). `round_shape` = a circle (props), otherwise a rounded rectangle (building footprints). One draw, no lights, no texture.

uniform vec2 half_size = vec2(3.0, 2.5);   // the footprint's half extents (the dark is full inside)
uniform float margin = 0.9;                // how far it fades out beyond the footprint (m)
uniform float strength = 0.38;
uniform vec3 shade : source_color = vec3(0.16, 0.1, 0.22);
uniform bool round_shape = false;

varying vec2 v_local;

void vertex() {
	v_local = VERTEX.xz;
}

void fragment() {
	float d;
	if (round_shape) {
		d = length(v_local) - half_size.x;
	} else {
		vec2 q = abs(v_local) - half_size;
		d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
	}
	float a = (1.0 - smoothstep(0.0, margin, d)) * strength;
	ALBEDO = shade;
	ALPHA = a;
}
