class_name EntryList extends Control

@export var button_animation_time: float = 0.2
@onready var project_name: LineEdit = %ProjectName
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var entries_container: VBoxContainer = %EntriesContainer
@onready var scroll_to_bottom_timer: Timer = $ScrollToBottomTimer
# ViewMode Buttons
@onready var view_all_button: Button = %ViewAll
@onready var view_today_button: Button = %ViewToday
@onready var view_this_week_button: Button = %ViewThisWeek
@onready var view_this_month_button: Button = %ViewThisMonth
@onready var view_last_7_button: Button = %ViewLast7
@onready var view_last_30_button: Button = %ViewLast30
@onready var view_summary_daily_button: Button = %ViewSummaryDaily
@onready var view_summary_weekly_button: Button = %ViewSummaryWeekly
@onready var view_summary_monthly_button: Button = %ViewSummaryMonthly
var entries: Dictionary[int, Entry]
var summaries_day: Dictionary[String, DaySummary]
var summaries_week: Dictionary[String, WeekSummary]
var summaries_month: Dictionary[String, MonthSummary]
var latest_entry_id: int
var view_mode: ViewMode
var button_on_tween: Tween
var button_off_tween: Tween
var entry_scene: PackedScene = preload(E.ENTRY_SCENE)
var day_summary_scene: PackedScene = preload(E.DAY_SUMMARY_SCENE)
var week_summary_scene: PackedScene = preload(E.WEEK_SUMMARY_SCENE)
var month_summary_scene: PackedScene = preload(E.MONTH_SUMMARY_SCENE)
var ensure_visible: bool = false
var ensure_visible_control: Control

signal project_name_changed

enum ViewMode {
	ALL,
	TODAY,
	THIS_WEEK,
	THIS_MONTH,
	LAST_7,
	LAST_30,
	DAY_SUMMARY,
	WEEK_SUMMARY,
	MONTH_SUMMARY,
}


func _ready() -> void:
	view_all_button.set_pressed_no_signal(true)
	toggle_button_on_tween(view_all_button)


func _process(_delta: float) -> void:
	if ensure_visible and ensure_visible_control:
		scroll_container.ensure_control_visible.call_deferred(ensure_visible_control)
		ensure_visible = false


func new_entry() -> int:
	var new: Entry = entry_scene.instantiate() as Entry
	entries_container.add_child(new)
	var eid: int = entries.size()
	new.id = eid
	new.erase_entry.connect(_on_entry_erased)
	entries[eid] = new
	latest_entry_id = eid
	return eid


func new_entry_from_task(task: Task) -> void:
	var eid: int = new_entry()
	entries[eid].set_description(task.description)
	entries[eid].set_duration(task.time_elapsed / 1000)
	entries[eid].set_break_duration(task.break_time_elapsed / 1000)
	entries[eid].set_start_datetime(task.start_datetime)
	entries[eid].set_end_datetime(task.end_datetime)
	entries[eid].visible = bool(view_mode == ViewMode.ALL || view_mode == ViewMode.TODAY || view_mode == ViewMode.THIS_WEEK || view_mode == ViewMode.THIS_MONTH)
	add_entry_to_day_summary(entries[eid], true)
	add_entry_to_week_summary(entries[eid], true)
	add_entry_to_month_summary(entries[eid], true)
	scroll_to_bottom_timer.start()


func populate_entries_from_dict(dict: Dictionary) -> void:
	project_name.text = dict["ProjectName"]
	for e in dict["Entries"]:
		var eid: int = new_entry()
		entries[eid].set_data_from_json(dict["Entries"][e])
		entries[eid].visible = bool(view_mode == ViewMode.ALL || view_mode == ViewMode.TODAY || view_mode == ViewMode.THIS_WEEK || view_mode == ViewMode.THIS_MONTH)


func build_all_summaries() -> void:
	clear_summaries_day()
	clear_summaries_week()
	clear_summaries_month()
	build_summaries_day()
	build_summaries_week()
	build_summaries_month()
	update_summaries_day()
	update_summaries_week()
	update_summaries_month()


func set_entry_data(eid: int, entry_dict: Dictionary) -> void:
	if entries.has(eid):
		entries[eid].set_duration(entry_dict["Duration"])


func set_project_name(_name: String) -> void:
	project_name.text = _name


