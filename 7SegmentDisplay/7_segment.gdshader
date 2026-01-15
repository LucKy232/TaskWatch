shader_type canvas_item;
render_mode blend_mix;

uniform vec4 digit_color : source_color;
uniform vec4 unlit_color : source_color;
uniform sampler2D texture_mask : filter_nearest;
uniform int bitmask;

int decode_segment(vec3 c) {
	return (int(c.r > 0.2) * 1 + int(c.r > 0.45) * 1 + int(c.r > 0.7) * 2
			+ int(c.g > 0.2) * 8 + int(c.g > 0.45) * 8 + int(c.g > 0.7) * 16
			+ int(c.b > 0.2) * 64 + int(c.b > 0.45) * 64);
}

void fragment() {
	vec4 segment_color = texture(texture_mask, UV).rgba;
	lowp int segment = decode_segment(segment_color.rgb);
	lowp int mask = segment & bitmask;
	float on = float(mask != 0) * (segment_color.a);
	float unlit = (1.0 - on) * (segment_color.a);
	COLOR.rgba = digit_color.rgba * (on)
			+ unlit_color.rgba * (unlit);
}
