class_name TaskTimer extends Control
## 0, 1 HH  |  2, 3 MM  |  4, 5 SS

@export var dots_material: ShaderMaterial
@export var material_7_segment: ShaderMaterial
@export var material_14_segment: ShaderMaterial
@export var material_dot3x5: ShaderMaterial
@export var material_dot6x5: ShaderMaterial
@export var segments: Array[ColorRect]
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var dots_1: ColorRect = $HBoxContainer/Dots1
@onready var dots_2: ColorRect = $HBoxContainer/Dots2
var state: TimerState = TimerState.STOPPED
var display_type: E.DisplayType = E.DisplayType.FOURTEEN_SEGMENT
var show_seconds: bool = true
var dot_id: int = 0

const paused_bits1: int = 0b000_010_000_010_000
const paused_bits2: int = 0b010_010_010_010_010
#const paused_bits2: int = 0b000_101_101_101_000
const dot_coords: Dictionary[int, Vector2] = {
	0: Vector2(0.6055, 0.0),
	1: Vector2(0.6055, 0.25),
	2: Vector2(0.6055, 0.50),
	3: Vector2(0.6055, 0.75),
	4: Vector2(0.6685, 0.0),
	5: Vector2(0.6685, 0.25),
}

signal size_changed

enum TimerState {
	STOPPED,
	PLAYING,
	PAUSED,
}


func _ready() -> void:
	toggle_first_dots(true)
	toggle_second_dots(true)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cycle_dot_images"):
		cycle_dot_types()


func set_digit_color(color: Color, show_unlit: bool = true) -> void:
	var unlit_color: Color = color
	unlit_color.a = 0.12 * color.a if show_unlit else 0.0
	
	for s in segments:
		s.material.set_shader_parameter("digit_color", color)
		s.material.set_shader_parameter("unlit_color", unlit_color)
	dots_1.material.set_shader_parameter("digit_color", color)
	dots_1.material.set_shader_parameter("unlit_color", unlit_color)
	dots_2.material.set_shader_parameter("digit_color", color)
	dots_2.material.set_shader_parameter("unlit_color", unlit_color)


func cycle_dot_types() -> void:
	if display_type == E.DisplayType.DOT_MATRIX_3x5 or display_type == E.DisplayType.DOT_MATRIX_6x5:
		dot_id += 1
		if !dot_coords.has(dot_id):
			dot_id = 0
		for s in segments:
			s.material.set_shader_parameter("UV_OFFSET", dot_coords[dot_id])
		dots_1.material.set_shader_parameter("UV_OFFSET", dot_coords[dot_id])
		dots_2.material.set_shader_parameter("UV_OFFSET", dot_coords[dot_id])


func toggle_seconds(toggle_on: bool) -> void:
	dots_2.visible = toggle_on
	segments[4].visible = toggle_on
	segments[5].visible = toggle_on
	show_seconds = toggle_on
	toggle_first_dots(true)
	toggle_second_dots(true)


func change_display_type(type: E.DisplayType) -> void:
	change_dots_display_type(display_type, type)
	display_type = type
	match display_type:
		E.DisplayType.SEVEN_SEGMENT:
			for segment in segments:
				segment.material = material_7_segment.duplicate()
				if segment.custom_minimum_size != Vector2(80.0, 128.0):
					segment.custom_minimum_size = Vector2(80.0, 128.0)
					size = Vector2.ZERO
			size_changed.emit()
		E.DisplayType.FOURTEEN_SEGMENT:
			for segment in segments:
				segment.material = material_14_segment.duplicate()
				if segment.custom_minimum_size != Vector2(80.0, 128.0):
					segment.custom_minimum_size = Vector2(80.0, 128.0)
					size = Vector2.ZERO
			size_changed.emit()
		E.DisplayType.DOT_MATRIX_3x5:
			for segment in segments:
				segment.material = material_dot3x5.duplicate()
				if segment.custom_minimum_size != Vector2(75.0, 125.0):
					segment.custom_minimum_size = Vector2(75.0, 125.0)
					size = Vector2.ZERO
			size_changed.emit()
		E.DisplayType.DOT_MATRIX_6x5:
			for segment in segments:
				segment.material = material_dot6x5.duplicate()
				if segment.custom_minimum_size != Vector2(150.0, 125.0):
					segment.custom_minimum_size = Vector2(150.0, 125.0)
					size = Vector2.ZERO
			size_changed.emit()


