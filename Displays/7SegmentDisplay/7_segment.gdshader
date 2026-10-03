shader_type canvas_item;
render_mode blend_mix;

uniform vec4 digit_color : source_color;
uniform vec4 unlit_color : source_color;
uniform sampler2D texture_mask : filter_linear;
uniform int bitmask;

uniform vec2 UV_OFFSET1 = vec2(0.0);
uniform vec2 UV_SCALE1 = vec2(1.0);
uniform vec2 UV_OFFSET2 = vec2(0.0);
uniform vec2 UV_SCALE2 = vec2(1.0);
varying vec2 base_uv1;
varying vec2 base_uv2;


int decode_segment(float c) {
	return (  int(c > 0.85 && c <= 0.95) * 128
			+ int(c > 0.75 && c <= 0.85) * 64
			+ int(c > 0.65 && c <= 0.75) * 32
			+ int(c > 0.55 && c <= 0.65) * 16
			+ int(c > 0.45 && c <= 0.55) * 8
			+ int(c > 0.35 && c <= 0.45) * 4
			+ int(c > 0.25 && c <= 0.35) * 2
			+ int(c > 0.15 && c <= 0.25) * 1);
}

int decode_segment2(float c) {
	if (c > 0.95) {
		return 0;
	}
	if (c > 0.85 && c <= 0.95) {
		return 128;
	}
	else if (c > 0.75) {
		return 64;
	}
	else if (c > 0.65) {
		return 32;
	}
	else if (c > 0.55) {
		return 16;
	}
	else if (c > 0.45) {
		return 8;
	}
	else if (c > 0.35) {
		return 4;
	}
	else if (c > 0.25) {
		return 2;
	}
	else if (c > 0.15) {
		return 1;
	}
	return 0;
}

void vertex() {
	base_uv1 = vec2(UV + UV_OFFSET1) * UV_SCALE1;
	base_uv2 = vec2(UV + UV_OFFSET2) * UV_SCALE2;
}

void fragment() {
	float segment = texture(texture_mask, base_uv1).r;
	float segment_mask = texture(texture_mask, base_uv2).r;
	lowp int segment_id = decode_segment(segment_mask);
	lowp int mask = segment_id & bitmask;
	float on = float(mask != 0);
	float unlit = (1.0 - on);
	COLOR.rgba = digit_color.rgba * (on) * segment
			+ unlit_color.rgba * (unlit) * segment;
	//COLOR.rgba = vec4(vec3(segment_mask), 1.0);
}
