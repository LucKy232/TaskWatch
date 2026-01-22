class_name EntryList extends Control

@export_file("*.tscn") var entry_scene
@export_file("*.tscn") var day_summary_scene
@onready var project_name: LineEdit = %ProjectName
@onready var entries_container: VBoxContainer = %EntriesContainer
var entries: Dictionary[int, Entry]
var summaries: Dictionary[String, DaySummary]
var latest_entry_id: int

var show_summaries: bool = false
signal project_name_changed


# TODO buttons instead
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_summaries"):
		show_summaries = !show_summaries
		for eid in entries:
			entries[eid].visible = !show_summaries
		for s in summaries:
			summaries[s].visible = show_summaries
	if Input.is_action_just_pressed("build_summaries"):
		clear_summaries()
		build_summaries()


func clear_summaries() -> void:
	for d in summaries:
		summaries[d].queue_free()
	summaries.clear()


# TODO only clear and rebuild today
func build_summaries() -> void:
	#var today: String = Time.get_date_string_from_system()
	for eid in entries:
		var date: String = entries[eid].start_datetime.split(" ")[0]
		if !summaries.has(date):
			var new: DaySummary = load(day_summary_scene).instantiate() as DaySummary
			entries_container.add_child(new)
			new.set_date(date)
			new.add_active_duration(entries[eid].duration)
			new.add_break_duration(entries[eid].break_duration)
			new.visible = show_summaries
			summaries[date] = new
		else:
			summaries[date].add_active_duration(entries[eid].duration)
			summaries[date].add_break_duration(entries[eid].break_duration)


func new_entry() -> int:
	var new: Entry = load(entry_scene).instantiate() as Entry
	entries_container.add_child(new)
	var eid: int = entries.size()
	new.id = eid
	new.erase_entry.connect(_on_entry_erased)
	entries[eid] = new
	latest_entry_id = eid
	return eid


func populate_entries_from_dict(dict: Dictionary) -> void:
	project_name.text = dict["ProjectName"]
	for e in dict["Entries"]:
		var eid: int = new_entry()
		entries[eid].set_data_from_json(dict["Entries"][e])


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


func erase_latest_entry() -> void:
	_on_entry_erased(latest_entry_id)
	latest_entry_id = -1


func _on_entry_erased(id: int) -> void:
	if !entries.has(id):
		print("No id")
		return
	entries[id].queue_free()
	entries.erase(id)


func _on_project_name_text_changed(new_text: String) -> void:
	project_name_changed.emit(new_text)
