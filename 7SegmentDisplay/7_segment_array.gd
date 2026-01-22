class_name TaskTimer extends Control

## 0, 1 HH
## 2, 3 MM
## 4, 5 SS
@export var segments: Array[ColorRect]
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var dots_1: ColorRect = $HBoxContainer/Dots1
@onready var dots_2: ColorRect = $HBoxContainer/Dots2
var state: TimerState = TimerState.STOPPED

## bits toggles the segments in the shader, by bitwise operations, index corresponds to digit displayed
var bits: Array[int] = [
	0b1111110,	# 0
	0b0110000,	# 1
	0b1101101,	# 2
	0b1111001,	# 3
	0b0110011,	# 4
	0b1011011,	# 5
	0b1011111,	# 6
	0b1110000,	# 7
	0b1111111,	# 8
	0b1111011,	# 9
]
enum TimerState {
	STOPPED,
	PLAYING,
	PAUSED,
}


func _ready() -> void:
	for segment in segments:
		segment.material = segment.material.duplicate()
	dots_2.material = dots_1.material.duplicate()
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


func toggle_dots(toggled_on: bool) -> void:
	dots_2.material.set_shader_parameter("lit", toggled_on)


func set_background_color(color: Color) -> void:
	get_theme_stylebox("panel").bg_color = color


func display_time(hour: int, minute: int, second: int) -> void:
	var ms: int = Time.get_ticks_msec() % 2000	# Animation time
	hour = clampi(hour, 0, 99)
	var hour_tens: int = hour / 10
	var minute_tens: int = minute / 10
	var seconds_tens: int = second / 10
	
	var bitmask0: int = bits[hour_tens]
	var bitmask1: int = bits[hour - hour_tens * 10]
	var bitmask2: int = bits[minute_tens]
	var bitmask3: int = bits[minute - minute_tens * 10]
	var bitmask4: int = bits[seconds_tens]
	var bitmask5: int = bits[second - seconds_tens * 10]
	if state == TimerState.PLAYING:
		bitmask5 = bitmask5 | (0b10000000 if (ms < 1000) else 0b00000000)
	elif state == TimerState.PAUSED:
		bitmask3 = bitmask3 | (0b10000000 if ms > 333 else 0b00000000)
		bitmask4 = bitmask4 | (0b10000000 if ms > 666 else 0b00000000)
		bitmask5 = bitmask5 | (0b10000000 if ms > 1000 else 0b00000000)
	segments[0].material.set_shader_parameter("bitmask", bitmask0)
	segments[1].material.set_shader_parameter("bitmask", bitmask1)
	segments[2].material.set_shader_parameter("bitmask", bitmask2)
	segments[3].material.set_shader_parameter("bitmask", bitmask3)
	segments[4].material.set_shader_parameter("bitmask", bitmask4)
	segments[5].material.set_shader_parameter("bitmask", bitmask5)


func display_time_seconds(seconds: int) -> void:
	var hour: int = seconds / 3600
	var minute: int = (seconds - hour * 3600) / 60
	var second: int = seconds % 60
	display_time(hour, minute, second)


func display_number(number: float, decimals: int) -> void:
	var segment: int = 0
	# Default to 1 unit place minimum
	if decimals >= segments.size():
		decimals = segments.size() - 1
	
	var whole_number_places: int = segments.size() - decimals
	for i in whole_number_places:
		var exponent: int = whole_number_places - i - 1
		var t: float = 10.0**exponent
		var digit: int = int((number - fmod(number, t)) / t)
		number -= digit * t
		if digit > 9:
			digit = digit % 10
		var bitmask: int = bits[digit]
		if exponent == 0:
			bitmask = bitmask | 0b10000000
		segments[segment].material.set_shader_parameter("bitmask", bitmask)
		segment += 1
	for i in decimals:
		number *= 10.0
		var digit: int = int(number)
		if digit > 9:
			digit = digit % 10
		var bitmask: int = bits[digit]
		segments[segment].material.set_shader_parameter("bitmask", bitmask)
		segment += 1
