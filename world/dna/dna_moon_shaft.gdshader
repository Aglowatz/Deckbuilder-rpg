shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;
// Overnight Nov 18 (the D.N.A. grand hall): a slanting shaft of cool moonlight from a tall window onto the marble - one additive band, soft at
// its edges and fading toward the floor, gone when the camera comes close (it never veils the hero). UV.x runs along the shaft (0 at the
// window), UV.y across it.
uniform vec4 color : source_color = vec4(0.62, 0.74, 1.0, 1.0);
uniform float strength = 0.11;
uniform float fade_near = 3.0;
uniform float fade_far = 7.0;
varying float v_fade;

void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_fade = smoothstep(fade_near, fade_far, distance(world, INV_VIEW_MATRIX[3].xyz));
}

void fragment() {
	float across = 1.0 - pow(abs(UV.y * 2.0 - 1.0), 2.0);
	float along = smoothstep(0.0, 0.12, UV.x) * (1.0 - smoothstep(0.55, 1.0, UV.x) * 0.75);
	ALBEDO = color.rgb * strength * across * along * v_fade;
}
