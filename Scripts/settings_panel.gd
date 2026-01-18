class_name SettingsPanel extends Control

@onready var color_picker_button: ColorPickerButton = %ColorPickerButton
@onready var bg_color_picker_button: ColorPickerButton = %BGColorPickerButton
@onready var scale_option_button: OptionButton = %ScaleOptionButton
@onready var unlit_segments_checkbox: CheckBox = %UnlitSegmentsCheckbox
@onready var always_on_top_checkbox: CheckBox = %AlwaysOnTopCheckbox
@onready var version_number: Label = $VersionNumber

var popup_1: PopupPanel
var popup_2: PopupPanel
var popup_3: PopupMenu
var picked_color: Color
var picked_bg_color: Color
var scale_dict: Dictionary[int, float] = {
	0: 0.10,
	1: 0.20,
	2: 0.30,
	3: 0.40,
	4: 0.50,
	5: 0.75,
	6: 1.00,
	7: 1.25,
	8: 1.50,
	9: 2.00,
	10: 3.00,
}

signal color_changed 
signal bg_color_changed
signal scale_changed
signal unlit_segments_toggled
signal always_on_top_toggled
signal color_picker_toggled

func _ready() -> void:
	popup_1 = color_picker_button.get_popup()
	popup_2 = bg_color_picker_button.get_popup()
	popup_3 = scale_option_button.get_popup()
	popup_1.visibility_changed.connect(_on_color_picker_popup)
	popup_2.visibility_changed.connect(_on_color_picker_popup)
	popup_3.visibility_changed.connect(_on_color_picker_popup)
	var app_version: String = ProjectSettings.get_setting("application/config/version")
	version_number.text = ("v%s" % app_version)


func set_digit_color(c: Color) -> void:
	color_picker_button.color = c


func set_background_color(c: Color) -> void:
	bg_color_picker_button.color = c


func set_unlit_checkbox_pressed(toggled_on: bool) -> void:
	unlit_segments_checkbox.set_pressed_no_signal(toggled_on)


func set_always_on_top_checkbox_pressed(toggled_on: bool) -> void:
	always_on_top_checkbox.set_pressed_no_signal(toggled_on)


func set_picked_scale(s: float) -> void:
	for i in scale_dict:
		if scale_dict[i] == s:
			scale_option_button.selected = i


func scale_up() -> void:
	var id: int = scale_option_button.get_selected_id()
	id = clampi(id + 1, 0, scale_option_button.item_count - 1)
	scale_option_button.select(id)
	_on_scale_option_button_item_selected(id)


func scale_down() -> void:
	var id: int = scale_option_button.get_selected_id()
	id = clampi(id - 1, 0, scale_option_button.item_count - 1)
	scale_option_button.select(id)
	_on_scale_option_button_item_selected(id)


func get_color_picker_passtrough() -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	if popup_1.is_visible():
		var v2p: Vector2 = Vector2(popup_1.position)
		var v2s: Vector2 = Vector2(popup_1.size)
		corners.append(v2p)
		corners.append(v2p + Vector2(v2s.x, 0.0))
		corners.append(v2p + v2s)
		corners.append(v2p + Vector2(0.0, v2s.y))
	elif popup_2.is_visible():
		var v2p: Vector2 = Vector2(popup_2.position)
		var v2s: Vector2 = Vector2(popup_2.size)
		corners.append(v2p)
		corners.append(v2p + Vector2(v2s.x, 0.0))
		corners.append(v2p + v2s)
		corners.append(v2p + Vector2(0.0, v2s.y))
	return corners


func get_option_button_passtrough() -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	if popup_3.is_visible():
		var v2p: Vector2 = Vector2(popup_3.position)
		var v2s: Vector2 = Vector2(popup_3.size)
		corners.append(v2p)
		corners.append(v2p + Vector2(v2s.x, 0.0))
		corners.append(v2p + v2s)
		corners.append(v2p + Vector2(0.0, v2s.y))
	return corners


func _on_color_picker_popup() -> void:
	color_picker_toggled.emit()


func _on_color_picker_button_color_changed(color: Color) -> void:
	picked_color = color


func _on_color_picker_button_popup_closed() -> void:
	color_changed.emit(picked_color)


func _on_bg_color_picker_button_color_changed(color: Color) -> void:
	picked_bg_color = color


func _on_bg_color_picker_button_popup_closed() -> void:
	bg_color_changed.emit(picked_bg_color)


func _on_scale_option_button_item_selected(index: int) -> void:
	if scale_dict.has(index):
		scale_changed.emit(scale_dict[index])


func _on_unlit_segments_checkbox_toggled(toggled_on: bool) -> void:
	unlit_segments_toggled.emit(toggled_on)


func _on_always_on_top_checkbox_toggled(toggled_on: bool) -> void:
	always_on_top_toggled.emit(toggled_on)
