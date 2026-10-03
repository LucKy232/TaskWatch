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
	return (  int(c > 0.875 && c < 0.925) * 16384		// Target 0.900 DecimalPoint
			+ int(c > 0.825 && c < 0.875) * 8192		// Target 0.850	Middle-BottomRight
			+ int(c > 0.775 && c < 0.825) * 4096		// Target 0.800 Middle-Down
			+ int(c > 0.725 && c < 0.775) * 2048		// Target 0.750 Middle-BottomLeft
			+ int(c > 0.675 && c < 0.725) * 1024		// Target 0.700 Middle-TopRight
			+ int(c > 0.625 && c < 0.675) * 512		// Target 0.650 Middle-Top
			+ int(c > 0.575 && c < 0.625) * 256		// Target 0.600 Middle-TopLeft
			+ int(c > 0.525 && c < 0.575) * 128		// Target 0.550 Middle-Right
			+ int(c > 0.475 && c < 0.525) * 64			// Target 0.500 Middle-Left
			+ int(c > 0.425 && c < 0.475) * 32			// Target 0.450 Top-Left
			+ int(c > 0.375 && c < 0.425) * 16			// Target 0.400 Bottom-Left
			+ int(c > 0.325 && c < 0.375) * 8			// Target 0.350 Bottom
			+ int(c > 0.275 && c < 0.325) * 4			// Target 0.300 Bottom-Right
			+ int(c > 0.225 && c < 0.275) * 2			// Target 0.250 Top-Right
			+ int(c > 0.175 && c < 0.225) * 1			// Target 0.200 Top
			);
}

void vertex() {
	base_uv1 = vec2(UV + UV_OFFSET1) * UV_SCALE1;
	base_uv2 = vec2(UV + UV_OFFSET2) * UV_SCALE2;
}

void fragment() {
	float segment = texture(texture_mask, base_uv1).r;
	float segment_mask = texture(texture_mask, base_uv2).r;
	int segment_id = decode_segment(segment_mask);
	int mask = segment_id & bitmask;
	float on = float(mask != 0);
	float unlit = (1.0 - on);
	COLOR.rgba = digit_color.rgba * (on) * segment
			+ unlit_color.rgba * (unlit) * segment;
	//COLOR.rgba = vec4(vec3(segment_mask), 1.0);
}
