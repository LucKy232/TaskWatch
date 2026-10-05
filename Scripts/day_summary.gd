class_name DaySummary extends Control

@onready var date: Label = %Date
@onready var active_time: Label = %ActiveTime
@onready var break_time: Label = %BreakTime
@onready var full_task_list: Label = %FullTaskList
var active_duration: int = 0 	# seconds
var break_duration: int = 0 	# seconds
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


func update_text() -> void:
	full_task_list.text = ""
	active_time.text = "Active: %s" % Formatter.format_duration(active_duration)
	break_time.text = "Break: %s" % Formatter.format_duration(break_duration)
	for entry in entries:
		full_task_list.text += ("%s- %s: %s" % ["\n" if full_task_list.text != "" else "", entry, Formatter.format_duration(entries[entry])])


func add_active_duration(seconds: int) -> void:
	active_duration += seconds
	active_time.text = "Active: %s" % Formatter.format_duration(active_duration)


func add_break_duration(seconds: int) -> void:
	break_duration += seconds
	break_time.text = "Break: %s" % Formatter.format_duration(break_duration)


func set_date(text: String) -> void:
	date.text = Formatter.format_day(text)


func _on_toggle_full_task_list_toggled(toggled_on: bool) -> void:
	full_task_list.visible = toggled_on
	full_task_list_toggled.emit()
