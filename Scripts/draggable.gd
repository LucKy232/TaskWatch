class_name Draggable extends Control

# Horizontal ordering, timer_and_side_buttons always facing nearest, left or right
@onready var segment_timer: TaskTimer = %SegmentTimer
@onready var buttons_v_box: VBoxContainer = %ButtonsVBox
# Vertical ordering, segment_timer always facing nearest: bottom or top
@onready var timer_and_side_buttons: HBoxContainer = $TimerAndSideButtons
@onready var buttons_h_box: HBoxContainer = %ButtonsHBox
var side_horizontal: SideH = SideH.LEFT
var side_vertical: SideV = SideV.TOP
var is_dragging: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO

signal position_changed

enum SideV {
	TOP,
	BOTTOM
}
enum SideH {
	LEFT,
	RIGHT
}


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
	scale = Vector2(s, s)
	position = pan_limits(position)


func get_mouse_passtrough() -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	var size_scale: Vector2 = size * scale
	corners.append(position)
	corners.append(position + Vector2(size_scale.x, 0.0))
	corners.append(position + size_scale)
	corners.append(position + Vector2(0.0, size_scale.y))
	if side_vertical == SideV.BOTTOM:
		corners.append(position)
	return corners


func find_quadrant_and_reorder() -> void:
	var window: Vector2 = get_window().size
	var half_size: Vector2 = size * scale * 0.5
	if position.x + half_size.x > window.x * 0.5:
		if side_horizontal != SideH.RIGHT:
			side_horizontal = SideH.RIGHT
			segment_timer.move_to_front()
	else:
		if side_horizontal != SideH.LEFT:
			side_horizontal = SideH.LEFT
			buttons_v_box.move_to_front()
	if position.y + half_size.y > window.y * 0.5:
		if side_vertical != SideV.BOTTOM:
			side_vertical = SideV.BOTTOM
			timer_and_side_buttons.move_to_front()
	else:
		if side_vertical != SideV.TOP:
			side_vertical = SideV.TOP
			buttons_h_box.move_to_front()


func reposition_timer(toggled_on: bool) -> void:
	var extra: float = floor(4.0 * scale.x)
	var offset_x: float = buttons_v_box.size.x * scale.x + extra if side_horizontal == SideH.RIGHT else 0.0
	var offset_y: float = buttons_h_box.size.y * scale.y + extra if side_vertical == SideV.BOTTOM else 0.0
	position += -Vector2(offset_x, offset_y) if toggled_on else Vector2(offset_x, offset_y)
	position_changed.emit()


func pan_limits(pos: Vector2) -> Vector2:
	var window: Vector2 = get_window().size
	var size_scale: Vector2 = scale * size
	if pos.x < 0.0:
		pos.x = 0.0
	elif pos.x + size_scale.x > window.x:
		pos.x = window.x - size_scale.x
	if pos.y < 0.0:
		pos.y = 0.0
	elif pos.y + size_scale.y > window.y:
		pos.y = window.y - size_scale.y
	return pos
