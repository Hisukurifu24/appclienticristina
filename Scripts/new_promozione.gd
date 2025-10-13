extends Panel

@onready var title_input = %TitleInput
@onready var description_input = %DescInput

@onready var start_day = %Day1Input
@onready var start_month = %Month1Input
@onready var start_year = %Year1Input

@onready var end_day = %Day2Input
@onready var end_month = %Month2Input
@onready var end_year = %Year2Input

@onready var save_button = %SaveButton
@onready var error_label = %ErrorLabel

func _ready():
	error_label.visible = false
	save_button.pressed.connect(on_save_button_pressed)
	load_selected_promo()


func load_selected_promo():
	if PromoManagerNode.selected_promo:
		var promo = PromoManagerNode.selected_promo
		title_input.text = promo.titolo
		description_input.text = promo.descrizione
		
		start_day.value = promo.data_inizio.day
		start_month.value = promo.data_inizio.month
		start_year.value = promo.data_inizio.year
		
		end_day.value = promo.data_fine.day
		end_month.value = promo.data_fine.month
		end_year.value = promo.data_fine.year

func show_error(message: String):
	error_label.text = message
	error_label.visible = true
	await get_tree().create_timer(3.0).timeout
	error_label.visible = false

func on_save_button_pressed():
	var titolo = title_input.text.strip_edges()
	var descrizione = description_input.text.strip_edges()
	var day1 = int(start_day.value)
	var month1 = int(start_month.value)
	var year1 = int(start_year.value)
	var day2 = int(end_day.value)
	var month2 = int(end_month.value)
	var year2 = int(end_year.value)

	if titolo == "":
		show_error("Il titolo non può essere vuoto.")
		return
	if descrizione == "":
		show_error("La descrizione non può essere vuota.")
		return
	if not Date.is_valid_date(year1, month1, day1):
		show_error("Data di inizio non valida.")
		return
	if not Date.is_valid_date(year2, month2, day2):
		show_error("Data di fine non valida.")
		return
	var data_inizio = Date.new(day1, month1, year1)
	var data_fine = Date.new(day2, month2, year2)
	if data_fine.is_before(data_inizio):
		show_error("La data di fine deve essere successiva alla data di inizio.")
		return

	var promo: Promozione
	if PromoManagerNode.selected_promo:
		# Modifica promozione esistente
		PromoManagerNode.selected_promo.titolo = titolo
		PromoManagerNode.selected_promo.descrizione = descrizione
		PromoManagerNode.selected_promo.data_inizio = data_inizio
		PromoManagerNode.selected_promo.data_fine = data_fine
		PromoManagerNode.save_promozioni()
	else:
		# Crea nuova promozione
		promo = Promozione.new()
		promo.titolo = titolo
		promo.descrizione = descrizione
		promo.data_inizio = data_inizio
		promo.data_fine = data_fine
		PromoManagerNode.add_promozione(promo)

	# Torna alla schermata delle promozioni
	PromoManagerNode.selected_promo = null
	get_tree().change_scene_to_file("res://Scenes/home.tscn")
