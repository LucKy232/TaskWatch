class_name TaskTimer extends Control

## 0, 1 HH  |  2, 3 MM  |  4, 5 SS
@export var material_7_segment: ShaderMaterial
@export var material_14_segment: ShaderMaterial
@export var segments: Array[ColorRect]
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var dots_1: ColorRect = $HBoxContainer/Dots1
@onready var dots_2: ColorRect = $HBoxContainer/Dots2
var state: TimerState = TimerState.STOPPED
var display_type: E.DisplayType = E.DisplayType.FOURTEEN_SEGMENT
var show_seconds: bool = true

enum TimerState {
	STOPPED,
	PLAYING,
	PAUSED,
}


func _ready() -> void:
	dots_1.material.set_shader_parameter("lit", true)
	dots_2.material.set_shader_parameter("lit", true)


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
	toggle_dots(true)


func toggle_seconds(toggle_on: bool) -> void:
	dots_2.visible = toggle_on
	segments[4].visible = toggle_on
	segments[5].visible = toggle_on
	show_seconds = toggle_on


func change_display_type(type: E.DisplayType) -> void:
	display_type = type
	match display_type:
		E.DisplayType.SEVEN_SEGMENT:
			for segment in segments:
				segment.material = material_7_segment.duplicate()
		E.DisplayType.FOURTEEN_SEGMENT:
			for segment in segments:
				segment.material = material_14_segment.duplicate()


func toggle_dots(toggled_on: bool) -> void:
	dots_2.material.set_shader_parameter("lit", toggled_on)


func set_background_color(color: Color) -> void:
	get_theme_stylebox("panel").bg_color = color


func display_time(hour: int, minute: int, second: int) -> void:
	var decode_function: Callable
	match display_type:
		E.DisplayType.SEVEN_SEGMENT:
			decode_function = SegmentEncoder.get_seven_segment_digit
		E.DisplayType.FOURTEEN_SEGMENT:
			decode_function = SegmentEncoder.get_fourteen_segment_digit
	
	var ms: int = Time.get_ticks_msec() % 2000	# Animation time
	var decimal_points: Array[bool]
	if show_seconds:
		decimal_points = [false, false, false, false, false, false]
	else:
		decimal_points = [false, false, false, false]
	match state:
		TimerState.PLAYING:
			decimal_points[-1] = true if ms < 1000 else false
		TimerState.PAUSED:
			decimal_points[-3] = true if ms > 333 else false
			decimal_points[-2] = true if ms > 666 else false
			decimal_points[-1] = true if ms > 1000 else false
	
	hour = clampi(hour, 0, 99)
	var hour_tens: int = hour / 10
	var minute_tens: int = minute / 10
	var seconds_tens: int = second / 10
	var bitmask0: int = decode_function.call(hour_tens, decimal_points[0])
	var bitmask1: int = decode_function.call(hour - hour_tens * 10, decimal_points[1])
	var bitmask2: int = decode_function.call(minute_tens, decimal_points[2])
	var bitmask3: int = decode_function.call(minute - minute_tens * 10, decimal_points[3])
	segments[0].material.set_shader_parameter("bitmask", bitmask0)
	segments[1].material.set_shader_parameter("bitmask", bitmask1)
	segments[2].material.set_shader_parameter("bitmask", bitmask2)
	segments[3].material.set_shader_parameter("bitmask", bitmask3)
	if show_seconds:
		var bitmask4: int = decode_function.call(seconds_tens, decimal_points[4])
		var bitmask5: int = decode_function.call(second - seconds_tens * 10, decimal_points[5])
		segments[4].material.set_shader_parameter("bitmask", bitmask4)
		segments[5].material.set_shader_parameter("bitmask", bitmask5)


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
