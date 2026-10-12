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
uniform vec4 shadow_color : source_color = vec4(0.14, 0.08, 0.24, 0.34);
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	float x = VERTEX.x * card_size.x * stretch.x;
	float y = max((VERTEX.y * card_size.y - feet_lift) * stretch.y, 0.0);
	vec3 world = MODEL_MATRIX[3].xyz + right * x + vec3(shadow_ground.x, 0.0, shadow_ground.y) * y + vec3(0.0, 0.035, 0.0);
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
