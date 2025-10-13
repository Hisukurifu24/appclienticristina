class_name Date

var day: int
var month: int
var year: int

func _init(_day: int = 1, _month: int = 1, _year: int = 2000):
	day = _day
	month = _month
	year = _year

static func is_valid_date(_year: int, _month: int, _day: int) -> bool:
	if _year < 1 or _month < 1 or _month > 12 or _day < 1:
		return false
	if _month == 2:
		# Controlla gli anni bisestili
		if is_leap_year(_year):
			return _day <= 29
		return _day <= 28
	if _month in [4, 6, 9, 11]:
		return _day <= 30
	return _day <= 31

static func is_leap_year(_year: int) -> bool:
	return _year % 4 == 0 and (_year % 100 != 0 or _year % 400 == 0)

static func today() -> Date:
	var current_time: Dictionary = Time.get_date_dict_from_system()
	return Date.new(current_time.day, current_time.month, current_time.year)

func is_before(other: Date) -> bool:
	if year != other.year:
		return year < other.year
	if month != other.month:
		return month < other.month
	return day < other.day

func add_days(days: int) -> Date:
	var new_day = day + days
	var new_month = month
	var new_year = year
	
	if days >= 0:
		# Handle positive days
		while true:
			var days_in_month = get_days_in_month(new_year, new_month)
			if new_day <= days_in_month:
				break
			new_day -= days_in_month
			new_month += 1
			if new_month > 12:
				new_month = 1
				new_year += 1
	else:
		# Handle negative days
		while new_day <= 0:
			new_month -= 1
			if new_month < 1:
				new_month = 12
				new_year -= 1
			var days_in_prev_month = get_days_in_month(new_year, new_month)
			new_day += days_in_prev_month
	
	return Date.new(new_day, new_month, new_year)

func add_months(months: int) -> Date:
	var new_month = month + months
	var new_year = year
	
	# Handle positive months
	while new_month > 12:
		new_month -= 12
		new_year += 1
	
	# Handle negative months
	while new_month < 1:
		new_month += 12
		new_year -= 1
	
	# Ensure the day is valid for the target month
	var target_day = day
	var max_days = get_days_in_month(new_year, new_month)
	if target_day > max_days:
		target_day = max_days
	
	return Date.new(target_day, new_month, new_year)

static func get_days_in_month(_year: int, _month: int) -> int:
	if _month == 2:
		return 29 if is_leap_year(_year) else 28
	if _month in [4, 6, 9, 11]:
		return 30
	return 31

func get_weekday() -> String:
	var weekdays = [
		"Domenica", "Lunedì", "Martedì", "Mercoledì",
		"Giovedì", "Venerdì", "Sabato"
	]
	var total_days = 0
	
	# Count days for complete years
	for y in range(1, year):
		total_days += 366 if is_leap_year(y) else 365
	
	# Count days for complete months in the current year
	for m in range(1, month):
		total_days += get_days_in_month(year, m)
	
	# Add days in the current month
	total_days += day - 1 # Subtract 1 because we start counting from day 0
	
	var weekday_index = total_days % 7
	return weekdays[weekday_index]

func get_weekday_index() -> int:
	var total_days = 0
	
	# Count days for complete years
	for y in range(1, year):
		total_days += 366 if is_leap_year(y) else 365

	# Count days for complete months in the current year
	for m in range(1, month):
		total_days += get_days_in_month(year, m)

	# Add days in the current month
	total_days += day - 1 # Subtract 1 because we start counting from day 0

	return total_days % 7
