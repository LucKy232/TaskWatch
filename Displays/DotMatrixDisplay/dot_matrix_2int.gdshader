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
//varying vec2 uv1;
//varying vec2 uv2;
varying float ratio;

void vertex() {
	repeating1 = vec2(repeat_texture.x, repeat_texture.y - y_split);
	repeating2 = vec2(repeat_texture.x, y_split);
	ratio = (y_split / repeat_texture.y);
}

void fragment() {
	int top = int(UV.y < ratio);
	vec2 uv1 = vec2(UV.x, min(UV.y / ratio, 1.0));
	vec2 uv2 = vec2(UV.x, min((UV.y - ratio) / (1.0 - ratio), 1.0));
	float zoom = 1.0 + dot_zoom * 2.0;
	vec2 base_uv = mod(UV * repeat_texture, 1.0);
	base_uv = vec2(clamp(base_uv.x * zoom - dot_zoom, dot_zoom_margin, 1.0 - dot_zoom_margin), clamp(base_uv.y * zoom - dot_zoom, dot_zoom_margin, 1.0 - dot_zoom_margin));
	base_uv = (base_uv * UV_SCALE + UV_OFFSET);
	float dot_mask = texture(texture_mask, base_uv).r;
	int id1 = int((1.0 - uv1.y) * y_split) * int(repeating1.x) + int((1.0 - uv1.x) * repeating1.x);
	int id2 = int((1.0 - uv2.y) * (repeat_texture.y - y_split)) * int(repeating2.x) + int((1.0 - uv2.x) * repeating2.x);
	int segment_id1 = int(pow(2.0, float(id1))) * top;
	int segment_id2 = int(pow(2.0, float(id2))) * (1 - top);
	int mask = (segment_id1 & bitmask.x) | (segment_id2 & bitmask.y);
	float on = float(mask != 0);
	float unlit = (1.0 - on);
	COLOR.rgba = digit_color * on * dot_mask
			+ unlit_color.rgba * (unlit) * dot_mask;
}
