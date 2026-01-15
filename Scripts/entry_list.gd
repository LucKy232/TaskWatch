class_name EntryList extends Control

@export_file("*.tscn") var entry_scene
@export_file("*.tscn") var break_time_scene
@onready var project_name: LineEdit = %ProjectName
@onready var entries_container: VBoxContainer = %EntriesContainer
var entries: Dictionary[int, Entry]

signal project_name_changed


func new_entry() -> int:
	var new: Entry = load(entry_scene).instantiate() as Entry
	entries_container.add_child(new)
	var eid: int = entries.size()
	new.id = eid
	new.erase_entry.connect(_on_entry_erased)
	entries[eid] = new
	return eid


func populate_entries_from_dict(dict: Dictionary) -> void:
	for e in dict:
		var eid: int = new_entry()
		entries[eid].set_data_from_json(dict[e])


func new_entry_from_task(task: Task) -> void:
	var eid: int = new_entry()
	entries[eid].set_description(task.description)
	entries[eid].set_duration(task.time_elapsed / 1000)
	entries[eid].set_break_duration(task.break_time_elapsed / 1000)
	entries[eid].set_start_datetime(task.start_datetime)
	entries[eid].set_end_datetime(task.end_datetime)


func set_entry_data(eid: int, entry_dict: Dictionary) -> void:
	if entries.has(eid):
		entries[eid].set_duration(entry_dict["Duration"])


func set_project_name(_name: String) -> void:
	project_name.text = _name


func all_entries_to_json() -> Dictionary:
	var dict: Dictionary
	for eid in entries:
		dict[eid] = entries[eid].to_json()
	return dict


func _on_entry_erased(id: int) -> void:
	entries[id].queue_free()
	entries.erase(id)


func _on_project_name_text_changed(new_text: String) -> void:
	project_name_changed.emit(new_text)
