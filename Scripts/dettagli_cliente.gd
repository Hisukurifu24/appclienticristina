extends Panel

@onready var photo: TextureRect = %Photo
@onready var name_label: Label = %Nominativo
@onready var email_label: Label = %Email
@onready var phone_label: Label = %Telefono
@onready var address_label: Label = %Indirizzo
@onready var dob_label: Label = %DataNascita

@onready var cure_label: Label = %Autocura

@onready var add_treat_button: Button = %AddTreatButton
var treat_row_scene: PackedScene = preload("res://Scenes/treat_row.tscn")

@onready var modify_button: Button = %ModifyButton
@onready var delete_button: Button = %DeleteButton

func _ready():
	modify_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://Scenes/nuovo_cliente.tscn")
	)
	delete_button.pressed.connect(on_delete_button_pressed)
	add_treat_button.pressed.connect(func():
		TreatManagerNode.selected_treatment = null
		get_tree().change_scene_to_file("res://Scenes/nuovo_trattamento.tscn")
	)
	insert_client_data()

func on_delete_button_pressed():
	var confirm = ConfirmationDialog.new()
	confirm.dialog_text = "Sei sicuro di voler eliminare questo cliente?"
	add_child(confirm)
	confirm.popup_centered()
	confirm.confirmed.connect(func():
		ClientManagerNode.deleteClient(ClientManagerNode.selected_client)
		# Go back to main scene after confirmation
		get_tree().change_scene_to_file("res://Scenes/home.tscn")
	)
	# Clean up the dialog when closed
	confirm.close_requested.connect(func():
		confirm.queue_free()
	)

func insert_client_data():
	var client: Cliente = ClientManagerNode.selected_client
	if client:
		name_label.text = client.nominativo
		email_label.text = client.email
		phone_label.text = client.numero_di_telefono
		address_label.text = client.indirizzo
		dob_label.text = str(client.data_di_nascita.day) + "/" + str(client.data_di_nascita.month) + "/" + str(client.data_di_nascita.year)
		cure_label.text = client.autocura

		for trattamento: Trattamento in TreatManagerNode.getAllTreatOfClient(client):
			var treat_row = treat_row_scene.instantiate()
			treat_row.get_node("Name").text = trattamento.tipo_trattamento.nome
			treat_row.get_node("Date").text = str(trattamento.data.day) + "/" + str(trattamento.data.month) + "/" + str(trattamento.data.year)
			treat_row.get_node("Button").pressed.connect(func():
				TreatManagerNode.selected_treatment = trattamento
				get_tree().change_scene_to_file("res://Scenes/trattamento.tscn")
			)
			%TreatList.add_child(treat_row)

		if client.foto:
			photo.texture = client.foto
		else:
			photo.texture = ClientManagerNode.default_icon
