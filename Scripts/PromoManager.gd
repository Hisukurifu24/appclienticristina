extends Node
class_name PromoManager

var promozioni_data_file = "user://promozioni.json"
var promozioni: Array[Promozione] = []
var selected_promo: Promozione = null

func _ready():
	load_promozioni()

func load_promozioni() -> void:
	# First check if user data exists
	if FileAccess.file_exists(promozioni_data_file):
		var file = FileAccess.open(promozioni_data_file, FileAccess.READ)
		if file:
			var data = file.get_as_text()
			file.close()
			var json = JSON.new()
			var parse_result = json.parse(data)
			if parse_result == OK:
				promozioni = []
				for promo_data in json.data:
					var promo = Promozione.new()
					promo.titolo = promo_data.get("titolo", "")
					promo.descrizione = promo_data.get("descrizione", "")
					
					# Load dates
					var data_inizio_raw = promo_data.get("data_inizio", {"day": 1, "month": 1, "year": 2024})
					promo.data_inizio = Date.new()
					promo.data_inizio.day = data_inizio_raw.get("day", 1)
					promo.data_inizio.month = data_inizio_raw.get("month", 1)
					promo.data_inizio.year = data_inizio_raw.get("year", 2024)
					
					var data_fine_raw = promo_data.get("data_fine", {"day": 1, "month": 1, "year": 2024})
					promo.data_fine = Date.new()
					promo.data_fine.day = data_fine_raw.get("day", 1)
					promo.data_fine.month = data_fine_raw.get("month", 1)
					promo.data_fine.year = data_fine_raw.get("year", 2024)
					
					promozioni.append(promo)
			print("Loaded ", promozioni.size(), " promotions from user data")
	# If no user data, try to load from default res:// location (first time only)
	elif FileAccess.file_exists("res://Data/promozioni.json"):
		print("Loading initial promotions from res://Data/promozioni.json")
		var file = FileAccess.open("res://Data/promozioni.json", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			file.close()
			var json = JSON.new()
			var parse_result = json.parse(data)
			if parse_result == OK:
				promozioni = []
				for promo_data in json.data:
					var promo = Promozione.new()
					promo.titolo = promo_data.get("titolo", "")
					promo.descrizione = promo_data.get("descrizione", "")
					
					# Load dates
					var data_inizio_raw = promo_data.get("data_inizio", {"day": 1, "month": 1, "year": 2024})
					promo.data_inizio = Date.new()
					promo.data_inizio.day = data_inizio_raw.get("day", 1)
					promo.data_inizio.month = data_inizio_raw.get("month", 1)
					promo.data_inizio.year = data_inizio_raw.get("year", 2024)
					
					var data_fine_raw = promo_data.get("data_fine", {"day": 1, "month": 1, "year": 2024})
					promo.data_fine = Date.new()
					promo.data_fine.day = data_fine_raw.get("day", 1)
					promo.data_fine.month = data_fine_raw.get("month", 1)
					promo.data_fine.year = data_fine_raw.get("year", 2024)
					
					promozioni.append(promo)
			# Save to user:// so we have a writable copy
			save_promozioni()
	else:
		print("No promotion data found.")

func save_promozioni() -> void:
	var file = FileAccess.open(promozioni_data_file, FileAccess.WRITE)
	if file:
		var promozioni_data = []
		for promo in promozioni:
			var promo_data = {}
			promo_data["titolo"] = promo.titolo
			promo_data["descrizione"] = promo.descrizione
			promo_data["data_inizio"] = {
				"day": promo.data_inizio.day,
				"month": promo.data_inizio.month,
				"year": promo.data_inizio.year
			}
			promo_data["data_fine"] = {
				"day": promo.data_fine.day,
				"month": promo.data_fine.month,
				"year": promo.data_fine.year
			}
			promozioni_data.append(promo_data)
		var data = JSON.stringify(promozioni_data)
		file.store_string(data)
		file.close()

func add_promozione(promo: Promozione) -> void:
	promozioni.append(promo)
	save_promozioni()

func remove_promozione(promo: Promozione) -> void:
	promozioni.erase(promo)
	save_promozioni()
