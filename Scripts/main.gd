class_name Main extends Control

@export var play_icon: CompressedTexture2D
@export var pause_icon: CompressedTexture2D
@onready var task_timer: TaskTimer = %SegmentTimer
@onready var entry_list: EntryList = $EntryList
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var timer_and_buttons: Draggable = $TimerAndButtons
@onready var play_pause_button: Button = %PlayPauseButton
@onready var task_description_line_edit: LineEdit = %TaskDescriptionLineEdit
@onready var buttons_v_box: VBoxContainer = %ButtonsVBox
@onready var buttons_h_box: HBoxContainer = %ButtonsHBox
@onready var show_list_button: Button = %ShowListButton
@onready var show_settings_button: Button = %ShowSettingsButton

var settings_data: SettingsData = SettingsData.new()
var current_task: Task = Task.new(0)
var show_clock: bool = false


func _ready() -> void:
	call_deferred("resize_to_screen")
	call_deferred("set_always_on_top", true)
	call_deferred("set_mouse_passtrough")
	settings_panel.color_changed.connect(_on_digit_color_changed)
	settings_panel.bg_color_changed.connect(_on_background_color_changed)
	settings_panel.scale_changed.connect(_on_scale_changed)
	settings_panel.unlit_segments_toggled.connect(_on_unlit_segments_toggled)
	settings_panel.color_picker_toggled.connect(_on_settings_color_picker_toggled)
	task_timer.show_buttons.connect(_on_timer_show_buttons)
	task_timer.hide_buttons.connect(_on_timer_hide_buttons)
	timer_and_buttons.position_changed.connect(_on_draggable_position_changed)


func _process(_delta: float) -> void:
	if current_task.is_started:
		tick_current_task(false)
	if current_task.start_datetime != "":
		tick_current_task(true)
	
	if show_clock:
		var current_time: Dictionary = Time.get_time_dict_from_system()
		task_timer.display_time(current_time["hour"], current_time["minute"], current_time["second"])
	else:
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


func save_all() -> void:
	save_settings()
	record_current_task()
	save_current_project()


func save_settings() -> void:
	pass


func save_current_project() -> void:
	pass


func resize_to_screen() -> void:
	get_window().mode = Window.Mode.MODE_MAXIMIZED


func set_always_on_top(toggled_on: bool) -> void:
	get_window().always_on_top = toggled_on


# Find min/max x/y from all 4 canvas items:
# TimerAndSideButtons, SettingsPanel, EntryList, ColorPickerPopup
func set_mouse_passtrough() -> void:
	var polygon: PackedVector2Array = PackedVector2Array()
	polygon.append_array(timer_and_buttons.get_mouse_passtrough())
	if settings_panel.is_visible():
		polygon.append_array(get_settings_panel_passtrough())
	if entry_list.is_visible():
		polygon.append_array(get_entry_list_passtrough())
	if settings_panel.is_visible():
		polygon.append_array(settings_panel.get_color_picker_passtrough())
		polygon.append_array(settings_panel.get_option_button_passtrough())
	
	# Simple implementation - take extremes; no combining polygons, has gaps with no passtrough
	var x_values: Array[float]
	var y_values: Array[float]
	for p in polygon:
		x_values.append(p.x)
		y_values.append(p.y)
	
	var min_x: float = x_values.min() - 8.0
	var max_x: float = x_values.max() + 8.0
	var min_y: float = y_values.min() - 8.0
	var max_y: float = y_values.max() + 8.0
	
	polygon.clear()
	polygon.append(Vector2(min_x, min_y))
	polygon.append(Vector2(max_x, min_y))
	polygon.append(Vector2(max_x, max_y))
	polygon.append(Vector2(min_x, max_y))
	get_window().mouse_passthrough_polygon = polygon


func get_settings_panel_passtrough() -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	corners.append(settings_panel.position)
	corners.append(settings_panel.position + Vector2(settings_panel.size.x, 0.0))
	corners.append(settings_panel.position + settings_panel.size)
	corners.append(settings_panel.position + Vector2(0.0, settings_panel.size.y))
	return corners


func get_entry_list_passtrough() -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	corners.append(entry_list.position)
	corners.append(entry_list.position + Vector2(entry_list.size.x, 0.0))
	corners.append(entry_list.position + entry_list.size)
	corners.append(entry_list.position + Vector2(0.0, entry_list.size.y))
	return corners


func set_panel_positions() -> void:
	var top: float = 0.0 if timer_and_buttons.side_vertical == timer_and_buttons.SideV.TOP else 1.0
	var list_visible: float = 1.0 if entry_list.is_visible() else 0.0
	var timer_size: Vector2 = timer_and_buttons.size * timer_and_buttons.scale
	entry_list.position.x = (timer_and_buttons.position.x
							+ timer_size.x
							- entry_list.size.x)
	entry_list.position.y = (timer_and_buttons.position.y
							- entry_list.size.y * top
							+ timer_size.y * (1.0 - top))
	settings_panel.position.x = (timer_and_buttons.position.x
							+ timer_size.x
							- settings_panel.size.x
							- entry_list.size.x * list_visible)
	settings_panel.position.y = (timer_and_buttons.position.y
							- settings_panel.size.y * top
							+ timer_size.y * (1.0 - top))


func _on_scale_changed(s: float) -> void:
	settings_data.timer_scale = s
	timer_and_buttons.set_timer_scale(s)
	timer_and_buttons.reposition_timer(false)


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
	current_task.is_started = false
	current_task.end_datetime = Time.get_datetime_string_from_system(false, true)
	record_current_task()
	current_task = Task.new(Time.get_ticks_msec())
	current_task.description = task_description_line_edit.text
	play_pause_button.set_pressed(false)


func _on_show_clock_button_toggled(toggled_on: bool) -> void:
	show_clock = toggled_on


func _on_show_list_button_toggled(toggled_on: bool) -> void:
	entry_list.visible = toggled_on
	set_mouse_passtrough()


func _on_show_settings_button_toggled(toggled_on: bool) -> void:
	settings_panel.visible = toggled_on
	set_mouse_passtrough()


func _on_task_description_line_edit_text_changed(new_text: String) -> void:
	current_task.description = new_text


func _on_exit_app_button_pressed() -> void:
	save_all()
	get_tree().quit()


func _on_timer_show_buttons() -> void:
	if !buttons_h_box.visible or !buttons_v_box.visible:
		buttons_h_box.visible = true
		buttons_v_box.visible = true
		timer_and_buttons.reposition_timer(true)
	settings_panel.visible = show_settings_button.is_pressed()
	entry_list.visible = show_list_button.is_pressed()
	set_panel_positions()
	set_mouse_passtrough()


func _on_timer_hide_buttons() -> void:
	if buttons_h_box.visible or buttons_v_box.visible:
		buttons_h_box.visible = false
		buttons_v_box.visible = false
		timer_and_buttons.reposition_timer(false)
	settings_panel.visible = false
	entry_list.visible = false
	set_mouse_passtrough()


func _on_draggable_position_changed() -> void:
	set_panel_positions()
	set_mouse_passtrough()


func _on_settings_color_picker_toggled() -> void:
	set_mouse_passtrough()