func get_last_entry_task_description() -> String:
	if entries.size() == 0:
		return ""
	var last_entry: Entry = entries[entries.keys()[-1]]
	return last_entry.get_description()


func all_entries_to_json() -> Dictionary:
	var dict: Dictionary
	for eid in entries:
		dict[eid] = entries[eid].to_json()
	return dict


func erase_latest_entry() -> void:
	_on_entry_erased(latest_entry_id)
	latest_entry_id = -1


func change_view_mode(previous: ViewMode) -> void:
	hide_previous_summaries(previous)
	match view_mode:
		ViewMode.ALL:
			for eid in entries:
				entries[eid].visible = true
		ViewMode.TODAY:
			var today_date: Dictionary = Time.get_date_dict_from_system()
			var today: int = today_date["day"]
			var this_month: int = today_date["month"]
			var this_year: int = today_date["year"]
			for eid in entries:
				var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(entries[eid].start_datetime, false)
				var entry_day: int = datetime["day"]
				var entry_month: int = datetime["month"]
				var entry_year: int = datetime["year"]
				entries[eid].visible = bool(today == entry_day and this_month == entry_month and this_year == entry_year)
		ViewMode.THIS_WEEK:
			var today_date: Dictionary = Time.get_date_dict_from_system()
			var today_week_day: int = today_date["weekday"]
			for eid in entries:
				var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(entries[eid].start_datetime, false)
				entries[eid].visible = Formatter.less_than_days_ago(datetime, today_date, today_week_day - 1 if today_week_day > 0 else 6)
		ViewMode.THIS_MONTH:
			var today_date: Dictionary = Time.get_date_dict_from_system()
			var this_month: int = today_date["month"]
			var this_year: int = today_date["year"]
			for eid in entries:
				var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(entries[eid].start_datetime, false)
				var entry_month: int = datetime["month"]
				var entry_year: int = datetime["year"]
				entries[eid].visible = bool(this_month == entry_month and this_year == entry_year)
		ViewMode.LAST_7:
			var today_date: Dictionary = Time.get_date_dict_from_system()
			for eid in entries:
				var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(entries[eid].start_datetime, false)
				entries[eid].visible = Formatter.less_than_days_ago(datetime, today_date, 6)
		ViewMode.LAST_30:
			var today_date: Dictionary = Time.get_date_dict_from_system()
			for eid in entries:
				var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(entries[eid].start_datetime, false)
				entries[eid].visible = Formatter.less_than_days_ago(datetime, today_date, 29)
		ViewMode.DAY_SUMMARY:
			for eid in entries:
				entries[eid].visible = false
			for s in summaries_day:
				summaries_day[s].visible = true
		ViewMode.WEEK_SUMMARY:
			for eid in entries:
				entries[eid].visible = false
			for w in summaries_week:
				summaries_week[w].visible = true
		ViewMode.MONTH_SUMMARY:
			for eid in entries:
				entries[eid].visible = false
			for m in summaries_month:
				summaries_month[m].visible = true


func hide_previous_summaries(previous_view: ViewMode) -> void:
	match previous_view:
		ViewMode.DAY_SUMMARY:
			for d in summaries_day:
				summaries_day[d].visible = false
		ViewMode.WEEK_SUMMARY:
			for w in summaries_week:
				summaries_week[w].visible = false
		ViewMode.MONTH_SUMMARY:
			for m in summaries_month:
				summaries_month[m].visible = false


func build_summaries_day() -> void:
	for eid in entries:
		add_entry_to_day_summary(entries[eid])


func add_entry_to_day_summary(e: Entry, update_text: bool = false) -> void:
	var date_string: String = e.start_datetime.split(" ")[0]
	if !summaries_day.has(date_string):
		var new: DaySummary = day_summary_scene.instantiate() as DaySummary
		entries_container.add_child(new)
		new.name = "DaySummary"
		new.set_date(date_string)
		new.visible = bool(view_mode == ViewMode.DAY_SUMMARY)
		new.full_task_list_toggled.connect(_on_entry_resized.bind(new))
		summaries_day[date_string] = new
	summaries_day[date_string].add_entry(e)
	if update_text:
		summaries_day[date_string].update_text()


func build_summaries_week() -> void:
	for eid in entries:
		add_entry_to_week_summary(entries[eid])


