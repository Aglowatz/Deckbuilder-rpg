shader_type spatial;
render_mode unshaded, cull_disabled;
// game-icons.net SVGs are white glyphs on a black square: use the brightness as the alpha and paint the glyph with `tint`
// (the 3D twin of ui/shaders/icon_mask.gdshader). The town camera always looks north, so a quad facing south needs no billboard.
uniform sampler2D icon_texture : source_color;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	float a = texture(icon_texture, UV).r;
	ALBEDO = tint.rgb;
	ALPHA = a * tint.a;
	ALPHA_SCISSOR_THRESHOLD = 0.35;
}
