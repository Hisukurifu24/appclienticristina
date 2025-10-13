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

func is_before(other: Date) -> bool:
	if year != other.year:
		return year < other.year
	if month != other.month:
		return month < other.month
	return day < other.day