func add_entry_to_week_summary(e: Entry, update_text: bool = false) -> void:
	var today_date: Dictionary = Time.get_date_dict_from_system()
	var date_dict: Dictionary = Time.get_datetime_dict_from_datetime_string(e.start_datetime, true)
	var date_string: String = e.start_datetime.split(" ")[0]
	var week_dict: Dictionary = Formatter.get_week_start_dict(date_dict)
	var week_string: String = str("%d-%d-%d" % [week_dict["year"], week_dict["month"], week_dict["day"]])
	if !summaries_week.has(week_string):
		var new: WeekSummary = week_summary_scene.instantiate() as WeekSummary
		entries_container.add_child(new)
		new.name = "WeekSummary"
		new.set_date(week_string)
		var days_passed: Vector2i = Formatter.get_week_days_passed(today_date, week_dict)
		new.set_days_passed(days_passed.x, days_passed.y)
		new.visible = bool(view_mode == ViewMode.WEEK_SUMMARY)
		new.full_task_list_toggled.connect(_on_entry_resized.bind(new))
		summaries_week[week_string] = new
	summaries_week[week_string].add_entry(e, date_string)
	if update_text:
		summaries_week[week_string].update_text()


func build_summaries_month() -> void:
	for eid in entries:
		add_entry_to_month_summary(entries[eid])


func add_entry_to_month_summary(e: Entry, update_text: bool = false) -> void:
	var today_date: Dictionary = Time.get_date_dict_from_system()
	var date_dict: Dictionary = Time.get_datetime_dict_from_datetime_string(e.start_datetime, true)
	var date_string: String = e.start_datetime.split(" ")[0]
	var month_string: String = str("%s-%s" % [date_string.split("-")[0], date_string.split("-")[1]])
	if !summaries_month.has(month_string):
		var new: MonthSummary = month_summary_scene.instantiate() as MonthSummary
		entries_container.add_child(new)
		new.name = "MonthSummary"
		new.set_date(date_string)
		var days_passed: Vector2i = Formatter.get_month_days_passed(today_date, date_dict)
		new.set_days_passed(days_passed.x, days_passed.y)
		new.visible = bool(view_mode == ViewMode.MONTH_SUMMARY)
		new.full_task_list_toggled.connect(_on_entry_resized.bind(new))
		summaries_month[month_string] = new
	summaries_month[month_string].add_entry(e, date_string)
	if update_text:
		summaries_month[month_string].update_text()


func update_summaries_day() -> void:
	for day in summaries_day:
		summaries_day[day].update_text()


func update_summaries_week() -> void:
	for week in summaries_week:
		summaries_week[week].update_text()


func update_summaries_month() -> void:
	for month in summaries_month:
		summaries_month[month].update_text()


func clear_summaries_day() -> void:
	for d in summaries_day:
		summaries_day[d].queue_free()
	summaries_day.clear()


func clear_summaries_week() -> void:
	for w in summaries_week:
		summaries_week[w].queue_free()
	summaries_week.clear()


func clear_summaries_month() -> void:
	for m in summaries_month:
		summaries_month[m].queue_free()
	summaries_month.clear()


func remove_entry_from_summaries(e: Entry) -> void:
	var date_string: String = e.start_datetime.split(" ")[0]
	var date_dict: Dictionary = Time.get_datetime_dict_from_datetime_string(e.start_datetime, true)
	var week_dict: Dictionary = Formatter.get_week_start_dict(date_dict)
	var week_string: String = str("%d-%d-%d" % [week_dict["year"], week_dict["month"], week_dict["day"]])
	var month_string: String = str("%s-%s" % [date_string.split("-")[0], date_string.split("-")[1]])
	if summaries_day.has(date_string):
		summaries_day[date_string].remove_entry(e)
		if summaries_day[date_string].active_duration < 1 and summaries_day[date_string].break_duration < 1:
			summaries_day[date_string].queue_free()
			summaries_day.erase(date_string)
		else:
			summaries_day[date_string].update_text()
	if summaries_week.has(week_string):
		summaries_week[week_string].remove_entry(e, date_string)
		summaries_week[week_string].update_text()
	if summaries_month.has(month_string):
		summaries_month[month_string].remove_entry(e, date_string)
		summaries_month[month_string].update_text()


