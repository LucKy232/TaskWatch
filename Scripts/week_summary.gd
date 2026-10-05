class_name WeekSummary extends Control

@onready var date: Label = %Date
@onready var active_time: Label = %ActiveTime
@onready var break_time: Label = %BreakTime
@onready var every_day_average: Label = %EveryDayAverage
@onready var exclude_weekends_average: Label = %ExcludeWeekendsAverage
@onready var active_days_average: Label = %ActiveDaysAverage
@onready var active_days_number: Label = %ActiveDaysNumber
@onready var full_task_list: Label = %FullTaskList
var active_duration: int = 0 	# seconds
var break_duration: int = 0 	# seconds
var active_days: PackedInt32Array
# Record how many days of the week have passed (1 - 7), and if < 7, how many of those are weekdays
var days_passed: int = 0
var weekend_days_passed: int = 0
var entries: Dictionary[String, int]

signal full_task_list_toggled


func add_entry(e: Entry) -> void:
	var description: String = e.get_description()
	if !entries.has(description):
		entries[description] = e.duration
	else:
		entries[description] += e.duration
	active_duration += e.duration
	break_duration += e.break_duration


func remove_entry(e: Entry) -> void:
	var description: String = e.get_description()
	if !entries.has(description):
		return
	else:
		entries[description] -= e.duration
		if entries[description] <= 0:
			entries.erase(description)
	active_duration -= e.duration
	break_duration -= e.break_duration


func add_active_duration(seconds: int) -> void:
	active_duration += seconds


func add_break_duration(seconds: int) -> void:
	break_duration += seconds


func set_days_passed(days: int, weekend_days: int) -> void:
	days_passed = days
	weekend_days_passed = weekend_days


# 6 and 0 are Saturday and Sunday, 1 - 5 are Mon - Fri
func add_active_day(weekday_number: int) -> void:
	if !active_days.has(weekday_number):
		active_days.append(weekday_number)


func update_text() -> void:
	full_task_list.text = ""
	active_time.text = "Active: %s" % Formatter.format_duration(active_duration)
	break_time.text = "Break: %s" % Formatter.format_duration(break_duration)
	for entry in entries:
		full_task_list.text += ("%s- %s: %s" % ["\n" if full_task_list.text != "" else "", entry, Formatter.format_duration(entries[entry])])
	if active_days.size() > 0:
		active_days_number.text = "%d Day%s active" % [active_days.size(), "" if active_days.size() == 1 else "s"]
		active_days_average.text = "Active day avg: %s" % Formatter.format_duration(active_duration / active_days.size())
	if days_passed > 0:
		every_day_average.text = "Everyday avg: %s" % Formatter.format_duration(active_duration / days_passed)
		exclude_weekends_average.text = "No Weekend avg: %s" % Formatter.format_duration(active_duration / (days_passed - weekend_days_passed))


func set_date(text: String) -> void:
	date.text = Formatter.format_week_from_string(text)


func _on_toggle_full_task_list_toggled(toggled_on: bool) -> void:
	full_task_list.visible = toggled_on
	full_task_list_toggled.emit()
