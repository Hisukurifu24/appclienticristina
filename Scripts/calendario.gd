extends Control

@onready var month_view_button: Button = %VistaMeseButton
@onready var events_view_button: Button = %VistaEventiButton

@onready var month_view = %"Vista Mese"
@onready var events_view = %"Vista Eventi"

@onready var prev_month_button: Button = %PreviousMonthButton
@onready var month_label: Label = %MonthLabel
@onready var next_month_button: Button = %NextMonthButton

var current_date: Date = Date.today()

var calendar_month_day_scene = preload("res://Scenes/calendar_month_day.tscn")
var calendar_event_day_scene = preload("res://Scenes/calendar_event_day.tscn")

func _ready():
	month_view_button.pressed.connect(func(): _show_view("month"))
	events_view_button.pressed.connect(func(): _show_view("events"))
	
	prev_month_button.pressed.connect(_on_prev_month_button_pressed)
	next_month_button.pressed.connect(_on_next_month_button_pressed)

	month_view.get_node("%AddEventButton").pressed.connect(func():
		var new_event = Evento.new()
		new_event.data = current_date
		EventManagerNode.selected_event = new_event
		get_tree().change_scene_to_file("res://Scenes/new_evento.tscn")
	)
	
	_show_view("month")
	_update_views()

func _update_views() -> void:
	_update_month_view()
	_update_events_view()

func _on_prev_month_button_pressed() -> void:
	current_date = current_date.add_months(-1)
	_update_views()

func _on_next_month_button_pressed() -> void:
	current_date = current_date.add_months(1)
	_update_views()

func _show_view(view: String) -> void:
	month_view.visible = view == "month"
	events_view.visible = view == "events"
	month_view_button.button_pressed = view == "month"
	events_view_button.button_pressed = view == "events"

func _update_month_view() -> void:
	var month_names = [
		"Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
		"Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"
	]
	month_label.text = "%s %d" % [month_names[current_date.month - 1], current_date.year]

	var calendar: GridContainer = month_view.get_node("Calendar")
	# Clear existing days
	for child in calendar.get_children():
		child.free()

	var first_day_of_month = Date.new(1, current_date.month, current_date.year)
	var days_in_month = Date.get_days_in_month(current_date.year, current_date.month)
	var start_weekday: int = first_day_of_month.get_weekday_index()
	# Add empty days for alignment
	for i in range(start_weekday):
		var empty_day = calendar_month_day_scene.instantiate()
		empty_day.get_node("%DayLabel").text = ""
		calendar.add_child(empty_day)
	# Add days of the month
	for day in range(1, days_in_month + 1):
		var day_instance = calendar_month_day_scene.instantiate()
		day_instance.get_node("%DayLabel").text = str(day)
		# Highlight current day
		if day == Date.today().day and current_date.month == Date.today().month and current_date.year == Date.today().year:
			var style_box = StyleBoxFlat.new()
			style_box.set_bg_color(Color.ALICE_BLUE)
			day_instance.get_node("%DayLabel").add_theme_stylebox_override("normal", style_box)
			day_instance.get_node("%DayLabel").add_theme_color_override("font_color", Color(0, 0, 0))
		calendar.add_child(day_instance)

	for client: Cliente in ClientManagerNode.clienti:
		if client.data_di_nascita.month == current_date.month:
			var day = client.data_di_nascita.day
			var day_node = calendar.get_child(start_weekday + day - 1)
			var birthday_label: Label = Label.new()
			birthday_label.clip_text = true
			birthday_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			birthday_label.add_theme_font_size_override("font_size", 10)
			birthday_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			birthday_label.text = "🎂 %s" % client.nominativo
			var style_box = StyleBoxFlat.new()
			style_box.set_bg_color(Color(0.1, 0.6, 0.1))
			birthday_label.add_theme_stylebox_override("normal", style_box)
			day_node.get_node("%Events").add_child(birthday_label)

func _update_events_view() -> void:
	var events: VBoxContainer = events_view.get_node("%Events")
	# Clear existing events
	for child in events.get_children():
		child.free()


	for day in range(1, Date.get_days_in_month(current_date.year, current_date.month) + 1):
		var day_instance = calendar_event_day_scene.instantiate()
		day_instance.get_node("%Day").text = "%s, %d %s %d" % [
			Date.new(day, current_date.month, current_date.year).get_weekday(),
			day,
			["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
			 "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"][current_date.month - 1],
			current_date.year
		]
		day_instance.get_node("%AddEventButton").pressed.connect(func():
			var new_event = Evento.new()
			new_event.data = Date.new(day, current_date.month, current_date.year)
			EventManagerNode.selected_event = new_event
			get_tree().change_scene_to_file("res://Scenes/new_evento.tscn")
		)
		# Highlight current day
		if day == Date.today().day and current_date.month == Date.today().month and current_date.year == Date.today().year:
			var style_box = StyleBoxFlat.new()
			style_box.set_bg_color(Color.ALICE_BLUE)
			var day_label = day_instance.get_node("%Day")
			day_label.add_theme_stylebox_override("normal", style_box)
			day_label.add_theme_color_override("font_color", Color(0, 0, 0))
		# Add birthdays
		for client in ClientManagerNode.clienti:
			if client.data_di_nascita.month == current_date.month and client.data_di_nascita.day == day:
				var event_label: Label = Label.new()
				event_label.text = "🎂 %s" % client.nominativo
				day_instance.get_node("%Events").add_child(event_label)
		events.add_child(day_instance)

	var scroll: ScrollContainer = events_view.get_node("ScrollContainer")
	# Scroll to current day if in current month
	if current_date.month == Date.today().month and current_date.year == Date.today().year:
		var current_day = Date.today().day
		# Defer scrolling to next frame so UI elements have proper sizes
		call_deferred("_scroll_to_current_day", scroll, events, current_day)
	else:
		scroll.scroll_vertical = 0

func _scroll_to_current_day(scroll: ScrollContainer, events: VBoxContainer, current_day: int) -> void:
	var target_y = 0
	for i in range(current_day - 1):
		var day_node = events.get_child(i)
		target_y += day_node.size.y + events.get_theme_constant("separation")
	scroll.scroll_vertical = target_y
