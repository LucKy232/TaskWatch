class_name Main extends Control

const MAIN_THEME = preload("uid://dirmfsg7xnbxr")
@export var settings_file_path: String = "user://settings_data.json"
@export var play_icon: CompressedTexture2D
@export var pause_icon: CompressedTexture2D
@onready var task_timer: TaskTimer = %SegmentTimer
@onready var entry_list: EntryList = $EntryList
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var timer_and_buttons: Draggable = $TimerAndButtons
@onready var play_pause_button: Button = %PlayPauseButton
@onready var stop_button: Button = %StopButton
@onready var show_clock_button: Button = %ShowClockButton
@onready var minimize_app_button: Button = %MinimizeAppButton
@onready var task_description_line_edit: LineEdit = %TaskDescriptionLineEdit
@onready var buttons_v_box: VBoxContainer = %ButtonsVBox
@onready var buttons_h_box: HBoxContainer = %ButtonsHBox
@onready var show_list_button: Button = %ShowListButton
@onready var show_settings_button: Button = %ShowSettingsButton
@onready var hover_timer: Timer = $HoverTimer
@onready var system_tray: SystemTray = $SystemTray

var settings_data: SettingsData = SettingsData.new()
var current_task: Task = Task.new(0)


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	call_deferred("resize_to_screen")
	call_deferred("set_mouse_passtrough")
	settings_panel.color_changed.connect(_on_digit_color_changed)
	settings_panel.bg_color_changed.connect(_on_background_color_changed)
	settings_panel.scale_changed.connect(_on_scale_changed)
	settings_panel.unlit_segments_toggled.connect(_on_unlit_segments_toggled)
	settings_panel.color_picker_toggled.connect(_on_settings_color_picker_toggled)
	settings_panel.always_on_top_toggled.connect(_on_always_on_top_toggled)
	timer_and_buttons.position_changed.connect(_on_draggable_position_changed)
	timer_and_buttons.gui_input.connect(_on_gui_input)
	settings_panel.gui_input.connect(_on_gui_input)
	entry_list.gui_input.connect(_on_gui_input)
	settings_panel.popup_1.window_input.connect(_on_gui_input)
	settings_panel.popup_2.window_input.connect(_on_gui_input)
	settings_panel.popup_3.window_input.connect(_on_gui_input)
	system_tray.system_tray_menu_pressed.connect(_on_system_tray_menu)
	system_tray.status_indicator.pressed.connect(_on_status_indicator_pressed)
	entry_list.project_name.editing_toggled.connect(_on_line_edit_editing_toggled)
	
	set_button_shortcut_events()
	# Load settings
	if !FileAccess.file_exists(settings_file_path):
		settings_data.opened_file_paths.append("user://%s%d.json" % [Time.get_datetime_string_from_system().remove_chars(":"), Time.get_ticks_msec()])
		save_settings_data()
	else:
		load_settings_data()
	# Load project
	if settings_data.opened_file_paths.size() == 0:
		settings_data.opened_file_paths.append("user://%s%d.json" % [Time.get_datetime_string_from_system().remove_chars(":"), Time.get_ticks_msec()])
		save_settings_data()
	else:
		load_current_project_file()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("scale_up", true):
		settings_panel.scale_up()
	if Input.is_action_just_pressed("scale_down", true):
		settings_panel.scale_down()
	
	if current_task.is_started:
		tick_current_task(false)
		task_timer.state = task_timer.TimerState.PLAYING
	elif current_task.start_datetime != "":
		tick_current_task(true)
		task_timer.state = task_timer.TimerState.PAUSED
	else:
		task_timer.state = task_timer.TimerState.STOPPED
	
	if settings_data.show_clock:
		var current_time: Dictionary = Time.get_time_dict_from_system()
		task_timer.display_time(current_time["hour"], current_time["minute"], current_time["second"])
	elif current_task.is_started:
		task_timer.display_time_seconds(current_task.time_elapsed / 1000)
	elif current_task.start_datetime != "":
		task_timer.display_time_seconds(current_task.break_time_elapsed / 1000)
	else:
		task_timer.display_time(0, 0, 0)
	
	var screen_id: int = DisplayServer.window_get_current_screen()
	if settings_data.screen_id != screen_id:
		settings_data.screen_id = screen_id
		change_screen(screen_id)


func change_screen(screen_number: int) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_current_screen(screen_number)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_current_screen(screen_number)
	timer_and_buttons.position = timer_and_buttons.pan_limits(timer_and_buttons.position)
	_on_draggable_position_changed()


func resize_to_screen() -> void:
	get_window().mode = Window.Mode.MODE_MAXIMIZED


func minimize_window() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


func maximize_window() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func set_button_shortcut_events() -> void:
	play_pause_button.shortcut = Shortcut.new()
	stop_button.shortcut = Shortcut.new()
	show_clock_button.shortcut = Shortcut.new()
	minimize_app_button.shortcut = Shortcut.new()
	show_list_button.shortcut = Shortcut.new()
	
	play_pause_button.shortcut.events = InputMap.action_get_events("play_pause")
	stop_button.shortcut.events = InputMap.action_get_events("stop")
	show_clock_button.shortcut.events = InputMap.action_get_events("show_clock")
	minimize_app_button.shortcut.events = InputMap.action_get_events("minimize_app")
	show_list_button.shortcut.events = InputMap.action_get_events("show_list")


