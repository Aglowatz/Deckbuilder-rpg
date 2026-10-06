shader_type spatial;
// A soft slanted shaft of light through the canopy: additive, no hard edge (fresnel-faded sides, fades out at both ends), slow shimmer.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, fog_disabled;

uniform vec4 tint : source_color = vec4(1.0, 0.92, 0.62, 1.0);
uniform float strength = 0.11;
uniform float half_height = 6.0;
uniform float phase = 0.0;

varying float along;

void vertex() {
	along = clamp(VERTEX.y / (half_height * 2.0) + 0.5, 0.0, 1.0);
}

void fragment() {
	float side = pow(clamp(abs(dot(normalize(NORMAL), normalize(VIEW))), 0.0, 1.0), 1.6);
	float ends = smoothstep(0.0, 0.3, along) * (1.0 - smoothstep(0.78, 1.0, along));
	float shimmer = 0.78 + 0.22 * sin(TIME * 0.55 + phase) * sin(TIME * 0.23 + phase * 1.7);
	ALBEDO = tint.rgb;
	ALPHA = strength * side * ends * shimmer;
}
