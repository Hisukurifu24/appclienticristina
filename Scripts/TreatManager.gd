class_name TreatManager
extends Node

var clients_photo_dir = "user://client_photos/trattamenti/"
var default_icon = preload("res://Images/icon.svg")

var log_trattamenti: Array[Trattamento] = []
var tipi_trattamenti: Array[TipoTrattamento] = []

var selected_treatment: Trattamento = null

func _ready():
	ensure_client_photos_directory()
	loadTipiTrattamenti()
	loadTrattamenti()

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

func loadTrattamenti():
	if FileAccess.file_exists("res://Data/trattamenti.json"):
		var file = FileAccess.open("res://Data/trattamenti.json", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(data)
			if parse_result == OK:
				log_trattamenti = []
				for trattamento_data in json.data:
					var trattamento = Trattamento.new()
					
					# Create TipoTrattamento from dictionary data
					var tipo_dict = trattamento_data.get("tipo_trattamento", {})
					var tipo_trattamento = TipoTrattamento.new()
					tipo_trattamento.nome = tipo_dict.get("nome", "")
					tipo_trattamento.descrizione = tipo_dict.get("descrizione", "")
					trattamento.tipo_trattamento = tipo_trattamento
					
					trattamento.cliente = ClientManagerNode.getClient(trattamento_data.get("cliente", ""))
					
					# Create Date object from JSON data
					var data_dict = trattamento_data.get("data", {})
					var day = int(data_dict.get("giorno", 1))
					var month = int(data_dict.get("mese", 1))
					var year = int(data_dict.get("anno", 2000))
					trattamento.data = Date.new(day, month, year)

					var foto_prima_path = trattamento_data.get("foto_prima", "")
					trattamento.foto_prima = load_image_texture(foto_prima_path)
					
					var foto_dopo_path = trattamento_data.get("foto_dopo", "")
					trattamento.foto_dopo = load_image_texture(foto_dopo_path)
					
					log_trattamenti.append(trattamento)
			file.close()
	else:
		print("File trattamenti.json non trovato.")

func loadTipiTrattamenti():
	if FileAccess.file_exists("res://Data/tipi-trattamento.json"):
		var file = FileAccess.open("res://Data/tipi-trattamento.json", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(data)
			if parse_result == OK:
				tipi_trattamenti = []
				for tipo_data in json.data:
					var tipo = TipoTrattamento.new()
					tipo.nome = tipo_data.get("nome", "")
					tipo.descrizione = tipo_data.get("descrizione", "")
					tipi_trattamenti.append(tipo)
			file.close()
	else:
		push_error("File tipi-trattamento.json non trovato.")

func getAllTreatOfClient(cliente: Cliente) -> Array[Trattamento]:
	var trattamenti_cliente: Array[Trattamento] = []
	for trattamento in log_trattamenti:
		if trattamento.cliente == cliente:
			trattamenti_cliente.append(trattamento)
	# Sort treatments by date
	trattamenti_cliente.sort_custom(func(a: Trattamento, b: Trattamento):
		return is_later(a.data, b.data)
	)
	return trattamenti_cliente

func getFirstTreatment(tipo: TipoTrattamento, cliente: Cliente) -> Trattamento:
	var first_treatment: Trattamento = null
	for trattamento in log_trattamenti:
		if trattamento.cliente == cliente and trattamento.tipo_trattamento.nome == tipo.nome:
			if first_treatment == null or is_earlier(trattamento.data, first_treatment.data):
				first_treatment = trattamento
	return first_treatment

func getLastTreatment(tipo: TipoTrattamento, cliente: Cliente) -> Trattamento:
	var last_treatment: Trattamento = null
	for trattamento in log_trattamenti:
		if trattamento.cliente == cliente and trattamento.tipo_trattamento.nome == tipo.nome:
			if last_treatment == null or is_later(trattamento.data, last_treatment.data):
				last_treatment = trattamento
	return last_treatment

func is_earlier(data1: Date, data2: Date) -> bool:
	if data1.year != data2.year:
		return data1.year < data2.year
	if data1.month != data2.month:
		return data1.month < data2.month
	return data1.day < data2.day

func is_later(data1: Date, data2: Date) -> bool:
	if data1.year != data2.year:
		return data1.year > data2.year
	if data1.month != data2.month:
		return data1.month > data2.month
	return data1.day > data2.day

func addTreatment(trattamento: Trattamento):
	log_trattamenti.append(trattamento)
	saveTrattamenti()

func deleteTreatment(trattamento: Trattamento):
	if trattamento in log_trattamenti:
		log_trattamenti.erase(trattamento)
		saveTrattamenti()

func saveTrattamenti():
	var file = FileAccess.open("res://Data/trattamenti.json", FileAccess.WRITE)
	if file:
		var data_array = []
		for trattamento in log_trattamenti:
			var trattamento_dict = {}

			var tipo_dict = {}
			tipo_dict["nome"] = trattamento.tipo_trattamento.nome
			tipo_dict["descrizione"] = trattamento.tipo_trattamento.descrizione
			trattamento_dict["tipo_trattamento"] = tipo_dict
			trattamento_dict["cliente"] = trattamento.cliente.email
			var data_dict = {}
			data_dict["giorno"] = trattamento.data.day
			data_dict["mese"] = trattamento.data.month
			data_dict["anno"] = trattamento.data.year
			trattamento_dict["data"] = data_dict
			trattamento_dict["foto_prima"] = ""
			if trattamento.foto_prima:
				var foto_prima_path = clients_photo_dir + trattamento.cliente.nominativo + "_" + trattamento.tipo_trattamento.nome + "_prima.png"
				save_image(trattamento.foto_prima, foto_prima_path)
				trattamento_dict["foto_prima"] = foto_prima_path
			trattamento_dict["foto_dopo"] = ""
			if trattamento.foto_dopo:
				var foto_dopo_path = clients_photo_dir + trattamento.cliente.nominativo + "_" + trattamento.tipo_trattamento.nome + "_dopo.png"
				save_image(trattamento.foto_dopo, foto_dopo_path)
				trattamento_dict["foto_dopo"] = foto_dopo_path
			data_array.append(trattamento_dict)
		var result = JSON.stringify(data_array, "\t")
		file.store_string(result)
		file.close()
	else:
		push_error("Failed to open trattamenti.json for writing.")

func save_image(texture: Texture2D, save_path: String):
	var image = texture.get_image()
	# Ensure the directory exists
	var dir = DirAccess.open(clients_photo_dir)
	if dir == null:
		DirAccess.make_dir_recursive_absolute(clients_photo_dir)
	if image != null:
		image.save_png(save_path)

func addTipoTrattamento(tipo: TipoTrattamento):
	tipi_trattamenti.append(tipo)
	saveTipiTrattamenti()

func saveTipiTrattamenti():
	var file = FileAccess.open("res://Data/tipi-trattamento.json", FileAccess.WRITE)
	if file:
		var data_array = []
		for tipo in tipi_trattamenti:
			var tipo_dict = {}
			tipo_dict["nome"] = tipo.nome
			tipo_dict["descrizione"] = tipo.descrizione
			data_array.append(tipo_dict)
		var result = JSON.stringify(data_array, "\t")
		file.store_string(result)
		file.close()
	else:
		push_error("Failed to open tipi-trattamento.json for writing.")
