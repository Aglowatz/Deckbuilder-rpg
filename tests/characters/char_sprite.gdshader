shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled, depth_prepass_alpha;
// Character look test (docs/art/character_test.md): a camera-facing character card.
//  - pixel = true : nearest-neighbour pixel art (HD-2D look), hard alpha, unlit by default.
//  - pixel = false: smooth painted art with scene-reactive light: the card is lit by the real sun and lamps (so it takes the local light colour
//    and goes dark in shadow) through the light() function below, like a toon material does.

uniform sampler2D tex_smooth : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D tex_pixel : source_color, filter_nearest_mipmap, repeat_disable;
uniform bool pixel = false;
uniform bool flip_h = false;
// 0 = flat (unlit), 1 = fully lit by the scene.
uniform float react : hint_range(0.0, 1.0) = 1.0;
uniform float world_scale = 1.0;
uniform float stretch = 1.0;
uniform vec3 tint : source_color = vec3(1.0);

void vertex() {
	// Full billboard: the card always faces the camera, so proportions are right at any camera pitch. Feet stay on the node origin.
	VERTEX.xy *= world_scale * vec2(1.0, stretch);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 uv = UV;
	if (flip_h) {
		uv.x = 1.0 - uv.x;
	}
	vec4 c = pixel ? texture(tex_pixel, uv) : texture(tex_smooth, uv);
	if (pixel) {
		if (c.a < 0.5) {
			discard;
		}
		ALPHA = 1.0;
	} else {
		ALPHA = c.a;
		ALPHA_SCISSOR_THRESHOLD = 0.62;
	}
	vec3 col = c.rgb * tint;
	ALBEDO = col * react;
	EMISSION = col * (1.0 - react);
	ROUGHNESS = 1.0;
	// A card facing the camera would be lit edge-on by a high sun: lean its normal towards the sky.
	vec3 up_view = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	NORMAL = normalize(mix(NORMAL, up_view, 0.55));
}

void light() {
	float ndl = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0);
	// ATTENUATION carries the shadow-map result, so a card inside a building's shadow loses the sun, and lamp pools tint it.
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * smoothstep(0.1, 0.9, ndl) * 0.98 / PI;
}
