class_name MonthSummary extends Control

@onready var date: Label = %Date
@onready var active_time: Label = %ActiveTime
@onready var break_time: Label = %BreakTime
@onready var every_day_average: Label = %EveryDayAverage
@onready var exclude_weekends_average: Label = %ExcludeWeekendsAverage
@onready var active_days_average: Label = %ActiveDaysAverage
@onready var active_days_number: Label = %ActiveDaysNumber
var active_duration: int = 0 	# seconds
var break_duration: int = 0 	# seconds
var active_days: PackedInt32Array
# Record how many days of the week have passed, and how many of those are weekdays
var days_passed: int = 0
var weekend_days_passed: int = 0


func add_active_duration(seconds: int) -> void:
	active_duration += seconds
	active_time.text = "Active: %s" % Formatter.format_duration(active_duration)
	if days_passed != 0:
		exclude_weekends_average.text = "No Weekend avg: %s" % Formatter.format_duration(active_duration / (days_passed - weekend_days_passed))
		every_day_average.text = "Everyday avg: %s" % Formatter.format_duration(active_duration / days_passed)


func add_break_duration(seconds: int) -> void:
	break_duration += seconds
	break_time.text = "Break: %s" % Formatter.format_duration(break_duration)


func set_days_passed(days: int, weekend_days: int) -> void:
	days_passed = days
	weekend_days_passed = weekend_days
	if days_passed != 0:
		exclude_weekends_average.text = "No Weekend avg: %s" % Formatter.format_duration(active_duration / (days_passed - weekend_days_passed))
		every_day_average.text = "Everyday avg: %s" % Formatter.format_duration(active_duration / days_passed)


func add_active_day(day_number: int) -> void:
	if !active_days.has(day_number):
		active_days.append(day_number)
	active_days_number.text = "%d Day%s active" % [active_days.size(), "" if active_days.size() == 1 else "s"]
	active_days_average.text = "Active day avg: %s" % Formatter.format_duration(active_duration / active_days.size())


func set_date(text: String) -> void:
	date.text = Formatter.format_month(text)
