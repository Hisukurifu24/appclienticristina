extends Node
class_name EventManager

var eventi: Array[Evento] = []
var selected_event: Evento = null

func _ready():
	load_eventi()

func load_eventi() -> void:
	if FileAccess.file_exists("res://Data/eventi.json"):
		var file = FileAccess.open("res://Data/eventi.json", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(data)
			if parse_result == OK:
				eventi = []
				for evento_data in json.data:
					var evento = Evento.new()
					evento.titolo = evento_data.get("titolo", "")
					evento.descrizione = evento_data.get("descrizione", "")
					
					# Load date
					var data_raw = evento_data.get("data", {"day": 1, "month": 1, "year": 2024})
					evento.data = Date.new()
					evento.data.day = data_raw.get("day", 1)
					evento.data.month = data_raw.get("month", 1)
					evento.data.year = data_raw.get("year", 2024)
					
					eventi.append(evento)
			file.close()
	else:
		print("File eventi.json non trovato.")

func save_eventi() -> void:
	var file = FileAccess.open("res://Data/eventi.json", FileAccess.WRITE)
	if file:
		var json = JSON.new()
		var data = []
		for evento in eventi:
			data.append({
				"titolo": evento.titolo,
				"descrizione": evento.descrizione,
				"data": {
					"day": evento.data.day,
					"month": evento.data.month,
					"year": evento.data.year
				}
			})
		var json_string = json.print(data)
		file.store_string(json_string)
		file.close()
	else:
		print("Impossibile aprire il file eventi.json per la scrittura.")

func add_evento(evento: Evento) -> void:
	eventi.append(evento)
	save_eventi()

func delete_evento(evento: Evento) -> void:
	eventi.erase(evento)
	save_eventi()