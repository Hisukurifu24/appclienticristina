class_name ClientManager
extends Node

var clients_photo_dir = "user://client_photos/"
var default_icon = preload("res://Images/client_icon.tres")

var clienti: Array[Cliente] = []
var selected_client: Cliente = null

func _ready():
	ensure_client_photos_directory()
	loadClients()

# Ensure the client photos directory exists
func ensure_client_photos_directory():
	if not DirAccess.dir_exists_absolute(clients_photo_dir):
		DirAccess.make_dir_recursive_absolute(clients_photo_dir)

# Helper function to load images from both res:// and user:// paths
func load_image_texture(path: String) -> Texture2D:
	if path == "" or not FileAccess.file_exists(path):
		return default_icon
	
	if path.begins_with("res://"):
		return load(path)
	
	# Load user directory files as ImageTexture
	var image = Image.new()
	var error = image.load(path)
	if error == OK:
		var texture = ImageTexture.new()
		texture.set_image(image)
		return texture
	else:
		push_error("Failed to load image from path: " + path)
		return default_icon

func loadClients():
	if FileAccess.file_exists("res://Data/clienti.json"):
		var file = FileAccess.open("res://Data/clienti.json", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(data)
			if parse_result == OK:
				clienti = []
				for cliente_data in json.data:
					var cliente = Cliente.new()
					cliente.nominativo = cliente_data.get("nominativo", "")
					var foto_path = cliente_data.get("foto", "")
					cliente.foto = load_image_texture(foto_path)
					
					# Create Date object from JSON data
					var data_nascita_raw = cliente_data.get("data_di_nascita", {"giorno": 1, "mese": 1, "anno": 2000})
					var day = int(data_nascita_raw.get("giorno", 1))
					var month = int(data_nascita_raw.get("mese", 1))
					var year = int(data_nascita_raw.get("anno", 2000))
					cliente.data_di_nascita = Date.new(day, month, year)
					
					cliente.indirizzo = cliente_data.get("indirizzo", "")
					cliente.numero_di_telefono = cliente_data.get("numero_di_telefono", "")
					cliente.email = cliente_data.get("email", "")
					cliente.autocura = cliente_data.get("autocura", "")
					
					clienti.append(cliente)
			file.close()
	else:
		print("File clienti.json non trovato.")

func saveClients():
	var file = FileAccess.open("res://Data/clienti.json", FileAccess.WRITE)
	if file:
		var clienti_data = []
		for cliente in clienti:
			var cliente_data = {}
			cliente_data["nominativo"] = cliente.nominativo
			cliente_data["foto"] = clients_photo_dir + cliente.nominativo + ".png" if cliente.foto else ""
			cliente_data["data_di_nascita"] = {
				"giorno": cliente.data_di_nascita.day,
				"mese": cliente.data_di_nascita.month,
				"anno": cliente.data_di_nascita.year
			}
			cliente_data["indirizzo"] = cliente.indirizzo
			cliente_data["numero_di_telefono"] = cliente.numero_di_telefono
			cliente_data["email"] = cliente.email
			cliente_data["autocura"] = cliente.autocura
			
			clienti_data.append(cliente_data)
		var data = JSON.stringify(clienti_data)
		file.store_string(data)
		file.close()
	else:
		print("Impossibile aprire il file clienti.json per la scrittura.")

func addClient(cliente: Cliente):
	# Save the client photo to user directory if it exists
	if cliente.foto != null:
		save_client_photo(cliente.nominativo, cliente.foto)
	clienti.append(cliente)
	saveClients()

# Save a client's photo to the user directory
func save_client_photo(client_name: String, texture: Texture2D):
	if texture == null:
		return
	
	ensure_client_photos_directory()
	var image = texture.get_image()
	if image != null:
		var file_path = clients_photo_dir + client_name + ".png"
		image.save_png(file_path)

func getClient(email: String) -> Cliente:
	for cliente in clienti:
		if cliente.email == email:
			return cliente
	return null

func deleteClient(cliente: Cliente):
	if cliente in clienti:
		clienti.erase(cliente)
		# Optionally delete the client's photo file
		var photo_path = clients_photo_dir + cliente.nominativo + ".png"
		if FileAccess.file_exists(photo_path):
			DirAccess.remove_absolute(photo_path)
		saveClients()
		selected_client = null
