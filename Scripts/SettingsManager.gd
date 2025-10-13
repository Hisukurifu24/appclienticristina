extends Node
class_name SettingsManager

var settings: Dictionary = {
	"theme": "light", # "light" or "dark"
	"notifications_enabled": true,
	"notification_time": 15 # minutes before an event to notify
}

var current_home_screen: String = "clienti" # Default home screen