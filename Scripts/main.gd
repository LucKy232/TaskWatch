class_name Main extends Control

@export var play_icon: CompressedTexture2D
@export var pause_icon: CompressedTexture2D
@onready var task_timer: TaskTimer = %SegmentTimer
@onready var entry_list: EntryList = $EntryList
@onready var settings_panel: Control = $SettingsPanel
@onready var timer_and_buttons: VBoxContainer = $TimerAndButtons
@onready var play_pause_button: Button = %PlayPauseButton
var settings_data: SettingsData = SettingsData.new()
var current_task: Task = Task.new(0)
var show_clock: bool = false

func _ready() -> void:
	settings_panel.color_changed.connect(_on_digit_color_changed)
	settings_panel.bg_color_changed.connect(_on_background_color_changed)
	settings_panel.scale_changed.connect(_on_scale_changed)
	settings_panel.unlit_segments_toggled.connect(_on_unlit_segments_toggled)


func _process(_delta: float) -> void:
	if show_clock:
		var current_time: Dictionary = Time.get_time_dict_from_system()
		task_timer.display_time(current_time["hour"], current_time["minute"], current_time["second"])
	elif current_task.is_started:
		tick_current_task(false)
		task_timer.display_time_seconds(current_task.time_elapsed / 1000)
	elif current_task.start_datetime != "":
		tick_current_task(true)
		task_timer.display_time_seconds(current_task.time_elapsed / 1000)


func tick_current_task(break_time: bool = false) -> void:
	var current: int = Time.get_ticks_msec()
	var delta = current - current_task.last_tick_ms
	current_task.last_tick_ms = current
	if break_time:
		current_task.break_time_elapsed += delta
	else:
		current_task.time_elapsed += delta


func record_current_task() -> void:
	entry_list.new_entry_from_task(current_task)


func _on_scale_changed(s: float) -> void:
	settings_data.timer_scale = s
	timer_and_buttons.scale = Vector2(s, s)


func _on_digit_color_changed(c: Color) -> void:
	settings_data.digit_color = c
	task_timer.set_digit_color(c, settings_data.show_unlit_segments)


func _on_background_color_changed(c: Color) -> void:
	settings_data.background_color = c
	task_timer.set_background_color(c)


func _on_unlit_segments_toggled(toggled_on: bool) -> void:
	settings_data.show_unlit_segments = toggled_on
	task_timer.set_digit_color(settings_data.digit_color, toggled_on)


func _on_play_pause_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		play_pause_button.icon = pause_icon
		if !current_task.is_started:
			if current_task.start_datetime == "":	# Never started before
				current_task.last_tick_ms = Time.get_ticks_msec()
				current_task.start_datetime = Time.get_datetime_string_from_system(false, true)
			current_task.is_started = true
	else:
		play_pause_button.icon = play_icon
		if current_task.is_started:
			current_task.is_started = false
			current_task.end_datetime = Time.get_datetime_string_from_system(false, true)


func _on_stop_button_pressed() -> void:
	record_current_task()
	current_task = Task.new(Time.get_ticks_msec())
	play_pause_button.set_pressed(false)
