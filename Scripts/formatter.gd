class_name Formatter

static var WeekdayNamesLong: Dictionary[int, String] = {
	0: "Sunday",
	1: "Monday",
	2: "Tuesday",
	3: "Wednesday",
	4: "Thursday",
	5: "Friday",
	6: "Saturday"
}
static var WeekdayNamesShort: Dictionary[int, String] = {
	0: "Sun",
	1: "Mon",
	2: "Tue",
	3: "Wed",
	4: "Thu",
	5: "Fri",
	6: "Sat"
}
static var MonthNamesLong: Dictionary[int, String] = {
	1: "January",
	2: "February",
	3: "March",
	4: "April",
	5: "May",
	6: "June",
	7: "July",
	8: "August",
	9: "September",
	10: "October",
	11: "November",
	12: "December"
}
static var MonthNamesShort: Dictionary[int, String] = {
	1: "Jan",
	2: "Feb",
	3: "Mar",
	4: "Apr",
	5: "May",
	6: "Jun",
	7: "Jul",
	8: "Aug",
	9: "Sep",
	10: "Oct",
	11: "Nov",
	12: "Dec"
}
static var MonthDuration: Dictionary[int, int] = {
	1:  31,
	2:  28,	# Check leap year
	3:  31,
	4:  30,
	5:  31,
	6:  30,
	7:  31,
	8:  31,
	9:  30,
	10: 31,
	11: 30,
	12: 31,
}


static func get_month_day_count(datetime: Dictionary) -> int:
	if datetime["month"] == 2 and leap_year(datetime["year"]):
		return 29
	else:
		return MonthDuration[datetime["month"]]


static func format_duration(s: int) -> String:
	var hours = s / 3600
	var minutes = (s - 3600 * hours) / 60
	var text: String = ""
	if hours > 0:
		text = "%dh%dmin" % [hours, minutes]
	elif minutes > 0:
		text = "%dmin" % [minutes]
	else:
		text = "%ds" % [s]
	return text


# year, month, day, weekday
static func format_day(date_string: String) -> String:
	var dict: Dictionary = Time.get_datetime_dict_from_datetime_string(date_string, true)
	var day: int = dict["day"]
	var month: Time.Month = dict["month"]
	var weekday: Time.Weekday = dict["weekday"]
	var year: int = dict["year"]
	var day_suffix: String = "th"
	if day < 10 or day > 20:
		match day % 10:
			1:
				day_suffix = "st"
			2:
				day_suffix = "nd"
			3:
				day_suffix = "rd"
	return ("%s - %d%s %s %d" % [WeekdayNamesLong[weekday], day, day_suffix, MonthNamesShort[month], year])


static func less_than_days_ago(date: Dictionary, today: Dictionary, days: int) -> bool:
	var day_diff: int = Formatter.gregorian_date_to_julian_day_number(today) - Formatter.gregorian_date_to_julian_day_number(date)
	if day_diff <= days and day_diff >= 0:	# No future dates
		return true
	return false


static func leap_year(year: int) -> bool:
	if year % 4 == 0 and year != 2100:
		return true
	return false


static func format_week_from_string(date_string: String) -> String:
	var arr: PackedStringArray = date_string.split("-")
	return str("Week of %s/%s/%s" % [arr[2].lpad(2, "0"), arr[1].lpad(2, "0"), arr[0]])


static func format_month(date_string: String) -> String:
	var dict: Dictionary = Time.get_datetime_dict_from_datetime_string(date_string, true)
	var month: Time.Month = dict["month"]
	var year: int = dict["year"]
	return str("%s %d" % [MonthNamesLong[month], year])


# Returns the Monday date of this day's week
static func get_week_start_string(date_dict: Dictionary) -> String:
	if !date_dict.has("weekday"):
		printerr("Dictionary doesn't have weekday!")
		print_stack()
		return str("%d-%d-%d" % [date_dict["year"], date_dict["month"], date_dict["day"]])
	var weekday: int = date_dict["weekday"]
	match weekday:
		0:		# Sunday
			var new_date: Dictionary = rewind_date_dict(date_dict.duplicate(), 6)
			return str("%d-%d-%d" % [new_date["year"], new_date["month"], new_date["day"]])
		1:		# Monday
			return str("%d-%d-%d" % [date_dict["year"], date_dict["month"], date_dict["day"]])
		2, 3, 4, 5, 6:
			var new_date: Dictionary = rewind_date_dict(date_dict.duplicate(), weekday - 1)
			return str("%d-%d-%d" % [new_date["year"], new_date["month"], new_date["day"]])
	return str("%d-%d-%d" % [date_dict["year"], date_dict["month"], date_dict["day"]])


