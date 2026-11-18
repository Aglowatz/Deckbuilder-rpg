shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, diffuse_lambert, specular_disabled;
// Overnight Nov 18 (the D.N.A. grand hall): a painted card that turns to face the camera round the vertical axis - chandeliers (hanging from
// their top, swaying very slightly), the hall's columns and the lobby clock (standing on their foot). The node's origin is the pivot (the
// chain's end for a chandelier, the foot for a column). The card fades out when the camera comes close, so nothing hanging or standing ever
// fills the view in front of the hero. `emission` lifts the painted candles and ghost flames (the bright, warm or green parts).
global uniform float style_desaturate;
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float sway_amp = 0.0;
uniform float sway_speed = 0.6;
uniform float sway_phase = 0.0;
uniform float fade_near = 4.0;
uniform float fade_far = 8.0;
uniform float emission = 0.0;
uniform float brightness = 1.0;
varying float v_fade;

void vertex() {
	float angle = sway_amp * sin(TIME * sway_speed + sway_phase);
	float c = cos(angle);
	float s = sin(angle);
	VERTEX.xy = vec2(c * VERTEX.x - s * VERTEX.y, s * VERTEX.x + c * VERTEX.y);
	vec3 origin = MODEL_MATRIX[3].xyz;
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz));
	vec3 fwd = normalize(cross(right, vec3(0.0, 1.0, 0.0)));
	vec3 scale = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), 1.0);
	vec3 world = origin + right * VERTEX.x * scale.x + vec3(0.0, 1.0, 0.0) * VERTEX.y * scale.y;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	VERTEX = world;
	NORMAL = -fwd;
	// the distance to the card's nearest point on its vertical span (a column's foot is far below a high camera)
	v_fade = smoothstep(fade_near, fade_far, length(vec2(origin.x - cam.x, origin.z - cam.z)));
}

void fragment() {
	vec4 t = texture(albedo_tex, UV);
	if (t.a < 0.3) {
		discard;
	}
	vec3 c = t.rgb * brightness;
	ALBEDO = mix(c, vec3(dot(c, vec3(0.299, 0.587, 0.114))), style_desaturate * 0.35);
	float lum = max(max(t.r, t.g), t.b);
	EMISSION = t.rgb * emission * smoothstep(0.62, 0.95, lum);
	ALPHA = smoothstep(0.3, 0.6, t.a) * v_fade;
}
