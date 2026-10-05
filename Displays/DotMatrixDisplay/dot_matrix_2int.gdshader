shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D texture_mask : filter_linear;
uniform vec2 UV_OFFSET = vec2(0.0);
uniform vec2 UV_SCALE = vec2(1.0);
uniform vec2 repeat_texture = vec2(1.0);
uniform float dot_zoom = 0.0;
uniform float dot_zoom_margin = 0.0;
uniform float y_split = 1.0;

uniform vec4 digit_color : source_color;
uniform vec4 unlit_color : source_color;
uniform ivec2 bitmask;

varying vec2 repeating1;
varying vec2 repeating2;

void vertex() {
	repeating1 = vec2(repeat_texture.x, repeat_texture.y - y_split);
	repeating2 = vec2(repeat_texture.x, y_split);
}

void fragment() {
	vec2 base_uv = mod(UV * repeat_texture, 1.0);
	float zoom = 1.0 + dot_zoom * 2.0;
	base_uv = vec2(clamp(base_uv.x * zoom - dot_zoom, dot_zoom_margin, 1.0 - dot_zoom_margin), clamp(base_uv.y * zoom - dot_zoom, dot_zoom_margin, 1.0 - dot_zoom_margin));
	base_uv = (base_uv * UV_SCALE + UV_OFFSET);
	float dot_mask = texture(texture_mask, base_uv).r;
	float first_uvy = clamp((UV.y / (repeating1.y / repeat_texture.y)) * repeating1.y, 0.0, y_split);
	int id1 = int((1.0 - UV.x) * repeating1.x) + int(first_uvy) * int(repeating1.x);
	int id2 = int((1.0 - UV.x) * repeating2.x) + int((1.0 - first_uvy) * repeating2.y) * int(repeating2.x);
	int segment_id1 = int(pow(2.0, float(id1)));
	int segment_id2 = int(pow(2.0, float(id2)));
	int mask = segment_id1 & bitmask.x + segment_id2 & bitmask.y;
	float on = float(mask != 0);
	float unlit = (1.0 - on);
	COLOR.rgba = digit_color * on * dot_mask
			+ unlit_color.rgba * (unlit) * dot_mask;
}
