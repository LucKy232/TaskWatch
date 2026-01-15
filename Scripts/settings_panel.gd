class_name SettingsPanel extends Control

#@onready var color_picker_button: ColorPickerButton = %ColorPickerButton
#@onready var bg_color_picker_button: ColorPickerButton = %BGColorPickerButton
#@onready var scale_option_button: OptionButton = %ScaleOptionButton
#@onready var unlit_segments_checkbox: CheckBox = %UnlitSegmentsCheckbox

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
