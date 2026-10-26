shader_type spatial;
render_mode unshaded, cull_disabled;
#include "res://assets/shaders/style_wind.gdshaderinc"
// Painted foliage cards for the World Look Test (WorldFoliage, one MultiMesh): each instance is an upright camera-facing card (it turns round the vertical axis only)
// showing one cell of the 3 x 2 atlas (grass, grass with seed heads, wildflowers, tall flowers, bush, fern). Wind bends the top of every card; a slow gust travels across the field.
// Lighting is faked (ambient + sun colour, darker at the base) so a thousand cards cost nothing, and the colour follows the town's light.
// Instance custom data: x = atlas cell, y = phase, z = tint variation, w = unused.

global uniform float style_wind;
uniform sampler2D atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform vec3 light_color : source_color = vec3(1.0, 0.92, 0.78);
uniform vec3 ambient_color : source_color = vec3(0.55, 0.6, 0.78);
uniform float wind_strength = 0.09;
uniform float wind_speed = 1.5;
uniform vec3 mood_tint : source_color = vec3(1.0);
// A dry, sun-bleached mood (the Gainlands v2 scrub): mix the painted green towards straw by its brightness. 0 = off (every other zone).
uniform float dry_amount = 0.0;
uniform vec3 dry_color : source_color = vec3(0.86, 0.72, 0.42);

varying float v_cell;
varying float v_tint;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float sx = length(MODEL_MATRIX[0].xyz);
	float sy = length(MODEL_MATRIX[1].xyz);
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	float h = clamp(VERTEX.y, 0.0, 1.0);
	float phase = INSTANCE_CUSTOM.y * 6.2831;
	// Tier 2: the zone's shared gust front (and its wind global), with the card's own flutter on top.
	float gust = style_wind_gust(origin.xz, TIME);
	float sway = (sin(TIME * wind_speed + phase + origin.x * 0.4 + origin.z * 0.3) * 0.6 + gust * 0.9 - 0.3) * wind_strength * style_wind;
	vec3 world = origin + right * (VERTEX.x * sx + sway * h * h * sy) + vec3(0.0, VERTEX.y * sy, 0.0);
	v_cell = INSTANCE_CUSTOM.x;
	v_tint = INSTANCE_CUSTOM.z;
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world, 1.0);
}

void fragment() {
	float cell = floor(v_cell + 0.5);
	vec2 uv = vec2((mod(cell, 3.0) + UV.x) / 3.0, (floor(cell / 3.0) + UV.y) / 2.0);
	vec4 c = texture(atlas, uv);
	if (c.a < 0.45) {
		discard;
	}
	// Darker towards the roots (UV.y = 1 is the base), a touch of per-card colour variation.
	float base = smoothstep(1.0, 0.55, UV.y);
	vec3 tint = mix(vec3(0.93, 1.0, 0.92), vec3(1.06, 1.0, 0.9), v_tint);
	vec3 lit = ambient_color * 0.55 + light_color * 0.62;
	vec3 painted = mix(c.rgb, dry_color * (0.45 + dot(c.rgb, vec3(0.3, 0.59, 0.11)) * 1.1), dry_amount);
	ALBEDO = painted * tint * mood_tint * lit * mix(0.62, 1.0, base);
	ALPHA = 1.0;
}
