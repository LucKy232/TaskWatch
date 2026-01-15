class_name Task

var description: String = ""
var start_datetime: String = ""
var end_datetime: String = ""
var is_started: bool = false
var time_elapsed: int = 0		# msec
var break_time_elapsed: int = 0 # msec
var last_tick_ms: int = 0

func _init(creation_time: int) -> void:
	last_tick_ms = creation_time
