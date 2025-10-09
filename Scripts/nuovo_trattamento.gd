extends Panel

@onready var cliente_input: LineEdit = %ClientInput
@onready var trattamento_input: LineEdit = %TreatInput

@onready var day_input: SpinBox = %DayInput
@onready var month_input: SpinBox = %MonthInput
@onready var year_input: SpinBox = %YearInput

# Generic popup system
var client_popup: VBoxContainer
var treatment_popup: VBoxContainer
var selected_client: Cliente = null
var selected_treatment_type: TipoTrattamento = null
var popup_interacting: bool = false

@onready var add_treat_button: Button = %AddTreatButton

@onready var before_photo: TextureRect = %Before
@onready var after_photo: TextureRect = %After
@onready var add_before_button: Button = %AddBeforeButton
@onready var add_after_button: Button = %AddAfterButton

@onready var error_label: Label = %ErrorLabel
@onready var save_button: Button = %SaveButton

func _ready():
	# Initialize generic popups
	client_popup = create_popup()
	treatment_popup = create_popup()
	
	# Connect input events
	cliente_input.text_changed.connect(func(text): on_input_text_changed(text, "client"))
	trattamento_input.text_changed.connect(func(text): on_input_text_changed(text, "treatment"))
	cliente_input.focus_exited.connect(func(): _on_input_focus_exited(client_popup))
	trattamento_input.focus_exited.connect(func(): _on_input_focus_exited(treatment_popup))

	if ClientManagerNode.selected_client:
		selected_client = ClientManagerNode.selected_client
		cliente_input.text = selected_client.nominativo

	year_input.max_value = Time.get_date_dict_from_system().year
	year_input.value = year_input.max_value
	month_input.value = Time.get_date_dict_from_system().month
	day_input.value = Time.get_date_dict_from_system().day
	error_label.visible = false
	
	add_treat_button.pressed.connect(on_add_treat_button_pressed)
	add_before_button.pressed.connect(func(): 
		popup_file_dialog(before_photo)
	)
	add_after_button.pressed.connect(func(): 
		popup_file_dialog(after_photo)
	)
	
	save_button.pressed.connect(on_save_button_pressed)

# Generic popup creation method
func create_popup() -> VBoxContainer:
	var popup = VBoxContainer.new()
	popup.visible = false
	add_child(popup)
	return popup

# Generic focus exited handler
func _on_input_focus_exited(popup: VBoxContainer):
	await get_tree().create_timer(0.1).timeout
	if not popup_interacting:
		popup.hide()

# Generic text change handler
func on_input_text_changed(new_text: String, input_type: String):
	var filtered_items: Array = []
	var input_field: LineEdit
	var popup: VBoxContainer
	
	if input_type == "client":
		input_field = cliente_input
		popup = client_popup
		if new_text.length() > 0:
			for cliente in ClientManagerNode.clienti:
				if cliente.nominativo.to_lower().contains(new_text.to_lower()):
					filtered_items.append(cliente)
		else:
			selected_client = null
	elif input_type == "treatment":
		input_field = trattamento_input
		popup = treatment_popup
		if new_text.length() > 0:
			for treatment_type in TreatManagerNode.tipi_trattamenti:
				if treatment_type.nome.to_lower().contains(new_text.to_lower()):
					filtered_items.append(treatment_type)
		else:
			selected_treatment_type = null
	
	if filtered_items.size() > 0:
		if filtered_items.size() > 5:
			filtered_items.resize(5) # Limit to 5 results
		show_popup(popup, filtered_items, input_field, input_type)
	else:
		popup.hide()

# Generic popup display method
func show_popup(popup: VBoxContainer, items: Array, input_field: LineEdit, input_type: String):
	# Clear existing popup items
	for child in popup.get_children():
		child.queue_free()
	
	# Add filtered items to popup
	for i in range(items.size()):
		var item = items[i]
		var button = Button.new()
		button.text = item.nominativo if input_type == "client" else item.nome
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 50)
		button.button_down.connect(func():
			popup_interacting = true
		)
		button.pressed.connect(func():
			on_item_selected(i, items, input_field, popup, input_type)
		)
		popup.add_child(button)
	
	# Position popup below the LineEdit
	var global_pos = input_field.global_position
	var popup_pos = Vector2(global_pos.x, global_pos.y + input_field.size.y)
	popup.position = popup_pos
	popup.size.x = int(input_field.size.x)
	popup.show()