func save_settings_data() -> void:
	var file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	if file == null:
		printerr("@main.gd : save_settings_data() - FileAcces open error: ", error_string(FileAccess.get_open_error()))
		return
	var save_data: Dictionary = settings_data.to_json()
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()


func load_settings_data() -> void:
	if !FileAccess.file_exists(settings_file_path):
		printerr("@main.gd : load_settings_data() - Settings file not found! %s" % [settings_file_path])
		return
	
	var file = FileAccess.open(settings_file_path, FileAccess.READ)
	if file == null:
		printerr("@main.gd : load_settings_data() - FileAcces open error: ", error_string(FileAccess.get_open_error()))
		return
	
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	
	if data == null:
		printerr("@main.gd : load_settings_data() - Can't parse json string!")
		return
	
	settings_data.load_from_dictionary(data)
	apply_settings_data()


func save_current_project_file() -> void:
	var path: String = settings_data.get_current_project_path()
	if path == "":
		printerr("@main.gd : save_current_project_file() - Empty file path stored in SettingData")
		return
	#if !FileAccess.file_exists(path):
		#printerr("@main.gd : save_current_project_file() - Project file not found! %s" % [path])
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("@main.gd : save_current_project_file() - FileAcces open error: %s %s" % [error_string(FileAccess.get_open_error()), path])
		return
	var save_data: Dictionary
	save_data["ProjectName"] = entry_list.project_name.text
	save_data["Entries"] = entry_list.all_entries_to_json()
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()


func load_current_project_file() -> void:
	var path: String = settings_data.get_current_project_path()
	if path == "":
		printerr("@main.gd : load_current_project_file() - Empty file path stored in SettingData")
		return
	if !FileAccess.file_exists(path):
		#printerr("@main.gd : load_current_project_file - File not found! %s" % [path])
		save_current_project_file()
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("@main.gd : load_current_project_file() - FileAcces open error: ", error_string(FileAccess.get_open_error()))
		return
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	if data == null:
		printerr("@main.gd : load_current_project_file() - Can't parse json string!")
		return
	entry_list.populate_entries_from_dict(data)


func apply_settings_data() -> void:
	DisplayServer.window_set_current_screen(settings_data.screen_id)
	set_theme_color(settings_data.digit_color)
	task_timer.set_digit_color(settings_data.digit_color, settings_data.show_unlit_segments)
	task_timer.set_background_color(settings_data.background_color)
	task_timer.toggle_dots(true)
	timer_and_buttons.set_timer_scale(settings_data.timer_scale)
	timer_and_buttons.position = settings_data.timer_position
	timer_and_buttons.reposition_timer(false)
	timer_and_buttons.find_quadrant_and_reorder()
	set_always_on_top(settings_data.always_on_top)
	system_tray.set_always_on_top_checked(settings_data.always_on_top)
	# Visible settings
	settings_panel.set_picked_scale(settings_data.timer_scale)
	settings_panel.set_digit_color(settings_data.digit_color)
	settings_panel.set_background_color(settings_data.background_color)
	settings_panel.set_unlit_checkbox_pressed(settings_data.show_unlit_segments)
	settings_panel.set_always_on_top_checkbox_pressed(settings_data.always_on_top)
	show_clock_button.set_pressed_no_signal(settings_data.show_clock)


func set_theme_color(c: Color) -> void:
	MAIN_THEME.get_stylebox("normal", "Button").border_color = c
	MAIN_THEME.get_stylebox("focus", "Button").border_color = c
	MAIN_THEME.get_stylebox("hover", "Button").border_color = c
	MAIN_THEME.get_stylebox("hover_pressed", "Button").border_color = c
	MAIN_THEME.get_stylebox("pressed", "Button").border_color = c
	MAIN_THEME.get_stylebox("normal", "LineEdit").border_color = c
	MAIN_THEME.get_stylebox("panel", "Panel").border_color = c
	MAIN_THEME.get_stylebox("panel", "PanelContainer").border_color = c
	MAIN_THEME.set_color("checkbox_checked_color", "CheckBox", c)


func tick_current_task(break_time: bool = false) -> void:
	var current: int = Time.get_ticks_msec()
	var delta = current - current_task.last_tick_ms
	current_task.last_tick_ms = current
	if break_time:
		current_task.break_time_elapsed += delta
	else:
		current_task.time_elapsed += delta


func record_current_task() -> bool:
	if current_task.start_datetime == "":
		return false
	if current_task.end_datetime == "":
		current_task.end_datetime = Time.get_datetime_string_from_system(false, true)
	entry_list.new_entry_from_task(current_task)
	return true


