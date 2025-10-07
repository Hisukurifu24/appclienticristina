extends Control

@onready var client_list: VBoxContainer = %ClientList
@onready var client_row_scene: PackedScene = preload("res://Scenes/client_row_button.tscn")
@onready var search_box: LineEdit = %Search
@onready var new_client_button: Button = %NewClientButton

func _ready():
	new_client_button.pressed.connect(on_new_client_button_pressed)
	search_box.text_changed.connect(func(new_text):
		update_client_list(new_text)
	)
	update_client_list()

func update_client_list(filter: String = ""):
	# Remove all existing children
	for child in client_list.get_children():
		child.queue_free()
	
	for cliente in ClientManagerNode.clienti:
		if filter == "" or filter.to_lower() in cliente.nominativo.to_lower():
			var client_row = client_row_scene.instantiate()
			client_row.get_node("%Nominativo").text = cliente.nominativo
			client_row.get_node("%Photo").texture = cliente.foto
			client_row.get_node("%DataNascita").text = str(cliente.data_di_nascita["giorno"]) + "/" + str(cliente.data_di_nascita["mese"]) + "/" + str(cliente.data_di_nascita["anno"])
			client_row.pressed.connect(func():
				ClientManagerNode.selected_client = cliente
				get_tree().change_scene_to_file("res://Scenes/dettagli_cliente.tscn")
			)
			client_list.add_child(client_row)

func on_new_client_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/nuovo_cliente.tscn")
