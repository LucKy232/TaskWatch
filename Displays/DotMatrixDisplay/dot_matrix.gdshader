shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D texture_mask : filter_linear;
uniform vec2 UV_OFFSET = vec2(0.0);
uniform vec2 UV_SCALE = vec2(1.0);
uniform vec2 repeat_texture = vec2(1.0);

uniform vec4 digit_color : source_color;
uniform vec4 unlit_color : source_color;
uniform int bitmask;


void fragment() {
	vec2 base_uv = mod(UV * repeat_texture, 1.0);
	base_uv = (base_uv * UV_SCALE + UV_OFFSET);
	float dot_mask = texture(texture_mask, base_uv).r;
	int id = int((1.0 - UV.x) * repeat_texture.x) + int((1.0 - UV.y) * repeat_texture.y) * int(repeat_texture.x);
	int segment_id = int(pow(2.0, float(id)));
	int mask = segment_id & bitmask;
	float on = float(mask != 0);
	float unlit = (1.0 - on);
	COLOR.rgba = digit_color * on * dot_mask
			+ unlit_color.rgba * (unlit) * dot_mask;
}
