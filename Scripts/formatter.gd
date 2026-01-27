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
static func format_day(s: String) -> String:
	var dict: Dictionary = Time.get_datetime_dict_from_datetime_string(s, true)
	var day: int = dict["day"]
	var month: Time.Month = dict["month"]
	var weekday: Time.Weekday = dict["weekday"]
	var year: int = dict["year"]
	var day_suffix: String = ""
	match day % 10:
		1:
			day_suffix = "st"
		2:
			day_suffix = "nd"
		3:
			day_suffix = "rd"
		_:
			day_suffix = "th"
	# Add 1st 2nd 3rd >=4th
	return ("%s - %s%s %s %s" % [WeekdayNamesLong[weekday], str(day), day_suffix, MonthNamesLong[month], str(year)])
