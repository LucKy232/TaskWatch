class_name Formatter

static func format_duration(s: int) -> String:
	var hours = s / 3600
	var minutes = s / 60
	var text: String = ""
	if hours > 0:
		text = "%dh%dmin" % [hours, minutes]
	elif minutes > 0:
		text = "%dmin" % [minutes]
	else:
		text = "%ds" % [s]
	return text
