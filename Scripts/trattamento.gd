extends Panel

@onready var nome_label: Label = %Nome
@onready var descrizione_label: Label = %Descrizione
@onready var data_label: Label = %Data
@onready var cliente_label: Label = %Cliente

@onready var before: TextureRect = %Before
@onready var after: TextureRect = %After
@onready var first: TextureRect = %First
@onready var last: TextureRect = %Last

@onready var delete_button: Button = %DeleteButton

func _ready():
	delete_button.pressed.connect(on_delete_button_pressed)
	insert_treatment_data()

func on_delete_button_pressed():
	var confirm = ConfirmationDialog.new()
	confirm.dialog_text = "Sei sicuro di voler eliminare questo trattamento?"
	add_child(confirm)
	confirm.popup_centered()
	confirm.confirmed.connect(func():
		TreatManagerNode.deleteTreatment(TreatManagerNode.selected_treatment)
		# Go back to main scene after confirmation
		get_tree().change_scene_to_file("res://Scenes/dettagli_cliente.tscn")
	)
	# Clean up the dialog when closed
	confirm.close_requested.connect(func():
		confirm.queue_free()
	)

func insert_treatment_data():
	var trattamento: Trattamento = TreatManagerNode.selected_treatment
	if trattamento:
		nome_label.text = trattamento.tipo_trattamento.nome
		descrizione_label.text = trattamento.tipo_trattamento.descrizione
		data_label.text = str(trattamento.data.day) + "/" + str(trattamento.data.month) + "/" + str(trattamento.data.year)
		cliente_label.text = trattamento.cliente.nominativo
		before.texture = trattamento.foto_prima
		after.texture = trattamento.foto_dopo
		first.texture = TreatManagerNode.getFirstTreatment(trattamento.tipo_trattamento, trattamento.cliente).foto_prima
		last.texture = TreatManagerNode.getLastTreatment(trattamento.tipo_trattamento, trattamento.cliente).foto_dopo
