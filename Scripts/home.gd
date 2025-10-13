extends Control

@onready var client_button: Button = %ClientButton
@onready var promo_button: Button = %PromoButton
@onready var cal_button: Button = %CalButton
@onready var stats_button: Button = %StatButton
@onready var settings_button: Button = %SettingsButton

@onready var content_area: Control = %Content

var schermata = {
	"clienti": preload("res://Scenes/clienti.tscn"),
	"promozioni": preload("res://Scenes/promozioni.tscn"),
	"calendario": preload("res://Scenes/calendario.tscn"),
	"statistiche": preload("res://Scenes/statistiche.tscn"),
	"impostazioni": preload("res://Scenes/impostazioni.tscn"),
}

func _ready():
	client_button.pressed.connect(func(): switch_to("clienti"))
	promo_button.pressed.connect(func(): switch_to("promozioni"))
	cal_button.pressed.connect(func(): switch_to("calendario"))
	stats_button.pressed.connect(func(): switch_to("statistiche"))
	settings_button.pressed.connect(func(): switch_to("impostazioni"))
	switch_to(SettingsManagerNode.current_home_screen)


func switch_to(screen_name: String):
	for child in content_area.get_children():
		child.queue_free()
	if schermata.has(screen_name):
		var screen_instance = schermata[screen_name].instantiate()
		content_area.add_child(screen_instance)
		SettingsManagerNode.current_home_screen = screen_name
		# Update button pressed state
		update_button_pressed_state(screen_name)
	else:
		push_error("Screen not found: " + screen_name)

func update_button_pressed_state(screen_name: String):
	# Reset all buttons
	client_button.button_pressed = false
	promo_button.button_pressed = false
	cal_button.button_pressed = false
	stats_button.button_pressed = false
	settings_button.button_pressed = false
	
	# Set the correct button as pressed
	match screen_name:
		"clienti":
			client_button.button_pressed = true
		"promozioni":
			promo_button.button_pressed = true
		"calendario":
			cal_button.button_pressed = true
		"statistiche":
			stats_button.button_pressed = true
		"impostazioni":
			settings_button.button_pressed = true
