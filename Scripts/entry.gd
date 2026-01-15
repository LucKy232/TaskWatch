class_name Entry extends Control

@onready var description: Label = %Description
@onready var duration_label: Label = %DurationLabel
@onready var break_duration_label: Label = %BreakDuration
@onready var start_date_time: Label = %StartDateTime
@onready var end_date_time: Label = %EndDateTime

var start_datetime: String = ""
var end_datetime: String = ""
var id: int = -1
var duration: int 		# seconds
var break_duration: int # seconds

signal erase_entry


func set_duration(seconds: int) -> void:
	duration = seconds
	duration_label.text = "Active: %s" % Formatter.format_duration(seconds)


func set_break_duration(seconds: int) -> void:
	break_duration = seconds
	break_duration_label.text = "Break: %s" % Formatter.format_duration(seconds)


func set_description(text: String) -> void:
	description.text = text


func set_start_datetime(text: String) -> void:
	start_datetime = text
	start_date_time.text = text


func set_end_datetime(text: String) -> void:
	end_datetime = text
	end_date_time.text = text


func _on_erase_button_pressed() -> void:
	erase_entry.emit(id)


func set_data_from_json(dict: Dictionary) -> void:
	set_duration(dict["Duration"])
	set_break_duration(dict["BreakDuration"])
	set_description(dict["Description"])
	set_start_datetime(dict["StartDateTime"])
	set_end_datetime(dict["EndDateTime"])


func to_json() -> Dictionary:
	var dict: Dictionary
	dict["Description"] = description.text
	dict["Duration"] = duration
	dict["BreakDuration"] = break_duration
	dict["StartDateTime"] = start_datetime
	dict["EndDateTime"] = end_datetime
	return dict