func toggle_button_on_tween(button: Button) -> void:
	if button_on_tween and button_on_tween.is_running():
		button_on_tween.custom_step(button_animation_time)
		button_on_tween.stop()
	button_on_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	button_on_tween.tween_property(button, "offset_transform_position_ratio:y", 0.3, button_animation_time)


func toggle_button_off_tween(button: Button) -> void:
	if button_off_tween and button_off_tween.is_running():
		button_off_tween.custom_step(button_animation_time)
		button_off_tween.stop()
	button_off_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	button_off_tween.tween_property(button, "offset_transform_position_ratio:y", 0.0, button_animation_time)


func _on_entry_erased(id: int) -> void:
	if !entries.has(id):
		print("No id")
		return
	remove_entry_from_summaries(entries[id])
	entries[id].queue_free()
	entries.erase(id)


func _on_project_name_text_changed(new_text: String) -> void:
	project_name_changed.emit(new_text)


func _on_view_all_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.ALL:
		view_mode = ViewMode.ALL
		change_view_mode(previous)
		toggle_button_on_tween(view_all_button)
	if !toggled_on:
		toggle_button_off_tween(view_all_button)
	scroll_to_bottom_timer.start()


func _on_view_today_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.TODAY:
		view_mode = ViewMode.TODAY
		change_view_mode(previous)
		toggle_button_on_tween(view_today_button)
	if !toggled_on:
		toggle_button_off_tween(view_today_button)
	scroll_to_bottom_timer.start()


func _on_view_this_week_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.THIS_WEEK:
		view_mode = ViewMode.THIS_WEEK
		change_view_mode(previous)
		toggle_button_on_tween(view_this_week_button)
	if !toggled_on:
		toggle_button_off_tween(view_this_week_button)
	scroll_to_bottom_timer.start()


func _on_view_this_month_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.THIS_MONTH:
		view_mode = ViewMode.THIS_MONTH
		change_view_mode(previous)
		toggle_button_on_tween(view_this_month_button)
	if !toggled_on:
		toggle_button_off_tween(view_this_month_button)
	scroll_to_bottom_timer.start()


func _on_view_last_7_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.LAST_7:
		view_mode = ViewMode.LAST_7
		change_view_mode(previous)
		toggle_button_on_tween(view_last_7_button)
	if !toggled_on:
		toggle_button_off_tween(view_last_7_button)
	scroll_to_bottom_timer.start()


func _on_view_last_30_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.LAST_30:
		view_mode = ViewMode.LAST_30
		change_view_mode(previous)
		toggle_button_on_tween(view_last_30_button)
	if !toggled_on:
		toggle_button_off_tween(view_last_30_button)
	scroll_to_bottom_timer.start()


func _on_view_summary_daily_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.DAY_SUMMARY:
		view_mode = ViewMode.DAY_SUMMARY
		change_view_mode(previous)
		toggle_button_on_tween(view_summary_daily_button)
	if !toggled_on:
		toggle_button_off_tween(view_summary_daily_button)
	scroll_to_bottom_timer.start()


func _on_view_summary_weekly_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.WEEK_SUMMARY:
		view_mode = ViewMode.WEEK_SUMMARY
		change_view_mode(previous)
		toggle_button_on_tween(view_summary_weekly_button)
	if !toggled_on:
		toggle_button_off_tween(view_summary_weekly_button)
	scroll_to_bottom_timer.start()


func _on_view_summary_monthly_toggled(toggled_on: bool) -> void:
	var previous: ViewMode = view_mode
	if toggled_on and previous != ViewMode.MONTH_SUMMARY:
		view_mode = ViewMode.MONTH_SUMMARY
		change_view_mode(previous)
		toggle_button_on_tween(view_summary_monthly_button)
	if !toggled_on:
		toggle_button_off_tween(view_summary_monthly_button)
	scroll_to_bottom_timer.start()


## Can't scroll to the bottom of the ScrollContainer if changing its size in the same frame / deferred
## wait with timer for its attributes to be set
func _on_scroll_to_bottom_timer_timeout() -> void:
	scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value)


func _on_visibility_changed() -> void:
	if visible:
		scroll_to_bottom_timer.start()


func _on_entry_resized(control: Control) -> void:
	ensure_visible = true
	ensure_visible_control = control