# Returns the Monday date of this day's week
static func get_week_start_dict(date_dict: Dictionary) -> Dictionary:
	if !date_dict.has("weekday"):
		printerr("Dictionary doesn't have weekday!")
		print_stack()
		return date_dict
	var weekday: int = date_dict["weekday"]
	match weekday:
		0:		# Sunday
			return rewind_date_dict(date_dict.duplicate(), 6)
		1:		# Monday
			return date_dict
		2, 3, 4, 5, 6:
			return rewind_date_dict(date_dict.duplicate(), weekday - 1)
	return date_dict


static func get_week_days_passed(today: Dictionary, week_start: Dictionary) -> Vector2i:
	var today_jdn: int = gregorian_date_to_julian_day_number(today)
	var monday_jdn: int = gregorian_date_to_julian_day_number(week_start)
	var diff: int = today_jdn - monday_jdn
	if diff >= 6:
		return Vector2i(7, 2)
	elif diff < 0:
		return Vector2i(0, 0)
	else:
		return Vector2i(diff + 1, maxi(diff + 1 - 5, 0))


static func get_month_days_passed(today: Dictionary, month_date: Dictionary) -> Vector2i:
	var month_string: String = str("%4d-%02d-01" % [month_date["year"], month_date["month"]])
	# Full month passed
	if today["year"] > month_date["year"] or (today["year"] == month_date["year"] and today["month"] > month_date["month"]):
		var full_day_count: int = get_month_day_count(month_date)
		return Vector2i(full_day_count, get_weekend_days_in_month(month_string, full_day_count))
	if (today["year"] == month_date["year"] and today["month"] == month_date["month"]):
		return Vector2i(today["day"], get_weekend_days_in_month(month_string, today["day"]))
	return Vector2i(0, 0)


# From the start of the month until day_count (inclusive)
static func get_weekend_days_in_month(month_string: String, day_count: int) -> int:
	var month_start_dict: Dictionary = Time.get_datetime_dict_from_datetime_string(month_string, true)
	var weekday: int = month_start_dict["weekday"]
	var extra_weekend: int = 0
	if day_count % 7 == 1:
		extra_weekend = 1 if (weekday == 0 or weekday == 6) else 0
	elif day_count % 7 == 2:
		extra_weekend = 1 if (weekday == 0 or weekday == 5) else (2 if (weekday == 6) else 0)
	elif day_count % 7 == 3:
		extra_weekend = 1 if (weekday == 0 or weekday == 4) else (2 if (weekday >= 5) else 0)
	elif day_count % 7 == 4:
		extra_weekend = 1 if (weekday == 0 or weekday == 3) else (2 if (weekday >= 4) else 0)
	elif day_count % 7 == 5:
		extra_weekend = 1 if (weekday == 0 or weekday == 2) else (2 if (weekday >= 3) else 0)
	elif day_count % 7 == 6:
		extra_weekend = 1 if (weekday == 0 or weekday == 1) else (2 if (weekday >= 2) else 0)
	return int(day_count / 7) * 2 + extra_weekend


static func rewind_date_dict(dict: Dictionary, rewind_days: int) -> Dictionary:
	if rewind_days > 28:
		push_error("I wasn't made for this!")
	if dict["day"] <= rewind_days:
		if dict["month"] == 1:
			dict["year"] -= 1
			dict["month"] = 12
			dict["day"] = dict["day"] + MonthDuration[12] - rewind_days
			return dict
		dict["month"] -= 1
		dict["day"] = dict["day"] + MonthDuration[dict["month"]] - rewind_days
		return dict
	dict["day"] -= rewind_days
	return dict


static func gregorian_date_to_julian_day_number(date: Dictionary) -> int:
	var m: int = floori((date["month"] - 14) / 12)
	var a: int = 1461 * (date["year"] + 4800 + m)
	var b: int = 367 * (date["month"] - 2 - (12 * m))
	var c: int = 3 * floori((date["year"] + 4900 + m) / 100)
	return floori(a / 4) + floori(b / 12) - floori(c / 4) + date["day"] - 32075
