extends Control
class_name Promozioni

@onready var add_promo_button = %AddPromoButton
@onready var promo_list = %PromoList

var promo_scene = preload("res://Scenes/promo.tscn")

func _ready():
	add_promo_button.pressed.connect(_on_add_promo_button_pressed)
	update_promo_list()

func update_promo_list() -> void:
	# Clear existing promotions
	for child in promo_list.get_children():
		child.queue_free()
	
	for promo: Promozione in PromoManagerNode.promozioni:
		var promo_instance = promo_scene.instantiate() as Promo
		promo_instance.get_node("%Title").text = promo.titolo
		promo_instance.get_node("%Description").text = promo.descrizione
		promo_instance.get_node("%DateLabel").text = "Dal %02d/%02d/%04d al %02d/%02d/%04d" % [
			promo.data_inizio.day, promo.data_inizio.month, promo.data_inizio.year,
			promo.data_fine.day, promo.data_fine.month, promo.data_fine.year
		]
		promo_instance.get_node("%MoreButton").pressed.connect(func():
			# Create a background panel that covers the entire screen
			var background = ColorRect.new()
			background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			background.color = Color.TRANSPARENT
			background.mouse_filter = Control.MOUSE_FILTER_STOP

			var popup: PanelContainer = preload("res://Scenes/promo_context_menu.tscn").instantiate()
			var edit_button: Button = popup.get_node("%EditButton")
			var delete_button: Button = popup.get_node("%DeleteButton")

			edit_button.pressed.connect(func():
				background.queue_free()
				PromoManagerNode.selected_promo = promo
				get_tree().change_scene_to_file("res://Scenes/new_promozione.tscn")
			)
			delete_button.pressed.connect(func():
				background.queue_free()
				var dialog = ConfirmationDialog.new()
				dialog.dialog_text = "Sei sicuro di voler eliminare questa promozione?"
				dialog.confirmed.connect(func():
					PromoManagerNode.remove_promozione(promo)
					update_promo_list()
				)
				add_child(dialog)
				dialog.popup_centered()
			)
			
			# Close popup when clicking on background
			background.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed:
					background.queue_free()
			)
			
			popup.size = Vector2(150, 0)
			popup.position = promo_instance.get_node("%MoreButton").get_global_position() + Vector2(-popup.size.x, 0)
			
			background.add_child(popup)
			add_child(background)
		)
		promo_instance.get_node("%ShareButton").pressed.connect(func():
			var share_text := "Guarda questa promozione!\n"
			share_text += "%s\n%s\nValida dal %02d/%02d/%04d al %02d/%02d/%04d" % [
				promo.titolo,
				promo.descrizione,
				promo.data_inizio.day, promo.data_inizio.month, promo.data_inizio.year,
				promo.data_fine.day, promo.data_fine.month, promo.data_fine.year
			]
			share_on_whatsapp(share_text)
		)
		promo_list.add_child(promo_instance)
		promo_list.add_child(HSeparator.new())

func _on_add_promo_button_pressed() -> void:
	PromoManagerNode.selected_promo = null
	get_tree().change_scene_to_file("res://Scenes/new_promozione.tscn")

func share_on_whatsapp(text: String) -> void:
	var encoded := text.uri_encode()
	# Prefer the app if present (mobile), otherwise WhatsApp Web:
	var app_url := "whatsapp://send?text=%s" % encoded
	var web_url := "https://wa.me/?text=%s" % encoded

	# Try app first; if it fails (e.g., on desktop), fall back to web:
	var result := OS.shell_open(app_url)
	if result != OK:
		OS.shell_open(web_url)
