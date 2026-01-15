class_name BreakTime extends HBoxContainer

@onready var break_label: Label = $BreakLabel


func set_break_duration(seconds: int) -> void:
	break_label.text = "Break time: %s" % Formatter.format_duration(seconds)
