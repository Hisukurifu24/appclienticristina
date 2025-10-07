extends Panel

@export var previous_scene: PackedScene
@export var title: String = "App Clienti Cristina"

@onready var title_label: Label = %Title
@onready var back_button: Button = %BackButton

func _ready():
	title_label.text = title
	back_button.pressed.connect(on_back_button_pressed)

func on_back_button_pressed():
	if previous_scene:
		get_tree().change_scene_to_packed(previous_scene)
	else:
		push_error("Previous scene not set for TopBar.")
