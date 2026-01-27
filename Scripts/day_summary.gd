class_name DaySummary extends Control

@onready var date: Label = %Date
@onready var active_time: Label = %ActiveTime
@onready var break_time: Label = %BreakTime

var active_duration: int = 0 	# seconds
var break_duration: int = 0 	# seconds


func add_active_duration(seconds: int) -> void:
	active_duration += seconds
	active_time.text = "Active: %s" % Formatter.format_duration(active_duration)


func add_break_duration(seconds: int) -> void:
	break_duration += seconds
	break_time.text = "Break: %s" % Formatter.format_duration(break_duration)


func set_date(text: String) -> void:
	# TODO week day
	date.text = Formatter.format_day(text)
