class_name Draggable extends VBoxContainer

@export var screen_limit_margin: Vector2i = Vector2i.ONE * 2
@onready var task_timer: TaskTimer = %TaskTimer
@onready var side_buttons_grid: GridContainer = %SideButtonsGrid
@onready var timer_and_side_buttons: HBoxContainer = %TimerAndSideButtons
@onready var top_buttons_control: Control = %TopButtonsControl
@onready var top_buttons_h_box: HBoxContainer = %TopButtonsHBox
@onready var task_description_line_edit: LineEdit = %TaskDescriptionLineEdit
@onready var task_timer_control: Control = %TaskTimerControl
@onready var play_pause_button_control: Control = %PlayPauseButtonControl
@onready var stop_button_control: Control = %StopButtonControl
@onready var show_clock_button_control: Control = %ShowClockButtonControl
@onready var play_pause_button: Button = %PlayPauseButton
@onready var stop_button: Button = %StopButton
@onready var show_clock_button: Button = %ShowClockButton

var side_horizontal: E.SideH = E.SideH.LEFT
var side_vertical: E.SideV = E.SideV.TOP
var is_dragging: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var adjust_next_frame: bool = false
var changed_scale_while_buttons_hidden = false

signal position_changed


func _process(_delta: float) -> void:
	if adjust_next_frame:
		adjust_sizes()
		adjust_next_frame = false


# Set sizes based on previously applied sizes & scales
func adjust_sizes() -> void:
	top_buttons_h_box.size.x = top_buttons_control.size.x / top_buttons_h_box.scale.x
	var vert_size: float = task_timer.size.y * task_timer.scale.y - 1.0
	task_timer_control.size.y = vert_size
	side_buttons_grid.size.y = vert_size
	if side_buttons_grid.columns == 3:
		play_pause_button_control.size.y = vert_size
		stop_button_control.size.y = vert_size
		show_clock_button_control.size.y = vert_size
		play_pause_button.size.y = vert_size / play_pause_button.scale.y
		stop_button.size.y = vert_size / stop_button.scale.y
		show_clock_button.size.y = vert_size / show_clock_button.scale.y


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			set_default_cursor_shape(Control.CURSOR_DRAG)
			drag_start_mouse_pos = event.position
		if event.is_released():
			is_dragging = false
			set_default_cursor_shape(Control.CURSOR_ARROW)
	
	if event is InputEventMouseMotion and is_dragging:
		var move: Vector2 = (event.position - drag_start_mouse_pos) * scale
		position = pan_limits(position + move)
		find_quadrant_and_reorder()
		position_changed.emit()


func set_timer_scale(s: float) -> void:
	if s < 0.7:
		side_buttons_grid.columns = 3
	else:
		side_buttons_grid.columns = 1
		play_pause_button_control.size = Vector2.ZERO
		stop_button_control.size = Vector2.ZERO
		show_clock_button_control.size = Vector2.ZERO
		play_pause_button.size = Vector2.ZERO
		stop_button.size = Vector2.ZERO
		show_clock_button.size = Vector2.ZERO
	var other_scale = remap(s, 0.125, 1.0, 0.33, 1.0)
	scale_other(other_scale)
	task_timer.scale = Vector2.ONE * s
	task_timer_control.custom_minimum_size = task_timer.size * s
	size = Vector2.ZERO
	position = pan_limits(position)


func scale_other(s: float) -> void:
	top_buttons_h_box.scale = Vector2.ONE * s
	top_buttons_h_box.position = Vector2.ZERO
	top_buttons_control.custom_minimum_size.y = top_buttons_h_box.size.y * s
	play_pause_button.scale = Vector2.ONE * s
	stop_button.scale = Vector2.ONE * s
	show_clock_button.scale = Vector2.ONE * s
	play_pause_button_control.custom_minimum_size = play_pause_button.size * s
	stop_button_control.custom_minimum_size = stop_button.size * s
	show_clock_button_control.custom_minimum_size = show_clock_button.size * s
	add_theme_constant_override("separation", int(4.0 * s))
	if !top_buttons_control.visible:
		changed_scale_while_buttons_hidden = true
	else:
		set_deferred("adjust_next_frame", true)


func get_mouse_passtrough() -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	var size_scale: Vector2 = size * scale
	corners.append(position)
	corners.append(position + Vector2(size_scale.x, 0.0))
	corners.append(position + size_scale)
	corners.append(position + Vector2(0.0, size_scale.y))
	if side_vertical == E.SideV.BOTTOM:
		corners.append(position)
	return corners


func find_quadrant_and_reorder() -> void:
	var window: Vector2 = get_window().size
	var half_size: Vector2 = size * scale * 0.5
	if position.x + half_size.x > window.x * 0.5:
		if side_horizontal != E.SideH.RIGHT:
			side_horizontal = E.SideH.RIGHT
			task_timer_control.move_to_front()
	else:
		if side_horizontal != E.SideH.LEFT:
			side_horizontal = E.SideH.LEFT
			side_buttons_grid.move_to_front()
	if position.y + half_size.y > window.y * 0.5:
		if side_vertical != E.SideV.BOTTOM:
			side_vertical = E.SideV.BOTTOM
			timer_and_side_buttons.move_to_front()
	else:
		if side_vertical != E.SideV.TOP:
			side_vertical = E.SideV.TOP
			top_buttons_control.move_to_front()


func reposition_timer(toggled_on: bool) -> void:
	var offset_x: float = side_buttons_grid.size.x + timer_and_side_buttons.get_theme_constant("separation") if side_horizontal == E.SideH.RIGHT else 0.0
	var offset_y: float = top_buttons_control.size.y + get_theme_constant("separation") if side_vertical == E.SideV.BOTTOM else 0.0
	var move: Vector2 = -Vector2(offset_x, offset_y) if toggled_on else Vector2(offset_x, offset_y)
	position += move
	position_changed.emit()


func reposition_along_corners(right_edge: float, bottom_edge: float) -> void:
	var to_right_edge: float = global_position.x + size.x - right_edge if side_horizontal == E.SideH.RIGHT else 0.0
	var to_bottom_edge: float = global_position.y + size.y - bottom_edge if side_vertical == E.SideV.BOTTOM else 0.0
	position = pan_limits(position - Vector2(floorf(to_right_edge), floorf(to_bottom_edge)))
	position_changed.emit()


func pan_limits(pos: Vector2) -> Vector2:
	var window: Vector2 = get_window().size + screen_limit_margin
	var size_scale: Vector2 = scale * size
	if pos.x < 0.0:
		pos.x = 0.0
	elif pos.x + size_scale.x > window.x:
		pos.x = window.x - size_scale.x
	if pos.y < 0.0:
		pos.y = 0.0
	elif pos.y + size_scale.y > window.y:
		pos.y = window.y - size_scale.y
	#printt(window, pos) 	# NOTE window size.y may change every frame by 2 px 1038 - 1040 until minimized
	return pos


func _on_top_buttons_control_visibility_changed() -> void:
	if !is_node_ready():
		return
	if top_buttons_control.visible and changed_scale_while_buttons_hidden:
		set_deferred("adjust_next_frame", true)
		changed_scale_while_buttons_hidden = false
