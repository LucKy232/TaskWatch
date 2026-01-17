class_name SystemTray extends Node

@export var tray_icon: CompressedTexture2D
@onready var menu: PopupMenu = $PopupMenu

var status_indicator: StatusIndicator = StatusIndicator.new()

signal system_tray_menu_pressed


func _ready() -> void:
	status_indicator.icon = tray_icon
	status_indicator.tooltip = "TaskWatch"
	
	menu = PopupMenu.new()
	add_child(status_indicator)
	status_indicator.add_child(menu)
	menu.add_item("Minimize", 0)
	menu.add_check_item("Always on top", 1)
	menu.set_item_checked(1, true)
	menu.add_separator()
	menu.add_item("Exit", 2)
	menu.id_pressed.connect(_on_system_tray_menu_pressed)
	status_indicator.menu = menu.get_path()


func _on_system_tray_menu_pressed(id: int) -> void:
	system_tray_menu_pressed.emit(id)


func set_always_on_top_checked(toggled_on: bool) -> void:
	menu.set_item_checked(1, toggled_on)
