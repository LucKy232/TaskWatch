class_name SettingsPanel extends Control

@onready var color_picker_button: ColorPickerButton = %ColorPickerButton
@onready var bg_color_picker_button: ColorPickerButton = %BGColorPickerButton
@onready var scale_option_button: OptionButton = %ScaleOptionButton
@onready var display_type_option_button: OptionButton = %DisplayTypeOptionButton
@onready var unlit_segments_checkbox: CheckBox = %UnlitSegmentsCheckbox
@onready var always_on_top_checkbox: CheckBox = %AlwaysOnTopCheckbox
@onready var show_seconds_checkbox: CheckBox = %ShowSecondsCheckbox
@onready var version_number: Label = $VersionNumber

var popup_1: PopupPanel	## color_picker_button popup
var popup_2: PopupPanel	## bg_color_picker_button popup
var popup_3: PopupMenu	## scale_option_button popup
var picked_color: Color
var picked_bg_color: Color

signal color_changed 
signal bg_color_changed
signal scale_changed
signal unlit_segments_toggled
signal always_on_top_toggled
signal color_picker_toggled
signal show_seconds_toggled
signal display_type_changed


func _ready() -> void:
	popup_1 = color_picker_button.get_popup()
	popup_2 = bg_color_picker_button.get_popup()
	popup_3 = scale_option_button.get_popup()
	popup_1.visibility_changed.connect(_on_color_picker_popup)
	popup_2.visibility_changed.connect(_on_color_picker_popup)
	popup_3.visibility_changed.connect(_on_color_picker_popup)
	var app_version: String = ProjectSettings.get_setting("application/config/version")
	version_number.text = ("v%s" % app_version)
	populate_scale_option_button()
	populate_display_type_option_button()


func populate_scale_option_button() -> void:
	for s in E.scale_dict:
		scale_option_button.add_item("%0.0f%%" % [E.scale_dict[s] * 100.0])


func populate_display_type_option_button() -> void:
	for type_name in E.DisplayTypeNames.values():
		display_type_option_button.add_item(type_name)


func set_digit_color(c: Color) -> void:
	color_picker_button.color = c


func set_background_color_picker_color(c: Color) -> void:
	bg_color_picker_button.color = c


func set_unlit_checkbox_pressed(toggled_on: bool) -> void:
	unlit_segments_checkbox.set_pressed_no_signal(toggled_on)


func set_always_on_top_checkbox_pressed(toggled_on: bool) -> void:
	always_on_top_checkbox.set_pressed_no_signal(toggled_on)


func set_show_seconds_checkbox_pressed(toggled_on: bool) -> void:
	show_seconds_checkbox.set_pressed_no_signal(toggled_on)


func set_picked_scale(s: float) -> void:
	for i in E.scale_dict:
		if E.scale_dict[i] == s:
			scale_option_button.selected = i


func set_picked_display_type(type: E.DisplayType) -> void:
	display_type_option_button.selected = type as int


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
	if E.scale_dict.has(index):
		scale_changed.emit(E.scale_dict[index])


func _on_display_type_option_button_item_selected(index: int) -> void:
	display_type_changed.emit(index as E.DisplayType)


func _on_unlit_segments_checkbox_toggled(toggled_on: bool) -> void:
	unlit_segments_toggled.emit(toggled_on)


func _on_always_on_top_checkbox_toggled(toggled_on: bool) -> void:
	always_on_top_toggled.emit(toggled_on)


func _on_show_seconds_checkbox_toggled(toggled_on: bool) -> void:
	show_seconds_toggled.emit(toggled_on)
