extends Popup

@onready var image_preview: TextureRect = %ImagePreview
@onready var crop_overlay: ColorRect = %CropOverlay
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

var start_pos: Vector2
var dragging = false
var image_bounds: Rect2  # Store the bounds of the displayed image


signal image_cropped(cropped_image: Texture2D)

func _ready():
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(hide)

func open(texture: Texture2D):
	image_preview.texture = texture
	
	# Wait for the next frame to ensure the UI is properly laid out
	await get_tree().process_frame
	
	# Calculate the actual displayed image size considering stretch mode
	var container_size = image_preview.size
	var texture_size = texture.get_size()
	
	# With stretch_mode = 5 (Keep Aspect Centered), calculate the displayed size
	var scale = min(container_size.x / texture_size.x, container_size.y / texture_size.y)
	var displayed_image_size = texture_size * scale
	
	# Store the image bounds for constraining crop overlay movement
	var image_offset = (container_size - displayed_image_size) / 2
	image_bounds = Rect2(image_offset, displayed_image_size)
	
	# Initialize crop overlay to a centered square based on displayed image size
	var crop_size = min(displayed_image_size.x, displayed_image_size.y)
	crop_overlay.size = Vector2(crop_size, crop_size)
	
	# Center the crop overlay on the displayed image
	crop_overlay.position = image_offset + (displayed_image_size - crop_overlay.size) / 2
	
	popup_centered()

func _input(event):
	if not visible:
		return

	# Handle both mouse (PC) and touch (mobile) input
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Convert global mouse position to local position relative to image_preview
				var local_pos = image_preview.global_position
				var mouse_pos = event.global_position - local_pos
				dragging = true
				start_pos = mouse_pos
			else:
				dragging = false
	elif event is InputEventMouseMotion and dragging:
		# Convert global mouse position to local position relative to image_preview
		var local_pos = image_preview.global_position
		var mouse_pos = event.global_position - local_pos
		var drag_offset = mouse_pos - start_pos
		var new_position = crop_overlay.position + drag_offset
		crop_overlay.position = _constrain_to_image_bounds(new_position)
		start_pos = mouse_pos  # Update start_pos for next frame
	# Single finger drag (crop box) for mobile
	elif event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			start_pos = event.position
		else:
			dragging = false
	elif event is InputEventScreenDrag and dragging:
		var drag_offset = event.position - start_pos
		var new_position = start_pos + drag_offset
		crop_overlay.position = _constrain_to_image_bounds(new_position)

	# Pinch zoom (optional for mobile)
	if event is InputEventMagnifyGesture:
		var new_size = crop_overlay.size * event.factor
		# Keep it square by using the same value for both dimensions
		var square_size = min(abs(new_size.x), abs(new_size.y))
		crop_overlay.size = Vector2(square_size, square_size)
		# Re-constrain position after size change
		crop_overlay.position = _constrain_to_image_bounds(crop_overlay.position)

func _constrain_to_image_bounds(pos: Vector2) -> Vector2:
	# Ensure the crop overlay stays within the image bounds
	var constrained_pos = pos
	
	# Constrain X position
	constrained_pos.x = max(image_bounds.position.x, constrained_pos.x)
	constrained_pos.x = min(image_bounds.position.x + image_bounds.size.x - crop_overlay.size.x, constrained_pos.x)
	
	# Constrain Y position
	constrained_pos.y = max(image_bounds.position.y, constrained_pos.y)
	constrained_pos.y = min(image_bounds.position.y + image_bounds.size.y - crop_overlay.size.y, constrained_pos.y)
	
	return constrained_pos

func _on_confirm_pressed():
	var cropped = _crop_texture()
	image_cropped.emit(cropped)
	hide()

func _crop_texture() -> Texture2D:
	var img = image_preview.texture.get_image()
	
	# Convert UI coordinates to image coordinates
	var texture_size = image_preview.texture.get_size()
	var container_size = image_preview.size
	
	# Calculate the scale factor used to display the image
	var scale = min(container_size.x / texture_size.x, container_size.y / texture_size.y)
	var displayed_image_size = texture_size * scale
	var image_offset = (container_size - displayed_image_size) / 2
	
	# Convert crop overlay position from UI coordinates to image coordinates
	var crop_pos_in_image = (crop_overlay.position - image_offset) / scale
	var crop_size_in_image = crop_overlay.size / scale
	
	# Create the crop rectangle in image coordinates
	var crop_rect = Rect2(crop_pos_in_image, crop_size_in_image)
	
	# Ensure the crop rect is within image bounds
	crop_rect = crop_rect.intersection(Rect2(Vector2.ZERO, texture_size))
	
	var cropped_img = img.get_region(crop_rect)
	return ImageTexture.create_from_image(cropped_img)
