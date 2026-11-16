shader_type spatial;
render_mode unshaded, cull_back, depth_draw_never, shadows_disabled;
// Fable Nov 16c: the faint outline of a Path's icon on a locked seal of the Four Seals (FourSealVault): the icon's silhouette as a
// pale line with a very faint fill, no colour of its own, so it reads as a mark stamped in the iron behind the padlock.

uniform sampler2D icon : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 tint : source_color = vec4(0.86, 0.84, 0.78, 1.0);
uniform float line = 0.55;
uniform float fill = 0.16;
uniform float width = 0.022;

void fragment() {
	float inside = texture(icon, UV).a;
	float around = 0.0;
	for (int i = 0; i < 8; i++) {
		float angle = float(i) * 0.7853982;
		around = max(around, texture(icon, UV + vec2(cos(angle), sin(angle)) * width).a);
	}
	float edge = clamp(around - inside, 0.0, 1.0);
	ALBEDO = tint.rgb;
	ALPHA = clamp(edge * line + inside * fill, 0.0, 1.0);
}
