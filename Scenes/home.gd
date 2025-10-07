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
    client_button.pressed.connect(switch_to("clienti"))
    promo_button.pressed.connect(switch_to("promozioni"))
    cal_button.pressed.connect(switch_to("calendario"))
    stats_button.pressed.connect(switch_to("statistiche"))
    settings_button.pressed.connect(switch_to("impostazioni"))

func switch_to(screen_name: String):
    print("Switching to screen: " + screen_name)
    for child in content_area.get_children():
        child.queue_free()
    if schermata.has(screen_name):
        var screen_instance = schermata[screen_name].instantiate()
        content_area.add_child(screen_instance)
    else:
        push_error("Screen not found: " + screen_name)