shader_type canvas_item;
// Recolours the cloth ribbons and glow of a card frame (UI-FRAME-MULTI, -INF, -TOKEN) to the card's Paths. The gold trim, wood and iron keep their colour: a pixel
// counts as cloth when it is saturated and its hue is away from the gold (about 42 degrees). Four corner colours are blended smoothly over the frame, so a
// four-Path card shows four bands and a one-Path card one colour. `cream_cloth` also catches the pale cloth of the lower-left band (MULTI only).
uniform vec4 top_left : source_color = vec4(1.0);
uniform vec4 top_right : source_color = vec4(1.0);
uniform vec4 bottom_left : source_color = vec4(1.0);
uniform vec4 bottom_right : source_color = vec4(1.0);
uniform float strength : hint_range(0.0, 1.0) = 1.0;
uniform float cream_cloth : hint_range(0.0, 1.0) = 0.0;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 hsv = rgb2hsv(c.rgb);
	float hue_gap = abs(hsv.x - 0.117);
	hue_gap = min(hue_gap, 1.0 - hue_gap);
	float cloth = smoothstep(0.2, 0.38, hsv.y) * smoothstep(0.035, 0.085, hue_gap);
	// Pale cloth: low saturation but bright, only in the lower-left strip where MULTI has its cream band.
	float strip = (1.0 - smoothstep(0.14, 0.2, UV.x)) * smoothstep(0.4, 0.5, UV.y);
	float pale = cream_cloth * strip * (1.0 - smoothstep(0.12, 0.3, hsv.y)) * smoothstep(0.62, 0.8, hsv.z) * smoothstep(0.03, 0.06, hsv.y + 0.03);
	float mask = clamp(max(cloth, pale), 0.0, 1.0) * strength;
	vec3 target = mix(mix(top_left.rgb, top_right.rgb, UV.x), mix(bottom_left.rgb, bottom_right.rgb, UV.x), UV.y);
	float luma = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	float target_luma = max(dot(target, vec3(0.299, 0.587, 0.114)), 0.12);
	vec3 tinted = clamp(target * (luma / target_luma) * 1.05, 0.0, 1.0);
	COLOR = vec4(mix(c.rgb, tinted, mask), c.a);
}
