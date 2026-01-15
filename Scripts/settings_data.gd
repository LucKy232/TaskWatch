class_name SettingsData

var digit_color: Color = Color.DARK_RED
var background_color: Color = Color.TRANSPARENT
var show_unlit_segments: bool = true
var timer_scale: float = 1.0


func to_json() -> Dictionary:
	var dict: Dictionary
	dict["color.r"] = digit_color.r
	dict["color.g"] = digit_color.g
	dict["color.b"] = digit_color.b
	dict["color.a"] = digit_color.a
	dict["backgroundcolor.r"] = background_color.r
	dict["backgroundcolor.g"] = background_color.g
	dict["backgroundcolor.b"] = background_color.b
	dict["backgroundcolor.a"] = background_color.a
	dict["show_unlit_segments"] = show_unlit_segments
	dict["timer_scale"] = timer_scale
	return dict
