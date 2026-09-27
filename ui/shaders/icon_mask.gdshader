shader_type canvas_item;
// game-icons.net SVGs are white glyphs on a black square: use the brightness as the alpha
// and paint the glyph with `tint`.
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	COLOR = vec4(tint.rgb, t.r * tint.a);
}
