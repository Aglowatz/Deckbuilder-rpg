shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;
// The ground shadow of a WorldSprite card (docs/art/world_look_test.md): the card's own silhouette sheared flat along the sun's direction, soft and violet,
// so the figure stands in the world instead of floating over it. Used as the sprite material's next pass.

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_disable;
uniform bool flip_h = false;
uniform vec2 card_size = vec2(1.0, 1.5);
uniform float feet_lift = 0.03;
uniform vec2 stretch = vec2(1.0, 1.0);
// Ground displacement per metre of height (points away from the sun; its length is 1 / tan(sun elevation)).
uniform vec2 shadow_ground = vec2(0.6, -0.8);
uniform vec4 shadow_color : source_color = vec4(0.14, 0.08, 0.24, 0.38);
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	// Graphics Tier 1: the silhouette is laid along the sun's ground direction with its width ACROSS that direction (as if the card faced the sun), so a side light
	// no longer collapses the figure into a line: the shadow is always the whole figure, like the shadow map's.
	vec2 along = shadow_ground;
	float along_len = max(length(along), 0.001);
	vec2 across = vec2(-along.y, along.x) / along_len;
	float x = VERTEX.x * card_size.x * stretch.x;
	float y = max((VERTEX.y * card_size.y - feet_lift) * stretch.y, 0.0);
	vec3 world = MODEL_MATRIX[3].xyz + vec3(across.x, 0.0, across.y) * x + vec3(along.x, 0.0, along.y) * y + vec3(0.0, 0.085, 0.0);
	// The vertex stage works in model space here: undo the model matrix so the engine's own transform lands on `world`.
	VERTEX = (inverse(MODEL_MATRIX) * vec4(world, 1.0)).xyz;
}

void fragment() {
	vec2 uv = UV;
	if (flip_h) {
		uv.x = 1.0 - uv.x;
	}
	float a = textureLod(tex, uv, 2.5).a;
	ALBEDO = shadow_color.rgb;
	ALPHA = a * shadow_color.a * fade;
}
