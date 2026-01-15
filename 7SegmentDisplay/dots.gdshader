shader_type canvas_item;
render_mode blend_mix;

uniform vec4 digit_color : source_color;
uniform vec4 unlit_color : source_color;
uniform sampler2D texture_mask : filter_nearest;
uniform bool lit;

void fragment() {
	vec4 segment_color = texture(texture_mask, UV).rgba;
	float on = float(lit) * (segment_color.a);
	float unlit = (1.0 - on) * (segment_color.a);
	COLOR.rgba = digit_color.rgba * (on)
			+ unlit_color.rgba * (unlit);
}
