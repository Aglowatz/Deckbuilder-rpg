shader_type canvas_item;
// Overnight Oct 17 (Phase 2 cycle 11): the dungeon map's side bands show a dark, soft copy of the map instead of flat black.
uniform float blur_lod = 4.5;
uniform vec4 shade : source_color = vec4(0.30, 0.27, 0.33, 1.0);

void fragment() {
	COLOR = textureLod(TEXTURE, UV, blur_lod) * shade;
}
