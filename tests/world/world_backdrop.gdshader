shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled;
// A painted distant-scenery layer (WorldScenery): a ring (or a flat landmark card) of one backdrop image. Atmospheric perspective is done here, not by the scene fog:
// the farther the layer, the more it is pulled towards a cool lavender and then the horizon haze, and its base always dissolves into the haze a little.

uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 haze : source_color = vec3(0.95, 0.81, 0.62);
uniform vec3 cool : source_color = vec3(0.6, 0.66, 0.88);
uniform float cool_amount : hint_range(0.0, 1.0) = 0.3;
uniform float haze_amount : hint_range(0.0, 1.0) = 0.4;
uniform float base_haze : hint_range(0.0, 1.0) = 0.35;
uniform float brightness = 1.0;

void fragment() {
	vec4 c = texture(tex, UV);
	vec3 col = c.rgb * brightness;
	col = mix(col, cool, cool_amount);
	// UV.y runs 0 at the top of the layer to 1 at its base.
	float base = smoothstep(0.55, 1.0, UV.y) * base_haze;
	col = mix(col, haze, clamp(haze_amount + base, 0.0, 1.0));
	ALBEDO = col;
	ALPHA = c.a;
}