# Generic selection handler
func on_item_selected(id: int, items: Array, input_field: LineEdit, popup: VBoxContainer, input_type: String):
	popup_interacting = false
	if id >= 0 and id < items.size():
		var selected_item = items[id]
		if input_type == "client":
			selected_client = selected_item
			input_field.text = selected_client.nominativo
		elif input_type == "treatment":
			selected_treatment_type = selected_item
			input_field.text = selected_treatment_type.nome
		popup.hide()

func on_add_treat_button_pressed():
	var confirm = ConfirmationDialog.new()
	confirm.dialog_text = "Sei sicuro di voler aggiungere questo trattamento?"
	confirm.ok_button_text = "Aggiungi"
	confirm.cancel_button_text = "Annulla"
	confirm.title = "Conferma Aggiunta"
	var similar_entries = []
	for trattamento in TreatManagerNode.tipi_trattamenti:
			if trattamento.nome.to_lower().similarity(trattamento_input.text.to_lower()) > 0.1:
				similar_entries.append(trattamento)
	if similar_entries.size() > 5:
		similar_entries.resize(5) # Limit to 5 suggestions
	if similar_entries.size() > 0:
		confirm.ok_button_text = "Aggiungi comunque"
		confirm.dialog_text += "\nTrattamenti simili trovati:"
		for entry in similar_entries:
			confirm.dialog_text += "\n- " + entry.nome
	add_child(confirm)
	confirm.popup_centered()
	confirm.confirmed.connect(func():
		var description_popup = AcceptDialog.new()
		description_popup.title = "Aggiungi Descrizione Trattamento"
		description_popup.ok_button_text = "Salva"
		description_popup.size = Vector2(400, 300)
		var textedit = TextEdit.new()
		textedit.wrap_mode = TextEdit.LineWrappingMode.LINE_WRAPPING_BOUNDARY
		textedit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		textedit.size_flags_vertical = Control.SIZE_EXPAND_FILL
		description_popup.add_child(textedit)
		description_popup.confirmed.connect(func():
			var new_tipo = TipoTrattamento.new()
			new_tipo.nome = trattamento_input.text
			new_tipo.descrizione = textedit.text
			TreatManagerNode.addTipoTrattamento(new_tipo)
			selected_treatment_type = new_tipo
			trattamento_input.text = selected_treatment_type.nome
			description_popup.hide()
		)
		add_child(description_popup)
		description_popup.popup_centered()
	)

func popup_file_dialog(preview_node: TextureRect):
	var file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	# Add more image format support
	file_dialog.filters = [
		"*.png ; PNG Image", 
		"*.jpg ; JPEG Image", 
		"*.jpeg ; JPEG Image",
		"*.bmp ; BMP Image",
		"*.webp ; WebP Image",
		"*.tga ; TGA Image",
		"*.svg ; SVG Image",
	]
	add_child(file_dialog)
	file_dialog.popup_centered_ratio(0.6)
	file_dialog.file_selected.connect(func(path):
		preview_node.texture = TreatManagerNode.load_image_texture(path)
	)
	file_dialog.close_requested.connect(func():
		file_dialog.queue_free()
	)

func show_error(message: String):
	error_label.text = message
	error_label.visible = true
	await get_tree().create_timer(3.0).timeout
	error_label.visible = false

func on_save_button_pressed():
	var day = int(day_input.value)
	var month = int(month_input.value)
	var year = int(year_input.value)
	var before_texture: Texture2D = before_photo.texture
	var after_texture: Texture2D = after_photo.texture

	if selected_client == null:
		show_error("Seleziona un cliente.")
		return
	if selected_treatment_type == null:
		show_error("Seleziona un tipo di trattamento.")
		return
	
	var new_trattamento = Trattamento.new()

	new_trattamento.cliente = selected_client
	new_trattamento.tipo_trattamento = selected_treatment_type
	var data_typed: Dictionary[String, int] = {}
	data_typed["giorno"] = day
	data_typed["mese"] = month
	data_typed["anno"] = year
	new_trattamento.data = data_typed
	new_trattamento.foto_prima = before_texture
	new_trattamento.foto_dopo = after_texture

	TreatManagerNode.addTreatment(new_trattamento)
	get_tree().change_scene_to_file("res://Scenes/dettagli_cliente.tscn")