func change_dots_display_type(last_type: E.DisplayType, current_type: E.DisplayType) -> void:
	match current_type:
		E.DisplayType.SEVEN_SEGMENT:
			if last_type != E.DisplayType.FOURTEEN_SEGMENT:
				dots_1.material = dots_material.duplicate()
				dots_2.material = dots_material.duplicate()
				dots_1.custom_minimum_size = Vector2(22.0, 128.0)
				dots_2.custom_minimum_size = Vector2(22.0, 128.0)
			dots_1.offset_transform_position = Vector2(-2.4, 0.0)
			dots_2.offset_transform_position = Vector2(-2.4, 0.0)
			dots_1.offset_transform_rotation = deg_to_rad(1.0)
			dots_2.offset_transform_rotation = deg_to_rad(1.0)
		E.DisplayType.FOURTEEN_SEGMENT:
			if last_type != E.DisplayType.SEVEN_SEGMENT:
				dots_1.material = dots_material.duplicate()
				dots_2.material = dots_material.duplicate()
				dots_1.custom_minimum_size = Vector2(22.0, 128.0)
				dots_2.custom_minimum_size = Vector2(22.0, 128.0)
			dots_1.offset_transform_position = Vector2(-0.5, 0.0)
			dots_2.offset_transform_position = Vector2(-0.5, 0.0)
			dots_1.offset_transform_rotation = deg_to_rad(4.0)
			dots_2.offset_transform_rotation = deg_to_rad(4.0)
		E.DisplayType.DOT_MATRIX_3x5, E.DisplayType.DOT_MATRIX_6x5:
			if last_type == E.DisplayType.DOT_MATRIX_3x5 or last_type == E.DisplayType.DOT_MATRIX_6x5:
				return
			dots_1.material = material_dot3x5.duplicate()
			dots_2.material = material_dot3x5.duplicate()
			dots_1.custom_minimum_size = Vector2(75.0, 125.0)
			dots_2.custom_minimum_size = Vector2(75.0, 125.0)
			dots_1.offset_transform_position = Vector2(0.0, 0.0)
			dots_2.offset_transform_position = Vector2(0.0, 0.0)
			dots_1.offset_transform_rotation = 0.0
			dots_2.offset_transform_rotation = 0.0
			toggle_first_dots(true)
			toggle_second_dots(true)


func toggle_first_dots(toggled_on: bool) -> void:
	match display_type:
		E.DisplayType.SEVEN_SEGMENT, E.DisplayType.FOURTEEN_SEGMENT:
			dots_1.material.set_shader_parameter("lit", toggled_on)
		E.DisplayType.DOT_MATRIX_3x5, E.DisplayType.DOT_MATRIX_6x5:
			var bitmask: int = SegmentEncoder.get_dot3x5_segment_symbol(":" if toggled_on else "")
			dots_1.material.set_shader_parameter("bitmask", bitmask)


func toggle_second_dots(toggled_on: bool) -> void:
	match display_type:
		E.DisplayType.SEVEN_SEGMENT, E.DisplayType.FOURTEEN_SEGMENT:
			dots_2.material.set_shader_parameter("lit", toggled_on)
		E.DisplayType.DOT_MATRIX_3x5, E.DisplayType.DOT_MATRIX_6x5:
			var bitmask: int = SegmentEncoder.get_dot3x5_segment_symbol(":" if toggled_on else "")
			dots_2.material.set_shader_parameter("bitmask", bitmask)


func set_background_color(color: Color) -> void:
	get_theme_stylebox("panel").bg_color = color


