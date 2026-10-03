shader_type canvas_item;
render_mode blend_mix;

uniform vec4 digit_color : source_color;
uniform vec4 unlit_color : source_color;
uniform sampler2D texture_mask : filter_linear;
uniform bool lit;

uniform vec2 UV_OFFSET = vec2(0.0);
uniform vec2 UV_SCALE = vec2(1.0);

void fragment() {
	vec2 base_uv = vec2(UV + UV_OFFSET) * UV_SCALE;
	float segment = texture(texture_mask, base_uv).r;
	float on = float(lit) * (segment);
	float unlit = (1.0 - on) * (segment);
	COLOR.rgba = digit_color.rgba * (on)
			+ unlit_color.rgba * (unlit);
}
