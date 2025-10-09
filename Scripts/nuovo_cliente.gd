extends Panel

@onready var photo: TextureRect = %Photo
@onready var add_photo_button: Button = %AddPhotoButton
@onready var name_input: LineEdit = %NameInput
@onready var email_input: LineEdit = %EmailInput
@onready var phone_input: LineEdit = %PhoneInput
@onready var address_input: LineEdit = %AddressInput
@onready var day_input: SpinBox = %DayInput
@onready var month_input: SpinBox = %MonthInput
@onready var year_input: SpinBox = %YearInput
@onready var product_input: TextEdit = %ProductInput
@onready var save_button: Button = %SaveButton
@onready var error_label: Label = %ErrorLabel

@onready var crop_popup = preload("res://Scenes/crop_image_dialog.tscn").instantiate()

var current_file_dialog: FileDialog

func _ready():
	add_photo_button.pressed.connect(on_add_photo_button_pressed)
	save_button.pressed.connect(on_save_button_pressed)
	year_input.max_value = Time.get_date_dict_from_system().year
	year_input.value = year_input.max_value
	error_label.visible = false
	insert_client_data()


func insert_client_data():
	var client = ClientManagerNode.selected_client
	if client:
		name_input.text = client.nominativo
		email_input.text = client.email
		phone_input.text = client.numero_di_telefono
		address_input.text = client.indirizzo
		day_input.value = client.data_di_nascita.get("giorno", 1)
		month_input.value = client.data_di_nascita.get("mese", 1)
		year_input.value = client.data_di_nascita.get("anno", year_input.max_value)
		product_input.text = client.autocura
		if client.foto:
			photo.texture = client.foto
		else:
			photo.texture = null


func on_add_photo_button_pressed():
	var file_dialog = FileDialog.new()
	current_file_dialog = file_dialog
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
	
	# Connect signals for file selection and dialog closing
	file_dialog.file_selected.connect(_on_photo_file_selected)
	file_dialog.close_requested.connect(_on_file_dialog_closed.bind(file_dialog))
	
	add_child(file_dialog)
	file_dialog.popup_centered_ratio(0.6)

func _on_photo_file_selected(path: String):
	# Close the file dialog first to avoid exclusive window conflict
	if current_file_dialog:
		current_file_dialog.queue_free()
		current_file_dialog = null
	
	# Load the image file
	var image = Image.new()
	var error = image.load(path)
	
	if error != OK:
		push_error("Failed to load image: " + path)
		_show_error_message("Errore nel caricamento dell'immagine. Assicurati che sia un file immagine valido.")
		return
	
	# Show crop popup after closing file dialog
	# Check if crop_popup already has a parent and remove it first
	if crop_popup.get_parent():
		crop_popup.get_parent().remove_child(crop_popup)
	
	add_child(crop_popup)
	
	# Connect signal only if not already connected
	if not crop_popup.is_connected("image_cropped", _on_image_cropped):
		crop_popup.connect("image_cropped", _on_image_cropped)
	
	# Convert Image to Texture2D before passing to crop dialog
	var texture = ImageTexture.create_from_image(image)
	crop_popup.open(texture)

func _on_file_dialog_closed(file_dialog: FileDialog):
	# Clean up the file dialog
	file_dialog.queue_free()
	if current_file_dialog == file_dialog:
		current_file_dialog = null

func _on_image_cropped(cropped_texture: Texture2D):
	# Set the texture directly since it's already a Texture2D
	photo.texture = cropped_texture

func _show_error_message(message: String):
	error_label.text = message
	error_label.visible = true
	# Optionally, you can hide the error message after a few seconds
	await get_tree().create_timer(5.0).timeout
	error_label.visible = false
	error_label.text = ""

func on_save_button_pressed():
	var _name = name_input.text.strip_edges()
	var email = email_input.text.strip_edges()
	var phone = phone_input.text.strip_edges()
	var address = address_input.text.strip_edges()
	var day = int(day_input.value)
	var month = int(month_input.value)
	var year = int(year_input.value)
	var product = product_input.text.strip_edges()

	# Basic validation
	if _name == "":
		_show_error_message("Il campo Nome è obbligatorio.")
		return
	if email == "" or not _is_valid_email(email):
		_show_error_message("Indirizzo email non valido.")
		return
	if ClientManagerNode.getClient(email) != null:
		_show_error_message("Esiste già un cliente con questa email.")
		return
	if phone != "" and not _is_valid_phone(phone):
		_show_error_message("Numero di telefono non valido.")
		return
	if not _is_valid_date(day, month, year):
		_show_error_message("Data di nascita non valida.")
		return
	
	var new_cliente = Cliente.new()
	new_cliente.nominativo = _name
	new_cliente.email = email
	new_cliente.numero_di_telefono = phone
	new_cliente.indirizzo = address
	
	# Create a properly typed Dictionary[String, int]
	var data_nascita_typed: Dictionary[String, int] = {}
	data_nascita_typed["giorno"] = day
	data_nascita_typed["mese"] = month
	data_nascita_typed["anno"] = year
	new_cliente.data_di_nascita = data_nascita_typed
	
	new_cliente.autocura = product
	if photo.texture:
		new_cliente.foto = photo.texture
		# Save the image to a file
		save_image(photo.texture, new_cliente.nominativo)
	else:
		new_cliente.foto = null

	ClientManagerNode.addClient(new_cliente)
	# Go back to main scene
	get_tree().change_scene_to_file("res://Scenes/home.tscn")
	pass

func _is_valid_email(email: String) -> bool:
	var email_regex = RegEx.new()
	email_regex.compile(r"^[\w\.-]+@[\w\.-]+\.\w+$")
	return email_regex.search(email) != null

func _is_valid_phone(phone: String) -> bool:
	var phone_regex = RegEx.new()
	phone_regex.compile(r"^\+?[0-9\s\-]{7,15}$")
	return phone_regex.search(phone) != null

func _is_valid_date(day: int, month: int, year: int) -> bool:
	# Check basic ranges
	if month < 1 or month > 12:
		return false
	if year < 1900 or year >= Time.get_date_dict_from_system().year:
		return false
	if day < 1:
		return false
	
	# Days in each month (non-leap year)
	var days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	# Check for leap year and adjust February
	if _is_leap_year(year):
		days_in_month[1] = 29
	
	# Check if day is valid for the given month
	if day > days_in_month[month - 1]:
		return false
	
	return true

func _is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

func save_image(texture: Texture2D, nominativo: String) -> String:
	var image = texture.get_image()
	var save_path = ClientManagerNode.clients_photo_dir
	# Ensure the directory exists
	var dir = DirAccess.open(save_path)
	if dir == null:
		DirAccess.make_dir_recursive_absolute(save_path)
	# Generate a unique filename
	var filename = nominativo + ".png"
	var full_path = save_path + filename
	var err = image.save_png(full_path)
	if err != OK:
		push_error("Failed to save image to: " + full_path)
	else:
		print("Image saved successfully to: " + full_path)
	return full_path
