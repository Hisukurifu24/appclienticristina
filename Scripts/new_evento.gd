extends Panel

@onready var title_input = %TitleInput
@onready var description_input = %DescInput
@onready var day_input = %DayInput
@onready var month_input = %MonthInput
@onready var year_input = %YearInput

@onready var save_button = %SaveButton
@onready var error_label = %ErrorLabel

func _ready():
	error_label.visible = false
	save_button.pressed.connect(on_save_button_pressed)
	load_selected_event()

func load_selected_event():
	if EventManagerNode.selected_event:
		var event = EventManagerNode.selected_event
		title_input.text = event.titolo
		description_input.text = event.descrizione
		day_input.value = event.data.day
		month_input.value = event.data.month
		year_input.value = event.data.year

func show_error(message: String):
	SoundManagerNode.play_sound("error")
	error_label.text = message
	error_label.visible = true
	await get_tree().create_timer(3.0).timeout
	error_label.visible = false

func on_save_button_pressed():
	var titolo = title_input.text.strip_edges()
	var descrizione = description_input.text.strip_edges()
	var day = int(day_input.value)
	var month = int(month_input.value)
	var year = int(year_input.value)

	if titolo == "":
		show_error("Il titolo non può essere vuoto.")
		return
	if not Date.is_valid_date(year, month, day):
		show_error("Data non valida.")
		return
	
	var evento = Evento.new()
	evento.titolo = titolo
	evento.descrizione = descrizione
	evento.data = Date.new(day, month, year)
	EventManagerNode.add_evento(evento)
	get_tree().change_scene_to_file("res://Scenes/home.tscn")