func display_time(hour: int, minute: int, second: int) -> void:
	var decode_function: Callable
	match display_type:
		E.DisplayType.SEVEN_SEGMENT:
			decode_function = SegmentEncoder.get_seven_segment_digit
		E.DisplayType.FOURTEEN_SEGMENT:
			decode_function = SegmentEncoder.get_fourteen_segment_digit
		E.DisplayType.DOT_MATRIX_3x5:
			decode_function = SegmentEncoder.get_dot3x5_segment_digit
		E.DisplayType.DOT_MATRIX_6x5:
			decode_function = SegmentEncoder.get_dot6x5_segment_digit
	
	var ms: int = Time.get_ticks_msec() % 2000	# Animation time
	var decimal_points: Array[bool]
	var bitmasks: Array[int]
	if show_seconds:
		decimal_points = [false, false, false, false, false, false]
		bitmasks = [0, 0, 0, 0, 0, 0]
	else:
		decimal_points = [false, false, false, false]
		bitmasks = [0, 0, 0, 0]
	match state:
		TimerState.PLAYING:
			#decimal_points[-1] = true if ms < 1000 else false
			dots_playing_animation(ms)
		TimerState.PAUSED:
			decimal_points[-3] = true if ms > 333 else false
			decimal_points[-2] = true if ms > 666 else false
			decimal_points[-1] = true if ms > 1000 else false
			dots_paused_animation(ms)
	
	hour = clampi(hour, 0, 99)
	var hour_tens: int = hour / 10
	var minute_tens: int = minute / 10
	var seconds_tens: int = second / 10
	bitmasks[0] = decode_function.call(hour_tens)
	bitmasks[1] = decode_function.call(hour - hour_tens * 10)
	bitmasks[2] = decode_function.call(minute_tens)
	bitmasks[3] = decode_function.call(minute - minute_tens * 10)
	
	for i in decimal_points.size():
		if decimal_points[i]:
			bitmasks[i] = add_decimal_point(bitmasks[i])
	
	segments[0].material.set_shader_parameter("bitmask", bitmasks[0])
	segments[1].material.set_shader_parameter("bitmask", bitmasks[1])
	segments[2].material.set_shader_parameter("bitmask", bitmasks[2])
	segments[3].material.set_shader_parameter("bitmask", bitmasks[3])
	if show_seconds:
		bitmasks[4] = decode_function.call(seconds_tens)
		bitmasks[5] = decode_function.call(second - seconds_tens * 10)
		if decimal_points[4]:
			bitmasks[4] = add_decimal_point(bitmasks[4])
		if decimal_points[5]:
			bitmasks[5] = add_decimal_point(bitmasks[5])
		segments[4].material.set_shader_parameter("bitmask", bitmasks[4])
		segments[5].material.set_shader_parameter("bitmask", bitmasks[5])


func dots_playing_animation(time_ms: int) -> void:
	if show_seconds:
		toggle_second_dots(true if time_ms < 1500 else false)
	else:
		toggle_first_dots(true if time_ms < 1500 else false)


func dots_paused_animation(time_ms: int) -> void:
	if display_type == E.DisplayType.SEVEN_SEGMENT or display_type == E.DisplayType.FOURTEEN_SEGMENT:
		return
	if show_seconds:
		dots_2.material.set_shader_parameter("bitmask", paused_bits1 if (time_ms / 500) % 2 == 0 else paused_bits2)
	else:
		dots_1.material.set_shader_parameter("bitmask", paused_bits1 if (time_ms / 500) % 2 == 0 else paused_bits2)


func add_decimal_point(bitmask: int) -> int:
	match display_type:
		E.DisplayType.SEVEN_SEGMENT:
			return SegmentEncoder.add_seven_segment_decimal_point(bitmask)
		E.DisplayType.FOURTEEN_SEGMENT:
			return SegmentEncoder.add_fourteen_segment_decimal_point(bitmask)
	return bitmask


func display_time_seconds(seconds: int) -> void:
	var hour: int = seconds / 3600
	var minute: int = (seconds - hour * 3600) / 60
	var second: int = seconds % 60
	display_time(hour, minute, second)


#func display_number(number: float, decimals: int) -> void:
	#var segment: int = 0
	## Default to 1 unit place minimum
	#if decimals >= segments.size():
		#decimals = segments.size() - 1
	#
	#var whole_number_places: int = segments.size() - decimals
	#for i in whole_number_places:
		#var exponent: int = whole_number_places - i - 1
		#var t: float = 10.0**exponent
		#var digit: int = int((number - fmod(number, t)) / t)
		#number -= digit * t
		#if digit > 9:
			#digit = digit % 10
		#var bitmask: int = bits[digit]
		#if exponent == 0:
			#bitmask = bitmask | 0b10000000
		#segments[segment].material.set_shader_parameter("bitmask", bitmask)
		#segment += 1
	#for i in decimals:
		#number *= 10.0
		#var digit: int = int(number)
		#if digit > 9:
			#digit = digit % 10
		#var bitmask: int = bits[digit]
		#segments[segment].material.set_shader_parameter("bitmask", bitmask)
		#segment += 1
