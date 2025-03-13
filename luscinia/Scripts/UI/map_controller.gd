extends Control

# Signal emitted when the zoom level changes
signal zoom_changed

# Exported variables for customizing zoom behavior
@export var zoom_speed : float = 0.1       # Controls the speed of zoom in/out
@export var min_zoom : float = 0.5         # Minimum allowed zoom level
@export var max_zoom : float = 2.0         # Maximum allowed zoom level
@export var pan_speed : float = 500        # Controls the speed of panning (moving the map)

# Internal variables to track the map scale and position
var current_scale : float = 1              # Tracks the current zoom level
var is_dragging = false                    # Flag to check if the map is being dragged
var last_mouse_position = Vector2.ZERO     # Stores the position of the mouse during dragging

# References to the map texture and its size
@onready var map = $MapTexture              # The map texture node
@onready var map_size = map.size           # The size of the map texture
@onready var viewport_size = Vector2(get_viewport().get_visible_rect().size)


# This function is called when the scene is loaded
func _ready() -> void:
	# Calculate initial position to center the map in the viewport based on the current scale
	var initial_position = (viewport_size - map_size * current_scale) / 2
	map.position = initial_position
	_clamp_position()  # Ensure the map is within the viewport bounds


# This function is called every frame to update map position (pan) or zoom (mouse wheel)
func _process(delta: float) -> void:
	# Define a dictionary for pan directions using WASD keys
	var directions = {
		KEY_W: Vector2(0, pan_speed),    # Move map up (W)
		KEY_S: Vector2(0, -pan_speed),   # Move map down (S)
		KEY_A: Vector2(pan_speed, 0),    # Move map left (A)
		KEY_D: Vector2(-pan_speed, 0)    # Move map right (D)
	}

	# Loop through directions and pan the map if the corresponding key is pressed
	for key in directions.keys():
		if Input.is_key_pressed(key):  # Check if key is pressed
			map.position += directions[key] * delta  # Update map position
			_clamp_position()  # Ensure map stays within boundaries


# This function handles different input events (mouse, touch gestures, etc.)
func _input(event):
	if event is InputEventMouseButton:
		# Handle zooming in or out based on mouse wheel input
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_handle_wheel_input(zoom_speed, get_global_mouse_position())  # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_handle_wheel_input(-zoom_speed, get_global_mouse_position())  # Zoom out
	elif event is InputEventScreenDrag:
		# Handle dragging the map with touch input (for touch screens)
		_handle_touch_drag(event)
	elif event is InputEventMagnifyGesture:
		# Handle pinch zoom gestures on touch devices
		_handle_touch_pinch(event)


# This function handles zooming when the mouse wheel is used
func _handle_wheel_input(delta_zoom: float, global_mouse_position: Vector2):
	# Convert global mouse position to local position relative to the map
	var local_mouse_position = global_mouse_position - map.position
	var prev_scale = current_scale  # Store previous scale before zooming
	current_scale += delta_zoom     # Update the zoom level
	current_scale = clamp(current_scale, min_zoom, max_zoom)

	# Only apply zoom changes if there was a change in the zoom level
	if current_scale != prev_scale:
		# Calculate the ratio of scale change to adjust the map's position for zoom
		var scale_ratio = current_scale / prev_scale
		map.scale = Vector2.ONE * current_scale  # Update map's scale
		# Adjust the map position to keep the zoom centered around the mouse pointer
		var focal_point_delta = local_mouse_position * (scale_ratio - 1)
		map.position -= focal_point_delta
		zoom_changed.emit()  # Emit the signal that the zoom level changed

	# Ensure the map stays within the viewport boundaries
	_clamp_position()


# This function handles pinch-to-zoom gestures on touch devices (for touch zooming)
func _handle_touch_pinch(event: InputEventMagnifyGesture):
	# Calculate the zoom change based on the pinch gesture factor
	var delta_zoom = (event.factor - 1.0) * zoom_speed
	_handle_wheel_input(delta_zoom, get_global_mouse_position())


# This function ensures the map is within the boundaries of the viewport after zooming or panning
func _clamp_position() -> void:
	# Calculate the size of the map after scaling
	var scaled_map_size = map_size * current_scale
	# Calculate the allowed boundaries for the map's position
	var min_x = -(scaled_map_size.x - viewport_size.x)  # Minimum X position
	var max_x = 0  # Maximum X position (map can't go further right)
	var min_y = -(scaled_map_size.y - viewport_size.y)  # Minimum Y position (map can't go further up)
	var max_y = 0  # Maximum Y position (map can't go further down)

	# Clamp the map's position to ensure it stays within the allowed boundaries
	map.position.x = clamp(map.position.x, min_x, max_x)
	map.position.y = clamp(map.position.y, min_y, max_y)


# This function handles dragging the map with touch gestures
func _handle_touch_drag(event: InputEventScreenDrag) -> void:
	var prev_scale = current_scale  # Store the previous scale
	# Move the map based on the relative drag movement
	map.position += event.relative
	_clamp_position()  # Ensure map stays within bounds
	# Update the zoom scale and map position based on the drag
	current_scale = clamp(current_scale, min_zoom, max_zoom)

	# Only apply zoom changes if there was a scale change
	if current_scale != prev_scale:
		# Calculate the scale ratio to adjust the map's scale
		var scale_ratio = current_scale / prev_scale
		map.scale = Vector2.ONE * current_scale  # Update map's scale
		# Adjust the map position based on the drag to keep it centered
		var focal_point_delta = (event.position - map.position) * (scale_ratio - 1)
		map.position -= focal_point_delta
		zoom_changed.emit()  # Emit signal that zoom has changed

	# Ensure map stays within boundaries after dragging and zooming
	_clamp_position()