func save_all() -> void:
	save_settings_data()
	var entry_created: bool = record_current_task()
	save_current_project_file()
	if entry_created:
		entry_list.erase_latest_entry()


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
	
	var min_x: float = x_values.min()
	var max_x: float = x_values.max()
	var min_y: float = y_values.min()
	var max_y: float = y_values.max()
	var margin: float = 8.0
	polygon.clear()
	polygon.append(Vector2(min_x - margin, min_y - margin))
	polygon.append(Vector2(max_x + margin, min_y - margin))
	polygon.append(Vector2(max_x + margin, max_y + margin))
	polygon.append(Vector2(min_x - margin, max_y + margin))
	
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


# Replace quit behaviour with save file + quit
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_exit_app_button_pressed()
		#get_tree().quit() # default behavior


func _on_scale_changed(s: float) -> void:
	settings_data.timer_scale = s
	timer_and_buttons.set_timer_scale(s)
	timer_and_buttons.reposition_timer(false)


func _on_digit_color_changed(c: Color) -> void:
	settings_data.digit_color = c
	task_timer.set_digit_color(c, settings_data.show_unlit_segments)
	set_theme_color(c)


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


func _on_always_on_top_toggled(toggled_on: bool) -> void:
	settings_data.always_on_top = toggled_on
	set_always_on_top(toggled_on)
	system_tray.set_always_on_top_checked(toggled_on)


func _on_stop_button_pressed() -> void:
	if current_task.start_datetime == "":
		return
	current_task.is_started = false
	current_task.end_datetime = Time.get_datetime_string_from_system(false, true)
	record_current_task()
	current_task = Task.new(Time.get_ticks_msec())
	current_task.description = task_description_line_edit.text
	play_pause_button.set_pressed(false)


func _on_show_clock_button_toggled(toggled_on: bool) -> void:
	settings_data.show_clock = toggled_on


func _on_show_list_button_toggled(toggled_on: bool) -> void:
	entry_list.visible = toggled_on
	set_panel_positions()
	set_mouse_passtrough()


func _on_show_settings_button_toggled(toggled_on: bool) -> void:
	settings_panel.visible = toggled_on
	set_panel_positions()
	set_mouse_passtrough()


func _on_task_description_line_edit_text_changed(new_text: String) -> void:
	current_task.description = new_text


func _on_exit_app_button_pressed() -> void:
	save_all()
	get_tree().quit()


func _on_timer_show_buttons() -> void:
	var set_passtrough: bool = false
	var set_panels: bool = false
	
	if !buttons_h_box.visible or !buttons_v_box.visible:
		buttons_h_box.visible = true
		buttons_v_box.visible = true
		set_passtrough = true
		timer_and_buttons.reposition_timer(true)
	if show_settings_button.is_pressed() and !settings_panel.is_visible():
		settings_panel.visible = true
		set_panels = true
		set_passtrough = true
	if show_list_button.is_pressed() and !entry_list.is_visible():
		entry_list.visible = true
		set_panels = true
		set_passtrough = true
	
	if set_panels:
		set_panel_positions()
	if set_passtrough:
		set_mouse_passtrough()


func _on_timer_hide_buttons() -> void:
	if get_window().gui_get_focus_owner() is LineEdit and get_window().gui_get_focus_owner().is_editing:
		return
	if buttons_h_box.visible or buttons_v_box.visible:
		buttons_h_box.visible = false
		buttons_v_box.visible = false
		timer_and_buttons.reposition_timer(false)
	settings_panel.visible = false
	entry_list.visible = false
	set_mouse_passtrough()


func _on_draggable_position_changed() -> void:
	settings_data.timer_position = timer_and_buttons.position
	set_panel_positions()
	set_mouse_passtrough()


func _on_settings_color_picker_toggled() -> void:
	set_mouse_passtrough()


func _on_hover_timer_timeout() -> void:
	_on_timer_hide_buttons()


## _on_mouse_entered() and _on_mouse_exited() aren't reliable with transparent windows
func _on_gui_input(_event: InputEvent) -> void:
	_on_timer_show_buttons()
	hover_timer.start()


func _on_autosave_timer_timeout() -> void:
	save_all()


func _on_minimize_app_button_pressed() -> void:
	minimize_app_button.set_focus_mode(Control.FOCUS_NONE)
	minimize_window()


func _on_system_tray_menu(id: int) -> void:
	match id:
		0:
			_on_minimize_app_button_pressed()
		1:
			settings_data.always_on_top = !settings_data.always_on_top
			settings_panel.set_always_on_top_checkbox_pressed(settings_data.always_on_top)
			set_always_on_top(settings_data.always_on_top)
			system_tray.set_always_on_top_checked(settings_data.always_on_top)
		2:
			timer_and_buttons.position = timer_and_buttons.pan_limits(Vector2.ZERO)
			timer_and_buttons.find_quadrant_and_reorder()
			_on_draggable_position_changed()
		3:
			var screen: int = DisplayServer.window_get_current_screen()
			var count: int = DisplayServer.get_screen_count()
			screen += 1
			if screen >= count:
				screen = 0
			change_screen(screen)
		4:
			_on_exit_app_button_pressed()


func _on_status_indicator_pressed(_mouse_button: int, _mouse_position: Vector2i) -> void:
	maximize_window()


func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		play_pause_button.grab_focus(true)
