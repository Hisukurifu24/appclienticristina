extends Node
class_name SoundManager

var sound_effects = {
	"button_click": preload("res://Assets/Sounds/Minimalist1.wav"),
	"notification": preload("res://Assets/Sounds/Modern13.wav"),
	"error": preload("res://Assets/Sounds/Modern16.wav"),
}

var audio_player: AudioStreamPlayer
var connected_buttons = []

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	get_tree().tree_changed.connect(_connect_buttons)

func _connect_buttons():
	var buttons = get_tree().get_nodes_in_group("Buttons")
	for button in buttons:
		if button is BaseButton and not button in connected_buttons:
			button.pressed.connect(func():
				play_sound("button_click")
				vibrate())
			connected_buttons.append(button)

func play_sound(effect_name: String):
	if !SettingsManagerNode.settings["sound_enabled"]:
		return
	if sound_effects.has(effect_name):
		audio_player.stream = sound_effects[effect_name]
		audio_player.play()

func vibrate(duration_ms: int = 5):
	if !SettingsManagerNode.settings["vibration_enabled"]:
		return
	# Vibrate on mobile devices (Android/iOS)
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(duration_ms, 0.2)
