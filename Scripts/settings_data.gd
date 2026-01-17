class_name SettingsData

var digit_color: Color = Color.DARK_RED
var background_color: Color = Color.TRANSPARENT
var show_unlit_segments: bool = true
var always_on_top: bool = true
var timer_scale: float = 1.0
var timer_position: Vector2 = Vector2.ZERO
var screen_id: int = 0	## Which monitor the application is displayed on, no multi-monitor support because maximized
var opened_file_paths: Array[String] = []
var opened_file_id: int = 0


func get_current_project_path() -> String:
	if opened_file_id >= 0 and opened_file_id < opened_file_paths.size():
		return opened_file_paths[opened_file_id]
	else:
		return ""


func load_from_dictionary(dict) -> void:
	digit_color = Color(dict["color.r"], dict["color.g"], dict["color.b"], dict["color.a"])
	background_color = Color(dict["background_color.r"], dict["background_color.g"], dict["background_color.b"], dict["background_color.a"])
	show_unlit_segments = bool(dict["show_unlit_segments"])
	always_on_top = bool(dict["always_on_top"])
	timer_scale = dict["timer_scale"]
	timer_position = Vector2(dict["timer_position_x"], dict["timer_position_y"])
	screen_id = int(dict["screen_id"])
	opened_file_paths = opened_file_paths_from_dict(dict["opened_file_paths"])
	opened_file_id = int(dict["opened_file_id"])


func to_json() -> Dictionary:
	var dict: Dictionary
	dict["color.r"] = digit_color.r
	dict["color.g"] = digit_color.g
	dict["color.b"] = digit_color.b
	dict["color.a"] = digit_color.a
	dict["background_color.r"] = background_color.r
	dict["background_color.g"] = background_color.g
	dict["background_color.b"] = background_color.b
	dict["background_color.a"] = background_color.a
	dict["show_unlit_segments"] = show_unlit_segments
	dict["timer_scale"] = timer_scale
	dict["timer_position_x"] = timer_position.x
	dict["timer_position_y"] = timer_position.y
	dict["screen_id"] = screen_id
	dict["always_on_top"] = always_on_top
	dict["opened_file_id"] = opened_file_id
	dict["opened_file_paths"] = opened_file_paths_to_json()
	return dict


func opened_file_paths_from_dict(dict: Dictionary) -> Array[String]:
	var arr: Array[String] = []
	dict.sort()
	var counter: int = 0
	for key in dict:
		if key == str(counter):
			arr.append(dict[key])
	return arr


func opened_file_paths_to_json() -> Dictionary:
	var dict: Dictionary
	for i in range(opened_file_paths.size()):
		dict[str(i)] = opened_file_paths[i]
	return dict
