extends Control

@onready var sound_toggle: CheckButton = %SoundToggle
@onready var vibration_toggle: CheckButton = %VibrationToggle

func _ready():
	sound_toggle.pressed.connect(on_sound_toggle_pressed)
	vibration_toggle.pressed.connect(on_vibration_toggle_pressed)
	
	# Initialize toggles based on current settings
	sound_toggle.button_pressed = SettingsManagerNode.settings["sound_enabled"]
	vibration_toggle.button_pressed = SettingsManagerNode.settings["vibration_enabled"]

func on_sound_toggle_pressed():
	SettingsManagerNode.settings["sound_enabled"] = sound_toggle.button_pressed

func on_vibration_toggle_pressed():
	SettingsManagerNode.settings["vibration_enabled"] = vibration_toggle.button_pressed