extends Node
class_name SettingsManager

var settings: Dictionary = {
	"theme": "light", # "light" or "dark"
	"notifications_enabled": true,
	"notification_time": 15, # minutes before an event to notify
	"vibration_enabled": true,
	"sound_enabled": true,
}:
	set(value):
		settings = value
		save_settings()

var current_home_screen: String = "clienti" # Default home screen

func _ready():
	load_settings()


func save_settings():
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	if file:
		file.store_var(settings)
		file.close()
	else:
		push_error("Failed to open settings file for writing.")

func load_settings():
	if not FileAccess.file_exists("user://settings.cfg"):
		save_settings() # Create file with default settings
		return
	
	var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
	if file:
		settings = file.get_var()
		file.close()
	else:
		push_error("Failed to open settings file for reading.")